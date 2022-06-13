#Assignment


#Path to the file we'll be checking for
$incomingFile = 'C:\temp\incoming\*'
$incomingFileDirect = 'C:\temp\incoming\'

#Path to where you want the outgoing file to go
$outgoingFile = 'C:\temp\outgoing\'

#Location of this script for scheduling purposes
$scriptLocation = 'C:\temp\scripts\#Assignment.ps1'

#Log file locations
$logPath = 'C:\temp\'

#Hashtable to hold file values
$fileContents = @{}

#Hashtable to hold values for the new file
$newFile = @()

#Current timestamp for new files
$currentTimestamp = Get-Date -Format "yyyyMMdHHmmss"

#Email Variables for setup based on your infrastructure
$emailTo = ''
$emailFrom = ''
$SMTP = ''
$username = ''
$password = ''

#Variables needed to scheduling the task
$scheduleSetTime = New-ScheduledTaskTrigger -Once -At 9:00 -RepetitionInterval (New-TimeSpan -Minutes 5)
$scheduleAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-File $scriptLocation"


#Emails Summary but method is considered obselete by Mircosoft
function sendEmailObselete() {
    $jobRunTime = Get-Date
    $entriesInFile = $fileContents.Count
    $entriesMoved = $newFile.Count
    $EmailTo = $emailTo
    $EmailFrom = $emailFrom
    $Subject = "CsvImport Results" 
    $Body = "Job Ran: $jobRunTime Entries in File: $entriesInFile Entries Moved to Outgoing: $entriesMoved" 
    $SMTPServer = $SMTP 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $password); 
    $SMTPClient.Send($SMTPMessage)
}

#Checking the contents of the file to see if we need to build a new file

function fileHandler() {

            $files = Get-ChildItem -Path $incomingFileDirect -filter *.csv 
            foreach ($f in $files)  {
                try {
                $file= Get-Item "$incomingFileDirect$f"
                $fileName = $file.BaseName
                #Insert file contents into the Hash Table fileContents
                $fileTable = Import-Csv -Path "$incomingFileDirect$fileName.csv"
                foreach ($entry in $fileTable)
                {$fileContents[$entry.name] = $entry.emailadress}
                #$fileContents
                #Check to see if there are records to move to a new files
                $properEmail = $fileContents.GetEnumerator().Where({$_.Value -like "*@abc.edu"})

                #Check if the email address we're looking for is here, if it is we move the entries to a new array to build an outgoing file with
                if ($properEmail) {

                    $newFile = $fileContents.GetEnumerator().Where({$_.Value -like "*@abc.edu"})
                    
                    $newFile | Export-Csv "$outgoingFile$filename$currentTimestamp.csv" -NoTypeInformation
                    (Import-Csv "$outgoingFile$filename$currentTimestamp.csv" | Select "Name", "Value" | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1) -replace '"' | Set-Content "C:\temp\outgoing\$filename$currentTimestamp.csv"
                    

                    # remove file from folder so that the same file isn't 
                    Remove-Item "$incomingFileDirect$fileName.csv"
                    #sendEmailObselete
                }
                
                #Creates a log file in C:\temp stating no files to move
                else {
                    New-Item -Path $logPath"NoRecord$currentTimestamp.log"
                    Set-Content $logPath"NoRecord$currentTimestamp.log" 'No Records to move at this time.'
                }

            }
 
            catch {
                throw $_.Exception.Message
            }
        }
       }


function checkFile() {

    #check if the file exists, it does we'll begin the process of reading through the file and checking the contents
    if (Get-ChildItem -Path $incomingFile -include *.csv) {
        fileHandler
        }
# If there is no file to process then ignore and log message stating such.
        else {
            New-Item -Path $logPath"NoFile$currentTimestamp.log"
            Set-Content $logPath"NoFile$currentTimestamp.log" 'No Files to move at this time.'
        }
}

#This function is used so that the script will schedule itself on first run, and on following runs it will just call checkFile to begin the script
function checkSchedule() {
    $task = "CsvImport"
    $taskAlreadyScheduled = Get-ScheduledTask | Where-Object {$_.TaskName -like $task}

    if($taskAlreadyScheduled) {
        checkFile
        }
    else {
        Register-ScheduledTask -TaskName "CsvImport" -Action $scheduleAction -Trigger $scheduleSetTime -AsJob
        checkFile

    } 
}


checkSchedule




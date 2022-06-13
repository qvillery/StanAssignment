# StanAssignment
Imports and Checks .csv files


This powershell script looks for a users.csv and pulls out users whose email address end with a @abc.edu

Note: You must be able to run scripts on your system to run this scripts

To enable this complete the following:
Open Powershell and enter "Set-ExceptionPolicy -ExecutionPolicy unrestricted -Scope CurrentUser"
I added Scope due to most department settings have it so you cannot edit the registry key so omitting Scope will throw back an error.

By default on first run the script will schedule itself as a task that will run every 5 minutes. The process should be handled as a job 

At the top of the script is a variable called $scriptLocation, edit this to the path location that you’ve saved the script to. There is also fileIncoming and fileIncomingDirect, both can be edited from their defaults of C:\temp\incoming\* and c:\temp\incoming\ respectively. The script defaults to sending the outgoing files to C:\temp\outgoing, you can change the variable $outgoingFile for point to where you'd like the new files to be placed. 

The Script also defaults to placing the log files in the C:\temp\, this can be changed by editing the $logPath variable to fit your needs.

There is also email variables that need to be set. Unfortunately, the method used by Powershell is considered obselete by Mircosoft and I do not know the infrastructure that is used by your department so these will need to be edited by the user running the script. This includes SMTP settings, email sender, email reciever, and username/password for the email sender. The script functions without the email portion if need be but you'll need to comment (#) out the function call within the function fileHandler().



How to run:
Download the “Assignment.ps1” file
Script should open in Windows Powershell or your default program for running .ps1. 

If using Visual Studio Code, then load the file and "Run and Debug" the program (F5 is the shortcut key)
The above method works for Windows Powershell ISE

To run using command line: powershell -"*insert path to the script here


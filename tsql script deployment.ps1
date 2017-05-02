<#
.SYNOPSIS
    ...
.DESCRIPTION
    ...
.PARAMETER
    ...
.INPUTS
    ...
.OUTPUTS
    ...
.NOTES
  Version:        0.0.0.9000
  Author:         mjfii
  Creation Date:  2017-04-20

.EXAMPLE
    
#>

# get timestamp
$ts = Get-Date -Format g

# get the instance name
[string]$server = Read-Host -Prompt 'Input the SQL Server Instance name'

if ($server -eq "") {
    Write-Host "No SQL Server instance name was specified, exiting process." -ForegroundColor Red
    Write-Host "Press any key to continue and exit script." -ForegroundColor Red
    Try 
     {
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
     } 
    Catch 
     {
        Write-Host " "
     }
    break
}

# get the instance name
[string]$catalog = Read-Host -Prompt 'Input the Database/Catalog name'

if ($catalog -eq "") {
    Write-Host "No Database/Catalog name was specified, exiting process." -ForegroundColor Red
    Write-Host "Press any key to continue and exit script." -ForegroundColor Red
    Try 
     {
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
     } 
    Catch 
     {
        Write-Host " "
     }
    break
}

#build connection strings and connect
try 
 { 
    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection

    if($un -and $pw) 
     { 
        $SQLConnection.ConnectionString = "Server=$server;Database=$catalog;User ID=$un;Password=$pw;" 
     } 
    else 
     { 
        $SQLConnection.ConnectionString = "Server=$server;Database=$catalog;Integrated Security=True;" 
     } 
    $SQLConnection.Open() 
 }
# if there is a connection error, alert and bail
catch
 {
    Write-Host " "
    Write-Host $Error[0] -ForegroundColor Red
    Write-Host "Press Enter to continue and exit script..." -ForegroundColor Red
    Try 
     {
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
     } 
    Catch 
     {
        Write-Host " "
     }
    break
 }

# figure out where we are and get the file path and name in variables
$scriptPath = $pwd.Path
$currentFolder = Split-Path -leaf -path ($scriptPath)
$currentFolder = $currentFolder -replace " ", "_"

# get the log file ready, delete file if it already exists
$logFile = $scriptPath + '\' + $currentFolder + '_execution.log'
Write-Host " "
Write-Host "All executions will be logged to this file:"
Write-Host $logFile

# remove the log file if it exists
if (Test-Path $logFile)
 {
    Remove-Item $logFile
 }

# begin the process of executing the scripts
Write-Host " "
Write-Host "Begin executing T-SQL scripts..."
Write-Host " "
Write-Host $ts
Write-Host " "

" " | Out-File $logfile -Append
"$ts" | Out-File $logfile -Append
" " | Out-File $logfile -Append
"T-Script Deployment Framework" | Out-File $logfile -Append
"-https://github.com/mjfii/TSQL-Script-Deployment-Framework" | Out-File $logfile -Append
"-mick.flanigan@gmail.com" | Out-File $logfile -Append
" " | Out-File $logfile -Append

# for each folder, iterate. exclude folders named '_wip'
$folders = @(Get-ChildItem -Path $scriptPath | Where-Object{($_.PSIsContainer) -and $_.Name -ne "_wip" }) | Sort-Object $_.Name
$folder = $folders[0]

foreach ($folder in $folders) {

    Write-Host "folder: $folder" -ForegroundColor Green

    # for each sql file we find, iterate through
    $files = @(Get-ChildItem -Path "$scriptPath\$folder" -Name '*.sql') | Sort-Object $_.Name
    
    if($files.Count -eq 0)
     {
        Write-Host "   there are not any .sql files in this folder..." -ForegroundColor White
     }

    foreach ($file in $files) {
    
        Write-Host "   script: $file" -ForegroundColor Green

        $fileText = @(Get-Content -Path $folder\$file) 

        foreach($wrk in $fileText) 
        { 
            if($wrk -ne "go") 
             { 
                $tsql += $wrk + "`r`n" #crlf
             } 
            else 
             { 
                
                $tsql = $tsql.TrimStart()
                $tsql = $tsql.TrimEnd()

                "----------------------------------------------------------------------------------------------------------------------------------------" | Out-File $logfile -Append 
                "Executing T-SQL statement from: $scriptPath\$folder\$file" | Out-File $logfile -Append 
                "----------------------------------------------------------------------------------------------------------------------------------------" | Out-File $logfile -Append 
                $tsql | Out-File $logfile -Append
                "go" | Out-File $logfile -Append
                "  " | Out-File $logfile -Append

                # execute the tsql statement
                try 
                 { 
                    $alert = "      tsql: " + $tsql.Substring(0,30).Trim() + "..."
                    Write-Host $alert -ForegroundColor Green
                    $cmd = New-Object System.Data.SqlClient.SqlCommand($tsql, $SQLConnection) 
                    $cmd.ExecuteScalar() | Out-File $logFile  -Append
                    "T-SQL executed sucessfully." | Out-File $logFile -Append
                 }
                catch 
                 { 
                    $error = $true 
                    Write-Host $Error[0] -ForegroundColor Red 
                    $Error[0] | Out-File $logFile  -Append 
                    "----------------------------------------------------------------------------------------------------------------------------------------" | Out-File $logfile -Append 
                 }

                $tsql = "" 
             }
        } # each sql statement
    } # each sql file

    Write-Host ""
} # each folder

#
$SQLConnection.Close() 

# add a footer to the log file
" " | Out-File $logfile -Append 
"----------------------------------------------------------------------------------------------------------------------------------------" | Out-File $logfile -Append 
"----------------------------------------------------------------------------------------------------------------------------------------" | Out-File $logfile -Append 
" " | Out-File $logfile -Append 
"Deployment complete and successful." | Out-File $logfile -Append 

# alert the end user of completion
Write-Host " "
Write-Host "Deployment complete and successful." 
Write-Host " "
Write-Host "Executions logged here: $logFile"
Write-Host " "
Write-Host "Press any key to continue..."

Try {
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
 } Catch {
    Write-Host " "
 }
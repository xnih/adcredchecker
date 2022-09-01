#Import Active Directory Module
Import-Module Activedirectory

 
#Vars
#Comment out if you want it to write to screen instead of a log file
$writeToLog = "True"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$logfile = $scriptPath + "\results.csv"  

#excel file location and sheet to look at for data
$file = $scriptPath + "\CompromisedPWList.xlsx"
$sheetNameHostList = "Sheet1"

#Create an instance of Excel.Application and Open Excel file
$objExcel = New-Object -ComObject Excel.Application
$workbook = $objExcel.Workbooks.Open($file)
$HostNameList = $workbook.Worksheets.Item($sheetNameHostList)
$objExcel.Visible=$false

	
Function Write-Log {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$False)]
      [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
      [String]$Level = "INFO",
      [Parameter(Mandatory=$True)]
      [string]$Message
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Message"
    If($writeToLog -eq "True") {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}



#Test User Credentials Function
Function TestUserCredentials($Username, $Password, $DomainFQDN, $passwordNoticeFrom)
{
   
    #Checks user credentials against the domain
    $DomainObj = "LDAP://" + $DomainFQDN

    Write-Host "`n"
    Write-Host "Checking Credentials for $DomainFQDN\$UserName" -BackgroundColor Black -ForegroundColor White
    Write-Host "***************************************"
		Try
		{
			$DomainBind = New-Object System.DirectoryServices.DirectoryEntry($DomainObj,$UserName,$Password)
			$DomainName = $DomainBind.distinguishedName
		}
		Catch
		{
			Write-Host "`n"
			Write-Host "Error: Bind issue: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
		}


    
    If ($DomainName -eq $Null)
        {
            #Write-Host "Domain $DomainFQDN was found: True" -BackgroundColor Black -ForegroundColor Green
        
            $UserExist = Get-ADUser -Server $DomainFQDN -Properties LockedOut -Filter {sAMAccountName -eq $UserName}
						#$UserExist = Get-ADUser $UserName
            If ($UserExist -eq $Null) 
							{
                Write-Host "Error: Username $Username does not exist in $DomainFQDN Domain." -BackgroundColor Black -ForegroundColor Red
                Write-Log "DEBUG" "$username`tUserDoesNotExist`t$passwordNoticeFrom"
              }
						Else
							{
								Write-Host "Authentication failed for $DomainFQDN\$UserName with the password supplied" -BackgroundColor Black -ForegroundColor Red
								Write-Log "DEBUG" "$username`tPasswordFailed`t$passwordNoticeFrom"
							}
        }
     
    Else
        {
					Write-Host "SUCCESS: The account $Username successfully authenticated against the domain: $DomainFQDN" -BackgroundColor Black -ForegroundColor Green
					Write-Log "DEBUG" "$username`tPasswordNeedsChanged`t$passwordNoticeFrom"
        }
}    


#User list
#Count number of users to process
$MaxCount = ($HostNameList.UsedRange.Rows).count
#Declare the starting positions
$rowNumber = 1



for ($i=1; $i -le $MaxCount-1; $i++) {
  $currentRow = $rowNumber + $i
  $name = $HostNameList.Cells.Item($currentRow,1).text
  #try to get local domain, if you need to hard code it uncomment/comment correct lines below
  #$ADdomainFQDN = "somedomain.local"
  $ADdomainFQDN = Get-ADDomain -Current LocalComputer | select forest
  $password = $HostNameList.Cells.Item($currentRow,3).text
  $passwordNoticeFrom = $HostNameList.Cells.Item($currentRow,4).text

  Write-Host "$currentRow of $MaxCount"
  if (-not ([string]::IsNullOrEmpty($name))) {
    TestUserCredentials $name $password $ADdomainFQDN.forest $passwordNoticeFrom
  }
}
#close excel file
$objExcel.quit() 

#finish off some log file stuff
$date = Get-Date -Format "yyyy-MM-dd"
$filename = "final-results-" + $date  + ".txt" 
Rename-Item -Path $logfile -NewName $filename


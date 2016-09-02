<#
# 
# createADUsers.ps1
# Author: Nathan Crum
# Date: 2016-09-02
# Version: 1.0.0
#
#>
Import-Module ActiveDirectory

# Store secure credentials to access the intended domain
$cred = Get-Credential

# Convert and import the content of the json configuration file as an object
$data = (gc "C:\Users\20453065\Documents\Visual Studio 2015\Projects\createADUsers\createADUsers\users.json" -RAW) | ConvertFrom-Json

# Store an array of users obtained from the json file
$users = $data.employees

# Store the security groups assigned to the user provided as the employee template 
$groups = Get-ADUser -Identity $data.modelUser `
			-Properties memberof `
			-Server $data.domain `
			-Credential $cred | `
			Select-Object -ExpandProperty memberof

# Create All Users from Source then add them to the correct security group
for($i = 0; $i -le $users.count; $i++){
	
	Write-Host ([string]::Concat("Creating user ", $users[$i].samAccountName,"..."))
	
	New-ADUser `
		-Name ([string]::Concat($users[$i].first_name," ",$users[$i].last_name)) `
		-GivenName $users[$i].first_name `
		-Surname $users[$i].last_name `
		-Path $data.path `
		-SamAccountName $users[$i].samAccountName `
		-UserPrincipalName $users[$i].samAccountName `
		-DisplayName ([string]::Concat($users[$i].first_name," ",$users[$i].last_name)) `
		-AccountPassword (ConvertTo-SecureString $data.passwordTemplate -AsPlainText -Force) `
		-ChangePasswordAtLogon $true `
		-Enabled $true
	
	Write-Host ([string]::Concat("Adding member groups to ", $users[$i].samAccountName))
	$groups | Add-ADGroupMember -Members $users[$i].samAccountName -Server xrxss.com -Credential $cred
}
Write-Host "!--Task completed--!"
# Import SyncroMSP Module
Import-Module $env:SyncroModule -WarningAction SilentlyContinue

# Requires the following Script Variables be added in SyncroMSP
# $assetname : "Variable Type = Platform", "Vaule = {{asset_name}}"
# $ToRestartTypeYes : "Variable Type = Runtime"
# $NewComputerName : "Variable Type = Runtime"

# Ticket Variables for the Subject and Ticket Body
$ticksub = "Computer Asset Renamed - " + $assetname + " renamed to " + $NewComputerName
$tickbody = "Computer was renamed from " + $assetname + " to " + $NewComputerName + " via script. The name will autoupdate the next time the asset refreshes."
# Make the ticket comments public or private
$tickprivate = "True"

# Check if computer is domain joined
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    $username = (Get-WmiObject Win32_ComputerSystem).Domain+"\$DomainAdminUserName"
    $password = ConvertTo-SecureString -String "$DomainAdminPassword" -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
    Rename-Computer -NewName "$NewComputerName" -DomainCredential $credential
}
else {
    Rename-Computer -newname "$NewComputerName"
}

# Restart the computer for rename to take effect
if ($ToRestartTypeYes -eq 'Yes') {
    Restart-Computer -Force
}

# Create New Ticket to Rename Asset
$newtick = Create-Syncro-Ticket -Subject $ticksub -IssueType "Remote Support" -Status "New"
Create-Syncro-Ticket-Comment -TicketIdOrNumber $newtick.ticket.id -Subject "INITIAL ISSUE" -Body $tickbody -Hidden $tickprivate

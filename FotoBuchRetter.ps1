$originalPathStart = '<origin_path>'
$originalPathEnd = '</origin_path>'
$position = 0
$count = 0

#Browsing file
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = "Aldi Projekt (*.cpr)| *.cpr"
$FileBrowser.Title = "Fotobuch Datei wählen"
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileName

$doNumeration = $false





function Get-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]$Message = "Bitte wählen sie ein Zielverzeichnis.",

        [Parameter(Mandatory=$false, Position=1)]
        [string]$InitialDirectory,

        [Parameter(Mandatory=$false)]
        [System.Environment+SpecialFolder]$RootFolder = [System.Environment+SpecialFolder]::Desktop,

        [switch]$ShowNewFolderButton
    )
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description  = $Message
    $dialog.SelectedPath = $InitialDirectory
    $dialog.RootFolder   = $RootFolder
    $dialog.ShowNewFolderButton = if ($ShowNewFolderButton) { $true } else { $false }
    $selected = $null

    # force the dialog TopMost
    # Since the owning window will not be used after the dialog has been 
    # closed we can just create a new form on the fly within the method call
    $result = $dialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    if ($result -eq [Windows.Forms.DialogResult]::OK){
        $selected = $dialog.SelectedPath
    }
    # clear the FolderBrowserDialog from memory
    $dialog.Dispose()
    # return the selected folder
    $selected
} 

Function Get-ShouldNumerate
{

    $title    = 'Dateien Sortieren'
    $question = 'Möchten sie die Dateien nach der Reihenfolge im Fotobuch nummerieren?'

    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        $doNumeration = $true
    } else {
        $doNumeration = $false
    }

    $doNumeration
}

$FolderNavn = Get-Folder
$doNumeration = Get-ShouldNumerate

# Write-Output $FolderNavn



# Write-Output $doNumberation
get-content $FileBrowser.FileName -ReadCount 1000 |
foreach { 
    $lines = $_ -match $originalPathStart
    foreach ($line in $lines) 
    {    
        $oldFileName = $line.Replace($originalPathStart, "").Replace($originalPathEnd, "")
        $oldFileName = $oldFileName.Trim()
        
        $count++
        
        if($doNumeration)
        {
            $newFileName = $folderNavn + "\" + $count + "_" + $oldFileName.Split("/")[-1]
        } else {
            $newFileName = $folderNavn + "\" + $oldFileName.Split("/")[-1]
        }

        

        $op =  "Datei: " + $count + " " + $oldFileName  + "  ->  " + $newFileName
        # Write-Output $op
        
        Copy-Item $oldFileName $newFileName
    }
}



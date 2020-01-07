PowerShell.exe -windowstyle hidden {
##########################################################################
#####****************************************************************#####
####******************************************************************####
###********************************************************************###
##****           _________________________________________       *******##
##****          |                                         |      *******##
##****   () ()  |  phlashko - 7 Jan 2020 - Version 1      |      *******##
##****   ( ^_^) <_________________________________________|      *******##
##****   ((")(")                                                 *******##
###***                                                           ******###
###*******************************************************************####
####*****************************************************************#####
##########################################################################

##########################################################################
# ****** This allows for dialog boxes to be utilized in the script *******
##########################################################################
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

##########################################################################
# ******************** This is the gui container *************************
##########################################################################
$folderForm = New-Object System.Windows.Forms.Form
$folderForm.Text = "Phlashko's ADS Tool"
$folderForm.Size = "365,160"

##########################################################################
# ******************** This is the file location box *********************
##########################################################################
$pathTextBox = New-Object System.Windows.Forms.TextBox

$pathTextBox.Location = '23,23'
$pathTextBox.Size = '228,23'

$folderForm.Controls.Add($pathTextBox)

##########################################################################
# **************** This adds Select button to the gui ******************** 
##########################################################################
$selectButton = New-Object System.Windows.Forms.Button

$selectButton.Text = 'Select'
$selectButton.Location = '254,22'

$folderForm.Controls.Add($selectButton)

##########################################################################
# ******** This makes the select button enable file selection ************
##########################################################################
$folderBrowser = New-Object System.Windows.Forms.OpenFileDialog

$selectButton.Add_Click({
    $folderBrowser.ShowDialog()
    $pathTextBox.Text = $folderBrowser.filename
})

##########################################################################
# **************** This adds the ADS button to the gui ******************* 
##########################################################################
$ADSButton = New-Object System.Windows.Forms.Button

$ADSButton.Text = 'ADS'
$ADSButton.Location = '23,53'

##########################################################################
# ********* This makes the ADS button perform Alternate Data Stream ******
##########################################################################

$ADSButton.Add_Click({
   Get-item -Path $pathTextBox.Text -Stream * | Out-GridView
})

$folderForm.Controls.Add($ADSButton)

##########################################################################
# **************** This adds FileSize button to the gui ****************** 
##########################################################################
$FileSizeButton = New-Object System.Windows.Forms.Button

$FileSizeButton.Text = 'File Size'
$FileSizeButton.Location = '100,53'

$folderForm.Controls.Add($FileSizeButton)

##########################################################################
# ************ This makes the FileSize Button display size in MB *********
##########################################################################
$FileSizeButton.Add_Click({
   $file = $pathTextBox.Text 
   $size = Get-ChildItem $file -recurse | Measure-Object -property length -sum
   $convert = $size.sum / 1MB
   $SizeTitle = "Size in MB"
   [System.Windows.MessageBox]::Show($convert,$SizeTitle)
})

##########################################################################
# **************** This adds SHA hash button to the gui ****************** 
##########################################################################
$SHAButton = New-Object System.Windows.Forms.Button

$SHAButton.Text = "SHA Hash's"
$SHAButton.Location = '177,53'

$folderForm.Controls.Add($SHAButton)

##########################################################################
#  This makes the SHA Button display the sha1, sha256, and sha512 hashes *
##########################################################################
$SHAButton.Add_Click({
    $file = $pathTextBox.Text
    %{Get-FileHash -Algorithm MD5 -Path $file; Get-FileHash -Algorithm SHA1 -Path $file ; Get-FileHash -Algorithm SHA256 -Path $file ; Get-FileHash -Algorithm SHA512 -Path $file} | Out-GridView
})

##########################################################################
# ****************** This adds MD5 hash button to the gui **************** 
##########################################################################
$MD5Button = New-Object System.Windows.Forms.Button

$MD5Button.Text = 'MD5 Hash'
$MD5Button.Location = '254,53'

$folderForm.Controls.Add($MD5Button)

##########################################################################
# ************ This makes the MD5 Button display the MD5 hash ************
##########################################################################
$MD5Button.Add_Click({
    $file = $pathTextBox.Text
    %{certutil.exe -hashfile $file md5} | Out-GridView  
})

##########################################################################
# **************** This adds Hide Files button to the gui **************** 
##########################################################################
$HideFileButton = New-Object System.Windows.Forms.Button

$HideFileButton.Text = 'Hide Files'
$HideFileButton.Location = '23,84'

$folderForm.Controls.Add($HideFileButton)

##########################################################################
#This makes the Hide Files Button hide a user prompted message to the file *
##########################################################################
$HideFileButton.Add_Click({
    $file = $pathTextBox.Text
    $folderBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $folderBrowser.ShowDialog()
    $value = $folderBrowser.filename
    $getcont = Get-Content $value
    $StreamText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your stream name", "Desired Stream Name?")
    Add-Content -Path $file -Value $getcont -Stream $StreamText
    Get-item -Path $pathTextBox.Text -Stream * | Out-GridView
})

##########################################################################
# **************** This adds See Hidden File button to the gui *********** 
##########################################################################
$SeeADSButton = New-Object System.Windows.Forms.Button

$SeeADSButton.Text = 'See Hidden'
$SeeADSButton.Location = '100,84'

$folderForm.Controls.Add($SeeADSButton)

##########################################################################
# ******** This makes the See Hidden Button hide a user selected file ****
##########################################################################
$SeeADSButton.Add_Click({
    $StreamText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Stream Name", "Exact Stream Name Only?")
    $combo = $pathTextBox.Text + ":" + $StreamText
    Get-Content $combo | Out-GridView
})

##########################################################################
# **************** This adds Kill ADS File button to the gui *************** 
##########################################################################
$KillADSButton = New-Object System.Windows.Forms.Button

$KillADSButton.Text = 'Kill ADS'
$KillADSButton.Location = '177,84'

$folderForm.Controls.Add($KillADSButton)

##########################################################################
# **** This makes the Kill ADS Button unhide a user selected file *****
##########################################################################
$KillADSButton.Add_Click({
    $file = $pathTextBox.Text
    $StreamText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Stream Name to remove", "Exact Stream Name Only?")
    remove-item -stream $StreamText $file
    Get-item -Path $pathTextBox.Text -Stream * | Out-GridView
})

##########################################################################
# ************* This adds the Delete File button to the gui ************** 
##########################################################################
$DelButton = New-Object System.Windows.Forms.Button

$DelButton.Text = 'Delete File'
$DelButton.Location = '254,84'
$DelButton.BackColor = 'Red'

$folderForm.Controls.Add($DelButton)

##########################################################################
# ************ This makes the remove Button the selected file ************
##########################################################################
$DelButton.Add_Click({
    $file = $pathTextBox.Text
    Remove-Item -Path $file -Force
})

##########################################################################
# ****** This is the end that shows everything above on one nice gui *****
##########################################################################
$folderForm.ShowDialog()
}

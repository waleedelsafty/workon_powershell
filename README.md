# workon_powershell
adding workon (virtualenv) to powershell



this small  solution to installing virtualenv on windows

after installing your virtualenv   using the command [pip install virtualenv]  you may still  have trouble  getting the workon command  to work  in your powershell  .  or  it may work  with very limited information   that doesnt tell you much except the name of  availble  environment 

you can overcome this problem by adding a custom script  to your powershell profile to  make it recognise  the workon keyword  that may only work in regular  cmd prompt  and not  your  powershell 

   to do so    you need  to create a VirtualEnvWrapper.psm1 file and save it  in your  documents folder 
c:\users\username\Documents\WindowsPowerShell\modules\ 
or just add this [file](./VirtualEnvWrapper.psm1) to your c:\users\username\Documents\WindowsPowerShell

```powershell
.
.
.
# SOFTWARE.

# modified by waleed elsafty     elsafty.waleed@gmail.com 20-may2020

$WORKON_HOME=$Env:WORKON_HOME
$VIRTUALENWRAPPER_HOOK_DIR=''
$Version = "0.2.0"
.
.

#
# Powershell alias for naming convention
#
Set-Alias lsenv Get-VirtualEnvs 
Set-Alias lsvirtualenv Get-VirtualEnvs  
Set-Alias rmvirtualenv Remove-VirtualEnv 
Set-Alias mkvirtualenv New-VirtualEnv
Set-Alias getvertualenvver Get-VirtualEnvVersion


Write-Host "Virtual Env Wrapper for Powershell activated"

```

  this is the suggested location of the file but you can save it anywhere on your machine as long as  you dave it in a location that powershell would have access  to 
  
  then you modify   the powershell profile.ps1 (by default it  would be located  in  your  <User Name>\Documents\WindowsPowerShell folder 
   and add the folowing lines to it :
```powershell
  $MyDocuments = [environment]::getfolderpath("mydocuments")
  Import-Module $MyDocuments\WindowsPowerShell\VirtualEnvWrapper.psm1
```
  
your  windows 10  would have a folder called [WindowsPowerShell]  in your  c:\Users\<username>\Documents     for the default powershell that comes  with windowss 10 <  and if  you have updraded  to   a newer version of powershell  you will   have nother directory in the same Documents folder  with the name [powershell]   and each would have its own profile.ps1 that will be used by iether version of powershell when you  open it , ( you may apply the change  to both  if  you want of  chose only one of them  to work with the updated  workon script





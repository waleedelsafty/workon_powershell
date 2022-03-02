# workon_powershell
adding workon (virtualenv) to powershell



this small  solution to installing virtualenv on windows

after installing your virtualenv   using the command [pip install virtualenv]  you may still  have trouble  getting the workon command  to work  in your powershell  .  or  it may work  with very limited information   that doesnt tell you much except the name of  availble  environment 

you can overcome this problem by adding a custom script  to your powershell profile to  make it recognise  the workon keyword  that may only work in regular  cmd prompt  and not  your  powershell 

   to do so    you need  to create a VirtualEnvWrapper.psm1 file and save it  in your  documents folder 
c:\users\username\Documents\WindowsPowerShell\modules\ 
or just add this [file](./VirtualEnvWrapper.psm1) to your c:\users\username\Documents\WindowsPowerShell


  this is the suggested location of the file but you can save it anywhere on your machine as long as  you dave it in a location that powershell would have access  to 
  
  then you modify   the powershell profile.ps1 (by default it  would be located  in  your  <User Name>\Documents\WindowsPowerShell folder 
   and add the folowing lines to it :
```powershell
  $MyDocuments = [environment]::getfolderpath("mydocuments")
  Import-Module $MyDocuments\WindowsPowerShell\VirtualEnvWrapper.psm1
```
  
your  windows 10  would have a folder called [WindowsPowerShell]  in your  c:\Users\<username>\Documents     for the default powershell that comes  with windowss 10 <  and if  you have updraded  to   a newer version of powershell  you will   have nother directory in the same Documents folder  with the name [powershell]   and each would have its own profile.ps1 that will be used by iether version of powershell when you  open it , ( you may apply the change  to both  if  you want of  chose only one of them  to work with the updated  workon script

your  windows 10  would have a folder called [WindowsPowerShell]  in your  c:\Users\<username>\Documents     for the default powershell that comes  with windowss 10 <  and if  you have updraded  to   a newer version of powershell  you will   have nother directory in the same Documents folder  with the name [powershell]   and each would have its own profile.ps1 that will be used by iether version of powershell when you  open it , ( you may apply the change  to both  if  you want of  chose only one of them  to work with the updated  workon script
your  windows 10  would have a folder called [WindowsPowerShell]  in your  c:\Users\<username>\Documents     for the default powershell that comes  with windowss 10 <  and if  you have updraded  to   a newer version of powershell  you will   have nother directory in the same Documents folder  with the name [powershell]   and each would have its own profile.ps1 that will be used by iether version of powershell when you  open it , ( you may apply the change  to both  if  you want of  chose only one of them  to work with the updated  workon script



![workon1](https://user-images.githubusercontent.com/51638781/156271651-369d2c42-1b23-4b1c-a502-9221a3ae4e66.png)
![workon2](https://user-images.githubusercontent.com/51638781/156271656-3df2b096-f624-49e7-8ac0-4d3a659467ba.png)
![workon3](https://user-images.githubusercontent.com/51638781/156271658-6439e633-1c28-435b-bb0b-93db6b9bf477.png)




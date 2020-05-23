# workon_powershell
adding workon (virtualenv) to powershell



this small  solution to installing virtualenv on windows

after installing your virtualenv   using the command [pip install virtualenv]  you may still  have trouble  getting the workon command  to work  in your powershell  .  or  it may work  with very limited information   that doesnt tell you much except the name of  availble  environment 

you can overcome this problem by adding a custom script  to your powershell profile to  make it recognise  the workon keyword  that may only work in regular  cmd prompt  and not  your  powershell 

   to do so    you need  to create a VirtualEnvWrapper.psm1 file and save it  in your  documents folder 
c:\users\username\Documents\WindowsPowerShell\modules\   

  this is the suggested location of the file but you can save it anywhere on your machine as long as  you dave it in a location that powershell would have access  to 
  
  then you modify   the powershell profile.ps1 (by default it  would be located  in  your  <User Name>\Documents\WindowsPowerShell folder 
   and add the folowing lines to it :
  
  $MyDocuments = [environment]::getfolderpath("mydocuments")
  Import-Module $MyDocuments\WindowsPowerShell\VirtualEnvWrapper.psm1

#
# Python virtual env manager inspired by VirtualEnvWrapper
#
# Copyright (c) 2017 Regis FLORET
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# modified by waleed elsafty     elsafty.waleed@gmail.com 20-may2020

function is_it_Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

$WORKON_HOME=$Env:WORKON_HOME
$VIRTUALENWRAPPER_HOOK_DIR=''
$Version = "0.2.0"

#
# Set the default path and create the directory if don't exist
#
if (!$WORKON_HOME) {
    $WORKON_HOME = "$Env:USERPROFILE\Envs"
}

if ((Test-Path $WORKON_HOME) -eq $false) {
    mkdir $WORKON_HOME
}

#
# Get the absolute path for the environment
#
function Get-FullPyEnvPath($pypath) {
    return ("{0}\{1}" -f $WORKON_HOME, $pypath)
}

# 
# Display a formated error message
#
function Write-FormatedError($err) {
    Write-Host 
    Write-Host "  ERROR: $err" -ForegroundColor Red
    Write-Host 
}

#
# Display a formated success messge
#
function Write-FormatedSuccess($err) {
    Write-Host 
    Write-Host "  SUCCESS: $err" -ForegroundColor Green
    Write-Host 
}

#
# Retrieve the python version with the path the python exe regarding the version. 
# Python < 3.3 is for this function a Python 2 because the module venv comes with python 3.3
#
# Return the major version of python 
#
function Get-PythonVersion($Python) {
    if (!(Test-Path $Python)) {
        Write-FormatedError "$Python doesn't exist"
        return
    }

    $python_version = Invoke-Expression "& '$Python' --version 2>&1"
    if (!$Python -and !$python_version) {
        Write-Host "I don't find any Python version into your path" -ForegroundColor Red
        return 
    }

    $is_version_2 = ($python_version -match "^Python\s2") -or ($python_version -match "^Python\s3.3")
    $is_version_3 = $python_version -match "^Python\s3" -and !$is_version_2
    
    if (!$is_version_2 -and !$is_version_3) {
        Write-FormatedError "Unknown Python Version expected Python 2 or Python 3 got $python_version"
        return 
    }

    return $(if ($is_version_2) {"2"} else {"3"})
}

#
# Common command to create the Python Virtual Environement. 
# $Command contains either the Py2 or Py3 command
#
function Invoke-CreatePyEnv($Command, $Name) {
    $NewEnv = Join-Path $WORKON_HOME $Name
    Write-Host "Creating virtual env... "
    
    Invoke-Expression "$Command '$NewEnv'"
    
    $VEnvScritpsPath = Join-Path $NewEnv "Scripts"
    $ActivatepPath = Join-Path $VEnvScritpsPath "activate.ps1"
    . $ActivatepPath

    Write-FormatedSuccess "$Name virtual environment was created and your're in."
}

#
# Create Python Environment using the VirtualEnv.exe command
#
function New-Python2Env($Python, $Name)  {
 Write-Host "Started New-Python2Env ($ Python ='$Python' , $ Name = '$Name')"

    $Command = (Join-Path (Join-Path (Split-Path $Python -Parent) "Scripts") "virtualenv.exe")
    if ((Test-Path $Command) -eq $false) {
        Write-FormatedError "You must install virtualenv program to create the Python virtual environment '$Name'"
        return 
    }
    Invoke-CreatePyEnv $Command $Name
}
    
# 
# Create Python Environment using the venv module
# 
function New-Python3Env($Python, $Name) {
 Write-Host "Started New-python3ENV  ($ Python ='$Python' , $ Name = '$Name')"
    if (!$Python) {
        $PythonExe = Find-Python
    } else {
        $PythonExe = Join-Path (Split-Path $Python -Parent) "python.exe"
    }

    $Command = "& '$PythonExe' -m venv"

    Invoke-CreatePyEnv $Command $Name
}

#
# Find python.exe in the path. If $Python is given, try with the given path
#
function Find-Python ($Python) {

    # The path contains the python executable
    if ($Python.EndsWith('python.exe'))
    {
        if (!(Test-Path $Python)) 
        {
            return $false
        }
        return $Python
    }
    
 if (Is_it_Numeric $Python){
 $result = & invoke-Expression "py -0p" | Out-String

 foreach ($line in $result.Split([Environment]::NewLine).Where({ $_ -ne "" }))
{
        Do {        
        $line = $line -replace "  ", " "
        $line = $line -replace "  ", " "
        } # End of 'Do'
        While ($line -contains "  ")

  $pyArray   = $line.split(" ").Where({ $_ -ne "" })
  $pyName    = $pyArray[0]
  $pyVersion = $pyArray[0].split("-").Where({ $_ -ne "" })[0]
  $pybits    = $pyArray[0].split("-").Where({ $_ -ne "" })[1]
  $pyPath    = $pyArray[1]

  if ($python -eq $pyVersion )
  {

  return $pyPath
  }
}
 } else {
 
 Write-Host  " the version of python you have provided [$python] did not match any of the python versions recognised by your py.exe luncher ... "
 Write-Host  " Trying to create  virtualenv with default python on your system  "
 }
    # No python given, get the default one
    if (!$Python) {
        return Get-Command "python.exe" | Select-Object -ExpandProperty Source
    }

    # The python path doesn't exist
    if (!(Test-Path $Python)) {
        return $false
    }
    
    # The pas is a directory path not a executable path
    $PythonExe = Join-Path $Python "python.exe"
    if (!(Test-Path $PythonExe)) {
        return $false
    }

    return $PythonExe
}

#
# Create the Python Environment regardless the Python version
#
function New-PythonEnv($Python, $Name, $Packages, $Append) {

    if ($Python -eq 2) {
    $version = 2
    } elseif ($Python -eq 3){
    $version = 3
    }
    else {
    $version = Get-PythonVersion $Python
    }
    BackupPath
    if ($Append) {
        $Env:PYTHONPATH = "$Append;$($Env:PYTHONPATH)"
    }

    if ($Version -eq "2") {
        New-Python2Env -Python $Python -Name $Name 
    } elseif ($Version -eq "3") {
    
        New-Python3Env -Python $Python -Name $Name 
    } else {
        Write-FormatedError "This is the debug voice. I expected a Python version, got $Version"
        RestorePath        
    }    
}

function BackupPath {
    $Env:OLD_PYTHON_PATH = $Env:PYTHONPATH
}

function RestorePath {
    $Env:PYTHONPATH = $Env:OLD_PYTHON_PATH
    $Env:Path = $Env:OLD_SYSTEM_PATH
}

# 
# Test if there's currently a python virtual env
#
function Get-IsInPythonVenv($Name) {
    if ($Env:VIRTUAL_ENV) {
        if ($Name) {
            if (([string]$Env:VIRTUAL_ENV).EndsWith($Name)) {
                return $true
            }

            return $false;
        }

        return $true
    }

    return $false
}

# Now, work on a env
function Workon {
    Param(
        [string] $Name
    )

    if (!$Name) {
        Write-FormatedError "No python venv to work on. Did you forget the -Name option?"
        Get-VirtualEnvs
        Write-Host "`tchose one of the listed invironments  and type in [workon <env-name>]"
        Write-Host 
        Write-Host "`tto create a new virtual environment   use the  on of the folowing commands: " 
        Write-Host "`tmkvirtualenv -python <Version Number> <NewEnvNAME>" -ForegroundColor Green          
        Write-Host "`t`tmkvirtualenv -python 2.7 my_venv27" -ForegroundColor Yellow    
        Write-Host "`tmkvirtualenv -python <Python.exe full path> <NewEnvNAME>" -ForegroundColor Green      
        Write-Host "`t`tmkvirtualenv -python D:\Python2.7.18\Python.exe my_venv27" -ForegroundColor Yellow 
        Write-Host
        return
    }

    $new_pyenv = Get-FullPyEnvPath $Name
    if ((Test-Path $new_pyenv) -eq $false) {
        Get-VirtualEnvs
        Write-Host "`tThe Python Vertual Environment "-nonewline; Write-Host "'$Name'" -f Red -nonewline; 
        Write-Host " don't exists.";
        Write-Host "`t`You may want to create it with " -nonewline; 
        Write-Host "'PS>MkVirtualEnv -python <python version number> $Name'" -ForegroundColor Green                
        Write-Host "`t example 'PS>mkvirtualenv -python 2.7 $Name '" -ForegroundColor Yellow    
        Write-Host "`t chose one of the listed invironments  and type in [" -nonewline; Write-Host "workon "-nonewline -f Yellow;; Write-Host "$Name"-nonewline -f Red; Write-Host "]";

       
        return
    }

    if (Get-IsInPythonVenv -eq $true) {
        Deactivate
    }

    $activate_path = "$new_pyenv\Scripts\Activate.ps1"
    if ((Test-path $activate_path) -eq $false) {
        Write-FormatedError "Enable to find the activation script. You Python environment $Name seems compromized"
        return
    }
    
    . $activate_path

    $Env:OLD_PYTHON_PATH = $Env:PYTHON_PATH
    $Env:VIRTUAL_ENV = "$new_pyenv"
}

# 
# Create a new virtual environment. 
#
function New-VirtualEnv {
    Param(
        [Parameter(HelpMessage="The virtual env name")]
        [string]$Name,

        [Parameter(HelpMessage="The requirements file")]
        [alias("r")]
        [string]$Requirement,

        [Parameter(HelpMessage="The Python directory where the python.exe lives")]
        [string]$Python,

        [Parameter(HelpMessage="The package to install. Repeat the parameter for more than one")]
        [alias("i")]
        [string[]]$Packages,

        [Parameter(HelpMessage="Associate an existing project directory to the new environment")]
        [alias("a")]
        [string]$Associate
    )


    if ($Name.StartsWith("-")) {
        Write-FormatedError "The virtual environment name couldn't start with - (minus)"
        return
    }

    if ($Append -and !(Test-Path $Append)) {
        Write-FormatedError "The path '$Append' doesn't exist"
        return
    }

    if (!$Name) {
        Write-FormatedError "You must at least give me a PyEnv name"
        return
    }

    if ((IsPyEnvExists $Name) -eq $true) {
        Write-FormatedError "There is an environment with the same name"
        return
    }
    
    Write-Host "Trying to get PythonRealPath = Find-Python Python:'$Python'"
    $PythonRealPath = Find-Python $Python
    if (!$PythonRealPath) {
        Write-FormatedError "The path to access to python doesn't exist. Python directory = $Python"
        return
    }
    New-PythonEnv -Python $PythonRealPath -Name $Name 
    
    foreach($Package in $Packages)  {
        Invoke-Expression "$WORKON_HOME\$Name\Scripts\pip.exe install $Package"
    }


    if ($Requirement -ne "") {
        if (! $(Test-Path $Requirement)) {
            Write-Error "The requirement file doesn't exist"
            Break
        }

        Invoke-Expression "$WORKON_HOME\$Name\Scripts\pip.exe install -r $Requirement"
    }
 
}


#
# Check if there is an environment named $Name
#
function IsPyEnvExists($Name) {
    $children = Get-ChildItem $WORKON_HOME

    if ($children.Length -gt 0) {
        for ($i=0; $i -lt $children.Length; $i++) {
            if (([string]$children[$i]).CompareTo($Name) -eq 0) {
                return $true
            }
        }
    }

    return $false
}


function Get-VirtualEnvs {
  $children = Get-ChildItem -Directory -name -Exclude  .*  @($WORKON_HOME)
  Write-Host "`tYour Python Virtual Environments Directory is:"
  Write-Host "`t"$WORKON_HOME"\" -f Yellow; 
  Write-Host 
  Write-host ("`t{0,-32}{1,-24}{2,-30}" -f  "Vertual Environment Name ",         "Python version", "date created")
  Write-host ("`t{0,-32}{1,-24}{2,-30}" -f  "=========================","===============","========================")

    if ($children.count -eq 1) {  
    # must defrentiate  between only one virtual env and multiple because powershell for loon  would  count number of items or number of letters in one item and scrow everything up
            $timeCreated = Get-ItemPropertyValue -Path $WORKON_HOME"\"$children -Name LastWriteTime
            $PythonVersion = (((Invoke-Expression ("$WORKON_HOME\$children\Scripts\Python.exe --version 2>&1" -f $child)) -replace "`r|`n","") -Split " ")[1]
            #Write-Host ("`t{0,-25}{1,-18}{2,-30}" -f $child ,$PythonVersion,$timeCreated)   -Color Yellow, Green
            Write-Host ("`t{0,-30}" -f $children )   -ForegroundColor Yellow -NoNewline
            Write-Host ("`t{0,-18}" -f $PythonVersion)   -ForegroundColor  Green -NoNewline
            Write-Host ("`t{0,-0}" -f $timeCreated)   -ForegroundColor DarkGreen

   } 
   elseif ($children.count -gt 1) {
        for($i = 0; $i -lt $children.count; $i++) {
            $child = $children[$i]
            $timeCreated = Get-ItemPropertyValue -Path $WORKON_HOME"\"$child -Name LastWriteTime
            $PythonVersion = (((Invoke-Expression ("$WORKON_HOME\{0}\Scripts\Python.exe --version 2>&1" -f $child)) -replace "`r|`n","") -Split " ")[1]
            #Write-Host ("`t{0,-25}{1,-18}{2,-30}" -f $child ,$PythonVersion,$timeCreated)   -Color Yellow, Green
            Write-Host ("`t{0,-30}" -f $child )   -ForegroundColor Yellow -NoNewline
            Write-Host ("`t{0,-18}" -f $PythonVersion)   -ForegroundColor  Green -NoNewline
            Write-Host ("`t{0,-0}" -f $timeCreated)   -ForegroundColor DarkGreen
            }
   } 
   else {
     Write-Host "`tNo Python Environments found"
   }
   Write-Host "`t================================================================================"
   Write-Host
    
}



#
# Remove a virtual environment.
#
function Remove-VirtualEnv {
    Param(
        [string]$Name
    )
    
    if ((Get-IsInPythonVenv $Name) -eq $true) {
        Write-FormatedError "You want to destroy the Virtual Env you are in. Please type 'deactivate' before to dispose the environment before"
        return
    }

    if (!$Name) {
        Write-FormatedError "You must fill a environmennt name"
        return
    }

    $full_path = Get-FullPyEnvPath $Name
    if ((Test-Path $full_path) -eq $true) {
        Remove-Item -Path $full_path -Recurse 
        Write-FormatedSuccess "$Name was deleted permanently"
    } else {
        Write-FormatedError "$Name not found"
    }
}

#
# Get the current version of VirtualEnvWrapper
#
function Get-VirtualEnvVersion() {
    Write-Host "Version $Version"
}

#
# Powershell alias for naming convention
#
Set-Alias lsenv Get-VirtualEnvs 
Set-Alias lsvirtualenv Get-VirtualEnvs  
Set-Alias rmvirtualenv Remove-VirtualEnv 
Set-Alias mkvirtualenv New-VirtualEnv
Set-Alias getvertualenvver Get-VirtualEnvVersion


Write-Host "Virtual Env Wrapper for Powershell activated"

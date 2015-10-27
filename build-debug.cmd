call "%ProgramFiles(x86)%\Embarcadero\RAD Studio\11.0\bin\rsvars.bat"
MSBuild /target:Build /p:Config=Debug source\Mods.Checker.dproj

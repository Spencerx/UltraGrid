#Set-PSDebug -Trace 1

# Free some space - TODO: regular uninstall would be better
Remove-Item -Recurse "C:\Program Files (x86)\Android"
Remove-Item -Recurse "C:\Program Files (x86)\dotnet"

# Install CUDA
if (!${env:no_cuda}) {
  Invoke-WebRequest https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_441.22_win10.exe -OutFile cuda_inst.exe
  Start-Process -FilePath "cuda_inst.exe" -ArgumentList "-s nvcc_10.2" -Wait -NoNewWindow
  Remove-Item cuda_inst.exe
  echo "::add-path::C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.2\bin"
}

# Install XIMEA
if (${env:sdk_pass}) {
  $pair = "sdk:${env:sdk_pass}"
  $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
  $basicAuthValue = "Basic $encodedCreds"
  $Headers = @{Authorization = $basicAuthValue}
  Invoke-WebRequest -Headers $Headers https://frakira.fi.muni.cz/~xpulec/sdks/ximea.zip -OutFile ximea.zip
  Expand-Archive -LiteralPath 'ximea.zip' -DestinationPath 'C:\'
  Remove-Item ximea.zip
}

# Install NDI
if (${env:sdk_pass} -and ${env:GITHUB_REF} -eq "refs/heads/ndi-build") {
  $pair = "sdk:${env:sdk_pass}"
  $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
  $basicAuthValue = "Basic $encodedCreds"
  $Headers = @{Authorization = $basicAuthValue}
  Invoke-WebRequest -Headers $Headers https://frakira.fi.muni.cz/~xpulec/sdks/NDI%204%20SDK.exe -OutFile C:\ndi.exe
  # TODO: NDI installer opens a manual in a browser and doesn't end, thus StartProcess with -Wait
  # waits infinitely. Therefore, there is a hack with Sleep (and not removint the installer)
  #Start-Process -FilePath "C:\ndi.exe" -ArgumentList "/VERYSILENT" -Wait -NoNewWindow
  Start-Process -FilePath "C:\ndi.exe" -ArgumentList "/VERYSILENT"
  Sleep 10
  $sdk=(dir "C:\Program Files\NewTek" -Filter *SDK -Name)
  echo "::add-path::C:\Program Files\NewTek\$sdk\Bin\x64"
  #Remove-Item C:\ndi.exe
}


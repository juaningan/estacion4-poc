[System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")

# Install chocolatey
Get-ExecutionPolicy
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install puppet
choco install -y puppet-agent

# Install consul
$default = '{ "start_join": ["192.168.50.2"], "bind_addr": "{{ GetAllInterfaces | include \"network\" \"192.168.50.0/24\"  | sort \"size,address\" | attr \"address\" }}" }'
$watches = '{ "watches": [ { "type": "event", "name": "puppet-apply", "handler": "/usr/local/bin/puppet.sh" } ] }'
New-Item -ItemType Directory -Force -Path $env:ProgramData\consul\config
$default | Set-Content $env:ProgramData\consul\config\default.json
$watches | Set-Content $env:ProgramData\consul\config\watches.json
choco install -y consul

# Install fsconsul
$fsconsul_source = "https://bintray.com/cimpress-mcp/Go/download_file?file_path=v0.6.5%2Fwindows-amd64%2Ffsconsul.exe"
$fsconsul_dest = "$env:ProgramData\chocolatey\bin\fsconsul.exe"
$webclient = New-Object system.net.webclient
$webclient.DownloadFile($fsconsul_source,$fsconsul_dest)


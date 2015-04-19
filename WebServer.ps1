#function Load-Packages
#{
#    param ([string] $directory = 'Packages')
#    $assemblies = Get-ChildItem $directory -Recurse -Filter '*.dll' | Select -Expand FullName
#    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
#}
#
#Load-Packages

$staticPath = "D:\temp\sandbox\Powershell\root"

$routes = @{
    "/hello" = { return '<html><h1>Hello world!</h1></html>' }
	"/" =  { return '<html><body>root</body></html>' }
}

$url = 'http://localhost:8080/'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Listening at url $url..."
& 'C:\Program files\Internet Explorer\iexplore.exe' @('http://localhost:8080/hello')

while ($listener.IsListening)
{
    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $response = $context.Response

    Write-Host "$requestUrl"

    $localPath = $requestUrl.LocalPath
	Write-Host "localPath $localPath" 
    $route = $routes.Get_Item($requestUrl.LocalPath)
	Write-Host "route $route " 

    if ($route -eq $null)
    {	
		#check if static file exists
		$fileFullName = [System.IO.Path]::Combine($staticPath, $localPath.Replace("/",""))
		if(Test-Path $fileFullName){
			$content = Get-Content $fileFullName |  Out-String
		}
        else{
			$response.StatusCode = 404
		}
    }
	else{
		 $content = & $route
	}
    if($content -ne $null)
    {
       
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()

    $responseStatus = $response.StatusCode
    Write-Host "$responseStatus"
}

$sig = @'
[DllImport("User32.dll")]
'@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info 
$balloon.BalloonTipText = " Soild work GDI 偵測已啟動"
$balloon.Visible = $true 
$balloon.ShowBalloonTip(0)
while(1){
    $soildwork_gdi=0
    $processes = [System.Diagnostics.Process]::GetProcesses()
    [int]$gdiHandleCount = 0
    ForEach ($p in $processes)
    {
        try{
            $gdiHandles = [Win32.NativeMethods]::GetGuiResources($p.Handle, 0)
            $gdiHandleCount += $gdiHandles
            if($p.Name -eq "SLDWORKS"){
                $soildwork_gdi+=$gdiHandles
            }
        }
        catch {
            #"Error accessing " + $p.Name
        }
    }
    if($soildwork_gdi -ge 6000){
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon
        $path = (Get-Process -id $pid).Path
        $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
        $balloon.BalloonTipText = " Soild work GDI 數量已達到：" + $soildwork_gdi + ",建議您關閉並重新開啟 Soild Works"
        $balloon.BalloonTipTitle = "Soild Works GDI過高" 
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(0)
    }
    Start-Sleep -Seconds 60
}

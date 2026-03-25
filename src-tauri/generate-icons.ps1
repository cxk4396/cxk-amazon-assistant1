# 生成 Tauri 图标 - 本地 PowerShell 脚本
# 在 src-tauri 目录运行

Add-Type -AssemblyName System.Drawing

$ sizes = @(32, 128, 256, 512)

# 创建大图标
$size = 512
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(255, 153, 0))

$font = New-Object System.Drawing.Font("Arial", 200, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center

$g.DrawString("CXK", $font, $brush, $size/2, $size/2, $format)

# 保存各种尺寸
foreach ($s in $sizes) {
    $newBmp = New-Object System.Drawing.Bitmap($bmp, $s, $s)
    $newBmp.Save("icons/$($s)x$($s).png", [System.Drawing.Imaging.ImageFormat]::Png)
    $newBmp.Save("icons/$($s)x$($s)@2x.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $newBmp.Dispose()
}

# 保存 ICO 文件 (256x256)
$iconBmp = New-Object System.Drawing.Bitmap($bmp, 256, 256)
$iconBmp.Save("icons/icon.ico", [System.Drawing.Imaging.ImageFormat]::Icon)
$iconBmp.Dispose()

# 保存 ICNS (复制 PNG)
$bmp.Save("icons/icon.icns", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$font.Dispose()

Write-Host "Icons generated successfully!"

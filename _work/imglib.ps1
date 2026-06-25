Add-Type -AssemblyName System.Drawing

$Global:SRC = "C:\Users\User\OneDrive\Desktop\10k websites plan\images for Cravings"
$Global:OUT = "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\assets\img"
$Global:TRIM = "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\_work\trimmed"

function Save-Jpeg([System.Drawing.Bitmap]$bmp, [string]$path, [int]$quality=84) {
  $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatID -eq [System.Drawing.Imaging.ImageFormat]::Jpeg.Guid }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
  $bmp.Save($path, $enc, $ep)
  $ep.Dispose()
}

# Returns array of per-row mean brightness from a small proxy of the image
function Get-RowProfile([System.Drawing.Bitmap]$bmp, [int]$pw=96) {
  $ph = [int]([math]::Round($bmp.Height * ($pw / $bmp.Width)))
  $proxy = New-Object System.Drawing.Bitmap($pw, $ph)
  $g = [System.Drawing.Graphics]::FromImage($proxy)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear
  $g.DrawImage($bmp, 0, 0, $pw, $ph)
  $g.Dispose()
  $rows = New-Object 'double[]' $ph
  for ($y=0; $y -lt $ph; $y++) {
    $s = 0.0
    for ($x=0; $x -lt $pw; $x++) {
      $p = $proxy.GetPixel($x,$y)
      $s += ($p.R*0.299 + $p.G*0.587 + $p.B*0.114)
    }
    $rows[$y] = $s / $pw
  }
  $proxy.Dispose()
  return ,$rows
}

# Find the longest vertical run of "bright" rows (the real photo / card)
function Find-ContentBand([System.Drawing.Bitmap]$bmp, [double]$thresh=85) {
  $rows = Get-RowProfile $bmp
  $ph = $rows.Length
  $bestS=-1; $bestLen=0; $curS=-1; $curLen=0
  for ($y=0; $y -lt $ph; $y++) {
    if ($rows[$y] -gt $thresh) {
      if ($curS -lt 0) { $curS=$y }
      $curLen++
      if ($curLen -gt $bestLen) { $bestLen=$curLen; $bestS=$curS }
    } else { $curS=-1; $curLen=0 }
  }
  $y0 = [double]$bestS / $ph
  $y1 = [double]($bestS + $bestLen) / $ph
  return @($y0, $y1)
}

# Crop a fractional rectangle of a source image, optional max width, save JPEG
function Crop-Frac([string]$srcFile, [double]$x0,[double]$y0,[double]$x1,[double]$y1, [string]$outName, [int]$maxW=0, [int]$q=84) {
  $img = [System.Drawing.Bitmap]::new((Join-Path $Global:SRC $srcFile))
  $W=$img.Width; $H=$img.Height
  $sx=[int]($x0*$W); $sy=[int]($y0*$H); $sw=[int](($x1-$x0)*$W); $sh=[int](($y1-$y0)*$H)
  $dw=$sw; $dh=$sh
  if ($maxW -gt 0 -and $sw -gt $maxW) { $scale=$maxW/$sw; $dw=$maxW; $dh=[int]($sh*$scale) }
  $dest = New-Object System.Drawing.Bitmap($dw,$dh)
  $g=[System.Drawing.Graphics]::FromImage($dest)
  $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $srcRect = New-Object System.Drawing.Rectangle($sx,$sy,$sw,$sh)
  $dstRect = New-Object System.Drawing.Rectangle(0,0,$dw,$dh)
  $g.DrawImage($img,$dstRect,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  Save-Jpeg $dest (Join-Path $Global:OUT $outName) $q
  "{0}  ->  {1}  ({2}x{3})" -f $srcFile,$outName,$dw,$dh
  $dest.Dispose(); $img.Dispose()
}

# Auto-trim IG chrome (keep longest bright band), optional max width
function Trim-Chrome([string]$srcFile, [string]$outName, [int]$maxW=0, [double]$inset=0.004, [int]$q=84, [string]$dest=$Global:TRIM) {
  $img = [System.Drawing.Bitmap]::new((Join-Path $Global:SRC $srcFile))
  $band = Find-ContentBand $img
  $y0 = [math]::Min(0.99, $band[0] + $inset)
  $y1 = [math]::Max($y0+0.05, $band[1] - $inset)
  $img.Dispose()
  $W=738.0
  Crop-Frac $srcFile 0.0 $y0 1.0 $y1 $outName $maxW $q | Out-Null
  # re-point output dir for trimmed pass
  "{0} -> {1}  band[{2:N3},{3:N3}]" -f $srcFile,$outName,$band[0],$band[1]
}

# Isolate the bright circular logo -> transparent circular PNG
function Make-Logo([string]$srcFile, [string]$outName, [int]$size=512) {
  $img = [System.Drawing.Bitmap]::new((Join-Path $Global:SRC $srcFile))
  $pw=96; $ph=[int]([math]::Round($img.Height*($pw/$img.Width)))
  $proxy=New-Object System.Drawing.Bitmap($pw,$ph)
  $g=[System.Drawing.Graphics]::FromImage($proxy); $g.DrawImage($img,0,0,$pw,$ph); $g.Dispose()
  $minx=$pw; $miny=$ph; $maxx=0; $maxy=0
  for($y=0;$y -lt $ph;$y++){ for($x=0;$x -lt $pw;$x++){ $p=$proxy.GetPixel($x,$y); $b=($p.R*0.299+$p.G*0.587+$p.B*0.114); if($b -gt 165){ if($x -lt $minx){$minx=$x}; if($x -gt $maxx){$maxx=$x}; if($y -lt $miny){$miny=$y}; if($y -gt $maxy){$maxy=$y} } } }
  $proxy.Dispose()
  $fx0=$minx/$pw; $fx1=($maxx+1)/$pw; $fy0=$miny/$ph; $fy1=($maxy+1)/$ph
  $cx=($fx0+$fx1)/2; $cy=($fy0+$fy1)/2
  $halfW=($fx1-$fx0)/2; $halfH=($fy1-$fy0)/2; $half=[math]::Max($halfW,$halfH)*1.02
  $W=$img.Width; $H=$img.Height
  $sx=[int](($cx-$half)*$W); $sy=[int](($cy-$half)*$H); $sd=[int]($half*2*$W)
  if($sx -lt 0){$sx=0}; if($sy -lt 0){$sy=0}
  $dest=New-Object System.Drawing.Bitmap($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g2=[System.Drawing.Graphics]::FromImage($dest)
  $g2.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g2.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $path=New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(0,0,$size,$size)
  $g2.SetClip($path)
  $srcRect=New-Object System.Drawing.Rectangle($sx,$sy,$sd,$sd)
  $dstRect=New-Object System.Drawing.Rectangle(0,0,$size,$size)
  $g2.DrawImage($img,$dstRect,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
  $g2.Dispose()
  $dest.Save((Join-Path $Global:OUT $outName),[System.Drawing.Imaging.ImageFormat]::Png)
  "logo {0} -> {1}  bbox x[{2:N2},{3:N2}] y[{4:N2},{5:N2}]" -f $srcFile,$outName,$fx0,$fx1,$fy0,$fy1
  $dest.Dispose(); $img.Dispose()
}
Write-Host "imglib loaded"

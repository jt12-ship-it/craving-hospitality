. "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\_work\imglib.ps1"
$Global:OUT = "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\assets\img"
function Crop-Item([string]$srcFile,[double]$b0,[double]$b1,[double]$tx0,[double]$ty0,[double]$tx1,[double]$ty1,[string]$out,[int]$maxW=600){
  $oy0=$b0+$ty0*($b1-$b0); $oy1=$b0+$ty1*($b1-$b0)
  Crop-Frac $srcFile $tx0 $oy0 $tx1 $oy1 $out $maxW 90 | Out-Null; "  -> $out"
}
$S1="WhatsApp Image 2026-06-25 at 12.05.39 AM.jpeg"
$S2="WhatsApp Image 2026-06-25 at 12.05.40 AM (2).jpeg"
$SAL="WhatsApp Image 2026-06-25 at 12.05.40 AM (1).jpeg"
$bS0=0.072; $bS1=0.894
# tighter sandwich ovals
Crop-Item $S1 $bS0 $bS1 0.03 0.295 0.45 0.395 "sand-chicken-avocado.jpg"
Crop-Item $S1 $bS0 $bS1 0.50 0.350 0.99 0.450 "sand-chicken-caesar.jpg"
Crop-Item $S1 $bS0 $bS1 0.01 0.575 0.44 0.680 "sand-crab-corn.jpg"
Crop-Item $S1 $bS0 $bS1 0.50 0.690 0.99 0.795 "sand-chicken-pesto.jpg"
Crop-Item $S2 $bS0 $bS1 0.02 0.280 0.46 0.385 "sand-roast-beef.jpg"
Crop-Item $S2 $bS0 $bS1 0.50 0.345 0.99 0.455 "sand-halloumi-pesto.jpg"
Crop-Item $S2 $bS0 $bS1 0.01 0.585 0.45 0.690 "sand-tuna.jpg"
Crop-Item $S2 $bS0 $bS1 0.50 0.695 0.99 0.800 "sand-deli-ham.jpg"
Crop-Item $SAL $bS0 $bS1 0.55 0.185 0.875 0.315 "salad-chicken-caesar.jpg" 640
"DONE2"

# bigger contact sheet
Add-Type -AssemblyName System.Drawing
$IMG=$Global:OUT
$files=@("logo.png","sand-roast-beef.jpg","sand-halloumi-pesto.jpg","sand-tuna.jpg","sand-deli-ham.jpg","sand-chicken-avocado.jpg","sand-chicken-caesar.jpg","sand-crab-corn.jpg","sand-chicken-pesto.jpg","salad-chicken-caesar.jpg","salad-crab-citrus.jpg","salad-greek-feta.jpg")
$cols=3; $cell=300; $pad=16; $lbl=24
$rows=[math]::Ceiling($files.Count/$cols)
$W=$cols*$cell+($cols+1)*$pad; $H=$rows*($cell+$lbl)+($rows+1)*$pad
$bmp=New-Object System.Drawing.Bitmap($W,$H); $g=[System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(247,244,227)); $g.InterpolationMode='HighQualityBicubic'; $g.SmoothingMode='AntiAlias'
$font=New-Object System.Drawing.Font("Arial",10); $brush=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(31,77,46))
for($i=0;$i -lt $files.Count;$i++){
  $c=$i%$cols; $r=[math]::Floor($i/$cols)
  $x=$pad+$c*($cell+$pad); $y=$pad+$r*($cell+$lbl+$pad)
  $im=[System.Drawing.Image]::FromFile((Join-Path $IMG $files[$i]))
  $sc=[math]::Min($cell/$im.Width,$cell/$im.Height); $dw=[int]($im.Width*$sc); $dh=[int]($im.Height*$sc)
  $g.DrawImage($im,[int]($x+($cell-$dw)/2),[int]($y+($cell-$dh)/2),$dw,$dh); $im.Dispose()
  $g.DrawString($files[$i],$font,$brush,$x,$y+$cell+2)
}
$g.Dispose(); $out="C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\_work\contact2.png"
$bmp.Save($out,[System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); "saved $out"
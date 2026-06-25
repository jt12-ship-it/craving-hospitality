. "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\_work\imglib.ps1"
$FINAL = "C:\Users\User\OneDrive\Desktop\10k websites plan\craving-hospitality\assets\img"
$Global:OUT = $FINAL

# crop a sub-region expressed in TRIMMED-band fractions, mapping back to the original screenshot
function Crop-Item([string]$srcFile,[double]$b0,[double]$b1,[double]$tx0,[double]$ty0,[double]$tx1,[double]$ty1,[string]$out,[int]$maxW=600){
  $oy0 = $b0 + $ty0*($b1-$b0)
  $oy1 = $b0 + $ty1*($b1-$b0)
  Crop-Frac $srcFile $tx0 $oy0 $tx1 $oy1 $out $maxW 88 | Out-Null
  "  item -> $out"
}

# Logo fix: explicit pixel circle from the original profile shot
function Make-LogoPx([string]$srcFile,[string]$out,[int]$cx,[int]$cy,[int]$r,[int]$size=512){
  $img=[System.Drawing.Bitmap]::new((Join-Path $Global:SRC $srcFile))
  $dest=New-Object System.Drawing.Bitmap($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g=[System.Drawing.Graphics]::FromImage($dest)
  $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $path=New-Object System.Drawing.Drawing2D.GraphicsPath; $path.AddEllipse(0,0,$size,$size); $g.SetClip($path)
  $src=New-Object System.Drawing.Rectangle(($cx-$r),($cy-$r),(2*$r),(2*$r))
  $dst=New-Object System.Drawing.Rectangle(0,0,$size,$size)
  $g.DrawImage($img,$dst,$src,[System.Drawing.GraphicsUnit]::Pixel); $g.Dispose()
  $dest.Save((Join-Path $Global:OUT $out),[System.Drawing.Imaging.ImageFormat]::Png)
  "logo -> $out"; $dest.Dispose(); $img.Dispose()
}

$S1 = "WhatsApp Image 2026-06-25 at 12.05.39 AM.jpeg"      # sands1
$S2 = "WhatsApp Image 2026-06-25 at 12.05.40 AM (2).jpeg"  # sands2
$SAL= "WhatsApp Image 2026-06-25 at 12.05.40 AM (1).jpeg"  # salads
$MOOD="WhatsApp Image 2026-06-25 at 12.05.42 AM.jpeg"      # mood
$CP = "WhatsApp Image 2026-06-25 at 12.05.41 AM (3).jpeg"  # chicken pesto cloche
$HAL= "WhatsApp Image 2026-06-25 at 12.05.42 AM (1).jpeg"  # halloumi
$TUNA="WhatsApp Image 2026-06-25 at 12.05.40 AM.jpeg"
$ROST="WhatsApp Image 2026-06-25 at 12.05.41 AM.jpeg"      # rosto before/after
$CRBS="WhatsApp Image 2026-06-25 at 12.05.41 AM (1).jpeg"  # crab on salad
$GC = "WhatsApp Image 2026-06-25 at 12.05.40 AM (3).jpeg"  # greek/caesar split

$band = 0.822  # sands/salads card span (0.072..0.894)
$bS0=0.072; $bS1=0.894
$bM0=0.245; $bM1=0.827

"== LOGO =="
Make-LogoPx "WhatsApp Image 2026-06-25 at 12.05.43 AM.jpeg" "logo.png" 369 727 242 512

"== SANDWICH THUMBS =="
Crop-Item $S1 $bS0 $bS1 0.01 0.26 0.45 0.40 "sand-chicken-avocado.jpg"
Crop-Item $S1 $bS0 $bS1 0.47 0.29 1.00 0.45 "sand-chicken-caesar.jpg"
Crop-Item $S1 $bS0 $bS1 0.00 0.55 0.45 0.70 "sand-crab-corn.jpg"
Crop-Item $S1 $bS0 $bS1 0.47 0.64 1.00 0.80 "sand-chicken-pesto.jpg"
Crop-Item $S2 $bS0 $bS1 0.01 0.25 0.47 0.40 "sand-roast-beef.jpg"
Crop-Item $S2 $bS0 $bS1 0.47 0.30 1.00 0.46 "sand-halloumi-pesto.jpg"
Crop-Item $S2 $bS0 $bS1 0.00 0.55 0.46 0.70 "sand-tuna.jpg"
Crop-Item $S2 $bS0 $bS1 0.47 0.65 1.00 0.81 "sand-deli-ham.jpg"

"== SALAD BOWLS =="
Crop-Item $MOOD $bM0 $bM1 0.30 0.33 0.50 0.57 "salad-crab-citrus.jpg" 640
Crop-Item $MOOD $bM0 $bM1 0.51 0.33 0.71 0.57 "salad-greek-feta.jpg" 640
Crop-Item $SAL  $bS0 $bS1 0.53 0.17 0.90 0.33 "salad-chicken-caesar.jpg" 640

"== GALLERY POSTS (final, resized) =="
$posts = @{
 $CP   = @("post-chicken-pesto.jpg",1100)
 $HAL  = @("post-halloumi.jpg",1100)
 $TUNA = @("post-tuna.jpg",1100)
 $ROST = @("post-rosto.jpg",1100)
 $CRBS = @("post-crab-salad.jpg",1100)
 $GC   = @("post-greek-caesar.jpg",1100)
 $MOOD = @("post-mood.jpg",1100)
 $S1   = @("poster-sands1.jpg",1000)
 $S2   = @("poster-sands2.jpg",1000)
 $SAL  = @("poster-salads.jpg",1000)
}
foreach($k in $posts.Keys){ Trim-Chrome $k $posts[$k][0] $posts[$k][1] 0.004 86 | Out-Null; "  post -> $($posts[$k][0])" }

"DONE-GEN"
Get-ChildItem $FINAL -File | Sort-Object Name | ForEach-Object { "{0,-28} {1,7:N0} KB" -f $_.Name, ($_.Length/1KB) }
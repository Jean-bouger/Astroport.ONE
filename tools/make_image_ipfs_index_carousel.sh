#!/bin/bash
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "$MY_PATH/my.sh"

#Set Path to Images
img_dir="$1"
[[ ! -d $img_dir ]] && echo "Not a directory" && exit 1

#Set Path to HTML page
html_file="/tmp/index.html"

#Create HTML page
echo "<!DOCTYPE html>
<html>
<head>
<title>Astroport IPFS Gallery</title>
<meta charset=\"UTF-8\">
<link rel=\"stylesheet\" href=\"${myIPFSGW}/ipfs/QmX9QyopkTw9TdeC6yZpFzutfjNFWP36nzfPQTULc4cYVJ/bootstrap.min.css\">
<style>
.carousel-item {
    background-color: #0B0C10;
}
.carousel-indicators li {
    background-color: #0B0C10;
}
.carousel-indicators .active {
    background-color: #FFFFFF;
}
</style>
</head>
<body>

<div class=\"container\">
  <h2> Astroport IPFS $(myPlayer) Gallery $(date) </h2>
  <div id=\"myCarousel\" class=\"carousel slide\" data-ride=\"carousel\">
    <!-- Indicators -->
    <ul class=\"carousel-indicators\">
      <li data-target=\"#myCarousel\" data-slide-to=\"0\" class=\"active\"></li>" > $html_file

#Loop over images
num=1
for i in "$img_dir"/*; do
if [[ $i =~ \.(JPG|jpg|PNG|png|JPEG|jpeg|GIF|gif)$ ]]; then
  if [ $num -ne 1 ]; then
    echo "      <li data-target=\"#myCarousel\" data-slide-to=\"$num\"></li>" >> $html_file
  fi
  num=$((num+1))
fi
done

echo "    </ul>

    <!-- The slideshow -->
    <div class=\"carousel-inner\">" >> $html_file

#Loop over images
num=1
for i in "$img_dir"/*; do
if [[ $i =~ \.(JPG|jpg|PNG|png|JPEG|jpeg|GIF|gif)$ ]]; then
  ilink=$(ipfs add -q $i)
  img_info=$(identify -format '%w %h %[EXIF:*]' $i)
  img_width=$(echo $img_info | cut -d ' ' -f1)
  img_height=$(echo $img_info | cut -d ' ' -f2)
  img_alt=$(echo $img_info | cut -d ' ' -f3)
  if [ $num -eq 1 ]; then
    echo "      <div class=\"carousel-item active\">
        <img src=\"${myIPFSGW}/ipfs/$ilink\" alt=\"$img_alt\" width=\"$img_width\" height=\"$img_height\">
      </div>" >> $html_file
  else
    echo "      <div class=\"carousel-item\">
        <img src=\"${myIPFSGW}/ipfs/$ilink\" alt=\"$img_alt\" width=\"$img_width\" height=\"$img_height\">
      </div>" >> $html_file
  fi
  num=$((num+1))
fi
done

echo "    </div>

    <!-- Left and right controls -->
    <a class=\"carousel-control-prev\" href=\"#myCarousel\" data-slide=\"prev\">
      <span class=\"carousel-control-prev-icon\"></span>
    </a>
    <a class=\"carousel-control-next\" href=\"#myCarousel\" data-slide=\"next\">
      <span class=\"carousel-control-next-icon\"></span>
    </a>
  </div>
</div>

<script src=\"${myIPFSGW}/ipfs/QmX9QyopkTw9TdeC6yZpFzutfjNFWP36nzfPQTULc4cYVJ/jquery-3.2.1.slim.min.js\"></script>
<script src=\"${myIPFSGW}/ipfs/QmX9QyopkTw9TdeC6yZpFzutfjNFWP36nzfPQTULc4cYVJ/popper.min.js\"></script>
<script src=\"${myIPFSGW}/ipfs/QmX9QyopkTw9TdeC6yZpFzutfjNFWP36nzfPQTULc4cYVJ/bootstrap.min.js\"></script>

</body>
</html>" >> $html_file

htmlipfs=$(ipfs add -q $html_file)
xdg-open ${myIPFSGW}/ipfs/$htmlipfs

exit 0
#!/bin/bash
# lista zainstalowanych fontow
fc-list | cut -d ':' -f2

#napis wodny
convert blured.jpeg -font Suruma -pointsize 50 -draw "gravity SouthEast fill white text 100,50 'Copyright@ Cool IT Help' " wmark_Output.jpg

gsettings get org.gnome.desktop.interface monospace-font-name |  sed "s/'//g" | cut -d " " -f1
xrandr --output DP-0 --primary
xrandr --output DP-0 --mode 3440x1440 --rate 165.00 --right-of DP-4
echo "monitor 1 set..."
xrandr --output DP-2 --mode 2560x1440 --rate 165.00 --right-of DP-0
echo "monitor 2 set..."
xrandr --output DP-4 --mode 2560x1440 --rate 165.00 --left-of DP-0
echo "monitor 3 set..."

# not using nitrogen for now
#nitrogen --restore
#echo "restored wallpapers..."

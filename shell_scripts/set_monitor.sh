MONITOR_MIDDLE=DP-0
xrandr --output $MONITOR_MIDDLE --primary
xrandr --output $MONITOR_MIDDLE --mode 3440x1440 --rate 165.00
echo "monitor 1 set..."

#MONITOR_LEFT=DP-4
#MONITOR_RIGHT=DP-0
#xrandr --output $MONITOR_RIGHT --mode 2560x1440 --rate 165.00 --right-of $MONITOR_MIDDLE
#echo "monitor 2 set..."
#xrandr --output $MONITOR_LEFT --mode 2560x1440 --rate 165.00 --left-of $MONITOR_MIDDLE
#echo "monitor 3 set..."


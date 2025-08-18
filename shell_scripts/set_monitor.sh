MONITOR_LEFT=eDP-1-1
MONITOR_RIGHT=DVI-I-2-1

echo "left: $MONITOR_LEFT"
echo "right: $MONITOR_RIGHT"

xrandr --output $MONITOR_RIGHT --primary
xrandr --output $MONITOR_RIGHT --mode 3440x1440 --rate 99.98 --right-of $MONITOR_LEFT
echo "monitor 1 set..."
xrandr --output $MONITOR_LEFT --mode 1920x1200 --rate 59.95 --left-of $MONITOR_MIDDLE
echo "monitor 2 set..."

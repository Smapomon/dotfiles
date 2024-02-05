nohup ferdium &
nohup slack &
nohup discord-ptb &
nohup solaar &
nohup diodon &
nohup fcitx5
echo "Apps started..."

#echo "Checking spotify state..."

#runnin_instances=$(wmctrl -l | grep "Spotify" | wc -l)
#runnin_instances=${runnin_instances:-0}

#if [ $runnin_instances -eq 0 ]; then
	#echo "$runnin_instances"
	#nohup spotify &
	#echo "Spotify started..."
#else
	#echo "Spotify already running..."
#fi

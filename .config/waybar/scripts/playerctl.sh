#!/usr/bin/env bash
exec 2>"$XDG_RUNTIME_DIR/waybar-playerctl.log"
IFS=$'\n\t'

while true; do
	while read -r playing position length name artist title arturl hpos hlen; do
		playing=${playing:1} position=${position:1} length=${length:1} name=${name:1}
		artist=${artist:1} title=${title:1} arturl=${arturl:1} hpos=${hpos:1} hlen=${hlen:1}
		line="${artist:+$artist ${title:+- }}${title:+$title }${hpos:+$hpos${hlen:+|}}$hlen"

		line="${line//\"/\\\"}"
		((percentage = length ? (100 * (position % length)) / length : 0))
		case $playing in
		⏸️ | Paused) text='<span foreground=\"#cccc00\" size=\"smaller\">'"$line"'</span>' ;;
		▶️ | Playing) text="<small>$line</small>" ;;
		*) text='<span foreground=\"#073642\">⏹</span>' ;;
		esac

		printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
			"$text" "$playing $name | $line" "$percentage" "$percentage" || break 2

	done < <(
		playerctl --follow metadata --player playerctld --format \
			$':{{emoji(status)}}\t:{{position}}\t:{{mpris:length}}\t:{{playerName}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}\t:{{mpris:artUrl}}\t:{{duration(position)}}\t:{{duration(mpris:length)}}' &
		echo $! >"$XDG_RUNTIME_DIR/waybar-playerctl.pid"
	)

	echo '<span foreground=#dc322f>⏹</span>' || break
	sleep 15
done

kill "$(<"$XDG_RUNTIME_DIR/waybar-playerctl.pid")"

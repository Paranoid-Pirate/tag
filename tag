#!/bin/sh
# tag, a simple script to tag music via ffmpeg. Doesnt work with vorbis

verbose=0
clean=1

help_message() {
	echo "USAGE: tag -(?) input myfile.flac"
	echo "-h, --help       brings up this menu"
	echo "-a, --album"
	echo "-t, --title"
	echo "-c, --comment"
	echo "-g, --genre"
	echo "--grab           outputs metadata for file"
	echo "  USAGE: tag -g myfile.flac"
	echo "--track          the track number of the file"
	echo "--cover          sets the cover art for the file"
	echo "  USAGE: tag --cover myfile.flac cover.png"
	echo "--grab-cover     grabs the cover art of the file"
	echo "  USAGE: tag --grab-cover myfile.flac cover.png"
	echo "--artist"
	echo "--album-artist"
	exit 0
}

tag_ffmpeg() {
	if [ $verbose = 0 ]; then
		ffmpeg -hide_banner -loglevel 16 -i "$3" -c:a copy -metadata $1="$2" "$(echo $3 | rev | cut -c6- | rev).$1.flac"
		if [ $clean = 1 ]; then
			rm "$3"
			mv "$(echo $3 | rev | cut -c6- | rev).$1.flac" "$3"
		fi
	else
		ffmpeg -i "$3" -c:a copy -metadata $1="$2" "$(echo $3 | rev | cut -c6- | rev).$1.flac"
		if [ $clean = 1 ]; then
			rm "$3"
			mv "$(echo $3 | rev | cut -c6- | rev).$1.flac" "$3"
		fi
	fi
}

tag_cover_ffmpeg() {
	if [ $verbose = 0 ]; then
		ffmpeg -hide_banner -loglevel 16 -i "$2" -i "$3" -map 0 -map 1:0 -codec copy "$(echo $2 | rev | cut -c6- | rev).cover.flac"
		if [ $clean = 1 ]; then
			rm "$2"
			mv "$(echo $2 | rev | cut -c6- | rev).cover.flac" "$2"
		fi
	else
		ffmpeg -i "$2" -i "$3" -map 0 -map 1:0 -codec copy "$(echo $2 | rev | cut -c6- | rev).cover.flac"
		if [ $clean = 1 ]; then
			rm "$2"
			mv "$(echo $2 | rev | cut -c6- | rev).cover.flac" "$3"
		fi
	fi
}

grab_cover_ffmpeg() {
	if [ $verbose = 0 ]; then
		ffmpeg -hide_banner -loglevel 16 -i "$2" -an -vcodec copy "$3"
	else
		ffmpeg -i "$2" -an -vcodec copy "$3"
	fi
}

check_extension() {
	case "$1" in
		*.flac )
		;;
		*)
			echo "Error, unsupported format"
			help_message
		;;
	esac
}

echo $1 $2 $3 $4

case $1 in
	-h | --help)
	help_message
	;;
	-a | --album )
		check_extension "$3"
		tag_ffmpeg "album" "$2" "$3"
	;;
	-t | --title )
		check_extension "$3"
		tag_ffmpeg "title" "$2" "$3"
	;;
	-c | --comment )
		check_extension "$3"
		tag_ffmpeg "comment" "$2" "$3"
	;;
	-g | --genre )
		check_extension "$3"
		tag_ffmpeg "genre" "$2" "$3"
	;;
	--grab )
		ffprobe -hide_banner "$2"
	;;
	--track )
		check_extension "$3"
		tag_ffmpeg "track" "$2" "$3"
	;;
	--cover )
		check_extension "$3"
		tag_cover_ffmpeg "$1" "$2" "$3"
	;;
	--grab-cover )
		grab_cover_ffmpeg "$1" "$2" "$3"
	;;
	--artist )
		check_extension "$3"
		tag_ffmpeg "artist" "$2" "$3"
	;;
	--album-artist )
		check_extension "$3"
		tag_ffmpeg "album_artist" "$2" "$3"
	;;
	*)
	echo "Error: $1 not an option"
	help_message
	;;
esac

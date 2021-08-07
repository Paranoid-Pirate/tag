#!/bin/sh
# tag, a simple script to tag music via ffmpeg. Doesnt work with vorbis

verbose=0
clean=0

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
	ext=${3##*.}
	filename=${3%.*}
	if [ $verbose = 0 ]; then
		ffmpeg -hide_banner -loglevel 16 -i "$3" -c:a copy -metadata $1="$2" "$filename.$1.$ext"
		if [ $clean = 1 ]; then
			rm "$3"
			mv "$filename.$1.$ext" "$3"
		fi
	else
		ffmpeg -i "$3" -c:a copy -metadata $1="$2" "$filename.$1.$ext"
		if [ $clean = 1 ]; then
			rm "$3"
			mv "$filename.$1.$ext" "$3"
		fi
	fi
}

tag_cover_ffmpeg() {
	ext=${2##*.}
	filename=${2%.*}
	case $3 in
		*.wav )
			echo "Error, cannot tag cover on wav files"
			help_message
		;;
		*)
		;;
	esac
	if [ $verbose = 0 ]; then
		ffmpeg -i "$2" -i "$3" -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$filename.cover.$ext"
		if [ $clean = 1 ]; then
			rm "$2"
			mv "$filename.cover.$ext" "$2"
		fi
	else
		ffmpeg -i "$2" -i "$3" -map 0 -map 1:0 -codec copy "$filename.cover.$ext"
		if [ $clean = 1 ]; then
			rm "$2"
			mv "$filename.cover.flac" "$3"
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

echo $1 $2 $3 $4

case $1 in
	-h | --help)
	help_message
	;;
	-a | --album )
		tag_ffmpeg "album" "$2" "$3"
	;;
	-t | --title )
		tag_ffmpeg "title" "$2" "$3"
	;;
	-c | --comment )
		tag_ffmpeg "comment" "$2" "$3"
	;;
	-g | --genre )
		tag_ffmpeg "genre" "$2" "$3"
	;;
	--grab )
		ffprobe -hide_banner "$2"
	;;
	--track )
		tag_ffmpeg "track" "$2" "$3"
	;;
	--cover )
		tag_cover_ffmpeg "$1" "$2" "$3"
	;;
	--grab-cover )
		grab_cover_ffmpeg "$1" "$2" "$3"
	;;
	--artist )
		tag_ffmpeg "artist" "$2" "$3"
	;;
	--album-artist )
		tag_ffmpeg "album_artist" "$2" "$3"
	;;
	*)
	echo "Error: $1 not an option"
	help_message
	;;
esac

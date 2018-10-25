#!/usr/bin/env bash
# shellcheck disable=2155

# author: Marcos Oliveira <terminalroot.com.br>
# describe: Get data youtube video and channel details
# version: 0.1
# license: MIT License

function youtube(){
	
	local _video=$(mktemp)
	local _channel=$(mktemp)
	local _url="https://youtube.com/channel"
	wget "$1" -O "$_video" 2>/dev/null

	local _title=$(grep '<title>' "$_video" | sed 's/<[^>]*>//g' | sed 's/ - You.*//g')
	local _publi=$(egrep 'Publicado.*<\/strong>' "$_video" | sed 's/.*Publicado/Publicado/g ; s/<\/strong>.*//g')
	local _views=$(grep 'watch-view-count' "$_video" | sed 's/<[^>]*>//g')
	local _likes=$(grep 'like-button-renderer-like-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g;s/ //g')
	local _dislikes=$(grep 'like-button-renderer-dislike-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g' | sed 's/ //g')
	local _id=$(sed 's/channel/\n&/g' "$_video" | grep '^channel' |sed -n 1p | sed 's/isCrawlable.*//g;s/..,.*//g;s/.*"//g')
	wget "$_url/$_id" -O "$_channel" 2>/dev/null

	local _tchannnel=$(sed -n '/title/{p; q;}' "$_channel" | sed 's/<title>  //g')
	local _subscriber=$(sed -n '/subscriber-count/{p; q;}' "$_channel" | sed 's/.*subscriber-count//g' | sed 's/<[^>]*>//g;s/.*>//g')

	echo "Título do canal: $_tchannnel"
	echo "Inscritos: $_subscriber"
	echo "Título: $_title"
	echo "Data: $_publi"
	echo "Visualizações: $_views"
	echo "Gostei: $_likes"
	echo "Dislikes: $_dislikes"

}


youtube "$1"

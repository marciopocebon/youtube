#!/usr/bin/env bash
# shellcheck disable=2155

# author: Marcos Oliveira <terminalroot.com.br>
# describe: Get data youtube video and channel details
# version: 0.1
# license: MIT License

function youtube(){

	_gr="\e[36;1m" ; _yl="\e[33;1m" ; _of="\e[m"
	local _video=$(mktemp)
	local _channel=$(mktemp)
	local _token=$(mktemp)
	local _url="https://youtube.com/channel"
	wget "$1" -O "$_video" 2>/dev/null

	local _title=$(grep '<title>' "$_video" | sed 's/<[^>]*>//g' | sed 's/ - You.*//g')
	
	# procura Estreou ou Publicado
	local _publi=$(egrep '(Publicado|Estreou).*<\/strong>' "$_video" | sed 's/.*\(Publicado\|Estreou\)/Publicado/g ; s/<\/strong>.*//g')
	
	local _views=$(grep 'watch-view-count' "$_video" | sed 's/<[^>]*>//g')
	local _likes=$(grep 'like-button-renderer-like-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g;s/ //g')
	local _dislikes=$(grep 'like-button-renderer-dislike-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g' | sed 's/ //g')
	local _id=$(sed 's/channel/\n&/g' "$_video" | grep '^channel' |sed -n 1p | sed 's/isCrawlable.*//g;s/..,.*//g;s/.*"//g')
	wget "$_url/$_id" -O "$_channel" 2>/dev/null
	
	# Adicionado COMMENTS em vez de -i coment
	local _data=$(grep 'COMMENTS' "$_video" | sed 's/.*: \"//g ; s/\".*//g')
	wget "$1&lc=$_data" -O $_token 2>/dev/null
	
	# filtrado somente os números
	local _comments=$(grep -i 'coment' "$_token" | sed -n 1p | sed 's/<[^>]*>//g ; s/.*• //g')
	
	local _tchannnel=$(sed -n '/title/{p; q;}' "$_channel" | sed 's/<title>  //g')
	local _subscriber=$(sed -n '/subscriber-count/{p; q;}' "$_channel" | sed 's/.*subscriber-count//g' | sed 's/<[^>]*>//g;s/.*>//g')

	echo -e "${_gr}Título do canal: ${_yl}$_tchannnel"
	echo -e "${_gr}Inscritos: ${_yl}$_subscriber"
	echo -e "${_gr}Título: ${_yl}$_title"
	echo -e "${_gr}Data: ${_yl}$_publi"
	echo -e "${_gr}Visualizações: ${_yl}$_views"
	echo -e "${_gr}Gostei: ${_yl}$_likes"
	echo -e "${_gr}Dislikes: ${_yl}$_dislikes"
	
	# Exibido igual aos demais
	echo -e "${_gr}Comentários: ${_yl}$_comments${_of}"

}


youtube "$1"

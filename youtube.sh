#!/usr/bin/env bash
# shellcheck disable=2155
# vim: et ts=2 sw=2 ft=sh:

# author: Marcos Oliveira <terminalroot.com.br>
# describe: Get data youtube video and channel details
# version: 1.0
# license: MIT License

COLOR=0
default_channel="https://www.youtube.com/TerminalRootTV"

usage(){
  cat <<EOF
usage: ${0##*/} [options] [video]
  
  Options:
    -c            Show channel title
    -i            Show scribers
    -t            Show video title
    -d            Show date publish
    -v            Show views
    -g            Show likes
    -n            Show dislikes
    -C            Show comments
    -h,--help     Print this help message
    --version     Print version
    -u            Get update
    --no-color    Disable colors

* This option '-u' still not implanted

EOF

}

if [[ $1 = @(-h|--help) ]];then
  usage
  exit 0
fi

[[ $1 = @(--version) ]] && sed -n '/^#.*version/p' $0 | sed 's/#.//' && exit 0
[[ $1 =~ ^http ]] && _todos=1
[[ -z $1 ]] && _todos=1

function youtube(){
	
  while [[ "$1" ]]; do
    [[ "$1" =~ ^http ]] && URL=$1
    [[ "$1" =~ ^--no-color$ ]] && COLOR=1
  shift
  done

  if [[ "$COLOR" == "0" ]]; then
    _gr="\e[36;1m" ; _yl="\e[33;1m" ; _of="\e[m"; _rd="\e[30;1m"
  else
    _gr=;_yl=;_of=;_rd=
  fi


  if [[ -z "$URL" ]]; then
    if [[ -z "$default_channel" ]]; then
      echo 'Informe a url do video.'
      exit 1
    else
      local _recent=$(mktemp)
      wget "$default_channel/videos" -qO "$_recent"
      local idv=$(grep 'data-context-item-id' ${_recent} | sed -n 1p | sed 's/.*=\"//g' | sed 's/\"//g')
      local URL="https://youtube.com/watch?v=$idv"
      echo -ne "${_rd}+recente...${_of}\r"
    fi
  fi

  local _video=$(mktemp)
	local _channel=$(mktemp)
	local _token=$(mktemp)
	local _url="https://youtube.com/channel"
	wget "$URL" -qO "$_video"

	local _title=$(grep '<title>' "$_video" | sed 's/<[^>]*>//g' | sed 's/ - You.*//g')
	
	# procura Estreou ou Publicado
	local _publi=$(egrep '(Publicado|Estreou).*<\/strong>' "$_video" | sed 's/.*\(Publicado\|Estreou\)/Publicado/g ; s/<\/strong>.*//g')
	
	local _views=$(grep 'watch-view-count' "$_video" | sed 's/<[^>]*>//g')
	local _likes=$(grep 'like-button-renderer-like-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g;s/ //g')
	local _dislikes=$(grep 'like-button-renderer-dislike-button' "$_video" | sed -n 1p | sed 's/<[^>]*>//g' | sed 's/ //g')
	local _id=$(sed 's/channel/\n&/g' "$_video" | grep '^channel' |sed -n 1p | sed 's/isCrawlable.*//g;s/..,.*//g;s/.*"//g')
	wget "$_url/$_id" -qO "$_channel"

	# Adicionado COMMENTS em vez de -i coment
	local _data=$(grep 'COMMENTS' "$_video" | sed 's/.*: \"//g ; s/\".*//g')
	wget "$URL&lc=$_data" -qO $_token
	
	# filtrado somente os números
	local _comments=$(grep -i 'coment' "$_token" | sed -n 1p | sed 's/<[^>]*>//g ; s/.*• //g')

	local _tempty=$(cat "$_channel")

	if [[ -z "$_tempty" || $_tempty == "" ]]; then

		if [[ ! -z "${default_channel}" ]]; then
			wget "$default_channel" -qO "/tmp/canal.tmp"
			local _tchannel=$(sed -n '/title/{p; q;}' "/tmp/canal.tmp" | sed 's/<title>  //g')
			local _subscriber=$(sed -n '/subscriber-count/{p; q;}' "/tmp/canal.tmp" | sed 's/.*subscriber-count//g' | sed 's/<[^>]*>//g;s/.*>//g')
		else
			local _tchannel=$(sed -n '/title/{p; q;}' "$_channel" | sed 's/<title>  //g')
			local _subscriber=$(sed -n '/subscriber-count/{p; q;}' "$_channel" | sed 's/.*subscriber-count//g' | sed 's/<[^>]*>//g;s/    .*>//g')
		fi

	else
		local _tchannel=$(sed -n '/title/{p; q;}' "$_channel" | sed 's/<title>  //g')
		local _subscriber=$(sed -n '/subscriber-count/{p; q;}' "$_channel" | sed 's/.*subscriber-count//g' | sed 's/<[^>]*>//g;s/.*>//g')

	fi

  	export dados=("$_tchannel" "$_subscriber" "$_title" "$_publi" "$_views" "$_likes" "$_dislikes" "$_comments" "$URL")
  
}

get_all(){
 echo -e "${_gr}canal: ${_yl}${dados[0]}"
 echo -e "${_gr}inscritos: ${_yl}${dados[1]}"
 echo -e "${_gr}título: ${_yl}${dados[2]}"
 echo -e "${_gr}data: ${_yl}${dados[3]}"
 echo -e "${_gr}visualizações: ${_yl}${dados[4]}"
 echo -e "${_gr}gostei: ${_yl}${dados[5]}"
 echo -e "${_gr}dislikes: ${_yl}${dados[6]}"
 echo -e "${_gr}comentários: ${_yl}${dados[7]}${_of}"
 echo -e "${_gr}url: ${_yl}${dados[8]}${_of}"
}

echo -en 'Aguarde ...\r'
youtube "$@"

if [[ "$@" == "--no-color" ]]; then
  set -- $(echo $@ | sed 's/\-\-no\-color/-citdvgnC/g')
fi

while 

  getopts ':citdvgnCE' flag;
   
  
do
  
	case $flag in
		c) echo -e "${_gr}canal: ${_yl}${dados[0]}";;
		i) echo -e "${_gr}inscritos: ${_yl}${dados[1]}";;
		t) echo -e "${_gr}título: ${_yl}${dados[2]}";;
		d) echo -e "${_gr}data: ${_yl}${dados[3]}";;
		v) echo -e "${_gr}visualizações: ${_yl}${dados[4]}";;
		g) echo -e "${_gr}gostei: ${_yl}${dados[5]}";;
		n) echo -e "${_gr}desgosteis: ${_yl}${dados[6]}";;
		C) echo -e "${_gr}comentários: ${_yl}${dados[7]}${_of}";;
    E) get_all && read -sn 1 ENTER
    # ?) echo Opção inválida: -${OPTARG};;
	esac
shift $(( OPTIND - 1 ))
done

if [[ "$_todos" == "1" ]]; then
  get_all
fi


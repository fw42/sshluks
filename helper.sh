#!/bin/bash
msg_status(){
	echo -e ">> \e[0;32;49m$*\e[0m"
}

msg_error(){
	echo -e "!! \e[0;31;49m$*\e[0m"
}

die(){	
	if [ $# -eq 0 ]
	then
		msg_error "Something went wrong."
	else
		msg_error $*
	fi
	exit
}

checkroot(){
	if [ $(id -u) != "0" ]
	then
		die "Need root privileges"
	fi
}

runuser(){
	su $LOCALUSER -c "$*"
}

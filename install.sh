#!/bin/bash

# personalize here

# Set the access point SSID
AP_SSID=ermes

# Set the access point passphrase
AP_PASSPHRASE=12345678

# Set the access point channel
AP_CHANNEL=11

# Set the install directory path
INSTALL_DIR=/home/pi/wifiExtender/

# end personalize

# At your own risk

# To automatically modify the file /etc/rc.local
# set RC_LOCAL_CHANGE=yes
RC_LOCAL_CHANGE=yes

#end at your own risk

# Base dev interfaces
BASE_WIFI_DEV=wlan0
ACCESS_POINT_DEV=ap0

# project subdir do not modify
WEBROOT_DIR=/var/www/
SYSTEM_UTILS_DIR=utils/system/
DNSMQSQ_UTILS_DIR=utils/dnsmasq/
DHCPCD_UTILS_DIR=utils/dhcpcd/
HOSTAPD_UTILS_DIR=utils/hostapd/
WPA_SUPPLICANT_UTILS_DIR=utils/wpa_supplicant/
LIGHTTPD_CONF_DIR=utils/lighttpd/conf/
ADDBLOCK_UTILS_DIR=utils/addBlock/


# export for files customization
export INSTALL_DIR SYSTEM_UTILS_DIR DNSMQSQ_UTILS_DIR HOSTAPD_UTILS_DIR WPA_SUPPLICANT_UTILS_DIR DHCPCD_UTILS_DIR
export ACCESS_POINT_DEV BASE_WIFI_DEV AP_SSID AP_PASSPHRASE ADDBLOCK_UTILS_DIR


function setupFile {
	cat $1 | envsubst '$INSTALL_DIR $SYSTEM_UTILS_DIR $DNSMQSQ_UTILS_DIR $HOSTAPD_UTILS_DIR $DHCPCD_UTILS_DIR  \
		$WPA_SUPPLICANT_UTILS_DIR $ACCESS_POINT_DEV $BASE_WIFI_DEV $AP_SSID $AP_PASSPHRASE $ADDBLOCK' > ${INSTALL_DIR}$1
	chmod +x ${INSTALL_DIR}$1 || install_error "Unable to chmode "${INSTALL_DIR}${1}
}

function createDir {
	if [ ! -d $1 ]; then
	        mkdir -p $1 || install_error "Unable to create dir"${1}
	fi
}


function config_installation() {
    install_log "Configure installation"
    echo "Install this software only on a RaspberryPi Zero W" 
    echo "*******************************************************"
    echo "Use a fresh installation of Raspian Stretch"
    echo "After installation probably nothing will work."
    echo "I take no responsability"
    echo "*******************************************************"
    echo "Install directory: ${INSTALL_DIR}"
    echo "Access point SSD: ${AP_SSID}"
    echo "Access point pwd: ${AP_PASSPHRASE}"
    echo -n "Complete installation with these values? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
}


function display_welcome() {
    raspberry='\033[0;35m'
    green='\033[1;32m'
    # https://www.ascii-art-generator.org/

    echo -e "${raspberry}\n"
    echo -e " #######                             " 
    echo -e " #       #####  #    # ######  ####  " 
    echo -e " #       #    # ##  ## #      #      " 
    echo -e " #####   #    # # ## # #####   ####  " 
    echo -e " #       #####  #    # #           # " 
    echo -e " #       #   #  #    # #      #    # " 
    echo -e " ####### #    # #    # ######  ####  "           
    echo -e "                             				"
    echo -e "${green}"
    echo -e "The Quick Installer will guide you through a few easy steps\n\n"
}

function install_log() {
    echo -e "\033[1;32mErmes Install: $*\033[m"
}

# Outputs a RaspAP Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mErmes Install Error: $*\033[m"
    exit 1
}

# Outputs a RaspAP Warning line
function install_warning() {
    echo -e "\033[1;33mWarning: $*\033[m"
}



function install_complete() {
    install_log "Installation completed!"

    echo -n "The system needs to be rebooted as a final step. Reboot now? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation reboot aborted."
        exit 0
    fi
    sudo shutdown -r now || install_error "Unable to execute shutdown"
}

#setup base files
function setup_base_files(){
    install_log "Setup base file"
    createDir ${INSTALL_DIR}

    setupFile startWiFiExtender.sh
    setupFile setJail.sh
    setupFile setDnsMasqOptions.sh
}

#setup dnsmasq files 
function setup_dnsmasq_files(){
    install_log "Setup dnsmasq file"
    createDir ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}

    setupFile ${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh

    createDir ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}/conf
    cp ${pwd}${DNSMQSQ_UTILS_DIR}conf/dnsmasq.conf.tmpl ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}conf/  || install_error "Unable to copy "${pwd}${DNSMQSQ_UTILS_DIR}conf/dnsmasq.conf.tmpl
}

#setup dhcpcd files
function setup_dhcpcd_files(){
    install_log "Setup dhcpcd file"
    createDir ${INSTALL_DIR}${DHCPCD_UTILS_DIR}

    setupFile ${DHCPCD_UTILS_DIR}setDhcpcdConf.sh

    createDir ${INSTALL_DIR}${DHCPCD_UTILS_DIR}/conf
    cp ${pwd}${DHCPCD_UTILS_DIR}conf/dhcpcd.conf.tmpl ${INSTALL_DIR}${DHCPCD_UTILS_DIR}conf/  || install_error "Unable to copy "${pwd}${DHCPCD_UTILS_DIR}conf/dhcpcd.conf.tmpl
}

#setup hostapd files
function setup_hostapd_files(){
    install_log "Setup dhcpcd file"
    createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}

    setupFile ${HOSTAPD_UTILS_DIR}deauthStation.sh
    setupFile ${HOSTAPD_UTILS_DIR}execDeauthStation.sh
    setupFile ${HOSTAPD_UTILS_DIR}setHostapdConf.sh

    createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}/conf
    cp ${pwd}${HOSTAPD_UTILS_DIR}conf/hostapd.conf.tmpl ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}conf/  || install_error "Unable to copy "${pwd}${HOSTAPD_UTILS_DIR}conf/hostapd.conf.tmpl
}

#setup system files
function setup_system_files(){
    install_log "Setup system file"
    #cp ${SYSTEM_UTILS_DIR}90-wireless.rules /etc/udev/rules.d/

    createDir ${INSTALL_DIR}${SYSTEM_UTILS_DIR}

    setupFile ${SYSTEM_UTILS_DIR}removeBaseRoute.sh
    setupFile ${SYSTEM_UTILS_DIR}saveAPChannel.sh
    setupFile ${SYSTEM_UTILS_DIR}setBaseRoute.sh
    setupFile ${SYSTEM_UTILS_DIR}removeVPNRoute.sh
    setupFile ${SYSTEM_UTILS_DIR}setVPNRoute.sh
    setupFile ${SYSTEM_UTILS_DIR}isBaseRouteEnable.sh
}

#setup wpa_supplicant files
function setup_wpa_supplicant_files(){
    install_log "Setup supplicant file"
    createDir ${INSTALL_DIR}${WPA_SUPPLICANT_UTILS_DIR}
    setupFile ${WPA_SUPPLICANT_UTILS_DIR}wpa_events.sh
    #setupFile ${base_dir}${WPA_SUPPLICANT_UTILS_DIR}createWpa_supplicantTCPInterface.sh
    #cp  ${pwd}${WPA_SUPPLICANT_UTILS_DIR}wpaTcpGateway.py ${INSTALL_DIR}${WPA_SUPPLICANT_UTILS_DIR}
    #Considerare se creare un wpa_supplicant.conf con parametri per wpa_cli
    #nel caso deve contenere almeno una rete configurata
}

#change to /etc/rc.local
function change_rc_local_file(){
    install_log "Setup rc.local file"
    if [ $(cat /etc/rc.local |grep startWiFiExtender.sh |wc -l) !=  1 ]; then
            if [ "$RC_LOCAL_CHANGE" = "yes" ]; then
                    echo "File /etc/rc.local modified"
                    echo "a backup copy off the file is made /etc/rc.local.wifiExtender"
                    cp /etc/rc.local /etc/rc.local.wifiExtender  || install_error "Unable to backup rc.local "
                    sed  "s|exit 0$|${INSTALL_DIR}startWiFiExtender.sh \&\nexit 0|" /etc/rc.local.wifiExtender > /etc/rc.local || install_error "Unable to setup rc.local "
            else
                    echo "Remeber to modify the file: /etc/rc.local"
                    echo "add '${INSTALL_DIR}startWiFiExtender.sh &' before the line: 'exit 0'"
            fi
    else
            echo "File /etc/rc.local already modified"
    fi
}

#install dependencies 
function install_dependencies(){
    install_log "Install dependencies"
    apt-get update || install_error "Unable to update package list"
    apt-get  -y upgrade || install_error "Unable to upgrade"
    apt-get -y install hostapd dnsmasq haveged openvpn  || install_error "Unable to install dependencies"

    #systemctl stop dnsmasq
    #systemctl stop hostapd
    #systemctl stop openvpn.service

    systemctl disable wpa_supplicant.service  || install_error "Unable disable supplicant"
    systemctl disable dnsmasq  || install_error "Unable disable dnsmasq"
    systemctl disable hostapd  || install_error "Unable disable hostapd"
    systemctl disable openvpn.service  || install_error "Unable disable openvpn"
    #systemctl disable dhcpcd
}

#setup dnsmasq and hostapd config file
function setup_ap_configuration(){
    install_log "setup dnsmasq, dhcpcd and hostapd config file..."
    ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}setHostapdConf.sh $ACCESS_POINT_DEV ${AP_CHANNEL}
    ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh $ACCESS_POINT_DEV n n n
    ${INSTALL_DIR}${DHCPCD_UTILS_DIR}setDhcpcdConf.sh $ACCESS_POINT_DEV ${BASE_WIFI_DEV}
}



#install wpa_cli_py
function install_wpa_cli_py(){
    install_log "Install wpa_cli"
    git clone https://github.com/fustinoni-net/wpa_cli_py.git /tmp/wpa_cli
    cd /tmp/wpa_cli/
    git -C /tmp/wpa_cli/ checkout dev
    chmod +x /tmp/wpa_cli/install.sh
    /tmp/wpa_cli/install.sh
    cd -
    rm -R /tmp/wpa_cli
}

#install raspbian Ermes edition
function install_raspbian(){
    install_log "Install raspap-webgui"
    wget -q https://raw.githubusercontent.com/fustinoni-net/raspap-webgui/dev/installers/raspbian.sh -O /tmp/raspbian.sh
    chmod +x /tmp/raspbian.sh
    /tmp/raspbian.sh ${INSTALL_DIR}
    rm /tmp/raspbian.sh
}

#setup install dir group for lighttpd
function set_install_dir_group(){ 
    install_log "Setup permissions for install dir"
    chgrp -R www-data ${INSTALL_DIR}
    chmod -R g+w ${INSTALL_DIR}
}


function configure_lighttpd(){
    install_log "Configure lighttpd"

    systemctl stop lighttpd  || install_error "Unable to stop lighttpd"
    systemctl disable lighttpd   || install_error "Unable to disable lighttpd"

    #WEBROOT_DIR
    #server.bind  ='192.1568.50.10'
    #export ??
    cat ${LIGHTTPD_CONF_DIR}lighttpd.conf.tmpl | envsubst '$AP_SSID' > /etc/lighttpd/lighttpd.conf || install_error "Unable to set up lighttpd config file"

    cp -R ${LIGHTTPD_CONF_DIR}connectivitycheck.gstatic.com ${WEBROOT_DIR} || install_error "Unable to copy "${LIGHTTPD_CONF_DIR}connectivitycheck.gstatic.com
    chgrp -R www-data ${WEBROOT_DIR}connectivitycheck.gstatic.com 
    #cp -R ${LIGHTTPD_CONF_DIR}jail ${WEBROOT_DIR}  || install_error "Unable to copy "${LIGHTTPD_CONF_DIR}jail
    mkdir ${WEBROOT_DIR}jail || install_error "Unable to copy "${LIGHTTPD_CONF_DIR}jail
    chgrp -R www-data ${WEBROOT_DIR}jail

}


#setup addBlock files
function setup_addBlock_files(){
    install_log "Setup addBlock file"
    createDir ${INSTALL_DIR}${ADDBLOCK_UTILS_DIR}
    setupFile ${ADDBLOCK_UTILS_DIR}make-ads-hostfile.sh
    chmod +x ${INSTALL_DIR}${ADDBLOCK_UTILS_DIR}make-ads-hostfile.sh
    ${INSTALL_DIR}${ADDBLOCK_UTILS_DIR}make-ads-hostfile.sh
}


display_welcome
config_installation
setup_base_files
setup_dnsmasq_files
setup_dhcpcd_files
setup_hostapd_files
setup_system_files
setup_wpa_supplicant_files
change_rc_local_file
install_dependencies
setup_ap_configuration
install_wpa_cli_py
install_raspbian
set_install_dir_group
configure_lighttpd
setup_addBlock_files
install_complete

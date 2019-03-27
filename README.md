# Ermes

The aim of this project is to use a Raspberry Pi Zero W like "secure" portable wifi access point.
For secure I mean
- it keep your devices isolated from the wifi lan you are connected too
- Does not share the internet connection automatically to the access point network. You have to allow it.
- It can route all the traffic (DNS query to check) throw a VPN connection
- php-proxy, a web proxy application to browse the internet without share  
  the internet connection to the access point lan (useful to deal with captive portal)

Anyway do not consider it a secure environment. At the moment all the DNS query will be passed outside to the connected network and so available to every one.
The VPN support is made using the OpenVPN project but maybe the way I use it is not secured.

Tested with a Raspberry Pi Zero W with Raspbian Stretch Lite version: November 2018

Tested wifi usb dongle:

###Feature
Features of the system:
- Easy installation
- Web interface
- php-proxy
- Ads blocker (Experimental and limited)
- OpenVPN support with .ovpn configuration file
- WPA Supplicant support for open, WEP, WPA, WPA2, EAP (at least some kind) connection. Support for WPS button and WPS PIN connections.
- Internal Android connection check handler (on request)
- "Jail" for all domain name (locally resolution name)
- Enable/disable interface routing
- Connectivity check.
- Work with the internal wifi interface only or with the internal plus and external (nl80211) usb one.


###Install procedure

Please install it only on a fresh Raspbian Strech installation.
After the installation there is the possibility that nothing will work, and your system will be unusable until you will reinstall a new copy of the operation system.

Please don't use it. I don't take any responsibility.
  
To install the system and all the related projects just clone this project with

    git clone https://github.com/fustinoni-net/Ermes.git

then move inside the directory Ermes, edit the file install.sh for adjusting your preferences:
 
    # personalize here
    
    # Set the access point SSID
    AP_SSID=ermes
    
    # Set the access point passphrase
    AP_PASSPHRASE=12345678
    
    # Set the access point channel
    AP_CHANNEL=11
    
    # Set the install directory path
    INSTALL_DIR=/home/pi/wifiExtender/
 
 and then execute like sudo the install script

    sudo ./install.sh
    
 Follow the onscreen instruction and then reboot the system.
    
 The script will install all the dependence, will change many system configuration files and install the additional projects:
 
 - https://github.com/fustinoni-net/wpa_cli_py
 - https://github.com/fustinoni-net/raspap-webgui
 - https://github.com/Athlon1600/php-proxy
 
 
###Quick user guide
The system can work just with the internal Zero W wifi interface using it like an access point and a managed interface (normal wifi client) 
or with the internal interface used like access point plus an external usb wifi interface used like a managed interface for connecting
to existing wifi network. Only device compliant with nl80211 interface will be used.
The switch from one mode to the other is not plug and play. So switch off the Raspberry Pi Zero W, plug or unplug the external
usb wifi dongle and then switch on the system.

After powering the system, you should wait a couple of minutes for the system to start the access point and connect to it.
Onece you device is paired with the access point, start a browser and connect to 
    
       http://yourSSIname
       
   or
       
       http://yourSSIname.com
       
   ex: 
       
       http://ermes
       http://ermes.com
       
       
and insert the login credentials:

    user name: admin
    password: secret
    

You are now logged in the access point interface. In the dashboard page push "Share Internet" to let your connected device to access Internet.  

If you want to browse internet using the php-proxy just connect to:
    
    http://php-proxy
    
or 

    http://php-proxy.com
    
Enjoy :-)

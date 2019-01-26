#!/usr/bin/python

import getopt
import socket
import sys
import os
import time

class SendCommandException(Exception):
    pass


def sendCommand(socket, socketFile, command):
        
	try:
        	socket.sendto(command, socketFile);
        except socket.error:
        	raise SendCommandException('send faild')

	data, addr = socket.recvfrom(4096)
	return data

class SendCommandNotOkException(Exception):
    pass


def sendCommandOkValidated (socket, socketFile, command ):

        data = sendCommand(socket, socketFile, command)
        if str(data[0:2]) != 'OK':
                print "Error: " + command + " " + data
                raise SendCommandNotOkException(command + '\n' + data +'\nKO')

        return command + '\n' + data


def addNetwork (socket, socketFile):
	command = 'ADD_NETWORK'
	data = sendCommand(socket, socketFile, command)
	return data.rstrip(), command + '\n' + data

def removeNetwork (socket, socketFile, id ):
        command = 'REMOVE_NETWORK ' + id.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def enableNetwork (socket, socketFile, id ):
        command = 'ENABLE_NETWORK ' + id.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def disableNetwork (socket, socketFile, id ):
        command = 'DISABLE_NETWORK ' + id.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def saveConfig (socket, socketFile):
        command = 'SAVE_CONFIG'
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data


def setNetworkProperty (socket, socketFile, id, property, value ):
        command = 'SET_NETWORK ' + id.rstrip() + ' '  + property.rstrip() + ' ' + value.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def setNetworkCrtRspIdentity (socket, socketFile, id, value ):
    #https://w1.fi/wpa_supplicant/devel/ctrl_iface_page.html
    
    #prova a gestirle come set_network n identity ....
    
        command = 'CTRL-RSP-IDENTITY-' + str(id.rstrip()) + ':' + value
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def setNetworkCrtRspPassword (socket, socketFile, id, value ):
        command = 'CTRL-RSP-PASSWORD- ' + id + ':' + value
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data


def setNetworkEnable (socket, socketFile, id ):
        command = 'ENABLE_NETWORK ' + id.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

def setNetworkDisable (socket, socketFile, id ):
        command = 'DISABLE_NETWORK ' + id.rstrip()
        data = sendCommandOkValidated(socket, socketFile, command)
        return command + '\n' + data

class InvalidProtocol(Exception):
    pass

def main(argv):
	id_net = ''
	protocol = ''
	ssid = ''
	bssid = ''
	password = ''
	priority = ''
	enabled = ''
	#scan_ssid = 1
	key_mgmt = '' #WPA-EAP, NONE per free wifi (no password)
	identity = '' #username
	eap = '' #PEAP
	#phase1="peaplabel=0"
	#phase2="auth=MSCHAPV2"	



	SERVER_FILE = "/var/run/wpa_supplicant/wlan0"
	CLIENT_FILE = "/tmp/wpa_SR" + str(time.time())

	try:
		opts, args = getopt.getopt(argv,"hp:i:s:b:p:P:r:ek:I:E:",["protocol=","idNet=","ssid=","bssid=","password=","priority=","keyMgmt=","identity=","eap="])
	except getopt.GetoptError:
		print 'error wpaCreateNet.py -p (--protocol) -i (--idNet) -s (--ssid) -b (--bssid) -P (--password) -r (--priority) -e -k (--keyMgmt) -I (--identity) -E (--eap)'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'wpaCreateNet.py -p (--protocol) -i (--idNet) -s (--ssid) -b (--bssid) -P (--password) -r (--priority) -e -k (--keyMgmt) -I (--identity) -E (--eap)'
			sys.exit()
		elif opt in ("-p", "--protocol"):
			protocol = arg
		elif opt in ("-i", "--idNet"):
			id_net = arg
                elif opt in ("-s", "--ssid"):
                        ssid = '"' + arg + '"'
                elif opt in ("-b", "--bssid"):
                        bssid = arg
                elif opt in ("-P", "--password"):
                        if arg.startswith('0x'):
                            password = arg
                        else:
                            password = '"' + arg + '"'
                elif opt in ("-r", "--priority"):
                        priority = arg
                elif opt in ("-e", "--enabled"):
                        enabled = '1'
                elif opt in ("-k", "--keyMgmt"):
                        key_mgmt = arg
                elif opt in ("-I", "--identity"):
                        identity = '"' + arg + '"'
                elif opt in ("-E", "--eap"):
                        eap = arg

        
            

	out = ""
        if protocol == '':
            out = out + "Invalid protocol" + '\n' + "KO" + '\n' 
            raise SendCommandException('Invalid protocol')
        
        s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        s.bind(CLIENT_FILE)

	try:
                id, data = addNetwork (s, SERVER_FILE)
                out = out + data + '\n'
                
                if ssid != '""' and ssid != '':
                    data = setNetworkProperty (s, SERVER_FILE, id, 'ssid', ssid )
                    out = out + data + '\n'
                else:
                    data = setNetworkProperty (s, SERVER_FILE, id, 'scan_ssid', '1' )
                    out = out + data + '\n'

                if bssid != '':
                    data = setNetworkProperty (s, SERVER_FILE, id, 'bssid', bssid )
                    out = out + data + '\n'

                if priority != '':
                    data = setNetworkProperty (s, SERVER_FILE, id, 'priority', priority )
                    out = out + data + '\n'

		if protocol == 'OPEN':
                        print 'Open'
			#open network
                        data = setNetworkProperty (s, SERVER_FILE, id, 'key_mgmt', 'NONE' )
                        out = out + data + '\n'
			
		elif protocol == 'WEP':
			#WEP
                        print 'WEP'
                        data = setNetworkProperty (s, SERVER_FILE, id, 'key_mgmt', 'NONE' )
                        out = out + data + '\n'
                        if password != '""':
                            data = setNetworkProperty (s, SERVER_FILE, id, 'wep_key0', password )
                            out = out + data + '\n'
                            data = setNetworkProperty (s, SERVER_FILE, id, 'wep_tx_keyidx', '0' )
                            out = out + data + '\n'

		elif protocol == 'WPA' or protocol == 'WPA2':
			#WAP/WAP2
                        print 'WPA'
                        data = setNetworkProperty (s, SERVER_FILE, id, 'psk', password )
                        out = out + data + '\n'


		elif protocol == 'EAP':
			#EAP
			print 'EAP'

                        data = setNetworkProperty(s, SERVER_FILE, id, 'identity', identity )
                        out = out + data + '\n'

                        data = setNetworkProperty(s, SERVER_FILE, id, 'password', password )
                        out = out + data + '\n'

                        #  scan_ssid=1

                        #  eap=PEAP
                        data = setNetworkProperty (s, SERVER_FILE, id, 'eap', eap )
                        out = out + data + '\n'

                        #  key_mgmt=WPA-EAP
                        data = setNetworkProperty (s, SERVER_FILE, id, 'key_mgmt', key_mgmt )
                        out = out + data + '\n'



                if enabled == '1':
                    print 'enabled'
                    data = setNetworkEnable(s, SERVER_FILE, id)
                    out = out + data + '\n'
                else:
                    data = setNetworkDisable(s, SERVER_FILE, id)
                    out = out + data + '\n'

		data = saveConfig(s, SERVER_FILE)
                out = out + data + '\n'
        except SendCommandException as e1:
            out =  out + 'E1: ' + str(e1) + '\n'
        except SendCommandNotOkException as e2:
            try:
                data = removeNetwork(s, SERVER_FILE, id)
                out = out + data + '\n'
            except :
                pass

            out = out + 'E2: ' + str(e2) + '\n'    
	finally:
	        sys.stdout.write(out + '\n')
		s.close()
	        os.unlink(CLIENT_FILE)
		os.system('rm -f ' + CLIENT_FILE)


if __name__ == "__main__":
	main(sys.argv[1:])

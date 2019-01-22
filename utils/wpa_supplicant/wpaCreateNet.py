#!/usr/bin/python

import getopt
import socket
import sys
import os
import time


def sendCommand(socket, socketFile, command):
	try:
        	socket.sendto(command, socketFile);
        except socket.error:
        	return 'send faild'

	data, addr = socket.recvfrom(4096)
	return data

def addNetwork (socket, socketFile):
	command = 'ADD_NETWORK'
	success = 0
	data = sendCommand(socket, socketFile, command)
	return data

def removeNetwork (socket, socketFile, id ):
        command = 'REMOVE_NETWORK ' + id.rstrip()
        success = 0
        data = sendCommand(socket, socketFile, command)
        if data == 'OK':
                success = 1
        return command + '\n' + data, success

def enableNetwork (socket, socketFile, id ):
        command = 'ENABLE_NETWORK ' + id.rstrip()
        success = 0
        data = sendCommand(socket, socketFile, command)
        if data == 'OK':
                success = 1
        return command + '\n' + data, success

def disableNetwork (socket, socketFile, id ):
        command = 'DISABLE_NETWORK ' + id.rstrip()
        success = 0
        data = sendCommand(socket, socketFile, command)
        if data == 'OK':
                success = 1
        return command + '\n' + data, success

def saveConfig (socket, socketFile):
        command = 'SAVE_CONFIG'
        success = 0
        data = sendCommand(socket, socketFile, command)
        if data == 'OK':
                success = 1
        return command + '\n' + data, success


def setNetworkProperty (socket, socketFile, id, property, value ):
        command = 'SET_NETWORK ' + id.rstrip() + ' '  + property.rstrip() + ' ' + value.rstrip()
        print command
	success = 0
        data = sendCommand(socket, socketFile, command)
        if data == 'OK':
                success = 1
        return command + '\n' + data, success

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
		opts, args = getopt.getopt(argv,"hp:i:s:b:p:P:r:e:k:I:E:",["protocol=","idNet=","ssid=","bssid=","password=","priority=","enabled=","keyMgmt=","identity=","eap="])
	except getopt.GetoptError:
		print 'error wpaCreateNet.py -i <inputfile> -o <outputfile>'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'test.py -i <inputfile> -o <outputfile>'
			sys.exit()
		elif opt in ("-p", "--protocol"):
			protocol = arg
		elif opt in ("-i", "--idNet"):
			id_net = arg
                elif opt in ("-s", "--ssid"):
                        ssid = arg
                elif opt in ("-b", "--bssid"):
                        bssid = arg
                elif opt in ("-P", "--password"):
                        password = arg
                elif opt in ("-r", "--priority"):
                        priority = arg
                elif opt in ("-e", "--enabled"):
                        enabled = arg
                elif opt in ("-k", "--keyMgmt"):
                        key_mgmt = arg
                elif opt in ("-I", "--identity"):
                        identity = arg
                elif opt in ("-E", "--eap"):
                        eap = arg

	out = ""
        s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        s.bind(CLIENT_FILE)

	try:
                data = addNetwork (s, SERVER_FILE)
                id = data
		if protocol == 'Open':
			#open network
                        out = out + data + '\n'
			data, success = setNetworkProperty (s, SERVER_FILE, id, 'ssid', ssid )
			out = out + data + '\n'
                        data, success = setNetworkProperty (s, SERVER_FILE, id, 'key_mgmt', 'NONE' )
                        out = out + data + '\n'
			
		elif protocol == 'WEP':
			#WEP
			print 'WEP'
		elif protocol == 'WAP' or protocol == 'WAP2':
			#WAP/WAP2
			print 'WPA'
		elif protocol == 'EAP':
			#EAP
			print 'EAP'

		data, success = saveConfig(s, SERVER_FILE)

	finally:
	        sys.stdout.write(out + '\n')
		s.close()
	        os.unlink(CLIENT_FILE)
		os.system('rm -f ' + CLIENT_FILE)


if __name__ == "__main__":
	main(sys.argv[1:])

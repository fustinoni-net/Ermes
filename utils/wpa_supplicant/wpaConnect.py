import socket
import sys
import os
import time


class NetworkItem:
	id = ""
	ssid = ""
	bssid = ""
	flags = ""


SERVER_FILE = "/var/run/wpa_supplicant/wlan0"
CLIENT_FILE = "/tmp/wpa_SR" + str(time.time())

os.system('rm -f ' + CLIENT_FILE)

s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
s.bind(CLIENT_FILE)

out = ""

try:
	out = out + 'LIST_NETWORKS' + '\n'
        try:
                s.sendto('LIST_NETWORKS',SERVER_FILE)
        except socket.error:
                out = out + 'send faild' + '\n'
                sys.exit()

	data, addr = s.recvfrom(4096)
	out = out + data + '\n'

	networkList=[]	
	dataList = data.split('\n')
	for line in dataList:
		#sys.stdout.write(line[0:4] + '\n')
		if str(line[0:4]) == "netw":
			continue
		lineValue = line.split('\t')
		#sys.stdout.write(str(len(lineValue)) + '\n')
		if len(lineValue) == 1:
			continue
		net = NetworkItem()
		net.id = lineValue[0]
		net.ssid = lineValue[1]
		#sys.stdout.write(net.ssid)
		net.bssid = lineValue[2]
		if len(lineValue) == 4:
			net.flags = lineValue[3]
		networkList.append(net)


	out = out + 'ATTACH' + '\n'
        try:
                s.sendto('ATTACH',SERVER_FILE);
        except socket.error:
                out = out + 'send faild' + '\n'
                sys.exit()

        data, addr = s.recvfrom(4096)
	out = out + data + '\n'

	out = out + 'SELECT_NETWORK ' + sys.argv[1] + '\n'
        try:
                s.sendto('SELECT_NETWORK ' + sys.argv[1],SERVER_FILE)
        except socket.error:
                out = out + 'send faild' + '\n'
                sys.exit()
	data = ''
        while  (not data.startswith('<3>CTRL-EVENT-CONNECTED')) and data != '<4>Failed to initiate sched scan' and data != 'FAIL\n':
		#while data != 'FAIL\n':
                # Receive data
                #print('# Receive data from server')
                #print 'leggo'
                data, addr = s.recvfrom(4096)
		sys.stdout.write( "-----" + data + '\n')
		out = out + data + '\n'

	out = out + 'DETACH' + '\n'

        try:
                s.sendto('DETACH', SERVER_FILE);
        except socket.error:
                out = out + 'send faild' + '\n'
                sys.exit()

        data, addr = s.recvfrom(4096)
	out = out + data + '\n'

	for n in networkList:
		sys.stdout.write(n.ssid + '\n')
		if 

	s.close()
	os.unlink(CLIENT_FILE)
finally:
	os.system('rm -f ' + CLIENT_FILE)
	sys.stdout.write(out + '\n')

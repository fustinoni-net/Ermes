 # Socket client example in python

import socket
import sys  
import os

SERVER_FILE = "/var/run/wpa_supplicant/wlan0"
CLIENT_FILE = "/tmp/wpa_SR"

os.system('rm -f ' + CLIENT_FILE)

s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
s.bind(CLIENT_FILE)


try:
	s.sendto('ATTACH',SERVER_FILE);
except socket.error:
    print 'Send failed'
    sys.exit()

data, addr = s.recvfrom(4096)


try:
    s.sendto('SCAN',SERVER_FILE)
except socket.error:
    print 'Send failed'
    sys.exit()

while data != '<3>CTRL-EVENT-SCAN-RESULTS ': 
	# Receive data
	#print('# Receive data from server')
	#print 'leggo'
	data, addr = s.recvfrom(4096)
	#print reply

#print 'out'
#print reply 

try:
        s.sendto('DETACH', SERVER_FILE);
except socket.error:
    #print 'Send failed'
    sys.exit()

data, addr = s.recvfrom(4096)

#print reply

try:
        s.sendto('SCAN_RESULTS', SERVER_FILE);
except socket.error:
    print 'Send failed'
    sys.exit()

data, addr = s.recvfrom(4096)

sys.stdout.write(data)
s.close()
os.unlink(CLIENT_FILE)

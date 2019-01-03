
import socket
import sys  
import os

SERVER_FILE = "/var/run/wpa_supplicant/wlan0"
CLIENT_FILE = "/tmp/wpa_G"

os.system('rm -f ' + CLIENT_FILE)
#os.unlink(CLIENT_FILE)
# create socket
#print('# Creating socket')
#try:
s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
#except socket.error:
#    print('Failed to create socket')
#    sys.exit()

s.bind(CLIENT_FILE)

# Send data to remote server
#print('# Sending data to server')
request = sys.argv[1].upper()

if len(sys.argv) > 2 :
	sys.argv.remove(sys.argv[0])
	sys.argv.remove(sys.argv[0])
	request = request + ' ' +  ' '.join(sys.argv)


try:
    s.sendto(request, SERVER_FILE)
except socket.error:
    print 'Send failed'
    sys.exit()

# Receive data
#print('# Receive data from server')
data, addr = s.recvfrom(4096)

#print reply 
sys.stdout.write(data)

s.close()
os.unlink(CLIENT_FILE)

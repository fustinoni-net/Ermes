#!/usr/bin/python

#
#   MIT License
#
#   Copyright (c) 2019 Enrico Fustinoni
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.
#

import sys
import subprocess
import argparse
import re


def main():

    parser = argparse.ArgumentParser(description='Check if the system is connected to the Internet or behind a captive '
                                                 'portal.')
    parser.add_argument("ifname", help="Specify the interface to check for an Internet connection.")
    args = parser.parse_args()

    out = "NOT_CONNECTED"
    error = 0

    try:
        sp = subprocess.Popen("iw dev " + args.ifname + " link", shell=True, stdout=subprocess.PIPE).stdout.read()

        found = re.search("Connected to", sp)
        if found:
            #curl --resolve clients3.google.com:80:216.58.205.78 -D - clients3.google.com -o /dev/null -s
            response = subprocess.Popen(
                'curl --resolve clients3.google.com:80:216.58.205.78 -D - clients3.google.com/generate_204 -o /dev/null -s',
                shell=True, stdout=subprocess.PIPE).stdout.read()
            response_line = response.split('\n')
            response_dic = {}
            #print response_line

            for line in response_line:
                #print line
                if line == '\r' or line == '':
                    pass
                elif str(line[0:4]) == "HTTP":
                    values = line.split(' ')
                    response_dic["status_code"] = values[1].rstrip()
                else:
                    values = line.split(':',1)
                    response_dic[values[0]] = values[1]

            #print response_dic['status_code']
            if response_dic['status_code'] == '204':
                out = "CONNECTED"
            elif response_dic['status_code'] == '302':
                out = "CAPTIVE: " + response_dic['Location']
            else:
                out = "NO_INTERNET? STATUS CODE: " + response_dic['status_code']

    except BaseException as be:
        out = be.message
        error = 1
    finally:
        if error == 0:
            sys.stdout.write(out + '\n')
        else:
            sys.stderr.write(out + '\n')

        sys.exit(error)


if __name__ == "__main__":
    main()

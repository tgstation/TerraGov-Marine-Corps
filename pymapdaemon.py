from http.server import BaseHTTPRequestHandler, HTTPServer
from pymapdaemon_internals import PyMapDaemon
import time
import json
import sys
import os

# This is fucking cancer, I fucked up architecture so much,
# so I have to call methods of my class through global functions
# And I have zero motivation to remake it properly.
# Maybe later.

class ByondRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        code = str(url_decode(self.path[1:]))
        print('\nGot request:')
        print(code)

        request = code.split(':')
        if request[0] in 'current_map':
            set_cr_map(mapdmn, request[1])
        if request[0] in 'next_map':
            set_nxt_map(mapdmn, request[1])
            install_map(mapdmn)
            stop_server(map_daemon)
            sys.exit('Compilation ended') #I cannot describe how stupid I'm feeling right now

def url_decode(text):
    """Decode a URL into regular text"""
    inp = list(text)
    out = []
    while inp:
        c = inp.pop(0)
        if c == '%':
            c = chr(int(inp.pop(0) + inp.pop(0), 16))
        out.append(c)
    return ''.join(out)

def set_cr_map(mapdaemon, map):
    mapdaemon.set_current_map(map)

def set_nxt_map(mapdaemon, map):
    mapdaemon.set_next_map(map)

def install_map(mapdaemon):
    mapdaemon.install_next_map()

def stop_server(servak):
    servak.server_close()
            
if __name__ == '__main__':

    #initialize mapdaemon and json config

    temp = open('mapdaemon_config.json', mode='r')
    deserialized_json_config = json.load(temp)
    temp.close()    
    mapdmn = PyMapDaemon(deserialized_json_config)

    # start the server listening on port specified in config

    server_address = ('127.0.0.1', mapdmn.pymapdaemon_port)
    HTTPServer.allow_reuse_address = True
    server_class = HTTPServer
    server_class.allow_reuse_address = True
    map_daemon = server_class(server_address, ByondRequestHandler)
    print(time.asctime(), 'Server Starts - %s:%s' % (server_address))
    try:
        map_daemon.serve_forever()
    except BaseException as error:
        print('An exception occurred: {}'.format(error))
        pass
    map_daemon.server_close()
    print(time.asctime(), 'Server Stops - %s:%s' % (server_address))

#! UTF-8
#!usr/bin/python

import platform #lib for getting platform info
import json
import os
import fileinput
import sys


# This class handles changing map mainly on SS13-DMCA.
# Can be used on any other project though.

class PyMapDaemon:

    # Json config must be already deserialized with python's 'JSON' module.
    # Do not try to load unserialized data, it will end itself on the initialization process
    # Also using convinient 'os' module that handles pathing in different OSs

    def __init__(self, json_config):
        try:
            self.path_to_project = os.path.normpath(str(json_config['path_to_project']))

            self.project_name = os.path.normpath(json_config['project_name'] + '.dme')

            self.byond_location = os.path.normpath(json_config['byond_location'])

            self.maps = json_config['maps'].split(',') # Making a list from string of maps, separated by commas.

            self.pymapdaemon_port = int(json_config['pymapdaemon_port'])

            self.current_map = '999999999999999999'

            self.next_map = '9999999999999999999'
        except TypeError:
            sys.exit('CONFING NOT LOADED PROPERLY. ABORT THE MISSION!')
        if not str(platform.system()) == 'Windows':
            self.byond_location += os.path.normpath(r'/DreamMaker')
            self.path_to_project = os.path.expanduser(self.path_to_project)
        else:
            self.byond_location += os.path.normpath(r'/dm.exe')
            self.byond_location = '"' + self.byond_location + '"'

    # With current naming convetions
    # Big red has to be hardcoded
    # Or maybe I'm just too lazy

    def is_big_red(self, map):
        if str(map) == 'Solaris Ridge':
            map = 'BigRed'
        return map

    def set_current_map(self, current_map):
        if not current_map:
            print('Nothing is passed to set_current_map')
        self.current_map = str(self.is_big_red(current_map))

    def set_next_map(self, next_map):
        if not next_map:
            print('Nothing is passed to install_next_map')
        self.next_map = str(self.is_big_red(next_map))


    def install_next_map(self):
        if self.next_map != self.current_map:
            normalized_next_map = self.next_map.replace(' ', '_')
            normalized_next_map = normalized_next_map.replace('-', '')
            normalized_current_map = self.current_map.replace(' ', '_')
            normalized_current_map = normalized_current_map.replace('-', '')
            temp_path_to_dme = os.path.normpath(self.path_to_project + r'/' + self.project_name)
            config_contain_map = False
            for map in self.maps:
                if normalized_next_map in str(map):
                    normalized_next_map = str(map)
                    config_contain_map = True
            if not config_contain_map:
                print('Config does not contain this map')
                return 0
            # It has to be 'fileinput', with inplace=True
            # Otherwise one needs to implement the same feature by hand
            try:
                mapfile = fileinput.input(temp_path_to_dme, inplace=True)
            except FileNotFoundError:
                sys.exit('FILE NOT FOUND, YOUR CONFIG SUCK')
            # The proper way to deal with this, instead of .replace()
            # Finds if line contains map speicific literal 'Z.01.'
            # Then finds where current map name starts
            # And then cuts is from behind, leaving only:
            # #include "Z.01.
            # Then places next_map.dmm" + new line
            for line in mapfile:
                if 'Z.01.' in line:
                    cut = line.find(normalized_current_map)
                    if cut > 1 :
                        temp = line[:cut]
                        line = temp + normalized_next_map + '.dmm"\n'
                sys.stdout.write(line)
            mapfile.close()
            self.compile_dme()
                
    # Call_path is what will be sent to system command promt
    # Something like "/bin/DreamMaker ~/Downloads/ss13/build_name/build.dme"

    def compile_dme(self):
        temp_path_to_dme = os.path.normpath("'" + self.path_to_project + r'/' + self.project_name + "'")
        path_to_rsc = temp_path_to_dme.replace('.dme', '.rsc')
        call_path = os.path.normpath(self.byond_location + ' ' + temp_path_to_dme)
        delete_path = 'rm ' + path_to_rsc
        print('system command is:\n', call_path)
        try:
            os.system(delete_path)
            os.system(call_path)
        except OSError:
            sys.exit('Compiling failed. Either path or something else')
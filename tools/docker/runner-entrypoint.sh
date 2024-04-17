#!/bin/bash
source /byond/bin/byondsetup
exec DreamDaemon application.dmb ${DREAMDAEMON_PORT} -trusted

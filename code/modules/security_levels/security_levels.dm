/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = code delta

//config.alert_desc_blue_downto


/proc/set_security_level(var/level, no_sound=0, announce=1)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA


	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				if(announce)
					command_announcement.Announce("Attention: Security level lowered to GREEN - all clear.", "Priority Alert", no_sound ? null : 'sound/AI/code_green.ogg')
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_mainship_level(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("default")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					if(announce)
						command_announcement.Announce("Attention: Security level elevated to BLUE - potentially hostile activity on board.", "Priority Alert", no_sound ? null : 'sound/AI/code_blue_elevated.ogg')
				else
					if(announce)
						command_announcement.Announce("Attention: Security level lowered to BLUE - potentially hostile activity on board.", "Priority Alert", no_sound ? null : 'sound/AI/code_blue_lowered.ogg')
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_mainship_level(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("default")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					if(announce)
						command_announcement.Announce("Attention: Security level elevated to RED - there is an immediate threat to the ship.", "Priority Alert", no_sound ? null : 'sound/AI/code_red_elevated.ogg')
				else
					if(announce)
						command_announcement.Announce("Attention: Security level lowered to RED - there is an immediate threat to the ship.", "Priority Alert", no_sound ? null : 'sound/AI/code_red_lowered.ogg')
					/*
					var/area/A
					for(var/obj/machinery/power/apc/O in machines)
						if(is_mainship_level(O.z))
							A = O.loc.loc
							A.toggle_evacuation()
					*/

				security_level = SEC_LEVEL_RED

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_mainship_level(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("redalert")
			if(SEC_LEVEL_DELTA)
				if(announce)
					command_announcement.Announce("Attention! Delta security level reached! " + CONFIG_GET(string/alert_delta), "Priority Alert")
				security_level = SEC_LEVEL_DELTA
				spawn(0)
					for(var/obj/machinery/door/poddoor/shutters/almayer/D in GLOB.machines)
						if(D.id == "sd_lockdown")
							D.open()
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_mainship_level(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("redalert")
	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA
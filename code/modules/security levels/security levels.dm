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
				if(announce) ai_system.Announce("Attention: Security level lowered to GREEN - all clear.", no_sound ? null : 'sound/AI/code_green.ogg')
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in machines)
					if(FA.z == MAIN_SHIP_Z_LEVEL)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")
				for(var/obj/machinery/status_display/SD in machines)
					if(SD.z == MAIN_SHIP_Z_LEVEL)
						SD.set_picture("default")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					if(announce) ai_system.Announce("Attention: Security level elevated to BLUE - potentially hostile activity on board.", no_sound ? null : 'sound/AI/code_blue_elevated.ogg')
				else
					if(announce) ai_system.Announce("Attention: Security level lowered to BLUE - potentially hostile activity on board.", no_sound ? null : 'sound/AI/code_blue_lowered.ogg')
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in machines)
					if(FA.z == MAIN_SHIP_Z_LEVEL)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")
				for(var/obj/machinery/status_display/SD in machines)
					if(SD.z == MAIN_SHIP_Z_LEVEL)
						SD.set_picture("default")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					if(announce) ai_system.Announce("Attention: Security level elevated to RED - there is an immediate threat to the ship.", no_sound ? null : 'sound/AI/code_red_elevated.ogg')
				else
					if(announce) ai_system.Announce("Attention: Security level lowered to RED - there is an immediate threat to the ship.", no_sound ? null : 'sound/AI/code_red_lowered.ogg')
					/*
					var/area/A
					for(var/obj/machinery/power/apc/O in machines)
						if(O.z == MAIN_SHIP_Z_LEVEL)
							A = O.loc.loc
							A.toggle_evacuation()
					*/

				security_level = SEC_LEVEL_RED

				for(var/obj/machinery/firealarm/FA in machines)
					if(FA.z == MAIN_SHIP_Z_LEVEL)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")
				for(var/obj/machinery/status_display/SD in machines)
					if(SD.z == MAIN_SHIP_Z_LEVEL)
						SD.set_picture("redalert")
			if(SEC_LEVEL_DELTA)
				if(announce) ai_system.Announce("Attention! Delta security level reached! " + config.alert_desc_delta)
				security_level = SEC_LEVEL_DELTA
				spawn(0)
					for(var/obj/machinery/door/poddoor/shutters/almayer/D in machines)
						if(D.id == "sd_lockdown")
							D.open()
				for(var/obj/machinery/firealarm/FA in machines)
					if(FA.z == MAIN_SHIP_Z_LEVEL)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")
				for(var/obj/machinery/status_display/SD in machines)
					if(SD.z == MAIN_SHIP_Z_LEVEL)
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


/*DEBUG
/mob/verb/set_thing0()
	set_security_level(0)
/mob/verb/set_thing1()
	set_security_level(1)
/mob/verb/set_thing2()
	set_security_level(2)
/mob/verb/set_thing3()
	set_security_level(3)
*/

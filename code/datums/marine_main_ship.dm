GLOBAL_DATUM_INIT(marine_main_ship, /datum/marine_main_ship, new)

// datum for stuff specifically related to the marine main ship like theseus
/datum/marine_main_ship

	var/obj/structure/orbital_cannon/orbital_cannon
	var/list/ob_type_fuel_requirements

	var/obj/structure/ship_rail_gun/rail_gun

	var/maint_all_access = FALSE

	var/security_level = SEC_LEVEL_GREEN

/datum/marine_main_ship/proc/make_maint_all_access()
	maint_all_access = TRUE
	priority_announce("The maintenance access requirement has been revoked on all airlocks.", "Attention!", sound = 'sound/misc/notice1.ogg')

/datum/marine_main_ship/proc/revoke_maint_all_access()
	maint_all_access = FALSE
	priority_announce("The maintenance access requirement has been readded on all maintenance airlocks.", "Attention!", sound = 'sound/misc/notice2.ogg')

/datum/marine_main_ship/proc/set_security_level(level, announce = TRUE)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	if(level <= SEC_LEVEL_BLUE)
		for(var/obj/effect/soundplayer/alarmplayer AS in GLOB.ship_alarms)
			alarmplayer.deltalarm.stop(alarmplayer)
		for(var/obj/machinery/light/mainship/light AS in GLOB.mainship_lights)
			light.base_state = "tube"
			var/area/A = get_area(light)
			if(!A.power_light || light.status != LIGHT_OK) //do not adjust unpowered or broken bulbs
				continue
			light.light_color = COLOR_WHITE
			light.brightness = 8
			light.light_range = 8
			if(istype(light, /obj/machinery/light/mainship/small))
				light.icon_state = "bulb1"
				light.base_state = "bulb"
			else
				light.icon_state = "tube1"
			light.update_light()
	else
		for(var/obj/effect/soundplayer/alarmplayer AS in GLOB.ship_alarms)
			if(level != SEC_LEVEL_DELTA)
				alarmplayer.deltalarm.stop(alarmplayer)
			else
				alarmplayer.deltalarm.start(alarmplayer)
		for(var/obj/machinery/light/mainship/light AS in GLOB.mainship_lights)
			light.base_state = "tubered"
			var/area/A = get_area(light)
			if(!A.power_light || light.status != LIGHT_OK) //do not adjust unpowered or broken bulbs
				continue
			light.light_color = COLOR_SOMEWHAT_LIGHTER_RED
			light.brightness = 3.0
			light.light_range = 7.5
			if(prob(75)) //randomize light range on most lights, patchy lighting gives a sense of danger
				var/rangelevel = pick(5.5,6.0,6.5,7.0)
				if(prob(15))
					rangelevel -= pick(0.5,1.0,1.5,2.0)
				light.light_range = rangelevel
			if(istype(light, /obj/machinery/light/mainship/small))
				light.icon_state = "bulbred1"
				light.base_state = "bulbred"
			else
				light.icon_state = "tubered1"
			light.update_light()

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				if(announce)
					priority_announce("Attention: Security level lowered to GREEN - all clear.", "Priority Alert", sound = 'sound/AI/code_green.ogg')
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("default")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					if(announce)
						priority_announce("Attention: Security level elevated to BLUE - potentially hostile activity on board.", "Priority Alert", sound = 'sound/AI/code_blue_elevated.ogg')
				else
					if(announce)
						priority_announce("Attention: Security level lowered to BLUE - potentially hostile activity on board.", "Priority Alert", sound = 'sound/AI/code_blue_lowered.ogg')
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("default")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					if(announce)
						priority_announce("Attention: Security level elevated to RED - there is an immediate threat to the ship.", "Priority Alert", sound = 'sound/AI/code_red_elevated.ogg')
				else
					if(announce)
						priority_announce("Attention: Security level lowered to RED - there is an immediate threat to the ship.", "Priority Alert", sound = 'sound/AI/code_red_lowered.ogg')
					/*
					var/area/A
					for(var/obj/machinery/power/apc/O in machines)
						if(is_mainship_level(O.z))
							A = O.loc.loc
							A.toggle_evacuation()
					*/

				security_level = SEC_LEVEL_RED

				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("redalert")
			if(SEC_LEVEL_DELTA)
				if(announce)
					priority_announce("Attention! Delta security level reached! " + CONFIG_GET(string/alert_delta), "Priority Alert")
				security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/door/poddoor/shutters/mainship/D in GLOB.machines)
					if(D.id == "sd_lockdown")
						D.open()
				for(var/obj/machinery/status_display/SD in GLOB.machines)
					if(is_mainship_level(SD.z))
						SD.set_picture("redalert")

		for(var/obj/machinery/firealarm/FA in GLOB.machines)
			if(is_mainship_level(FA.z))
				FA.update_icon()
	else
		return

/datum/marine_main_ship/proc/get_security_level(sec = security_level)
	switch(sec)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/datum/marine_main_ship/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA

#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/items/tank.dmi'
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BACK
	w_class = 3

	var/pressure_full = ONE_ATMOSPHERE*4

	var/pressure = ONE_ATMOSPHERE*4
	var/gas_type = GAS_TYPE_AIR
	var/temperature = T20C

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	var/manipulated_by = null		//Used by _onclick/hud/screen_objects.dm internals to determine if someone has messed with our tank or not.
						//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.

/obj/item/tank/examine(mob/user)
	..()
	if (in_range(src, user))
		var/celsius_temperature = temperature-T0C
		var/descriptive
		switch(celsius_temperature)
			if (-280 to 20)
				descriptive = "cold"
			if(20 to 40)
				descriptive = "room temperature"
			if(40 to 80)
				descriptive = "lukewarm"
			if(80 to 100)
				descriptive = "warm"
			if(100 to 300)
				descriptive = "hot"
			else
				descriptive = "furiously hot"

		user << "\blue \The \icon[src][src] feels [descriptive]"


/obj/item/tank/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used [W] on \icon[src] [src]"

		manipulated_by = user.real_name			//This person is aware of the contents of the tank.

		user << "\blue Results of analysis of \icon[src]"
		if (pressure>0)
			user << "\blue Pressure: [round(pressure,0.1)] kPa"

			user << "\blue [gas_type]: 100%"
			user << "\blue Temperature: [round(temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"
		src.add_fingerprint(user)


/obj/item/tank/attack_self(mob/user as mob)
	if (pressure == 0)
		return

	ui_interact(user)

/obj/item/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	var/using_internal
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal==src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(pressure)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0

	data["maskConnected"] = 0
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal == src || (location.wear_mask && (location.wear_mask.flags_inventory & ALLOWINTERNALS)))
			data["maskConnected"] = 1

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/tank/Topic(href, href_list)
	..()
	if (usr.stat|| usr.is_mob_restrained())
		return 0
	if (src.loc != usr)
		return 0

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
		src.distribute_pressure = min(max(round(src.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
	if (href_list["stat"])
		if(istype(loc,/mob/living/carbon))
			var/mob/living/carbon/location = loc
			if(location.internal == src)
				location.internal = null
				usr << "\blue You close the tank release valve."
				if (location.hud_used && location.hud_used.internals)
					location.hud_used.internals.icon_state = "internal0"
			else
				if(location.wear_mask && (location.wear_mask.flags_inventory & ALLOWINTERNALS))
					location.internal = src
					usr << "\blue You open \the [src] valve."
					if (location.hud_used && location.hud_used.internals)
						location.hud_used.internals.icon_state = "internal1"
				else
					usr << "\blue You need something to connect to \the [src]."

	src.add_fingerprint(usr)
	return 1


/obj/item/tank/return_air()
	return list(gas_type, temperature, pressure)

/obj/item/tank/return_pressure()
	return pressure

/obj/item/tank/return_temperature()
	return temperature

/obj/item/tank/return_gas()
	return gas_type

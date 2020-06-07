#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/items/tank.dmi'
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL

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

		to_chat(user, "<span class='notice'>\The [icon2html(src, user)][src] feels [descriptive], the gauge reads [return_pressure()] kPa.</span>")


/obj/item/tank/attackby(obj/item/I, mob/user, params)
	. = ..()

	if((istype(I, /obj/item/analyzer)) && get_dist(user, src) <= 1)
		visible_message("<span class='warning'>[user] has used [I] on [icon2html(src, user)] [src]</span>")

		manipulated_by = user.real_name			//This person is aware of the contents of the tank.

		to_chat(user, "<span class='notice'>Results of analysis of [icon2html(src, user)]</span>")
		if(pressure > 0)
			to_chat(user, "<span class='notice'>Pressure: [round(pressure, 0.1)] kPa</span>")
			to_chat(user, "<span class='notice'>[gas_type]: 100%</span>")
			to_chat(user, "<span class='notice'>Temperature: [round(temperature - T0C)]&deg;C</span>")
		else
			to_chat(user, "<span class='notice'>Tank is empty!</span>")

/obj/item/tank/return_air()
	return list(gas_type, temperature, distribute_pressure)

/obj/item/tank/return_pressure()
	return pressure

/obj/item/tank/return_temperature()
	return temperature

/obj/item/tank/return_gas()
	return gas_type

/obj/item/tank/proc/remove_pressure(remove)
	pressure = max(0, pressure - remove)
	distribute_pressure = min(distribute_pressure, pressure)
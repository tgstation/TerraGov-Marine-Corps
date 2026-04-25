
/obj/structure/xeno/evotower
	name = "evolution tower"
	desc = "A sickly outcrop from the ground. It seems to ooze a strange chemical that shimmers and warps the ground around it."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "evotower"
	pixel_x = -16
	pixel_y = -16
	obj_integrity = 600
	max_integrity = 600
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL
	///boost amt to be added per tower per cycle
	var/boost_amount = 0.2
	///maturity boost amt to be added per tower per cycle
	var/maturty_boost_amount = 0.4

/obj/structure/xeno/evotower/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].evotowers += src
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/evotower/Destroy()
	GLOB.hive_datums[hivenumber].evotowers -= src
	return ..()

/obj/structure/xeno/evotower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/psychictower
	name = "Psychic Relay"
	desc = "A sickly outcrop from the ground. It seems to allow for more advanced growth of the Xenomorphs."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "maturitytower"
	pixel_x = -16
	pixel_y = -16
	obj_integrity = 400
	max_integrity = 400
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL

/obj/structure/xeno/psychictower/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].psychictowers += src
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/psychictower/Destroy()
	GLOB.hive_datums[hivenumber].psychictowers -= src
	return ..()

/obj/structure/xeno/psychictower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

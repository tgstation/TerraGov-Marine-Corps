
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

/obj/structure/xeno/lighttower
	name = "Light tower"
	desc = "A resin formation that looks like a small pillar. It just provides light, not much more."
	icon = 'ntf_modular/icons/Xeno/1x1building.dmi'
	icon_state = "lighttower"
	bound_width = 32
	bound_height = 32
	obj_integrity = 200
	max_integrity = 200

/obj/structure/xeno/lighttower/Initialize(mapload)
	. = ..()
	set_light(5, 4, LIGHT_COLOR_BLUE)
	playsound(src, "alien_drool", 25)

/obj/structure/xeno/lighttower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(200, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/lighttower/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!(issamexenohive(X)))
		return ..()
	if(X.a_intent == INTENT_HARM && (X.xeno_flags & XENO_DESTROY_OWN_STRUCTURES)) // If we're on harm intend and have the toggle on, destroy it.
		balloon_alert(X, "Removing...")
		if(!do_after(X, XENO_ACID_WELL_FILL_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
			balloon_alert(X, "Stopped removing")
			return
		playsound(src, "alien_resin_break", 25)
		deconstruct(TRUE, X)
		return
	return ..()

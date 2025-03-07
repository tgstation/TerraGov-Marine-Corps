
/obj/structure/xeno/pherotower
	name = "pheromone tower"
	desc = "A resin formation that looks like a small pillar. A faint, weird smell can be perceived from it."
	icon = 'icons/Xeno/1x1building.dmi'
	icon_state = "recoverytower"
	obj_integrity = 400
	max_integrity = 400
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL
	///The type of pheromone currently being emitted.
	var/datum/aura_bearer/current_aura
	///Strength of pheromones given by this tower.
	var/aura_strength = 5
	///Radius (in tiles) of the pheromones given by this tower.
	var/aura_radius = 32

/obj/structure/xeno/pherotower/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "phero", MINIMAP_LABELS_LAYER))
	GLOB.hive_datums[hivenumber].pherotowers += src

//Pheromone towers start off with recovery.
	current_aura = SSaura.add_emitter(src, AURA_XENO_RECOVERY, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	playsound(src, SFX_ALIEN_DROOL, 25)
	update_icon()

/obj/structure/xeno/pherotower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/pherotower/Destroy()
	GLOB.hive_datums[hivenumber].pherotowers -= src
	return ..()

// Clicking on the tower brings up a radial menu that allows you to select the type of pheromone that this tower will emit.
/obj/structure/xeno/pherotower/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	var/phero_choice = show_radial_menu(xeno_attacker, src, GLOB.pheromone_images_list, radius = 35, require_near = TRUE)

	if(!phero_choice)
		return

	QDEL_NULL(current_aura)
	current_aura = SSaura.add_emitter(src, phero_choice, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	balloon_alert(xeno_attacker, "[phero_choice]")
	playsound(src, SFX_ALIEN_DROOL, 25)
	update_icon()

/obj/structure/xeno/pherotower/update_icon_state()
	switch(current_aura.aura_types[1])
		if(AURA_XENO_RECOVERY)
			icon_state = "recoverytower"
			set_light(2, 2, LIGHT_COLOR_BLUE)
		if(AURA_XENO_WARDING)
			icon_state = "wardingtower"
			set_light(2, 2, LIGHT_COLOR_GREEN)
		if(AURA_XENO_FRENZY)
			icon_state = "frenzytower"
			set_light(2, 2, LIGHT_COLOR_RED)

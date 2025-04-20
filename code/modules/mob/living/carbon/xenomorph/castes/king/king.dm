/mob/living/carbon/xenomorph/king
	caste_base_type = /datum/xeno_caste/king
	name = "King"
	desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."
	icon = 'icons/Xeno/castes/king/king.dmi'
	icon_state = "King Walking"
	health = 500
	maxHealth = 500
	plasma_stored = 300
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR //King, like queen, doesn't count towards population limit.
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)

/mob/living/carbon/xenomorph/king/Initialize(mapload)
	. = ..()
	spawn_cry()

/mob/living/carbon/xenomorph/king/generate_name()
	var/playtime_mins = client?.get_exp(xeno_caste.caste_name)
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	if(!client?.prefs.show_xeno_rank || !client)
		name = prefix + "King ([nicknumber])"
		real_name = name
		if(mind)
			mind.name = name
		return
	switch(playtime_mins)
		if(601 to 1500)
			name = prefix + "Mature King ([nicknumber])"
		if(1501 to 4200)
			name = prefix + "Elder Emperor ([nicknumber])"
		if(4201 to 10500)
			name = prefix + "Ancient Emperor ([nicknumber])"
		if(10501 to INFINITY)
			name = prefix + "Prime Emperor ([nicknumber])"
		else
			name = prefix + "Young King ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/// Plays a sound when the King spawns in.
/mob/living/carbon/xenomorph/king/proc/spawn_cry()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)


// ***************************************
// *********** Conqueror
// ***************************************
/mob/living/carbon/xenomorph/king/conqueror
	caste_base_type = /datum/xeno_caste/king/conqueror
	name = "Conqueror"
	desc = "A primordial beast, sculpted by countless fights, intent on conquering the battlefield."
	icon = 'icons/Xeno/castes/king/conqueror.dmi'
	icon_state = "Conqueror Walking"

/mob/living/carbon/xenomorph/king/conqueror/generate_name()
	var/playtime_mins = client?.get_exp(xeno_caste.caste_name)
	var/rank_name
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	if(!client?.prefs.show_xeno_rank || !client)
		name = prefix + "[xeno_caste.display_name] ([nicknumber])"
		real_name = name
		if(mind)
			mind.name = name
		return
	switch(playtime_mins)
		if(601 to 1500) //10 hours
			rank_name = "Mature"
		if(1501 to 4200) //25 hours
			rank_name = "Elder"
		if(4201 to 10500) //70 hours
			rank_name = "Ancient"
		if(10501 to INFINITY) //175 hours
			rank_name = "Exalted"
		else
			rank_name = "Young"
	name = prefix + "[rank_name ? "[rank_name] " : ""][xeno_caste.display_name] ([nicknumber])"
	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/conqueror/spawn_cry()
	return

/// Includes Endurance's health as a HUD element.
/mob/living/carbon/xenomorph/king/conqueror/hud_set_plasma()
	. = ..()
	if(!xeno_caste || stat == DEAD)
		return
	var/image/holder = hud_list[PLASMA_HUD]
	var/endurance_amount = round(endurance_health * 100 / endurance_health_max, 10)
	holder?.overlays += "[endurance_broken ? "no_endurance" : "endurance"][endurance_amount]"

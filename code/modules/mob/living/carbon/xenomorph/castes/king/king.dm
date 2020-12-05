/mob/living/carbon/xenomorph/king
	caste_base_type = /mob/living/carbon/xenomorph/king
	name = "King"
	desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "King Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 500	//High health since it doesnt heal normally
	maxHealth = 500
	amount_grown = 0
	max_grown = 10
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR //King, like queen, doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO

/mob/living/carbon/xenomorph/king/generate_name()
	switch(upgrade)
		if(XENO_UPGRADE_ZERO)
			name = "[hive.prefix]King ([nicknumber])"	 //Young
		if(XENO_UPGRADE_ONE)
			name = "[hive.prefix]Elder King ([nicknumber])"	 //Mature
		if(XENO_UPGRADE_TWO)
			name = "[hive.prefix]Elder Emperor ([nicknumber])"	 //Elder
		if(XENO_UPGRADE_THREE)
			name = "[hive.prefix]Ancient Emperor ([nicknumber])" //Ancient

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/handle_special_state()
	if(whispering)
		icon_state = "King Screeching"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/king/handle_special_wound_states(severity)
	. = ..()
	if(whispering)
		return "king_wounded_screeching"


///resin pod that creates the king xeno after a delay
/obj/structure/resin/king_pod
	name = "psychic echo chamber"
	desc = "A resin monolith used to channel the Queen Mother's energy to summon elder xenomorphs to the battlefield."
	icon = 'icons/Xeno/king_pod.dmi'
	icon_state = "king_pod"
	density = FALSE
	anchored = TRUE
	var/ownerhive

/obj/structure/resin/king_pod/Initialize(mapload, hivenumber)
	. = ..()
	ownerhive = hivenumber
	addtimer(CALLBACK(src, .proc/try_summon_king), KING_SUMMON_TIMER_DURATION)

///creates a new king and tries to get a mob for it
/obj/structure/resin/king_pod/proc/try_summon_king()
	var/new_caste_type = /mob/living/carbon/xenomorph/king
	switch(ownerhive)
		if(XENO_HIVE_CORRUPTED)
			new_caste_type = /mob/living/carbon/xenomorph/king/Corrupted
		if(XENO_HIVE_ALPHA)
			new_caste_type = /mob/living/carbon/xenomorph/king/Alpha
		if(XENO_HIVE_BETA)
			new_caste_type = /mob/living/carbon/xenomorph/king/Beta
		if(XENO_HIVE_ZETA)
			new_caste_type = /mob/living/carbon/xenomorph/king/Zeta
		if(XENO_HIVE_ADMEME)
			new_caste_type = /mob/living/carbon/xenomorph/king/admeme
	var/mob/living/carbon/xenomorph/king/kong = new new_caste_type(src)
	RegisterSignal(kong, COMSIG_MOB_LOGIN , .proc/on_king_occupied)
	kong.offer_mob()

///When the king mob is offered and then accepted this proc ejects the king and does announcements
/obj/structure/resin/king_pod/proc/on_king_occupied(mob/occupied)
	UnregisterSignal(occupied, COMSIG_MOB_LOGIN)
	occupied.forceMove(loc)
	desc += " This one has already been used."
	var/myarea = get_area(src)
	priority_announce("Warning: Psychic anomaly signature in [myarea] has spiked and begun to move.", "TGMC Intel Division")
	xeno_message("<span class='xenoannounce'>[occupied] has awakened at [myarea]. Praise the queen mother!</span>", 3 ,ownerhive)

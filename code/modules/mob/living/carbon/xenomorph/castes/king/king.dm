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
	health = 500
	maxHealth = 500
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR //King, like queen, doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO

/mob/living/carbon/xenomorph/king/Initialize(mapload)
	. = ..()
	SSmonitor.stats.king++
	hive.king_present += 1

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
		if(XENO_UPGRADE_FOUR)
			name = "[hive.prefix]Primordial Emperor ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/on_death()
	. = ..()
	SSmonitor.stats.king--
	hive.king_present = max(hive.king_present - 1, 0)

/mob/living/carbon/xenomorph/king/upgrade_possible()
	return (upgrade != XENO_UPGRADE_THREE)

///resin pod that creates the king xeno after a delay
/obj/structure/resin/king_pod
	name = "psychic echo chamber"
	desc = "A resin monolith used to channel the Queen Mother's energy to summon elder xenomorphs to the battlefield."
	icon = 'icons/Xeno/king_pod.dmi'
	icon_state = "king_pod"
	density = FALSE
	anchored = TRUE
	///Which hive own this pod
	var/ownerhive = ""
	///What xeno was designed to be the new king
	var/mob/living/carbon/xenomorph/future_king

/obj/structure/resin/king_pod/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ownerhive = hivenumber
	addtimer(CALLBACK(src, .proc/choose_king), KING_SUMMON_TIMER_DURATION)
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	hive.king_present += 1

/obj/structure/resin/king_pod/Destroy()
	future_king = null
	return ..()

/obj/structure/resin/king_pod/obj_destruction(damage_flag)
	. = ..()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	if(hive)
		hive.king_present = max(hive.king_present - 1, 0)

/obj/structure/resin/king_pod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X != future_king)
		to_chat(X, span_notice("You are not the future king, you cannot use the pod!"))
		return
	if(!do_after(X, 5 SECONDS, TRUE, src))
		return
	try_summon_king()

/**
 * Choose at random a xeno beyond live xeno of the ownerhive, and ask them if they want to become the king
 * If no xeno accepted to become king, give it to ghosts
 */
/obj/structure/resin/king_pod/proc/choose_king()
	for(var/mob/living/carbon/xenomorph/xenomorph_alive AS in shuffle(GLOB.alive_xeno_list))
		if(xenomorph_alive.hivenumber != ownerhive)
			continue
		if(!(xenomorph_alive.xeno_caste.can_flags & CASTE_CAN_BECOME_KING))
			continue
		var/accept_to_be_king = tgui_alert(xenomorph_alive, "The fate has landed and you, and you can become the King. Do you accept?", "Rise of the King", list("Accept", "Leave it for another xeno"), 20 SECONDS)
		if(accept_to_be_king != "Accept")
			continue
		future_king = xenomorph_alive
		RegisterSignal(future_king, COMSIG_HIVE_XENO_DEATH, .proc/choose_another_king)
		to_chat(future_king, span_notice("You have 5 minutes to go to the [src] to ascend to the king position! Your tracker will guide you to it."))
		future_king.set_tracked(src)
		addtimer(CALLBACK(src, .proc/choose_another_king), 5 MINUTES)
		return
	//If no xeno accepted, give it to ghost
	try_summon_king()

///Signal handler for when the futur king died and another one must be chose
/obj/structure/resin/king_pod/proc/choose_another_king()
	SIGNAL_HANDLER
	if(future_king?.stat != DEAD)
		to_chat(future_king, span_warning("You lost your chance to become the king..."))
	future_king = null
	INVOKE_ASYNC(src, .proc/choose_king)

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
	var/mob/living/carbon/xenomorph/king/kong = new new_caste_type()
	RegisterSignal(kong, COMSIG_MOB_LOGIN , .proc/on_king_occupied)
	if(future_king)
		future_king.mind.transfer_to(kong)
		return
	kong.offer_mob()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	hive.king_present = max(hive.king_present - 1, 0)
	ownerhive = ""

///When the king mob is offered and then accepted this proc ejects the king and does announcements
/obj/structure/resin/king_pod/proc/on_king_occupied(mob/living/carbon/xenomorph/king/occupied)
	SIGNAL_HANDLER
	UnregisterSignal(occupied, COMSIG_MOB_LOGIN)
	occupied.forceMove(get_turf(src))
	var/myarea = get_area(src)
	priority_announce("Warning: Psychic anomaly signature in [myarea] has spiked and begun to move.", "TGMC Intel Division")
	xeno_message(span_xenoannounce("[occupied] has awakened at [myarea]. Praise the Queen Mother!"), 3, ownerhive)
	future_king?.offer_mob()
	SSminimaps.add_marker(occupied, occupied.z, MINIMAP_FLAG_XENO, occupied.xeno_caste.minimap_icon)
	qdel(src)

/obj/structure/resin/king_pod/obj_destruction(damage_flag)
	xeno_message("<B>The [src] has been destroyed at [get_area(src)]!</B>",3,ownerhive)
	priority_announce("Psychic anomaly neutralized in [get_area(src)].", "TGMC Intel Division")
	return ..()

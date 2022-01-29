/mob/living/carbon/xenomorph/chimera
	caste_base_type = /mob/living/carbon/xenomorph/chimera
	name = "Chimera"
	desc = "A slim, deadly alien creature. It has two additional arms with mantis blades."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Chimera Walchimera"
	health = 400
	maxHealth = 400
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_ZERO
	mob_size = MOB_SIZE_BIG

/mob/living/carbon/xenomorph/chimera/Initialize(mapload)
	. = ..()
	SSmonitor.stats.chimera++
	hive.chimera_present += 1

/mob/living/carbon/xenomorph/chimera/on_death()
	. = ..()
	SSmonitor.stats.chimera--
	hive.chimera_present = max(hive.chimera_present - 1, 0)

///resin pod that creates the chimera xeno after a delay
/obj/structure/resin/chimera_pod
	name = "psychic echo chamber"
	desc = "A resin monolith used to channel the Queen Mother's energy to summon elder xenomorphs to the battlefield."
	icon = 'icons/Xeno/king_pod.dmi'
	icon_state = "king_pod"
	density = FALSE
	anchored = TRUE
	///Which hive own this pod
	var/ownerhive = ""
	///What xeno was designed to be the new chimera
	var/mob/living/carbon/xenomorph/future_chimera

/obj/structure/resin/chimera_pod/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ownerhive = hivenumber
	addtimer(CALLBACK(src, .proc/choose_chimera), KING_SUMMON_TIMER_DURATION)
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	hive.chimera_present += 1

/obj/structure/resin/chimera_pod/Destroy()
	future_chimera = null
	return ..()

/obj/structure/resin/chimera_pod/obj_destruction(damage_flag)
	. = ..()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	if(hive)
		hive.chimera_present = max(hive.chimera_present - 1, 0)

/obj/structure/resin/chimera_pod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X != future_chimera)
		to_chat(X, span_notice("You are not the future chimera, you cannot use the pod!"))
		return
	if(!do_after(X, 5 SECONDS, TRUE, src))
		return
	try_summon_chimera()

/**
 * Choose at random a xeno beyond live xeno of the ownerhive, and ask them if they want to become the chimera
 * If no xeno accepted to become chimera, give it to ghosts
 */
/obj/structure/resin/chimera_pod/proc/choose_chimera()
	for(var/mob/living/carbon/xenomorph/xenomorph_alive AS in shuffle(GLOB.alive_xeno_list))
		if(xenomorph_alive.hivenumber != ownerhive)
			continue
		if(!(xenomorph_alive.xeno_caste.caste_flags & CASTE_CAN_BECOME_KING))
			continue
		var/accept_to_be_chimera = tgui_alert(xenomorph_alive, "The fate has landed and you, and you can become the chimera. Do you accept?", "Rise of the chimera", list("Accept", "Leave it for another xeno"), 20 SECONDS)
		if(accept_to_be_chimera != "Accept")
			continue
		future_chimera = xenomorph_alive
		RegisterSignal(future_chimera, COMSIG_HIVE_XENO_DEATH, .proc/choose_another_chimera)
		to_chat(future_chimera, span_notice("You have 5 minutes to go to the [src] to ascend to the chimera position! Your tracker will guide you to it."))
		future_chimera.set_tracked(src)
		addtimer(CALLBACK(src, .proc/choose_another_chimera), 5 MINUTES)
		return
	//If no xeno accepted, give it to ghost
	try_summon_chimera()

///Signal handler for when the futur chimera died and another one must be chose
/obj/structure/resin/chimera_pod/proc/choose_another_chimera()
	SIGNAL_HANDLER
	if(future_chimera?.stat != DEAD)
		to_chat(future_chimera, span_warning("You lost your chance to become the chimera..."))
	future_chimera = null
	INVOKE_ASYNC(src, .proc/choose_chimera)

///creates a new chimera and tries to get a mob for it
/obj/structure/resin/chimera_pod/proc/try_summon_chimera()
	var/new_caste_type = /mob/living/carbon/xenomorph/chimera
	switch(ownerhive)
		if(XENO_HIVE_CORRUPTED)
			new_caste_type = /mob/living/carbon/xenomorph/chimera/Corrupted
		if(XENO_HIVE_ALPHA)
			new_caste_type = /mob/living/carbon/xenomorph/chimera/Alpha
		if(XENO_HIVE_BETA)
			new_caste_type = /mob/living/carbon/xenomorph/chimera/Beta
		if(XENO_HIVE_ZETA)
			new_caste_type = /mob/living/carbon/xenomorph/chimera/Zeta
		if(XENO_HIVE_ADMEME)
			new_caste_type = /mob/living/carbon/xenomorph/chimera/admeme
	var/mob/living/carbon/xenomorph/chimera/_chimera = new new_caste_type()
	RegisterSignal(_chimera, COMSIG_MOB_LOGIN , .proc/on_chimera_occupied)
	if(future_chimera)
		future_chimera.mind.transfer_to(_chimera)
		return
	_chimera.offer_mob()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	hive.chimera_present = max(hive.chimera_present - 1, 0)
	ownerhive = ""

///When the chimera mob is offered and then accepted this proc ejects the chimera and does announcements
/obj/structure/resin/chimera_pod/proc/on_chimera_occupied(mob/living/carbon/xenomorph/chimera/occupied)
	SIGNAL_HANDLER
	UnregisterSignal(occupied, COMSIG_MOB_LOGIN)
	occupied.forceMove(get_turf(src))
	var/myarea = get_area(src)
	priority_announce("Warning: Psychic anomaly signature in [myarea] has spiked and begun to move.", "TGMC Intel Division")
	xeno_message(span_xenoannounce("[occupied] has awakened at [myarea]. Praise the Queen Mother!"), 3, ownerhive)
	future_chimera?.offer_mob()
	SSminimaps.add_marker(occupied, occupied.z, MINIMAP_FLAG_XENO, occupied.xeno_caste.minimap_icon)
	qdel(src)

/obj/structure/resin/chimera_pod/obj_destruction(damage_flag)
	xeno_message("<B>The [src] has been destroyed at [get_area(src)]!</B>",3,ownerhive)
	priority_announce("Psychic anomaly neutralized in [get_area(src)].", "TGMC Intel Division")
	return ..()

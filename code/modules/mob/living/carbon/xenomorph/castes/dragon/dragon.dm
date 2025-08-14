/mob/living/carbon/xenomorph/dragon
	caste_base_type = /datum/xeno_caste/dragon
	name = "Dragon"
	desc = "A massive, ancient beast with scales that shimmer like polished armor. The fiercest and most formidable creature."
	icon = 'icons/Xeno/castes/dragon.dmi'
	icon_state = "Dragon Walking"
	attacktext = "bites"
	friendly = "nuzzles"
	health = 850
	maxHealth = 850
	plasma_stored = 0
	pixel_x = -48
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)
	attack_effect = list("dragonslash","dragonslash2")

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)
	hive.dragon_present += 1

/mob/living/carbon/xenomorph/dragon/on_death()
	. = ..()
	hive.dragon_present = max(hive.dragon_present - 1, 0)

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/throw_at(atom/target, range, speed = 5, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	return FALSE

/mob/living/carbon/xenomorph/dragon/handle_special_state()
	if(!(status_flags & INCORPOREAL))
		return FALSE
	var/datum/action/ability/activable/xeno/fly/fly_ability = actions_by_path[/datum/action/ability/activable/xeno/fly]
	if(!fly_ability || fly_ability.performing_landing_animation || COOLDOWN_TIMELEFT(fly_ability, animation_cooldown))
		return FALSE
	icon_state = "dragon_marker"
	return TRUE

/// If they have plasma, reduces their damage accordingly by up to 50%. Ratio is 4 plasma per 1 damage.
/mob/living/carbon/xenomorph/dragon/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if((status_flags & GODMODE) || damage <= 0)
		return FALSE
	if(damagetype != BRUTE && damagetype != BURN)
		return FALSE
	if(stat != DEAD && plasma_stored)
		var/damage_reduction = min(damage / 2, plasma_stored / 5)
		use_plasma(ROUND_UP(damage_reduction * 5))
		damage -= damage_reduction
	return ..()

///resin den that creates the dragon xeno after a delay
/obj/structure/resin/dragon_den
	name = "dragons den"
	desc = "A resin monolith used to channel the Queen Mother's energy to summon elder xenomorphs to the battlefield."
	icon = 'icons/Xeno/dragon_den.dmi'
	icon_state = "dragon_den"
	density = FALSE
	anchored = TRUE
	///Which hive own this den
	var/ownerhive = ""
	///What xeno was designed to be the new dragon
	var/mob/living/carbon/xenomorph/future_dragon

/obj/structure/resin/dragon_den/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ownerhive = hivenumber
	addtimer(CALLBACK(src, .proc/choose_dragon), 5 MINUTES)
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	hive.dragon_present += 1

/obj/structure/resin/dragon_den/Destroy()
	future_dragon = null
	return ..()

/obj/structure/resin/dragon_den/obj_destruction(damage_flag)
	. = ..()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	if(hive)
		hive.dragon_present = max(hive.dragon_present - 1, 0)

/obj/structure/resin/dragon_den/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X != future_dragon)
		to_chat(X, span_notice("You are not the future dragon, you cannot use the den!"))
		return
	if(!do_after(X, 5 SECONDS, TRUE, src))
		return
	try_summon_dragon()

/**
 * Choose at random a xeno beyond live xeno of the ownerhive, and ask them if they want to become the dragon.
 * If no xeno accepted to become dragon, give it to ghosts
 */
/obj/structure/resin/dragon_den/proc/choose_dragon()
	for(var/mob/living/carbon/xenomorph/xenomorph_alive AS in shuffle(GLOB.alive_xeno_list))
		if(xenomorph_alive.hivenumber != ownerhive)
			continue
		if((xenomorph_alive.xeno_caste.caste_flags & CASTE_EXCLUDE_BECOME_DRAGON))
			continue
		var/accept_to_be_dragon = tgui_alert(xenomorph_alive, "The fate has landed and you, and you can become the Dragon. Do you accept?", "Ascent of the Dragon", list("Accept", "Leave it for another xeno"), 20 SECONDS)
		if(accept_to_be_dragon != "Accept")
			continue
		future_dragon = xenomorph_alive
		RegisterSignal(future_dragon, COMSIG_HIVE_XENO_DEATH, choose_another_dragon())
		to_chat(future_dragon, span_notice("You have 5 minutes to go to the [src] to ascend to as the dragon! Your tracker will guide you to it."))
		future_dragon.set_tracked(src)
		addtimer(CALLBACK(src, choose_another_dragon()), 5 MINUTES)
		return
	//If no xeno accepted, give it to ghost
	try_summon_dragon()

///Signal handler for when the future dragon died and another one must be chosen
/obj/structure/resin/dragon_den/proc/choose_another_dragon()
	SIGNAL_HANDLER
	if(future_dragon?.stat != DEAD)
		to_chat(future_dragon, span_warning("You lost your chance to become the dragon..."))
	future_dragon = null
	INVOKE_ASYNC(src, .proc/choose_dragon)

///creates a new dragon and tries to get a mob for it
/obj/structure/resin/dragon_den/proc/try_summon_dragon()
	var/new_caste_type = /mob/living/carbon/xenomorph/dragon
	switch(ownerhive)
		if(XENO_HIVE_CORRUPTED)
			new_caste_type = /mob/living/carbon/xenomorph/dragon/Corrupted
		if(XENO_HIVE_ALPHA)
			new_caste_type = /mob/living/carbon/xenomorph/dragon/Alpha
		if(XENO_HIVE_BETA)
			new_caste_type = /mob/living/carbon/xenomorph/dragon/Beta
		if(XENO_HIVE_ZETA)
			new_caste_type = /mob/living/carbon/xenomorph/dragon/Zeta
		if(XENO_HIVE_ADMEME)
			new_caste_type = /mob/living/carbon/xenomorph/dragon/admeme
	var/mob/living/carbon/xenomorph/dragon/drogon = new new_caste_type()
	RegisterSignal(drogon, COMSIG_MOB_LOGIN , .proc/on_dragon_occupied)
	if(future_dragon)
		future_dragon.mind.transfer_to(drogon)
		return
	drogon.offer_mob()
	var/datum/hive_status/hive = GLOB.hive_datums[ownerhive]
	hive.dragon_present = max(hive.dragon_present - 1, 0)
	ownerhive = ""

///When the dragon mob is offered and then accepted this proc ejects the dragon and does announcements
/obj/structure/resin/dragon_den/proc/on_dragon_occupied(mob/living/carbon/xenomorph/dragon/occupied)
	SIGNAL_HANDLER
	UnregisterSignal(occupied, COMSIG_MOB_LOGIN)
	occupied.forceMove(get_turf(src))
	var/myarea = get_area(src)
	priority_announce("Warning: Psychic anomaly signature in [myarea] has spiked and begun to move.", "TGMC Intel Division")
	xeno_message(span_xenoannounce("[occupied] has awakened at [myarea]. Praise the Queen Mother!"), 3, ownerhive)
	future_dragon?.offer_mob()
	SSminimaps.add_marker(occupied, occupied.z, MINIMAP_FLAG_XENO, occupied.xeno_caste.minimap_icon)
	qdel(src)

/obj/structure/resin/dragon_den/obj_destruction(damage_flag)
	xeno_message("<B>The [src] has been destroyed at [get_area(src)]!</B>",3,ownerhive)
	priority_announce("Psychic anomaly neutralized in [get_area(src)].", "TGMC Intel Division")
	return ..()

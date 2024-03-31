/datum/antagonist/zombie
	name = "Zombie"
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "zombie"
	var/zombie_start
	var/revived = FALSE
	var/next_idle_sound
	show_in_roundend = FALSE

/datum/antagonist/zombie/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampirelord))
		var/datum/antagonist/vampirelord/V = examined_datum
		if(!V.disguised)
			return "<span class='boldnotice'>Another deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/zombie))
		return "<span class='boldnotice'>Another deadite. My ally.</span>"
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return "<span class='boldnotice'>Another deadite.</span>"

/datum/antagonist/zombie/on_gain()
	if(owner)
		var/mob/living/carbon/human/H = owner.current
		if(H)
			var/obj/item/bodypart/B = H.get_bodypart(BODY_ZONE_HEAD)
			if(!B)
				qdel(src)
				return
	zombie_start = world.time
	return ..()

/datum/antagonist/zombie/proc/transform_zombie()
	if(owner)
		owner.skill_experience = list()
	var/mob/living/carbon/human/H = owner.current
	if(!H)
		qdel(src)
		return
	var/obj/item/bodypart/B = H.get_bodypart(BODY_ZONE_HEAD)
	if(!B)
		qdel(src)
		return
	if(H.mind)
		H.mind.special_role = name
	if(H.dna && H.dna.species)
		H.dna.species.soundpack_m = new /datum/voicepack/zombie/m()
		H.dna.species.soundpack_f = new /datum/voicepack/zombie/f()
	H.remove_all_languages()
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/unarmed/claw)
	H.update_a_intents()
	H.setToxLoss(0, 0)
	H.aggressive=1
	H.mode = AI_IDLE
	if(H.mind)
		H.mind.RemoveAllSpells()

	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(H,1)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision/zombie
	eyes.Insert(H)
	H.ambushable = FALSE

	if(H.charflaw)
		QDEL_NULL(H.charflaw)
	H.mob_biotypes = MOB_UNDEAD
	H.update_body()
	H.faction = list("undead")
	ADD_TRAIT(H, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOFATSTAM, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EASYDISMEMBER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CHUNKYFINGERS, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_BASHDOORS, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_LIMPDICK, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)
	H.verbs |= /mob/living/carbon/human/proc/zombie_seek
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_disabled()
//	H.STASTR = rand(12,18)
	H.STASPD = rand(5,7)
	H.STAINT = 1


/datum/antagonist/zombie/greet()
//	to_chat(owner.current, "<span class='userdanger'>Death is not the end...</span>")
	..()

/datum/antagonist/zombie/on_life(mob/user)
	if(!user)
		return
	if(user.stat == DEAD)
		return
	var/mob/living/carbon/human/H = user
	H.blood_volume = BLOOD_VOLUME_MAXIMUM
	if(world.time > next_idle_sound)
		H.emote("idle")
		next_idle_sound = world.time + rand(5 SECONDS, 10 SECONDS)

/datum/antagonist/zombie/proc/wake_zombie()
	testing("WAKEZOMBIE")
	if(owner.current)
		var/mob/living/carbon/human/H = owner.current
		if(!H || !istype(H))
			return
		var/obj/item/bodypart/B = H.get_bodypart(BODY_ZONE_HEAD)
		if(!B)
			qdel(src)
			return
		if(H.stat != DEAD)
			qdel(src)
			return
		if(istype(H.loc, /obj/structure/closet/dirthole))
			qdel(src)
			return
		GLOB.dead_mob_list -= H
		GLOB.alive_mob_list |= H
		H.stat = null //the mob starts unconscious,
		H.blood_volume = BLOOD_VOLUME_MAXIMUM
		H.updatehealth() //then we check if the mob should wake up.
		H.update_mobility()
		H.update_sight()
		H.clear_alert("not_enough_oxy")
		H.reload_fullscreen()
		H.add_client_colour(/datum/client_colour/monochrome)
		revived = TRUE //so we can die for real later
		transform_zombie()
		if(H.stat == DEAD)
			//could not revive
			owner.remove_antag_datum(/datum/antagonist/zombie)

/mob/living/carbon/human/proc/zombie_seek()
	set name = "Seek Brains"
	set category = "ZOMBIE"

	var/datum/antagonist/zombie/WD = mind.has_antag_datum(/datum/antagonist/zombie)
	if(!WD)
		return
	if(stat)
		return
	if(world.time % 5)
		to_chat(src, "<span class='warning'>I failed to smell anything...</span>")
		return
	var/closest_dist
	var/the_dir
	for(var/mob/living/carbon/human/M in GLOB.human_list)
		if(M == src)
			continue
		if(MOB_UNDEAD in M.mob_biotypes)
			continue
		if(M.stat == DEAD)
			continue
		var/TD = get_dist(src, M)
		if(!closest_dist)
			closest_dist = TD
			the_dir = get_dir(src, M)
		else
			if(TD < closest_dist)
				closest_dist = TD
				the_dir = get_dir(src, M)
	if(!closest_dist)
		to_chat(src, "<span class='warning'>I failed to smell anything...</span>")
		return
	to_chat(src, "<span class='warning'>[closest_dist], [dir2text(the_dir)]</span>")

/mob/living/carbon/human/proc/zombie_infect()
	if(prob(80))
		return
	if(!mind)
		return
	if(mind.has_antag_datum(/datum/antagonist/vampirelord))
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	var/datum/antagonist/zombie/new_antag = new /datum/antagonist/zombie()
	mind.add_antag_datum(new_antag)
	if(stat != DEAD)
		to_chat(src, "<span class='danger'>I feel horrible...</span>")
		if(getToxLoss() >= 75 && blood_volume)
			mob_timers["puke"] = world.time
			vomit(1, blood = TRUE)
		sleep(3 MINUTES)
		flash_fullscreen("redflash3")
		death()

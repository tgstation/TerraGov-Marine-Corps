/mob/living/carbon/xenomorph/facehugger
	caste_base_type = /mob/living/carbon/xenomorph/facehugger
	name = "Facehugger"
	desc = "This one looks much more active than its fellows"
	icon = 'icons/Xeno/facehugger_playable.dmi'
	icon_state = "Facehugger Walking"

	health = 50
	maxHealth = 50
	plasma_stored = 100

	pixel_x = -8
	pixel_y = -3
	old_x = -8
	old_y = -3

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	mob_size = MOB_SIZE_SMALL
	pull_speed = -2
	flags_pass = PASSXENO | PASSTABLE | PASSMOB
	density = FALSE

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	bubble_icon = "alien"

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/facehugger/Initialize(mapload)
	. = ..()
	GLOB.hive_datums[hivenumber].facehuggers += src

/mob/living/carbon/xenomorph/facehugger/handle_living_health_updates()
	. = ..()
	//We lose health if we go off the weed
	if(!loc_weeds_type && !is_ventcrawling && !(lying_angle || resting))
		adjustBruteLoss(2, TRUE)
		return

/mob/living/carbon/xenomorph/facehugger/update_progression()
	return

/mob/living/carbon/xenomorph/facehugger/on_death()
	///We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, 1 MINUTES)
	GLOB.hive_datums[hivenumber].facehuggers -= src
	return ..()

/mob/living/carbon/xenomorph/facehugger/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/pull_response(mob/puller)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/death_cry()
	playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

///Trying to attach facehagger to face. Returns true on success and false otherwise
/mob/living/carbon/xenomorph/facehugger/proc/try_attach(mob/living/carbon/human/host)
	var/obj/item/clothing/mask/facehugger/larval/mask = new /obj/item/clothing/mask/facehugger/larval(host, src.hivenumber, src)
	if(host.can_be_facehugged(mask, provoked = TRUE))
		if(mask.Attach(host, FALSE)) //Attach hugger-mask
			src.forceMove(host) //Moving sentient hugger inside host
			return TRUE
		else
			qdel(mask)
			return FALSE
	else
		qdel(mask)
		return FALSE




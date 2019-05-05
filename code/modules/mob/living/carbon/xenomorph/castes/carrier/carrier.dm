/mob/living/carbon/Xenomorph/Carrier
	caste_base_type = /mob/living/carbon/Xenomorph/Carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	drag_delay = 6 //pulling a big dead xeno is hard
	speed = 0
	mob_size = MOB_SIZE_BIG
	var/list/huggers = list()
	var/eggs_cur = 0
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16 //Needed for 2x2
	old_x = -16

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/activable/retrieve_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/Xenomorph/Carrier/death(gibbed)
	. = ..()
	if(. && !gibbed && length(huggers))
		var/chance = 75
		visible_message("<span class='xenowarning'>The chittering mass of tiny aliens is trying to escape [src]!</span>")
		for(var/i in 1 to 3)
			var/obj/item/clothing/mask/facehugger/F = pick_n_take(huggers)
			if(!F)
				return
			if(prob(chance))
				F.forceMove(loc)
				step_away(F,src,1)
				addtimer(CALLBACK(F, /obj/item/clothing/mask/facehugger.proc/GoActive, TRUE), 2 SECONDS)
			else
				qdel(F)
			chance -= 30
		QDEL_LIST(huggers)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Carrier/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Stored Huggers: [huggers.len] / [xeno_caste.huggers_max]")
		stat(null, "Stored Eggs: [eggs_cur] / [xeno_caste.eggs_max]")

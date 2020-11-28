/mob/living/carbon/xenomorph/carrier
	caste_base_type = /mob/living/carbon/xenomorph/carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	var/list/huggers = list()
	var/eggs_cur = 0
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16 //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/carrier/on_death()
	if(length(huggers))
		var/chance = 75
		visible_message("<span class='xenowarning'>The chittering mass of tiny aliens is trying to escape [src]!</span>")
		for(var/i in 1 to 3)
			var/obj/item/clothing/mask/facehugger/F = pick_n_take(huggers)
			if(!F)
				break
			if(prob(chance))
				F.forceMove(loc)
				step_away(F,src,1)
				addtimer(CALLBACK(F, /obj/item/clothing/mask/facehugger.proc/go_active, TRUE), 2 SECONDS)
			else
				qdel(F)
			chance -= 30
		QDEL_LIST(huggers)

	return ..()


// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/carrier/Stat()
	. = ..()

	if(statpanel("Game"))
		stat("Stored Huggers:", "[LAZYLEN(huggers)] / [xeno_caste.huggers_max]")
		stat("Stored Eggs:", "[LAZYLEN(eggs_cur)] / [xeno_caste.eggs_max]")

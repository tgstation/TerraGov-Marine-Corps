/mob/living/carbon/xenomorph/carrier
	caste_base_type = /mob/living/carbon/xenomorph/carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	///Number of huggers the carrier is currently carrying
	var/huggers = 0
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16 //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/carrier/proc/try_drop_all_huggers()
	if(!huggers)
		return

	visible_message(span_xenowarning("A chittering mass of tiny aliens is trying to escape [src]!"))
	while(huggers > 0)
		var/obj/item/clothing/mask/facehugger/F = new selected_hugger_type(get_turf(src))
		step_away(F,src,1)
		addtimer(CALLBACK(F, /obj/item/clothing/mask/facehugger.proc/go_active, TRUE), F.jump_cooldown)
		huggers--

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/carrier/on_death()
	. = ..()
	try_drop_all_huggers()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/carrier/Stat()
	. = ..()

	if(statpanel("Game"))
		stat("Stored Huggers:", "[huggers] / [xeno_caste.huggers_max]")

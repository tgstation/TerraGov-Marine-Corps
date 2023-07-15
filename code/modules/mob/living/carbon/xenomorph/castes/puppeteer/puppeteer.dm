/mob/living/carbon/xenomorph/puppeteer
	caste_base_type = /mob/living/carbon/xenomorph/puppeteer
	name = "Puppeteer"
	desc = "A xenomorph of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Puppeteer Running"
	health = 250
	maxHealth = 250
	plasma_stored = 350
	pixel_x = -8
	old_x = -8
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	mob_size = MOB_SIZE_BIG
	drag_delay = 5 //pulling a big dead xeno is hard
	bubble_icon = "alien"

/mob/living/carbon/xenomorph/puppeteer/Initialize(mapload)
	. = ..()
	GLOB.huds[DATA_HUD_XENO_HEART].add_hud_to(src)
	RegisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(postattack))

/mob/living/carbon/xenomorph/puppeter/handle_special_state() //prevent us from using different run/walk sprites
	icon_state = "[xeno_caste.caste_name] Running"
	return TRUE

/mob/living/carbon/xenomorph/puppeteer/proc/postattack(mob/living/source, useless, damage)
	SIGNAL_HANLDER
	plasma_stored = min(plasma_stored + round(damage / 0.8), xeno_caste.plasma_max)

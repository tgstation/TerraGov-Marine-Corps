/mob/living/carbon/xenomorph/puppeteer
	caste_base_type = /mob/living/carbon/xenomorph/puppeteer
	name = "Puppeteer"
	desc = "A xenomorph of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws."
	icon = 'icons/Xeno/castes/puppeteer.dmi'
	icon_state = "Puppeteer Running"
	health = 250
	maxHealth = 250
	plasma_stored = 350
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	drag_delay = 5 //pulling a big dead xeno is hard
	bubble_icon = "alien"

/mob/living/carbon/xenomorph/puppeteer/Initialize(mapload)
	. = ..()
	GLOB.huds[DATA_HUD_XENO_HEART].add_hud_to(src)
	RegisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(postattack))

/mob/living/carbon/xenomorph/puppeteer/proc/postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	plasma_stored = min(plasma_stored + round(damage / 0.8), xeno_caste.plasma_max)
	SEND_SIGNAL(src, COMSIG_PUPPET_CHANGE_ALL_ORDER, PUPPET_ATTACK, target) //we are on harm intent so it probably means we want to kill the target

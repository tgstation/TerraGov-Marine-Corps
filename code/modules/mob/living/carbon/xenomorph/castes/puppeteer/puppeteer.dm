/mob/living/carbon/xenomorph/puppeteer
	caste_base_type = /mob/living/carbon/xenomorph/puppeteer
	name = "Puppeteer"
	desc = "A xenomorph of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Puppeteer Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 100
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	mob_size = MOB_SIZE_BIG
	drag_delay = 5 //pulling a big dead xeno is hard
	bubble_icon = "alien"

/mob/living/carbon/xenomorph/puppeteer/Initialize(mapload)
	. = ..()
	GLOB.huds[DATA_HUD_XENO_HEART].add_hud_to(src)

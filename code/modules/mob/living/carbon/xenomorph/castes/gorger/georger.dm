/mob/living/carbon/xenomorph/georger
	caste_base_type = /mob/living/carbon/xenomorph/georger
	name = "georger"
	desc = "A large, powerfully muscled xeno with seemingly more vitality than others."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "georger Walking"
	health = 600
	maxHealth = 600
	plasma_stored = 100
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	mob_size = MOB_SIZE_BIG
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/georger/Initialize(mapload)
	. = ..()
	GLOB.huds[DATA_HUD_XENO_HEART].add_hud_to(src)

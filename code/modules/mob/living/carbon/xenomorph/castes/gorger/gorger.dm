/mob/living/carbon/xenomorph/gorger
	caste_base_type = /datum/xeno_caste/gorger
	name = "Gorger"
	desc = "A large, powerfully muscled xeno with seemingly more vitality than others."
	icon = 'icons/Xeno/castes/gorger.dmi'
	icon_state = "Gorger Walking"
	health = 600
	maxHealth = 600
	plasma_stored = 100
	pixel_x = -16
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	mob_size = MOB_SIZE_BIG
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/gorger/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_XENO_HEART]
	hud.add_hud_to(src)

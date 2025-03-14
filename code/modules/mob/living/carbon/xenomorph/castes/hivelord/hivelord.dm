/mob/living/carbon/xenomorph/hivelord
	caste_base_type = /datum/xeno_caste/hivelord
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/Xeno/castes/hivelord.dmi'
	icon_state = "Hivelord Walking"
	bubble_icon = "alienroyal"
	health = 250
	maxHealth = 250
	plasma_stored = 200
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/hivelord/Initialize(mapload)
	. = ..()
	update_spits()


/mob/living/carbon/xenomorph/hivelord/get_status_tab_items()
	. = ..()
	. += "Active Tunnel Sets: [LAZYLEN(tunnels)] / [HIVELORD_TUNNEL_SET_LIMIT]"
	. += "Active Recovery Pylons: [LAZYLEN(GLOB.hive_datums[hivenumber].recovery_pylons)] / [HIVELORD_RECOVERY_PYLON_SET_LIMIT]"

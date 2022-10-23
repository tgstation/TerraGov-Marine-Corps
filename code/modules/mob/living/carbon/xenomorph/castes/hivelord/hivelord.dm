/mob/living/carbon/xenomorph/hivelord
	caste_base_type = /mob/living/carbon/xenomorph/hivelord
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 200
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	orbit_icon = "chess-rook"
	var/list/tunnels = list() //list of active tunnels

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/hivelord/Initialize()
	. = ..()
	update_spits()


/mob/living/carbon/xenomorph/hivelord/Stat()
	. = ..()

	if(statpanel("Game"))
		stat("Active Tunnel Sets:", "[LAZYLEN(tunnels)] / [HIVELORD_TUNNEL_SET_LIMIT]")

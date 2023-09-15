//medical hud used by ghosts
/datum/atom_hud/medical/observer
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, XENO_DEBUFF_HUD, STATUS_HUD, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD, XENO_BANISHED_HUD)

//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_FIRE_HUD, XENO_BANISHED_HUD)

/mob/living/carbon/xenomorph/proc/hud_set_banished()
	var/image/holder = hud_list[XENO_BANISHED_HUD]
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if (stat != DEAD && HAS_TRAIT(src, TRAIT_BANISHED))
		holder.icon_state = "xeno_banished"
	holder.pixel_x = -4
	holder.pixel_y = -6

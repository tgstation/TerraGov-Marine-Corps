//Hivelord Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Hivelord
	caste = "Hivelord"
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 220
	maxHealth = 220
	storedplasma = 200
	maxplasma = 800
	evolution_threshold = 800
	plasma_gain = 35
	evolves_to = list()
	caste_desc = "A builder of REALLY BIG hives."
	pixel_x = -16
	speed = 0.4
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	var/speed_activated = 0
	tier = 2
	upgrade = 0
	aura_strength = 1 //Hivelord's aura is not extremely strong, but better than Drones. At the top, it's just a bit above a young Queen. Climbs by 0.5 to 2.5
	actions = list(
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/tail_attack,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/transfer_plasma/hivelord,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/toggle_speed,
		)



/mob/living/carbon/Xenomorph/Hivelord/movement_delay()
	if(istype(loc, /turf/space))
		return -1 //It's hard to be slowed down in space by... anything

	. = ..()

	if(speed_activated)
		if(locate(/obj/effect/alien/weeds) in loc)
			. -= 1.5


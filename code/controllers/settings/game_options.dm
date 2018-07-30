/datum/configuration
	//game_options.txt configs
	var/health_threshold_softcrit = 0
	var/health_threshold_crit = 0
	var/health_threshold_dead = -100

	var/organ_health_multiplier = 1
	var/organ_regeneration_multiplier = 1

	var/bones_can_break = 0
	var/limbs_can_break = 0

	var/revival_pod_plants = 1
	var/revival_cloning = 1
	var/revival_brain_life = -1

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/animal_delay = 0

	var/use_loyalty_implants = 0
	var/remove_gun_restrictions = 0
	var/allow_synthetic_gun_use = 0

/datum/configuration/proc/initialize_game_options(name,value)
	value = text2num(value)
	switch(name)
		if("health_threshold_crit")
			config.health_threshold_crit = value
		if("health_threshold_softcrit")
			config.health_threshold_softcrit = value
		if("health_threshold_dead")
			config.health_threshold_dead = value
		if("revival_pod_plants")
			config.revival_pod_plants = value
		if("revival_cloning")
			config.revival_cloning = value
		if("revival_brain_life")
			config.revival_brain_life = value
		if("organ_health_multiplier")
			config.organ_health_multiplier = value / 100
		if("organ_regeneration_multiplier")
			config.organ_regeneration_multiplier = value / 100
		if("bones_can_break")
			config.bones_can_break = value
		if("limbs_can_break")
			config.limbs_can_break = value

		if("run_speed")
			config.run_speed = value
		if("walk_speed")
			config.walk_speed = value

		if("human_delay")
			config.human_delay = value
		if("robot_delay")
			config.robot_delay = value
		if("monkey_delay")
			config.monkey_delay = value
		if("alien_delay")
			config.alien_delay = value
		if("animal_delay")
			config.animal_delay = value


		if("use_loyalty_implants")
			config.use_loyalty_implants = 1
		if("remove_gun_restrictions")
			config.remove_gun_restrictions = 1
		else
			log_misc("Unknown setting in game options: '[name]'")
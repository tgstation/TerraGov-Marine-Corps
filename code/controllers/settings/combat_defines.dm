/datum/configuration
	var/proj_base_accuracy_mult = 0.01
	var/proj_base_damage_mult = 0.01

	var/proj_variance_high = 105
	var/proj_variance_low = 95

	var/critical_chance_low = 5
	var/critical_chance_high = 10

	var/base_armor_resist_low = 1.0
	var/base_armor_resist_high = 2.0

	var/xeno_armor_resist_min = 0.25
	var/xeno_armor_resist_vlow = 0.33
	var/xeno_armor_resist_low = 0.5
	var/xeno_armor_resist_mlow = 0.66
	var/xeno_armor_resist_lmed = 0.75
	var/xeno_armor_resist_high = 1.5

	var/min_hit_accuracy = 5
	var/low_hit_accuracy = 10
	var/med_hit_accuracy = 15
	var/hmed_hit_accuracy = 20
	var/high_hit_accuracy = 30
	var/max_hit_accuracy = 40

	var/base_hit_accuracy_mult = 1
	var/min_hit_accuracy_mult = 0.05
	var/low_hit_accuracy_mult = 0.10
	var/mlow_hit_accuracy_mult = 0.15
	var/med_hit_accuracy_mult = 0.20
	var/hmed_hit_accuracy_mult = 0.30
	var/high_hit_accuracy_mult = 0.40
	var/max_hit_accuracy_mult = 0.50

	var/base_hit_damage = 10
	var/min_hit_damage = 15
	var/llow_hit_damage = 20
	var/mlow_hit_damage = 25
	var/low_hit_damage = 30
	var/hlow_hit_damage = 35
	var/lmed_hit_damage = 40
	var/lmmed_hit_damage = 45
	var/med_hit_damage = 50
	var/hmed_hit_damage = 55
	var/high_hit_damage = 70
	var/mhigh_hit_damage = 80
	var/max_hit_damage = 90
	var/super_hit_damage = 120
	var/ultra_hit_damage = 150
	var/aprocket_hit_damage = 250
	var/ltb_hit_damage = 300

	var/base_hit_damage_mult = 1
	var/min_hit_damage_mult = 0.05
	var/low_hit_damage_mult = 0.10
	var/med_hit_damage_mult = 0.20
	var/tacshottie_damage_mult = 0.25
	var/hmed_hit_damage_mult = 0.30
	var/high_hit_damage_mult = 0.40
	var/max_hit_damage_mult = 0.50

	var/reg_damage_falloff = 1
	var/smg_damage_falloff = 1.5
	var/buckshot_damage_falloff = 5
	var/extra_damage_falloff = 10

	var/base_damage_falloff_mult = 1
	var/min_damage_falloff_mult = 0.1
	var/low_damage_falloff_mult = 0.25
	var/lmed_damage_falloff_mult = 0.4
	var/med_damage_falloff_mult = 0.5
	var/hmed_damage_falloff_mult = 0.75
	var/high_damage_falloff_mult = 1.5
	var/max_damage_falloff_mult = 2

	var/min_burst_value = 1
	var/low_burst_value = 2
	var/med_burst_value = 3
	var/high_burst_value = 4
	var/vhigh_burst_value = 5
	var/max_burst_value = 6

	var/min_fire_delay = 1
	var/vlow_fire_delay = 1.5
	var/mlow_fire_delay = 2
	var/low_fire_delay = 3
	var/med_fire_delay = 4
	var/high_fire_delay = 5
	var/mhigh_fire_delay = 6
	var/max_fire_delay = 7
	var/tacshottie_fire_delay = 15

	var/min_scatter_value = 5
	var/mlow_scatter_value = 10
	var/low_scatter_value = 15
	var/med_scatter_value = 20
	var/high_scatter_value = 25
	var/thirty_scatter_value = 30
	var/mhigh_scatter_value = 35
	var/max_scatter_value = 40

	var/min_recoil_value = 1
	var/low_recoil_value = 2
	var/med_recoil_value = 3
	var/high_recoil_value = 4
	var/max_recoil_value = 5

	var/min_shrapnel_chance = 5
	var/low_shrapnel_chance = 10
	var/mlow_shrapnel_chance = 20
	var/med_shrapnel_chance = 25
	var/high_shrapnel_chance = 45
	var/max_shrapnel_chance = 75

	var/min_shell_range = 3
	var/close_shell_range = 5
	var/screen_shell_range = 7
	var/near_shell_range = 10
	var/short_shell_range = 15
	var/norm_shell_range = 20
	var/lnorm_shell_range = 25
	var/long_shell_range = 30
	var/mlong_shell_range = 35
	var/max_shell_range = 40

	var/min_shell_speed = 0.5
	var/mslow_shell_speed = 0.75
	var/slow_shell_speed = 1
	var/reg_shell_speed = 2
	var/fast_shell_speed = 3
	var/super_shell_speed = 4
	var/ultra_shell_speed = 5

	var/min_armor_penetration = 5
	var/mlow_armor_penetration = 10
	var/low_armor_penetration = 20
	var/lmed_armor_penetration = 25
	var/med_armor_penetration = 30
	var/hmed_armor_penetration = 40
	var/high_armor_penetration = 50
	var/mhigh_armor_penetration = 60
	var/vhigh_armor_penetration = 70
	var/max_armor_penetration = 80
	var/aprocket_armor_penetration = 120 //It's an anti-tank weapon
	var/ltb_armor_penetration = 150 //Can't stop the rock-et

	var/min_proj_extra = 1
	var/low_proj_extra = 2
	var/med_proj_extra = 3
	var/hmed_proj_extra = 4
	var/high_proj_extra = 5
	var/mhigh_proj_extra = 6
	var/vhigh_proj_extra = 7
	var/max_proj_extra = 8

	var/min_proj_variance = 1
	var/mlow_proj_variance = 3
	var/low_proj_variance = 5
	var/med_proj_variance = 7
	var/hmed_proj_variance = 8
	var/high_proj_variance = 9
	var/max_proj_variance = 10

//The following is *NOT* featured in combat_defines.txt

	var/min_movement_acc_penalty = 1
	var/low_movement_acc_penalty = 2
	var/med_movement_acc_penalty = 3
	var/high_movement_acc_penalty = 4
	var/max_movement_acc_penalty = 5

	var/min_burst_scatter_penalty = 1
	var/low_burst_scatter_penalty = 2
	var/med_burst_scatter_penalty = 3
	var/high_burst_scatter_penalty = 4
	var/max_burst_scatter_penalty = 5

/datum/configuration/proc/initialize_combat_defines(name,value)
	value = text2num(value)
	switch(name)
		if("proj_base_accuracy_mult")
			proj_base_accuracy_mult = value
		if("proj_base_damage_mult")
			proj_base_damage_mult = value
		if("proj_variance_low")
			proj_variance_low = value
		if("proj_variance_high")
			proj_variance_high = value
		if("critical_chance_low")
			critical_chance_low = value
		if("critical_chance_high")
			critical_chance_high = value

		if("base_armor_resist_low")
			base_armor_resist_low = value
		if("base_armor_resist_high")
			base_armor_resist_high = value

		if("xeno_armor_resist_min")
			xeno_armor_resist_min = value
		if("xeno_armor_resist_vlow")
			xeno_armor_resist_vlow = value
		if("xeno_armor_resist_low")
			xeno_armor_resist_low = value
		if("xeno_armor_resist_mlow")
			xeno_armor_resist_low = value
		if("xeno_armor_resist_lmed")
			xeno_armor_resist_lmed = value
		if("xeno_armor_resist_high")
			xeno_armor_resist_high = value

		if("min_hit_accuracy")
			min_hit_accuracy = value
		if("low_hit_accuracy")
			low_hit_accuracy = value
		if("med_hit_accuracy")
			med_hit_accuracy = value
		if("hmed_hit_accuracy")
			hmed_hit_accuracy = value
		if("high_hit_accuracy")
			high_hit_accuracy = value
		if("max_hit_accuracy")
			max_hit_accuracy = value

		if("base_hit_accuracy_mult")
			base_hit_accuracy_mult = value
		if("min_hit_accuracy_mult")
			min_hit_accuracy_mult = value
		if("low_hit_accuracy_mult")
			low_hit_accuracy_mult = value
		if("mlow_hit_accuracy_mult")
			mlow_hit_accuracy_mult = value
		if("med_hit_accuracy_mult")
			med_hit_accuracy_mult = value
		if("hmed_hit_accuracy_mult")
			hmed_hit_accuracy_mult = value
		if("high_hit_accuracy_mult")
			high_hit_accuracy_mult = value
		if("max_hit_accuracy_mult")
			max_hit_accuracy_mult = value

		if("base_hit_damage")
			base_hit_damage = value
		if("min_hit_damage")
			min_hit_damage = value
		if("llow_hit_damage")
			llow_hit_damage = value
		if("mlow_hit_damage")
			mlow_hit_damage = value
		if("low_hit_damage")
			low_hit_damage = value
		if("hlow_hit_damage")
			hlow_hit_damage = value
		if("lmed_hit_damage")
			lmed_hit_damage = value
		if("lmmed_hit_damage")
			lmed_hit_damage = value
		if("med_hit_damage")
			med_hit_damage = value
		if("hmed_hit_damage")
			hmed_hit_damage = value
		if("high_hit_damage")
			high_hit_damage = value
		if("mhigh_hit_damage")
			mhigh_hit_damage = value
		if("max_hit_damage")
			max_hit_damage = value
		if("super_hit_damage")
			super_hit_damage = value
		if("ultra_hit_damage")
			ultra_hit_damage = value
		if("aprocket_hit_damage")
			aprocket_hit_damage = value
		if("ltb_hit_damage")
			ltb_hit_damage = value


		if("base_hit_damage_mult")
			base_hit_damage_mult = value
		if("min_hit_damage_mult")
			min_hit_damage_mult = value
		if("low_hit_damage_mult")
			low_hit_damage_mult = value
		if("med_hit_damage_mult")
			med_hit_damage_mult = value
		if("tacshottie_damage_mult")
			tacshottie_damage_mult = value
		if("hmed_hit_damage_mult")
			hmed_hit_damage_mult = value
		if("high_hit_damage_mult")
			high_hit_damage_mult = value
		if("max_hit_damage_mult")
			max_hit_damage_mult = value

		if("reg_damage_falloff")
			reg_damage_falloff = value
		if("smg_damage_falloff")
			smg_damage_falloff = value
		if("buckshot_damage_falloff")
			buckshot_damage_falloff = value
		if("extra_damage_falloff")
			extra_damage_falloff = value

		if("base_damage_falloff_mult")
			base_damage_falloff_mult = value
		if("min_damage_falloff_mult")
			min_damage_falloff_mult = value
		if("low_damage_falloff_mult")
			low_damage_falloff_mult = value
		if("lmed_damage_falloff_mult")
			lmed_damage_falloff_mult = value
		if("med_damage_falloff_mult")
			med_damage_falloff_mult = value
		if("hmed_damage_falloff_mult")
			hmed_damage_falloff_mult = value
		if("high_damage_falloff_mult")
			high_damage_falloff_mult = value
		if("max_damage_falloff_mult")
			max_damage_falloff_mult = value

		if("min_burst_value")
			min_burst_value = value
		if("low_burst_value")
			low_burst_value = value
		if("med_burst_value")
			med_burst_value = value
		if("high_burst_value")
			high_burst_value = value
		if("vhigh_burst_value")
			vhigh_burst_value = value
		if("max_burst_value")
			max_burst_value = value

		if("min_fire_delay")
			min_fire_delay = value
		if("vlow_fire_delay")
			vlow_fire_delay = value
		if("mlow_fire_delay")
			mlow_fire_delay = value
		if("low_fire_delay")
			low_fire_delay = value
		if("med_fire_delay")
			med_fire_delay = value
		if("high_fire_delay")
			high_fire_delay = value
		if("mhigh_fire_delay")
			mhigh_fire_delay = value
		if("max_fire_delay")
			max_fire_delay = value
		if("tacshottie_fire_delay")
			tacshottie_fire_delay = value

		if("min_scatter_value")
			min_scatter_value = value
		if("mlow_scatter_value")
			low_scatter_value = value
		if("low_scatter_value")
			low_scatter_value = value
		if("med_scatter_value")
			med_scatter_value = value
		if("high_scatter_value")
			high_scatter_value = value
		if("thirty_scatter_value")
			thirty_scatter_value = value
		if("mhigh_scatter_value")
			mhigh_scatter_value = value
		if("max_scatter_value")
			max_scatter_value = value

		if("min_recoil_value")
			min_recoil_value = value
		if("low_recoil_value")
			low_recoil_value = value
		if("med_recoil_value")
			med_recoil_value = value
		if("high_recoil_value")
			high_recoil_value = value
		if("max_recoil_value")
			max_recoil_value = value

		if("min_shrapnel_chance")
			min_shrapnel_chance = value
		if("low_shrapnel_chance")
			low_shrapnel_chance = value
		if("mlow_shrapnel_chance")
			low_shrapnel_chance = value
		if("med_shrapnel_chance")
			med_shrapnel_chance = value
		if("high_shrapnel_chance")
			high_shrapnel_chance = value
		if("max_shrapnel_chance")
			max_shrapnel_chance = value

		if("min_shell_range")
			min_shell_range = value
		if("close_shell_range")
			close_shell_range = value
		if("screen_shell_range")
			screen_shell_range = value
		if("short_shell_range")
			short_shell_range = value
		if("near_shell_range")
			near_shell_range = value
		if("norm_shell_range")
			norm_shell_range = value
		if("lnorm_shell_range")
			lnorm_shell_range = value
		if("long_shell_range")
			long_shell_range = value
		if("mlong_shell_range")
			mlong_shell_range = value
		if("max_shell_range")
			max_shell_range = value

		if("min_shell_speed")
			min_shell_speed = value
		if("mslow_shell_speed")
			mslow_shell_speed = value
		if("slow_shell_speed")
			slow_shell_speed = value
		if("reg_shell_speed")
			reg_shell_speed = value
		if("fast_shell_speed")
			fast_shell_speed = value
		if("super_shell_speed")
			super_shell_speed = value
		if("ultra_shell_speed")
			ultra_shell_speed = value

		if("min_armor_penetration")
			min_armor_penetration = value
		if("mlow_armor_penetration")
			mlow_armor_penetration = value
		if("low_armor_penetration")
			low_armor_penetration = value
		if("lmed_armor_penetration")
			lmed_armor_penetration = value
		if("med_armor_penetration")
			med_armor_penetration = value
		if("hmed_armor_penetration")
			hmed_armor_penetration = value
		if("high_armor_penetration")
			high_armor_penetration = value
		if("mhigh_armor_penetration")
			mhigh_armor_penetration = value
		if("vhigh_armor_penetration")
			vhigh_armor_penetration = value
		if("max_armor_penetration")
			max_armor_penetration = value
		if("aprocket_armor_penetration")
			aprocket_armor_penetration = value
		if("ltb_armor_penetration")
			ltb_armor_penetration = value

		if("min_proj_extra")
			min_proj_extra = value
		if("low_proj_extra")
			low_proj_extra = value
		if("med_proj_extra")
			med_proj_extra = value
		if("hmed_proj_extra")
			hmed_proj_extra = value
		if("high_proj_extra")
			high_proj_extra = value
		if("mhigh_proj_extra")
			mhigh_proj_extra = value
		if("vhigh_proj_extra")
			vhigh_proj_extra = value
		if("max_proj_extra")
			max_proj_extra = value

		if("min_proj_variance")
			min_proj_variance = value
		if("low_proj_variance")
			low_proj_variance = value
		if("mlow_proj_variance")
			mlow_proj_variance = value
		if("med_proj_variance")
			med_proj_variance = value
		if("hmed_proj_variance")
			hmed_proj_variance = value
		if("high_proj_variance")
			high_proj_variance = value
		if("max_proj_variance")
			max_proj_variance = value

		else
			log_misc("Unknown setting in combat defines: '[name]'")

/obj/item/armored_weapon/volkite_carronade
	name = "Volkite Cardanelle"
	desc = "A massive volkite weapon seen on SOM battle tanks, the cardanelle is a devestating anti infantry weapon, able to mow down whole groups of soft targets with ease. \
	Against armored targets however, it can prove less effective."
	icon_state = "volkite"
	fire_sound = 'sound/weapons/guns/fire/volkite_4.ogg'
	windup_sound = 'sound/vehicles/weapons/particle_charge.ogg'
	windup_delay = 0.6 SECONDS
	ammo = /obj/item/ammo_magazine/tank/volkite_carronade
	accepted_ammo = list(/obj/item/ammo_magazine/tank/volkite_carronade)
	maximum_magazines = 5
	hud_state_empty = "battery_empty_flash"
	fire_sound_vary = FALSE
	///Range of this weapon
	var/beam_range = 12
	///Armor pen of this weapon
	var/armor_pen = 30

/obj/item/armored_weapon/volkite_carronade/do_fire(turf/source_turf)
	var/turf/target_turf = get_turf_in_angle(Get_Angle(source_turf, get_turf(current_target)), source_turf, beam_range)

	var/list/turf/beam_turfs = get_line(source_turf, target_turf)
	var/list/turf/impacted_turfs = list()
	var/list/light_effects = list()

	for(var/turf/line_turf AS in beam_turfs)
		target_turf = line_turf //we redefine this so we can draw the beam to where the effect actually stops, if its stopped early
		new /obj/effect/temp_visual/shockwave(line_turf, 4)
		if(isclosedturf(line_turf))
			break
		for(var/range_turf in RANGE_TURFS(1, line_turf))
			impacted_turfs |= range_turf

	for(var/turf/impacted_turf AS in impacted_turfs)
		light_effects += new /atom/movable/hitscan_projectile_effect(impacted_turf, null, null, null, null, null, LIGHT_COLOR_ORANGE)
		var/attack_dir = get_dir(source_turf, impacted_turf)
		var/beam_turf = (impacted_turf in beam_turfs)
		for(var/target in impacted_turf)
			if(isobj(target))
				if(target == chassis || target == chassis.hitbox)
					continue
				if(isitem(target))
					continue
				var/obj/obj_target = target
				if(istype(obj_target, /obj/effect/particle_effect/smoke))
					obj_target.ex_act() //we clear smoke in our path for visual effect
					continue
				if(obj_target.resistance_flags & INDESTRUCTIBLE)
					continue
				var/obj_damage = beam_turf ? 120 : 50
				if(isarmoredvehicle(obj_target) || ishitbox(obj_target))
					obj_damage *= 0.25 //you can hit them a bunch of times
				if(ismecha(obj_target))
					obj_damage *= 3
				obj_target.take_damage(obj_damage, BURN, beam_turf ? ENERGY : FIRE, FALSE, attack_dir, armor_pen, current_firer)
			if(isliving(target))
				var/mob/living/living_target = target
				if(beam_turf)
					living_target.apply_damage(50, BURN, blocked = ENERGY, penetration = armor_pen)
				living_target.apply_damage(40, BURN, blocked = FIRE, updating_health = TRUE)
				living_target.Stagger(beam_turf ? 2 SECONDS : 1 SECONDS)
				living_target.adjust_slowdown(beam_turf ? 2 : 1)
				living_target.adjust_fire_stacks(beam_turf ? 12 : 6)
				living_target.IgniteMob()

	QDEL_IN(source_turf.beam(target_turf, "volkite", beam_type = /obj/effect/ebeam/carronade), 0.6 SECONDS)
	QDEL_LIST_IN(light_effects, 0.6 SECONDS)

/obj/effect/ebeam/carronade/Initialize(mapload)
	. = ..()
	alpha = 0
	animate(src, alpha = 255, time = 0.2 SECONDS)
	animate(alpha = 0, time = 0.4 SECONDS, easing = SINE_EASING|EASE_IN)

/obj/item/armored_weapon/particle_lance
	name = "particle lance"
	desc = "The particle lance is a powerful energy beam weapon, able to tear apart anything in its path with a concentrated beam of charged particles. Particularly potent against armored targets."
	icon_state = "particle_beam"
	ammo = /obj/item/ammo_magazine/tank/particle_lance
	accepted_ammo = list(/obj/item/ammo_magazine/tank/particle_lance)
	fire_sound = 'sound/vehicles/weapons/particle_fire.ogg'
	windup_sound = 'sound/vehicles/weapons/particle_charge.ogg'
	windup_delay = 0.6 SECONDS
	hud_state_empty = "battery_empty_flash"
	fire_sound_vary = FALSE

/obj/item/armored_weapon/coilgun
	name = "battle tank coilgun"
	desc = "The coilgun is considered the standard main weapon for SOM battle tanks. \
	While technologically very different from a traditional cannon, fundamentally both serve the same purpose - to accelerate a large projectile at a high speed towards the enemy."
	icon_state = "coilgun"

/obj/item/armored_weapon/secondary_mlrs
	name = "secondary MLRS"
	desc = "A pair of forward facing multiple launch rocket systems with a total of 12 homing rockets. Can unleash its entire payload in rapid succession."
	icon_state = "mlrs"
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'
	armored_weapon_flags = MODULE_SECONDARY|MODULE_FIXED_FIRE_ARC
	ammo = /obj/item/ammo_magazine/tank/secondary_mlrs
	accepted_ammo = list(/obj/item/ammo_magazine/tank/secondary_mlrs)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	projectile_delay = 0.2 SECONDS
	variance = 40
	rearm_time = 5 SECONDS
	maximum_magazines = 5
	hud_state_empty = "rocket_empty"

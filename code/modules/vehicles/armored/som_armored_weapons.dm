///Actual time for the visual beam effect
#define CARRONADE_BEAM_TIME 0.6 SECONDS

/obj/item/armored_weapon/volkite_carronade
	name = "Volkite Cardanelle"
	desc = "A massive volkite weapon seen on SOM battle tanks, the cardanelle is a devestating anti infantry weapon, able to mow down whole groups of soft targets with ease. \
	Against armored targets however, it can prove less effective."
	icon_state = "volkite"
	fire_sound = 'sound/weapons/guns/fire/volkite_4.ogg'
	interior_fire_sound = 'sound/vehicles/weapons/volkite_fire_interior.ogg'
	windup_sound = 'sound/vehicles/weapons/particle_charge.ogg'
	windup_delay = 0.6 SECONDS
	projectile_delay = 3 SECONDS
	ammo = /obj/item/ammo_magazine/tank/volkite_carronade
	accepted_ammo = list(/obj/item/ammo_magazine/tank/volkite_carronade)
	hud_state_empty = "battery_empty_flash"
	fire_sound_vary = FALSE
	///Range of this weapon
	var/beam_range = 20
	///Armor pen of this weapon
	var/armor_pen = 20

/obj/item/armored_weapon/volkite_carronade/do_fire(turf/source_turf, ammo_override)
	var/turf/target_turf = get_turf_in_angle(Get_Angle(source_turf, get_turf(current_target)), source_turf, beam_range)
	var/list/turf/beam_turfs = get_traversal_line(source_turf, target_turf)
	var/list/turf/impacted_turfs = list()
	var/list/light_effects = list()
	var/list/stop_beam_turfs
	//If the beam is stopped early, we only process the turfs in range of the (new) final turf
	//We do this because we can't change the list the for loop is already cycling through

	for(var/turf/line_turf AS in beam_turfs)
		if(isclosedturf(line_turf))
			break
		for(var/range_turf in RANGE_TURFS(1, line_turf))
			impacted_turfs |= range_turf

	for(var/turf/impacted_turf AS in impacted_turfs)
		if(stop_beam_turfs && !(impacted_turf in stop_beam_turfs))
			break
		light_effects += new /atom/movable/hitscan_projectile_effect(impacted_turf, null, null, null, null, null, LIGHT_COLOR_EMISSIVE_ORANGE)
		var/attack_dir = get_dir(impacted_turf, source_turf)
		var/beam_turf = (impacted_turf in beam_turfs)
		var/beam_stop = FALSE
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
				var/obj_damage = beam_turf ? 500 : 350
				if(isarmoredvehicle(obj_target) || ishitbox(obj_target))
					obj_damage *= 0.75
					beam_stop = TRUE
				else if(ismecha(obj_target))
					beam_stop = TRUE
				obj_target.take_damage(obj_damage * 0.5, BURN, ENERGY, TRUE, attack_dir, armor_pen, current_firer)
				if(!QDELETED(obj_target))
					obj_target.take_damage(obj_damage * 0.5, BURN, FIRE, FALSE, attack_dir, armor_pen, current_firer)
				continue
			if(isliving(target))
				var/mob/living/living_target = target
				living_target.apply_damage(80, BURN, blocked = ENERGY, penetration = armor_pen, attacker = current_firer)
				if(!QDELETED(living_target))
					living_target.apply_damage(80, BURN, blocked = FIRE, penetration = armor_pen, updating_health = TRUE, attacker = current_firer)
				living_target.flash_act(beam_turf ? 2 SECONDS : 1 SECONDS)
				living_target.Stagger(beam_turf ? 3 SECONDS : 2 SECONDS)
				living_target.adjust_slowdown(beam_turf ? 3 : 2)
				living_target.adjust_fire_stacks(beam_turf ? 15 : 9)
				living_target.IgniteMob()
		if(!beam_turf)
			continue
		new /obj/effect/temp_visual/shockwave(impacted_turf, 4)
		target_turf = impacted_turf //we redefine this so we can draw the beam to where the effect actually stops, if its stopped early
		if(!beam_stop)
			continue
		beam_turfs.Cut(beam_turfs.Find(impacted_turf))
		stop_beam_turfs = RANGE_TURFS(1, impacted_turf)

	explosion(target_turf, 0, 2, 5, 0, 3, 4, 4, explosion_cause=current_firer)

	QDEL_IN(source_turf.beam(target_turf, "volkite", beam_type = /obj/effect/ebeam/carronade), CARRONADE_BEAM_TIME)
	QDEL_LIST_IN(light_effects, CARRONADE_BEAM_TIME)

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
	interior_fire_sound = 'sound/vehicles/weapons/particle_fire_interior.ogg'
	windup_sound = 'sound/vehicles/weapons/particle_charge.ogg'
	windup_delay = 0.6 SECONDS
	hud_state_empty = "battery_empty_flash"
	fire_sound_vary = FALSE

/obj/item/armored_weapon/particle_lance/do_fire(turf/source_turf, ammo_override)
	for(var/mob/living/viewer AS in cheap_get_living_near(source_turf, 9) + current_firer)
		viewer.overlay_fullscreen("particle_flash", /atom/movable/screen/fullscreen/particle_flash, 2)
		viewer.clear_fullscreen("particle_flash")
	return ..()

#define COILGUN_LOW_POWER 1
#define COILGUN_MED_POWER 2
#define COILGUN_HIGH_POWER 3

/obj/item/armored_weapon/coilgun
	name = "battle tank coilgun"
	desc = "The coilgun is considered the standard main weapon for SOM battle tanks. \
	While technologically very different from a traditional cannon, fundamentally both serve the same purpose - to accelerate a large projectile at a high speed towards the enemy."
	icon_state = "coilgun"
	ammo = /obj/item/ammo_magazine/tank/coilgun
	accepted_ammo = list(/obj/item/ammo_magazine/tank/coilgun)
	fire_sound = 'sound/vehicles/weapons/coil_fire.ogg'
	windup_sound = 'sound/vehicles/weapons/coil_charge.ogg'
	interior_fire_sound = 'sound/vehicles/weapons/coilgun_fire_interior.ogg'
	windup_delay = 0.6 SECONDS
	projectile_delay = 3 SECONDS
	maximum_magazines = 3
	rearm_time = 0.5 SECONDS
	///Power setting of the weapon. Effect the projectile fired
	var/power_level = COILGUN_MED_POWER
	///Current ammo override to use based on power level
	var/current_ammo_type = /datum/ammo/rocket/coilgun
	///Power setting toggle action
	var/datum/action/item_action/coilgun_power/power_toggle

/obj/item/armored_weapon/coilgun/Initialize(mapload)
	. = ..()
	power_toggle = new(src)

/obj/item/armored_weapon/coilgun/Destroy()
	QDEL_NULL(power_toggle)
	return ..()

/obj/item/armored_weapon/coilgun/attach(obj/vehicle/sealed/armored/tank, attach_primary)
	. = ..()
	RegisterSignal(tank, COMSIG_VEHICLE_GRANT_CONTROL_FLAG, PROC_REF(give_action))

/obj/item/armored_weapon/coilgun/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_VEHICLE_GRANT_CONTROL_FLAG)
	return ..()

/obj/item/armored_weapon/coilgun/do_fire(turf/source_turf, ammo_override)
	ammo_override = current_ammo_type
	var/x_offset = 0
	var/y_offset = 0
	var/animation_duration = 0.9 SECONDS
	switch(power_level)
		if(COILGUN_MED_POWER)
			switch(chassis.dir)
				if(NORTH)
					y_offset = -15
				if(SOUTH)
					y_offset = 15
				if(EAST)
					x_offset = -15
				if(WEST)
					x_offset = 15
		if(COILGUN_HIGH_POWER)
			animation_duration = 1.2 SECONDS
			switch(chassis.dir)
				if(NORTH)
					y_offset = -25
				if(SOUTH)
					y_offset = 25
				if(EAST)
					x_offset = -25
				if(WEST)
					x_offset = 25
	if(x_offset || y_offset)
		animate(chassis, time = 0.3 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_END_NOW, pixel_x = x_offset, pixel_y = y_offset)
		animate(time = animation_duration -  0.3 SECONDS, easing = SINE_EASING, flags = ANIMATION_RELATIVE, pixel_x = -x_offset, pixel_y = -y_offset)
		if(istype(chassis, /obj/vehicle/sealed/armored/multitile/som_tank)) //byond animations are very smelly, there is no way to have these two anims running together nicely
			addtimer(CALLBACK(chassis, TYPE_PROC_REF(/obj/vehicle/sealed/armored/multitile/som_tank, animate_hover)), animation_duration)
	return ..()

/obj/item/armored_weapon/coilgun/eject_ammo()
	for(var/mob/occupant AS in chassis.occupants)
		occupant.hud_used.update_ammo_hud(src, list(hud_state_empty, hud_state_empty), 0)
	QDEL_NULL(ammo)

/obj/item/armored_weapon/coilgun/ui_action_click(mob/user, datum/action/item_action/action)
	var/datum/action/item_action/coilgun_power/power_action = action
	if(!istype(power_action))
		return ..()
	toggle_power_level(user)
	return TRUE

///Switches between coil power levels
/obj/item/armored_weapon/coilgun/proc/toggle_power_level(mob/user)
	power_level += 1
	if(power_level > COILGUN_HIGH_POWER)
		power_level = COILGUN_LOW_POWER
	switch(power_level)
		if(COILGUN_LOW_POWER)
			current_ammo_type = /datum/ammo/rocket/coilgun/low
			windup_delay = 0
			projectile_delay = 1 SECONDS
		if(COILGUN_MED_POWER)
			current_ammo_type = /datum/ammo/rocket/coilgun
			windup_delay = 0.6 SECONDS
			projectile_delay = 3 SECONDS
		if(COILGUN_HIGH_POWER)
			current_ammo_type = /datum/ammo/rocket/coilgun/high
			windup_delay = 1 SECONDS
			projectile_delay = 4.5 SECONDS
	to_chat(user, "power level set to [power_level]")

///Gives the power setting action to the gunner
/obj/item/armored_weapon/coilgun/proc/give_action(datum/source, mob/living/user, flags)
	if(!(flags & VEHICLE_CONTROL_EQUIPMENT))
		return
	power_toggle.give_action(user)
	RegisterSignal(chassis, COMSIG_VEHICLE_REVOKE_CONTROL_FLAG, PROC_REF(remove_action))

///Removes the power setting action from the gunner
/obj/item/armored_weapon/coilgun/proc/remove_action(datum/source, mob/living/user, flags)
	if(!(flags & VEHICLE_CONTROL_EQUIPMENT))
		return
	power_toggle.remove_action(user)
	UnregisterSignal(chassis, COMSIG_VEHICLE_REVOKE_CONTROL_FLAG)

/obj/item/armored_weapon/secondary_mlrs
	name = "secondary MLRS"
	desc = "A pair of forward facing multiple launch rocket systems with a total of 12 homing rockets. Can unleash its entire payload in rapid succession."
	icon_state = "mlrs"
	fire_sound = 'sound/vehicles/weapons/mlrs_fire.ogg'
	interior_fire_sound = 'sound/vehicles/weapons/mlrs_interior.ogg'
	armored_weapon_flags = MODULE_SECONDARY|MODULE_FIXED_FIRE_ARC
	ammo = /obj/item/ammo_magazine/tank/secondary_mlrs
	accepted_ammo = list(/obj/item/ammo_magazine/tank/secondary_mlrs)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	projectile_delay = 0.2 SECONDS
	variance = 40
	rearm_time = 5 SECONDS
	hud_state_empty = "rocket_empty"

/datum/action/item_action/coilgun_power
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_FIREMODE,
	)
	use_obj_appeareance = FALSE
	///The coilgun associated with this action
	var/obj/item/armored_weapon/coilgun/holder_gun


/datum/action/item_action/coilgun_power/New()
	. = ..()
	holder_gun = holder_item
	update_button_icon()

/datum/action/item_action/coilgun_power/action_activate()
	. = ..()
	if(!.)
		return
	update_button_icon()

/datum/action/item_action/coilgun_power/update_button_icon()
	action_icon_state = "coilgun_[holder_gun.power_level]"
	switch(holder_gun.power_level)
		if(COILGUN_LOW_POWER)
			button.name = "Low power"
		if(COILGUN_MED_POWER)
			button.name = "Standard power"
		if(COILGUN_HIGH_POWER)
			button.name = "High power"
	return ..()

/datum/action/item_action/coilgun_power/handle_button_status_visuals()
	button.color = rgb(255,255,255,255)

#undef COILGUN_LOW_POWER
#undef COILGUN_MED_POWER
#undef COILGUN_HIGH_POWER
#undef CARRONADE_BEAM_TIME

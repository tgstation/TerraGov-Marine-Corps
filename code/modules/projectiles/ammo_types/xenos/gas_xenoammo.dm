/*
//================================================
					Boiler gas, mostly
//================================================
*/

/datum/ammo/xeno/boiler_gas
	name = "glob of neurotoxin"
	icon_state = "boiler_neurotoxin"
	ping = "ping_x"
	///Key used for icon stuff during bombard ammo selection.
	var/icon_key = BOILER_GLOB_NEUROTOXIN
	///This text will show up when a boiler selects this ammo. Span proc should be applied when this var is used.
	var/select_text = "We will now fire neurotoxic gas. This is nonlethal."
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	var/danger_message = span_danger("A glob of acid lands with a splat and explodes into noxious fumes!")
	armor_type = BIO
	accuracy_variation = 10
	max_range = 16
	damage = 50
	damage_type = STAMINA
	damage_falloff = 0
	penetration = 50
	bullet_color = BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR
	reagent_transfer_amount = 30
	///On a direct hit, how long is the target paralyzed?
	var/hit_paralyze_time = 1 SECONDS
	///On a direct hit, how much do the victim's eyes get blurred?
	var/hit_eye_blur = 11
	///On a direct hit, how much drowsyness gets added to the target?
	var/hit_drowsyness = 12
	///Base spread range
	var/fixed_spread_range = 3
	///Which type is the smoke we leave on passed tiles, provided the projectile has AMMO_LEAVE_TURF enabled?
	var/passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	///We're going to reuse one smoke spread system repeatedly to cut down on processing.
	var/datum/effect_system/smoke_spread/xeno/trail_spread_system

/datum/ammo/xeno/boiler_gas/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	if(isxeno(proj.firer))
		var/mob/living/carbon/xenomorph/X = proj.firer
		trail_spread_system.strength = X.xeno_caste.bomb_strength
	trail_spread_system.set_up(0, target_turf)
	trail_spread_system.start()

/**
 * Loads a trap with a gas cloud depending on current glob type
 * Called when something with a boiler glob as current ammo interacts with an empty resin trap.
 * * Args:
 * * trap: The trap being loaded
 * * user_xeno: The xeno interacting with the trap
 * * Returns: TRUE on success, FALSE on failure.
**/
/datum/ammo/xeno/boiler_gas/proc/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 2 SECONDS, NONE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_NEURO)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/neuro/medium
	trap.smoke.set_up(2, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/New()
	. = ..()
	if((ammo_behavior_flags & AMMO_LEAVE_TURF) && passed_turf_smoke_type)
		trail_spread_system = new passed_turf_smoke_type(only_once = FALSE)

/datum/ammo/xeno/boiler_gas/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/boiler_gas/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)

/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj.firer)
	if(target_mob.stat == DEAD || !ishuman(target_mob))
		return
	var/mob/living/carbon/human/human_victim = target_mob

	human_victim.Paralyze(hit_paralyze_time)
	human_victim.blur_eyes(hit_eye_blur)
	human_victim.adjustDrowsyness(hit_drowsyness)

	if(!reagent_transfer_amount)
		return

	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = human_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	human_victim.reagents.add_reagent_list(spit_reagents)

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(ismecha(target_obj))
		proj.damage *= 7 //Globs deal much higher damage to mechs.
	var/turf/target_turf = get_turf(target_obj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_turf, proj.firer)

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj.firer) //we don't want the gas globs to land on dense turfs, they block smoke expansion.

/datum/ammo/xeno/boiler_gas/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj.firer)

/datum/ammo/xeno/boiler_gas/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()

/datum/ammo/xeno/boiler_gas/drop_nade(turf/T, atom/firer, range = 1)
	set_smoke()
	if(isxeno(firer))
		var/mob/living/carbon/xenomorph/X = firer
		smoke_system.strength = X.xeno_caste.bomb_strength
		range = fixed_spread_range
	smoke_system.set_up(range, T)
	smoke_system.start()
	smoke_system = null
	T.visible_message(danger_message)

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_corrosive"
	sound_hit = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	icon_key = BOILER_GLOB_CORROSIVE
	select_text = "We will now fire corrosive acid. This is lethal!"
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	armor_type = ACID
	danger_message = span_danger("A glob of acid lands with a splat and explodes into corrosive bile!")
	damage = 50
	damage_type = BURN
	penetration = 50
	bullet_color = BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR
	hit_paralyze_time = 1 SECONDS
	hit_eye_blur = 1
	hit_drowsyness = 1
	reagent_transfer_amount = 0

/datum/ammo/xeno/boiler_gas/corrosive/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 3 SECONDS, NONE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_ACID)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/acid/opaque
	trap.smoke.set_up(1, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/corrosive/on_shield_block(mob/target_mob, atom/movable/projectile/proj)
	airburst(target_mob, proj)

/datum/ammo/xeno/boiler_gas/corrosive/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/acid/opaque()

/datum/ammo/xeno/boiler_gas/ozelomelyn
	name = "glob of ozelomelyn"
	icon_state = "boiler_ozelomelyn"
	sound_hit = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	icon_key = BOILER_GLOB_OZELOMELYN
	select_text = "We will now fire ozelomelyn gas."
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	danger_message = span_danger("A glob of ozelomelyn lands with a splat and explodes into noxious fumes!")
	damage_type = TOXIC
	bullet_color = BOILER_LUMINOSITY_AMMO_OZELOMELYN_COLOR

/datum/ammo/xeno/boiler_gas/ozelomelyn/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/ozelomelyn()

/datum/ammo/xeno/boiler_gas/hemodile
	name = "glob of hemodile"
	icon_state = "boiler_hemodile"
	sound_hit = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	icon_key = BOILER_GLOB_HEMODILE
	select_text = "We will now fire hemodile gas."
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	danger_message = span_danger("A glob of hemodile lands with a splat and explodes into noxious fumes!")
	damage_type = TOXIC
	bullet_color = BOILER_LUMINOSITY_AMMO_HEMODILE_COLOR

/datum/ammo/xeno/boiler_gas/hemodile/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/hemodile()

/datum/ammo/xeno/boiler_gas/sanguinal
	name = "glob of sanguinal"
	icon_state = "boiler_sanguinal"
	sound_hit = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	icon_key = BOILER_GLOB_SANGUINAL
	select_text = "We will now fire sanguinal gas."
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	danger_message = span_danger("A glob of sanguinal lands with a splat and explodes into noxious fumes!")
	damage_type = TOXIC
	bullet_color = BOILER_LUMINOSITY_AMMO_SANGUINAL_COLOR

/datum/ammo/xeno/boiler_gas/sanguinal/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/sanguinal()

/datum/ammo/xeno/boiler_gas/fast
	name = "fast glob of neurotoxin"
	icon_key = BOILER_GLOB_NEUROTOXIN_FAST
	select_text = "We will now fire fast neurotoxic gas. This is nonlethal."
	fixed_spread_range = 2
	shell_speed = 2

/datum/ammo/xeno/boiler_gas/fast/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro/light/fast()

/datum/ammo/xeno/boiler_gas/corrosive/fast
	name = "fast glob of acid"
	icon_key = BOILER_GLOB_CORROSIVE_FAST
	select_text = "We will now fire fast corrosive acid. This is lethal!"
	fixed_spread_range = 2
	shell_speed = 2

/datum/ammo/xeno/boiler_gas/corrosive/fast/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/acid/fast()

/datum/ammo/xeno/boiler_gas/lance
	name = "pressurized glob of gas"
	icon_key = BOILER_GLOB_NEUROTOXIN_LANCE
	select_text = "We will now fire a pressurized neurotoxic lance. This is barely nonlethal."
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a nasty splat and explodes into noxious fumes!")
	max_range = 16
	damage = 75
	penetration = 70
	reagent_transfer_amount = 55
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	hit_paralyze_time = 2 SECONDS
	hit_eye_blur = 16
	hit_drowsyness = 18
	fixed_spread_range = 2
	accuracy = 100
	accurate_range = 30
	shell_speed = 1.5

/datum/ammo/xeno/boiler_gas/corrosive/lance
	name = "pressurized glob of acid"
	icon_key = BOILER_GLOB_CORROSIVE_LANCE
	select_text = "We will now fire a pressurized corrosive lance. This lethal!"
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a concerning hissing sound and explodes into corrosive bile!")
	max_range = 16
	damage = 75
	penetration = 70
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/acid/light
	hit_paralyze_time = 1.5 SECONDS
	hit_eye_blur = 4
	hit_drowsyness = 2
	fixed_spread_range = 2
	accuracy = 100
	shell_speed = 1.5

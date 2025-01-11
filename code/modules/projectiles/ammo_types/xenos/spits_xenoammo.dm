/*
//================================================
					Xeno Spits
//================================================
*/

/datum/ammo/xeno
	icon_state = "neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	ammo_behavior_flags = AMMO_XENO
	var/added_spit_delay = 0 //used to make cooldown of the different spits vary.
	var/spit_cost = 5
	armor_type = BIO
	shell_speed = 1
	accuracy = 40
	accurate_range = 15
	max_range = 15
	accuracy_var_low = 3
	accuracy_var_high = 3
	bullet_color = COLOR_LIME
	///List of reagents transferred upon spit impact if any
	var/list/datum/reagent/spit_reagents
	///Amount of reagents transferred upon spit impact if any
	var/reagent_transfer_amount
	///Amount of stagger stacks imposed on impact if any
	var/stagger_stacks
	///Amount of slowdown stacks imposed on impact if any
	var/slowdown_stacks
	///These define the reagent transfer strength of the smoke caused by the spit, if any, and its aoe
	var/datum/effect_system/smoke_spread/xeno/smoke_system
	var/smoke_strength
	var/smoke_range
	///The hivenumber of this ammo
	var/hivenumber = XENO_HIVE_NORMAL

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	spit_cost = 55
	added_spit_delay = 0
	damage_type = STAMINA
	accurate_range = 5
	max_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 40
	stagger_stacks = 1.1 SECONDS
	slowdown_stacks = 1.5
	smoke_strength = 0.5
	smoke_range = 0
	reagent_transfer_amount = 4

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/toxin/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)

/datum/ammo/xeno/toxin/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_neuro_smoke(get_turf(target_mob))

	if(isxeno(proj.firer))
		var/mob/living/carbon/xenomorph/xeno = proj.firer
		if(xeno.IsStaggered())
			reagent_transfer_amount *= STAGGER_DAMAGE_MULTIPLIER

	var/mob/living/carbon/carbon_victim = target_mob
	if(!istype(carbon_victim) || carbon_victim.stat == DEAD || carbon_victim.issamexenohive(proj.firer) )
		return

	if(isnestedhost(carbon_victim))
		return

	carbon_victim.adjust_stagger(stagger_stacks)
	carbon_victim.add_slowdown(slowdown_stacks)

	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = carbon_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	carbon_victim.reagents.add_reagent_list(spit_reagents)

	return ..()

/datum/ammo/xeno/toxin/on_hit_obj(obj/target_obj, obj/projectile/proj)
	var/turf/target_turf = get_turf(target_obj)
	drop_neuro_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_neuro_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_neuro_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro/light()

/datum/ammo/xeno/toxin/proc/drop_neuro_smoke(turf/T)
	if(T.density)
		return

	set_smoke()
	smoke_system.strength = smoke_strength
	smoke_system.set_up(smoke_range, T)
	smoke_system.start()
	smoke_system = null

/datum/ammo/xeno/toxin/upgrade1
	smoke_strength = 0.6
	reagent_transfer_amount = 5

/datum/ammo/xeno/toxin/upgrade2
	smoke_strength = 0.7
	reagent_transfer_amount = 6

/datum/ammo/xeno/toxin/upgrade3
	smoke_strength = 0.75
	reagent_transfer_amount = 6.5


/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	added_spit_delay = 0
	spit_cost = 100
	damage = 40
	smoke_strength = 1
	reagent_transfer_amount = 10


/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	icon_state = "sticky"
	ping = null
	ammo_behavior_flags = AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF|AMMO_XENO
	damage_type = STAMINA
	armor_type = BIO
	spit_cost = 50
	sound_hit = "alien_resin_build2"
	sound_bounce = "alien_resin_build3"
	damage = 20 //minor; this is mostly just to provide confirmation of a hit
	max_range = 40
	bullet_color = COLOR_PURPLE
	stagger_stacks = 2
	slowdown_stacks = 3


/datum/ammo/xeno/sticky/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_resin(get_turf(target_mob))
	if(iscarbon(target_mob))
		var/mob/living/carbon/target_carbon = target_mob
		if(target_carbon.issamexenohive(proj.firer))
			return
		target_carbon.adjust_stagger(stagger_stacks) //stagger briefly; useful for support
		target_carbon.add_slowdown(slowdown_stacks) //slow em down


/datum/ammo/xeno/sticky/on_hit_obj(obj/target_obj, obj/projectile/proj)
	if(isarmoredvehicle(target_obj))
		var/obj/vehicle/sealed/armored/tank = target_obj
		COOLDOWN_START(tank, cooldown_vehicle_move, tank.move_delay)
	var/turf/target_turf = get_turf(target_obj)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/proc/drop_resin(turf/T)
	if(T.density || istype(T, /turf/open/space)) // No structures in space
		return

	for(var/obj/O in T.contents)
		if(is_type_in_typecache(O, GLOB.no_sticky_resin))
			return

	new /obj/alien/resin/sticky/thin(T)

/datum/ammo/xeno/sticky/turret
	max_range = 9

/datum/ammo/xeno/sticky/globe
	name = "sticky resin globe"
	icon_state = "sticky_globe"
	damage = 40
	max_range = 7
	spit_cost = 200
	added_spit_delay = 8 SECONDS
	bonus_projectiles_type = /datum/ammo/xeno/sticky/mini
	bonus_projectiles_scatter = 22
	///number of sticky resins made
	var/bonus_projectile_quantity = 16

/datum/ammo/xeno/sticky/mini
	damage = 5
	max_range = 3
	shell_speed = 1

/datum/ammo/xeno/sticky/globe/on_hit_obj(obj/target_obj, obj/projectile/proj)
	var/turf/det_turf = target_obj.allow_pass_flags & PASS_PROJECTILE ? get_step_towards(target_obj, proj) : target_obj.loc
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_obj), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/on_hit_turf(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/on_hit_mob(mob/target_mob, obj/projectile/proj)
	var/turf/det_turf = get_turf(target_mob)
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/do_at_max_range(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	damage_type = BURN
	added_spit_delay = 5
	spit_cost = 50
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF
	armor_type = ACID
	damage = 22
	max_range = 8
	bullet_color = COLOR_PALE_GREEN_GRAY
	///Duration of the acid puddles
	var/puddle_duration = 1 SECONDS //Lasts 1-3 seconds
	///Damage dealt by acid puddles
	var/puddle_acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE

/datum/ammo/xeno/acid/on_shield_block(mob/target_mob, obj/projectile/proj)
	airburst(target_mob, proj)

/datum/ammo/xeno/acid/drop_nade(turf/T) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(T.density)
		return
	new /obj/effect/xenomorph/spray(T, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 35
	ammo_behavior_flags = AMMO_XENO

/datum/ammo/xeno/acid/auto
	name = "light acid spatter"
	damage = 12
	damage_falloff = 0.2
	spit_cost = 20
	added_spit_delay = 0

/datum/ammo/xeno/acid/auto/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_nade(get_turf(target_mob), proj)

/datum/ammo/xeno/acid/auto/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : get_turf(target_obj))

/datum/ammo/xeno/acid/auto/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/auto/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/passthrough
	name = "acid spittle"
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 2
	spit_cost = 70
	damage = 40

/datum/ammo/xeno/acid/heavy/turret
	damage = 20
	name = "acid turret splash"
	shell_speed = 2
	max_range = 9

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/target_mob, obj/projectile/proj)
	var/turf/target_turf = get_turf(target_mob)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : get_turf(target_obj))

/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/heavy/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)


///For the Spitter's Scatterspit ability
/datum/ammo/xeno/acid/heavy/scatter
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	bonus_projectiles_type = /datum/ammo/xeno/acid/heavy/scatter
	bonus_projectiles_amount = 6
	bonus_projectiles_scatter = 2
	max_range = 8
	puddle_duration = 1 SECONDS //Lasts 2-4 seconds

///For the Sizzler Boiler's Spit
/datum/ammo/xeno/acid/airburst
	name = "acid steam spittle"
	spit_cost = 50
	damage = 15
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF
	bonus_projectiles_type = /datum/ammo/xeno/acid/airburst_bomblet
	bonus_projectiles_scatter = 10
	///How many projectiles we split into
	var/bonus_projectile_quantity = 3

/datum/ammo/xeno/acid/airburst/on_hit_mob(mob/target_mob, obj/projectile/proj)
	var/turf/det_turf = get_step_towards(target_mob, proj)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/xeno/acid/airburst/on_hit_obj(obj/target_obj, obj/projectile/proj)
	var/turf/det_turf = get_step_towards(target_obj, proj)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_obj), loc_override = det_turf)

/datum/ammo/xeno/acid/airburst/on_hit_turf(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/acid/airburst/do_at_max_range(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/acid/airburst_bomblet
	name = "acid steam spatter"
	icon_state = "neurotoxin"
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 3
	shell_speed = 1
	damage = 10
	penetration = 0
	/// smoke type created when the projectile detonates
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/xeno/acid
	///radius this smoke will encompass
	var/smoke_radius = 0
	///duration the smoke will last
	var/smoke_duration = 2

/datum/ammo/xeno/acid/airburst_bomblet/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(smoke_radius, T, smoke_duration)
	smoke.start()

/datum/ammo/xeno/acid/airburst_bomblet/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.allow_pass_flags & PASS_PROJECTILE ? get_step_towards(target_obj, proj) : get_turf(target_obj))

/datum/ammo/xeno/acid/airburst_bomblet/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/airburst_bomblet/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/airburst/heavy
	name = "acid steam glob"
	icon_state = "neurotoxin"
	added_spit_delay = 1 SECONDS
	spit_cost = 50
	damage = 35
	stagger_stacks = 2 SECONDS
	slowdown_stacks = 3
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF
	bonus_projectiles_type = /datum/ammo/xeno/acid/airburst_bomblet/smokescreen
	bonus_projectiles_scatter = 30
	bonus_projectile_quantity = 5

/datum/ammo/xeno/acid/airburst/heavy/on_hit_mob(mob/target_mob, obj/projectile/proj)
	. = ..()
	if(iscarbon(target_mob))
		var/mob/living/carbon/target_carbon = target_mob
		if(target_carbon.issamexenohive(proj.firer))
			return
		target_carbon.adjust_stagger(stagger_stacks)
		target_carbon.add_slowdown(slowdown_stacks)

/datum/ammo/xeno/acid/airburst_bomblet/smokescreen
	max_range = 5
	damage = 0
	smoketype = /datum/effect_system/smoke_spread/xeno/acid/opaque
	smoke_radius = 1
	smoke_duration = 4

///For the Sizzler Boiler's primo
/datum/ammo/xeno/acid/heavy/high_pressure_spit
	name = "pressurized steam glob"
	icon_state = "boiler_gas"
	damage = 50
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS
	max_range = 16
	shell_speed = 1.5
	stagger_stacks = 2 SECONDS
	slowdown_stacks = 3
	///How long it knocks down the target
	var/knockdown_duration = 2 SECONDS
	///Knockback dealt on hit
	var/knockback = 7
	///shatter effection duration when hitting mobs
	var/shatter_duration = 10 SECONDS

/datum/ammo/xeno/acid/heavy/high_pressure_spit/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(!iscarbon(target_mob))
		return
	var/mob/living/carbon/target_carbon = target_mob
	if(target_carbon.issamexenohive(proj.firer))
		return
	staggerstun(target_mob, proj, max_range, 0, knockdown_duration, stagger_stacks, slowdown_stacks, knockback)
	target_carbon.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

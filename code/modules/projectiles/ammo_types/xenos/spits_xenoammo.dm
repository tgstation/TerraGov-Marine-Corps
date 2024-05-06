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

/datum/ammo/xeno/toxin/on_hit_mob(mob/living/carbon/carbon_victim, obj/projectile/proj)
	drop_neuro_smoke(get_turf(carbon_victim))

	if(isxeno(proj.firer))
		var/mob/living/carbon/xenomorph/xeno = proj.firer
		if(xeno.IsStaggered())
			reagent_transfer_amount *= STAGGER_DAMAGE_MULTIPLIER

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

/datum/ammo/xeno/toxin/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_neuro_smoke(T.density ? P.loc : T)

/datum/ammo/xeno/toxin/on_hit_turf(turf/T, obj/projectile/P)
	drop_neuro_smoke(T.density ? P.loc : T)

/datum/ammo/xeno/toxin/do_at_max_range(turf/T, obj/projectile/P)
	drop_neuro_smoke(T.density ? P.loc : T)

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


/datum/ammo/xeno/sticky/on_hit_mob(mob/M, obj/projectile/P)
	drop_resin(get_turf(M))
	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.issamexenohive(P.firer))
			return
		C.adjust_stagger(stagger_stacks) //stagger briefly; useful for support
		C.add_slowdown(slowdown_stacks) //slow em down


/datum/ammo/xeno/sticky/on_hit_obj(obj/O, obj/projectile/P)
	if(isarmoredvehicle(O))
		var/obj/vehicle/sealed/armored/tank = O
		COOLDOWN_START(tank, cooldown_vehicle_move, tank.move_delay)
	var/turf/T = get_turf(O)
	drop_resin(T.density ? P.loc : T)

/datum/ammo/xeno/sticky/on_hit_turf(turf/T, obj/projectile/P)
	drop_resin(T.density ? P.loc : T)

/datum/ammo/xeno/sticky/do_at_max_range(turf/T, obj/projectile/P)
	drop_resin(T.density ? P.loc : T)

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
	var/bonus_projectile_quantity = 16
	var/bonus_projectile_range = 3
	var/bonus_projectile_speed = 1

/datum/ammo/xeno/sticky/mini
	damage = 5
	max_range = 3

/datum/ammo/xeno/sticky/globe/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/initial_turf = O.density ? P.loc : get_turf(O)
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/on_hit_turf(turf/T, obj/projectile/P)
	var/turf/initial_turf = T.density ? P.loc : T
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/initial_turf = get_turf(M)
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/do_at_max_range(turf/T, obj/projectile/P)
	var/turf/initial_turf = T.density ? P.loc : T
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce = "acid_bounce"
	damage_type = BURN
	added_spit_delay = 5
	spit_cost = 50
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF
	armor_type = ACID
	damage = 18
	max_range = 8
	bullet_color = COLOR_PALE_GREEN_GRAY
	///Duration of the acid puddles
	var/puddle_duration = 1 SECONDS //Lasts 1-3 seconds
	///Damage dealt by acid puddles
	var/puddle_acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE

/datum/ammo/xeno/acid/on_shield_block(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/acid/drop_nade(turf/T) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(T.density)
		return
	new /obj/effect/xenomorph/spray(T, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30
	ammo_behavior_flags = AMMO_XENO

/datum/ammo/xeno/acid/auto
	name = "light acid spatter"
	damage = 10
	damage_falloff = 0.3
	spit_cost = 25
	added_spit_delay = 0

/datum/ammo/xeno/acid/auto/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/T = get_turf(M)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/auto/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : get_turf(O))

/datum/ammo/xeno/acid/auto/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/auto/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/passthrough
	name = "acid spittle"
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 2
	spit_cost = 70
	damage = 30

/datum/ammo/xeno/acid/heavy/turret
	damage = 20
	name = "acid turret splash"
	shell_speed = 2
	max_range = 9

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/T = get_turf(M)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : get_turf(O))

/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

///For the Spitter's Scatterspit ability
/datum/ammo/xeno/acid/heavy/scatter
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	bonus_projectiles_type = /datum/ammo/xeno/acid/heavy/scatter
	bonus_projectiles_amount = 6
	bonus_projectiles_scatter = 2
	max_range = 8
	puddle_duration = 1 SECONDS //Lasts 2-4 seconds

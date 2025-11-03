/*
//================================================
					TX54 Ammo
//================================================
*/

/datum/ammo/tx54
	name = "20mm airburst grenade"
	icon_state = "20mm_flight"
	hud_state = "grenade_airburst"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "20mm_airburst"
	handful_amount = 3
	ping = null //no bounce off.
	sound_bounce = SFX_ROCKET_BOUNCE
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	armor_type = BOMB
	damage_falloff = 0.5
	shell_speed = 2
	accurate_range = 12
	max_range = 15
	damage = 12			//impact damage from a grenade to the dome
	penetration = 0
	sundering = 0
	shrapnel_chance = 0
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread
	bonus_projectiles_scatter = 10
	///How many
	var/bonus_projectile_quantity = 7

	handful_greyscale_config = /datum/greyscale_config/ammo
	handful_greyscale_colors = COLOR_AMMO_AIRBURST

	projectile_greyscale_config = /datum/greyscale_config/projectile
	projectile_greyscale_colors = COLOR_AMMO_AIRBURST

/datum/ammo/tx54/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_mob, proj)
	staggerstun(target_mob, proj, max_range, slowdown = 0.5, knockback = 1)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/tx54/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_obj, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_obj), loc_override = det_turf)

/datum/ammo/tx54/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/tx54/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/tx54/incendiary
	name = "20mm incendiary grenade"
	hud_state = "grenade_fire"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/incendiary
	bullet_color = LIGHT_COLOR_FIRE
	handful_greyscale_colors = COLOR_AMMO_INCENDIARY
	projectile_greyscale_colors = COLOR_AMMO_INCENDIARY

/datum/ammo/tx54/smoke
	name = "20mm tactical smoke grenade"
	hud_state = "grenade_hide"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke
	bonus_projectiles_scatter = 24
	bonus_projectile_quantity = 5
	handful_greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE
	projectile_greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE

/datum/ammo/tx54/smoke/dense
	name = "20mm smoke grenade"
	hud_state = "grenade_smoke"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke/dense
	handful_greyscale_colors = COLOR_AMMO_SMOKE
	projectile_greyscale_colors = COLOR_AMMO_SMOKE

/datum/ammo/tx54/smoke/tangle
	name = "20mm tanglefoot grenade"
	hud_state = "grenade_drain"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke/tangle
	handful_greyscale_colors = COLOR_AMMO_TANGLEFOOT
	projectile_greyscale_colors = COLOR_AMMO_TANGLEFOOT

/datum/ammo/tx54/smoke/acid
	name = "20mm acid grenade"
	hud_state = "grenade_acid"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke/acid
	handful_greyscale_colors = COLOR_AMMO_ACID
	projectile_greyscale_colors = COLOR_AMMO_ACID

/datum/ammo/tx54/razor
	name = "20mm razorburn grenade"
	hud_state = "grenade_razor"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/razor
	bonus_projectiles_scatter = 50
	bonus_projectile_quantity = 3
	handful_greyscale_colors = COLOR_AMMO_RAZORBURN
	projectile_greyscale_colors = COLOR_AMMO_RAZORBURN

/datum/ammo/tx54/he
	name = "20mm HE grenade"
	hud_state = "grenade_he"
	bonus_projectiles_type = null
	max_range = 12
	handful_greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE
	projectile_greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE

/datum/ammo/tx54/he/drop_nade(turf/T)
	explosion(T, 0, 0, 1, 3, 1, explosion_cause=src)

/datum/ammo/tx54/he/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/tx54/he/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(get_turf(target_obj))

/datum/ammo/tx54/he/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/tx54/he/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

//The secondary projectiles
/datum/ammo/bullet/tx54_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_variation = 5
	max_range = 4
	shell_speed = 3
	damage = 20
	penetration = 20
	sundering = 1.5
	damage_falloff = 0

/datum/ammo/bullet/tx54_spread/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 3, stagger = 0.6 SECONDS, slowdown = 0.3)

/datum/ammo/bullet/tx54_spread/incendiary
	name = "incendiary flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/tx54_spread/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/tx54_spread/incendiary/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(target_turf)

/datum/ammo/bullet/tx54_spread/smoke
	name = "chemical bomblet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 3
	damage = 5
	penetration = 0
	sundering = 0
	shrapnel_chance = 0
	///The smoke type loaded in this ammo
	var/datum/effect_system/smoke_spread/trail_spread_system = /datum/effect_system/smoke_spread/tactical

/datum/ammo/bullet/tx54_spread/smoke/New()
	. = ..()

	trail_spread_system = new trail_spread_system(only_once = FALSE)

/datum/ammo/bullet/tx54_spread/smoke/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

/datum/ammo/bullet/tx54_spread/smoke/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/smoke/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	trail_spread_system.set_up(0, target_turf)
	trail_spread_system.start()

/datum/ammo/bullet/tx54_spread/smoke/dense
	trail_spread_system = /datum/effect_system/smoke_spread/bad

/datum/ammo/bullet/tx54_spread/smoke/tangle
	trail_spread_system = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/bullet/tx54_spread/smoke/acid
	trail_spread_system = /datum/effect_system/smoke_spread/xeno/acid

/datum/ammo/bullet/tx54_spread/razor
	name = "chemical bomblet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 4
	damage = 5
	penetration = 0
	sundering = 0
	///The foam type loaded in this ammo
	var/datum/effect_system/foam_spread/chemical_payload
	///The reagent content of the projectile
	var/datum/reagents/reagent_list

/datum/ammo/bullet/tx54_spread/razor/New()
	. = ..()

	chemical_payload = new
	reagent_list = new
	reagent_list.add_reagent(/datum/reagent/foaming_agent = 1)
	reagent_list.add_reagent(/datum/reagent/toxin/nanites = 7)

/datum/ammo/bullet/tx54_spread/razor/Destroy()
	if(chemical_payload)
		QDEL_NULL(chemical_payload)
	return ..()

/datum/ammo/bullet/tx54_spread/razor/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/razor/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	chemical_payload.set_up(0, target_turf, reagent_list, RAZOR_FOAM)
	chemical_payload.start()


/datum/ammo/tx54/tank_canister
	name = "canister"
	icon_state = "canister_shot"
	damage = 30
	penetration = 0
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	damage_falloff = 0.5
	max_range = 3
	projectile_greyscale_colors = "#4f0303"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/tank_canister/ricochet/one
	bonus_projectiles_scatter = 4
	bonus_projectile_quantity = 12

/datum/ammo/bullet/tx54_spread/tank_canister
	name = "canister shot"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	max_range = 12
	damage = 30
	penetration = 15
	sundering = 2
	damage_falloff = 1
	shrapnel_chance = 15

/datum/ammo/bullet/tx54_spread/tank_canister/ricochet
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/tank_canister
	bonus_projectiles_scatter = 0
	damage = 35

/datum/ammo/bullet/tx54_spread/tank_canister/ricochet/one
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/tank_canister/ricochet
	damage = 40

/datum/ammo/bullet/tx54_spread/tank_canister/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 4, stagger = 2 SECONDS, slowdown = 0.2)

/datum/ammo/bullet/tx54_spread/tank_canister/ricochet/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	reflect(target_turf, proj, 5)

/datum/ammo/tx54/tank_canister/incendiary
	name = "incendiary canister"
	icon_state = "canister_shot"
	hud_state = "grenade_fire"
	projectile_greyscale_colors = "#5f2702"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/tank_canister/incendiary
	bonus_projectiles_scatter = 4
	bonus_projectile_quantity = 12

/datum/ammo/bullet/tx54_spread/tank_canister/incendiary
	name = "incendiary canister shot"
	ammo_behavior_flags = parent_type::ammo_behavior_flags|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	bullet_color = COLOR_LIGHT_ORANGE
	damage = 25

/datum/ammo/bullet/tx54_spread/tank_canister/incendiary/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	if(prob(35))
		drop_flame(target_turf)

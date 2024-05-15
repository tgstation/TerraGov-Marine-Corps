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
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER
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

/datum/ammo/tx54/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, slowdown = 0.5, knockback = 1)
	playsound(proj, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, M) )

/datum/ammo/tx54/on_hit_obj(obj/O, obj/projectile/proj)
	playsound(proj, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, O) )

/datum/ammo/tx54/on_hit_turf(turf/T, obj/projectile/proj)
	playsound(proj, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, T) )

/datum/ammo/tx54/do_at_max_range(turf/T, obj/projectile/proj)
	playsound(proj, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, get_turf(proj)) )

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
	explosion(T, 0, 0, 1, 3, 1)

/datum/ammo/tx54/he/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/tx54/he/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))

/datum/ammo/tx54/he/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/tx54/he/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

//The secondary projectiles
/datum/ammo/bullet/tx54_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 5
	accuracy_var_high = 5
	max_range = 4
	damage = 20
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/tx54_spread/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 3, stagger = 0.6 SECONDS, slowdown = 0.3)

/datum/ammo/bullet/tx54_spread/incendiary
	name = "incendiary flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/tx54_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/tx54_spread/incendiary/on_leave_turf(turf/T, obj/projectile/proj)
	drop_flame(T)

/datum/ammo/bullet/tx54_spread/smoke
	name = "chemical bomblet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 3
	damage = 5
	penetration = 0
	sundering = 0
	///The smoke type loaded in this ammo
	var/datum/effect_system/smoke_spread/trail_spread_system = /datum/effect_system/smoke_spread/tactical

/datum/ammo/bullet/tx54_spread/smoke/New()
	. = ..()

	trail_spread_system = new trail_spread_system(only_once = FALSE)

/datum/ammo/bullet/tx54_spread/smoke/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

/datum/ammo/bullet/tx54_spread/smoke/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/smoke/on_leave_turf(turf/T, obj/projectile/proj)
	trail_spread_system.set_up(0, T)
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

/datum/ammo/bullet/tx54_spread/razor/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/razor/on_leave_turf(turf/T, obj/projectile/proj)
	chemical_payload.set_up(0, T, reagent_list, RAZOR_FOAM)
	chemical_payload.start()

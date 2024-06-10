/*
//================================================
					Warlock Ammo
//================================================
*/

/datum/ammo/energy/xeno
	barricade_clear_distance = 0
	///Plasma cost to fire this projectile
	var/ability_cost
	///Particle type used when this ammo is used
	var/particles/channel_particle
	///The colour the xeno glows when using this ammo type
	var/glow_color

/datum/ammo/energy/xeno/psy_blast
	name = "psychic blast"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_ENERGY|AMMO_HITSCAN|AMMO_SKIPS_ALIENS
	damage = 35
	penetration = 10
	sundering = 1
	max_range = 7
	accurate_range = 7
	hitscan_effect_icon = "beam_cult"
	icon_state = "psy_blast"
	ability_cost = 230
	channel_particle = /particles/warlock_charge/psy_blast
	glow_color = "#9e1f1f"
	///The AOE for drop_nade
	var/aoe_range = 2
	///AOE damage amount
	var/aoe_damage = 45

/datum/ammo/energy/xeno/psy_blast/drop_nade(turf/T, obj/projectile/P)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/effects/EMPulse.ogg', 50)
	var/list/turf/target_turfs = generate_true_cone(T, aoe_range, -1, 359, 0, air_pass = TRUE)
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/target AS in target_turf)
			if(isliving(target))
				var/mob/living/living_victim = target
				if(living_victim.stat == DEAD)
					continue
				if(!isxeno(living_victim))
					living_victim.apply_damage(aoe_damage, BURN, null, ENERGY, FALSE, FALSE, TRUE, penetration)
					staggerstun(living_victim, P, 10, slowdown = 1)
			else if(isobj(target))
				var/obj/obj_victim = target
				var/dam_mult = 1
				if(!(obj_victim.resistance_flags & XENO_DAMAGEABLE))
					continue
				if(isbarricade(target))
					continue
				if(isarmoredvehicle(target))
					dam_mult -= 0.5
				obj_victim.take_damage(aoe_damage * dam_mult, BURN, ENERGY, TRUE, armour_penetration = penetration)
			if(target.anchored)
				continue

	new /obj/effect/temp_visual/shockwave(T, aoe_range + 2)

/datum/ammo/energy/xeno/psy_blast/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_nade(get_turf(target_mob), proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj, proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj)

/datum/ammo/energy/xeno/psy_blast/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj)

/datum/ammo/energy/xeno/psy_blast/psy_lance
	name = "psychic lance"
	ammo_behavior_flags = AMMO_XENO|AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE
	damage = 60
	penetration = 50
	accuracy = 100
	sundering = 5
	max_range = 12
	hitscan_effect_icon = "beam_hcult"
	icon_state = "psy_lance"
	ability_cost = 300
	channel_particle = /particles/warlock_charge/psy_blast/psy_lance
	glow_color = "#CB0166"

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_obj(obj/target_obj, obj/projectile/proj)
	if(isvehicle(target_obj))
		var/obj/vehicle/veh_victim = target_obj
		veh_victim.take_damage(200, BURN, ENERGY, TRUE, armour_penetration = penetration)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(isxeno(target_mob))
		return
	staggerstun(target_mob, proj, 9, stagger = 1 SECONDS, slowdown = 2, knockback = 1)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_turf(turf/target_turf, obj/projectile/proj)
	return

/datum/ammo/energy/xeno/psy_blast/psy_lance/do_at_max_range(turf/target_turf, obj/projectile/proj)
	return

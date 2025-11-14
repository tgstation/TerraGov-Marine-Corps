/*
//================================================
					Warlock Ammo
//================================================
*/

/datum/ammo/energy/xeno
	barricade_clear_distance = 1
	///Plasma cost to fire this projectile
	var/ability_cost
	///Particle type used when this ammo is used
	var/particles/channel_particle
	///The colour the xeno glows when using this ammo type
	var/glow_color

/datum/ammo/energy/xeno/psy_blast
	name = "psychic blast"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG|AMMO_ENERGY|AMMO_HITSCAN|AMMO_SKIPS_ALIENS
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

/datum/ammo/energy/xeno/psy_blast/drop_nade(turf/T, atom/movable/projectile/proj)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/effects/EMPulse.ogg', 50)
	var/list/turf/target_turfs = generate_cone(T, aoe_range, -1, 359, 0, pass_flags_checked = PASS_AIR)
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/target AS in target_turf)
			if(isliving(target))
				var/mob/living/living_victim = target
				if(living_victim.stat == DEAD)
					continue
				if(!isxeno(living_victim))
					living_victim.apply_damage(aoe_damage, BURN, null, ENERGY, FALSE, FALSE, TRUE, penetration, attacker = proj.firer)
					staggerstun(living_victim, proj, 10, slowdown = 1)
					living_victim.do_jitter_animation(500)
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

/datum/ammo/energy/xeno/psy_blast/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj, proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj)

/datum/ammo/energy/xeno/psy_blast/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
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

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(isvehicle(target_obj))
		var/obj/vehicle/veh_victim = target_obj
		var/veh_damage = 200
		if(isgreyscalemecha(veh_victim))
			veh_damage = 25
		veh_victim.take_damage(veh_damage, BURN, ENERGY, TRUE, armour_penetration = penetration)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(isxeno(target_mob))
		return
	staggerstun(target_mob, proj, 9, stagger = 1 SECONDS, slowdown = 2, knockback = 1)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	return

/datum/ammo/energy/xeno/psy_blast/psy_lance/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	return

/datum/ammo/energy/xeno/psy_blast/psy_drain
	name = "psychic drain"
	damage = 24.5 // 35 * 0.7 = 24.5
	damage_type = STAMINA
	aoe_range = 1
	aoe_damage = 31.5 // 45 * 0.7 = 31.5

/datum/ammo/energy/xeno/psy_blast/psy_drain/drop_nade(turf/T, atom/movable/projectile/proj)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/effects/portal_opening.ogg', 50)
	var/list/turf/target_turfs = generate_cone(T, aoe_range, -1, 359, 0, pass_flags_checked = PASS_AIR)
	for(var/turf/target_turf AS in target_turfs)
		for(var/mob/living/carbon/human/affected_human in target_turf)
			if(affected_human.stat == DEAD)
				continue
			affected_human.apply_damage(aoe_damage, STAMINA, null, ENERGY, FALSE, FALSE, TRUE, penetration, attacker = proj.firer)
			staggerstun(affected_human, proj, 10, slowdown = 1)
			affected_human.do_jitter_animation(500)
			if(target_turf != T)
				step_away(affected_human, T, 1)
	new /obj/effect/temp_visual/shockwave(T, aoe_range + 2)

/datum/ammo/energy/xeno/psy_blast/psy_drain/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj)
	if(ishuman(target_mob))
		var/mob/living/carbon/human/living_human = target_mob
		living_human.Knockdown(0.3 SECONDS)

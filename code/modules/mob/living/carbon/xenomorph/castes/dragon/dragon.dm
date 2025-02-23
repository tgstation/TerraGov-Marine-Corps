/mob/living/carbon/xenomorph/dragon
	caste_base_type = /datum/xeno_caste/dragon
	name = "Dragon"
	desc = "A massive, ancient beast with scales that shimmer like polished armor. The fiercest and most formidable creature."
	icon = 'icons/Xeno/castes/dragon.dmi'
	icon_state = "Dragon Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	health = 850
	maxHealth = 850
	plasma_stored = 0
	pixel_x = -48
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	initial_language_holder = /datum/language_holder/xeno/dragon
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)
	// If they should be prevented from using the special state icon.
	var/no_special_state = FALSE

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/handle_special_state()
	if(no_special_state || !(status_flags & INCORPOREAL))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DRAGON_CHANGE_FORM))
		return FALSE
	icon_state = "dragon_marker"
	return TRUE

/// If they have plasma, reduces their damage accordingly. Ratio is 4 plasma per 1 damage.
/mob/living/carbon/xenomorph/dragon/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if((status_flags & GODMODE) || damage <= 0)
		return FALSE
	if(damagetype != BRUTE && damagetype != BURN)
		return FALSE
	if(stat != DEAD && plasma_stored)
		var/damage_reduction = min(damage / 2, plasma_stored / 4)
		use_plasma(ROUND_UP(damage_reduction * 4))
		damage -= damage_reduction
	return ..()

/// If they are incorporeal, lets them move anywhere as long it is not a bad place.
/mob/living/carbon/xenomorph/dragon/Move(atom/newloc, direction, glide_size_override)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DRAGON_CHANGE_FORM))
		return FALSE
	if(!(status_flags & INCORPOREAL))
		return ..()
	if(isclosedturf(newloc) && !istype(newloc, /turf/closed/wall/resin))
		return FALSE
	for(var/atom/atom_on_turf AS in newloc.contents)
		if(!atom_on_turf.CanPass(src, newloc))
			if((atom_on_turf.resistance_flags & RESIST_ALL)) // Like hull windows.
				return FALSE
			if(istype(atom_on_turf, /obj/machinery/door/poddoor/timed_late))
				return FALSE
	abstract_move(newloc)

/// Begins changing forms from flight to ground and vice versa.
/mob/living/carbon/xenomorph/dragon/change_form()
	if(!(status_flags & INCORPOREAL))
		TIMER_COOLDOWN_START(src, COOLDOWN_DRAGON_CHANGE_FORM, 0.5 SECONDS)
		animate(src, pixel_x = -48, pixel_y = 500, time = 0.5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(finish_flying)), 0.5 SECONDS)
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_DRAGON_CHANGE_FORM, 3 SECONDS)
	animate(src, pixel_x = generator("num", -100, 100, NORMAL_RAND), pixel_y = 500, time = 0)
	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/list/turf/affected_turfs = RANGE_TURFS(2, loc)
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)
	addtimer(CALLBACK(src, PROC_REF(handle_dropping_animations)), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_dropping), telegraphed_atoms), 3.0 SECONDS)

/// Ends the animation and sets up the rest of the flying stuff.
/mob/living/carbon/xenomorph/dragon/proc/finish_flying()
	TIMER_COOLDOWN_END(src, COOLDOWN_DRAGON_CHANGE_FORM) // Special state won't think it is ready otherwise.
	animate(src, pixel_x = 0, pixel_y = 0, time = 0)
	status_flags = GODMODE|INCORPOREAL
	resistance_flags = RESIST_ALL|BANISH_IMMUNE
	pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	density = FALSE
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	update_icons(TRUE)
	update_action_buttons()

// Start the animation of descending and revert our sprite back to normal.
/mob/living/carbon/xenomorph/dragon/proc/handle_dropping_animations(list/obj/effect/xeno/dragon_warning/telegraphed_atoms)
	no_special_state = TRUE
	update_icons(TRUE)
	animate(src, pixel_x = -48, pixel_y = 0, time = 0.5 SECONDS)

// Removes telegraphing, does various landing effects, and reverts any changes caused by flying.
/mob/living/carbon/xenomorph/dragon/proc/finish_dropping(list/obj/effect/xeno/dragon_warning/telegraphed_atoms)
	no_special_state = FALSE
	QDEL_LIST(telegraphed_atoms)
	var/list/turf/affected_turfs = RANGE_TURFS(2, loc)
	var/damage = 100 * xeno_melee_damage_modifier
	var/list/obj/vehicle/vehicles_already_affected_so_far = list() // To stop hitting something the same multitile vehicle twice.
	for(var/turf/affected_tile AS in affected_turfs)
		affected_tile.Shake(duration = 0.2 SECONDS)
		for(var/atom/affected_atom AS in affected_tile)
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(affected_atom in vehicles_already_affected_so_far)
				continue
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				animate(affected_living, pixel_z = affected_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, affected_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(affected_living, pixel_z = affected_living.pixel_z - 8, layer = affected_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				affected_living.animation_spin(0.5 SECONDS, 1, affected_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				var/datum/component/jump/living_jump_component = affected_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(affected_living, JUMP_COMPONENT_COOLDOWN, 0.25 SECONDS)
				continue
			if(!isobj(affected_atom))
				continue
			var/obj/affected_obj = affected_atom
			if(ishitbox(affected_obj))
				var/obj/hitbox/vehicle_hitbox = affected_obj
				if(vehicle_hitbox.root in vehicles_already_affected_so_far)
					continue
				handle_vehicle_effects(vehicle_hitbox.root, damage / 3)
				vehicles_already_affected_so_far += vehicle_hitbox.root
				continue
			if(!isvehicle(affected_obj))
				affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = src)
				continue
			if(ismecha(affected_obj))
				handle_vehicle_effects(affected_obj, damage * 3, 50)
			else if(isarmoredvehicle(affected_obj))
				handle_vehicle_effects(affected_obj, damage / 3)
			else
				handle_vehicle_effects(affected_obj, damage * 3)
			vehicles_already_affected_so_far += affected_obj
	playsound(loc, 'sound/effects/alien/behemoth/seismic_fracture_explosion.ogg', 50, 1)

	status_flags = initial(status_flags)
	resistance_flags = initial(resistance_flags)
	pass_flags = initial(pass_flags)
	density = TRUE
	REMOVE_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	update_icons(TRUE)
	update_action_buttons()
	var/datum/action/ability/activable/xeno/fly/fly_ability = actions_by_path[/datum/action/ability/activable/xeno/fly]
	fly_ability?.succeed_activate()
	fly_ability?.add_cooldown()

/// Stuns the vehicle's occupants and does damage to the vehicle itself.
/mob/living/carbon/xenomorph/dragon/proc/handle_vehicle_effects(obj/vehicle/vehicle, damage, ap)
	for(var/mob/living/living_occupant in vehicle.occupants)
		living_occupant.apply_effect(3 SECONDS, EFFECT_PARALYZE)
	vehicle.take_damage(damage, BRUTE, MELEE, armour_penetration = ap, blame_mob = src)

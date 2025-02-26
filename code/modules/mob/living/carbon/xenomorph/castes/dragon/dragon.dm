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
	gib_chance = 0
	// If they are currently doing landing animations and thus should display their regular sprite.
	var/doing_landing_animations = FALSE

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/handle_special_state()
	if(doing_landing_animations || !(status_flags & INCORPOREAL))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DRAGON_CHANGE_FORM))
		return FALSE
	icon_state = "dragon_marker"
	return TRUE

/// If they have plasma, reduces their damage accordingly by up to 50%. Ratio is 4 plasma per 1 damage.
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
		if(atom_on_turf.CanPass(src, newloc))
			continue
		if((atom_on_turf.resistance_flags & RESIST_ALL)) // This prevents them from going off into space during hijack.
			return FALSE
		if(istype(atom_on_turf, /obj/machinery/door/poddoor/timed_late)) /// This prevents them from entering the LZ early.
			return FALSE
	abstract_move(newloc)

/// Begins changing forms from flight to ground and vice versa.
/mob/living/carbon/xenomorph/dragon/change_form()
	if(!(status_flags & INCORPOREAL))
		start_flight()
		return
	start_landing()

/// Begins the process of flying.
/mob/living/carbon/xenomorph/dragon/proc/start_flight()
	TIMER_COOLDOWN_START(src, COOLDOWN_DRAGON_CHANGE_FORM, 0.5 SECONDS)
	new /obj/effect/temp_visual/dragon/fly(loc)
	animate(src, pixel_x = initial(pixel_x), pixel_y = 500, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finalize_flight)), 0.5 SECONDS)

/// Finalizes the process of flying by granting various flags and so on.
/mob/living/carbon/xenomorph/dragon/proc/finalize_flight()
	TIMER_COOLDOWN_END(src, COOLDOWN_DRAGON_CHANGE_FORM) // NOTE: Cooldown needs to end for special state to work as wanted.
	animate(src, pixel_x = 0, pixel_y = 0, time = 0)
	status_flags = GODMODE|INCORPOREAL
	resistance_flags = RESIST_ALL|BANISH_IMMUNE
	pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	density = FALSE
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	update_icons(TRUE)
	update_action_buttons()

/// Begins the process of landing.
/mob/living/carbon/xenomorph/dragon/proc/start_landing()
	TIMER_COOLDOWN_START(src, COOLDOWN_DRAGON_CHANGE_FORM, 3 SECONDS)
	animate(src, pixel_x = initial(pixel_x), pixel_y = 500, time = 0)
	var/list/turf/future_impacted_turfs = filled_turfs(src, 2, "square", FALSE, pass_flags_checked = PASS_AIR)
	telegraph_these_turfs(future_impacted_turfs)
	addtimer(CALLBACK(src, PROC_REF(continue_landing), future_impacted_turfs), 2.5 SECONDS)

/// Continues the process of landing (mainly because of animations).
/mob/living/carbon/xenomorph/dragon/proc/continue_landing(list/turf/impacted_turfs)
	doing_landing_animations = TRUE
	animate(src, pixel_x = initial(pixel_x), pixel_y = 0, time = 0.5 SECONDS)
	update_icons(TRUE)
	addtimer(CALLBACK(src, PROC_REF(perform_landing_effects), impacted_turfs), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finalize_landing)), 0.5 SECONDS)

/// Finalizes the process of landing by reversing the effects from flying.
/mob/living/carbon/xenomorph/dragon/proc/finalize_landing()
	doing_landing_animations = FALSE
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

// Performs various landing effects.
/mob/living/carbon/xenomorph/dragon/proc/perform_landing_effects(list/turf/impacted_turfs)
	new /obj/effect/temp_visual/dragon/land(loc)
	var/damage = 100 * xeno_melee_damage_modifier
	var/list/obj/vehicle/already_stunned_vehicles = list() // This prevents hitting the main body of a vehicle twice.
	for(var/turf/impacted_turf AS in impacted_turfs)
		impacted_turf.Shake(duration = 0.2 SECONDS)
		for(var/atom/impacted_atom AS in impacted_turf)
			if(!(impacted_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(impacted_atom))
				continue
			if(isliving(impacted_atom))
				var/mob/living/impacted_living = impacted_atom
				if(impacted_living.stat == DEAD)
					continue
				impacted_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				animate(impacted_living, pixel_z = impacted_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, impacted_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = impacted_living.pixel_z - 8, layer = impacted_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				impacted_living.animation_spin(0.5 SECONDS, 1, impacted_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				continue
			if(!isobj(impacted_atom))
				continue
			var/obj/impacted_obj = impacted_atom
			if(ishitbox(impacted_atom))
				var/obj/hitbox/impacted_hitbox = impacted_atom
				var/can_stun = !(impacted_hitbox.root in already_stunned_vehicles)
				handle_vehicle_effects(impacted_hitbox.root, damage / 3, should_stun = can_stun)
				if(can_stun)
					already_stunned_vehicles += impacted_hitbox.root
				continue
			if(!isvehicle(impacted_obj))
				impacted_obj.take_damage(damage, BRUTE, MELEE, blame_mob = src)
				continue
			var/can_stun = !(impacted_obj in already_stunned_vehicles)
			if(ismecha(impacted_obj))
				handle_vehicle_effects(impacted_obj, damage * 3, 50, should_stun = can_stun)
			else if(isarmoredvehicle(impacted_obj))
				handle_vehicle_effects(impacted_obj, damage / 3, should_stun = can_stun)
			else
				handle_vehicle_effects(impacted_obj, damage * 3, should_stun = can_stun)
			already_stunned_vehicles += impacted_obj
	playsound(loc, 'sound/effects/alien/behemoth/seismic_fracture_explosion.ogg', 50, 1)

/// Creates telegraph effects for a list of turfs which will automatically delete.
/mob/living/carbon/xenomorph/dragon/proc/telegraph_these_turfs(list/turf/turfs_to_telegraph)
	var/list/obj/effect/telegraph_effects = list()
	for(var/turf/turf_to_telegraph AS in turfs_to_telegraph)
		telegraph_effects += new /obj/effect/temp_visual/dragon/warning(turf_to_telegraph, 3 SECONDS)
	return telegraph_effects

/// Stuns the vehicle's occupants and does damage to the vehicle itself.
/mob/living/carbon/xenomorph/dragon/proc/handle_vehicle_effects(obj/vehicle/vehicle, damage, ap, should_stun)
	vehicle.take_damage(damage, BRUTE, MELEE, armour_penetration = ap, blame_mob = src)
	if(!should_stun)
		return
	for(var/mob/living/living_occupant in vehicle.occupants)
		living_occupant.apply_effect(3 SECONDS, EFFECT_PARALYZE)

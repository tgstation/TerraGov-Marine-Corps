/obj/effect/temp_visual/behemoth/stomp
	name = "Behemoth Stomp"
	icon_state = "behemoth_stomp"
	duration = 0.4 SECONDS
	layer = ABOVE_LYING_MOB_LAYER

/obj/effect/temp_visual/behemoth/stomp/Initialize(mapload)
	. = ..()
	var/matrix/scale_change = matrix()
	transform = scale_change.Scale(0.6, 0.6)
	scale_change.Scale(2.0, 2.0)
	animate(src, alpha = 0, transform = scale_change, time = duration - 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/stomp/west

/obj/effect/temp_visual/behemoth/stomp/west/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = 12
			pixel_y = 1
		if(SOUTH)
			pixel_x = -10
			pixel_y = -1
		if(WEST)
			pixel_x = -25
			pixel_y = -1
		if(EAST)
			pixel_x = 32
			pixel_y = -1

/obj/effect/temp_visual/behemoth/stomp/east

/obj/effect/temp_visual/behemoth/stomp/east/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = -12
			pixel_y = 1
		if(SOUTH)
			pixel_x = 10
			pixel_y = -1
		if(WEST)
			pixel_x = -11
			pixel_y = -1
		if(EAST)
			pixel_x = 18
			pixel_y = -1

/obj/effect/temp_visual/behemoth/crack
	name = "Behemoth Crack"
	icon_state = "behemoth_crack"
	duration = 6 SECONDS
	layer = ABOVE_TURF_LAYER

/obj/effect/temp_visual/behemoth/crack/Initialize(mapload)
	. = ..()
	animate(src, time = duration - 1 SECONDS)
	animate(alpha = 0, time = 1 SECONDS, easing = LINEAR_EASING)

/obj/effect/temp_visual/behemoth/crack/west

/obj/effect/temp_visual/behemoth/crack/west/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = 13
			pixel_y = -11
		if(SOUTH)
			pixel_x = -10
			pixel_y = -11
		if(WEST)
			pixel_x = -26
			pixel_y = -12
		if(EAST)
			pixel_x = 32
			pixel_y = -13

/obj/effect/temp_visual/behemoth/crack/east

/obj/effect/temp_visual/behemoth/crack/east/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = -13
			pixel_y = -11
		if(SOUTH)
			pixel_x = 10
			pixel_y = -11
		if(WEST)
			pixel_x = -12
			pixel_y = -12
		if(EAST)
			pixel_x = 19
			pixel_y = -12

/obj/effect/temp_visual/behemoth/warning
	name = "Behemoth Warning"
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "crush_warning"
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload)
	. = ..()
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

// ***************************************
// *********** Behemoth Parry
// ***************************************
/datum/element/behemoth_parry
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The overlay applied by this element.
	var/mutable_appearance/parry_flash

/datum/element/behemoth_parry/Attach(datum/target)
	. = ..()
	if(!isxeno(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(damage_taken))
	var/mob/living/carbon/xenomorph/xeno_target = target
	var/icon/flash_icon = icon('icons/Xeno/3x3_Xenos.dmi', "Behemoth Flash")
	parry_flash = new(flash_icon)
	xeno_target.add_overlay(parry_flash)
	handle_animation(TRUE)

/datum/element/behemoth_parry/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	var/mob/living/carbon/xenomorph/xeno_source = source
	xeno_source.cut_overlay(parry_flash)

/// Reduces damage taken based on the user's current sunder.
/datum/element/behemoth_parry/proc/damage_taken(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_source = source
	if(amount <= 0 || xeno_source.get_sunder() <= 0)
		return
	var/reduction = xeno_source.get_sunder()
	amount_mod += min(amount * reduction)
	handle_animation(TRUE)

/// Handles the animation associated with a successful parry.
/datum/element/behemoth_parry/proc/handle_animation(parry)
	if(parry_flash)
		addtimer(CALLBACK(src, PROC_REF(handle_animation)), 3 SECONDS)
		if(!parry)
			animate(parry_flash, alpha = 0, time = 1.5 SECONDS)
			animate(alpha = 200, time = 1.5 SECONDS)
			return
		parry_flash.alpha = 255
		animate(parry_flash, alpha = 0, time = 0.2 SECONDS)


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_RANGE 3

/datum/action/xeno_action/activable/earth_riser
	name = "Earth Riser"
	ability_name = "Earth Riser"
	action_icon_state = "4"
	desc = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage."
	plasma_cost = 25
	cooldown_timer = 20 SECONDS
	target_flags = XABB_TURF_TARGET
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
	)
*/

/datum/action/xeno_action/activable/earth_riser/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!target)
		return
	var/target_turf = get_turf(target)
	if(!line_of_sight(xeno_owner, target, EARTH_RISER_RANGE) || isclosedturf(target_turf))
		xeno_owner.balloon_alert(xeno_owner, "Out of range")
		return

	var/owner_turf = get_turf(xeno_owner)
	xeno_owner.dir = get_cardinal_dir(owner_turf, target_turf)
	new /obj/effect/temp_visual/behemoth/crack/west(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/stomp/west(owner_turf, owner.dir)
	playsound(owner.loc, 'sound/effects/bang.ogg', 8, 0)
	for(var/atom/movable/affected_atom in target_turf)
		if(isliving(affected_atom))
			var/mob/living/affected_living = affected_atom
			if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
				continue
			affected_living.emote("pain")
			shake_camera(affected_living, 2, 0.5)
			step_away(affected_living, target_turf, 1, 2)
			affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage * 0.5, BRUTE, blocked = MELEE)
		if(isobj(affected_atom))
			if(ismecha(affected_atom))
				var/obj/vehicle/sealed/mecha/affected_mecha = affected_atom
				affected_mecha.take_damage(xeno_owner.xeno_caste.melee_damage * 5, MELEE)
				continue
			var/obj/affected_object = affected_atom
			affected_object.take_damage(xeno_owner.xeno_caste.melee_damage * 5, MELEE)
	new /obj/structure/earth_pillar(target_turf)
	add_cooldown()
	succeed_activate()


// ***************************************
// *********** Seismic Fracture
// ***************************************
#define SEISMIC_FRACTURE_RANGE 3
#define SEISMIC_FRACTURE_WIND_UP 1.5 SECONDS
#define SEISMIC_FRACTURE_PARALYZE_DURATION 2 SECONDS

/obj/effect/temp_visual/behemoth/warning/seismic_fracture

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload, warning_duration)
	duration = warning_duration
	return ..()

/obj/effect/temp_visual/behemoth/seismic_fracture
	icon = 'icons/effects/64x64.dmi'
	icon_state = "seismic_fracture"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER
	pixel_x = -16
	pixel_y = 8

/obj/effect/temp_visual/behemoth/seismic_fracture/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING|EASE_OUT)

/datum/action/xeno_action/activable/seismic_fracture
	name = "Seismic Fracture"
	ability_name = "Seismic Fracture"
	action_icon_state = "4"
	desc = "Blast the earth around the selected location, inflicting heavy damage in a large radius."
	plasma_cost = 25
	cooldown_timer = 20 SECONDS
	target_flags = XABB_TURF_TARGET
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SEISMIC_FRACTURE,
	)
*/

/datum/action/xeno_action/activable/seismic_fracture/use_ability(atom/target)
	if(!target)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!line_of_sight(xeno_owner, target, SEISMIC_FRACTURE_RANGE))
		xeno_owner.balloon_alert(xeno_owner, "Out of range")
		return
	do_ability(target)

/// Called by use_ability. Handles actually doing the ability.
/datum/action/xeno_action/activable/seismic_fracture/proc/do_ability(atom/target, earth_pillar, warning_duration = SEISMIC_FRACTURE_WIND_UP)
	var/owner_turf = get_turf(owner)
	var/target_turf = get_turf(target)

	if(!earth_pillar)
		add_cooldown()
		succeed_activate()
		owner.dir = get_cardinal_dir(owner_turf, target_turf)
		new /obj/effect/temp_visual/behemoth/crack/east(owner_turf, owner.dir)
		new /obj/effect/temp_visual/behemoth/stomp/east(owner_turf, owner.dir)
		playsound(owner.loc, 'sound/effects/bang.ogg', 8, 0)
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		for(var/mob/living/living_target in owner_turf)
			if(xeno_owner.issamexenohive(living_target) || living_target.stat == DEAD)
				continue
			living_target.emote("scream")
			shake_camera(living_target, 2, 1)
			living_target.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION * 0.75)
			living_target.apply_damage(xeno_owner.xeno_caste.melee_damage * 2, BRUTE, blocked = MELEE)

	var/list/turf/turfs_to_attack
	LAZYINITLIST(turfs_to_attack)
	for(var/turf/affected_turf in filled_turfs(target_turf, 2, bypass_window = TRUE, bypass_xeno = TRUE, air_pass = TRUE))
		if(isclosedturf(affected_turf))
			continue
		turfs_to_attack += affected_turf
	do_warning(target_turf, turfs_to_attack, warning_duration)

/// Called by use_ability. Creates a visual effect that serves as a warning for this ability.
/datum/action/xeno_action/activable/seismic_fracture/proc/do_warning(target_turf, list/turf/turfs_to_attack, duration)
	if(duration <= SEISMIC_FRACTURE_WIND_UP)
		playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_rumble.ogg', 20, 0)

	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/turf/affected_turf AS in turfs_to_attack)
		new /obj/effect/temp_visual/behemoth/warning/seismic_fracture(affected_turf, duration)
		for(var/mob/living/affected_living in affected_turf)
			if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
				continue
			shake_camera(affected_living, duration, 0.5)

	addtimer(CALLBACK(src, PROC_REF(do_attack), target_turf, turfs_to_attack), duration)

/// Called by do_warning. Does the actual attack on any living mobs caught inside the ability's radius.
/datum/action/xeno_action/activable/seismic_fracture/proc/do_attack(target_turf, list/turf/turfs_to_attack)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_explosion.ogg', 40, 0)

	var/list/mob/living/living_to_attack
	LAZYINITLIST(living_to_attack)
	for(var/turf/affected_turf AS in turfs_to_attack)
		new /obj/effect/temp_visual/behemoth/seismic_fracture(affected_turf)
		new /obj/effect/temp_visual/behemoth/crack(affected_turf)
		for(var/atom/movable/affected_atom in affected_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				living_to_attack += affected_living
				affected_living.emote("scream")
				shake_camera(affected_living, 3, 1)
				affected_living.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION)
				affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage, BRUTE, blocked = MELEE)
				affected_living.layer = ABOVE_MOB_LAYER
				affected_living.status_flags |= (INCORPOREAL|GODMODE)
				animate(affected_living, pixel_y = affected_living.pixel_y + 40, layer = ABOVE_MOB_LAYER, time = SEISMIC_FRACTURE_PARALYZE_DURATION * 0.5, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
				animate(pixel_y = initial(affected_living.pixel_y), time = SEISMIC_FRACTURE_PARALYZE_DURATION * 0.5, easing = CIRCULAR_EASING|EASE_IN)
			if(isobj(affected_atom))
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mech = affected_atom
					affected_mech.take_damage(xeno_owner.xeno_caste.melee_damage * 10, MELEE)
					continue
				if(istype(affected_atom, /obj/structure/earth_pillar))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					affected_pillar.do_jitter_animation(1000)
					affected_pillar.seismic_fracture()
					playsound(affected_pillar, affected_pillar.destroy_sound, 40, 0)
					do_ability(get_turf(affected_pillar), TRUE, initial(affected_pillar.warning_flashes) * 10)
					continue
				var/obj/affected_object = affected_atom
				affected_object.take_damage(xeno_owner.xeno_caste.melee_damage * 2, MELEE)

	addtimer(CALLBACK(src, PROC_REF(do_landing), living_to_attack), SEISMIC_FRACTURE_PARALYZE_DURATION)

/// Called by do_attack. Handles the aftereffects for any living mobs caught by the attack.
/datum/action/xeno_action/activable/seismic_fracture/proc/do_landing(list/mob/living/living_to_attack)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living AS in living_to_attack)
		affected_living.layer = initial(affected_living.layer)
		affected_living.status_flags &= ~(INCORPOREAL|GODMODE)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage * 0.5, BRUTE, blocked = MELEE)
		playsound(affected_living.loc, 'sound/effects/behemoth/seismic_fracture_landing.ogg', 10, 0)
		new /obj/effect/temp_visual/behemoth/stomp(get_turf(affected_living))


// ***************************************
// *********** Primal Wrath
// ***************************************
/datum/action/xeno_action/primal_wrath
	name = "Primal Wrath"
	ability_name = "Primal Wrath"
	action_icon_state = "26"
	desc = "Unleash your wrath. Enhances your abilities, changing their functionality and allowing them to apply a damage over time debuff."
	plasma_cost = 0
	cooldown_timer = 300 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PRIMAL_WRATH,
	)
*/

/datum/action/xeno_action/primal_wrath/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.balloon_alert(xeno_owner, "Primal Wrath ready")
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/primal_wrath/action_activate()


// ***************************************
// *********** Earth Pillar
// ***************************************
/obj/effect/temp_visual/behemoth/earth_pillar
	name = "Behemoth Earth Pillar"
	icon = 'icons/effects/64x64.dmi'
	duration = 2 SECONDS
	layer = WALL_OBJ_LAYER
	pixel_x = -15
	pixel_y = -15

/obj/effect/temp_visual/behemoth/earth_pillar/front
	icon_state = "earth_pillar_front"

/obj/effect/temp_visual/behemoth/earth_pillar/front/Initialize(mapload)
	. = ..()
	layer += 0.01

/obj/effect/temp_visual/behemoth/earth_pillar/back
	icon_state = "earth_pillar_back"

/obj/effect/temp_visual/behemoth/earth_pillar/front/Initialize(mapload)
	. = ..()
	layer -= 0.01

/obj/structure/earth_pillar
	name = "Earth Pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar"
	base_icon_state = "earth_pillar"
	layer = WALL_OBJ_LAYER
	max_integrity = 300
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	var/possible_hit_sounds = list('sound/effects/behemoth/earth_pillar_hit_1.ogg',
	'sound/effects/behemoth/earth_pillar_hit_2.ogg',
	'sound/effects/behemoth/earth_pillar_hit_3.ogg',
	'sound/effects/behemoth/earth_pillar_hit_4.ogg',
	'sound/effects/behemoth/earth_pillar_hit_5.ogg',
	'sound/effects/behemoth/earth_pillar_hit_6.ogg')
	destroy_sound = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	/// The amount of times a xeno needs to attack this to destroy it.
	var/attacks_to_destroy = 3
	/// The amount of times an Earth Pillar flashes before executing its interaction with Seismic Fracture.
	var/warning_flashes = 3

/obj/structure/earth_pillar/Initialize(mapload)
	. = ..()
	var/matrix/scale_change = matrix()
	transform = scale_change.Scale(1.5, 1.5)
	do_jitter_animation(1000)
	//new /obj/effect/temp_visual/behemoth/earth_pillar/front(get_turf(src))
	//new /obj/effect/temp_visual/behemoth/earth_pillar/back(get_turf(src))

/obj/structure/earth_pillar/attacked_by(obj/item/I, mob/living/user, def_zone)
	playsound(src, pick(possible_hit_sounds), 20)
	return ..()

// Attacking an Earth Pillar as a xeno will decrease the amount of attacks needed to destroy this structure, without reducing its integrity.
// When that amount is zero, it will destroy this structure.
/obj/structure/earth_pillar/attack_alien(mob/living/carbon/xenomorph/X, isrightclick = FALSE)
	if(X.a_intent != INTENT_HARM)
		return FALSE
	if(attacks_to_destroy <= 1)
		X.balloon_alert(X, "Destroyed")
		Destroy()
		return TRUE
	attacks_to_destroy--
	X.balloon_alert(X, "Attack [attacks_to_destroy] more time(s) to destroy")
	playsound(src, pick(possible_hit_sounds), 20)
	return TRUE

/obj/structure/earth_pillar/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel()
		if(EXPLODE_HEAVY)
			take_damage(100)
		if(EXPLODE_LIGHT)
			take_damage(50)

/// Handles the jitter animation, because this isn't an /obj proc for w/e reason.
/obj/structure/earth_pillar/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	var/final_pixel_x = initial(pixel_x)
	var/final_pixel_y = initial(pixel_y)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)

/// Called by Seismic Fracture's do_attack() proc. Handles the interaction between the ability and this structure.
/obj/structure/earth_pillar/proc/seismic_fracture()
	if(warning_flashes <= 0)
		qdel(src)
		return
	warning_flashes--
	addtimer(CALLBACK(src, PROC_REF(seismic_fracture)), 1 SECONDS)
	animate(src, color = "#FF6A00", time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFFFF", time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

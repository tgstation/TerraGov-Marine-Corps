/datum/action/xeno_action/activable/web_spit
	name = "Web Spit"
	ability_name = "Web Spit"
	mechanics_text = "Spit a web to your target, this causes different effects depending on where you hit. Spitting the head causes the target to be temporarily blind, body and arms will cause the target to be weakened, and legs will snare the target for a brief while."
	action_icon_state = "web_spit"
	plasma_cost = 125
	cooldown_timer = 10 SECONDS
	keybind_signal = COMSIG_XENOABILITY_WEB_SPIT

/datum/action/xeno_action/activable/web_spit/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/ammo/xeno/web/web_spit = GLOB.ammo_list[/datum/ammo/xeno/web]
	var/obj/projectile/newspit = new /obj/projectile(get_turf(X))

	newspit.generate_bullet(web_spit, web_spit.damage * SPIT_UPGRADE_BONUS(X))
	newspit.def_zone = X.get_limbzone_target()

	newspit.fire_at(target, X, null, newspit.ammo.max_range)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Leash Ball
// ***************************************

/datum/action/xeno_action/activable/leash_ball
	name = "Leash Ball"
	ability_name = "Leash Ball"
	mechanics_text = "Spit a huge web ball that snares groups of targets for a brief while."
	action_icon_state = "leash_ball"
	plasma_cost = 250
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LEASH_BALL

/datum/action/xeno_action/activable/leash_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(target)
	if(!do_after(X, 1 SECONDS, TRUE, X, BUSY_ICON_DANGER))
		return fail_activate()
	var/datum/ammo/xeno/leash_ball = GLOB.ammo_list[/datum/ammo/xeno/leash_ball]
	var/obj/projectile/newspit = new (get_turf(X))

	newspit.generate_bullet(leash_ball)
	newspit.fire_at(target, X, null, newspit.ammo.max_range)
	succeed_activate()
	add_cooldown()

/obj/structure/xeno/aoe_leash
	name = "Snaring Web"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "aoe_leash"
	desc = "Sticky and icky. Destroy it when you are stuck!"
	destroy_sound = "alien_resin_break"
	max_integrity = 25
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	throwpass = FALSE
	density = FALSE
	obj_flags = CAN_BE_HIT | PROJ_IGNORE_DENSITY
	/// How long the leash ball lasts untill it dies
	var/leash_life = 10 SECONDS
	/// Radius for how far the leash should affect humans and how far away they may walk
	var/leash_radius = 5
	/// List of beams to be removed on obj_destruction
	var/list/obj/effect/ebeam/beams = list()
	/// List of victims to unregister aoe_leash is destroyed
	var/list/mob/living/carbon/human/leash_victims = list()

/// Humans caught get beamed and registered for proc/check_dist, aoe_leash also gains increased integrity for each caught human
/obj/structure/xeno/aoe_leash/Initialize(mapload)
	. = ..()
	for(var/mob/living/carbon/human/victim in view(leash_radius, loc))
		if(victim.stat == DEAD) /// Add || CONSCIOUS after testing
			break
		if(HAS_TRAIT(victim, TRAIT_LEASHED))
			break
		ADD_TRAIT(victim, TRAIT_LEASHED, src)
		beams += beam(victim, "beam_web", 'icons/effects/beam.dmi', INFINITY, INFINITY)
		leash_victims += victim
		RegisterSignal(victim, COMSIG_MOVABLE_PRE_MOVE, .proc/check_dist)
	if(!length(beams))
		return INITIALIZE_HINT_QDEL
	QDEL_IN(src, leash_life)

/// To remove beams after the leash_ball is destroyed and also unregister all victims
/obj/structure/xeno/aoe_leash/Destroy()
	for(var/mob/living/carbon/human/victim AS in leash_victims)
		UnregisterSignal(victim, COMSIG_MOVABLE_PRE_MOVE)
		REMOVE_TRAIT(victim, TRAIT_LEASHED, src)
	leash_victims = null
	QDEL_LIST(beams)
	return ..()

/// Humans caught in the aoe_leash will be pulled back if they leave it's radius
/obj/structure/xeno/aoe_leash/proc/check_dist(datum/leash_victim, atom/newloc)
	SIGNAL_HANDLER
	if(get_dist(newloc, src) >= leash_radius)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// This is so that xenos can remove leash balls
/obj/structure/xeno/aoe_leash/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	X.visible_message(span_xenonotice("\The [X] starts tearing down \the [src]!"), \
	span_xenonotice("We start to tear down \the [src]."))
	if(!do_after(X, 1 SECONDS, TRUE, X, BUSY_ICON_GENERIC))
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_xenonotice("\The [X] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity)

// ***************************************
// *********** Spiderling Section
// ***************************************

/datum/action/xeno_action/create_spiderling
	name = "Birth Spiderling"
	ability_name = "birth_spiderling"
	mechanics_text = "Give birth to a spiderling after a short charge-up. The spiderlings will follow you until death. You can only deploy 5 spiderlings at one time."
	action_icon_state = "spawn_spiderling"
	plasma_cost = 100
	cooldown_timer = 15 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CREATE_SPIDERLING
	/// List of all our spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/spiderlings = list()

/// The action to create spiderlings
/datum/action/xeno_action/create_spiderling/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(length(spiderlings) >= X.xeno_caste.max_spiderlings)
		X.balloon_alert(X, "Max Spiderlings")
		return fail_activate()
	if(!do_after(X, 0.5 SECONDS, TRUE, X, BUSY_ICON_DANGER))
		return fail_activate()
	/// This creates and stores the spiderling so we can reassign the owner for spider swarm and cap how many spiderlings you can have at once
	var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new(owner.loc, owner, owner)
	add_spiderling(new_spiderling)
	succeed_activate()
	add_cooldown()

/// Adds spiderlings to spiderling list and registers them for death so we can remove them later
/datum/action/xeno_action/create_spiderling/proc/add_spiderling(mob/living/carbon/xenomorph/spiderling/new_spiderling)
	RegisterSignal(new_spiderling, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), .proc/remove_spiderling)
	spiderlings += new_spiderling
	new_spiderling.pixel_x = rand(-8, 8)
	new_spiderling.pixel_y = rand(-8, 8)

/// Removes spiderling from spiderling list and unregisters death signal
/datum/action/xeno_action/create_spiderling/proc/remove_spiderling(datum/source)
	SIGNAL_HANDLER
	spiderlings -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

// ***************************************
// *********** Burrow
// ***************************************

/datum/action/xeno_action/burrow
	name = "Burrow"
	ability_name = "Burrow"
	mechanics_text = "Burrow into the ground, allowing you and your active spiderlings to hide in plain sight. You cannot use abilities, attack nor move while burrowed. Use the ability again to unburrow if you're already burrowed."
	action_icon_state = "burrow"
	plasma_cost = 0
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BURROW
	use_state_flags = XACT_USE_BURROWED

/datum/action/xeno_action/burrow/action_activate()
	. = ..()
	/// We need the list of spiderlings so that we can burrow them
	var/datum/action/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/xeno_action/create_spiderling]
	/// Here we make every single spiderling that we have also burrow and assign a signal so that they unburrow too
	for(var/mob/living/carbon/xenomorph/spiderling/spiderling AS in create_spiderling_action?.spiderlings)
		/// Here we trigger the burrow proc, the registering happens there
		var/datum/action/xeno_action/burrow/spiderling_burrow = spiderling.actions_by_path[/datum/action/xeno_action/burrow]
		spiderling_burrow.xeno_burrow()
	xeno_burrow()
	succeed_activate()

/// Burrow code for xenomorphs
/datum/action/xeno_action/burrow/proc/xeno_burrow()
	var/mob/living/carbon/xenomorph/X = owner
	SIGNAL_HANDLER
	if(!HAS_TRAIT(X, TRAIT_BURROWED))
		to_chat(X, span_xenowarning("We start burrowing into the ground..."))
		INVOKE_ASYNC(src, .proc/xeno_burrow_doafter)
		return
	UnregisterSignal(X, COMSIG_MOVABLE_MOVED)
	X.fire_resist_modifier += BURROW_FIRE_RESIST_MODIFIER
	X.icon_state = initial(X.icon_state)
	X.mouse_opacity = initial(X.mouse_opacity)
	X.density = TRUE
	X.throwpass = FALSE
	REMOVE_TRAIT(X, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(X, TRAIT_MOB_ICON_UPDATE_BLOCKED, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(X, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(X, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	add_cooldown()

/// Called by xeno_burrow only when burrowing
/datum/action/xeno_action/burrow/proc/xeno_burrow_doafter()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(X, 3 SECONDS, TRUE, null, BUSY_ICON_DANGER))
		return
	to_chat(X, span_xenowarning("We are now burrowed, hidden in plain sight and ready to strike."))
	// This part here actually burrows the xeno
	X.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	X.density = FALSE
	X.throwpass = TRUE
	// Update here without waiting for life
	X.icon_state = "[X.xeno_caste.caste_name] Burrowed"
	X.wound_overlay.icon_state = ""
	X.fire_overlay.icon_state = ""
	// Here we prevent the xeno from moving or attacking or using abilities untill they unburrow by clicking the ability
	X.fire_resist_modifier -= BURROW_FIRE_RESIST_MODIFIER // This makes the xeno immune to fire while burrowed, even if burning beforehand
	ADD_TRAIT(X, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(X, TRAIT_MOB_ICON_UPDATE_BLOCKED, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(X, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(X, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	// We register for movement so that we unburrow if bombed
	RegisterSignal(X, COMSIG_MOVABLE_MOVED, .proc/xeno_burrow)

// ***************************************
// *********** Attach Spiderlings
// ***************************************
/datum/action/xeno_action/attach_spiderlings
	name = "Attach Spiderlings"
	ability_name = "Attach Spiderlings"
	mechanics_text = "Attach your current spiderlings to you "
	action_icon_state = "attach_spiderling"
	plasma_cost = 0
	cooldown_timer = 0 SECONDS
	keybind_signal = COMSIG_XENOABILITY_ATTACH_SPIDERLINGS
	// the attached spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/attached_spiderlings = list()
	// how many times we attempt to attach adjacent spiderligns
	var/attach_attempts = 5

/datum/action/xeno_action/attach_spiderlings/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/widow/X = owner
	if(X.buckled_mobs)
		/// yeet off all spiderlings if we are carrying any
		X.unbuckle_all_mobs(TRUE)
		return
	var/datum/action/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/xeno_action/create_spiderling]
	if(!(length(create_spiderling_action.spiderlings)))
		X.balloon_alert(X, "No spiderlings")
		return fail_activate()
	var/list/mob/living/carbon/xenomorph/spiderling/remaining_spiderlings = create_spiderling_action.spiderlings.Copy()
	grab_spiderlings(remaining_spiderlings, attach_attempts)
	succeed_activate()

// this proc scoops up adjacent spiderlings and then calls ride_widow on them
/datum/action/xeno_action/attach_spiderlings/proc/grab_spiderlings(list/mob/living/carbon/xenomorph/spiderling/remaining_list, number_of_attempts_left)
	var/mob/living/carbon/xenomorph/widow/X = owner
	if(number_of_attempts_left <= 0)
		return
	for(var/mob/living/carbon/xenomorph/spiderling/remaining_spiderling AS in remaining_list)
		if(!X.Adjacent(remaining_spiderling))
			continue
		remaining_list -= remaining_spiderling
		X.buckle_mob(remaining_spiderling, TRUE, TRUE, 90, 1,0)
	addtimer(CALLBACK(src, .proc/grab_spiderlings, remaining_list, number_of_attempts_left - 1), 1)

// ***************************************
// *********** Web Hook
// ***************************************
/datum/action/xeno_action/activable/web_hook
	name = "Web Hook"
	ability_name = "Web Hook"
	mechanics_text = "Shoot out a web and pull it to traverse forward"
	action_icon_state = "web_hook"
	plasma_cost = 50
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_WEB_HOOK
	//ref to beam for web hook
	var/datum/beam/web_beam
	//Do we go full or half?
	var/full_distance = TRUE

/datum/action/xeno_action/activable/web_hook/can_use_ability(atom/A)
	. = ..()
	if(isliving(A))
		return FALSE
	if(!isturf(A))
		return FALSE
	var/turf/current = get_turf(owner)
	var/turf/target_turf = get_turf(A)
	if(get_dist(current, target_turf) > WIDOW_WEB_HOOK_RANGE)
		return FALSE
	current = get_step_towards(current, target_turf)
	while((current != target_turf))
		if(current.density)
			full_distance = TRUE
			return TRUE
		current = get_step_towards(current, target_turf)
	if(!current.density)
		full_distance = FALSE

/datum/action/xeno_action/activable/web_hook/use_ability(atom/A)
	var/atom/movable/web_hook/web_hook = new (get_turf(owner))
	web_beam = owner.beam(web_hook,"beam_web",'icons/effects/beam.dmi')
	RegisterSignal(web_hook, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT), .proc/drag_widow)
	web_hook.throw_at(A, WIDOW_WEB_HOOK_RANGE * 1.5, 3, owner, FALSE) //Too hard to hit if just TENTACLE_ABILITY_RANGE
	succeed_activate()
	add_cooldown()

/// This throws widow wherever the web_hook landed, distance is dependant on if the web_hook hit a wall or just ground
/datum/action/xeno_action/activable/web_hook/proc/drag_widow(datum/source, turf/t)
	SIGNAL_HANDLER
	QDEL_NULL(web_beam)
	var/throw_turf = get_turf(t)
	if(full_distance)
		owner.throw_at(throw_turf, WIDOW_WEB_HOOK_RANGE, 1, owner)
	else
		throw_turf = get_turf(source)
		var/throw_distance = (get_dist(throw_turf, owner) / 2)
		owner.throw_at(throw_turf, throw_distance, 1, owner)
	qdel(source)
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, .proc/delete_beam)

///signal handler to delete tetacle after we are done draggging owner along
/datum/action/xeno_action/activable/web_hook/proc/delete_beam(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	QDEL_NULL(web_beam)

/atom/movable/web_hook
	name = "You can't see this"
	invisibility = INVISIBILITY_ABSTRACT

/datum/action/ability/activable/xeno/web_spit
	name = "Web Spit"
	desc = "Spit a web to your target, this causes different effects depending on where you hit. Spitting the head causes the target to be temporarily blind, body and arms will cause the target to be weakened, and legs will snare the target for a brief while."
	action_icon_state = "web_spit"
	ability_cost = 125
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WEB_SPIT,
	)

/datum/action/ability/activable/xeno/web_spit/use_ability(atom/target)
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

/datum/action/ability/activable/xeno/leash_ball
	name = "Leash Ball"
	desc = "Spit a huge web ball that snares groups of targets for a brief while."
	action_icon_state = "leash_ball"
	ability_cost = 250
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LEASH_BALL,
	)

/datum/action/ability/activable/xeno/leash_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(target)
	if(!do_after(X, 1 SECONDS, NONE, X, BUSY_ICON_DANGER))
		return fail_activate()
	var/datum/ammo/xeno/leash_ball = GLOB.ammo_list[/datum/ammo/xeno/leash_ball]
	leash_ball.hivenumber = X.hivenumber
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
	max_integrity = 75
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	allow_pass_flags = NONE
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
/obj/structure/xeno/aoe_leash/Initialize(mapload, _hivenumber)
	. = ..()
	for(var/mob/living/carbon/human/victim in GLOB.humans_by_zlevel["[z]"])
		if(get_dist(src, victim) > leash_radius)
			continue
		if(victim.stat == DEAD) /// Add || CONSCIOUS after testing
			continue
		if(HAS_TRAIT(victim, TRAIT_LEASHED))
			continue
		if(!check_path(src, victim, projectile = TRUE))
			continue
		leash_victims += victim
	for(var/mob/living/carbon/human/snared_victim AS in leash_victims)
		ADD_TRAIT(snared_victim, TRAIT_LEASHED, src)
		beams += beam(snared_victim, "beam_web", 'icons/effects/beam.dmi', INFINITY, INFINITY)
		RegisterSignal(snared_victim, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_dist))
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
	if(!do_after(X, 1 SECONDS, NONE, X, BUSY_ICON_GENERIC) || QDELETED(src))
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_xenonotice("\The [X] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity)

// ***************************************
// *********** Spiderling Section
// ***************************************

/datum/action/ability/xeno_action/create_spiderling
	name = "Birth Spiderling"
	desc = "Give birth to a spiderling after a short charge-up. The spiderlings will follow you until death. You can only deploy 5 spiderlings at one time. On alt-use, if any charges of Cannibalise are stored, create a spiderling at no plasma cost or cooldown."
	action_icon_state = "spawn_spiderling"
	ability_cost = 100
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_SPIDERLING,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CREATE_SPIDERLING_USING_CC,
	)

	/// List of all our spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/spiderlings = list()
	/// Current amount of cannibalise charges
	var/cannibalise_charges = 0

/datum/action/ability/xeno_action/create_spiderling/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	var/max_spiderlings = X?.xeno_caste.max_spiderlings ? X.xeno_caste.max_spiderlings : 5
	desc = "Give birth to a spiderling after a short charge-up. The spiderlings will follow you until death. You can only deploy [max_spiderlings] spiderlings at one time. On alt-use, if any charges of Cannibalise are stored, create a spiderling at no plasma cost or cooldown."

/datum/action/ability/xeno_action/create_spiderling/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(length(spiderlings) >= X.xeno_caste.max_spiderlings)
		if(!silent)
			X.balloon_alert(X, "Max Spiderlings")
		return FALSE

/// The action to create spiderlings
/datum/action/ability/xeno_action/create_spiderling/action_activate()
	. = ..()
	if(!do_after(owner, 0.5 SECONDS, NONE, owner, BUSY_ICON_DANGER))
		return fail_activate()
	add_spiderling()
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/create_spiderling/alternate_action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(cannibalise_charges <= 0)
		X.balloon_alert(X, "No charges remaining!")
		return
	if(length(spiderlings) >= X.xeno_caste.max_spiderlings)
		X.balloon_alert(X, "Max Spiderlings")
		return
	INVOKE_ASYNC(src, PROC_REF(use_cannibalise))
	return COMSIG_KB_ACTIVATED

/// Birth a spiderling and use up a charge of cannibalise
/datum/action/ability/xeno_action/create_spiderling/proc/use_cannibalise()
	if(!do_after(owner, 0.5 SECONDS, NONE, owner, BUSY_ICON_DANGER))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(cannibalise_charges <= 0)
		X.balloon_alert(X, "No charges remaining!")
		return
	if(length(spiderlings) >= X.xeno_caste.max_spiderlings)
		X.balloon_alert(X, "Max Spiderlings")
		return
	add_spiderling()
	cannibalise_charges -= 1
	owner.balloon_alert(owner, "[cannibalise_charges]/3 charges remaining")

/// Adds spiderlings to spiderling list and registers them for death so we can remove them later
/datum/action/ability/xeno_action/create_spiderling/proc/add_spiderling()
	/// This creates and stores the spiderling so we can reassign the owner for spider swarm and cap how many spiderlings you can have at once
	var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new(owner.loc, owner, owner)
	RegisterSignals(new_spiderling, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(remove_spiderling))
	spiderlings += new_spiderling
	new_spiderling.pixel_x = rand(-8, 8)
	new_spiderling.pixel_y = rand(-8, 8)
	return TRUE

/// Removes spiderling from spiderling list and unregisters death signal
/datum/action/ability/xeno_action/create_spiderling/proc/remove_spiderling(datum/source)
	SIGNAL_HANDLER
	spiderlings -= source
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_QDELETING))

// ***************************************
// *********** Spiderling mark
// ***************************************

/datum/action/ability/activable/xeno/spiderling_mark
	name = "Spiderling Mark"
	desc = "Send your spawn on a valid target, they will automatically destroy themselves out of sheer fury after 15 seconds."
	action_icon_state = "spiderling_mark"
	ability_cost = 50
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPIDERLING_MARK,
	)

/datum/action/ability/activable/xeno/spiderling_mark/use_ability(atom/A)
	. = ..()
	// So the spiderlings can actually attack
	owner.unbuckle_all_mobs(TRUE)
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(length(create_spiderling_action.spiderlings) <= 0)
		owner.balloon_alert(owner, "No spiderlings")
		return fail_activate()
	if(!isturf(A) && !istype(A, /obj/alien/weeds))
		owner.balloon_alert(owner, "Spiderlings attacking " + A.name)
	else
		for(var/item in A) //Autoaim at humans if weeds or turfs are clicked
			if(!ishuman(item))
				continue
			A = item
			owner.balloon_alert(owner, "Spiderlings attacking " + A.name)
			break
		if(!ishuman(A)) //If no human found, cancel ability
			owner.balloon_alert(owner, "Nothing to attack, cancelled")
			return fail_activate()

	succeed_activate()
	SEND_SIGNAL(owner, COMSIG_SPIDERLING_MARK, A)
	add_cooldown()

// ***************************************
// *********** Burrow
// ***************************************

/datum/action/ability/xeno_action/burrow
	name = "Burrow"
	desc = "Burrow into the ground, allowing you and your active spiderlings to hide in plain sight. You cannot use abilities, attack nor move while burrowed. Use the ability again to unburrow if you're already burrowed."
	action_icon_state = "burrow"
	ability_cost = 0
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BURROW,
	)
	use_state_flags = ABILITY_USE_BURROWED

/datum/action/ability/xeno_action/burrow/action_activate()
	. = ..()
	/// We need the list of spiderlings so that we can burrow them
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	/// Here we make every single spiderling that we have also burrow and assign a signal so that they unburrow too
	for(var/mob/living/carbon/xenomorph/spiderling/spiderling AS in create_spiderling_action?.spiderlings)
		/// Here we trigger the burrow proc, the registering happens there
		var/datum/action/ability/xeno_action/burrow/spiderling_burrow = spiderling.actions_by_path[/datum/action/ability/xeno_action/burrow]
		spiderling_burrow.xeno_burrow()
	xeno_burrow()
	succeed_activate()

/// Burrow code for xenomorphs
/datum/action/ability/xeno_action/burrow/proc/xeno_burrow()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	if(!HAS_TRAIT(X, TRAIT_BURROWED))
		to_chat(X, span_xenowarning("We start burrowing into the ground..."))
		INVOKE_ASYNC(src, PROC_REF(xeno_burrow_doafter))
		return
	UnregisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE)
	ADD_TRAIT(X, TRAIT_NON_FLAMMABLE, initial(name))
	X.soft_armor = X.soft_armor.modifyRating(fire = 100)
	X.hard_armor = X.hard_armor.modifyRating(fire = 100)
	X.mouse_opacity = initial(X.mouse_opacity)
	X.density = TRUE
	X.allow_pass_flags &= ~PASSABLE
	REMOVE_TRAIT(X, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(X, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(X, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	X.update_icons()
	add_cooldown()
	owner.unbuckle_all_mobs(TRUE)

/// Called by xeno_burrow only when burrowing
/datum/action/ability/xeno_action/burrow/proc/xeno_burrow_doafter()
	if(!do_after(owner, 3 SECONDS, NONE, null, BUSY_ICON_DANGER))
		return
	to_chat(owner, span_xenowarning("We are now burrowed, hidden in plain sight and ready to strike."))
	// This part here actually burrows the xeno
	owner.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	owner.density = FALSE
	owner.allow_pass_flags |= PASSABLE
	// Here we prevent the xeno from moving or attacking or using abilities until they unburrow by clicking the ability
	ADD_TRAIT(owner, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(owner, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	// We register for movement so that we unburrow if bombed
	var/mob/living/carbon/xenomorph/X = owner
	X.soft_armor = X.soft_armor.modifyRating(fire = -100)
	X.hard_armor = X.hard_armor.modifyRating(fire = -100)
	REMOVE_TRAIT(X, TRAIT_NON_FLAMMABLE, initial(name))
	// Update here without waiting for life
	X.update_icons()
	RegisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(xeno_burrow))

// ***************************************
// *********** Attach Spiderlings
// ***************************************
/datum/action/ability/xeno_action/attach_spiderlings
	name = "Attach Spiderlings"
	desc = "Attach your current spiderlings to you "
	action_icon_state = "attach_spiderling"
	ability_cost = 0
	cooldown_duration = 0 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ATTACH_SPIDERLINGS,
	)
	///the attached spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/attached_spiderlings = list()
	///how many times we attempt to attach adjacent spiderligns
	var/attach_attempts = 5

/datum/action/ability/xeno_action/attach_spiderlings/action_activate()
	. = ..()
	if(owner.buckled_mobs)
		/// yeet off all spiderlings if we are carrying any
		owner.unbuckle_all_mobs(TRUE)
		return
	var/mob/living/carbon/xenomorph/widow/X = owner
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = X.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!(length(create_spiderling_action.spiderlings)))
		X.balloon_alert(X, "No spiderlings")
		return fail_activate()
	var/list/mob/living/carbon/xenomorph/spiderling/remaining_spiderlings = create_spiderling_action.spiderlings.Copy()
	// First make the spiderlings stop what they are doing and return to the widow
	for(var/mob/spider in remaining_spiderlings)
		var/datum/component/ai_controller/AI = spider.GetComponent(/datum/component/ai_controller)
		AI?.ai_behavior.change_action(ESCORTING_ATOM, AI.ai_behavior.escorted_atom)
	grab_spiderlings(remaining_spiderlings, attach_attempts)
	succeed_activate()

/// this proc scoops up adjacent spiderlings and then calls ride_widow on them
/datum/action/ability/xeno_action/attach_spiderlings/proc/grab_spiderlings(list/mob/living/carbon/xenomorph/spiderling/remaining_list, number_of_attempts_left)
	if(number_of_attempts_left <= 0)
		return
	for(var/mob/living/carbon/xenomorph/spiderling/remaining_spiderling AS in remaining_list)
		SEND_SIGNAL(owner, COMSIG_SPIDERLING_RETURN) //So spiderlings move towards the buckle
		if(!owner.Adjacent(remaining_spiderling))
			continue
		remaining_list -= remaining_spiderling
		owner.buckle_mob(remaining_spiderling, TRUE, TRUE, 90, 1,0)
		ADD_TRAIT(remaining_spiderling, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(grab_spiderlings), remaining_list, number_of_attempts_left - 1), 1)

// ***************************************
// *********** Cannibalise
// ***************************************
/datum/action/ability/activable/xeno/cannibalise
	name = "Cannibalise Spiderling"
	desc = "Consume one of your children, storing their biomass for future use. If any charges of Cannibalise are stored, alt-use of Birth Spiderling will create one spiderling in exchange for one charge of Cannibalise. Up to three charges of Cannibalise may be stored at once."
	action_icon_state = "cannibalise_spiderling"
	ability_cost = 150
	cooldown_duration = 2 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CANNIBALISE_SPIDERLING,
	)

/datum/action/ability/activable/xeno/cannibalise/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.Adjacent(A))
		owner.balloon_alert(owner, "Not adjacent")
		return FALSE
	if(!istype(A, /mob/living/carbon/xenomorph/spiderling))
		owner.balloon_alert(owner, "We can't cannibalise this")
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/cannibalise/use_ability(atom/A)
	if(!do_after(owner, 0.5 SECONDS, NONE, A, BUSY_ICON_DANGER))
		return fail_activate()

	var/mob/living/carbon/xenomorph/spiderling/to_cannibalise = A
	QDEL_NULL(to_cannibalise)
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling_action)
		return

	if(create_spiderling_action.cannibalise_charges < 3)
		create_spiderling_action.cannibalise_charges += 1
		owner.balloon_alert(owner, "[create_spiderling_action.cannibalise_charges]/3 charges")
	else
		owner.balloon_alert(owner, "We're full, no charges gained!")
	playsound(owner.loc, 'sound/items/eatfood.ogg', 15, TRUE)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Web Hook
// ***************************************
/datum/action/ability/activable/xeno/web_hook
	name = "Web Hook"
	desc = "Shoot out a web and pull it to traverse forward"
	action_icon_state = "web_hook"
	ability_cost = 200
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WEB_HOOK,
	)
	//ref to beam for web hook
	var/datum/beam/web_beam

/datum/action/ability/activable/xeno/web_hook/can_use_ability(atom/A)
	. = ..()
	if(!.)
		return
	if(isliving(A))
		owner.balloon_alert(owner, "We can't attach to that")
		return FALSE
	if(!isturf(A))
		return FALSE
	if(get_dist(owner, A) <= WIDOW_WEB_HOOK_MIN_RANGE)
		owner.balloon_alert(owner, "Too close")
		return FALSE
	var/turf/current = get_turf(owner)
	var/turf/target_turf = get_turf(A)
	if(get_dist(current, target_turf) > WIDOW_WEB_HOOK_RANGE)
		owner.balloon_alert(owner, "Too far")
		return FALSE
	current = get_step_towards(current, target_turf)

/datum/action/ability/activable/xeno/web_hook/use_ability(atom/A)
	var/atom/movable/web_hook/web_hook = new (get_turf(owner))
	web_beam = owner.beam(web_hook,"beam_web",'icons/effects/beam.dmi')
	RegisterSignals(web_hook, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT), PROC_REF(drag_widow), TRUE)
	web_hook.throw_at(A, WIDOW_WEB_HOOK_RANGE, 3, owner, FALSE)
	succeed_activate()
	add_cooldown()

/// This throws widow wherever the web_hook landed, distance is dependant on if the web_hook hit a wall or just ground
/datum/action/ability/activable/xeno/web_hook/proc/drag_widow(datum/source, turf/target_turf)
	SIGNAL_HANDLER
	QDEL_NULL(web_beam)
	if(target_turf)
		owner.throw_at(target_turf, WIDOW_WEB_HOOK_RANGE, WIDOW_WEB_HOOK_SPEED, owner, FALSE)
	else
		// we throw widow half the distance if she hits the floor
		owner.throw_at(get_turf(source), WIDOW_WEB_HOOK_RANGE / 2, WIDOW_WEB_HOOK_SPEED, owner, FALSE)
	qdel(source)
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(delete_beam))

///signal handler to delete the web_hook after we are done draggging owner along
/datum/action/ability/activable/xeno/web_hook/proc/delete_beam(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	QDEL_NULL(web_beam)

/// Our web hook that we throw
/atom/movable/web_hook
	name = "You can't see this"
	invisibility = INVISIBILITY_ABSTRACT

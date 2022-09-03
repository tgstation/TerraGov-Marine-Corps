/datum/action/xeno_action/activable/web_spit
	name = "Web Spit"
	ability_name = "Web Spit"
	mechanics_text = "We spit a stretchy web at our prey"
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
	mechanics_text = " Spit a huge ball of web that snares groups of marines "
	action_icon_state = "leash_ball"
	plasma_cost = 250
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LEASH_BALL

/datum/action/xeno_action/activable/leash_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(target)
	if(!do_after(X, 1 SECONDS, TRUE, X, BUSY_ICON_DANGER)) // currently here for balance prediction, shooting a 5x5 AoE snare is pretty insane even for T3 imo
		return fail_activate()

	var/datum/ammo/leash_ball = GLOB.ammo_list[/datum/ammo/leash_ball]
	var/obj/projectile/newspit = new /obj/projectile(get_turf(X))

	newspit.generate_bullet(leash_ball)
	newspit.fire_at(target, X, null, newspit.ammo.max_range)
	succeed_activate()
	add_cooldown()

/obj/structure/xeno/aoe_leash
	name = "Snaring Web"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "aoe_leash"
	desc = "Looks very sticky"
	destroy_sound = "alien_resin_break"
	max_integrity = 1920
	/// Radius for how far the leash should affect humans and how far away they may walk
	var/leash_radius = 5
	/// How much more integrity aoe_leash gains per caught marine, it is preferable that max_integrity is this var * 8.
	var/integrity_increase = 240
	/// List of beams to be removed on obj_destruction
	var/list/obj/effect/ebeam/beams = list()
	/// List of victims to unregister aoe_leash is destroyed
	var/list/mob/living/carbon/human/leash_victims = list()
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/// Humans caught get beamed and registered for proc/check_dist, aoe_leash also gains increased integrity for each caught human
/obj/structure/xeno/aoe_leash/Initialize(mapload)
	. = ..()
	for(var/mob/living/carbon/human/victim in view(leash_radius, loc))
		beams += (beam(victim, "beam_web", 'icons/effects/beam.dmi', INFINITY, INFINITY))
		leash_victims += victim
		RegisterSignal(victim, COMSIG_MOVABLE_MOVED, .proc/check_dist)
		obj_integrity = obj_integrity + integrity_increase
		if(obj_integrity > max_integrity)
			obj_integrity = min(obj_integrity + integrity_increase, max_integrity)
	if(!length(beams))
		return INITIALIZE_HINT_QDEL

/// To remove beams after the leash_ball is destroyed and also unregister all victims
/obj/structure/xeno/aoe_leash/obj_destruction()
	. = ..()
	for(var/mob/living/carbon/human/victim AS in leash_victims)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
	leash_victims = null
	if(!length(beams))
		return
	QDEL_LIST(beams)


/// Humans caught in the aoe_leash will be pulled back if they leave it's radius
/obj/structure/xeno/aoe_leash/proc/check_dist(datum/leash_victim, atom/oldloc)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/victim = leash_victim
	if(get_dist(victim, src) >= leash_radius)
		victim.forceMove(oldloc)

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
	mechanics_text = " Spawn a spiderling directly under you"
	action_icon_state = "spawn_spiderling"
	plasma_cost = 100
	cooldown_timer = 15 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LEASH_BALL
	/// List of all our spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/spiderlings = list()
	/// Max amount of spiderligns
	var/max_spiderlings = 5

/// The action to create spiderlings
/datum/action/xeno_action/create_spiderling/action_activate()
	. = ..()
	if(length(spiderlings) >= max_spiderlings)
		owner.visible_message(span_notice("We have reached the maximum amount of spiderlings"))
		return fail_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(X, 0.5 SECONDS, TRUE, X, BUSY_ICON_DANGER))
		return fail_activate()
	/// This creates and stores the spiderling so we can reassign the owner for spider swarm and cap how many spiderlings you can have at once
	var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new /mob/living/carbon/xenomorph/spiderling(owner.loc, owner, owner)
	add_spiderling(new_spiderling)
	succeed_activate()
	add_cooldown()

/// Adds spiderlings to spiderling list and registers them for death so we can remove them later
/datum/action/xeno_action/create_spiderling/proc/add_spiderling(mob/living/carbon/xenomorph/spiderling/new_spiderling)
	RegisterSignal(new_spiderling, COMSIG_MOB_DEATH, .proc/remove_spiderling)
	spiderlings += new_spiderling

/// Removes spiderling from spiderling list and unregisters death signal
/datum/action/xeno_action/create_spiderling/proc/remove_spiderling(datum/source)
	SIGNAL_HANDLER
	spiderlings -= source
	var/datum/action/xeno_action/spider_swarm/spider_swarm_action = owner.actions_by_path[/datum/action/xeno_action/spider_swarm]
	if(!spider_swarm_action)
		return
	if(source != spider_swarm_action.current_controlling_spiderling)
		return
	var/mob/living/carbon/xenomorph/spiderling/next_spiderling
	if(length(spiderlings) >= 1)
		next_spiderling = pick(spiderlings)
	else if(length(spiderlings) <= 0)
		next_spiderling = null
	if(!next_spiderling)
		spider_swarm_action.switch_to_mother()
		return
	spider_swarm_action.switch_to_next_spiderling(next_spiderling)

// ***************************************
// *********** Spider Swarm
// ***************************************
/datum/action/xeno_action/spider_swarm
	name = "Spider Swarm"
	ability_name = "Spider Swarm"
	mechanics_text = " Turn into a swarm of spiderlings "
	action_icon_state = "spider_swarm"
	plasma_cost = 500
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_SPIDER_SWARM
	/// The spiderling we are controlling right now
	var/mob/living/carbon/xenomorph/spiderling/current_controlling_spiderling
	/// how many spiderlings should spawn to replace widow
	var/amount_of_spiderlings = 2

/datum/action/xeno_action/spider_swarm/action_activate()
	. = ..()
	if(!do_after(owner, 3 SECONDS, TRUE, owner, BUSY_ICON_DANGER))
		return fail_activate()
	/// We store the spiderling that we want to posses in order to make the other spiderlings follow it
	current_controlling_spiderling = new(get_turf(owner), owner)
	SEND_SIGNAL(owner, COMSIG_ESCORTED_ATOM_CHANGING, current_controlling_spiderling)
	owner.mind.transfer_to(current_controlling_spiderling)
	owner.moveToNullspace()
	/// We want to access the spiderlings list and therefore have this
	var/datum/action/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/xeno_action/create_spiderling]

	for(var/spawned_spiderlings = 0, spawned_spiderlings < amount_of_spiderlings, spawned_spiderlings++)
		var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new /mob/living/carbon/xenomorph/spiderling(current_controlling_spiderling.loc, current_controlling_spiderling)
		/// here we add the created spiderligns to the list
		create_spiderling_action.add_spiderling(new_spiderling)

	create_spiderling_action.add_spiderling(current_controlling_spiderling)
	succeed_activate()
	add_cooldown()

/// This happens whenever the spiderling that we control dies and there are spiderlings left to control
/datum/action/xeno_action/spider_swarm/proc/switch_to_next_spiderling(mob/living/carbon/xenomorph/spiderling/spiderling)
	SEND_SIGNAL(current_controlling_spiderling, COMSIG_ESCORTED_ATOM_CHANGING, spiderling)
	current_controlling_spiderling.mind.transfer_to(spiderling)
	current_controlling_spiderling = spiderling

/// Put the player back in widow
/datum/action/xeno_action/spider_swarm/proc/switch_to_mother()
	owner.forceMove(get_turf(current_controlling_spiderling))
	current_controlling_spiderling.mind.transfer_to(owner)

// ***************************************
// *********** Burrow
// ***************************************

/datum/action/xeno_action/burrow
	name = "Burrow"
	ability_name = "Burrow"
	mechanics_text = " Burrow into the ground to hide in plain sight "
	action_icon_state = "burrow"
	plasma_cost = 100
	cooldown_timer = 4 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BURROW
	use_state_flags = XACT_USE_BURROWED

/datum/action/xeno_action/burrow/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	/// We need the list of spiderlings so that we can burrow them
	var/datum/action/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/xeno_action/create_spiderling]
	/// Here we make every single spiderling that we have also burrow and assign a signal so that they unburrow too
	for(var/mob/living/carbon/xenomorph/spiderling/spiderling AS in create_spiderling_action.spiderlings)
		/// Here we trigger the burrow proc, the registering happens there
		spiderling.xeno_burrow()
	X.xeno_burrow()
	succeed_activate()
	add_cooldown()

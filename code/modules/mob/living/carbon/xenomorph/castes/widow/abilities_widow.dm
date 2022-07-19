// ***************************************
// *********** Web Spit
// ***************************************
/datum/action/xeno_action/activable/web_spit
	name = "Web Spit"
	ability_name = "Web Spit"
	mechanics_text = "We spit a stretchy web at our prey"
	action_icon_state = "toggle_bomb0" // temporary until I get my own icons
	plasma_cost = 1
	cooldown_timer = 5 SECONDS
	keybind_signal = COMSIG_XENOABILITY_WEB_SPIT

/datum/action/xeno_action/activable/web_spit/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner

	var/datum/ammo/xeno/acid/web/web_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/web]

	var/obj/projectile/newspit = new /obj/projectile(get_turf(X))

	newspit.generate_bullet(web_spit, web_spit.damage * SPIT_UPGRADE_BONUS(X))
	newspit.permutated += X
	newspit.def_zone = X.get_limbzone_target()

	newspit.fire_at(target, X, null, newspit.ammo.max_range)

// ***************************************
// *********** Burrow
// ***************************************

/datum/action/xeno_action/activable/burrow
	name = "Burrow"
	ability_name = "Burrow"
	mechanics_text = " Burrow into the ground to hide in plain sight "
	action_icon_state = "savage_on" //temporary until I get my own icons
	plasma_cost = 1
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BURROW

/datum/action/xeno_action/activable/burrow/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_xenowarning("We start burrowing into the ground"))
	if(!do_after(X, 1 SECONDS, TRUE, target, BUSY_ICON_DANGER))
		return fail_activate()
	to_chat(X, span_xenowarning("We have burrowed ourselves, we are hidden from the enemy"))
	X.alpha = 0
	X.mouse_opacity = 0
	X.density = FALSE
	RegisterSignal(X, COMSIG_MOVABLE_MOVED, .proc/un_burrow)

/datum/action/xeno_action/activable/burrow/proc/un_burrow(mob/M)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	X.alpha = 255
	X.mouse_opacity = 255
	X.density = TRUE
	UnregisterSignal(X, COMSIG_MOVABLE_MOVED)


// ***************************************
// *********** Leash Ball
// ***************************************

/datum/action/xeno_action/activable/leash_ball
	name = "leash_ball" // change to in character name later
	ability_name = "leash_ball" // change to in character name later
	mechanics_text = " Spit a huge ball of web that snares groups of marines "
	action_icon_state = "scatter_spit" // temporary until I get my own icons
	plasma_cost = 1
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LEASH_BALL

/datum/action/xeno_action/activable/leash_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(target)
	if(!do_after(X, 1 SECONDS, TRUE, X, BUSY_ICON_DANGER)) // currently here for balance prediction, shooting a 5x5 AoE snare is pretty insane even for T3 imo
		return fail_activate()

	var/datum/ammo/xeno/acid/web/leash_ball = GLOB.ammo_list[/datum/ammo/xeno/acid/web/leash_ball]
	var/obj/projectile/newspit = new /obj/projectile(get_turf(X))

	newspit.generate_bullet(leash_ball)
	newspit.fire_at(target, X, null, newspit.ammo.max_range)
/obj/structure/xeno/aoe_leash
	name = "Snaring Web"
	icon = 'icons/obj/items/projectiles.dmi' // temp ?
	icon_state = "boiler_gas2" // temp
	desc = "Looks very sticky"
	destroy_sound = "alien_resin_break"
	obj_integrity = 0
	max_integrity = 1920
	var/leash_radius = 5 /// radius for aoe_leash and range for the leash
	var/intergrity_increase = 240
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/// Humans caught get beamed and registered for proc/check_dist
/obj/structure/xeno/aoe_leash/Initialize(mapload, atom/A)
	. = ..()
	var/mob/living/carbon/human/victims
	for(victims in view(leash_radius, loc))
		beam(victims, "beam_heavy", 'icons/obj/items/projectiles.dmi', INFINITY, INFINITY)
		RegisterSignal(victims, COMSIG_MOVABLE_MOVED, .proc/check_dist)
		obj_integrity = obj_integrity + intergrity_increase
		if(obj_integrity > max_integrity)
			obj_integrity = max_integrity
/// Humans caught in the aoe_leash will be pulled back if they leave it's radius
/obj/structure/xeno/aoe_leash/proc/check_dist(datum/leash_victims, atom/oldloc)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/victim = leash_victims
	var/distance = get_dist(victim, loc)
	if(distance >= leash_radius)
		victim.Move(oldloc)

// ***************************************
// *********** Spawn Spiderling
// ***************************************

/mob/living/spiderling
	name = "Spiderling"
	flags_pass = PASSXENO
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "spiderling"
	/// Which hive this spiderling belongs to
	var/hivenumber = XENO_HIVE_NORMAL

/mob/living/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/spidermother)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, spidermother)
	hivenumber = spidermother.hivenumber

/mob/living/spiderling/bullet_act(obj/projectile/proj)
	if(proj.ammo.flags_ammo_behavior & AMMO_XENO)
		return FALSE
	return ..()

/mob/living/spiderling/update_stat()
	. = ..()
	if(.)
		return

	if(stat == DEAD)
		return

	if(health <= 0)
		gib()

/datum/action/xeno_action/create_spiderling

/datum/action/xeno_action/create_spiderling/action_activate()
	. = ..()
	new /mob/living/spiderling(owner.loc, owner)


// ***************************************
// *********** Spiderling AI Section
// ***************************************
/datum/ai_behavior/spiderling
	target_distance = 1
	base_action = ESCORTING_ATOM

/datum/ai_behavior/spiderling/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/go_to_target)

/datum/ai_behavior/spiderling/proc/go_to_target(source, mob/living/target)
	SIGNAL_HANDLER
	if(mob_parent.get_xeno_hivenumber() == target.get_xeno_hivenumber())
		return
	change_action(MOVING_TO_ATOM, target)

///Signal handler to try to attack our target
/datum/ai_behavior/spiderling/proc/attack_target(datum/soure, atom/attacked)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = atom_to_walk_to
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	mob_parent.UnarmedAttack(attacked, TRUE)

/datum/ai_behavior/spiderling/look_for_new_state()
	switch(current_action)
		if(MOVING_TO_ATOM)
			if(escorted_atom && get_dist(escorted_atom, mob_parent) > 3)
				change_action(ESCORTING_ATOM, escorted_atom)
				return

/datum/ai_behavior/spiderling/register_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target)
		if(ishuman(atom_to_walk_to))
			RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/ai_behavior.proc/change_action, ESCORTING_ATOM, escorted_atom)
			return

	return ..()

/datum/ai_behavior/spiderling/unregister_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(ishuman(atom_to_walk_to))
			UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH)
			return

	return ..()

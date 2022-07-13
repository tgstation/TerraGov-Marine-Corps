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

/datum/action/xeno_action/activable/burrow/use_ability()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(X, 2 SECONDS, TRUE, X, BUSY_ICON_GENERIC))
		return fail_activate()
	//burrow code goes here

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
	name = "aoe_leash" // change to in character name later
	icon = 'icons/obj/items/projectiles.dmi' // temp ?
	icon_state = "boiler_gas2" // temp
	desc = "Looks very sticky"
	destroy_sound = "alien_resin_break"
	obj_integrity = 5
	max_integrity = 100
	var/leash_radius = 5 // doubles as the range for the leash and how far away ugnas can move before being pulled in
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/// Humans caught get beamed and registered for proc/check_dist
/obj/structure/xeno/aoe_leash/Initialize(mapload, atom/A)
	. = ..()
	for(var/mob/living/carbon/human/victims in view(leash_radius, loc))
		beam(victims, "beam_heavy", 'icons/obj/items/projectiles.dmi', INFINITY, INFINITY)
		RegisterSignal(victims, COMSIG_MOVABLE_MOVED, .proc/check_dist)

/// Humans caught in the aoe_leash will be pulled back if they leave it's radius
/obj/structure/xeno/aoe_leash/proc/check_dist(datum/leash_victims, atom/oldloc)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/victim = leash_victims
	var/distance = get_dist(victim, loc)
	if(distance >= leash_radius)
		victim.Move(oldloc)

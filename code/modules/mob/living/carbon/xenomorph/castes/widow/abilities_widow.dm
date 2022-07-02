// ***************************************
// *********** Web Spit
// ***************************************
/datum/action/xeno_action/activable/web_spit
	name = "webspit"
	ability_name = "webspit"
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
	name = "burrow"
	ability_name = "burrow"
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
// *********** Snare Ball
// ***************************************

/datum/action/xeno_action/activable/snare_ball
	name = "snare_ball"
	ability_name = "snare_ball"
	mechanics_text = " Spit a huge ball of web that snares groups of marines "
	action_icon_state = "scatter_spit" // temporary until I get my own icons
	plasma_cost = 1
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_SNARE_BALL

/datum/action/xeno_action/activable/snare_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(target)
	if(!do_after(X, 1 SECONDS, TRUE, X, BUSY_ICON_DANGER)) // currently here for balance prediction, shooting a 5x5 AoE snare is pretty insane even for T3 imo
		return fail_activate()
	//snare ball spitting goes here

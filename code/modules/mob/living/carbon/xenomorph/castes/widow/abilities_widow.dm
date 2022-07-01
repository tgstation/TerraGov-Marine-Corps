// ***************************************
// *********** Move fast in tight space
// ***************************************
/datum/action/xeno_action/tight
    name = "tight"
    ability_name = "tight"
    mechanics_text = " Move faster in tight spaces"

/datum/action/xeno_action/tight/give_action(mob/M)
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/tight_speed)

/// Signal Handler for increased movement speed in 1x1 spaces
/datum/action/xeno_action/tight/proc/tight_speed(datum/source, atom/oldloc)
	SIGNAL_HANDLER
	var/static/list/dirs_to_check = list(NORTH, EAST, SOUTH, WEST, SOUTHEAST, NORTHWEST, SOUTHWEST, NORTHEAST)
	for(var/direction in dirs_to_check)
		if(!isclosedturf(get_step(owner, direction)))
			continue
		if(!isclosedturf(get_step(owner, REVERSE_DIR(direction))))
			continue
		owner.next_move_slowdown -= WIDOW_SPEED_BONUS
		break

// ***************************************
// *********** Web Spit
// ***************************************
/datum/action/xeno_action/activable/web_spit
	name = "webspit"
	ability_name = "webspit"
	mechanics_text = "We spit a stretchy web at our prey"
	plasma_cost = 1
	cooldown_timer = 5 SECONDS
	keybind_signal = COMSIG_XENOABILITY_WEB_SPIT

/datum/action/xeno_action/activable/web_spit/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner

	var/datum/ammo/xeno/web/web_spit = GLOB.ammo_list[/datum/ammo/xeno/web]

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
	plasma_cost = 1
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_SNARE_BALL


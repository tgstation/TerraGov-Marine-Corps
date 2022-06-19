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
	message_admins("Spitted!")

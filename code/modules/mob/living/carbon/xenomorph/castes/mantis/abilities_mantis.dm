/datum/action/xeno_action/activable/ravage/slow
	///How long is the windup before ravaging
	var/windup_time = 0.5 SECONDS
	cooldown_timer = 30 SECONDS

/datum/action/xeno_action/activable/ravage/slow/use_ability(atom/A)
	if(!do_after(owner, windup_time, FALSE, owner, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, .proc/can_use_ability, A, FALSE, XACT_USE_BUSY)))
		return fail_activate()
	return ..()

/datum/action/xeno_action/activable/ravage/slow/ai_should_use(atom/target)
	. = ..()
	if(!.)
		return
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, .proc/decrease_do_action, target), windup_time)

///Decrease the do_actions of the owner
/datum/action/xeno_action/activable/ravage/slow/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)

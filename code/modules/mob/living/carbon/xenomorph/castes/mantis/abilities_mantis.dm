/datum/action/ability/activable/xeno/ravage/slow
	///How long is the windup before ravaging
	var/windup_time = 0.5 SECONDS
	cooldown_duration = 30 SECONDS

/datum/action/ability/activable/xeno/ravage/slow/use_ability(atom/A)
	if(!do_after(owner, windup_time, IGNORE_HELD_ITEM, owner, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, PROC_REF(can_use_action), FALSE, ABILITY_USE_BUSY)))
		return fail_activate()
	return ..()

/datum/action/ability/activable/xeno/ravage/slow/ai_should_use(atom/target)
	. = ..()
	if(!.)
		return
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, PROC_REF(decrease_do_action), target), windup_time)

///Decrease the do_actions of the owner
/datum/action/ability/activable/xeno/ravage/slow/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)

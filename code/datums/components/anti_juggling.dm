/datum/component/anti_juggling
	/// The next time the gun we just fired will be able to fire
	var/next_fire_time = 0

/datum/component/anti_juggling/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_GUN_COOLDOWN, PROC_REF(check_cooldown))
	RegisterSignal(parent, COMSIG_MOB_GUN_FIRE, PROC_REF(on_fire))

/// Gets called when the mob fires a gun, we get the gun they fired and store the next time it'll be able to fire.
/datum/component/anti_juggling/proc/on_fire(datum/source, obj/item/weapon/gun/fired_gun)
	SIGNAL_HANDLER

	if(!isgun(fired_gun) || fired_gun.master_gun || fired_gun.dual_wield)
		return //Attached guns and guns being dual wielded aren't taken into account.
	next_fire_time = world.time + fired_gun.fire_delay

/// Checks if the cooldown of the gun we previously fired is up.
/datum/component/anti_juggling/proc/check_cooldown(datum/source, obj/item/weapon/gun/cool_gun)
	SIGNAL_HANDLER

	if(cool_gun.master_gun)
		return TRUE
	if(world.time < next_fire_time)
		return FALSE
	return TRUE

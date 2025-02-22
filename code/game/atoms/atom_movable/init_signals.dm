///Returns a list of traits corrosponding to a supplied set of passflags
/proc/get_traits_from_pass_flags(check_flags)
	var/list/trait_list = list()
	if(check_flags & PASS_LOW_STRUCTURE)
		trait_list += TRAIT_PASS_LOW_STRUCTURE
	if(check_flags & PASS_GLASS)
		trait_list += TRAIT_PASS_GLASS
	if(check_flags & PASS_GRILLE)
		trait_list += TRAIT_PASS_GRILLE
	if(check_flags & PASS_MOB)
		trait_list += TRAIT_PASS_MOB
	if(check_flags & PASS_DEFENSIVE_STRUCTURE)
		trait_list += TRAIT_PASS_DEFENSIVE_STRUCTURE
	if(check_flags & PASS_FIRE)
		trait_list += TRAIT_PASS_FIRE
	if(check_flags & PASS_XENO)
		trait_list += TRAIT_PASS_XENO
	if(check_flags & PASS_THROW)
		trait_list += TRAIT_PASS_THROW
	if(check_flags & PASS_PROJECTILE)
		trait_list += TRAIT_PASS_PROJECTILE
	if(check_flags & PASS_AIR)
		trait_list += TRAIT_PASS_AIR
	if(check_flags & PASS_WALKOVER)
		trait_list += TRAIT_PASS_WALKOVER
	if(check_flags & PASS_TANK)
		trait_list += TRAIT_PASS_TANK
	return trait_list

///Called on Initialize(), for the AM to register to relevant signals.
/atom/movable/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_LOW_STRUCTURE), PROC_REF(pass_low_structure_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_LOW_STRUCTURE), PROC_REF(pass_low_structure_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_GLASS), PROC_REF(pass_glass_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_GLASS), PROC_REF(pass_glass_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_GRILLE), PROC_REF(pass_grille_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_GRILLE), PROC_REF(pass_grille_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_MOB), PROC_REF(pass_mob_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_MOB), PROC_REF(pass_mob_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_DEFENSIVE_STRUCTURE), PROC_REF(pass_defensive_structure_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_DEFENSIVE_STRUCTURE), PROC_REF(pass_defensive_structure_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_FIRE), PROC_REF(pass_fire_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_FIRE), PROC_REF(pass_fire_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_XENO), PROC_REF(pass_xeno_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_XENO), PROC_REF(pass_xeno_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_THROW), PROC_REF(pass_throw_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_THROW), PROC_REF(pass_throw_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_PROJECTILE), PROC_REF(pass_projectile_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_PROJECTILE), PROC_REF(pass_projectile_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_AIR), PROC_REF(pass_air_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_AIR), PROC_REF(pass_air_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_WALKOVER), PROC_REF(pass_walkover_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_WALKOVER), PROC_REF(pass_walkover_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PASS_TANK), PROC_REF(trait_pass_tank_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PASS_TANK), PROC_REF(trait_pass_tank_trait_loss))

///Called when PASS_LOW_STRUCTURE is added to the AM
/atom/movable/proc/pass_low_structure_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_LOW_STRUCTURE

///Called when PASS_LOW_STRUCTURE is removed from the AM
/atom/movable/proc/pass_low_structure_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_LOW_STRUCTURE

///Called when PASS_GLASS is added to the AM
/atom/movable/proc/pass_glass_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_GLASS

///Called when PASS_GLASS is removed from the AM
/atom/movable/proc/pass_glass_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_GLASS

///Called when PASS_GRILLE is added to the AM
/atom/movable/proc/pass_grille_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_GRILLE

///Called when PASS_GRILLE is removed from the AM
/atom/movable/proc/pass_grille_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_GRILLE

///Called when PASS_MOB is added to the AM
/atom/movable/proc/pass_mob_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_MOB

///Called when PASS_MOB is removed from the AM
/atom/movable/proc/pass_mob_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_MOB

///Called when PASS_DEFENSIVE_STRUCTURE is added to the AM
/atom/movable/proc/pass_defensive_structure_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_DEFENSIVE_STRUCTURE

///Called when PASS_DEFENSIVE_STRUCTURE is removed from the AM
/atom/movable/proc/pass_defensive_structure_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_DEFENSIVE_STRUCTURE

///Called when PASS_FIRE is added to the AM
/atom/movable/proc/pass_fire_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_FIRE

///Called when PASS_FIRE is removed from the AM
/atom/movable/proc/pass_fire_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_FIRE

///Called when PASS_XENO is added to the AM
/atom/movable/proc/pass_xeno_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_XENO

///Called when PASS_XENO is removed from the AM
/atom/movable/proc/pass_xeno_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_XENO

///Called when PASS_THROW is added to the AM
/atom/movable/proc/pass_throw_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_THROW

///Called when PASS_THROW is removed from the AM
/atom/movable/proc/pass_throw_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_THROW

///Called when TRAIT_PASS_LOW_STRUCTURE is added to the AM
/atom/movable/proc/pass_projectile_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_PROJECTILE

///Called when PASS_PROJECTILE is removed from the AM
/atom/movable/proc/pass_projectile_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_PROJECTILE

///Called when PASS_AIR is added to the AM
/atom/movable/proc/pass_air_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_AIR

///Called when PASS_AIR is removed from the AM
/atom/movable/proc/pass_air_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_AIR

///Called when PASS_WALKOVER is added to the AM
/atom/movable/proc/pass_walkover_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_WALKOVER

///Called when PASS_WALKOVER is removed from the AM
/atom/movable/proc/pass_walkover_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_WALKOVER

///Called when PASS_TANK is added to the AM
/atom/movable/proc/trait_pass_tank_trait_gain(datum/source)
	SIGNAL_HANDLER
	pass_flags |= PASS_TANK

///Called when PASS_TANK is removed from the AM
/atom/movable/proc/trait_pass_tank_trait_loss(datum/source)
	SIGNAL_HANDLER
	pass_flags &= ~PASS_TANK

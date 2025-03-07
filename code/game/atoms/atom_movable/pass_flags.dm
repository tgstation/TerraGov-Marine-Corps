///Correctly sets pass_flags with their source
/atom/movable/proc/add_pass_flags(new_pass_flags, trait_source)
	add_traits(get_traits_from_pass_flags(new_pass_flags), trait_source)
	pass_flags |= new_pass_flags

///Correctly removes sources and pass_flags as required
/atom/movable/proc/remove_pass_flags(old_pass_flags, trait_source)
	old_pass_flags = old_pass_flags & pass_flags
	if(!old_pass_flags)
		return
	var/list/trait_list = get_traits_from_pass_flags(old_pass_flags)
	remove_traits(trait_list, trait_source)

	for(var/trait in trait_list)
		if(HAS_TRAIT(src, trait))
			continue
		pass_flags &= ~(GLOB.traits_to_pass_flags[trait])

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

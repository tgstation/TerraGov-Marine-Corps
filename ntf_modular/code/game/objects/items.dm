/obj/item/proc/check_space_to_deploy(mob/user, turf/location, direction, obj/deploy_type)
	if((item_flags & DEPLOY_ON_INITIALIZE) && (item_flags & DEPLOYED_NO_PICKUP))
		return TRUE
	if(location.density)
		return FALSE
	if(deploy_type.atom_flags & ON_BORDER)
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
				if(!(object.atom_flags & ON_BORDER))
					continue
				if(object.dir != direction)
					continue
			return FALSE
	else
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
			return FALSE
	return TRUE

/obj/structure/barricade/solid/deployable/proc/check_space_to_deploy(mob/user, turf/location, direction, obj/deploy_type)
	if((item_flags & DEPLOY_ON_INITIALIZE) && (item_flags & DEPLOYED_NO_PICKUP))
		return TRUE
	if(location.density)
		return FALSE
	if(deploy_type.atom_flags & ON_BORDER)
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
				if(!(object.atom_flags & ON_BORDER))
					continue
				if(object.dir != direction)
					continue
			return FALSE
	else
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
			return FALSE
	return TRUE

/obj/vehicle/unmanned/deployable/proc/check_space_to_deploy(mob/user, turf/location, direction, obj/deploy_type)
	if((item_flags & DEPLOY_ON_INITIALIZE) && (item_flags & DEPLOYED_NO_PICKUP))
		return TRUE
	if(location.density)
		return FALSE
	if(deploy_type.atom_flags & ON_BORDER)
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
				if(!(object.atom_flags & ON_BORDER))
					continue
				if(object.dir != direction)
					continue
			return FALSE
	else
		for(var/obj/object in location)
			if(!(object.obj_flags & BLOCKS_CONSTRUCTION))
				if(!object.density)
					continue
			return FALSE
	return TRUE

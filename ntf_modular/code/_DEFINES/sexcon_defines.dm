GLOBAL_LIST_INIT(sex_actions, build_sex_actions())

/// Returns whether a type is an abstract type.
/proc/is_abstract(datum/datumussy)
	var/datum/sex_action/datum_type = datumussy
	return (initial(datum_type.abstract_type) == datum_type)

/proc/build_sex_actions()
	. = list()
	for(var/path in typesof(/datum/sex_action))
		if(is_abstract(path))
			continue
		.[path] = new path()
	return .

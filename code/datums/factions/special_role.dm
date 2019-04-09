#define SPECIAL_ROLE_UNLIMITED -1
#define SPECIAL_ROLE_DYNAMIC -2
#define SPECIAL_ROLE_UNIQUE -3

/datum/special_role
	var/name = ""
	var/role_limit = SPECIAL_ROLE_UNLIMITED
	var/current_dynamic_limit
	var/assigned_role // matches mind.assigned role for now

/datum/special_role/proc/get_limit()
	switch(role_limit)
		if(SPECIAL_ROLE_UNIQUE)
			return 1
		if(SPECIAL_ROLE_UNLIMITED)
			return INFINITY
		if(SPECIAL_ROLE_DYNAMIC)
			return current_dynamic_limit
		else
			return role_limit

/datum/special_role/proc/update_dynamic_limit(playercount, squadcount)
	return

	
/datum/squad
	var/name = ""
	var/list/has_special_roles = list()
	var/datum/special_role/default_role

	var/datum/faction/faction
	var/ideal_size

	var/tracking_target

	var/list/special_roles = list()
	var/list/special_roles_by_assigned_role = list() // datums sorted by assigned_role

	var/radio_freq

/datum/squad/New(datum/faction/F, name)
	. = ..()
	faction = F
	var/list/sr = list()
	for(var/t in has_special_roles)
		var/datum/special_role/S = t
		special_roles[t] = list()
		S = new t
		sr[t] = S
		special_roles_by_assigned_role[S.assigned_role] = S
	has_special_roles = sr
	src.name = name

/datum/squad/proc/can_be_added_to_squad(mob/living/L)
	if(!L?.mind?.assigned_role)
		CRASH("trying to add a mob with no assigned role")
	return can_be_added_by_assigned_role(L.mind.assigned_role)

/datum/squad/proc/can_be_added_by_assigned_role(assigned_role)
	var/datum/special_role/SR = special_roles_by_assigned_role[assigned_role]
	if(!SR)
		return FALSE // not a role that can be in this squad
	if(SR.get_limit() >= length(special_roles[SR.type]))
		return FALSE // at or over the limit
	return TRUE

/datum/squad/proc/add_to_squad(mob/living/L)
	var/datum/special_role/SR = special_roles_by_assigned_role[L.mind.assigned_role]
	special_roles[SR.type] += L
	L.mind.assigned_squad = src
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.assigned_squad = src
	return TRUE

/datum/squad/proc/remove_from_squad(mob/living/L)
	var/datum/special_role/SR = special_roles_by_assigned_role[L.mind.assigned_role]
	if(!SR)
		return FALSE
	special_roles[SR.type] -= L
	L.mind.assigned_squad = null
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.assigned_squad = null
	return TRUE

/datum/squad/proc/get_tracking_object() // return a /mob or /turf or /obj based on the /datum/squad/var/tracking_target
	if(istype(tracking_target, /datum/special_role))
		if(length(special_roles[tracking_target]))
			return special_roles[tracking_target][1]
		return null
	return tracking_target

/datum/squad/proc/get_total_members()
	. = 0
	for(var/t in special_roles)
		. += length(special_roles[t])

/datum/squad/proc/update_dynamic_limit(playercount)
	var/total = get_total_members()
	for(var/t in has_special_roles)
		var/datum/special_role/S = has_special_roles[t]
		S.update_dynamic_limit(playercount, total)


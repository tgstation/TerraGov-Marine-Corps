GLOBAL_LIST(admin_objective_list) //Prefilled admin assignable objective list

/datum/objective
	var/datum/mind/owner //The primary owner of the objective.
	var/name = "generic objective" //Name for admin prompts
	var/explanation_text = "Nothing" //What that person is supposed to do.
	///name used in printing this objective (Objective #1)
	var/objective_name = "Objective"
	var/team_explanation_text //For when there are multiple owners.
	var/datum/mind/target = null //If they are focused on a particular person.
	var/target_amount = 0 //If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = FALSE //currently only used for custom objectives.
	///can this be granted by admins?
	var/admin_grantable = FALSE

/datum/objective/proc/get_owners() // Combine owner and team into a single list.
	. = list()
	if(owner)
		. += owner

/datum/objective/New(text)
	if(text)
		explanation_text = text

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	return ..()

/datum/objective/proc/admin_edit(mob/admin)
	return

//Shared by few objective types
/datum/objective/proc/admin_simple_target_pick(mob/admin)
	var/list/possible_targets = list()
	var/def_value
	for(var/datum/mind/possible_target in SSticker.minds)
		if ((possible_target != src) && ishuman(possible_target.current))
			possible_targets += possible_target.current

	possible_targets = list("Free objective", "Random") + sort_names(possible_targets)


	if(target?.current)
		def_value = target.current

	var/mob/new_target = input(admin,"Select target:", "Objective target", def_value) as null|anything in possible_targets
	if (!new_target)
		return

	if (new_target == "Free objective")
		target = null
	else if (new_target == "Random")
		find_target()
	else
		target = new_target.mind

/**
 * Checks if the passed mind is considered "escaped".
 *
 * Escaped mobs are used to check certain antag objectives / results.
 *
 * Escaped includes minds with alive, non-exiled mobs generally.
 */

/* /proc/considered_escaped(datum/mind/escapee)
	if(!considered_alive(escapee))
		return FALSE
	if(considered_exiled(escapee))
		return FALSE
	if(escapee.force_escaped)
		return TRUE
	if(SSticker.force_ending || GLOB.station_was_nuked) // Just let them win.
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/area/current_area = get_area(escapee.current)
	if(!current_area || istype(current_area, /area/shuttle/escape/brig)) // Fails if they are in the shuttle brig
		return FALSE
	var/turf/current_turf = get_turf(escapee.current)
	return current_turf.onCentCom() || current_turf.onSyndieBase()
*/

/datum/objective/proc/update_explanation_text()
	if(team_explanation_text && LAZYLEN(get_owners()) > 1)
		explanation_text = team_explanation_text

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_unique_objective(possible_target, dupe_search_range)
	if(!islist(dupe_search_range))
		stack_trace("Non-list passed as duplicate objective search range")
		dupe_search_range = list(dupe_search_range)

	for(var/A in dupe_search_range)
		var/list/objectives_to_compare
		if(istype(A,/datum/mind))
			var/datum/mind/M = A
			objectives_to_compare = M.get_all_objectives()
		else if(istype(A,/datum/antagonist))
			var/datum/antagonist/G = A
			objectives_to_compare = G.objectives
		for(var/datum/objective/O in objectives_to_compare)
			if(istype(O, type) && O.get_target() == possible_target)
				return FALSE
	return TRUE

/datum/objective/proc/get_target()
	return target

//dupe_search_range is a list of antag datums / minds / teams
/datum/objective/proc/find_target(dupe_search_range, list/blacklist)
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	for(var/datum/mind/possible_target in GLOB.alive_human_list)
//		var/target_area = get_area(possible_target.current)
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue
		if(!is_unique_objective(possible_target,dupe_search_range))
			continue
		if(possible_target in blacklist)
			continue
		possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/I in all_possible_targets)
//			var/datum/mind/PT = I
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	return target

/datum/objective/proc/find_target_by_role(role, role_type=FALSE,invert=FALSE)//Option sets either to check assigned role or special role. Default to assigned., invert inverts the check, eg: "Don't choose a Ling"
	var/list/datum/mind/owners = get_owners()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in GLOB.alive_human_list)
		if(!(possible_target in owners) && ishuman(possible_target.current))
			var/is_role = FALSE
			if(possible_target.assigned_role == role)
				is_role = TRUE

			if(invert)
				if(is_role)
					continue
				possible_targets += possible_target
				break
			else if(is_role)
				possible_targets += possible_target
				break
	if(length(possible_targets))
		target = pick(possible_targets)
	update_explanation_text()
	return target

//Created by admin tools
/datum/objective/custom
	name = "custom"
	admin_grantable = TRUE

/datum/objective/custom/admin_edit(mob/admin)
	var/expl = stripped_input(admin, "Custom objective:", "Objective", explanation_text)
	if(expl)
		explanation_text = expl

//Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	GLOB.admin_objective_list = list()

	var/list/allowed_types = sort_list(subtypesof(/datum/objective), GLOBAL_PROC_REF(cmp_typepaths_asc))

	for(var/datum/objective/goal as anything in allowed_types)
		if(!initial(goal.admin_grantable))
			continue
		GLOB.admin_objective_list[initial(goal.name)] = goal

/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/escape/check_completion()
	// Require all owners escape safely.
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		var/turf/current_turf = get_turf(M)
		if(!is_mainship_level(current_turf))
			return FALSE
	return TRUE

/datum/objective/survive
	name = "survive"
	explanation_text = "Survive until the end of the operation."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/survive/check_completion()
	// Require all owners escape safely.
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_alive(M))
			return FALSE
	return TRUE

/datum/objective/maroon
	name = "maroon"
	var/target_role_type=FALSE

/datum/objective/maroon/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/maroon/check_completion()
	var/turf/current_turf = get_turf(target)
	return !target || !isliving(target) || (!is_mainship_level(current_turf) && (SSticker.mode.round_finished == MODE_INFESTATION_X_MINOR||MODE_INFESTATION_X_MINOR))

/datum/objective/maroon/update_explanation_text()
	var/mob/living/livingtarget = target.current
	if(target && target.current)
		explanation_text = "Strand [livingtarget.name], the [livingtarget.job], on the planet."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/assassinate
	name = "assasinate"
	var/target_role_type=FALSE

/datum/objective/assassinate/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/assassinate/check_completion()
	return completed || (!considered_alive(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	var/mob/living/livingtarget = target.current
	if(target && target.current)
		explanation_text = "Ensure [livingtarget.name], the [livingtarget.job] does not survive the operation."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

GLOBAL_LIST_EMPTY(possible_items)
/datum/objective/steal
	name = "steal"
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/New()
	..()
	if(!GLOB.possible_items.len)//Only need to fill the list when it's needed.
		for(var/I in subtypesof(/datum/objective_item/steal))
			new I

/datum/objective/steal/find_target(dupe_search_range)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	check_items:
		for(var/datum/objective_item/possible_item in GLOB.possible_items)
			if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
				continue
			for(var/datum/mind/M in owners)
				if(M.current.mind.assigned_role in possible_item.excludefromjob)
					continue check_items
			approved_targets += possible_item
	if (length(approved_targets))
		return set_target(pick(approved_targets))
	return set_target(null)

/datum/objective/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item
		steal_target = targetinfo.targetitem
		explanation_text = "Retrieve [targetinfo.name]"
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/steal/admin_edit(mob/admin)
	var/list/possible_items_all = GLOB.possible_items
	var/new_target = input(admin,"Select target:", "Objective target", steal_target) as null|anything in sortNames(possible_items_all)+"custom"
	if (!new_target)
		return

	if (new_target == "custom") //Can set custom items.
		var/custom_path = input(admin,"Search for target item type:","Type") as null|text
		if (!custom_path)
			return
		var/obj/item/custom_target = pick_closest_path(custom_path, make_types_fancy(subtypesof(/obj/item)))
		var/custom_name = initial(custom_target.name)
		custom_name = stripped_input(admin,"Enter target name:", "Objective target", custom_name)
		if (!custom_name)
			return
		steal_target = custom_target
		explanation_text = "Steal [custom_name]."

	else
		set_target(new_target)

/datum/objective/steal/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!steal_target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

		for(var/obj/I in all_items) //Check for items
			if(istype(I, steal_target))
				return TRUE
	return FALSE

/datum/objective/loseoperation
	name = "lose operation"
	explanation_text = "Make sure the operation is a failure, do not get your hands dirty."
	team_explanation_text = "Make sure the operation is a failure, do not get your hands dirty."

/datum/objective/loseoperation/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(SSticker.mode.round_finished == MODE_INFESTATION_M_MINOR||MODE_INFESTATION_M_MINOR)
			return TRUE
		else
			return FALSE

/datum/objective/winoperation
	name = "win operation"
	explanation_text = "Make sure the operation is a success."
	team_explanation_text = "Make sure the operation is a success."

/datum/objective/winoperation/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(SSticker.mode.round_finished == MODE_INFESTATION_M_MINOR||MODE_INFESTATION_M_MINOR)
			return TRUE
		else
			return FALSE

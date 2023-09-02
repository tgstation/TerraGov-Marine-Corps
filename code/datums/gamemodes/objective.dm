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
	///if true during target selection we will try to avoid players already targeted by another objective
	var/avoid_double_target = FALSE

/datum/objective/proc/get_owners() // Combine owner and team into a single list.
	. = list()
	if(owner)
		. += owner

/datum/objective/New(text)
	if(text)
		explanation_text = text
	post_setup()

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	return ..()

/datum/objective/proc/admin_edit(mob/admin)
	return

/datum/objective/proc/post_setup()
	return

/datum/objective/proc/handle_removal() //called when an admin removes objective from a player
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
		if(!target)
			target = owner
	else
		target = new_target.mind

	update_explanation_text()

/**
 * Checks if the passed mind is considered "escaped".
 *
 * Escaped mobs are used to check certain antag objectives / results.
 *
 * Escaped includes minds with alive, non-exiled mobs generally.
 */

/proc/considered_escaped(datum/mind/escapee, admin_override = FALSE)
	if(!considered_alive(escapee))
		return FALSE
	//if(SSticker.force_ending) // Just let them win.
		//return TRUE
	var/area/current_area = get_area(escapee.current)
	var/list/allowed_areas = list(
		/area/shuttle/ert/pmc,
		/area/shuttle/big_ert,
		/area/shuttle/ert/ufo,
		/area/shuttle/ert/upp,
		/area/shuttle/pod_1,
		/area/shuttle/pod_2,
		/area/shuttle/pod_3,
		/area/shuttle/pod_4,
		/area/shuttle/escape_pod,
	)
	if(admin_override)
		if(is_mainship_level(escapee.current.z))
			return FALSE
		if(current_area.type in allowed_areas) // Ship only
			return TRUE
	if(!current_area)
		return FALSE
	if(!istype(current_area, /area/shuttle/escape_pod)) //have to escape in a pod or escape shuttle, at least for the time being
		return FALSE
	if(!HAS_TRAIT(escapee.current, TRAIT_HAS_ESCAPED))
		return FALSE
	return TRUE



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
/datum/objective/proc/find_target(dupe_search_range, blacklist)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	for(var/datum/mind/possible_target in GLOB.alive_human_list)
		if(!(possible_target in owners) && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && is_unique_objective(possible_target,dupe_search_range))
			if (!(possible_target in blacklist))
				possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		if(!length(possible_targets))
			possible_targets = all_possible_targets
	if(length(possible_targets) > 0)
		target = pick(possible_targets)
	if(!target)
		var/mob/living/M
		for(M in GLOB.mob_list)
			var/datum/mind/mobmind = M.mind
			if(mobmind == null)
				continue
			if(HAS_TRAIT(mobmind.current, TRAIT_HAS_BEEN_TARGETED) && avoid_double_target)
				continue
			else
				target = mobmind
				if(!HAS_TRAIT(mobmind.current, TRAIT_HAS_BEEN_TARGETED))
					ADD_TRAIT(mobmind.current, TRAIT_HAS_BEEN_TARGETED, TRAIT_HAS_BEEN_TARGETED)
	update_explanation_text()
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

//Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	GLOB.admin_objective_list = list()

	var/list/allowed_types = sortList(list(
		/datum/objective/assassinate,
		/datum/objective/maroon,
		/datum/objective/steal,
		/datum/objective/survive,
		/datum/objective/escape,
		/datum/objective/protect,
		/datum/objective/winoperation,
		/datum/objective/loseoperation,
		/datum/objective/escape_with,
		/datum/objective/gather_cash,
		/datum/objective/kill_zombies,
		/datum/objective/seize_area,
		/datum/objective/kill_other_factions,
		/datum/objective/custom,
	),/proc/cmp_typepaths_asc)

	for(var/T in allowed_types)
		var/datum/objective/X = T
		GLOB.admin_objective_list[initial(X.name)] = T


//Created by admin tools
/datum/objective/custom
	name = "custom"
	admin_grantable = TRUE

/datum/objective/custom/admin_edit(mob/admin)
	var/expl = stripped_input(admin, "Custom objective:", "Objective", explanation_text)
	if(expl)
		explanation_text = expl

/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on a shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."
	///passed to considered_escaped, if true allows greentext by simply being on a shuttle not on ship level by round end
	var/admin_event = FALSE

/datum/objective/escape/check_completion()
	if(!considered_escaped(owner, admin_event))
		return FALSE
	return TRUE

/datum/objective/escape/find_target(dupe_search_range, blacklist)
	return

/datum/objective/escape/admin_edit(mob/admin)
	if(tgui_alert(admin, "Relax escape requirements (recommended for admin events)?", "Continue?", list("Yes", "No")) != "No")
		admin_event = TRUE

/datum/objective/escape_with
	name = "kidnap"
	explanation_text = "Have both you and your target escape alive and unharmed on a shuttle or pod."
	team_explanation_text = "Have both you and your target escape alive and unharmed on a shuttle or pod."
	avoid_double_target = TRUE
	///passed to considered_escaped, if true allows greentext by simply being on a shuttle not on ship level by round end
	var/admin_event = FALSE

/datum/objective/escape_with/check_completion()
	if(!considered_escaped(owner, admin_event))
		return FALSE
	if(!considered_escaped(target, admin_event))
		return FALSE
	for(var/mob/M in range(4)) //enough to cover the entirety of an escape shuttle
		if(M.mind == null)
			continue
		if(M.mind == target)
			return TRUE

/datum/objective/escape_with/update_explanation_text()
	if(target == null)
		explanation_text = "Escape with somebody on a shuttle." //placeholder in case we can't find a real player
		return
	var/mob/living/livingtarget = target.current
	if(target?.current)
		explanation_text = "Escape with [livingtarget.name], the [livingtarget.job.title], on a shuttle without being in custody."
	else
		explanation_text = "Free Objective"

/datum/objective/escape_with/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
	if(tgui_alert(admin, "Relax escape requirements (recommended for admin events)?", "Continue?", list("Yes", "No")) != "No")
		admin_event = TRUE

/datum/objective/survive
	name = "survive"
	explanation_text = "Survive until the end of the operation."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/survive/check_completion()
	if(!considered_alive(owner))
		return FALSE
	return TRUE

/datum/objective/maroon
	name = "maroon"
	var/target_role_type = FALSE
	avoid_double_target = TRUE

/datum/objective/maroon/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/maroon/check_completion()
	var/turf/current_turf = get_turf(target.current)
	if(!target)
		return
	if(!isliving(target.current))
		return
	if(is_mainship_level(current_turf.z))
		return
	return TRUE

/datum/objective/maroon/update_explanation_text()
	if(target == null)
		explanation_text = "Strand somebody on the planet." //placeholder in case we can't find a real player
		return
	var/mob/living/livingtarget = target.current
	if(target?.current)
		explanation_text = "Make sure [livingtarget.name], the [livingtarget.job.title], is planetside at the end of the operation."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/assassinate
	name = "assassinate"
	var/target_role_type = FALSE
	avoid_double_target = TRUE

/datum/objective/assassinate/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/assassinate/check_completion()
	if(target == null)
		return FALSE
	return completed || (!considered_alive(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target == null)
		explanation_text = "Kill somebody." //placeholder in case we can't find a real player
		return
	var/mob/living/livingtarget = target.current
	if(target?.current)
		explanation_text = "Ensure [livingtarget.name], the [livingtarget.job.title] does not survive the operation."
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
	if(!length(GLOB.possible_items))//Only need to fill the list when it's needed.
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
	if(SSticker.mode.round_finished == MODE_INFESTATION_X_MINOR)
		return TRUE
	else if(SSticker.mode.round_finished == MODE_INFESTATION_X_MAJOR)
		return TRUE
	else
		return FALSE

/datum/objective/winoperation
	name = "win operation"
	explanation_text = "Make sure the operation is a success."
	team_explanation_text = "Make sure the operation is a success."

/datum/objective/winoperation/check_completion()
	if(SSticker.mode.round_finished == MODE_INFESTATION_M_MINOR)
		return TRUE
	else if(SSticker.mode.round_finished == MODE_INFESTATION_M_MAJOR)
		return TRUE
	else
		return FALSE

/datum/objective/protect//The opposite of killing a dude.
	name = "protect"
	explanation_text = "Keep target from dying."
	team_explanation_text = "Keep target from dying."
	avoid_double_target = TRUE

/datum/objective/protect/check_completion()
	//Protect will always suceed when someone suicides
	return !target || considered_alive(target)

/datum/objective/protect/update_explanation_text()
	..()
	if(target?.current)
		var/mob/living/livingtarget = target.current
		explanation_text = "Protect [livingtarget.name], the [livingtarget.job.title]."
	else
		explanation_text = "Free Objective"

/datum/objective/protect/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/gather_cash//The opposite of killing a dude.
	name = "gather cash"
	explanation_text = "Gather credits to repay your debt."
	team_explanation_text = "Gather credits to repay your debt."
	var/neededcash = 1500

/datum/objective/gather_cash/check_completion()
	var/currentcash = 0
	var/list/all_items = owner.current.GetAllContents()
	for(var/obj/I in all_items) //Check and count cash
		if(istype(I, /obj/item/spacecash/c1))
			currentcash += 1
		if(istype(I, /obj/item/spacecash/c10))
			currentcash += 10
		if(istype(I, /obj/item/spacecash/c20))
			currentcash += 20
		if(istype(I, /obj/item/spacecash/c50))
			currentcash += 50
		if(istype(I, /obj/item/spacecash/c100))
			currentcash += 100
		if(istype(I, /obj/item/spacecash/c200))
			currentcash += 200
		if(istype(I, /obj/item/spacecash/c500))
			currentcash += 500
	if(currentcash >= neededcash)
		return TRUE
	return FALSE

/datum/objective/gather_cash/update_explanation_text()
	..()
	if(neededcash)
		explanation_text = "Gather at least [neededcash] credits."
	else
		explanation_text = "Free Objective"

/datum/objective/gather_cash/admin_edit(mob/admin)
	neededcash = input(admin,"Set the amount of cash needed to complete this objective", neededcash) as num
	update_explanation_text()

/datum/objective/kill_zombies
	name = "kill all zombies"
	explanation_text = "Eliminate all zombies and keep them from rising again. Rip and tear!"
	team_explanation_text = "Eliminate all zombies. Rip and tear!"

/datum/objective/kill_zombies/check_completion()
	for(var/mob/living/carbon/human/affectedmob in GLOB.mob_list)
		if(iszombie(affectedmob))
			for(var/datum/internal_organ/affectedorgan in affectedmob.internal_organs)
				if(affectedorgan == affectedmob.internal_organs_by_name["heart"]) //zombies with hearts aren't truly dead
					return FALSE
	return TRUE

/datum/objective/seize_area
	name = "control area"
	explanation_text = "Hold area and defend against all intruders."
	var/area/defendedarea

/datum/objective/seize_area/admin_edit(mob/admin)
	if(tgui_alert(admin, "Use the area we are currently in?", "Continue?", list("Yes", "No")) != "No")
		defendedarea = get_area(admin)
	else
		var/area/new_target = input(admin,"Select target:", "Objective target") as null|anything in GLOB.sorted_areas
		defendedarea = new_target
	update_explanation_text()

/datum/objective/seize_area/check_completion()
	if(!owner.current.faction)
		owner.current.faction = FACTION_NEUTRAL //fallback in case factionless mobs get this objective
	var/currentfaction = owner.current.faction
	for(var/mob/living/carbon/human/targethuman in GLOB.mob_list)
		if(iszombie(owner.current)) //zombies don't care about factions
			if(locate(/mob/living/carbon/xenomorph) in defendedarea)
				return FALSE
			for(targethuman in defendedarea)
				if(targethuman.stat == DEAD)
					continue
				if(!iszombie(targethuman))
					return FALSE
			return TRUE
		for(targethuman in defendedarea)
			if(iszombie(targethuman)) //zombies count as hostile forces to everyone but zombies
				for(var/datum/internal_organ/affectedorgan in targethuman.internal_organs)
					if(affectedorgan == targethuman.internal_organs_by_name["heart"])
						return FALSE
			if(targethuman.stat == DEAD) //we don't care about dead humans
				continue
			if(isxeno(owner.current))
				if(ishuman(targethuman))
					return FALSE
			if(!targethuman.faction) //consider them hostile anyway
				return FALSE
			if(targethuman.faction != currentfaction)
				return FALSE
	if(locate(/mob/living/carbon/xenomorph) in defendedarea)
		return FALSE
	return TRUE

/datum/objective/seize_area/update_explanation_text()
	..()
	if(defendedarea)
		explanation_text = "Defend [defendedarea] from any hostile forces."
	else
		explanation_text = "Free Objective"

/datum/objective/kill_other_factions
	name = "kill other faction"
	explanation_text = "Eliminate all other factions."
	team_explanation_text = "Eliminate all other factions."

/datum/objective/kill_other_factions/check_completion()
	var/currentfaction = owner.current.faction
	for(var/mob/living/carbon/human/affectedmob in GLOB.mob_list)
		if(affectedmob.stat == DEAD) //we don't care about dead humans
			continue
		else if(affectedmob.faction != currentfaction)
			return FALSE
	return TRUE

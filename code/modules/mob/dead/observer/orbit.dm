/datum/orbit_menu
	var/auto_observe = FALSE
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Orbit")
		ui.open()

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("orbit")
			var/ref = params["ref"]
			var/atom/movable/poi = locate(ref) in GLOB.mob_list
			if (poi == null)
				. = TRUE
				return
			owner.ManualFollow(poi)
			owner.reset_perspective(null)
			if(auto_observe)
				owner.do_observe(poi)
			. = TRUE
		if("refresh")
			update_static_data()
			. = TRUE
		if("toggle_observe")
			auto_observe = !auto_observe
			if(auto_observe && !QDELETED(owner.orbiting.parent))
				owner.do_observe(owner.orbiting.parent)
			else
				owner.reset_perspective(null)



/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()
	data["auto_observe"] = auto_observe
	return data

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/humans = list()
	var/list/marines = list()
	var/list/survivors = list()
	var/list/xenos = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/is_admin = check_other_rights(user.client, R_ADMIN, FALSE)
	var/list/pois = getpois(skip_mindless = !is_admin, specify_dead_role = FALSE)
	for(var/name in pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = pois[name]

		serialized["ref"] = REF(poi)

		var/mob/M = poi
		if(!istype(M))
			misc += list(serialized)
			continue

		var/number_of_orbiters = length(M.get_all_orbiters())
		if(number_of_orbiters)
			serialized["orbiters"] = number_of_orbiters

		if(isobserver(M))
			ghosts += list(serialized)
		else if(M.stat == DEAD)
			dead += list(serialized)
		else if(M.mind == null)
			npcs += list(serialized)
		else if(isxeno(M))
			xenos += list(serialized)
		else if(isAI(M))
			humans += list(serialized)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = poi
			if(ismarinejob(H.job))
				marines += list(serialized)
			else if (issurvivorjob(H.job))
				survivors += list(serialized)
			else
				humans += list(serialized)

	data["humans"] = humans
	data["marines"] = marines
	data["survivors"] = survivors
	data["xenos"] = xenos
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs

	return data

/datum/orbit_menu/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)

/datum/orbit_menu
	/// Determines whether the orbit UI displays the hud on observable click.
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
			update_static_data(usr, ui)
			. = TRUE
		if("toggle_observe")
			auto_observe = !auto_observe
			if(auto_observe && !QDELETED(owner.orbiting.parent))
				owner.do_observe(owner.orbiting.parent)
			else
				owner.reset_perspective(null)
			. = TRUE

/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()
	data["auto_observe"] = auto_observe
	return data

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/humans = list()
	var/list/marines = list()
	var/list/som = list()
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
		serialized["full_name"] = name

		var/poi = pois[name]

		serialized["ref"] = REF(poi)

		var/mob/mob_poi = poi

		if(!istype(mob_poi))
			misc += list(serialized)
			continue

		if(isobserver(mob_poi))
			ghosts += list(serialized)
			continue

		if(mob_poi.stat == DEAD)
			dead += list(serialized)
			continue

		if(mob_poi.mind == null)
			npcs += list(serialized)
			continue

		var/number_of_orbiters = length(mob_poi.get_all_orbiters())
		if(number_of_orbiters)
			serialized["orbiters"] = number_of_orbiters

		var/mob/living/player = mob_poi
		serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)

		if(isxeno(mob_poi))
			var/mob/living/carbon/xenomorph/xeno = poi
			if(xeno.xeno_caste)
				var/datum/xeno_caste/caste = xeno.xeno_caste
				serialized["caste"] = caste.display_name
				serialized["icon"] = caste.minimap_icon
			if(!isnum(xeno.nicknumber))
				serialized["nickname"] = xeno.nicknumber
			xenos += list(serialized)
			continue

		if(isAI(mob_poi))
			serialized["job"] = "AI"
			humans += list(serialized)
			continue

		if(ishuman(mob_poi))
			var/mob/living/carbon/human/human = poi
			var/datum/job/job = human.job
			serialized["nickname"] = human.real_name

			if(ismarinejob(human.job))
				if(human.assigned_squad)
					serialized["icon"] = lowertext(human.assigned_squad.name) + "_" + job.minimap_icon
					serialized["job"] = human.assigned_squad.name + " " + job.title
				marines += list(serialized)
				continue

			serialized["icon"] = job.minimap_icon
			serialized["job"] = job.title

			if(issommarinejob(human.job))
				som += list(serialized)
				continue

			if(issurvivorjob(human.job))
				survivors += list(serialized)
				continue

			humans += list(serialized)

	data["dead"] = dead
	data["ghosts"] = ghosts
	data["humans"] = humans
	data["icons"] = GLOB.minimap_icons
	data["misc"] = misc
	data["npcs"] = npcs
	data["marines"] = marines
	data["som"] = som
	data["survivors"] = survivors
	data["xenos"] = xenos

	return data

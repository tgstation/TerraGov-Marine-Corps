/datum/orbit_menu
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.observer_state)
	if (!ui)
		ui = new(user, src, ui_key, "Orbit", "Orbit", 350, 700, master_ui, state)
		ui.open()

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	if (action == "orbit")
		var/is_admin = check_other_rights(owner.client, R_ADMIN, FALSE)
		var/list/pois = getpois(skip_mindless = !is_admin)
		var/atom/movable/poi = pois[params["name"]]
		if (poi != null)
			owner.ManualFollow(poi)
			ui.close()

/datum/orbit_menu/ui_data(mob/user)
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
	var/list/pois = getpois(skip_mindless = !is_admin)
	for (var/name in pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = pois[name]

		var/mob/M = poi
		if (!istype(M))
			misc += list(serialized)
			continue

		if (isobserver(M))
			ghosts += list(serialized)
		else if (M.stat == DEAD)
			dead += list(serialized)
		else if (M.mind == null)
			npcs += list(serialized)
		else
			var/number_of_orbiters = M.orbiters?.orbiters?.len
			if (number_of_orbiters)
				serialized["orbiters"] = number_of_orbiters

			if (isxeno(poi))
				xenos += list(serialized)
			else if(ishuman(poi))
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

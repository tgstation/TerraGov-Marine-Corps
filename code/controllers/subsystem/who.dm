SUBSYSTEM_DEF(who)
	name = "Who"
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVELS_DEFAULT|RUNLEVEL_LOBBY
	wait = 5 SECONDS

	var/datum/player_list/who = new
	var/datum/player_list/staff/staff_who = new

/datum/controller/subsystem/who/fire(resumed = TRUE)
	who.update_data()
	staff_who.update_data()

//datum
/datum/player_list
	var/tgui_name = "Who"
	var/tgui_interface_name = "Who"
	var/list/mobs_ckey = list()
	var/list/list_data = list()

/datum/player_list/proc/update_data()
	var/list/new_list_data = list()
	var/list/new_mobs_ckey = list()
	var/list/additiona_data = list(
		"lobby" = 0,
		"observers" = 0,
		"admin_observers" = 0,
		"zombie" = 0,
		"yautja" = 0,
		"infected_preds" = 0,
		"humans" = 0,
		"infected_humans" = 0,
		"tgmc" = 0,
		"marines" = 0,
		"som" = 0,
		"xenomorphs" = 0,
	)
	new_list_data["additional_info"] = list()

	for(var/client/client in GLOB.clients)
		new_list_data["all_clients"]++
		var/list/client_payload = list()
		client_payload["ckey"] = "[client.key]"
		client_payload["text"] = "[client.key]"
		client_payload["ckey_color"] = "white"
		var/mob/client_mob = client.mob
		new_mobs_ckey[client.key] = client_mob
		if(client_mob)
			if(istype(client_mob, /mob/new_player))
				client_payload["text"] += " - in Lobby"
				additiona_data["lobby"]++
				new_list_data["total_players"] += list(client_payload)
				continue

			if(isobserver(client_mob))
				client_payload["text"] += " - Playing as [client_mob.real_name]"
				if(check_other_rights(client, R_ADMIN, FALSE))
					additiona_data["admin_observers"]++
				else
					additiona_data["observers"]++

				var/mob/dead/observer/observer = client_mob
				if(observer.started_as_observer)
					client_payload["color"] += "#808080"
					client_payload["text"] += " - Spectating"
				else
					client_payload["color"] += "#A000D0"
					client_payload["text"] += " - DEAD"

			else
				client_payload["text"] += " - Playing as [client_mob.real_name]"

				switch(client_mob.stat)
					if(UNCONSCIOUS)
						client_payload["color"] += "#B0B0B0"
						client_payload["text"] += " - Unconscious"
					if(DEAD)
						client_payload["color"] += "#A000D0"
						client_payload["text"] += " - DEAD"

				if(client_mob.stat != DEAD)
					if(isxeno(client_mob))
						client_payload["color"] += "#f00"
						client_payload["text"] += " - Xenomorph"
						additiona_data["xenomorphs"]++
					else if(ishuman(client_mob))
						if(client_mob.faction == FACTION_ZOMBIE)
							client_payload["color"] += "#2DACB1"
							client_payload["text"] += " - Zombie"
							additiona_data["zombie"]++
//						else if(client_mob.faction == FACTION_YAUTJA)
//							client_payload["color"] += "#7ABA19"
//							client_payload["text"] += " - Yautja"
//							additiona_data["yautja"]++
//							if(client_mob.status_flags & XENO_HOST)
//								additiona_data["infected_preds"]++
						else
							additiona_data["humans"]++
							if(client_mob.status_flags & XENO_HOST)
								additiona_data["infected_humans"]++
							if(client_mob.faction == FACTION_TERRAGOV)
								additiona_data["tgmc"]++
								if(client_mob.job.title in GLOB.jobs_marines)
									additiona_data["marines"]++
							else if(client_mob.faction == FACTION_SOM)
								additiona_data["som"]++

		new_list_data["total_players"] += list(client_payload)

	new_list_data["additional_info"] += list(list(
		"content" = "in Lobby: [additiona_data["lobby"]]",
		"color" = "#777",
		"text" = "Player in lobby",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Spectators: [additiona_data["observers"]] Players",
		"color" = "#777",
		"text" = "Spectating players",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Spectators: [additiona_data["admin_observers"]] Administrators",
		"color" = "#777",
		"text" = "Spectating administrators",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Humans: [additiona_data["humans"]]",
		"color" = "#2C7EFF",
		"text" = "Players playing as Human",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Infected Humans: [additiona_data["infected_humans"]]",
		"color" = "#F00",
		"text" = "Players playing as Infected Human",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "TGMC '[SSmapping.configs[SHIP_MAP].map_name]' Personnel: [additiona_data["tgmc"]]",
		"color" = "#472aea",
		"text" = "Players playing as TGMC '[SSmapping.configs[SHIP_MAP].map_name]' Personnel",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Marines: [additiona_data["marines"]]",
		"color" = "#472aea",
		"text" = "Players playing as Marines",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Sons of Mars: [additiona_data["som"]]",
		"color" = "#c18e18",
		"text" = "Players playing as SOM",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Yautjes: [additiona_data["yautja"]]",
		"color" = "#7ABA19",
		"text" = "Players playing as Yautja",
	))

	new_list_data["additional_info"] += list(list(
		"content" = "Infected Yautjes: [additiona_data["infected_preds"]])",
		"color" = "#7ABA19",
		"text" = "Players playing as Infected Yautja",
	))

	var/datum/hive_status/hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	new_list_data["xenomorphs"] += list(list(
		"content" = "[hive.name]: [length(hive.get_all_xenos())]",
		"color" = hive.color ? hive.color : "#A000D0",
		"text" = "Queen: [hive.living_xeno_ruler ? "Alive" : "Dead"]",
	))

	list_data = new_list_data
	mobs_ckey = new_mobs_ckey

/datum/player_list/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, tgui_name, tgui_interface_name)
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/player_list/ui_data(mob/user)
	. = list_data

/datum/player_list/ui_static_data(mob/user)
	. = list()

	.["admin"] = check_other_rights(user.client, R_ADMIN, FALSE)

/datum/player_list/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("get_player_panel")
			usr.client.holder.show_player_panel(mobs_ckey[params["ckey"]])

/datum/player_list/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE


/datum/player_list/staff
	tgui_name = "StaffWho"
	tgui_interface_name = "Staff Who"

	var/list/category_colors = list(
		"Management" = "purple",
		"Maintainers" = "blue",
		"Administrators" = "red",
		"Moderators" = "orange",
		"Mentors" = "green"
	)

/datum/player_list/staff/update_data()
	var/list/new_list_data = list()
	mobs_ckey = list()

	var/list/listings
	var/list/mappings
	LAZYSET(mappings, "Administrators", R_ADMIN)
	LAZYSET(mappings, "Mentors", R_MENTOR)

	for(var/category in mappings)
		LAZYSET(listings, category, list())

	for(var/client/client in GLOB.admins)
		if(client.holder?.fakekey && !check_other_rights(client, R_ADMIN|R_MENTOR, FALSE))
			continue

		for(var/category in mappings)
			if(check_other_rights(client, mappings[category], FALSE))
				LAZYADD(listings[category], client)
				break

	for(var/category in listings)
		var/list/admins = list()
		for(var/client/entry in listings[category])
			var/list/admin = list()
			var/rank = entry.holder.rank
			admin["content"] = "[entry.key] ([rank])"
			admin["text"] = ""

			if(entry.holder?.fakekey)
				admin["text"] += " (HIDDEN)"

			if(istype(entry.mob, /mob/dead/observer))
				admin["color"] = "#808080"
				admin["text"] += " Spectating"

			else if(istype(entry.mob, /mob/new_player))
				admin["color"] = "#688944"
				admin["text"] += " in Lobby"
			else
				admin["color"] = "#688944"
				admin["text"] += " Playing"

			if(entry.is_afk())
				admin["color"] = "#A040D0"
				admin["text"] += " (AFK)"

			admins += list(admin)

		new_list_data["administrators"] += list(list(
			"category" = category,
			"category_color" = category_colors[category],
			"category_administrators" = length(listings[category]),
			"admins" = admins,
		))

	list_data = new_list_data

/mob/verb/who()
	set category = "OOC"
	set name = "Who"

	SSwho.who.ui_interact(src)

/mob/verb/staffwho()
	set category = "Admin"
	set name = "Staff Who"

	SSwho.staff_who.ui_interact(src)

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		user.client.register_map_obj(screen_main)
		user.client.register_map_obj(screen_bg)

		ui = new(user, src, "PlayerPreferences", "Preferences")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/preferences/ui_close(mob/user)
	. = ..()
	user.client.clear_map(map_name)
	user.client.clear_character_previews()

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

/datum/preferences/ui_data(mob/user)
	. = list(
		"is_admin" = user.client?.holder ? TRUE : FALSE,
		"slot" = default_slot,
		"real_name" = real_name,
		"random_name" = random_name,
		"synthetic_name" = synthetic_name,
		"synthetic_type" = synthetic_type,
		"xeno_name" = xeno_name,
		"ai_name" = ai_name,

		"age" = age,
		"gender" = gender,
		"ethnicity" = ethnicity,
		"species" = species,
		"body_type" = body_type,
		"good_eyesight" = good_eyesight,
		"h_style" = h_style,
		"r_hair" = r_hair,
		"g_hair" = g_hair,
		"b_hair" = b_hair,
		"f_style" = f_style,
		"r_facial" = r_facial,
		"g_facial" = g_facial,
		"b_facial" = b_facial,
		"r_eyes" = r_eyes,
		"g_eyes" = g_eyes,
		"b_eyes" = b_eyes,

		"citizenship" = citizenship,
		"religion" = religion,
		"nanotrasen_relation" = nanotrasen_relation,

		// Records
		"flavor_text" = flavor_text,
		"med_record" = med_record,
		"gen_record" = gen_record,
		"sec_record" = sec_record,
		"exploit_record" = exploit_record,

		// Clothing
		"undershirt" = undershirt,
		"underwear" = underwear,
		"backpack" = backpack,
		"gear" = gear,

		// Job prefs
		"job_preferences" = job_preferences,
		"preferred_squad" = preferred_squad,
		"alternate_option" = alternate_option,

		"special_occupation" = be_special,

		// Game prefs
		"ui_style" = ui_style,
		"ui_style_color" = ui_style_color,
		"ui_style_alpha" = ui_style_alpha,
		"windowflashing" = windowflashing,
		"auto_fit_viewport" = auto_fit_viewport,
		"focus_chat" = focus_chat,
		"clientfps" = clientfps,

		"chat_on_map" = chat_on_map,
		"max_chat_length" = max_chat_length,
		"see_chat_non_mob" = see_chat_non_mob,
		"see_rc_emotes" = see_rc_emotes,
		"mute_others_combat_messages" = mute_others_combat_messages,
		"mute_self_combat_messages" = mute_self_combat_messages,
		"show_typing" = show_typing,

		"tooltips" = tooltips,

		"key_bindings" = key_bindings,
	)
	.["key_bindings"] = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			.["key_bindings"][kb_name] += list(key)

	// Get save slot name
	.["save_slot_names"] = list()
	if(!path)
		return
	var/savefile/S = new (path)
	if(!S)
		return
	var/name
	for(var/i in 1 to MAX_SAVE_SLOTS)
		S.cd = "/character[i]"
		S["real_name"] >> name
		if(!name)
			continue
		.["save_slot_names"]["[i]"] = name



/datum/preferences/ui_static_data(mob/user)
	update_preview_icon()
	. = list(
		"all_species" = get_playable_species(),
		"synth_types" = SYNTH_TYPES,
		"bodytypes" = GLOB.body_types_list,
		"ethnicities" = GLOB.ethnicities_list,
		"citizenships" = CITIZENSHIP_CHOICES,
		"religions" = RELIGION_CHOICES,
		"corporate_relations" = CORP_RELATIONS,
		"squads" = SELECTABLE_SQUADS,
		"clothing" = list(
			"underwear" = list(
				"male" = GLOB.underwear_m,
				"female" = GLOB.underwear_f,
			),
			"undershirt" = GLOB.undershirt_t,
			"backpack" = GLOB.backpacklist,
			"loadout" = GLOB.gear_datums
		),
		"hairstyles" = GLOB.hair_styles_list,
		"facialhair" = GLOB.facial_hair_styles_list,
		"genders" = list(
			"NEUTER",
			"MALE",
			"FEMALE",
			"PLURAL",
		),
		"validation" = list(
			"age" = list("min" = AGE_MIN, "max" = AGE_MAX),
		),
		"overflow_job" = SSjob?.overflow_role?.title,
		"ui_styles" = UI_STYLES,
	)
	.["gearsets"] = list()
	for(var/g in GLOB.gear_datums)
		var/datum/gear/gearset = GLOB.gear_datums[g]
		.["gearsets"][gearset.display_name] = list(
			"name" = gearset.display_name,
			"cost" = gearset.cost,
			"slot" = gearset.slot,
		)

	.["jobs"] = list()
	for(var/j in SSjob.joinable_occupations)
		var/datum/job/job = j
		var/rank = job.title
		.["jobs"][rank] = list(
			"color" = job.selection_color,
			"description" = job.html_description,
			"banned" = is_banned_from(user.ckey, rank),
			"playtime_req" = job.required_playtime_remaining(user.client),
			"account_age_req" = !job.player_old_enough(user.client),
			"flags" = list(
				"bold" = (job.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION) ? TRUE : FALSE
			)
		)
	.["special_occupations"] = list(
		"Latejoin Xenomorph" = BE_ALIEN,
		"Xenomorph when unrevivable" = BE_ALIEN_UNREVIVABLE,
		"End of Round Deathmatch" = BE_DEATHMATCH,
		"Prefer Squad over Role" = BE_SQUAD_STRICT
	)

	// Group keybinds by category
	.["all_keybindings"] = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		.["all_keybindings"][kb.category] += list(list(
			name = kb.name,
			display_name = kb.full_name,
			desc = kb.description,
			category = kb.category,
		))


/datum/preferences/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/client/current_client = CLIENT_FROM_VAR(usr)
	var/mob/user = current_client.mob

	switch(action)
		if("changeslot")
			if(!load_character(text2num(params["changeslot"])))
				random_character()
				real_name = random_unique_name(gender)
				save_character()

		if("random")
			randomize_appearance_for()

		if("name_real")
			var/newValue = params["newValue"]
			newValue = reject_bad_name(newValue)
			if(!newValue)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			real_name = newValue

		if("randomize_name")
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("toggle_always_random")
			random_name = !random_name

		if("randomize_appearance")
			randomize_appearance_for()

		if("synth_name")
			var/newValue = params["newValue"]
			newValue = reject_bad_name(newValue)
			if(!newValue)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			synthetic_name = newValue

		if("synth_type")
			var/new_synth_type = params["newValue"]
			if(!(new_synth_type in SYNTH_TYPES))
				return
			synthetic_type = new_synth_type

		if("xeno_name")
			var/newValue = params["newValue"]
			if(newValue == "")
				xeno_name = "Undefined"
			else
				newValue = reject_bad_name(newValue)
				if(!newValue)
					to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
					return
				xeno_name = newValue

		if("ai_name")
			var/newValue = params["newValue"]
			if(newValue == "")
				ai_name = "ARES v3.2"
			else
				newValue = reject_bad_name(newValue, TRUE)
				if(!newValue)
					to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
					return
				ai_name = newValue

		if("age")
			var/new_age = text2num(params["newValue"])
			if(!isnum(new_age))
				return
			new_age = round(new_age)
			age = clamp(new_age, AGE_MIN, AGE_MAX)

		if("toggle_gender")
			if(gender == MALE)
				gender = FEMALE
				f_style = "Shaved"
			else
				gender = MALE
				underwear = 1


		if("ethnicity")
			var/new_ethnicity = params["newValue"]
			if(!(new_ethnicity in GLOB.ethnicities_list))
				return
			ethnicity = new_ethnicity

		if("species")
			var/new_species = params["newValue"]
			if(!(new_species in get_playable_species()))
				return
			species = new_species


		if("body_type")
			var/new_body_type = params["newValue"]
			if(!(new_body_type in GLOB.body_types_list))
				return
			body_type = new_body_type

		if("toggle_eyesight")
			good_eyesight = !good_eyesight

		if("moth_wings")
			if(species != "Moth")
				return
			var/new_wings = params["newValue"]
			if(!(new_wings in (GLOB.moth_wings_list - "Burnt Off")))
				return
			moth_wings = new_wings

		if("be_special")
			var/flag = text2num(params["flag"])
			TOGGLE_BITFIELD(be_special, flag)

		if("jobselect")
			UpdateJobPreference(user, params["job"], text2num(params["level"]))

		if("jobalternative")
			var/newValue = text2num(params["newValue"])
			alternate_option = clamp(newValue, 0, 2)

		if("jobreset")
			job_preferences = list()
			preferred_squad = "None"
			alternate_option = 2 // return to lobby

		if("underwear")
			var/list/underwear_options
			if(gender == MALE)
				underwear_options = GLOB.underwear_m
			else
				underwear_options = GLOB.underwear_f

			var/new_underwear = underwear_options.Find(params["newValue"])
			if(!new_underwear)
				return
			underwear = new_underwear

		if("undershirt")
			var/new_undershirt = GLOB.undershirt_t.Find(params["newValue"])
			if(!new_undershirt)
				return
			undershirt = new_undershirt

		if("backpack")
			var/new_backpack = GLOB.backpacklist.Find(params["newValue"])
			if(!new_backpack)
				return
			backpack = new_backpack

		if("loadoutadd")
			var/choice = params["gear"]
			if(!(choice in GLOB.gear_datums))
				return

			var/total_cost = 0
			var/datum/gear/C = GLOB.gear_datums[choice]

			if(!C)
				return

			if(length(gear))
				for(var/gear_name in gear)
					if(GLOB.gear_datums[gear_name])
						var/datum/gear/G = GLOB.gear_datums[gear_name]
						total_cost += G.cost

			total_cost += C.cost
			if(total_cost <= MAX_GEAR_COST)
				if(!islist(gear))
					gear = list()
				gear += choice
				to_chat(user, "<span class='notice'>Added '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>")
			else
				to_chat(user, "<span class='warning'>Adding '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>")

		if("loadoutremove")
			gear.Remove(params["gear"])
			if(!islist(gear))
				gear = list()

		if("loadoutclear")
			gear.Cut()
			if(!islist(gear))
				gear = list()

		if("ui")
			var/choice = params["newValue"]
			if(!(choice in  UI_STYLES))
				return
			ui_style = choice

		if("uicolor")
			var/ui_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", "UI Color") as null|color
			if(!ui_style_color_new)
				return
			ui_style_color = ui_style_color_new

		if("uialpha")
			var/ui_style_alpha_new = text2num(params["newValue"])
			if(!ui_style_alpha_new)
				return
			ui_style_alpha_new = round(ui_style_alpha_new)
			ui_style_alpha = clamp(ui_style_alpha_new, 55, 230)

		if("hairstyle")
			var/list/valid_hairstyles = list()
			for(var/hairstyle in GLOB.hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
				if(!(species in S.species_allowed))
					continue

				valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

			var/new_h_style = params["newValue"]
			if(!(new_h_style in valid_hairstyles))
				return
			h_style = new_h_style

		if("haircolor")
			var/new_color = input(user, "Choose your character's hair colour:", "Hair Color") as null|color
			if(!new_color)
				return
			r_hair = hex2num(copytext(new_color, 2, 4))
			g_hair = hex2num(copytext(new_color, 4, 6))
			b_hair = hex2num(copytext(new_color, 6, 8))

		if("facialstyle")
			var/list/valid_facialhairstyles = list()
			for(var/facialhairstyle in GLOB.facial_hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
				if(gender != S.gender)
					continue
				if(!(species in S.species_allowed))
					continue

				valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

			var/new_f_style = params["newValue"]
			if(!(new_f_style in (valid_facialhairstyles + "Shaved")))
				return
			f_style = new_f_style

		if("facialcolor")
			var/facial_color = input(user, "Choose your character's facial-hair colour:", "Facial Hair Color") as null|color
			if(!facial_color)
				return
			r_facial = hex2num(copytext(facial_color, 2, 4))
			g_facial = hex2num(copytext(facial_color, 4, 6))
			b_facial = hex2num(copytext(facial_color, 6, 8))

		if("eyecolor")
			var/eyecolor = input(user, "Choose your character's eye colour:", "Character Preference") as null|color
			if(!eyecolor)
				return
			r_eyes = hex2num(copytext(eyecolor, 2, 4))
			g_eyes = hex2num(copytext(eyecolor, 4, 6))
			b_eyes = hex2num(copytext(eyecolor, 6, 8))

		if("citizenship")
			var/choice = params["newValue"]
			if(!(choice in CITIZENSHIP_CHOICES))
				return
			citizenship = choice

		if("religion")
			var/choice = params["newValue"]
			if(!(choice in RELIGION_CHOICES))
				return
			religion = choice

		if("corporation")
			var/new_relation = params["newValue"]
			if(!(new_relation in CORP_RELATIONS))
				return
			nanotrasen_relation = new_relation

		if("squad")
			var/new_squad = params["newValue"]
			if(!(new_squad in SELECTABLE_SQUADS))
				return
			preferred_squad = new_squad

		if("med_record")
			var/new_record = trim(html_encode(params["medicalDesc"]), MAX_MESSAGE_LEN)
			if(!new_record)
				return
			med_record = new_record

		if("sec_record")
			var/new_record = trim(html_encode(params["securityDesc"]), MAX_MESSAGE_LEN)
			if(!new_record)
				return
			sec_record = new_record

		if("gen_record")
			var/new_record = trim(html_encode(params["employmentDesc"]), MAX_MESSAGE_LEN)
			if(!new_record)
				return
			gen_record = new_record

		if("exploit_record")
			var/new_record = trim(html_encode(params["exploitsDesc"]), MAX_MESSAGE_LEN)
			if(!new_record)
				return
			exploit_record = new_record

		if("flavor_text")
			var/new_record = trim(html_encode(params["characterDesc"]), MAX_MESSAGE_LEN)
			if(!new_record)
				return
			flavor_text = new_record

		if("windowflashing")
			windowflashing = !windowflashing

		if("auto_fit_viewport")
			auto_fit_viewport = !auto_fit_viewport
			if(auto_fit_viewport && parent)
				parent.fit_viewport()

		if("focus_chat")
			focus_chat = !focus_chat
			if(focus_chat)
				winset(user, null, "input.focus=true")
			else
				winset(user, null, "map.focus=true")

		if("clientfps")
			var/desiredfps = params["newValue"]
			if(isnull(desiredfps))
				return
			desiredfps = clamp(desiredfps, 0, 240)
			clientfps = desiredfps
			parent.fps = desiredfps

		if("chat_on_map")
			chat_on_map = !chat_on_map

		if ("max_chat_length")
			var/desiredlength = text2num(params["newValue"])
			if(!isnull(desiredlength))
				max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)

		if("see_chat_non_mob")
			see_chat_non_mob = !see_chat_non_mob

		if("see_rc_emotes")
			see_rc_emotes = !see_rc_emotes

		if("mute_self_combat_messages")
			mute_self_combat_messages = !mute_self_combat_messages

		if("mute_others_combat_messages")
			mute_others_combat_messages = !mute_others_combat_messages

		if("show_typing")
			show_typing = !show_typing
			// Need to remove any currently shown
			if(!show_typing && istype(user))
				user.remove_typing_indicator()

		if("tooltips")
			tooltips = !tooltips
			if(!tooltips)
				closeToolTip(usr)
			else if(!current_client.tooltips && tooltips)
				current_client.tooltips = new /datum/tooltip(current_client)

		if("keybindings_set")
			var/kb_name = params["keybinding"]
			if(!kb_name)
				return

			var/clear_key = text2num(params["clear_key"])
			var/old_key = params["old_key"]
			if(clear_key)
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key

			else
				var/new_key = uppertext(params["key"])
				var/AltMod = text2num(params["alt"]) ? "Alt" : ""
				var/CtrlMod = text2num(params["ctrl"]) ? "Ctrl" : ""
				var/ShiftMod = text2num(params["shift"]) ? "Shift" : ""
				var/numpad = text2num(params["numpad"]) ? "Numpad" : ""
				// var/key_code = text2num(params["key_code"])

				if(GLOB._kbMap[new_key])
					new_key = GLOB._kbMap[new_key]

				var/full_key
				switch(new_key)
					if("Alt")
						full_key = "[new_key][CtrlMod][ShiftMod]"
					if("Ctrl")
						full_key = "[AltMod][new_key][ShiftMod]"
					if("Shift")
						full_key = "[AltMod][CtrlMod][new_key]"
					else
						full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key
				key_bindings[full_key] += list(kb_name)
				key_bindings[full_key] = sortList(key_bindings[full_key])

				current_client.update_movement_keys()

		if("reset-keybindings")
			key_bindings = GLOB.hotkey_keybinding_list_by_key
			current_client.update_movement_keys()

		if("bancheck")
			var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, params["role"])
			var/admin = FALSE
			if(GLOB.admin_datums[user.ckey] || GLOB.deadmins[user.ckey])
				admin = TRUE
			for(var/i in ban_details)
				if(admin && !text2num(i["applies_to_admins"]))
					continue
				ban_details = i
				break //we only want to get the most recent ban's details
			if(!length(ban_details))
				return

			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [params["role"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")

		if("update-character-preview")
			update_preview_icon()

		else //  Handle the unhandled cases
			return

	save_preferences()
	save_character()
	update_preview_icon()
	return TRUE
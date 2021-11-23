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
	user.client?.clear_map(map_name)
	user.client?.clear_character_previews()

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

/datum/preferences/ui_data(mob/user)
	. = list()
	.["tabIndex"] = tab_index
	.["slot"] = default_slot
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

	.["unique_action_use_active_hand"] = unique_action_use_active_hand

	switch(tab_index)
		if(CHARACTER_CUSTOMIZATION)
			.["r_hair"] = r_hair
			.["g_hair"] = g_hair
			.["b_hair"] = b_hair
			.["r_grad"] = r_grad
			.["g_grad"] = g_grad
			.["b_grad"] = b_grad
			.["r_facial"] = r_facial
			.["g_facial"] = g_facial
			.["b_facial"] = b_facial
			.["r_eyes"] = r_eyes
			.["g_eyes"] = g_eyes
			.["b_eyes"] = b_eyes
			.["real_name"] = real_name
			.["xeno_name"] = xeno_name
			.["synthetic_name"] = synthetic_name
			.["synthetic_type"] = synthetic_type
			.["random_name"] = random_name
			.["ai_name"] = ai_name
			.["age"] = age
			.["gender"] = gender
			.["ethnicity"] = ethnicity
			.["species"] = species || "Human"
			.["good_eyesight"] = good_eyesight
			.["citizenship"] = citizenship
			.["religion"] = religion
			.["h_style"] = h_style
			.["grad_style"] = grad_style
			.["f_style"] = f_style
		if(BACKGROUND_INFORMATION)
			.["slot"] = default_slot
			.["flavor_text"] = flavor_text
			.["med_record"] = med_record
			.["gen_record"] = gen_record
			.["sec_record"] = sec_record
			.["exploit_record"] = exploit_record
		if(GEAR_CUSTOMIZATION)
			.["gearsets"] = list()
			for(var/g in GLOB.gear_datums)
				var/datum/gear/gearset = GLOB.gear_datums[g]
				.["gearsets"][gearset.display_name] = list(
					"name" = gearset.display_name,
					"cost" = gearset.cost,
					"slot" = gearset.slot,
				)
			.["gear"] = gear || list()
			.["undershirt"] = undershirt
			.["underwear"] = underwear
			.["backpack"] = backpack
			.["gender"] = gender
		if(JOB_PREFERENCES)
			.["job_preferences"] = job_preferences
			.["preferred_squad"] = preferred_squad
			.["alternate_option"] = alternate_option
			.["special_occupation"] = be_special
		if(GAME_SETTINGS)
			.["ui_style_color"] = ui_style_color
			.["ui_style"] = ui_style
			.["ui_style_alpha"] = ui_style_alpha
			.["windowflashing"] = windowflashing
			.["auto_fit_viewport"] = auto_fit_viewport
			.["mute_xeno_health_alert_messages"] = mute_xeno_health_alert_messages
			.["tgui_fancy"] = tgui_fancy
			.["tgui_lock"] = tgui_lock
			.["tgui_input"] = tgui_input
			.["tgui_input_big_buttons"] = tgui_input_big_buttons
			.["tgui_input_buttons_swap"] = tgui_input_buttons_swap
			.["clientfps"] = clientfps
			.["chat_on_map"] = chat_on_map
			.["max_chat_length"] = max_chat_length
			.["see_chat_non_mob"] = see_chat_non_mob
			.["see_rc_emotes"] = see_rc_emotes
			.["mute_others_combat_messages"] = mute_others_combat_messages
			.["mute_self_combat_messages"] = mute_self_combat_messages
			.["show_typing"] = show_typing
			.["tooltips"] = tooltips
			.["widescreenpref"] = widescreenpref
			.["radialmedicalpref"] = toggles_gameplay & RADIAL_MEDICAL
			.["radialstackspref"] = toggles_gameplay & RADIAL_STACKS
			.["scaling_method"] = scaling_method
			.["pixel_size"] = pixel_size
			.["parallax"] = parallax
			.["fullscreen_mode"] = fullscreen_mode
			.["preferred_slot"] = slot_flag_to_fluff(preferred_slot)
			.["preferred_slot_alt"] = slot_flag_to_fluff(preferred_slot_alt)
		if(KEYBIND_SETTINGS)
			.["is_admin"] = user.client?.holder ? TRUE : FALSE
			.["key_bindings"] = list()
			for(var/key in key_bindings)
				for(var/kb_name in key_bindings[key])
					.["key_bindings"][kb_name] += list(key)
			.["custom_emotes"] = list()
			for(var/id in 1 to CUSTOM_EMOTE_SLOTS)
				var/datum/custom_emote/emote = custom_emotes[id]
				.["custom_emotes"]["Custom emote :[id]"] = list(
					sentence = emote.message,
					emote_type = (emote.spoken_emote ? "say" : "me"),
					)

/datum/preferences/ui_static_data(mob/user)
	if(!user?.client)
		return

	. = list()
	switch(tab_index)
		if(CHARACTER_CUSTOMIZATION)
			update_preview_icon()
			.["mapRef"] = "player_pref_map"
		if(GEAR_CUSTOMIZATION)
			.["clothing"] = list(
				"underwear" = list(
					"male" = GLOB.underwear_m,
					"female" = GLOB.underwear_f,
				),
				"undershirt" = GLOB.undershirt_t,
				"backpack" = GLOB.backpacklist,
				)
			.["gearsets"] = list()
			for(var/g in GLOB.gear_datums)
				var/datum/gear/gearset = GLOB.gear_datums[g]
				.["gearsets"][gearset.display_name] = list(
					"name" = gearset.display_name,
					"cost" = gearset.cost,
					"slot" = gearset.slot,
				)
		if(JOB_PREFERENCES)
			.["squads"] = SELECTABLE_SQUADS
			.["jobs"] = list()
			for(var/datum/job/job AS in SSjob.joinable_occupations)
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
		if(KEYBIND_SETTINGS)
			.["all_keybindings"] = list()
			for(var/name in GLOB.keybindings_by_name)
				var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
				.["all_keybindings"][kb.category] += list(list(
					name = kb.name,
					display_name = kb.full_name,
					desc = kb.description,
					category = kb.category,
				))

/datum/preferences/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/client/current_client = CLIENT_FROM_VAR(usr)
	if(!current_client)
		return
	var/mob/user = current_client.mob

	switch(action)
		if("changeslot")
			if(!load_character(text2num(params["changeslot"])))
				random_character()
				real_name = random_unique_name(gender)
				save_character()

		if("tab_change")
			tab_index = params["tabIndex"]
			update_static_data(ui.user, ui)

		if("random")
			randomize_appearance_for()
			save_character()

		if("name_real")
			var/newValue = params["newValue"]
			newValue = reject_bad_name(newValue, TRUE)
			if(!newValue)
				tgui_alert(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>", "Invalid name", list("Ok"))
				return
			real_name = newValue

		if("randomize_name")
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("toggle_always_random")
			random_name = !random_name

		if("randomize_appearance")
			randomize_appearance_for()

		if("synthetic_name")
			var/newValue = params["newValue"]
			newValue = reject_bad_name(newValue, TRUE)
			if(!newValue)
				tgui_alert(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>", "Invalid name", list("Ok"))
				return
			synthetic_name = newValue

		if("synthetic_type")
			var/choice = tgui_input_list(ui.user, "What kind of synthetic do you want to play with?", "Synthetic type choice", SYNTH_TYPES)
			if(choice)
				synthetic_type = choice

		if("xeno_name")
			var/newValue = params["newValue"]
			if(newValue == "")
				xeno_name = "Undefined"
			else
				newValue = reject_bad_name(newValue)
				if(!newValue)
					tgui_alert(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>", "Invalid name", list("Ok"))
					return
				xeno_name = newValue

		if("ai_name")
			var/newValue = params["newValue"]
			if(newValue == "")
				ai_name = "ARES v3.2"
			else
				newValue = reject_bad_name(newValue, TRUE)
				if(!newValue)
					tgui_alert(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>", "Invalid name", list("Ok"))
					return
				ai_name = newValue

		if("age")
			var/new_age = text2num(params["newValue"])
			if(!isnum(new_age))
				return
			new_age = round(new_age)
			age = clamp(new_age, AGE_MIN, AGE_MAX)

		if("toggle_gender")
			gender = params["newgender"]
			if(gender == FEMALE)
				f_style = "Shaved"
			else
				underwear = 1


		if("ethnicity")
			var/choice = tgui_input_list(ui.user, "What ethnicity do you want to play with?", "Ethnicity choice", GLOB.ethnicities_list)
			if(choice)
				ethnicity = choice

		if("species")
			var/choice = tgui_input_list(ui.user, "What species do you want to play with?", "Species choice", get_playable_species())
			if(!choice || species == choice)
				return
			species = choice
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("toggle_eyesight")
			good_eyesight = !good_eyesight

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
				to_chat(user, span_notice("Added '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining)."))
			else
				to_chat(user, span_warning("Adding '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points."))

		if("loadoutremove")
			gear.Remove(params["gear"])
			if(!islist(gear))
				gear = list()

		if("loadoutclear")
			gear.Cut()
			if(!islist(gear))
				gear = list()

		if("ui")
			var/choice = tgui_input_list(ui.user, "What UI style do you want?", "UI style choice", UI_STYLES)
			if(choice)
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
			var/choice = tgui_input_list(ui.user, "What hair style do you want?", "Hair style choice", valid_hairstyles)
			if(choice)
				h_style = choice

		if("haircolor")
			var/new_color = input(user, "Choose your character's hair colour:", "Hair Color") as null|color
			if(!new_color)
				return
			r_hair = hex2num(copytext(new_color, 2, 4))
			g_hair = hex2num(copytext(new_color, 4, 6))
			b_hair = hex2num(copytext(new_color, 6, 8))

		if("grad_color")
			var/new_grad = input(user, "Choose your character's secondary hair color:", "Gradient Color") as null|color
			if(!new_grad)
				return
			r_grad = hex2num(copytext(new_grad, 2, 4))
			g_grad = hex2num(copytext(new_grad, 4, 6))
			b_grad = hex2num(copytext(new_grad, 6, 8))

		if("grad_style")
			var/list/valid_grads = list()
			for(var/grad in GLOB.hair_gradients_list)
				var/datum/sprite_accessory/S = GLOB.hair_gradients_list[grad]
				if(!(species in S.species_allowed))
					continue

				valid_grads[grad] = GLOB.hair_gradients_list[grad]

			var/choice = tgui_input_list(ui.user, "What hair grad style do you want?", "Hair grad style choice", valid_grads)
			if(choice)
				grad_style = choice

		if("facial_style")
			var/list/valid_facialhairstyles = list()
			for(var/facialhairstyle in GLOB.facial_hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
				if(gender == FEMALE && S.gender == MALE)
					continue
				if(!(species in S.species_allowed))
					continue

				valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

			var/choice = tgui_input_list(ui.user, "What facial hair style do you want?", "Facial hair style choice", valid_facialhairstyles)
			if(choice)
				f_style = choice

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
			var/choice = tgui_input_list(ui.user, "Where do you hail from?", "Place of Origin", CITIZENSHIP_CHOICES)
			if(choice)
				citizenship = choice

		if("religion")
			var/choice = tgui_input_list(ui.user, "What religion do you belive in?", "Belief", RELIGION_CHOICES)
			if(choice)
				religion = choice

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

		if("mute_xeno_health_alert_messages")
			mute_xeno_health_alert_messages = !mute_xeno_health_alert_messages

		if("tgui_fancy")
			tgui_fancy = !tgui_fancy

		if("tgui_lock")
			tgui_lock = !tgui_lock

		if("tgui_input")
			tgui_input = !tgui_input

		if("tgui_input_big_buttons")
			tgui_input_big_buttons = !tgui_input_big_buttons

		if("tgui_input_buttons_swap")
			tgui_input_buttons_swap = !tgui_input_buttons_swap

		if("clientfps")
			var/desiredfps = text2num(params["newValue"])
			if(!isnum(desiredfps))
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

		if("preferred_slot_select")
			var/slot = tgui_input_list(usr, "Which slot would you like to draw/equip from?", "Preferred Slot", SLOT_FLUFF_DRAW)
			preferred_slot = slot_fluff_to_flag(slot)
			to_chat(src, span_notice("You will now equip/draw from the [slot] slot first."))

		if("preferred_slot_alt_select")
			var/slot = tgui_input_list(usr, "Which slot would you like to draw/equip from?", "Alternate preferred Slot", SLOT_FLUFF_DRAW)
			preferred_slot_alt = slot_fluff_to_flag(slot)
			to_chat(src, span_notice("You will now equip/draw from the [slot] slot first."))

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

		if("fullscreen_mode")
			fullscreen_mode = !fullscreen_mode
			user.client?.set_fullscreen(fullscreen_mode)

		if("set_keybind")
			var/kb_name = params["keybind_name"]
			if(!kb_name)
				return

			var/old_key = params["old_key"]
			if(key_bindings[old_key])
				key_bindings[old_key] -= kb_name
				if(!length(key_bindings[old_key]))
					key_bindings -= old_key

			if(!params["key"])
				return
			var/mods = params["key_mods"]
			var/full_key = uppertext(convert_ru_key_to_en_key(params["key"]))
			var/Altmod = ("ALT" in mods) ? "Alt" : ""
			var/Ctrlmod = ("CONTROL" in mods) ? "Ctrl" : ""
			var/Shiftmod = ("SHIFT" in mods) ? "Shift" : ""
			full_key = Altmod + Ctrlmod + Shiftmod + full_key

			if(GLOB._kbMap[full_key])
				full_key = GLOB._kbMap[full_key]

			if(kb_name in key_bindings[full_key]) //We pressed the same key combination that was already bound here, so let's remove to re-add and re-sort.
				key_bindings[full_key] -= kb_name

			key_bindings[full_key] += list(kb_name)
			key_bindings[full_key] = sortList(key_bindings[full_key])
			current_client.update_movement_keys()
			save_keybinds()
			return TRUE

		if("clear_keybind")
			var/kb_name = params["keybinding"]
			for(var/key in key_bindings)
				if(!(kb_name in key_bindings[key]))
					continue
				key_bindings[key] -= kb_name
				if(!length(key_bindings[key]))
					key_bindings -= key
					continue
				key_bindings[key] = sortList(key_bindings[key])
			current_client.update_movement_keys()
			save_keybinds()
			return TRUE

		if("setCustomSentence")
			var/kb_name = params["name"]
			if(!kb_name)
				return
			var/list/part = splittext_char(kb_name, ":")
			var/id = text2num(part[2])
			var/datum/custom_emote/emote = custom_emotes[id]
			var/new_message = params["sentence"]
			if(length(new_message) > 300)
				return
			emote.message = new_message
			custom_emotes[id] = emote

		if("setEmoteType")
			var/kb_name = params["name"]
			if(!kb_name)
				return
			var/list/part = splittext_char(kb_name, ":")
			var/id = text2num(part[2])
			var/datum/custom_emote/emote = custom_emotes[id]
			emote.spoken_emote = !emote.spoken_emote

		if("reset-keybindings")
			key_bindings = GLOB.hotkey_keybinding_list_by_key
			current_client.update_movement_keys()
			save_keybinds()

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
			to_chat(user, span_danger("You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [params["role"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]"))

		if("update-character-preview")
			update_preview_icon()

		if("widescreenpref")
			widescreenpref = !widescreenpref
			user.client.view_size.set_default(get_screen_size(widescreenpref))

		if("radialmedicalpref")
			toggles_gameplay ^= RADIAL_MEDICAL

		if("radialstackspref")
			toggles_gameplay ^= RADIAL_STACKS

		if("pixel_size")
			switch(pixel_size)
				if(PIXEL_SCALING_AUTO)
					pixel_size = PIXEL_SCALING_1X
				if(PIXEL_SCALING_1X)
					pixel_size = PIXEL_SCALING_1_2X
				if(PIXEL_SCALING_1_2X)
					pixel_size = PIXEL_SCALING_2X
				if(PIXEL_SCALING_2X)
					pixel_size = PIXEL_SCALING_3X
				if(PIXEL_SCALING_3X)
					pixel_size = PIXEL_SCALING_AUTO
			user.client.view_size.apply() //Let's winset() it so it actually works

		if("parallax")
			parallax = WRAP(parallax + 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
			if(parent && parent.mob && parent.mob.hud_used)
				parent.mob.hud_used.update_parallax_pref(parent.mob)

		if("scaling_method")
			switch(scaling_method)
				if(SCALING_METHOD_NORMAL)
					scaling_method = SCALING_METHOD_DISTORT
				if(SCALING_METHOD_DISTORT)
					scaling_method = SCALING_METHOD_BLUR
				if(SCALING_METHOD_BLUR)
					scaling_method = SCALING_METHOD_NORMAL
			user.client.view_size.update_zoom_mode()

		if("unique_action_use_active_hand")
			unique_action_use_active_hand = !unique_action_use_active_hand

		else //  Handle the unhandled cases
			return

	save_preferences()
	save_character()
	save_keybinds()
	update_preview_icon()
	ui_interact(user, ui)
	SEND_SIGNAL(current_client, COMSIG_CLIENT_PREFERENCES_UIACTED)
	return TRUE

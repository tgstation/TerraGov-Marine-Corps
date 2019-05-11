GLOBAL_LIST_EMPTY(preferences_datums)


/datum/preferences
	var/client/parent

	//Basics
	var/path
	var/default_slot = 1
	var/savefile_version = 0

	//Admin
	var/warns = 0
	var/muted = NOFLAGS
	var/last_ip
	var/last_id
	var/updating_icon = FALSE

	//Game preferences
	var/lastchangelog = ""	//Hashed changelog
	var/ooccolor = "#b82e00"
	var/be_special = BE_SPECIAL_DEFAULT	//Special role selection
	var/ui_style = "Midnight"
	var/ui_style_color = "#ffffff"
	var/ui_style_alpha = 255
	var/toggles_chat = TOGGLES_CHAT_DEFAULT
	var/toggles_sound = TOGGLES_SOUND_DEFAULT
	var/ghost_hud = TOGGLES_GHOSTHUD_DEFAULT
	var/show_typing = TRUE
	var/windowflashing = TRUE

	//Synthetic specific preferences
	var/synthetic_name = "David"
	var/synthetic_type = "Synthetic"

	//Xenomorph specific preferences
	var/xeno_name = "Undefined"

	//Character preferences
	var/real_name = ""
	var/random_name = FALSE
	var/gender = MALE
	var/age = 20
	var/species = "Human"
	var/ethnicity = "Western"
	var/body_type = "Mesomorphic (Average)"
	var/good_eyesight = TRUE
	var/preferred_squad = "None"
	var/alternate_option = RETURN_TO_LOBBY
	var/jobs_high = NOFLAGS
	var/jobs_medium = NOFLAGS
	var/jobs_low = NOFLAGS
	var/preferred_slot = SLOT_S_STORE
	var/list/gear = list()

	//Clothing
	var/underwear = 1
	var/undershirt = 1
	var/backpack = 2

	//Hair style
	var/h_style = "Bald"
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

	//Facial hair
	var/f_style = "Shaved"
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0

	//Eyes
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	//Species specific
	var/moth_wings = "Plain"

	//Lore
	var/citizenship = "TerraGov"
	var/religion = "None"
	var/nanotrasen_relation = "Neutral"
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/metadata = ""
	var/slot_name = ""

	//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

	var/list/exp = list()


/datum/preferences/New(client/C)
	if(!istype(C))
		return

	parent = C

	if(!IsGuestKey(C.key))
		load_path(C.ckey)
		if(load_preferences() && load_character())
			return

	gender = pick(MALE, FEMALE)
	var/datum/species/S = GLOB.all_species[species]
	real_name = S.random_name(gender)
	age = rand(18, 36)
	h_style = pick("Crewcut", "Bald", "Short Hair")


/datum/preferences/proc/ShowChoices(mob/user)
	if(!user?.client)
		return

	update_preview_icon()

	var/dat = "<html><head><style>"
	dat += "#wrapper 		{position: relative; width: 625px; height: 200px; margin: 0 auto;}"
	dat += "#preview		{position: absolute; top: 30px; left: 400px;}"
	dat += "#right			{position: absolute; top: 201px; left: 400px;}"
	dat += "</style></head>"
	dat += "<body>"

	if(path)
		dat += "<center>"
		dat += "Slot <b>[slot_name]</b> - "
		dat += "<a href ='?_src_=prefs;preference=slot_open'>Load slot</a> - "
		dat += "<a href ='?_src_=prefs;preference=slot_save'>Save slot</a> - "
		dat += "<a href ='?_src_=prefs;preference=slot_reload'>Reload slot</a>"
		dat += "</center>"
	else
		dat += "Please create an account to save your preferences."

	dat += "<div id='wrapper'>"

	dat += "<br><b>Synthetic Name:</b> <a href='?_src_=prefs;preference=synth_name'>[synthetic_name]</a><br>"
	dat += "<b>Synthetic Type:</b> <a href='?_src_=prefs;preference=synth_type'>[synthetic_type]</a><br>"

	dat +="<br><b>Xenomorph name:</b> <a href='?_src_=prefs;preference=xeno_name'>[xeno_name]</a><br><br>"

	dat += "<big><big><b>Name:</b> "
	dat += "<a href='?_src_=prefs;preference=name_real'><b>[real_name]</b></a>"
	dat += " (<a href='?_src_=prefs;preference=name_randomize'>&reg</A>)</big></big>"
	dat += "<br>"
	dat += "Always Pick Random Name: <a href='?_src_=prefs;preference=name_random'>[random_name ? "Yes" : "No"]</a>"
	dat += "<br>"

	if(is_banned_from(user.ckey, "Appearance"))
		dat += "You are banned from using custom names and appearances.<br>"
	dat += "<br>"

	dat += "<big><b><u>Physical Information:</u></b>"
	dat += " (<a href='?_src_=prefs;preference=random'>&reg;</A>)</big>"
	dat += "<br>"
	dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age'>[age]</a><br>"
	dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : "Female"]</a><br>"
	dat += "<b>Ethnicity:</b> <a href='?_src_=prefs;preference=ethnicity'>[ethnicity]</a><br>"
	dat += "<b>Species:</b> <a href='?_src_=prefs;preference=species'>[species]</a><br>"
	dat += "<b>Body Type:</b> <a href='?_src_=prefs;preference=body_type'>[body_type]</a><br>"
	dat += "<b>Good Eyesight:</b> <a href='?_src_=prefs;preference=eyesight'>[good_eyesight ? "Yes" : "No"]</a><br>"
	dat += "<br>"

	var/datum/species/current_species = GLOB.all_species[species]
	if(current_species.preferences)
		for(var/preference_id in current_species.preferences)
			dat += "<b>[current_species.preferences[preference_id]]:</b> <a href='?_src_=prefs;preference=[preference_id]'><b>[vars[preference_id]]</b></a><br>"
		dat += "<br>"

	dat += "<big><b><u>Occupation Choices:</u></b></big>"
	dat += "<br>"

	var/n = 0
	for(var/role in BE_SPECIAL_FLAGS)
		var/ban_check_name

		switch(role)
			if("Xenomorph")
				ban_check_name = ROLE_XENOMORPH

			if("Xeno Queen")
				ban_check_name = ROLE_XENO_QUEEN

			if("Survivor")
				ban_check_name = ROLE_SURVIVOR

		if(jobban_isbanned(user, ban_check_name) || is_banned_from(user.ckey, ban_check_name))
			dat += "<b>[role]:</b> <font color=red><b> \[BANNED]</b></font><br>"
		else
			dat += "<b>[role]:</b> <a href='?_src_=prefs;preference=be_special;flag=[n]'>[be_special & (1 << n) ? "Yes" : "No"]</a><br>"
		n++

	dat += "<br><b>Preferred Squad:</b> <a href ='?_src_=prefs;preference=squad'>[preferred_squad]</a><br>"

	dat += "<br>"
	dat += "<a href='?_src_=prefs;preference=jobmenu'>Set Marine Role Preferences</a><br>"
	dat += "<br>"

	dat += "<big><b><u>Marine Gear:</u></b></big><br>"
	if(gender == MALE)
		dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear'>[GLOB.underwear_m[underwear]]</a><br>"
	else
		dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear'>[GLOB.underwear_f[underwear]]</a><br>"

	dat += "<b>Undershirt:</b> <a href='?_src_=prefs;preference=undershirt'>[GLOB.undershirt_t[undershirt]]</a><br>"

	dat += "<b>Backpack Type:</b> <a href ='?_src_=prefs;preference=backpack'>[GLOB.backpacklist[backpack]]</a><br>"

	dat += "<b>Custom Loadout:</b> "
	var/total_cost = 0

	if(!islist(gear))
		gear = list()

	if(length(gear))
		dat += "<br>"
		for(var/i in GLOB.gear_datums)
			var/datum/gear/G = GLOB.gear_datums[i]
			if(!G || !gear.Find(i))
				continue
			total_cost += G.cost
			dat += "[i] ([G.cost] points) <a href ='?_src_=prefs;preference=loadoutremove;gear=[i]'>\[remove\]</a><br>"

		dat += "<b>Used:</b> [total_cost] points."
	else
		dat += "None"

	if(total_cost < MAX_GEAR_COST)
		dat += " <a href ='?_src_=prefs;preference=loadoutadd'>\[add\]</a>"
		if(length(gear))
			dat += " <a href ='?_src_=prefs;preference=loadoutclear'>\[clear\]</a>"

	dat += "<br><br>"


	dat += "<div id='preview'>"
	dat += "<br>"
	dat += "<b>Hair:</b> <a href='?_src_=prefs;preference=hairstyle'>[h_style]</a> | <a href='?_src_=prefs;preference=haircolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"

	dat += "<b>Facial Hair:</b> <a href='?_src_=prefs;preference=facialstyle'>[f_style]</a> | <a href='?_src_=prefs;preference=facialcolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"

	dat += "<b>Eye:</b> <a href='?_src_=prefs;preference=eyecolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td>__</td></tr></table></font><br>"
	dat += "</div>"

	dat += "<div id='right'>"
	dat += "<big><b><u>Background Information:</u></b></big><br>"
	dat += "<b>Citizenship</b>: <a href ='?_src_=prefs;preference=citizenship'>[citizenship]</a><br/>"
	dat += "<b>Religion</b>: <a href ='?_src_=prefs;preference=religion'>[religion]</a><br/>"
	dat += "<b>Corporate Relation:</b> <a href ='?_src_=prefs;preference=corporation'>[nanotrasen_relation]</a><br>"

	dat += "<br>"

	if(jobban_isbanned(user, "Records"))
		dat += "<b>You are banned from using character records.</b><br>"
	else
		dat += "<a href ='?_src_=prefs;preference=records'>Character Records</a><br>"

	dat += "<a href ='?_src_=prefs;preference=flavor_text'>Character Description</a><br>"
	dat += "<br>"

	dat += "<big><b><u>Game Settings:</u></b></big><br>"
	dat += "<b>Play Admin Midis:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles_sound & SOUND_MIDI) ? "Yes" : "No"]</a><br>"
	dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles_sound & SOUND_LOBBY) ? "Yes" : "No"]</a><br>"
	dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(toggles_chat & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</a><br>"
	dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(toggles_chat & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</a><br>"
	dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'>[(toggles_chat & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</a><br>"
	dat += "<b>Ghost Hivemind:</b> <a href='?_src_=prefs;preference=ghost_hivemind'>[(toggles_chat & CHAT_GHOSTHIVEMIND) ? "Show" : "Hide"]</a><br>"
	dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=windowflashing'>[windowflashing ? "Yes" : "No"]</a><br>"

	if(CONFIG_GET(flag/allow_metadata))
		dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata'> Edit </a><br>"

	dat += "<big><b><u>UI Customization:</u></b></big><br>"
	dat += "<b>Style:</b> <a href='?_src_=prefs;preference=ui'>[ui_style]</a><br>"
	dat += "<b>Color</b>: <a href='?_src_=prefs;preference=uicolor'>[ui_style_color]</a> <table style='display:inline;' bgcolor='[ui_style_color]'><tr><td>__</td></tr></table><br>"
	dat += "<b>Alpha</b>: <a href='?_src_=prefs;preference=uialpha'>[ui_style_alpha]</a>"

	dat += "<br>"
	dat += "</div>"

	dat += "<br>"

	dat += "</div></body></html>"


	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_window", "<div align='center'>Character Setup</div>", 670, 830)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "preferences_window", src)


/datum/preferences/proc/SetChoices(mob/user, limit = 22, list/splitJobs = list(), width = 450, height = 650)
	if(!SSjob)
		return

	//limit 	 - The amount of jobs allowed per column.
	//splitJobs	 - Allows you split the table by job. You can make different tables for each department by including their heads.
	//width		 - Screen' width.
	//height 	 - Screen's height.

	var/HTML = "<body>"
	HTML += "<center>"
	HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
	HTML += "<center><a href='?_src_=prefs;preference=jobclose'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	var/datum/job/job
	for(var/i in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
		job = i
		if(!job.prefflag)
			continue
		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/j = 0, j < (limit - index), j++)
					HTML += "<tr style='color:black' bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr style='color:black' bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		lastJob = job
		var/required_playtime_remaining = job.required_playtime_remaining(user.client)
		if(required_playtime_remaining)
			HTML += "<del>[job.title]</del></td><td><b> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </b></td></tr>"
			continue
		else if(jobban_isbanned(user, job.title) || is_banned_from(user.ckey, job.title))
			HTML += "<del>[job.title]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		else if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[job.title]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		else HTML += (job.title in JOBS_COMMAND) || job.title == "AI" ? "<b>[job.title]</b>" : "[job.title]"

		HTML += "</td><td width='40%'> "

		if(GetJobDepartment(job, JOBS_PRIORITY_HIGH) & job.prefflag)
			HTML += "<a href='?_src_=prefs;preference=jobselect;job=[job.title];level=[JOBS_PRIORITY_NEVER]'><font color=blue>\[High]</font></a>"
		else if(GetJobDepartment(job, JOBS_PRIORITY_MEDIUM) & job.prefflag)
			HTML += "<a href='?_src_=prefs;preference=jobselect;job=[job.title];level=[JOBS_PRIORITY_HIGH]'><font color='#9adb83'>\[Medium]</font></a>"
		else if(GetJobDepartment(job, JOBS_PRIORITY_LOW) & job.prefflag)
			HTML += "<a href='?_src_=prefs;preference=jobselect;job=[job.title];level=[JOBS_PRIORITY_MEDIUM]'><font color=orange>\[Low]</font></a>"
		else
			HTML += "<a href='?_src_=prefs;preference=jobselect;job=[job.title];level=[JOBS_PRIORITY_LOW]'><font color=red>\[NEVER]</font></a>"
		HTML += "</td></tr>"

	HTML += "</td'></tr></table>"
	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=jobalternative'>Get random job if preferences unavailable</a></u></center><br>"
		if(BE_MARINE)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=jobalternative'>Be marine if preference unavailable</a></u></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=jobalternative'>Return to lobby if preference unavailable</a></u></center><br>"

	HTML += "<center><a href='?_src_=prefs;preference=jobreset'>\[Reset\]</a></center>"

	winshow(user, "mob_occupation", TRUE)
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Choices</div>", width, height)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "mob_occupation", src)


/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href ='?_src_=prefs;preference=med_record'>Medical Records</a><br>"

	HTML += TextPreview(med_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=gen_record'>Employment Records</a><br>"

	HTML += TextPreview(gen_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=sec_record'>Security Records</a><br>"

	HTML += TextPreview(sec_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=exploit_record'>Exploit Record</a><br>"

	HTML += TextPreview(exploit_record, 40)

	HTML += "<br>"
	HTML += "<a href ='?_src_=prefs;preference=recordsclose'>\[Done\]</a>"
	HTML += "</center>"


	winshow(user, "records", TRUE)
	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "records", src)


/datum/preferences/proc/ResetJobs()
	jobs_high = NOFLAGS
	jobs_medium = NOFLAGS
	jobs_low = NOFLAGS


/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job?.prefflag || !level)
		return FALSE
	switch(level)
		if(JOBS_PRIORITY_HIGH)
			return jobs_high
		if(JOBS_PRIORITY_MEDIUM)
			return jobs_medium
		if(JOBS_PRIORITY_LOW)
			return jobs_low
	return FALSE


/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)
		return FALSE
	if(!job.prefflag)
		return FALSE
	if(jobs_high && level == JOBS_PRIORITY_HIGH)
		jobs_medium |= jobs_high
		jobs_high = NOFLAGS
	switch(level)
		if(JOBS_PRIORITY_HIGH)
			jobs_high = job.prefflag
			jobs_medium &= ~job.prefflag
		if(JOBS_PRIORITY_MEDIUM)
			jobs_medium |= job.prefflag
			jobs_low &= ~job.prefflag
		if(JOBS_PRIORITY_LOW)
			jobs_low |= job.prefflag
		if(JOBS_PRIORITY_NEVER)
			jobs_high = NOFLAGS
	return TRUE


/datum/preferences/Topic(href, href_list, hsrc)
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()


/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!istype(user) || !length(href_list))
		return

	switch(href_list["preference"])
		if("slot_open")
			if(IsGuestKey(user.key))
				return
			open_load_dialog(user)
			return

		if("slot_save")
			save_preferences()
			save_character()
			return

		if("slot_reload")
			load_preferences()
			load_character()
			return

		if("slot_close")
			close_load_dialog(user)
			return

		if("slot_change")
			load_character(text2num(href_list["num"]))
			load_preferences()
			close_load_dialog(user)

		if("synth_name")
			var/newname = input(user, "Choose your Synthetic's name:", "Synthetic Name") as text|null
			newname = reject_bad_name(newname)
			if(!newname)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			synthetic_name = newname

		if("synth_type")
			var/new_synth_type = input(user, "Choose your model of synthetic:", "Synthetic Model") as null|anything in SYNTH_TYPES
			if(!new_synth_type)
				return
			synthetic_type = new_synth_type

		if("xeno_name")
			var/newname = input(user, "Choose your Xenomorph name:", "Xenomorph Name") as text|null
			newname = reject_bad_name(newname)
			if(!newname)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			xeno_name = newname

		if("name_real")
			var/newname = input(user, "Choose your character's name:", "Character Name") as text|null
			newname = reject_bad_name(newname)
			if(!newname)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			real_name = newname

		if("name_randomize")
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("name_random")
			random_name = !random_name

		if("random")
			randomize_appearance_for()

		if("age")
			var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Age") as num|null
			if(!isnum(new_age))
				return
			new_age = round(new_age)
			age = CLAMP(new_age, AGE_MIN, AGE_MAX)

		if("gender")
			if(gender == MALE)
				gender = FEMALE
				f_style = "Shaved"
			else
				gender = MALE
				underwear = 1

		if("ethnicity")
			var/new_ethnicity = input(user, "Choose your character's ethnicity:", "Ethnicity") as null|anything in GLOB.ethnicities_list
			if(!new_ethnicity)
				return
			ethnicity = new_ethnicity

		if("species")
			var/new_species = input(user, "Choose your species:", "Species") as null|anything in get_playable_species()
			if(!new_species)
				return
			species = new_species

		if("body_type")
			var/new_body_type = input(user, "Choose your character's body type:", "Body Type") as null|anything in GLOB.body_types_list
			if(!new_body_type)
				return
			body_type = new_body_type

		if("eyesight")
			good_eyesight = !good_eyesight

		if("moth_wings")
			if(species != "Moth")
				return
			var/new_wings = input(user, "Choose your character's wings: ", "Moth Wings") as null|anything in (GLOB.moth_wings_list - "Burnt Off")
			if(!new_wings)
				return
			moth_wings = new_wings

		if("be_special")
			var/flag = text2num(href_list["flag"])
			be_special ^= (1 << flag)

		if("jobmenu")
			SetChoices(user)
			return

		if("jobclose")
			user << browse(null, "window=mob_occupation")

		if("jobselect")
			if(!href_list["job"] || !href_list["level"])
				return
			var/datum/job/job = SSjob.GetJob(href_list["job"])
			var/level = text2num(href_list["level"])
			SetJobDepartment(job, level)
			SetChoices(user)
			return

		if("jobalternative")
			if(alternate_option == GET_RANDOM_JOB)
				alternate_option = BE_MARINE
			else if(alternate_option == BE_MARINE)
				alternate_option = RETURN_TO_LOBBY
			else if(alternate_option == RETURN_TO_LOBBY)
				alternate_option = GET_RANDOM_JOB
			SetChoices(user)
			return

		if("jobreset")
			ResetJobs()
			SetChoices(user)
			return


		if("underwear")
			var/list/underwear_options
			if(gender == MALE)
				underwear_options = GLOB.underwear_m
			else
				underwear_options = GLOB.underwear_f

			var/new_underwear = input(user, "Choose your character's underwear:", "Underwear")  as null|anything in underwear_options
			if(!new_underwear)
				return
			underwear = underwear_options.Find(new_underwear)

		if("undershirt")
			var/new_undershirt = input(user, "Choose your character's undershirt:", "Undershirt") as null|anything in GLOB.undershirt_t
			if(!new_undershirt)
				return
			undershirt = GLOB.undershirt_t.Find(new_undershirt)

		if("backpack")
			var/new_backpack = input(user, "Choose your character's style of a backpack:", "Backpack Style")  as null|anything in GLOB.backpacklist
			if(!new_backpack)
				return
			backpack = GLOB.backpacklist.Find(new_backpack)

		if("loadoutadd")
			var/choice = input(user, "Select gear to add: ", "Custom Loadout") as null|anything in GLOB.gear_datums
			if(!choice)
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
			gear.Remove(href_list["gear"])
			if(!islist(gear))
				gear = list()

		if("loadoutclear")
			gear.Cut()
			if(!islist(gear))
				gear = list()

		if("ui")
			var/choice = input(user, "Please choose an UI style.", "UI Style") as null|anything in UI_STYLES
			if(!choice)
				return
			ui_style = choice

		if("uicolor")
			var/ui_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", "UI Color") as null|color
			if(!ui_style_color_new)
				return
			ui_style_color = ui_style_color_new

		if("uialpha")
			var/ui_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255", "UI Alpha") as null|num
			if(!ui_style_alpha_new)
				return
			ui_style_alpha_new = round(ui_style_alpha_new)
			ui_style_alpha = CLAMP(ui_style_alpha_new, 55, 255)

		if("hairstyle")
			var/list/valid_hairstyles = list()
			for(var/hairstyle in GLOB.hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
				if(!(species in S.species_allowed))
					continue

				valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

			var/new_h_style = input(user, "Choose your character's hair style:", "Hair Style")  as null|anything in valid_hairstyles
			if(!new_h_style)
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

			var/new_f_style = input(user, "Choose your character's facial-hair style:", "Facial Hair Style")  as null|anything in (valid_facialhairstyles + "Shaved")
			if(!new_f_style)
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
			var/choice = input(user, "Please choose your current citizenship.") as null|anything in CITIZENSHIP_CHOICES
			if(!choice)
				return
			citizenship = choice

		if("religion")
			var/choice = input(user, "Please choose a religion.") as null|anything in RELIGION_CHOICES
			if(!choice)
				return
			religion = choice

		if("corporation")
			var/new_relation = input(user, "Choose your relation to the Nanotrasen company that will appear on background checks.", "Nanotrasen Relation")  as null|anything in CORP_RELATIONS
			if(!new_relation)
				return
			nanotrasen_relation = new_relation

		if("squad")
			var/new_squad = input(user, "Choose your preferred squad.", "Preferred Squad") as null|anything in SELECTABLE_SQUADS
			if(!new_squad)
				return
			preferred_squad = new_squad

		if("records")
			SetRecords(user)
			return

		if("med_record")
			var/medmsg = input(user, "Set your medical notes here.", "Medical Records", sanitize(med_record)) as null|message
			if(!medmsg)
				return
			medmsg = copytext(sanitize(medmsg), 1, MAX_PAPER_MESSAGE_LEN)

			med_record = medmsg
			SetRecords(user)
			return

		if("sec_record")
			var/secmsg = input(user,"Set your security notes here.", "Security Records", sanitize(sec_record)) as null|message
			if(!secmsg)
				return

			secmsg = copytext(sanitize(secmsg), 1, MAX_PAPER_MESSAGE_LEN)

			sec_record = secmsg
			SetRecords(user)
			return

		if("gen_record")
			var/genmsg = input(user, "Set your employment notes here.", "Employment Records", sanitize(gen_record)) as null|message
			if(!genmsg)
				return

			genmsg = copytext(sanitize(genmsg), 1, MAX_PAPER_MESSAGE_LEN)

			gen_record = genmsg
			SetRecords(user)
			return

		if("exploit_record")
			var/exploit = input(user, "Enter information that others may want to use against you.", "Exploit Record", sanitize(exploit_record)) as null|message
			if(!exploit)
				return

			exploit = copytext(sanitize(exploit), 1, MAX_PAPER_MESSAGE_LEN)

			exploit_record = exploit
			SetRecords(user)
			return

		if("recordsclose")
			user << browse(null, "window=records")

		if("flavor_text")
			var/msg = input(user, "Give a physical description of your character.", "Flavor Text", sanitize(flavor_text)) as null|message
			if(!msg)
				return
			msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
			flavor_text = msg

		if("metadata")
			var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "OOC Notes", sanitize(metadata)) as null|message
			if(!new_metadata)
				return
			metadata = copytext(sanitize(new_metadata), 1, MAX_MESSAGE_LEN)

		if("hear_midis")
			toggles_sound ^= SOUND_MIDI

		if("lobby_music")
			toggles_sound ^= SOUND_LOBBY
			if(toggles_sound & SOUND_LOBBY && (isobserver(user) || isnewplayer(user)))
				user << sound(SSticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
			else
				user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

		if("ghost_ears")
			toggles_chat ^= CHAT_GHOSTEARS

		if("ghost_sight")
			toggles_chat ^= CHAT_GHOSTSIGHT

		if("ghost_radio")
			toggles_chat ^= CHAT_GHOSTRADIO

		if("ghost_hivemind")
			toggles_chat ^= CHAT_GHOSTHIVEMIND

		if("windowflashing")
			windowflashing = !windowflashing

	save_preferences()
	save_character()
	ShowChoices(user)
	return TRUE


/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = FALSE)
	if(random_name)
		var/datum/species/S = GLOB.all_species[species]
		real_name = S.random_name(gender)


	if(CONFIG_GET(flag/humans_need_surnames) && species == "Human")
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace || firstspace == name_length)
			real_name += " " + pick(GLOB.last_names)

	character.real_name = real_name
	character.name = character.real_name
	character.voice_name = character.real_name
	if(character.dna)
		character.dna.real_name = character.real_name

	character.flavor_text = flavor_text

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.age = age
	character.gender = gender
	character.ethnicity = ethnicity
	character.body_type = body_type

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.h_style = h_style
	character.f_style = f_style

	character.citizenship = citizenship
	character.religion = religion

	character.moth_wings = moth_wings
	character.underwear = underwear
	character.undershirt = undershirt
	character.backpack = backpack

	character.update_body()
	character.update_hair()


/datum/preferences/proc/open_load_dialog(mob/user)
	var/dat = "<html><head><title>Load Character Slot</title></head>"

	dat += "<body><center>"

	var/savefile/S = new /savefile(path)
	if(S)
		dat += "<b>Select a character slot to load</b><hr>"
		var/name
		for(var/i = 1 to MAX_SAVE_SLOTS)
			S.cd = "/character[i]"
			S["real_name"] >> name
			if(!name)
				name = "Character[i]"
			if(i == default_slot)
				name = "<b>[name]</b>"
			dat += "<a href='?_src_=prefs;preference=slot_change;num=[i];'>[name]</a><br>"

	dat += "<hr>"
	dat += "<a href ='?_src_=prefs;preference=slot_close'>Close</a><br>"
	dat += "</center>"


	winshow(user, "saves", TRUE)
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Slots</div>", 300, 390)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "saves", src)


/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")
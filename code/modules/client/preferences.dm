GLOBAL_LIST_EMPTY(preferences_datums)


/datum/preferences
	var/client/parent

	//Basics
	var/path
	var/default_slot = 1
	var/savefile_version = 0

	//Admin
	var/muted = NONE
	var/last_ip
	var/last_id
	var/updating_icon = FALSE

	//Game preferences
	var/lastchangelog = ""	//Hashed changelog
	var/ooccolor = "#b82e00"
	var/be_special = BE_SPECIAL_DEFAULT	//Special role selection
	var/ui_style = "Midnight"
	var/ui_style_color = "#ffffff"
	var/ui_style_alpha = 230
	var/toggles_chat = TOGGLES_CHAT_DEFAULT
	var/toggles_sound = TOGGLES_SOUND_DEFAULT

	var/ghost_hud = TOGGLES_GHOSTHUD_DEFAULT
	var/ghost_vision = TRUE
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_form = GHOST_DEFAULT_FORM
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION

	var/show_typing = TRUE
	var/windowflashing = TRUE
	var/hotkeys = TRUE

	// Custom Keybindings
	var/list/key_bindings = null

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
	var/preferred_slot = SLOT_S_STORE
	var/list/gear = list()
	var/list/job_preferences = list()

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

	var/list/exp = list()
	var/list/menuoptions = list()

	// Hud tooltip
	var/tooltips = TRUE


/datum/preferences/New(client/C)
	if(!istype(C))
		return

	parent = C

	if(!IsGuestKey(C.key))
		load_path(C.ckey)
		if(load_preferences() && load_character())
			return

	key_bindings = deepCopyList(GLOB.keybinding_list_by_key)

	random_character()


/datum/preferences/proc/ShowChoices(mob/user)
	if(!user?.client)
		return

	update_preview_icon()

	var/dat

	dat += {"
	<style>
	.column {
	  float: left;
	  width: 50%;
	}
	.row:after {
	  content: "";
	  display: table;
	  clear: both;
	}
	</style>
	"}

	dat += "<center>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences.</div>"

	dat += "</center>"

	if(path)
		var/savefile/S = new (path)
		if(S)
			dat += "<center>"
			var/name
			var/unspaced_slots = 0
			for(var/i = 1, i <= MAX_SAVE_SLOTS, i++)
				unspaced_slots++
				if(unspaced_slots > 4)
					dat += "<br>"
					unspaced_slots = 0
				S.cd = "/character[i]"
				S["real_name"] >> name
				if(!name)
					name = "Character[i]"
				dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
			dat += "</center>"

	dat += "<br>"

	dat += "<center>"
	dat += "<a href='?_src_=prefs;preference=jobmenu'>Set Marine Role Preferences</a><br>"
	dat += "<a href='?_src_=prefs;preference=keybindings_menu'>Keybindings</a>"
	dat += "</center>"

	dat += "<div class='row'>"
	dat += "<div class='column'>"



	dat += "<h2>Identity</h2>"

	if(is_banned_from(user.ckey, "Appearance"))
		dat += "You are banned from using custom names and appearances.<br>"

	dat += "<b>Name:</b> "
	dat += "<a href='?_src_=prefs;preference=name_real'><b>[real_name]</b></a>"
	dat += "<a href='?_src_=prefs;preference=randomize_name'>(R)</a>"
	dat += "<br>"
	dat += "Always Pick Random Name: <a href='?_src_=prefs;preference=random_name'>[random_name ? "Yes" : "No"]</a>"
	dat += "<br><br>"
	dat += "<b>Synthetic Name:</b>"
	dat += "<a href='?_src_=prefs;preference=synth_name'>[synthetic_name]</a>"
	dat += "<br>"
	dat += "<b>Synthetic Type:</b>"
	dat += "<a href='?_src_=prefs;preference=synth_type'>[synthetic_type]</a>"
	dat += "<br><br>"
	dat += "<b>Xenomorph name:</b>"
	dat += "<a href='?_src_=prefs;preference=xeno_name'>[xeno_name]</a>"
	dat += "<br><br>"



	dat += "<h2>Body</h2>"

	dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age'>[age]</a><br>"
	dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? MALE : FEMALE]</a><br>"
	dat += "<b>Ethnicity:</b> <a href='?_src_=prefs;preference=ethnicity'>[ethnicity]</a><br>"
	dat += "<b>Species:</b> <a href='?_src_=prefs;preference=species'>[species]</a><br>"
	dat += "<b>Body Type:</b> <a href='?_src_=prefs;preference=body_type'>[body_type]</a><br>"
	dat += "<b>Good Eyesight:</b> <a href='?_src_=prefs;preference=eyesight'>[good_eyesight ? "Yes" : "No"]</a><br>"
	dat += "<br>"
	dat += "<b>Hair:</b> <a href='?_src_=prefs;preference=hairstyle'>[h_style]</a> | <a href='?_src_=prefs;preference=haircolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"
	dat += "<b>Facial Hair:</b> <a href='?_src_=prefs;preference=facialstyle'>[f_style]</a> | <a href='?_src_=prefs;preference=facialcolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"
	dat += "<b>Eye:</b> <a href='?_src_=prefs;preference=eyecolor'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td>__</td></tr></table></font><br>"

	var/datum/species/current_species = GLOB.all_species[species]
	if(current_species.preferences)
		for(var/preference_id in current_species.preferences)
			dat += "<b>[current_species.preferences[preference_id]]:</b> <a href='?_src_=prefs;preference=[preference_id]'><b>[vars[preference_id]]</b></a><br>"

	dat += "<a href='?_src_=prefs;preference=random'>Randomize</a>"



	dat += "<h2>Occupation Choices:</h2>"

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
			dat += "<b>[role]:</b> <a href='?_src_=prefs;preference=bancheck;role=[role]'>BANNED</a><br>"
		else
			dat += "<b>[role]:</b> <a href='?_src_=prefs;preference=be_special;flag=[n]'>[be_special & (1 << n) ? "Yes" : "No"]</a><br>"
		n++

	dat += "<br><b>Preferred Squad:</b> <a href ='?_src_=prefs;preference=squad'>[preferred_squad]</a><br>"




	dat += "</div>"
	dat += "<div class='column'>"




	dat += "<h2>Marine Gear:</h2>"
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



	dat += "<h2>Background Information:</h2>"

	dat += "<b>Citizenship</b>: <a href ='?_src_=prefs;preference=citizenship'>[citizenship]</a><br/>"
	dat += "<b>Religion</b>: <a href ='?_src_=prefs;preference=religion'>[religion]</a><br/>"
	dat += "<b>Corporate Relation:</b> <a href ='?_src_=prefs;preference=corporation'>[nanotrasen_relation]</a><br>"
	dat += "<br>"

	if(jobban_isbanned(user, "Records"))
		dat += "<b>You are banned from using character records.</b><br>"
	else
		dat += "<a href ='?_src_=prefs;preference=records'>Character Records</a><br>"

	dat += "<a href ='?_src_=prefs;preference=flavor_text'>Character Description</a><br>"



	dat += "<h2>Game Settings:</h2>"
	dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=windowflashing'>[windowflashing ? "Yes" : "No"]</a><br>"
	dat += "<b>Hotkey mode:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Enabled" : "Disabled"]</a><br>"
	dat += "<b>Tooltips:</b> <a href='?_src_=prefs;preference=tooltips'>[(tooltips) ? "Shown" : "Hidden"]</a><br>"



	dat += "<h2>UI Customization:</h2>"
	dat += "<b>Style:</b> <a href='?_src_=prefs;preference=ui'>[ui_style]</a><br>"
	dat += "<b>Color</b>: <a href='?_src_=prefs;preference=uicolor'>[ui_style_color]</a> <table style='display:inline;' bgcolor='[ui_style_color]'><tr><td>__</td></tr></table><br>"
	dat += "<b>Alpha</b>: <a href='?_src_=prefs;preference=uialpha'>[ui_style_alpha]</a>"



	dat += "</div></div>"


	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 640, 770)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "preferences_window", src)


/datum/preferences/proc/SetChoices(mob/user, limit = 16, list/splitJobs, widthPerColumn = 305, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(!length(SSjob.occupations))
		HTML += "The job subsystem hasn't initialized yet, please try again later."
		HTML += "<center><a href='?_src_=prefs;preference=jobclose'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose marine role preferences.</b><br>"
		HTML += "<div align='center'>Left-click to raise the preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=jobclose'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, job) { window.location.href='?_src_=prefs;preference=jobselect;level=' + level + ';job=' + encodeURIComponent(job); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob
		var/datum/job/overflow = SSjob.GetJob(SSjob.overflow_role)

		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
			if(!(job.title in JOBS_REGULAR_ALL))
				continue

			index += 1
			if(index >= limit || (job.title in splitJobs))
				width += widthPerColumn
				if(index < limit && !isnull(lastJob))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(is_banned_from(user.ckey, rank))
				HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;preference=bancheck;role=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if((rank in JOBS_COMMAND) || rank == "AI")//Bold head jobs
				HTML += "<b><span class='dark'>[rank]</span></b>"
			else
				HTML += "<span class='dark'>[rank]</span>"

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "NEVER"
			var/prefLevelColor = "red"
			var/prefUpperLevel = JOBS_PRIORITY_LOW // level to assign on left click
			var/prefLowerLevel = JOBS_PRIORITY_HIGH // level to assign on right click

			switch(job_preferences[job.title])
				if(JOBS_PRIORITY_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = JOBS_PRIORITY_NEVER
					prefLowerLevel = JOBS_PRIORITY_MEDIUM
				if(JOBS_PRIORITY_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = JOBS_PRIORITY_HIGH
					prefLowerLevel = JOBS_PRIORITY_LOW
				if(JOBS_PRIORITY_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = JOBS_PRIORITY_MEDIUM
					prefLowerLevel = JOBS_PRIORITY_NEVER

			HTML += "<a class='white' href='?_src_=prefs;preference=jobselect;level=[prefUpperLevel];job=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role) //Overflow is special
				if(job_preferences[overflow.title] == JOBS_PRIORITY_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message
		switch(alternate_option)
			if(BE_OVERFLOW)
				message = "Be [SSjob.overflow_role] if preferences unavailable"
			if(GET_RANDOM_JOB)
				message = "Get random job if preferences unavailable"
			if(RETURN_TO_LOBBY)
				message = "Return to lobby if preferences unavailable"

		HTML += "<center><br><a href='?_src_=prefs;preference=jobalternative'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=jobreset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)


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
	HTML += "<a href ='?_src_=prefs;preference=recordsclose'>Done</a>"
	HTML += "</center>"


	winshow(user, "records", TRUE)
	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "records", src)



/datum/preferences/proc/ShowKeybindings(mob/user)
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] = key

	var/list/kb_categories = list()
	// Group keybinds by category
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(!(kb.category in kb_categories))
			kb_categories[kb.category] = list()
		kb_categories[kb.category] += list(kb)

	var/HTML = "<style>label { display: inline-block; width: 200px; }</style><body>"

	for(var/category in kb_categories)
		HTML += "<h3>[category]</h3>"
		for(var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			var/bound_key = user_binds[kb.name]
			bound_key = (bound_key) ? bound_key : "Unbound"

			HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key] Default: ( [kb.key] )</a>"
			HTML += "<br>"

	HTML += "<br><br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "</body>"

	winshow(user, "keybindings", TRUE)
	var/datum/browser/popup = new(user, "keybindings", "<div align='center'>Keybindings</div>", 500, 900)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "keybindings", src)


/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, var/old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	document.onkeyup = function(e) {
		var shift = e.shiftKey ? 1 : 0;
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+e.key+';shift='+shift+';alt='+alt+';ctrl='+ctrl+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)


/datum/preferences/Topic(href, href_list, hsrc)
	. = ..()
	if(.)
		return
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()


/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!istype(user) || !length(href_list))
		return

	switch(href_list["preference"])
		if("changeslot")
			if(!load_character(text2num(href_list["num"])))
				random_character()
				real_name = random_unique_name(gender)
				save_character()

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

		if("randomize_name")
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("random_name")
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
			var/new_species = input(user, "Choose your species:", "Species") as null|anything in GLOB.all_species[DEFAULT_SPECIES]
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
			UpdateJobPreference(user, href_list["job"], text2num(href_list["level"]))
			return

		if("jobalternative")
			if(alternate_option == GET_RANDOM_JOB)
				alternate_option = BE_OVERFLOW
			else if(alternate_option == BE_OVERFLOW)
				alternate_option = RETURN_TO_LOBBY
			else if(alternate_option == RETURN_TO_LOBBY)
				alternate_option = GET_RANDOM_JOB
			SetChoices(user)
			return

		if("jobreset")
			job_preferences = list()
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
			var/ui_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 230", "UI Alpha") as null|num
			if(!ui_style_alpha_new)
				return
			ui_style_alpha_new = round(ui_style_alpha_new)
			ui_style_alpha = CLAMP(ui_style_alpha_new, 55, 230)

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

		if("windowflashing")
			windowflashing = !windowflashing

		if("hotkeys")
			hotkeys = !hotkeys
			if(hotkeys)
				winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_DISABLED] mainwindow.macro=default")
			else
				winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=old_default")

		if("tooltips")
			tooltips = !tooltips
			if(!tooltips)
				closeToolTip(usr)
			else if(!usr.client.tooltips && tooltips)
				usr.client.tooltips = new /datum/tooltip(usr.client)

		if("keybindings_menu")
			ShowKeybindings(user)
			return

		if("keybindings_capture")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
			var/old_key = href_list["old_key"]
			CaptureKeybinding(user, kb, old_key)
			return

		if("keybindings_set")
			var/kb_name = href_list["keybinding"]
			if(!kb_name)
				user << browse(null, "window=capturekeypress")
				ShowKeybindings(user)
				return

			var/clear_key = text2num(href_list["clear_key"])
			var/old_key = href_list["old_key"]
			if(clear_key)
				if(old_key != "Unbound") // if it was already set
					key_bindings[old_key] -= kb_name
					key_bindings["Unbound"] += list(kb_name)
				user << browse(null, "window=capturekeypress")
				save_preferences()
				ShowKeybindings(user)
				return

			var/key = href_list["key"]
			var/numpad = text2num(href_list["numpad"])
			var/AltMod = text2num(href_list["alt"]) ? "Alt-" : ""
			var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl-" : ""
			var/ShiftMod = text2num(href_list["shift"]) ? "Shift-" : ""
			// var/key_code = text2num(href_list["key_code"])

			var/new_key = uppertext(key)

			// This is a mapping from JS keys to Byond - ref: https://keycode.info/
			var/list/_kbMap = list(
				"INSERT" = "Insert", "HOME" = "Northwest", "PAGEUP" = "Northeast",
				"DEL" = "Delete", "END" = "Southwest",  "PAGEDOWN" = "Southeast",
				"SPACEBAR" = "Space", "ALT" = "Alt", "SHIFT" = "Shift", "CONTROL" = "Ctrl"
			)
			new_key = _kbMap[new_key] ? _kbMap[new_key] : new_key

			if (numpad)
				new_key = "Numpad[new_key]"

			var/full_key = "[AltMod][CtrlMod][ShiftMod][new_key]"
			key_bindings[old_key] -= kb_name
			key_bindings[full_key] += list(kb_name)
			key_bindings[full_key] = sortList(key_bindings[full_key])

			user << browse(null, "window=capturekeypress")
			save_preferences()
			ShowKeybindings(user)
			return

		if("keybindings_done")
			user << browse(null, "window=keybindings")

		if("keybindings_reset")
			key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
			save_preferences()
			ShowKeybindings(user)
			return

		if("bancheck")
			var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["role"])
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
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["role"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")

	save_preferences()
	save_character()
	ShowChoices(user)
	return TRUE


/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob || !length(SSjob.occupations))
		return

	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == SSjob.overflow_role)
		if(job_preferences[job.title] == JOBS_PRIORITY_LOW)
			desiredLvl = JOBS_PRIORITY_NEVER
		else
			desiredLvl = JOBS_PRIORITY_LOW

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return TRUE


/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if(!job)
		return FALSE

	if(level == JOBS_PRIORITY_HIGH)
		for(var/j in job_preferences)
			if(job_preferences[j] == JOBS_PRIORITY_HIGH)
				job_preferences[j] = JOBS_PRIORITY_MEDIUM

	job_preferences[job.title] = level
	return TRUE
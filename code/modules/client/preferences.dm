//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

var/global/list/special_roles = list(
	"Xenomorph" = 1,
	"Xenomorph Queen" = 1,
	"Survivor" = 1,
	"Responder" = 1,
	"Predator" = 1,
	"WO Commander" = 1

	// "wizard" = IS_MODE_COMPILED("wizard"),               // 3
	// "malf AI" = IS_MODE_COMPILED("malfunction"),         // 4
	// "revolutionary" = IS_MODE_COMPILED("revolution"),    // 5
 	// "traitor" = IS_MODE_COMPILED("traitor"),             // 0
	// "operative" = IS_MODE_COMPILED("nuclear"),           // 1
	// "cultist" = IS_MODE_COMPILED("cult"),                // 8
	// "infested monkey" = IS_MODE_COMPILED("monkey"),      // 9
	// "ninja" = "true",                                    // 10
	// "vox raider" = IS_MODE_COMPILED("heist"),            // 11
	// "mutineer" = IS_MODE_COMPILED("mutiny"),             // 13
	// "changeling" = IS_MODE_COMPILED("changeling"),       // 2
)

var/const/MAX_SAVE_SLOTS = 10

datum/preferences
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/savefile_version = 0

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id
	var/updating_icon = 0

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/be_special = 0					//Special role selection
	var/UI_style = "Midnight"
	var/toggles_chat = TOGGLES_CHAT_DEFAULT
	var/toggles_sound = TOGGLES_SOUND_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255

	//Synthetic specific preferences
	var/synthetic_name = "Undefined"
	var/synthetic_type = "Synthetic"
	//Predator specific preferences.
	var/predator_name = "Undefined"
	var/predator_gender = MALE
	var/predator_age = 100
	var/predator_mask_type = 1
	var/predator_armor_type = 1
	var/predator_boot_type = 1

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 18						//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/underwear = 1					//underwear type
	var/undershirt = 1					//undershirt type
	var/backbag = 2						//backpack type
	var/h_style = "Crewcut"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color

	var/r_skin = 0						//Skin color
	var/g_skin = 0						//Skin color
	var/b_skin = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"               //Species datum to use.
	var/ethnicity = "Western"			// Ethnicity
	var/body_type = "Mesomorphic (Average)" // Body Type
	var/language = "None"				//Secondary language
	var/list/gear						//Custom/fluff item loadout.
	var/preferred_squad = "None"

		//Some faction information.
	var/home_system = "Unset"           //System of birth.
	var/citizenship = "United Americas (United States)" //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_command_high = 0
	var/job_command_med = 0
	var/job_command_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engi_high = 0
	var/job_engi_med = 0
	var/job_engi_low = 0

	var/job_marines_high = 0
	var/job_marines_med = 0
	var/job_marines_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 1 //Be a marine.

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/list/flavor_texts = list()

	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/disabilities = 0

	var/nanotrasen_relation = "Neutral"

	var/uplinklocation = "PDA"

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

/datum/preferences/New(client/C)
	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			if(load_preferences())
				if(load_character())
					return
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender)
	gear = list()

/datum/preferences/proc/ZeroSkills(var/forced = 0)
	for(var/V in SKILLS) for(var/datum/skill/S in SKILLS[V])
		if(!skills.Find(S.ID) || forced)
			skills[S.ID] = SKILL_NONE

/datum/preferences/proc/CalculateSkillPoints()
	used_skillpoints = 0
	for(var/V in SKILLS) for(var/datum/skill/S in SKILLS[V])
		var/multiplier = 1
		switch(skills[S.ID])
			if(SKILL_NONE)
				used_skillpoints += 0 * multiplier
			if(SKILL_BASIC)
				used_skillpoints += 1 * multiplier
			if(SKILL_ADEPT)
				// secondary skills cost less
				if(S.secondary)
					used_skillpoints += 1 * multiplier
				else
					used_skillpoints += 3 * multiplier
			if(SKILL_EXPERT)
				// secondary skills cost less
				if(S.secondary)
					used_skillpoints += 3 * multiplier
				else
					used_skillpoints += 6 * multiplier

/datum/preferences/proc/GetSkillClass(points)
	// skill classes describe how your character compares in total points
	var/original_points = points
	points -= min(round((age - 20) / 2.5), 4) // every 2.5 years after 20, one extra skillpoint
	if(age > 30)
		points -= round((age - 30) / 5) // every 5 years after 30, one extra skillpoint
	if(original_points > 0 && points <= 0) points = 1
	switch(points)
		if(0)
			return "Unconfigured"
		if(1 to 3)
			return "Terrifying"
		if(4 to 6)
			return "Below Average"
		if(7 to 10)
			return "Average"
		if(11 to 14)
			return "Above Average"
		if(15 to 18)
			return "Exceptional"
		if(19 to 24)
			return "Genius"
		if(24 to 1000)
			return "God"

/datum/preferences/proc/SetSkills(mob/user)
	if(SKILLS == null)
		setup_skills()

	if(skills.len == 0)
		ZeroSkills()


	var/HTML = "<body>"
	HTML += "<b>Select your Skills</b><br>"
	HTML += "Current skill level: <b>[GetSkillClass(used_skillpoints)]</b> ([used_skillpoints])<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=skills;skill_select=preconfigured;\">Use preconfigured skillset</a><br>"
	HTML += "<table>"
	for(var/V in SKILLS)
		HTML += "<tr><th colspan = 5><b>[V]</b>"
		HTML += "</th></tr>"
		for(var/datum/skill/S in SKILLS[V])
			var/level = skills[S.ID]
			HTML += "<tr style='text-align:left;'>"
			HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skill_select=info;skillinfo=\ref[S]'>[S.name]</a></th>"
			HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skill_select=set;setskill=\ref[S];newvalue=[SKILL_NONE]'><font color=[(level == SKILL_NONE) ? "red" : "black"]>\[Untrained\]</font></a></th>"
			// secondary skills don't have an amateur level
			if(S.secondary)
				HTML += "<th></th>"
			else
				HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skill_select=set;setskill=\ref[S];newvalue=[SKILL_BASIC]'><font color=[(level == SKILL_BASIC) ? "red" : "black"]>\[Amateur\]</font></a></th>"
			HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skill_select=set;setskill=\ref[S];newvalue=[SKILL_ADEPT]'><font color=[(level == SKILL_ADEPT) ? "red" : "black"]>\[Trained\]</font></a></th>"
			HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skill_select=set;setskill=\ref[S];newvalue=[SKILL_EXPERT]'><font color=[(level == SKILL_EXPERT) ? "red" : "black"]>\[Professional\]</font></a></th>"
			HTML += "</tr>"
	HTML += "</table>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=skills;skill_select=cancel;\">\[Done\]</a>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=show_skills;size=600x800")
	return

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)	return
	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")

	var/dat = "<html><head><style>"
	dat += "#wrapper 		{position: relative; width: 625px; height: 200px; margin: 0 auto;}"
	dat += "#preview		{position: absolute; top: 30px; left: 300px;}"
	dat += "#right			{position: absolute; top: 201px; left: 300px;}"
	dat += "</style></head>"
	dat += "<body>"

	if(path)
		dat += "<center>"
		dat += "Slot <b>[slot_name]</b> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>"
		dat += "</center>"
	else
		dat += "Please create an account to save your preferences."

	//dat += "</center><hr><table><tr><td width='340px' height='350px'>"
	if(RoleAuthority.roles_whitelist[user.ckey] & WHITELIST_PREDATOR)
		dat += "<br><b>Yautja name:</b> <a href='?_src_=prefs;preference=pred_name;task=input'>[predator_name]</a><br>"
		dat += "<b>Yautja gender:</b> <a href='?_src_=prefs;preference=pred_gender;task=input'>[predator_gender == MALE ? "Male" : "Female"]</a><br>"
		dat += "<b>Yautja age:</b> <a href='?_src_=prefs;preference=pred_age;task=input'>[predator_age]</a><br>"
		dat += "<b>Mask style:</b> <a href='?_src_=prefs;preference=pred_mask_type;task=input'>([predator_mask_type])</a><br>"
		dat += "<b>Armor style:</b> <a href='?_src_=prefs;preference=pred_armor_type;task=input'>([predator_armor_type])</a><br>"
		dat += "<b>Greave style:</b> <a href='?_src_=prefs;preference=pred_boot_type;task=input'>([predator_boot_type])</a><br><br>"
	if(RoleAuthority.roles_whitelist[user.ckey] & WHITELIST_SYNTHETIC)
		dat += "<br><b>Synthetic name:</b> <a href='?_src_=prefs;preference=synth_name;task=input'>[synthetic_name]</a><br>"
		dat += "<br><b>Synthetic Type:</b> <a href='?_src_=prefs;preference=synth_type;task=input'>[synthetic_type]</a><br>"

	dat += "<div id='wrapper'>"
	dat += "<big><big><b>Name:</b> "
	dat += "<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a>"
	dat += " (<a href='?_src_=prefs;preference=name;task=random'>&reg</A>)</big></big>"
	dat += "<br>"
	dat += "Always Pick Random Name: <a href='?_src_=prefs;preference=name'>[be_random_name ? "Yes" : "No"]</a>"
	dat += "<br><br>"


	//dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>"

	//dat += "</td><td width='300px' height='300px'>"


	dat += "<big><b><u>Physical Information:</u></b>"
	dat += " (<a href='?_src_=prefs;preference=all;task=random'>&reg;</A>)</big>"
	dat += "<br>"
	dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'><b>[age]</b></a><br>"
	dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
	dat += "<b>Ethnicity:</b> <a href='?_src_=prefs;preference=ethnicity;task=input'><b>[ethnicity]</b></a><br>"
	dat += "<b>Body Type:</b> <a href='?_src_=prefs;preference=body_type;task=input'><b>[body_type]</b></a><br>"
	dat += "<b>Poor Eyesight:</b> <a href='?_src_=prefs;preference=disabilities'><b>[disabilities == 0 ? "No" : "Yes"]</b></a><br>"
	dat += "<br>"

	dat += "<big><b><u>Occupation Choices:</u></b></big>"
	dat += "<br>"

	var/n = 0

	for (var/i in special_roles)
		var/ban_check_name

		switch (special_roles[i])
			if ("Xenomorph")
				ban_check_name = "Alien"

			if ("Xenomorph Queen")
				ban_check_name = "Queen"

			if ("Survivor")
				ban_check_name = "Survivor"

			if ("Predator")
				ban_check_name = "Predator"

			if ("WO Commander")
				ban_check_name = "WO Commander"

		if(jobban_isbanned(user, ban_check_name))
			dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
		else
			dat += "<b>Be [i]:</b> <a href='?_src_=prefs;preference=be_special;num=[n]'><b>[src.be_special&(1<<n) ? "Yes" : "No"]</b></a><br>"
		n++

	dat += "\t<a href='?_src_=prefs;preference=job;task=menu'><b>Set Marine Role Preferences</b></a><br>"
	dat += "<br>"

	dat += "<big><b><u>Marine Gear:</u></b></big><br>"
	if(gender == MALE)
		dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_m[underwear]]</b></a><br>"
	else
		dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_f[underwear]]</b></a><br>"

	dat += "<b>Undershirt:</b> <a href='?_src_=prefs;preference=undershirt;task=input'><b>[undershirt_t[undershirt]]</b></a><br>"

	dat += "<b>Backpack Type:</b> <a href ='?_src_=prefs;preference=bag;task=input'><b>[backbaglist[backbag]]</b></a><br>"

	dat += "<b>Custom Loadout:</b> "
	var/total_cost = 0

	if(!islist(gear)) gear = list()

	if(gear && gear.len)
		dat += "<br>"
		for(var/i = 1; i <= gear.len; i++)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G)
				total_cost += G.cost
				dat += "[gear[i]] ([G.cost] points) <a href='byond://?src=\ref[user];preference=loadout;task=remove;gear=[i]'>\[remove\]</a><br>"

		dat += "<b>Used:</b> [total_cost] points."
	else
		dat += "None"

	if(total_cost < MAX_GEAR_COST)
		dat += " <a href='byond://?src=\ref[user];preference=loadout;task=input'>\[add\]</a>"
		if(gear && gear.len)
			dat += " <a href='byond://?src=\ref[user];preference=loadout;task=clear'>\[clear\]</a>"

	dat += "<br><br>"

	dat += "<big><b><u>UI Customization:</u></b></big><br>"
	dat += "<b>Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
	dat += "<b>Color</b>: <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <table style='display:inline;' bgcolor='[UI_style_color]'><tr><td>__</td></tr></table><br>"
	dat += "<b>Alpha</b>: <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a>"


	dat += "<div id='preview'>"
	dat += "<img src=previewicon.png width=64 height=64><img src=previewicon2.png width=64 height=64 margin-left=auto margin-right=auto>"
	//dat += "</div>"
	dat += "<br>"
	dat += "<b>Hair:</b> <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a> | <a href='?_src_=prefs;preference=hair;task=input'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"

	dat += "<b>Facial Hair:</b> <a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a> | <a href='?_src_=prefs;preference=facial;task=input'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td>__</td></tr></table></font> "
	dat += "<br>"

	dat += "<b>Eye:</b> <a href='?_src_=prefs;preference=eyes;task=input'>Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td>__</td></tr></table></font><br>"
	dat += "</div>"

	dat += "<div id='right'>"
	dat += "<big><b><u>Background Information:</u></b></big><br>"
	//dat += "<b>Home system</b>: <a href='byond://?src=\ref[user];preference=home_system;task=input'>[home_system]</a><br/>"
	dat += "<b>Citizenship</b>: <a href='byond://?src=\ref[user];preference=citizenship;task=input'>[citizenship]</a><br/>"
	// dat += "<b>Faction</b>: <a href='byond://?src=\ref[user];preference=faction;task=input'>[faction]</a><br/>"
	dat += "<b>Religion</b>: <a href='byond://?src=\ref[user];preference=religion;task=input'>[religion]</a><br/>"

	dat += "<b>Corporate Relation:</b> <a href ='?_src_=prefs;preference=nt_relation;task=input'><b>[nanotrasen_relation]</b></a><br>"
	dat += "<b>Preferred Squad:</b> <a href ='?_src_=prefs;preference=prefsquad;task=input'><b>[preferred_squad]</b></a><br>"

	if(jobban_isbanned(user, "Records"))
		dat += "<b>You are banned from using character records.</b><br>"
	else
		dat += "<b><a href=\"byond://?src=\ref[user];preference=records;record=1\">Character Records</a></b><br>"

	dat += "<a href='byond://?src=\ref[user];preference=flavor_text;task=open'><b>Character Description</b></a><br>"
	dat += "<br>"

	dat += "<big><b><u>Game Settings:</u></b></big><br>"
	dat += "<b>Play Admin Midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(toggles_sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(toggles_sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles_chat & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
	dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles_chat & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
	dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles_chat & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
	dat += "<b>Ghost Hivemind:</b> <a href='?_src_=prefs;preference=ghost_hivemind'><b>[(toggles_chat & CHAT_GHOSTHIVEMIND) ? "Show Hivemind" : "Hide Hivemind"]</b></a><br>"

	if(config.allow_Metadata)
		dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"

	dat += "<br>"
	dat += "</div>"

	dat += "<br>"

	dat += "</div></body></html>"
	user << browse(dat, "window=preferences;size=670x830")

/datum/preferences/proc/SetChoices(mob/user, limit = 22, list/splitJobs = list(), width = 450, height = 650)
	if(!RoleAuthority) return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.


	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
	HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	var/datum/job/job
	var/i
	for(i in RoleAuthority.roles_for_mode)
		job = RoleAuthority.roles_for_mode[i]
		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/j = 0, j < (limit - index), j += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		lastJob = job
		if(jobban_isbanned(user, job.title))
			HTML += "<del>[job.disp_title]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		else if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[job.disp_title]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
//		if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
//			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
//			continue
		else if(job.flags_startup_parameters & ROLE_WHITELISTED && !(RoleAuthority.roles_whitelist[user.ckey] & job.flags_whitelist))
			HTML += "<del>[job.disp_title]</del></td><td> \[WHITELISTED]</td></tr>"
			continue
		else HTML += (job.title in ROLES_COMMAND) || job.title == "AI" ? "<b>[job.disp_title]</b>" : "[job.disp_title]"

		HTML += "</td><td width='40%'>"

		HTML += "<a href='?_src_=prefs;preference=job;task=input;text=[job.title]'>"

//		if(rank == "Assistant")//Assistant is special
//			if(job_civilian_low & ASSISTANT)
//				HTML += " <font color=green>\[Yes]</font>"
//			else
//				HTML += " <font color=red>\[No]</font>"
//			HTML += "</a></td></tr>"
//			continue

		if(GetJobDepartment(job, 1) & job.flag)
			HTML += " <font color=blue>\[High]</font>"
		else if(GetJobDepartment(job, 2) & job.flag)
			HTML += " <font color=green>\[Medium]</font>"
		else if(GetJobDepartment(job, 3) & job.flag)
			HTML += " <font color=orange>\[Low]</font>"
		else
			HTML += " <font color=red>\[NEVER]</font>"
		if(job.alt_titles)
			HTML += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
		HTML += "</a></td></tr>"

	HTML += "</td'></tr></table>"
	HTML += "</center></table>"

	if(user.client.prefs) //Just makin sure
		if(user.client.prefs.alternate_option == GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=green>Get random job if preferences unavailable</font></a></u></center><br>"
		if(user.client.prefs.alternate_option == BE_ASSISTANT)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=red>Be marine if preference unavailable</font></a></u></center><br>"
		if(user.client.prefs.alternate_option == RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=purple>Return to lobby if preference unavailable</font></a></u></center><br>"

	HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>\[Reset\]</a></center>"
	HTML += "</tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	return

/datum/preferences/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose disabilities</b><br>"

	HTML += "Need Glasses? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=0\">[disabilities & (1<<0) ? "Yes" : "No"]</a><br>"
	HTML += "Seizures? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=1\">[disabilities & (1<<1) ? "Yes" : "No"]</a><br>"
	HTML += "Coughing? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=2\">[disabilities & (1<<2) ? "Yes" : "No"]</a><br>"
	HTML += "Tourettes/Twitching? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=3\">[disabilities & (1<<3) ? "Yes" : "No"]</a><br>"
	HTML += "Nervousness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=4\">[disabilities & (1<<4) ? "Yes" : "No"]</a><br>"
	HTML += "Deafness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=5\">[disabilities & (1<<5) ? "Yes" : "No"]</a><br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preferences=1;disabilities=-2\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"

	HTML += TextPreview(med_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	HTML += TextPreview(gen_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	HTML += TextPreview(sec_record,40)

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return

/datum/preferences/proc/SetAntagoptions(mob/user)
	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Antagonist Options</b> <hr />"
	HTML += "<br>"
	HTML +="Uplink Type : <b><a href='?src=\ref[user];preference=antagoptions;antagtask=uplinktype;active=1'>[uplinklocation]</a></b>"
	HTML +="<br>"
	HTML +="Exploitable information about you : "
	HTML += "<br>"
	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML +="<b><a href=\"byond://?src=\ref[user];preference=records;task=exploitable_record\">[TextPreview(exploit_record,40)]</a></b>"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='?src=\ref[user];preference=antagoptions;antagtask=done;active=1'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=antagoptions")
	return

/datum/preferences/proc/SetFlavorText(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavor Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	/*
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	*/
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=flavor_text;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=flavor_text;size=430x300")
	return

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	if(player_alt_titles) . = player_alt_titles[job.title]

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = RoleAuthority.roles_for_mode[role]
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

//	if(role == "Assistant")
//		if(job_civilian_low & job.flag)
//			job_civilian_low &= ~job.flag
//		else
//			job_civilian_low |= job.flag
//		SetChoices(user)
//		return 1

	if(GetJobDepartment(job, 1) & job.flag)
		SetJobDepartment(job, 1)
	else if(GetJobDepartment(job, 2) & job.flag)
		SetJobDepartment(job, 2)
	else if(GetJobDepartment(job, 3) & job.flag)
		SetJobDepartment(job, 3)
	else//job = Never
		SetJobDepartment(job, 4)

	//var/list/L = list(ROLEGROUP_MARINE_COMMAND, ROLEGROUP_MARINE_ENGINEERING, ROLEGROUP_MARINE_MED_SCIENCE, ROLEGROUP_MARINE_SQUAD_MARINES)
	SetChoices(user)
	return 1

/datum/preferences/proc/ResetJobs()
	job_command_high = 0
	job_command_med = 0
	job_command_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engi_high = 0
	job_engi_med = 0
	job_engi_low = 0

	job_marines_high = 0
	job_marines_med = 0
	job_marines_low = 0

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(ROLEGROUP_MARINE_COMMAND)
			switch(level)
				if(1)
					return job_command_high
				if(2)
					return job_command_med
				if(3)
					return job_command_low
		if(ROLEGROUP_MARINE_MED_SCIENCE)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ROLEGROUP_MARINE_ENGINEERING)
			switch(level)
				if(1)
					return job_engi_high
				if(2)
					return job_engi_med
				if(3)
					return job_engi_low
		if(ROLEGROUP_MARINE_SQUAD_MARINES)
			switch(level)
				if(1)
					return job_marines_high
				if(2)
					return job_marines_med
				if(3)
					return job_marines_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_command_high = 0
			job_medsci_high = 0
			job_engi_high = 0
			job_marines_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_command_med |= job_command_high
			job_medsci_med |= job_medsci_high
			job_engi_med |= job_engi_high
			job_marines_med |= job_marines_high
			job_command_high = 0
			job_medsci_high = 0
			job_engi_high = 0
			job_marines_high = 0

	switch(job.department_flag)
		if(ROLEGROUP_MARINE_COMMAND)
			switch(level)
				if(2)
					job_command_high = job.flag
					job_command_med &= ~job.flag
				if(3)
					job_command_med |= job.flag
					job_command_low &= ~job.flag
				else
					job_command_low |= job.flag
		if(ROLEGROUP_MARINE_MED_SCIENCE)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ROLEGROUP_MARINE_ENGINEERING)
			switch(level)
				if(2)
					job_engi_high = job.flag
					job_engi_med &= ~job.flag
				if(3)
					job_engi_med |= job.flag
					job_engi_low &= ~job.flag
				else
					job_engi_low |= job.flag
		if(ROLEGROUP_MARINE_SQUAD_MARINES)
			switch(level)
				if(2)
					job_marines_high = job.flag
					job_marines_med &= ~job.flag
				if(3)
					job_marines_med |= job.flag
					job_marines_low &= ~job.flag
				else
					job_marines_low |= job.flag
	return 1

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!istype(user, /mob/new_player) && !istype(user, /mob/dead/observer)) return

	switch(href_list["preference"])
		if("job")
			switch(href_list["task"])
				if("close")
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				if("reset")
					ResetJobs()
					SetChoices(user)
				if("random")
					if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
						alternate_option += 1
					else if(alternate_option == RETURN_TO_LOBBY)
						alternate_option = 0
					else
						return 0
					SetChoices(user)
				if ("alt_title")
					var/datum/job/job = locate(href_list["job"])
					if (job)
						var/choices = list(job.title) + job.alt_titles
						var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices|null
						if(choice)
							SetPlayerAltTitle(job, choice)
							SetChoices(user)
				if("input")
					SetJob(user, href_list["text"])
				else
					SetChoices(user)
			return 1
		if("skills")
			switch(href_list["skill_select"])
				if("cancel")
					user << browse(null, "window=show_skills")
					ShowChoices(user)
				if("skill")
					var/datum/skill/S = locate(href_list["skillinfo"])
					var/HTML = "<b>[S.name]</b><br>[S.desc]"
					user << browse(HTML, "window=\ref[user]skillinfo")
				if("set")
					var/datum/skill/S = locate(href_list["setskill"])
					var/value = text2num(href_list["newvalue"])
					skills[S.ID] = value
					CalculateSkillPoints()
					SetSkills(user)
				if("preconfigured")
					var/selected = input(user, "Select a skillset", "Skillset") as null|anything in SKILL_PRE
					if(!selected) return

					ZeroSkills(1)
					for(var/V in SKILL_PRE[selected])
						if(V == "field")
							skill_specialization = SKILL_PRE[selected]["field"]
							continue
						skills[V] = SKILL_PRE[selected][V]
					CalculateSkillPoints()

					SetSkills(user)
				else SetSkills(user)

			return 1
		if("loadout")
			switch(href_list["task"])
				if("input")

					var/list/valid_gear_choices = list()

					for(var/gear_name in gear_datums)
						var/datum/gear/G = gear_datums[gear_name]
						if(G.whitelisted && !is_alien_whitelisted(user, G.whitelisted))
							continue
						valid_gear_choices += gear_name

					var/choice = input(user, "Select gear to add: ") as null|anything in valid_gear_choices

					if(choice && gear_datums[choice])

						var/total_cost = 0

						if(isnull(gear) || !islist(gear)) gear = list()

						if(gear && gear.len)
							for(var/gear_name in gear)
								if(gear_datums[gear_name])
									var/datum/gear/G = gear_datums[gear_name]
									total_cost += G.cost

						var/datum/gear/C = gear_datums[choice]
						total_cost += C.cost
						if(C && total_cost <= MAX_GEAR_COST)
							gear += choice
							user << "<span class='notice'>Added \the '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>"
						else
							user << "<span class='warning'>Adding \the '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>"

				if("remove")
					var/i_remove = text2num(href_list["gear"])
					if(i_remove < 1 || i_remove > gear.len) return
					gear.Cut(i_remove, i_remove + 1)

				if("clear")
					gear.Cut()

		if("flavor_text")
			switch(href_list["task"])
				if("open")
					SetFlavorText(user)
					return
				if("done")
					user << browse(null, "window=flavor_text")
					ShowChoices(user)
					return
				if("general")
					var/msg = input(usr,"Give a physical description of your character. This will be shown regardless of clothing.","Flavor Text",html_decode(flavor_texts[href_list["task"]])) as message
					if(msg != null)
						msg = copytext(msg, 1, 256)
						msg = html_encode(msg)
					flavor_texts[href_list["task"]] = msg
				else
					var/msg = input(usr,"Set the flavor text for your [href_list["task"]].","Flavor Text",html_decode(flavor_texts[href_list["task"]])) as message
					if(msg != null)
						msg = copytext(msg, 1, 256)
						msg = html_encode(msg)
					flavor_texts[href_list["task"]] = msg
			SetFlavorText(user)
			return

		if("records")
			if(text2num(href_list["record"]) >= 1)
				SetRecords(user)
				return
			else
				user << browse(null, "window=records")

			switch(href_list["task"])
				if("med_record")
					var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

					if(medmsg != null)
						medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
						medmsg = html_encode(medmsg)

						med_record = medmsg
						SetRecords(user)

				if("sec_record")
					var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

					if(secmsg != null)
						secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
						secmsg = html_encode(secmsg)

						sec_record = secmsg
						SetRecords(user)
				if("gen_record")
					var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message

					if(genmsg != null)
						genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
						genmsg = html_encode(genmsg)

						gen_record = genmsg
						SetRecords(user)

				if("exploitable_record")
					var/exploitmsg = input(usr,"Set exploitable information about you here.","Exploitable Information",html_decode(exploit_record)) as message

					if(exploitmsg != null)
						exploitmsg = copytext(exploitmsg, 1, MAX_PAPER_MESSAGE_LEN)
						exploitmsg = html_encode(exploitmsg)

						exploit_record = exploitmsg
						SetAntagoptions(user)

		if("antagoptions")
			if(text2num(href_list["active"]) == 0)
				SetAntagoptions(user)
				return
			switch(href_list["antagtask"])
				if ("uplinktype")
					switch(uplinklocation)
						if("PDA") uplinklocation = "Headset"
						if("Headset") uplinklocation = "None"
						else uplinklocation = "PDA"
					SetAntagoptions(user)
				if ("done")
					user << browse(null, "window=antagoptions")
					ShowChoices(user)
			return 1

	switch (href_list["task"])
		if ("random")
			switch (href_list["preference"])
				if ("name")
					real_name = random_name(gender)
				if ("age")
					age = rand(AGE_MIN, AGE_MAX)
				if ("ethnicity")
					ethnicity = random_ethnicity()
				if ("body_type")
					body_type = random_body_type()
				if ("hair")
					r_hair = rand(0,255)
					g_hair = rand(0,255)
					b_hair = rand(0,255)
				if ("h_style")
					h_style = random_hair_style(gender, species)
				if ("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if ("f_style")
					f_style = random_facial_hair_style(gender, species)
				if ("underwear")
					underwear = rand(1,underwear_m.len)
					ShowChoices(user)
				if ("undershirt")
					undershirt = rand(1,undershirt_t.len)
					ShowChoices(user)
				if ("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)

				if ("s_color")
					r_skin = rand(0,255)
					g_skin = rand(0,255)
					b_skin = rand(0,255)
				if ("bag")
					backbag = rand(1,4)

				if ("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference")  as text|null
					if (!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name)
							real_name = new_name
						else
							user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("synth_name")
					var/raw_name = input(user, "Choose your Synthetic's name:", "Character Preference")  as text|null
					if(raw_name) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name) synthetic_name = new_name
						else user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"
				if("synth_type")
					var/new_synth_type = input(user, "Choose your model of synthetic:", "Make and Model") as null|anything in synth_types
					if(new_synth_type) synthetic_type = new_synth_type
				if("pred_name")
					var/raw_name = input(user, "Choose your Predator's name:", "Character Preference")  as text|null
					if(raw_name) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name) predator_name = new_name
						else user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"
				if("pred_gender")
					predator_gender = predator_gender == MALE ? FEMALE : MALE
				if("pred_age")
					var/new_predator_age = input(user, "Choose your Predator's age(20 to 10000):", "Character Preference") as num|null
					if(new_predator_age) predator_age = max(min( round(text2num(new_predator_age)), 10000),20)
				if("pred_mask_type")
					var/new_predator_mask_type = input(user, "Choose your mask type:\n(1-7)", "Mask Selection") as num|null
					if(new_predator_mask_type) predator_mask_type = round(text2num(new_predator_mask_type))
				if("pred_armor_type")
					var/new_predator_armor_type = input(user, "Choose your armor type:\n(1-5)", "Armor Selection") as num|null
					if(new_predator_armor_type) predator_armor_type = round(text2num(new_predator_armor_type))
				if("pred_boot_type")
					var/new_predator_boot_type = input(user, "Choose your greaves type:\n(1-3)", "Greave Selection") as num|null
					if(new_predator_boot_type) predator_boot_type = round(text2num(new_predator_boot_type))

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("language")
					var/languages_available
					var/list/new_languages = list("None")
					var/datum/species/S = all_species[species]

					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))||(S && (L in S.secondary_langs))))
								new_languages += lang

								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if(!(lang.flags & RESTRICTED))
								new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				/*
				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type
				*/

				if("hair")
					if(species == "Human" || species == "Unathi" || species == "Tajara" || species == "Skrell")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if( !(species in S.species_allowed))
							continue

						valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if ("ethnicity")
					var/new_ethnicity = input(user, "Choose your character's ethnicity:", "Character Preferences") as null|anything in ethnicities_list

					if (new_ethnicity)
						ethnicity = new_ethnicity

				if ("body_type")
					var/new_body_type = input(user, "Choose your character's body type:", "Character Preferences") as null|anything in body_types_list

					if (new_body_type)
						body_type = new_body_type

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as color|null
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if( !(species in S.species_allowed))
							continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)
					ShowChoices(user)

				if("undershirt")
					var/list/undershirt_options
					undershirt_options = undershirt_t

					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_options
					if (new_undershirt)
						undershirt = undershirt_options.Find(new_undershirt)
					ShowChoices(user)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))


				if("skin")
					if(species == "Unathi" || species == "Tajara" || species == "Skrell")
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference") as color|null
						if(new_skin)
							r_skin = hex2num(copytext(new_skin, 2, 4))
							g_skin = hex2num(copytext(new_skin, 4, 6))
							b_skin = hex2num(copytext(new_skin, 6, 8))

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to the Weyland-Yutani company. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("prefsquad")
					var/new_pref_squad = input(user, "Choose your preferred squad.", "Character Preference")  as null|anything in list("Alpha", "Bravo", "Charlie", "Delta", "None")
					if(new_pref_squad)
						preferred_squad = new_pref_squad

				if("disabilities")
					if(text2num(href_list["disabilities"]) >= -1)
						if(text2num(href_list["disabilities"]) >= 0)
							disabilities ^= (1<<text2num(href_list["disabilities"])) //MAGIC
						SetDisabilities(user)
						return
					else
						user << browse(null, "window=disabil")

				if("limbs")
					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					switch(limb_name)
						if("Left Leg")
							limb = "l_leg"
							second_limb = "l_foot"
						if("Right Leg")
							limb = "r_leg"
							second_limb = "r_foot"
						if("Left Arm")
							limb = "l_arm"
							second_limb = "l_hand"
						if("Right Arm")
							limb = "r_arm"
							second_limb = "r_hand"
						if("Left Foot")
							limb = "l_foot"
							third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Prothesis") //"Amputated"
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
//						if("Amputated")
//							organ_data[limb] = "amputated"
//							if(second_limb)
//								organ_data[second_limb] = "amputated"
						if("Prothesis")
							organ_data[limb] = "cyborg"
							if(second_limb)
								organ_data[second_limb] = "cyborg"
							if(third_limb && organ_data[third_limb] == "amputated")
								organ_data[third_limb] = null
				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
					if(!organ_name) return

					var/organ = null
					switch(organ_name)
						if("Heart")
							organ = "heart"
						if("Eyes")
							organ = "eyes"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Assisted")
							organ_data[organ] = "assisted"
						if("Mechanical")
							organ_data[organ] = "mechanical"

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return

				if("spawnpoint")
					var/list/spawnkeys = list()
					for(var/S in spawntypes)
						spawnkeys += S
					var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
					if(!choice || !spawntypes[choice])
						spawnpoint = "Arrivals Shuttle"
						return
					spawnpoint = choice

				if("home_system")
					var/choice = input(user, "Please choose a home system.") as null|anything in home_system_choices + list("Unset","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a home system.")  as text|null
						if(raw_choice)
							home_system = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					home_system = choice
				if("citizenship")
					var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices
					if(choice)
						citizenship = choice
				if("faction")
					var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a faction.")  as text|null
						if(raw_choice)
							faction = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					faction = choice
				if("religion")
					var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a religon.")  as text|null
						if(raw_choice)
							religion = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					religion = choice
		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE
						underwear = 1

				if("disabilities")				//please note: current code only allows nearsightedness as a disability
					disabilities = !disabilities//if you want to add actual disabilities, code that selects them should be here

				if("hear_adminhelps")
					toggles_sound ^= SOUND_ADMINHELP

				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Orange"
						if("Orange")
							UI_style = "old"
						if("old")
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
					if(!UI_style_alpha_new|!(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

				if("be_special")
					var/num = text2num(href_list["num"])
					be_special ^= (1<<num)

				if("name")
					be_random_name = !be_random_name

				if("hear_midis")
					toggles_sound ^= SOUND_MIDI

				if("lobby_music")
					toggles_sound ^= SOUND_LOBBY
					if(toggles_sound & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
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

				if("save")
					save_preferences()
					save_character()

				if("reload")
					load_preferences()
					load_character()

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					load_character(text2num(href_list["num"]))
					close_load_dialog(user)

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = 0)
	if(be_random_name)
		real_name = random_name(gender)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.real_name = real_name
	character.name = character.real_name
	if(character.dna) character.dna.real_name = character.real_name

	character.flavor_texts["general"] = flavor_texts["general"]
	character.flavor_texts["head"] = flavor_texts["head"]
	character.flavor_texts["face"] = flavor_texts["face"]
	character.flavor_texts["eyes"] = flavor_texts["eyes"]
	character.flavor_texts["torso"] = flavor_texts["torso"]
	character.flavor_texts["arms"] = flavor_texts["arms"]
	character.flavor_texts["hands"] = flavor_texts["hands"]
	character.flavor_texts["legs"] = flavor_texts["legs"]
	character.flavor_texts["feet"] = flavor_texts["feet"]

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

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.h_style = h_style
	character.f_style = f_style

	character.home_system = home_system
	character.citizenship = citizenship
	character.personal_faction = faction
	character.religion = religion

	character.skills = skills
	character.used_skillpoints = used_skillpoints

	// Destroy/cyborgize organs

	for(var/name in organ_data)

		var/status = organ_data[name]
		var/datum/limb/O = character.get_limb(name)
		if(O)
//			if(status == "amputated")
//				O.amputated = 1
//				O.status |= LIMB_DESTROYED
//				O.destspawn = 1
			if(status == "cyborg")
				O.status |= LIMB_ROBOT
		else
			var/datum/internal_organ/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.mechanize()

	if(underwear > underwear_f.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
	character.underwear = underwear

	if(undershirt > undershirt_t.len || undershirt < 1)
		undershirt = 0
	character.undershirt = undershirt

	if(backbag > 4 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.gender = MALE

	character.update_body(0,1)

/datum/preferences/proc/open_load_dialog(mob/user)
	var/dat = "<body>"
	dat += "<tt><center>"

	var/savefile/S = new /savefile(path)
	if(S)
		dat += "<b>Select a character slot to load</b><hr>"
		var/name
		for(var/i=1, i<=MAX_SAVE_SLOTS, i++)
			S.cd = "/character[i]"
			S["real_name"] >> name
			if(!name)	name = "Character[i]"
			if(i==default_slot)
				name = "<b>[name]</b>"
			dat += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
	user << browse(dat, "window=saves;size=300x390")

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")

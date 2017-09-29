//Chief Medical Officer
/datum/job/civilian
	department_flag = ROLEGROUP_MARINE_MED_SCIENCE
	minimal_player_age = 7

/datum/job/civilian/professor
	title = "Chief Medical Officer"
	comm_title = "CMO"
	paygrade = "CCMO"
	flag = ROLE_CHIEF_MEDICAL_OFFICER
	total_positions = 1
	spawn_positions = 1
	supervisors = "the acting commander"
	selection_color = "#99FF99"
	idtype = /obj/item/weapon/card/id/silver
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_CMO,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_DEFAULT)

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/cmo,
				WEAR_BODY = /obj/item/clothing/under/rank/chief_medical_officer,
				WEAR_FEET = /obj/item/clothing/shoes/laceup,
				WEAR_HANDS = /obj/item/clothing/gloves/latex,
				WEAR_JACKET = /obj/item/clothing/suit/storage/labcoat/officer,
				WEAR_EYES = /obj/item/clothing/glasses/hud/health,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/weapon/storage/pouch/medical,
				WEAR_L_STORE = /obj/item/weapon/storage/pouch/syringe
				)

	generate_stored_equipment()
		. = list(
				WEAR_WAIST = /obj/item/device/pda/heads/cmo,
				WEAR_J_STORE = /obj/item/device/flashlight/pen,
				WEAR_L_HAND = /obj/item/weapon/storage/firstaid/adv
				)

	generate_entry_message()
		. = {"You are a civilian, and are not subject to follow military chain of command, but you do work for the USCM.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the marines healthy and strong."}


//Doctor
/datum/job/civilian/doctor
	title = "Doctor"
	comm_title = "Doc"
	paygrade = "CD"
	flag = ROLE_CIVILIAN_DOCTOR
	total_positions = 6
	spawn_positions = 6
	supervisors = "the chief medical officer"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_SURGERY,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/doc,
				WEAR_BODY = /obj/item/clothing/under/rank/medical/green,
				WEAR_FEET = /obj/item/clothing/shoes/laceup,
				WEAR_HANDS = /obj/item/clothing/gloves/latex,
				WEAR_JACKET = /obj/item/clothing/suit/storage/labcoat,
				WEAR_EYES = /obj/item/clothing/glasses/hud/health,
				WEAR_HEAD = /obj/item/clothing/head/surgery/green,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/weapon/storage/pouch/medical,
				WEAR_L_STORE = /obj/item/weapon/storage/pouch/syringe
				)

	generate_stored_equipment()
		. = list(
				WEAR_WAIST = /obj/item/device/pda/medical,
				WEAR_L_HAND = /obj/item/weapon/storage/firstaid/adv
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are a civilian, and are not subject to follow military chain of command, but you do work for the USCM.
You are tasked with keeping the marines healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, adminhelp so a mentor can assist you."}

//Researcher
/datum/job/civilian/researcher
	title = "Researcher"
	disp_title = "Medical Researcher"
	comm_title = "Rsr"
	paygrade = "CD"
	flag = ROLE_CIVILIAN_RESEARCHER
	total_positions = 2
	spawn_positions = 2
	supervisors = "chief medical officer"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_SURGERY,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/doc,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/researcher,
				WEAR_FEET = /obj/item/clothing/shoes/laceup,
				WEAR_HANDS = /obj/item/clothing/gloves/latex,
				WEAR_JACKET = /obj/item/clothing/suit/storage/labcoat,
				WEAR_EYES = /obj/item/clothing/glasses/hud/health,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/weapon/storage/pouch/medical,
				WEAR_L_STORE = /obj/item/weapon/storage/pouch/syringe
				)

	generate_stored_equipment()
		. = list(
				WEAR_WAIST = /obj/item/device/pda/medical,
				WEAR_J_STORE = /obj/item/device/flashlight/pen
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are a civilian, and are not subject to follow military chain of command, but you do work for the USCM.
You are tasked with researching and developing new medical treatments, helping your fellow doctors, and generally learning new things.
Your role involves a lot of roleplaying, but you can perform the function of a regular doctor. Do not hand out things to marines without getting permission from your supervisor."}

//Liaison
/datum/job/civilian/liaison
	title = "Corporate Liaison"
	comm_title = "CL"
	paygrade = "WY1"
	flag = ROLE_CORPORATE_LIAISON
	department_flag = ROLEGROUP_MARINE_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "the W-Y corporate office"
	selection_color = "#ffeedd"
	access = list(ACCESS_IFF_MARINE, ACCESS_WY_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_WY_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	idtype = /obj/item/weapon/card/id/silver
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/liaison_suit,
				WEAR_FEET = /obj/item/clothing/shoes/laceup,
				WEAR_BACK = /obj/item/weapon/storage/backpack/satchel
				)


	generate_entry_message(mob/living/carbon/human/H)
		. = {"As a representative of Weyland-Yutani Corporation, your job requires you to stay in character at all times.
You are not required to follow military orders; however, you cannot give military orders.
Your primary job is to observe and report back your findings to Weyland-Yutani. Follow regular game rules unless told otherwise by your superiors.
Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back, and this is normal."}

	generate_entry_conditions(mob/living/carbon/human/H)
		if(ticker && H.mind) ticker.liaison = H.mind //TODO Look into CL tracking in game mode.


/datum/job/civilian/liaison/nightmare
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_PMC_WHITE, ACCESS_WY_CORPORATE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_PMC_WHITE, ACCESS_WY_CORPORATE)
	flags_startup_parameters = NOFLAGS

	generate_entry_message(mob/living/carbon/human/H)
		. = {"It was just a regular day in the office when the higher up decided to send you in to this hot mess. If only you called in sick that day...
The W-Y mercs were hired to protect some important science experiment, and W-Y expects you to keep them in line.
These are hardened killers, and you write on paper for a living. It won't be easy, that's for damn sure.
Best to let the mercs do the killing and the dying, but remind them who pays the bills."}





/datum/job/civilian/synthetic
	title = "Synthetic"
	comm_title = "Syn"
	paygrade = "???"
	flag = ROLE_SYNTHETIC
	department_flag = ROLEGROUP_MARINE_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "the acting commander"
	selection_color = "#aaee55"
	idtype = /obj/item/weapon/card/id/gold
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	flags_whitelist = WHITELIST_SYNTHETIC
	skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_MT,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_OVERWATCH,"medical"=SKILL_MEDICAL_CMO,"melee_weapons"=SKILL_MELEE_SUPER,"pilot"=SKILL_PILOT_TRAINED,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_MP,"powerloader"=SKILL_POWERLOADER_MASTER)

	get_access()
		return get_all_accesses()


	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/rank/synthetic,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/weapon/storage/belt/utility/full,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/weapon/storage/pouch/general/medium,
				WEAR_L_STORE = /obj/item/weapon/storage/pouch/general/medium
				)

	generate_entry_conditions(mob/living/carbon/human/H)
		. = ..()
		H.set_species("Synthetic")
		//Most of the code below is copypasted from transform_predator().
		if(!H.client.prefs) H.client.prefs = new /datum/preferences(H.client) //Let's give them one.
		//They should have these set, but it's possible they don't have them.
		H.real_name = H.client.prefs.synthetic_name
		if(!H.real_name || H.real_name == "Undefined") //In case they don't have a name set or no prefs, there's a name.
			H.real_name = "David"
			spawn(9)
				H << "<span class='warning'>You forgot to set your name in your preferences. Please do so next time.</span>"
		H.mind.name = H.real_name

		//update id with new name
		if(H.wear_id)
			var/obj/item/weapon/card/id/I = H.wear_id
			I.registered_name = H.real_name
			I.name = "[I.registered_name]'s ID Card ([I.assignment])"


	generate_entry_message()
		. = {"You are a Synthetic! You are held to a higher standard and are required to obey not only the Server Rules but Marine Law and Synthetic Rules. Failure to do so may result in your White-list Removal.
Your primary job is to support and assist all USCM Departments and Personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship.
As a Synthetic you answer to the acting commander. Special circumstances may change this!"}



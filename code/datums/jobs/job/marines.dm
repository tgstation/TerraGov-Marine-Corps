/datum/job/terragov/squad
	job_category = JOB_CAT_MARINE
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES


/datum/job/terragov/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_squad()
	C.set_nutrition(NUTRITION_WELLFED)
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/human_spawn = C
	if(!human_spawn.assigned_squad)
		CRASH("after_spawn called for a marine without an assigned_squad")
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[human_spawn.assigned_squad.color]>[lowertext(human_spawn.assigned_squad.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})


//Squad Marine
/datum/job/terragov/squad/standard
	title = SQUAD_MARINE
	paygrade = "E2"
	comm_title = "Mar"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"})


/datum/outfit/job/marine/standard
	name = SQUAD_MARINE
	jobtype = /datum/job/terragov/squad/standard

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Engineer
/datum/job/terragov/squad/engineer
	title = SQUAD_ENGINEER
	paygrade = "E3"
	comm_title = "Eng"
	total_positions = 12
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_REMOTEBUILD)
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_MEDIUM, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM)

/datum/job/terragov/squad/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."})


/datum/outfit/job/marine/engineer
	name = SQUAD_ENGINEER
	jobtype = /datum/job/terragov/squad/engineer

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Corpsman
/datum/job/terragov/squad/corpsman
	title = SQUAD_CORPSMAN
	paygrade = "Corp"
	comm_title = "Med"
	total_positions = 16
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_MEDIUM, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM)


/datum/job/terragov/squad/corpsman/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})


/datum/outfit/job/marine/corpsman
	name = SQUAD_CORPSMAN
	jobtype = /datum/job/terragov/squad/corpsman

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/corpsman


//Squad Smartgunner
/datum/job/terragov/squad/smartgunner
	title = SQUAD_SMARTGUNNER
	paygrade = "E3"
	comm_title = "SGnr"
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/smartgunner
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	job_points_needed  = 10 //Redefined via config.

/datum/job/terragov/squad/smartgunner/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the smartgunner. Your job is to provide heavy weapons support."})


/datum/outfit/job/marine/smartgunner
	name = SQUAD_SMARTGUNNER
	jobtype = /datum/job/terragov/squad/smartgunner

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Specialist
/datum/job/terragov/squad/specialist
	title = SQUAD_SPECIALIST
	req_admin_notify = TRUE
	paygrade = "E4"
	comm_title = "Spec"
	total_positions = 4
	max_positions = 6
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/specialist
	display_order = JOB_DISPLAY_ORDER_SQUAD_SPECIALIST
	outfit = /datum/outfit/job/marine/specialist
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_STRONG)
	job_points_needed  = 10 //Redefined via config.


/datum/job/terragov/squad/specialist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."})


/datum/outfit/job/marine/specialist
	name = SQUAD_SPECIALIST
	jobtype = /datum/job/terragov/squad/specialist

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel
	head = /obj/item/clothing/head/helmet/specrag


//Squad Leader
/datum/job/terragov/squad/leader
	title = SQUAD_LEADER
	req_admin_notify = TRUE
	paygrade = "E5"
	comm_title = "SL"
	total_positions = 4
	supervisors = "the acting field commander"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/SL
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/marine/leader
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_HIGH, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_HIGH)


/datum/job/terragov/squad/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})


/datum/outfit/job/marine/leader
	name = SQUAD_LEADER
	jobtype = /datum/job/terragov/squad/leader

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/squad/leader/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	if(!latejoin || !ishuman(C))
		return
	var/mob/living/carbon/human/H = C
	if(!H.assigned_squad)
		return
	if(H.assigned_squad.squad_leader != H)
		if(H.assigned_squad.squad_leader)
			H.assigned_squad.demote_leader()
		H.assigned_squad.promote_leader(H)

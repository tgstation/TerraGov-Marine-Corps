/datum/job/marine
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	skills_type = /datum/skills/pfc
	faction = "Marine"
	exp_type_department = EXP_TYPE_MARINES


/datum/job/marine/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_squad()
	C.nutrition = rand(60,250)
	if(!C.mind?.assigned_squad)
		return
	var/datum/squad/S = C.mind.assigned_squad
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[S.color]>[lowertext(S.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})


//Squad Marine
/datum/job/marine/standard
	title = SQUAD_MARINE
	paygrade = "E2"
	comm_title = "Mar"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard
	total_positions = -1


/datum/job/marine/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"})


/datum/outfit/job/marine/standard
	name = SQUAD_MARINE
	jobtype = /datum/job/marine/standard

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Engineer
/datum/job/marine/engineer
	title = SQUAD_ENGINEER
	paygrade = "E3"
	comm_title = "Eng"
	total_positions = 12
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer


/datum/job/marine/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."})


/datum/outfit/job/marine/engineer
	name = SQUAD_ENGINEER
	jobtype = /datum/job/marine/engineer

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Corpsman
/datum/job/marine/corpsman
	title = SQUAD_CORPSMAN
	paygrade = "Corp"
	comm_title = "Med"
	total_positions = 16
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman


/datum/job/marine/corpsman/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})


/datum/outfit/job/marine/corpsman
	name = SQUAD_CORPSMAN
	jobtype = /datum/job/marine/corpsman

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/corpsman


//Squad Smartgunner
/datum/job/marine/smartgunner
	title = SQUAD_SMARTGUNNER
	paygrade = "E3"
	comm_title = "SGnr"
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/smartgunner
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner


/datum/job/marine/smartgunner/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the smartgunner. Your job is to provide heavy weapons support."})


/datum/outfit/job/marine/smartgunner
	name = SQUAD_SMARTGUNNER
	jobtype = /datum/job/marine/smartgunner

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


//Squad Specialist
/datum/job/marine/specialist
	title = SQUAD_SPECIALIST
	paygrade = "E4"
	comm_title = "Spec"
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/specialist
	display_order = JOB_DISPLAY_ORDER_SQUAD_SPECIALIST
	outfit = /datum/outfit/job/marine/specialist
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL


/datum/job/marine/specialist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."})


/datum/outfit/job/marine/specialist
	name = SQUAD_SPECIALIST
	jobtype = /datum/job/marine/specialist

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel
	head = /obj/item/clothing/head/helmet/specrag


//Squad Leader
/datum/job/marine/leader
	title = SQUAD_LEADER
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


/datum/job/marine/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})


/datum/outfit/job/marine/leader
	name = SQUAD_LEADER
	jobtype = /datum/job/marine/leader

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/marine/leader/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	if(!latejoin || !ishuman(C))
		return
	var/mob/living/carbon/human/H = C
	if(!H.assigned_squad)
		return
	if(H.assigned_squad.squad_leader)
		H.assigned_squad.demote_leader()
	H.assigned_squad.promote_leader(H)
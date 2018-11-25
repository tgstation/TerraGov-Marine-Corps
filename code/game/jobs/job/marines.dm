
//Marine jobs. All marines are genericized when they first log in, then it auto assigns them to squads.

/datum/job/marine
	department_flag = ROLEGROUP_MARINE_SQUAD_MARINES
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	total_positions = 8
	spawn_positions = 8
	skills_type = /datum/skills/pfc
	idtype = /obj/item/card/id/dogtag
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/marine

	generate_entry_message(mob/living/carbon/human/H)
		if(H.assigned_squad)
			. = "You have been assigned to: <b><font size=3 color=[squad_colors[H.assigned_squad.color]]>[lowertext(H.assigned_squad.name)] squad</font></b>.[flags_startup_parameters & ROLE_ADD_TO_MODE ? " Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room." : ""]"

	generate_entry_conditions(mob/living/carbon/human/H)
		. = ..()
		if(flags_startup_parameters & ROLE_ADD_TO_MODE) H.nutrition = rand(60,250) //Start hungry for the default marine.

/datum/job/marine/leader
	title = "Squad Leader"
	comm_title = "SL"
	paygrade = "E6"
	flag = ROLE_MARINE_LEADER
	total_positions = 4
	spawn_positions = 4
	supervisors = "the acting commander"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	skills_type = /datum/skills/SL

	generate_entry_message()
		. = ..() + {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."}

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)

/datum/job/marine/leader/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/engineer
	title = "Squad Engineer"
	comm_title = "Eng"
	paygrade = "E4"
	total_positions = 12
	spawn_positions = 12
	flag = ROLE_MARINE_ENGINEER
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	skills_type = /datum/skills/combat_engineer

	generate_entry_message()
		. = ..() + {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."}

	get_total_positions(var/latejoin=0)
		var/slots = engi_slot_formula(get_total_marines())
		if(latejoin)
			for(var/datum/squad/sq in RoleAuthority.squads)
				if(sq)
					sq.max_engineers = slots
		return (slots*4)

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/tech(H), WEAR_BACK)

/datum/job/marine/engineer/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/medic
	title = "Squad Medic"
	comm_title = "Med"
	paygrade = "E4"
	total_positions = 16
	spawn_positions = 16
	flag = ROLE_MARINE_MEDIC
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	skills_type = /datum/skills/combat_medic

	generate_entry_message()
		. = ..() + {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."}

	get_total_positions(var/latejoin=0)
		var/slots = medic_slot_formula(get_total_marines())
		if(latejoin)
			for(var/datum/squad/sq in RoleAuthority.squads)
				if(sq)
					sq.max_medics = slots
		return (slots*4)

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/medic(H), WEAR_BACK)


/datum/job/marine/medic/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/specialist
	title = "Squad Specialist"
	comm_title = "Spc"
	paygrade = "E5"
	flag = ROLE_MARINE_SPECIALIST
	total_positions = 4
	spawn_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	skills_type = /datum/skills/specialist

	generate_entry_message()
		. = ..() + {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."}

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(H), WEAR_HEAD)


/datum/job/marine/specialist/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD




/datum/job/marine/smartgunner
	title = "Squad Smartgunner"
	comm_title = "LCpl"
	paygrade = "E3"
	flag = ROLE_MARINE_SMARTGUN
	total_positions = 4
	spawn_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	skills_type = /datum/skills/smartgunner

	generate_entry_message()
		. = ..() + {"\nYou are the smartgunner. Your job is to provide heavy weapons support."}

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)


/datum/job/marine/smartgunner/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD


/datum/job/marine/standard
	title = "Squad Marine"
	comm_title = "Mar"
	paygrade = "E2"
	flag = ROLE_MARINE_STANDARD
	department_flag = ROLEGROUP_MARINE_SQUAD_MARINES
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD

	generate_entry_message()
		. = ..() + {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"}

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)

/datum/job/marine/standard/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/logistics
	supervisors = "the acting commander"
	total_positions = 1
	spawn_positions = 1
	idtype = /obj/item/card/id/silver
	minimal_player_age = 7

//Chief Engineer
/datum/job/logistics/engineering
	title = "Chief Engineer"
	comm_title = "CE"
	paygrade = "O3"
	flag = ROLE_CHIEF_ENGINEER
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	selection_color = "#ffeeaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CE

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/ce,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/utility/full,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel/tech,
				WEAR_R_STORE = /obj/item/storage/pouch/electronics
				)

	generate_stored_equipment()
		. = list()

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, adminhelp so that a mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."}

//Requisitions Officer
/datum/job/logistics/requisition
	title = "Requisitions Officer"
	comm_title = "RO"
	paygrade = "O1"
	flag = ROLE_REQUISITION_OFFICER
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	selection_color = "#9990B2"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/RO

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/rank/ro_suit,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/gun/m44/full,
				WEAR_HEAD = /obj/item/clothing/head/cmcap/req,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to dispense supplies to the marines, including weapon attachments.
Your cargo techs can help you out, but you have final say in your department. Make sure they're not goofing off.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy ship is a well-functioning ship."}

/datum/job/logistics/tech
	idtype = /obj/item/card/id
	minimal_player_age = 3

//Maintenance Tech
/datum/job/logistics/tech/maint
	title = "Maintenance Tech"
	comm_title = "MT"
	paygrade = "E6E"
	flag = ROLE_MAINTENANCE_TECH
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	scaled = 1
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_CIVILIAN_ENGINEERING)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/MT

	set_spawn_positions(var/count)
		spawn_positions = mt_slot_formula(count)

	get_total_positions(var/latejoin = 0)
		return (latejoin ? mt_slot_formula(get_total_marines()) : spawn_positions)

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mt,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/engi,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/utility/full,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/medium
				)

	generate_stored_equipment()
		. = list(
				WEAR_L_HAND = /obj/item/device/t_scanner
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to make sure the ship is clean and the powergrid is operational.
Start with the ship's engine, and don't forget radiation equipment."}

//Cargo Tech. Don't ask why this is in engineering
/datum/job/logistics/tech/cargo
	title = "Cargo Technician"
	comm_title = "CT"
	paygrade = "E5"
	flag = ROLE_REQUISITION_TECH
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	total_positions = 2
	spawn_positions = 2
	scaled = 1
	supervisors = "the requisitions officer"
	selection_color = "#BAAFD9"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CT

	set_spawn_positions(var/count)
		spawn_positions = ct_slot_formula(count)

	get_total_positions(var/latejoin = 0)
		return (latejoin ? ct_slot_formula(get_total_marines()) : spawn_positions)

	generate_wearable_equipment(mob/living/carbon/human/H)
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/ct,
				WEAR_BODY = /obj/item/clothing/under/rank/cargotech,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/gun/m4a3/full,
				WEAR_HEAD = /obj/item/clothing/head/beanie,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/medium
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to dispense supplies to the marines, including weapon attachments.
Stay in your department when possible to ensure the marines have full access to the supplies they may require.
Listen to the radio in case someone requests a supply drop via the overwatch system."}

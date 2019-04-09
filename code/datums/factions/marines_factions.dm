/datum/faction/tgmc
	name = "TerraGov Marine Corps"
	shortname = "TGMC"

	friendly_factions = list(
		/datum/faction/nanotrasen)

/datum/squad/marine
	has_special_roles = list(
		/datum/special_role/squad_leader,
		/datum/special_role/squad_specialist,
		/datum/special_role/squad_smartgunner,
		/datum/special_role/squad_engineer,
		/datum/special_role/squad_corpsman,
		/datum/special_role/squad_marine)
	default_role = /datum/special_role/squad_marine

	ideal_size = 20
	
	var/color = 0 //Color for helmets, etc.
	var/mob/living/carbon/human/overwatch_officer
	var/obj/item/device/squad_beacon/sbeacon = null
	var/obj/structure/supply_drop/drop_pad = null

	var/list/squad_orbital_beacons = list()
	var/list/squad_laser_targets = list()

/datum/special_role/squad_leader
	name = "Squad Leader"
	role_limit = SPECIAL_ROLE_UNIQUE
	assigned_role = "Squad Leader"

/datum/special_role/squad_specialist
	name = "Squad Specialist"
	role_limit = SPECIAL_ROLE_UNIQUE
	assigned_role = "Squad Specialist"

/datum/special_role/squad_smartgunner
	name = "Squad Smartgunner"
	role_limit = SPECIAL_ROLE_UNIQUE
	assigned_role = "Squad Smartgunner"

/datum/special_role/squad_engineer
	name = "Squad Engineer"
	role_limit = 3
	assigned_role = "Squad Engineer"

/datum/special_role/squad_corpsman
	name = "Squad Corpsman"
	role_limit = 4
	assigned_role = "Squad Corpsman"

/datum/special_role/squad_marine
	name = "Squad Marine"
	role_limit = SPECIAL_ROLE_UNLIMITED
	assigned_role = "Squad Marine"

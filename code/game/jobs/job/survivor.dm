/datum/job/survivor
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	skills_type = /datum/skills/civilian/survivor
	faction = "Marine"


//Assistant
/datum/job/survivor/assistant
	title = "Assistant"
	outfit = /datum/outfit/job/survivor/assistant


/datum/outfit/job/survivor/assistant
	name = "Assistant"
	jobtype = /datum/job/survivor/assistant

	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Scientist
/datum/job/survivor/scientist
	title = "Scientist"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/scientist


/datum/outfit/job/survivor/scientist
	name = "Scientist"
	jobtype = /datum/job/survivor/scientist

	w_uniform = /obj/item/clothing/under/colonist
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/tox


//Doctor
/datum/job/survivor/doctor
	title = "Doctor's Assistant"
	skills_type = /datum/skills/civilian/survivor/doctor
	outfit = /datum/outfit/job/survivor/doctor


/datum/outfit/job/survivor/doctor
	name = "Doctor's Assistant"
	jobtype = /datum/job/survivor/doctor

	w_uniform = /obj/item/clothing/under/rank/medical
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/med


//Liaison
/datum/job/survivor/liaison
	title = "Liaison"
	outfit = /datum/outfit/job/survivor/liaison


/datum/outfit/job/survivor/liaison
	name = "Liaison"
	jobtype = /datum/job/survivor/liaison

	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Security Guard
/datum/job/survivor/security
	title = "Security Guard"
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/security


/datum/outfit/job/survivor/security
	name = "Security Guard"
	jobtype = /datum/job/survivor/security

	w_uniform = /obj/item/clothing/under/rank/security/corp
	shoes = /obj/item/clothing/shoes/marine
	back = /obj/item/storage/backpack/satchel/sec


//Civilian
/datum/job/survivor/civilian
	title = "Civilian"
	outfit = /datum/outfit/job/survivor/civilian


/datum/outfit/job/survivor/civilian
	name = "Civilian"
	jobtype = /datum/job/survivor/civilian

	w_uniform = /obj/item/clothing/under/pj/red
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Chef
/datum/job/survivor/chef
	title = "Chef"
	skills_type = /datum/skills/civilian/survivor/chef
	outfit = /datum/outfit/job/survivor/chef


/datum/outfit/job/survivor/chef
	name = "Chef"
	jobtype = /datum/job/survivor/chef

	w_uniform = /obj/item/clothing/under/colonist
	wear_suit = /obj/item/clothing/suit/chef
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Botanist
/datum/job/survivor/botanist
	title = "Botanist"
	outfit = /datum/outfit/job/survivor/botanist


/datum/outfit/job/survivor/botanist
	name = "Botanist"
	jobtype = /datum/job/survivor/botanist

	w_uniform = /obj/item/clothing/under/colonist
	wear_suit = /obj/item/clothing/suit/apron
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/hydroponics


//Atmospherics Technician
/datum/job/survivor/atmos
	title = "Atmospherics Technician"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/atmos


/datum/outfit/job/survivor/atmos
	name = "Atmospherics Technician"
	jobtype = /datum/job/survivor/atmos

	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/eng


//Chaplain
/datum/job/survivor/chaplain
	title = "Chaplain"
	outfit = /datum/outfit/job/survivor/chaplain


/datum/outfit/job/survivor/chaplain
	name = "Chaplain"
	jobtype = /datum/job/survivor/chaplain

	w_uniform = /obj/item/clothing/under/rank/chaplain
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Miner
/datum/job/survivor/miner
	title = "Miner"
	skills_type = /datum/skills/civilian/survivor/miner
	outfit = /datum/outfit/job/survivor/miner


/datum/outfit/job/survivor/miner
	name = "Miner"
	jobtype = /datum/job/survivor/miner

	w_uniform = /obj/item/clothing/under/rank/miner
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Salesman
/datum/job/survivor/salesman
	title = "Salesman"
	outfit = /datum/outfit/job/survivor/salesman


/datum/outfit/job/survivor/salesman
	name = "Salesman"
	jobtype = /datum/job/survivor/salesman

	w_uniform = /obj/item/clothing/under/liaison_suit
	wear_suit = /obj/item/clothing/suit/wcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel


//Colonial Marshal
/datum/job/survivor/marshal
	title = "Colonial Marshal"
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/marshal


/datum/outfit/job/survivor/marshal
	name = "Colonial Marshal"
	jobtype = /datum/job/survivor/marshal

	w_uniform = /obj/item/clothing/under/CM_uniform
	wear_suit = /obj/item/clothing/suit/storage/CMB
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/satchel/sec


//Clown
/datum/job/survivor/clown
	title = "Clown"
	skills_type = /datum/skills/civilian/survivor/clown
	outfit = /datum/outfit/job/survivor/clown


/datum/outfit/job/survivor/clown
	name = "Clown"
	jobtype = /datum/job/survivor/clown

	w_uniform = /obj/item/clothing/under/rank/clown
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes
	back = /obj/item/storage/backpack/clown
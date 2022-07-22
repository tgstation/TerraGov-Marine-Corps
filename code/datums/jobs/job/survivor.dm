/datum/job/survivor
	title = "Generic Survivor"
	supervisors = "anyone who might rescue you"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	display_order = JOB_DISPLAY_ORDER_SURVIVOR
	skills_type = /datum/skills/civilian/survivor
	faction = FACTION_TERRAGOV

/datum/job/survivor/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		C.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(C), SLOT_HEAD)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(C), SLOT_WEAR_SUIT)
		C.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(C), SLOT_WEAR_MASK)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(C), SLOT_SHOES)
		C.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(C), SLOT_GLOVES)

	switch(SSmapping.configs[GROUND_MAP].map_name)
		if(MAP_PRISON_STATION)
			to_chat(M, span_notice("You are a survivor of the attack on Fiorina Orbital Penitentiary. You worked or lived on the prison station, and managed to avoid the alien attacks... until now."))
		if(MAP_ICE_COLONY)
			to_chat(M, span_notice("You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks... until now."))
		if(MAP_BIG_RED)
			to_chat(M, span_notice("You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks... until now."))
		if(MAP_LV_624)
			to_chat(M, span_notice("You are a survivor of the attack on the colony. You suspected something was wrong and tried to warn others, but it was too late..."))
		if(MAP_ICY_CAVES)
			to_chat(M, span_notice("You are a survivor of the attack on the icy cave system. You worked or lived on the site, and managed to avoid the alien attacks... until now."))
		if(MAP_RESEARCH_OUTPOST)
			to_chat(M, span_notice("You are a survivor of the attack on the outpost. But you question yourself: are you truely safe now?"))
		if(MAP_MAGMOOR_DIGSITE)
			to_chat(M, span_notice("You are a survivor of the attack on the Magmoor Digsite IV. You worked or lived on the digsite, and managed to avoid the alien attacks... until now."))
		else
			to_chat(M, span_notice("Through a miracle you managed to survive the attack. But are you truly safe now?"))

/datum/job/survivor/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"In whatever case you have been through, you are here to survive and get yourself rescued.
You appreciate the support of TerraGov and Nanotrasen should you be rescued.
You are not hostile to TGMC, nor you should oppose or disrupt their objective, unless an admin says otherwise.
If you find any other survivors in the area, cooperate with them to increase your chances of survival.
Depending on the job you've undertook, you may have additional skills to help others when needed.
Good luck, but do not expect to survive."})


//Scientist
/datum/job/survivor/scientist
	title = "Scientist Survivor"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/scientist


/datum/outfit/job/survivor/scientist
	name = "Scientist Survivor"
	jobtype = /datum/job/survivor/scientist

	w_uniform = /obj/item/clothing/under/rank/scientist
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/tox


//Doctor
/datum/job/survivor/doctor
	title = "Doctor's Assistant Survivor"
	skills_type = /datum/skills/civilian/survivor/doctor
	outfit = /datum/outfit/job/survivor/doctor


/datum/outfit/job/survivor/doctor
	name = "Doctor's Assistant Survivor"
	jobtype = /datum/job/survivor/doctor

	w_uniform = /obj/item/clothing/under/rank/medical
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/med


//Liaison
/datum/job/survivor/liaison
	title = "Liaison Survivor"
	outfit = /datum/outfit/job/survivor/liaison


/datum/outfit/job/survivor/liaison
	name = "Liaison Survivor"
	jobtype = /datum/job/survivor/liaison

	w_uniform = /obj/item/clothing/under/liaison_suit
	wear_suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm

//Civilian
/datum/job/survivor/civilian
	title = "Civilian Survivor"
	outfit = /datum/outfit/job/survivor/civilian


/datum/outfit/job/survivor/civilian
	name = "Civilian Survivor"
	jobtype = /datum/job/survivor/civilian

	w_uniform = /obj/item/clothing/under/pj/red
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Chef
/datum/job/survivor/chef
	title = "Chef Survivor"
	skills_type = /datum/skills/civilian/survivor/chef
	outfit = /datum/outfit/job/survivor/chef


/datum/outfit/job/survivor/chef
	name = "Chef Survivor"
	jobtype = /datum/job/survivor/chef

	w_uniform = /obj/item/clothing/under/rank/chef
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Botanist
/datum/job/survivor/botanist
	title = "Botanist Survivor"
	outfit = /datum/outfit/job/survivor/botanist


/datum/outfit/job/survivor/botanist
	name = "Botanist Survivor"
	jobtype = /datum/job/survivor/botanist

	w_uniform = /obj/item/clothing/under/rank/hydroponics
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/hydroponics


//Atmospherics Technician
/datum/job/survivor/atmos
	title = "Atmospherics Technician Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/atmos


/datum/outfit/job/survivor/atmos
	name = "Atmospherics Technician Survivor"
	jobtype = /datum/job/survivor/atmos

	w_uniform = /obj/item/clothing/under/rank/atmospheric_technician
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/eng


//Chaplain
/datum/job/survivor/chaplain
	title = "Chaplain Survivor"
	outfit = /datum/outfit/job/survivor/chaplain


/datum/outfit/job/survivor/chaplain
	name = "Chaplain Survivor"
	jobtype = /datum/job/survivor/chaplain

	w_uniform = /obj/item/clothing/under/rank/chaplain
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Miner
/datum/job/survivor/miner
	title = "Miner Survivor"
	skills_type = /datum/skills/civilian/survivor/miner
	outfit = /datum/outfit/job/survivor/miner


/datum/outfit/job/survivor/miner
	name = "Miner Survivor"
	jobtype = /datum/job/survivor/miner

	w_uniform = /obj/item/clothing/under/rank/miner
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm


//Colonial Marshal
/datum/job/survivor/marshal
	title = "Colonial Marshal Survivor"
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/marshal


/datum/outfit/job/survivor/marshal
	name = "Colonial Marshal Survivor"
	jobtype = /datum/job/survivor/marshal

	w_uniform = /obj/item/clothing/under/CM_uniform
	wear_suit = /obj/item/clothing/suit/storage/CMB
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/satchel/sec

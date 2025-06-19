/datum/job/survivor
	title = "Generic Survivor"
	supervisors = "anyone who might rescue you"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	display_order = JOB_DISPLAY_ORDER_SURVIVOR
	skills_type = /datum/skills/civilian/survivor
	faction = FACTION_TERRAGOV

/datum/job/survivor/after_spawn(mob/living/carbon/spawned_carbon, mob/M, latejoin = FALSE)
	. = ..()
	//todo this should be handled better
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(spawned_carbon), SLOT_HEAD)
		spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(spawned_carbon), SLOT_W_UNIFORM)
		spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(spawned_carbon), SLOT_WEAR_MASK)
		spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(spawned_carbon), SLOT_SHOES)
		spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(spawned_carbon), SLOT_GLOVES)

	var/weapons = pick(SURVIVOR_WEAPONS)
	var/obj/item/weapon/picked_weapon = weapons[1]
	var/obj/item/ammo_magazine/picked_ammo = weapons[2]
	spawned_carbon.equip_to_slot_or_del(new /obj/item/belt_harness(spawned_carbon), SLOT_BELT)
	spawned_carbon.put_in_hands(new picked_weapon(spawned_carbon))
	spawned_carbon.equip_to_slot_or_del(new picked_ammo(spawned_carbon), SLOT_IN_BACKPACK)
	spawned_carbon.equip_to_slot_or_del(new picked_ammo(spawned_carbon), SLOT_IN_BACKPACK)
	spawned_carbon.equip_to_slot_or_del(new picked_ammo(spawned_carbon), SLOT_IN_BACKPACK)
	spawned_carbon.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(spawned_carbon), SLOT_IN_BACKPACK)

	spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(spawned_carbon), SLOT_GLASSES)
	spawned_carbon.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(spawned_carbon), SLOT_R_STORE)
	spawned_carbon.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(spawned_carbon), SLOT_L_STORE)
	spawned_carbon.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/rugged(spawned_carbon), SLOT_HEAD)

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

/datum/job/survivor/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"In whatever case you have been through, you are here to survive and get yourself rescued.
You appreciate the support of TerraGov and Nanotrasen should you be rescued.
You are not hostile to TGMC, nor you should oppose or disrupt their objective, unless an admin says otherwise.
If you find any other survivors in the area, cooperate with them to increase your chances of survival.
Depending on the job you've undertook, you may have additional skills to help others when needed.
Good luck, but do not expect to survive."}


//Scientist
/datum/job/survivor/scientist
	title = "Scientist Survivor"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/scientist


//Doctor
/datum/job/survivor/doctor
	title = "Doctor's Assistant Survivor"
	skills_type = /datum/skills/civilian/survivor/doctor
	outfit = /datum/outfit/job/survivor/doctor


//Liaison
/datum/job/survivor/liaison
	title = "Liaison Survivor"
	outfit = /datum/outfit/job/survivor/liaison


//Security Guard
/datum/job/survivor/security
	title = "Security Guard Survivor"
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/security



//Civilian
/datum/job/survivor/civilian
	title = "Civilian Survivor"
	outfit = /datum/outfit/job/survivor/civilian


//Chef
/datum/job/survivor/chef
	title = "Chef Survivor"
	skills_type = /datum/skills/civilian/survivor/chef
	outfit = /datum/outfit/job/survivor/chef


//Botanist
/datum/job/survivor/botanist
	title = "Botanist Survivor"
	outfit = /datum/outfit/job/survivor/botanist



//Atmospherics Technician
/datum/job/survivor/atmos
	title = "Atmos Technician Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/atmos



//Chaplain
/datum/job/survivor/chaplain
	title = "Chaplain Survivor"
	outfit = /datum/outfit/job/survivor/chaplain


//Miner
/datum/job/survivor/miner
	title = "Miner Survivor"
	skills_type = /datum/skills/civilian/survivor/miner
	outfit = /datum/outfit/job/survivor/miner



//Salesman
/datum/job/survivor/salesman
	title = "Salesman Survivor"
	outfit = /datum/outfit/job/survivor/salesman



//Colonial Marshal
/datum/job/survivor/marshal
	title = "Colonial Marshal Survivor"
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/marshal

//Roboticist Survivor
/datum/job/survivor/roboticist
	title = "Roboticist Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/roboticist

//Chemist Survivor
/datum/job/survivor/chemist
	title = "Pharmacy Technician Survivor"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/chemist

//Assistant
/datum/job/survivor/assistant
	title = "Assistant Survivor"
	outfit = /datum/outfit/job/survivor/assistant

//Bartender Survivor
/datum/job/survivor/bartender
	title = "Bartender Survivor"
	outfit = /datum/outfit/job/survivor/bartender


//Roboticist Survivor
/datum/job/survivor/roboticist
	title = "Roboticist Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/roboticist


/datum/outfit/job/survivor/roboticist
	name = "Roboticist Survivor"
	jobtype = /datum/job/survivor/roboticist

	w_uniform = /obj/item/clothing/under/rank/roboticist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/science
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/tox
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/welding/flipped
	l_pocket = /obj/item/storage/pouch/electronics/full
	r_pocket = /obj/item/flashlight/combat

/datum/outfit/job/survivor/roboticist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/deployable_vehicle/tiny, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/unmanned_vehicle_remote, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)

// Rambo Survivor - pretty overpowered, pls spawn with caution
/datum/job/survivor/rambo
	title = "Rambo Survivor"
	skills_type = /datum/skills/civilian/survivor/master
	outfit = /datum/outfit/job/survivor/rambo
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_NOHEADSET|JOB_FLAG_OVERRIDELATEJOINSPAWN

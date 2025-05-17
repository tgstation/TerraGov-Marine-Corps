/datum/job/survivor
	title = "Generic Survivor"
	supervisors = "anyone who might rescue you"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	display_order = JOB_DISPLAY_ORDER_SURVIVOR
	faction = FACTION_TERRAGOV
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_ADDTOMANIFEST
	skills_type = /datum/skills/civilian/survivor

/datum/job/survivor/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	SSminimaps.add_marker(C, MINIMAP_FLAG_SURVIVOR, image('icons/UI_icons/map_blips.dmi', null, "survivor"))
	var/datum/action/minimap/survivor/mini = new
	mini.give_action(C)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		C.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(C), SLOT_HEAD)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(C), SLOT_WEAR_SUIT)
		C.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(C), SLOT_WEAR_MASK)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(C), SLOT_SHOES)
		C.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(C), SLOT_GLOVES)

	var/weapons = pick(SURVIVOR_WEAPONS)
	var/obj/item/weapon/W = weapons[1]
	var/obj/item/ammo_magazine/A = weapons[2]
	C.equip_to_slot_or_del(new /obj/item/belt_harness(C), SLOT_BELT)
	C.put_in_hands(new W(C))
	C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)
	C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)
	C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)

	C.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(C), SLOT_GLASSES)
	C.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(C), SLOT_R_STORE)
	C.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(C), SLOT_L_STORE)
	C.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(C), SLOT_IN_BACKPACK)
	C.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/rugged(C), SLOT_HEAD)

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
You are not hostile to NTC, nor you should oppose or disrupt their objective, unless an admin says otherwise.
If you find any other survivors in the area, cooperate with them to increase your chances of survival.
Depending on the job you've undertook, you may have additional skills to help others when needed.
Good luck, but do not expect to survive."}


//Assistant
/datum/job/survivor/assistant
	title = "Assistant Survivor"
	outfit = /datum/outfit/job/survivor/assistant


/datum/outfit/job/survivor/assistant
	name = "Assistant Survivor"
	jobtype = /datum/job/survivor/assistant

	w_uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id/captains_spare/survival
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	wear_suit = /obj/item/clothing/suit/armor/vest
	ears = /obj/item/radio/headset/survivor
	mask = /obj/item/clothing/mask/gas/tactical/coif
	head = /obj/item/clothing/head/welding/flipped
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/flashlight/combat
	r_hand = /obj/item/weapon/combat_knife

/datum/outfit/job/survivor/assistant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Scientist
/datum/job/survivor/scientist
	title = "Scientist Survivor"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/scientist


/datum/outfit/job/survivor/scientist
	name = "Scientist Survivor"
	jobtype = /datum/job/survivor/scientist

	w_uniform = /obj/item/clothing/under/rank/scientist
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/labcoat/researcher
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/toxins
	ears = /obj/item/radio/headset/survivor
	l_hand = /obj/item/storage/firstaid/adv
	l_pocket = /obj/item/storage/pouch/surgery
	r_pocket = /obj/item/flashlight/combat

/datum/outfit/job/survivor/scientist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/polyhexanide, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)

//Doctor
/datum/job/survivor/doctor
	title = "Doctor Survivor"
	skills_type = /datum/skills/civilian/survivor/doctor
	outfit = /datum/outfit/job/survivor/doctor


/datum/outfit/job/survivor/doctor
	name = "Doctor Survivor"
	jobtype = /datum/job/survivor/doctor
	w_uniform = /obj/item/clothing/under/rank/medical/blue
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/med
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/surgery
	belt = /obj/item/storage/belt/rig
	mask = /obj/item/clothing/mask/surgical
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/doctor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/bicaridine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/kelotane, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/dylovene, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/isotonic, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/inaprovaline, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_R_POUCH)


//Liaison
/datum/job/survivor/liaison
	title = "Liaison Survivor"
	outfit = /datum/outfit/job/survivor/liaison


/datum/outfit/job/survivor/liaison
	name = "Liaison Survivor"
	jobtype = /datum/job/survivor/liaison

	w_uniform = /obj/item/clothing/under/liaison_suit
	id = /obj/item/card/id/captains_spare/survival
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/headset/survivor
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp78
	l_hand = /obj/item/flashlight/combat
	l_pocket = /obj/item/tool/crowbar

/datum/outfit/job/survivor/liaison/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)

//Security Guard
/datum/job/survivor/security
	title = "Security Guard Survivor"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
	skills_type = /datum/skills/civilian/survivor/marshal
	outfit = /datum/outfit/job/survivor/security


/datum/outfit/job/survivor/security
	name = "Security Guard Survivor"
	jobtype = /datum/job/survivor/security

	w_uniform = /obj/item/clothing/under/rank/security
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/armor/patrol
	head = /obj/item/clothing/head/securitycap
	shoes = /obj/item/clothing/shoes/marine/full
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security
	gloves = /obj/item/clothing/gloves/black
	suit_store = /obj/item/storage/holster/belt/pistol/g22
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/flashlight/combat, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/telebaton, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Civilian
/datum/job/survivor/civilian
	title = "Civilian Survivor"
	outfit = /datum/outfit/job/survivor/civilian


/datum/outfit/job/survivor/civilian
	name = "Civilian Survivor"
	jobtype = /datum/job/survivor/civilian

	w_uniform = /obj/item/clothing/under/colonist
	id = /obj/item/card/id/captains_spare/survival
	belt = /obj/item/storage/holster/belt/pistol/m4a3
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/civilian/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Chef
/datum/job/survivor/chef
	title = "Chef Survivor"
	skills_type = /datum/skills/civilian/survivor/chef
	outfit = /datum/outfit/job/survivor/chef


/datum/outfit/job/survivor/chef
	name = "Chef Survivor"
	jobtype = /datum/job/survivor/chef
	w_uniform = /obj/item/clothing/under/rank/chef
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/chef
	head = /obj/item/clothing/head/chefhat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/chef/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/kitchen/knife/butcher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/burger/crazy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/soup/mysterysoup, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/packaged_hdogs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/chocolateegg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/meat/xeno, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/pastries/xemeatpie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/pastries/birthdaycakeslice, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/donut/meat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Botanist
/datum/job/survivor/botanist
	title = "Botanist Survivor"
	outfit = /datum/outfit/job/survivor/botanist


/datum/outfit/job/survivor/botanist
	name = "Botanist Survivor"
	jobtype = /datum/job/survivor/botanist

	w_uniform = /obj/item/clothing/under/rank/hydroponics
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/apron/overalls
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/hydroponics
	ears = /obj/item/radio/headset/survivor
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	l_hand = /obj/item/tool/hatchet

/datum/outfit/job/survivor/botanist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiadeus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiadeus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Atmospherics Technician
/datum/job/survivor/atmos
	title = "Technician Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/atmos


/datum/outfit/job/survivor/atmos
	name = "Technician Survivor"
	jobtype = /datum/job/survivor/atmos

	w_uniform = /obj/item/clothing/under/rank/atmospheric_technician
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/hazardvest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/som
	gloves = /obj/item/clothing/gloves/insulated
	belt = /obj/item/storage/belt
	head = /obj/item/clothing/head/hardhat/white
	glasses = /obj/item/clothing/glasses/welding
	r_pocket = /obj/item/storage/pouch/electronics/full
	l_pocket = /obj/item/storage/pouch/construction
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/atmos/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/multitool, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/lightreplacer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/deployable_floodlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/metalfoam, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/metalfoam, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_L_POUCH)


//Chaplain
/datum/job/survivor/chaplain
	title = "Chaplain Survivor"
	outfit = /datum/outfit/job/survivor/chaplain


/datum/outfit/job/survivor/chaplain
	name = "Chaplain Survivor"
	jobtype = /datum/job/survivor/chaplain

	w_uniform = /obj/item/clothing/under/rank/chaplain
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	belt = /obj/item/storage/holster/belt/m44/full
	ears = /obj/item/radio/headset/survivor
	l_hand = /obj/item/weapon/gun/shotgun/double
	r_hand = /obj/item/ammo_magazine/handful/buckshot

/datum/outfit/job/survivor/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/candle_box, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/bible, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/cup/glass/bottle/holywater , SLOT_IN_BACKPACK)


//Miner
/datum/job/survivor/miner
	title = "Miner Survivor"
	skills_type = /datum/skills/civilian/survivor/miner
	outfit = /datum/outfit/job/survivor/miner


/datum/outfit/job/survivor/miner
	name = "Miner Survivor"
	jobtype = /datum/job/survivor/miner

	w_uniform = /obj/item/clothing/under/rank/miner
	id = /obj/item/card/id/captains_spare/survival
	head = /obj/item/clothing/head/helmet/space/rig/mining
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/som
	l_hand = /obj/item/weapon/twohanded/sledgehammer
	r_pocket = /obj/item/reagent_containers/cup/glass/flask
	r_hand = /obj/item/clothing/suit/space/rig/mining
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/miner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/whiskey, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Salesman
/datum/job/survivor/salesman
	title = "Salesman Survivor"
	outfit = /datum/outfit/job/survivor/salesman


/datum/outfit/job/survivor/salesman
	name = "Salesman Survivor"
	jobtype = /datum/job/survivor/salesman

	w_uniform = /obj/item/clothing/under/lawyer/purpsuit
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/lawyer/purpjacket
	shoes = /obj/item/clothing/shoes/black
	belt = /obj/item/storage/holster/belt/pistol/g22
	back = /obj/item/storage/backpack/satchel
	mask = /obj/item/clothing/mask/cigarette/pipe/bonepipe
	glasses = /obj/item/clothing/glasses/sunglasses/aviator
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/salesman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter/zippo, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


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
	id = /obj/item/card/id/captains_spare/survival
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/satchel/sec
	suit_store = /obj/item/storage/holster/belt/m44/full
	belt = /obj/item/storage/belt/sparepouch
	gloves = /obj/item/clothing/gloves/ruggedgloves
	l_pocket = /obj/item/flashlight/combat
	ears = /obj/item/radio/headset/survivor
	head = /obj/item/clothing/head/slouch

/datum/outfit/job/survivor/marshal/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Bartender Survivor
/datum/job/survivor/bartender
	title = "Bartender Survivor"
	outfit = /datum/outfit/job/survivor/bartender


/datum/outfit/job/survivor/bartender
	name = "Bartender Survivor"
	jobtype = /datum/job/survivor/bartender

	w_uniform = /obj/item/clothing/under/rank/bartender
	wear_suit = /obj/item/clothing/suit/armor/vest
	id = /obj/item/card/id/captains_spare/survival
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/ammo_magazine/shotgun/buckshot
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/collectable/tophat
	ears = /obj/item/radio/headset/survivor
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/weapon/gun/shotgun/double/sawn

/datum/outfit/job/survivor/bartender/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/whiskey , SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/vodka , SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/beer , SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/beer , SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle , SLOT_IN_BACKPACK)


//Chemist Survivor
/datum/job/survivor/chemist
	title = "Pharmacy Technician Survivor"
	skills_type = /datum/skills/civilian/survivor/scientist
	outfit = /datum/outfit/job/survivor/chemist


/datum/outfit/job/survivor/chemist
	name = "Pharmacy Technician Survivor"
	jobtype = /datum/job/survivor/chemist

	w_uniform = /obj/item/clothing/under/rank/chemist
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/labcoat/chemist
	back = /obj/item/storage/backpack/satchel/chem
	belt = /obj/item/storage/belt/hypospraybelt
	gloves = /obj/item/clothing/gloves/latex
	shoes = /obj/item/clothing/shoes/white
	ears = /obj/item/radio/headset/survivor
	glasses = /obj/item/clothing/glasses/science
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/healthanalyzer

/datum/outfit/job/survivor/chemist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/bicaridine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/kelotane, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tramadol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tricordrazine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/lemoline/doctor, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/beaker/large, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/beaker/large, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/bicaridine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/kelotane, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/tramadol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/tricordrazine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/dylovene, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/inaprovaline, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/hypervene, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/imialky, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/big, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/big, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/syringe_case/empty, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/syringe_case/empty, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/dropper, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, SLOT_IN_BACKPACK)


//Roboticist Survivor
/datum/job/survivor/roboticist
	title = "Roboticist Survivor"
	skills_type = /datum/skills/civilian/survivor/atmos
	outfit = /datum/outfit/job/survivor/roboticist


/datum/outfit/job/survivor/roboticist
	name = "Roboticist Survivor"
	jobtype = /datum/job/survivor/roboticist

	w_uniform = /obj/item/clothing/under/rank/roboticist
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/storage/labcoat/science
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/tox
	ears = /obj/item/radio/headset/survivor
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
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle, SLOT_IN_BACKPACK)


//Non-Deployed Operative Survivor
/datum/job/survivor/non_deployed_operative
	title = "Non-Deployed Operative Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/non_deployed_operative

/datum/outfit/job/survivor/non_deployed_operative
	name = "Non-Deployed Operative Survivor"
	jobtype = /datum/job/survivor/non_deployed_operative

	w_uniform = /obj/item/clothing/under/marine/service
	id = /obj/item/card/id/captains_spare/survival
	gloves = /obj/item/clothing/gloves/white
	shoes = /obj/item/clothing/shoes/marine/full
	head = /obj/item/clothing/head/servicecap
	back = /obj/item/storage/backpack/marine/satchel
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/non_deployed_operative/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/pen, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/paper, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/folder/white, SLOT_IN_BACKPACK)


//Prisoner Survivor
/datum/job/survivor/prisoner
	title = "Prisoner Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/prisoner

/datum/outfit/job/survivor/prisoner
	name = "Prisoner Survivor"
	jobtype = /datum/job/survivor/prisoner

	w_uniform = /obj/item/clothing/under/rank/prisoner
	id = /obj/item/card/id/captains_spare/survival
	shoes = /obj/item/clothing/shoes/orange
	back =  /obj/item/storage/backpack/security
	mask = /obj/item/clothing/mask/gas/modular/skimask
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/prisoner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle, SLOT_IN_BACKPACK)


//Stripper Survivor
/datum/job/survivor/stripper
	title = "Stripper Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/stripper

/datum/outfit/job/survivor/stripper
	name = "Stripper Survivor"
	jobtype = /datum/job/survivor/stripper

	w_uniform = /obj/item/clothing/under/lewd/stripper
	id = /obj/item/card/id/captains_spare/survival
	shoes = /obj/item/clothing/shoes/high_heels/red
	back =  /obj/item/storage/backpack/satchel
	ears = /obj/item/radio/headset/survivor
	head = /obj/item/clothing/head/bunny_ears

/datum/outfit/job/survivor/stripper/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle, SLOT_IN_BACKPACK)


//Maid Survivor
/datum/job/survivor/maid
	title = "Maid Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/maid

/datum/outfit/job/survivor/maid
	name = "Maid Survivor"
	jobtype = /datum/job/survivor/maid

	w_uniform = /obj/item/clothing/under/dress/maid
	id = /obj/item/card/id/captains_spare/survival
	gloves = /obj/item/clothing/gloves/latex
	shoes = /obj/item/clothing/shoes/high_heels
	back =  /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/headset/survivor

/datum/outfit/job/survivor/maid/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/cans/waterbottle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/soap/deluxe, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bucket, SLOT_IN_BACKPACK)


// Rambo Survivor - pretty overpowered, pls spawn with caution
/datum/job/survivor/rambo
	title = "Rambo Survivor"
	skills_type = /datum/skills/civilian/survivor/master
	outfit = /datum/outfit/job/survivor/rambo
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN

/datum/outfit/job/survivor/rambo
	name = "Overpowered Survivor"
	jobtype = /datum/job/survivor/rambo

	w_uniform = /obj/item/clothing/under/marine/striped
	id = /obj/item/card/id/captains_spare/survival
	wear_suit = /obj/item/clothing/suit/armor/patrol
	shoes = /obj/item/clothing/shoes/marine/clf/full
	back = /obj/item/storage/holster/blade/machete/full
	gloves = /obj/item/clothing/gloves/ruggedgloves
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer
	belt = /obj/item/storage/belt/marine/alf_machinecarbine
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	r_pocket = /obj/item/flashlight/combat
	glasses = /obj/item/clothing/glasses/m42_goggles
	head = /obj/item/clothing/head/headband
	ears = /obj/item/radio/headset/survivor

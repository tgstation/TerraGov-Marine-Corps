/datum/job/upp
	special_role = "UPP"
	comm_title = "UPP"
	faction = "Union of Progressive People"
	supervisors = "the team leader"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/pfc/crafty
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/upp/generate_entry_conditions(mob/living/carbon/human/H)
		H.add_language("Russian")


//UPP Standard
/datum/job/upp/standard
	title = "UPP Standard"
	comm_title = "UPP PFC"
	paygrade = "UPP2"
	equipment = TRUE

/datum/job/upp/standard/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)


//UPP Medic
/datum/job/upp/medic
	title = "UPP Medic"
	comm_title = "UPP CPL"
	paygrade = "UPP3"
	skills_type = /datum/skills/combat_medic/crafty
	equipment = TRUE

/datum/job/upp/medic/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/skorpion/upp(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/upp_smg, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)


//UPP Heavy
/datum/job/upp/heavy
	title = "UPP Heavy"
	comm_title = "UPP LCPL"
	paygrade = "UPP4"
	skills_type = /datum/skills/specialist/upp
	equipment = TRUE

/datum/job/upp/heavy/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP/heavy(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(H), WEAR_L_STORE)


//UPP Leader
/datum/job/upp/leader
	title = "UPP Leader"
	comm_title = "UPP SGT"
	paygrade = "UPP5"
	skills_type = /datum/skills/SL/upp
	equipment = TRUE

/datum/job/upp/standard/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/standard(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(H), WEAR_L_STORE)


//The UPP Commandos
/datum/job/upp/commando
	special_role = "UPP"
	comm_title = "UPPC"
	skills_type = /datum/skills/commando


//UPP Commando Standard
/datum/job/upp/commando/standard
	title = "UPP Commando Standard"
	paygrade = "UPPC1"
	equipment = TRUE

/datum/job/upp/commando/standard/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/chameleon	(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)


//UPP Commando Medic
/datum/job/upp/commando/medic
	title = "UPP Commando Medic"
	paygrade = "UPPC2"
	skills_type = /datum/skills/commando/medic
	equipment = TRUE

/datum/job/upp/commando/medic/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/chameleon	(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/explosive/upp(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)


//UPP Commando Leader
/datum/job/upp/commando/leader
	title = "UPP Commando Leader"
	paygrade = "UPPC3"
	skills_type = /datum/skills/commando/leader
	equipment = TRUE

/datum/job/upp/commando/leader/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/chameleon(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/explosive/upp(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/handcuffs(H.back), WEAR_IN_BACK)
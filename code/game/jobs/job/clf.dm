/datum/job/clf
	special_role = "CLF"
	comm_title = "CLF"
	faction = "Colonial Liberation Force"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/pfc/crafty
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	equipment = TRUE

/datum/job/clf/standard/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/militia(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/knifepouch(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(H), WEAR_L_HAND)


//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	equipment = TRUE

/datum/job/clf/medic/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/militia(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
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


//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	equipment = TRUE

/datum/job/clf/leader/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/militia(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), WEAR_WAIST)
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
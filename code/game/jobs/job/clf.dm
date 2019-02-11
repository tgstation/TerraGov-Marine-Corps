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
	var/obj/item/storage/pouch/general/RS = new /obj/item/storage/pouch/general(H)
	RS.contents += new /obj/item/reagent_container/hypospray/autoinjector/tramadol

	var/obj/item/clothing/suit/storage/militia/J = new /obj/item/clothing/suit/storage/militia(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/ammo_magazine/smg/uzi/extended
	B.contents += new /obj/item/ammo_magazine/smg/uzi/extended
	B.contents += new /obj/item/ammo_magazine/smg/uzi/extended
	B.contents += new /obj/item/ammo_magazine/smg/uzi/extended


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/knifepouch(H), SLOT_BELT)
	H.equip_to_slot_or_del(pick(new /obj/item/storage/pill_bottle/happy(H), new /obj/item/storage/pill_bottle/zoom(H)), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/katana(H), SLOT_L_HAND)


//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	skills_type = /datum/skills/combat_medic/crafty
	equipment = TRUE

/datum/job/clf/medic/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/pouch/medkit/RS = new /obj/item/storage/pouch/medkit(H)
	RS.contents += new /obj/item/storage/firstaid/adv

	var/obj/item/clothing/suit/storage/militia/J = new /obj/item/clothing/suit/storage/militia(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/device/defibrillator
	B.contents += new /obj/item/device/healthanalyzer
	B.contents += new /obj/item/roller
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/skorpion/upp(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), SLOT_GLASSES)


//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	equipment = TRUE

/datum/job/clf/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/belt/marine/W = new /obj/item/storage/belt/marine(H)
	W.contents += new /obj/item/ammo_magazine/rifle/m16
	W.contents += new /obj/item/ammo_magazine/rifle/m16
	W.contents += new /obj/item/ammo_magazine/rifle/m16
	W.contents += new /obj/item/ammo_magazine/rifle/m16
	W.contents += new /obj/item/ammo_magazine/rifle/m16

	var/obj/item/storage/pouch/general/medium/RS = new /obj/item/storage/pouch/general/medium(H)
	RS.contents += new /obj/item/device/binoculars
	RS.contents += new /obj/item/explosive/plastique

	var/obj/item/clothing/suit/storage/militia/J = new /obj/item/clothing/suit/storage/militia(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/weapon/gun/pistol/highpower
	B.contents += new /obj/item/ammo_magazine/pistol/highpower
	B.contents += new /obj/item/ammo_magazine/pistol/highpower


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/militia(H), SLOT_HEAD)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m16(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(W, SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
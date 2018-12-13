/datum/job/freelancer
	special_role = "Freelancer"
	comm_title = "FRE"
	faction = "Freelancers"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/pfc/crafty
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


//Freelancer Standard
/datum/job/freelancer/standard
	title = "Freelancer Standard"
	paygrade = "FRE1"
	equipment = TRUE

/datum/job/freelancer/standard/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/belt/marine/W = new /obj/item/storage/belt/marine(H)
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40

	var/obj/item/storage/pouch/general/RS = new /obj/item/storage/pouch/general(H)
	RS.contents += new /obj/item/weapon/throwing_knife

	var/obj/item/clothing/suit/storage/faction/freelancer/J = new /obj/item/clothing/suit/storage/faction/freelancer(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(H), WEAR_HEAD)
	H.equip_to_slot_or_del(W, WEAR_WAIST)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(S, WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(RS, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/mar40(H), WEAR_J_STORE)


//Freelancer Medic
/datum/job/freelancer/medic
	title = "Freelancer Medic"
	paygrade = "FRE2"
	equipment = TRUE
	skills_type = /datum/skills/combat_medic

/datum/job/freelancer/medic/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/pouch/medkit/RS = new /obj/item/storage/pouch/medkit(H)
	RS.contents += new /obj/item/storage/firstaid/adv

	var/obj/item/clothing/suit/storage/faction/freelancer/J = new /obj/item/clothing/suit/storage/faction/freelancer(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/device/defibrillator
	B.contents += new /obj/item/device/healthanalyzer
	B.contents += new /obj/item/roller
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/ammo_magazine/smg/p90
	B.contents += new /obj/item/ammo_magazine/smg/p90
	B.contents += new /obj/item/ammo_magazine/smg/p90
	B.contents += new /obj/item/ammo_magazine/smg/p90

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), WEAR_WAIST)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(RS, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/p90(H), WEAR_J_STORE)


//Freelancer Leader
/datum/job/freelancer/leader
	title = "Freelancer Leader"
	paygrade = "FRE3"
	equipment = TRUE
	skills_type = /datum/skills/SL

/datum/job/freelancer/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/belt/marine/W = new /obj/item/storage/belt/marine(H)
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40
	W.contents += new /obj/item/ammo_magazine/rifle/mar40

	var/obj/item/storage/pouch/general/medium/RS = new /obj/item/storage/pouch/general/medium(H)
	RS.contents += new /obj/item/device/binoculars
	RS.contents += new /obj/item/explosive/plastique

	var/obj/item/clothing/suit/storage/faction/freelancer/J = new /obj/item/clothing/suit/storage/faction/freelancer(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	J.pockets.contents += new /obj/item/explosive/grenade/frag/stick

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/stack/sheet/plasteel/small_stack
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/storage/box/MRE
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer/beret(H), WEAR_HEAD)
	H.equip_to_slot_or_del(W, WEAR_WAIST)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(S, WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(RS, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/mar40/carbine(H), WEAR_J_STORE)
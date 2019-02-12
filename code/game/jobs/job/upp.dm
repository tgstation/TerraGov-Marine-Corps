/datum/job/upp
	special_role = "UPP"
	comm_title = "UPP"
	faction = "Union of Progressive People"
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
	var/obj/item/clothing/suit/storage/faction/UPP/J = new /obj/item/clothing/suit/storage/faction/UPP(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/bayonet/RS = new /obj/item/storage/pouch/bayonet(H)
	RS.contents += new /obj/item/weapon/combat_knife/upp
	RS.contents += new /obj/item/weapon/combat_knife/upp
	RS.contents += new /obj/item/weapon/combat_knife/upp

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/plastique
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/stack/sheet/metal/small_stack


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP(H), SLOT_HEAD)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)


//UPP Medic
/datum/job/upp/medic
	title = "UPP Medic"
	comm_title = "UPP CPL"
	paygrade = "UPP3"
	skills_type = /datum/skills/combat_medic/crafty
	equipment = TRUE

/datum/job/upp/medic/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/faction/UPP/J = new /obj/item/clothing/suit/storage/faction/UPP(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/medkit/RS = new /obj/item/storage/pouch/medkit(H)
	RS.contents += new /obj/item/storage/firstaid/adv

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/device/defibrillator
	B.contents += new /obj/item/device/healthanalyzer
	B.contents += new /obj/item/roller
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion
	B.contents += new /obj/item/ammo_magazine/smg/skorpion


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), SLOT_BELT)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/skorpion/upp(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), SLOT_GLASSES)


//UPP Heavy
/datum/job/upp/heavy
	title = "UPP Heavy"
	comm_title = "UPP LCPL"
	paygrade = "UPP4"
	skills_type = /datum/skills/specialist/upp
	equipment = TRUE

/datum/job/upp/heavy/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/faction/UPP/heavy/J = new /obj/item/clothing/suit/storage/faction/UPP/heavy(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/explosive/RS = new /obj/item/storage/pouch/explosive(H)
	RS.contents += new /obj/item/device/assembly/signaler
	RS.contents += new /obj/item/device/radio/detpack
	RS.contents += new /obj/item/device/radio/detpack
	RS.contents += new /obj/item/explosive/grenade/cloakbomb

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/plastique
	B.contents += new /obj/item/stack/sheet/metal/small_stack
	B.contents += new /obj/item/ammo_magazine/flamer_tank


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP/heavy(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)


//UPP Leader
/datum/job/upp/leader
	title = "UPP Leader"
	comm_title = "UPP SGT"
	paygrade = "UPP5"
	skills_type = /datum/skills/SL/upp
	equipment = TRUE

/datum/job/upp/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/faction/UPP/heavy/J = new /obj/item/clothing/suit/storage/faction/UPP/heavy(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/general/large/RS = new /obj/item/storage/pouch/general/large(H)
	RS.contents += new /obj/item/device/binoculars
	RS.contents += new /obj/item/explosive/plastique
	RS.contents += new /obj/item/explosive/plastique

	var/obj/item/weapon/gun/rifle/type71/carbine/R = new /obj/item/weapon/gun/rifle/type71/carbine(H)
	R.rail = new /obj/item/attachable/scope/slavic
	R.under = new /obj/item/attachable/verticalgrip

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/explosive/grenade/incendiary/molotov
	B.contents += new /obj/item/stack/sheet/metal/medium_stack
	B.contents += new /obj/item/stack/sheet/plasteel/small_stack
	B.contents += new /obj/item/ammo_magazine/rifle/type71
	B.contents += new /obj/item/ammo_magazine/rifle/type71
	B.contents += new /obj/item/ammo_magazine/rifle/type71


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(H), SLOT_HEAD)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(R, SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/standard(H), SLOT_BELT)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)


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
	var/obj/item/clothing/suit/storage/faction/UPP/commando/J = new /obj/item/clothing/suit/storage/faction/UPP/commando(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/general/large/RS = new /obj/item/storage/pouch/general/large(H)
	RS.contents += new /obj/item/device/binoculars
	RS.contents += new /obj/item/explosive/plastique
	RS.contents += new /obj/item/explosive/plastique

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/stack/sheet/metal/medium_stack
	B.contents += new /obj/item/stack/sheet/plasteel/small_stack
	B.contents += new /obj/item/device/chameleon


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)


//UPP Commando Medic
/datum/job/upp/commando/medic
	title = "UPP Commando Medic"
	paygrade = "UPPC2"
	skills_type = /datum/skills/commando/medic
	equipment = TRUE

/datum/job/upp/commando/medic/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/faction/UPP/commando/J = new /obj/item/clothing/suit/storage/faction/UPP/commando(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/medkit/RS = new /obj/item/storage/pouch/medkit(H)
	RS.contents += new /obj/item/storage/firstaid/adv

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/device/healthanalyzer
	B.contents += new /obj/item/device/defibrillator
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/device/chameleon
	B.contents += new /obj/item/clothing/glasses/hud/health
	B.contents += new /obj/item/ammo_magazine/rifle/type71
	B.contents += new /obj/item/ammo_magazine/rifle/type71


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(H), SLOT_HEAD)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)


//UPP Commando Leader
/datum/job/upp/commando/leader
	title = "UPP Commando Leader"
	paygrade = "UPPC3"
	skills_type = /datum/skills/commando/leader
	equipment = TRUE

/datum/job/upp/commando/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/faction/UPP/commando/J = new /obj/item/clothing/suit/storage/faction/UPP/commando(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp
	J.pockets.contents += new /obj/item/explosive/grenade/frag/upp

	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife/upp
	S.update_icon()

	var/obj/item/storage/pouch/general/large/RS = new /obj/item/storage/pouch/general/large(H)
	RS.contents += new /obj/item/device/binoculars
	RS.contents += new /obj/item/device/assembly/signaler
	RS.contents += new /obj/item/device/radio/detpack

	var/obj/item/storage/backpack/lightpack/B = new /obj/item/storage/backpack/lightpack(H)
	B.contents += new /obj/item/reagent_container/food/snacks/upp
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/explosive/grenade/phosphorus/upp
	B.contents += new /obj/item/stack/sheet/metal/medium_stack
	B.contents += new /obj/item/stack/sheet/plasteel/small_stack
	B.contents += new /obj/item/device/chameleon
	B.contents += new /obj/item/ammo_magazine/rifle/type71
	B.contents += new /obj/item/ammo_magazine/rifle/type71
	B.contents += new /obj/item/ammo_magazine/rifle/type71


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(J, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(H), SLOT_HEAD)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(H), SLOT_BELT)
	H.equip_to_slot_or_del(RS, SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)
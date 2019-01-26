/datum/job/pmc
	special_role = "PMC"
	comm_title = "NT"
	faction = "Weyland-Yutani"
	idtype = /obj/item/card/id/centcom
	skills_type = /datum/skills/pfc/pmc
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


//PMC Standard
/datum/job/pmc/standard
	title = "PMC Standard"
	paygrade = "PMC1"
	equipment = TRUE

/datum/job/pmc/standard/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/marine/veteran/PMC/J = new /obj/item/clothing/suit/storage/marine/veteran/PMC(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	var/obj/item/storage/backpack/satchel/B = new /obj/item/storage/backpack/satchel(H)
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/weapon/baton
	B.contents += new /obj/item/handcuffs


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_m39(H), WEAR_R_STORE)


//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	equipment = TRUE

/datum/job/pmc/gunner/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/pouch/general/large/RS = new /obj/item/storage/pouch/general/large(H)
	RS.contents += new /obj/item/handcuffs
	RS.contents += new /obj/item/explosive/mine/pmc
	RS.contents += new /obj/item/explosive/plastique

	var/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC/J = new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(RS, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), WEAR_WAIST)


//PMC Sniper
/datum/job/pmc/sniper
	title = "PMC Sniper"
	paygrade = "PMC3"
	skills_type = /datum/skills/specialist/pmc
	equipment = TRUE

/datum/job/pmc/sniper/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper/J = new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	var/obj/item/storage/backpack/satchel/B = new /obj/item/storage/backpack/satchel(H)
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/weapon/baton
	B.contents += new /obj/item/handcuffs


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), WEAR_EYES)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_sniper(H), WEAR_R_STORE)


//PMC Leader
/datum/job/pmc/leader
	title = "PMC Leader"
	paygrade = "PMC4"
	skills_type = /datum/skills/SL/pmc
	equipment = TRUE

/datum/job/pmc/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/marine/veteran/PMC/leader/J = new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/leader/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	var/obj/item/storage/backpack/satchel/B = new /obj/item/storage/backpack/satchel(H)
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/storage/box/m94
	B.contents += new /obj/item/weapon/baton
	B.contents += new /obj/item/handcuffs
	B.contents += new /obj/item/explosive/plastique


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), WEAR_FACE)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp78(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(H), WEAR_J_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_rifle(H), WEAR_R_STORE)


//PM Deathsquad
/datum/job/pmc/deathsquad
	special_role = "Deathsquad"


//PMC Deathsquad Standard
/datum/job/pmc/deathsquad/standard
	title = "PMC Deathsquad Standard"
	paygrade = "PMCDS"
	skills_type = /datum/skills/SL/pmc
	equipment = TRUE

/datum/job/pmc/deathsquad/standard/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/marine/veteran/PMC/commando/J = new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/commando/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	var/obj/item/storage/backpack/commando/B = new /obj/item/storage/backpack/commando(H)
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/explosive/plastique
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/assembly/signaler


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full, WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_rifle, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/admiral(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(H), WEAR_J_STORE)


//PMC Deathsquad Leader
/datum/job/pmc/deathsquad/leader
	title = "PMC Deathsquad Leader"
	paygrade = "PMCDSL"
	skills_type = /datum/skills/SL/pmc
	equipment = TRUE

/datum/job/pmc/deathsquad/leader/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/storage/marine/veteran/PMC/commando/J = new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(H)
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC
	J.pockets.contents += new /obj/item/explosive/grenade/frag/PMC

	var/obj/item/clothing/head/helmet/marine/veteran/PMC/commando/D = new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(H)
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar
	D.pockets.contents += new /obj/item/reagent_container/food/snacks/eat_bar

	var/obj/item/storage/backpack/commando/B = new /obj/item/storage/backpack/commando(H)
	B.contents += new /obj/item/device/radio
	B.contents += new /obj/item/tool/crowbar/red
	B.contents += new /obj/item/explosive/plastique
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/radio/detpack
	B.contents += new /obj/item/device/assembly/signaler

	var/obj/item/storage/pouch/explosive/RS = new /obj/item/storage/pouch/explosive(H)
	RS.contents += new /obj/item/ammo_magazine/rocket/m57a4
	RS.contents += new /obj/item/ammo_magazine/rocket/m57a4
	RS.contents += new /obj/item/ammo_magazine/rocket/m57a4
	RS.contents += new /obj/item/ammo_magazine/rocket/m57a4


	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(H), WEAR_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(H), WEAR_BODY)
	H.equip_to_slot_or_del(J, WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(H), WEAR_HANDS)
	H.equip_to_slot_or_del(D, WEAR_HEAD)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full, WEAR_L_STORE)
	H.equip_to_slot_or_del(RS, WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/admiral(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/m57a4(H), WEAR_J_STORE)
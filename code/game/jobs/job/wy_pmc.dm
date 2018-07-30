/datum/job/pmc
	special_role = "PMC"
	comm_title = "WY"
	faction = "Weyland-Yutani"
	supervisors = "the team leader"
	idtype = /obj/item/card/id/centcom
	//flag = WY_PMC
	//department_flag = WY_PMC
	minimal_player_age = 0
	skills_type = /datum/skills/pfc

/datum/job/pmc/proc/generate_random_pmc_primary(shuffle = rand(1,20))
	var/L[] = list(
				WEAR_ACCESSORY = /obj/item/clothing/tie/storage/webbing,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/quickclot,
				WEAR_IN_JACKET = /obj/item/explosive/grenade/frag/PMC
				)
	switch(shuffle)
		if(1 to 11)
			L += list(
					WEAR_J_STORE = /obj/item/weapon/gun/smg/m39/elite,
					WEAR_R_STORE = /obj/item/storage/pouch/magazine/large/pmc_m39,
					WEAR_IN_BACK = /obj/item/ammo_magazine/smg/m39/ap,
					WEAR_IN_BACK = /obj/item/ammo_magazine/smg/m39/ap
					)
		if(12,15)
			L += list(
					WEAR_J_STORE = /obj/item/weapon/gun/smg/p90,
					WEAR_R_STORE = /obj/item/storage/pouch/magazine/large/pmc_p90,
					WEAR_IN_BACK = /obj/item/ammo_magazine/smg/p90,
					WEAR_IN_BACK = /obj/item/ammo_magazine/smg/p90
					)
		if(16,18)
			L += list(
					WEAR_J_STORE = /obj/item/weapon/gun/rifle/lmg,
					WEAR_R_STORE = /obj/item/storage/pouch/magazine/large/pmc_lmg,
					WEAR_IN_BACK = /obj/item/ammo_magazine/rifle/lmg,
					WEAR_IN_BACK = /obj/item/ammo_magazine/rifle/lmg
					)
		else
			L += list(
					WEAR_J_STORE = /obj/item/weapon/gun/revolver/mateba,
					WEAR_R_STORE = /obj/item/storage/pouch/magazine/pistol/pmc_mateba,
					WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/revolver/mateba,
					WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/revolver/mateba,
					WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/revolver/mateba
					)
	return L

//PMC standard.
/datum/job/pmc/security_expert
	title = "PMC Standard"
	paygrade = "PMC1"
	total_positions = -1
	spawn_positions = -1
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

	generate_wearable_equipment()
		var/L[] = list(
						WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
						WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
						WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
						WEAR_HANDS = /obj/item/clothing/gloves/marine/veteran/PMC,
						WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC
						)
		if(prob(65)) L[WEAR_FACE] = /obj/item/clothing/mask/gas/PMC
		if(prob(65)) L[WEAR_HEAD] = /obj/item/clothing/head/helmet/marine/veteran/PMC
		return L

	generate_stored_equipment()
		var/L[] = new
		if(prob(60))
			L[WEAR_WAIST] = /obj/item/weapon/gun/pistol/vp70
			L[WEAR_L_STORE] = /obj/item/storage/pouch/magazine/pistol/pmc_vp70
		else if(prob(35)) L[WEAR_WAIST] = /obj/item/storage/belt/knifepouch
		L[WEAR_IN_JACKET] = /obj/item/reagent_container/hypospray/autoinjector/quickclot
		L[WEAR_IN_JACKET] = /obj/item/explosive/grenade/frag/PMC
		return L

	equip(mob/living/carbon/human/H, L[] = generate_wearable_equipment() + generate_stored_equipment() + generate_random_pmc_primary())
		. = ..(H, L)

//PMC support engineer.
/datum/job/pmc/support_specialist_mechanic
	title = "PMC Mechanic"
	paygrade = "PMC2S"
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/combat_engineer

	generate_wearable_equipment()
		var/L[] = list(
						WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
						WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
						WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
						WEAR_HANDS = /obj/item/clothing/gloves/yellow,
						SLOW_WAIST = /obj/item/storage/belt/utility/full,
						WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC,
						WEAR_EYES = /obj/item/clothing/glasses/welding,
						WEAR_BACK = /obj/item/storage/backpack/satchel/eng
						)
		if(prob(65)) L[WEAR_FACE] = /obj/item/clothing/mask/gas/PMC
		if(prob(65)) L[WEAR_HEAD] = /obj/item/clothing/head/helmet/marine/veteran/PMC
		return L

	generate_stored_equipment()
		. = list(
				WEAR_L_STORE = /obj/item/storage/pouch/explosive,
				WEAR_IN_BACK = /obj/item/explosive/plastique,
				WEAR_IN_BACK = /obj/item/stack/sheet/plasteel,
				WEAR_IN_BACK = /obj/item/explosive/grenade/frag/PMC,
				WEAR_IN_BACK = /obj/item/explosive/grenade/incendiary,
				WEAR_IN_BACK = /obj/item/stack/sheet/plasteel
				)

	equip(mob/living/carbon/human/H, L[] = generate_wearable_equipment() + generate_stored_equipment() + generate_random_pmc_primary())
		. = ..(H, L)

//PMC support medic.
/datum/job/pmc/support_specialist_triage
	title = "PMC Triage"
	paygrade = "PMC2M"
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/combat_medic

	generate_wearable_equipment()
		var/L[] = list(
						WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
						WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
						WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
						WEAR_HANDS = /obj/item/clothing/gloves/latex,
						SLOW_WAIST = /obj/item/storage/belt/combatLifesaver,
						WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC,
						WEAR_EYES = /obj/item/clothing/glasses/hud/health,
						WEAR_BACK = /obj/item/storage/backpack/satchel/med
						)
		if(prob(65)) L[WEAR_FACE] = /obj/item/clothing/mask/gas/PMC
		if(prob(65)) L[WEAR_HEAD] = /obj/item/clothing/head/helmet/marine/veteran/PMC
		return L

	generate_stored_equipment()
		. = list(
				WEAR_L_STORE = /obj/item/storage/pouch/medkit/full,
				WEAR_IN_BACK = /obj/item/reagent_container/hypospray/autoinjector/Oxycodone,
				WEAR_IN_BACK = /obj/item/storage/firstaid/adv,
				WEAR_IN_BACK = /obj/item/device/defibrillator,
				WEAR_IN_BACK = /obj/item/bodybag,
				WEAR_IN_BACK = /obj/item/storage/pill_bottle/inaprovaline,
				WEAR_IN_BACK = /obj/item/storage/pill_bottle/tramadol
				)

	equip(mob/living/carbon/human/H, L[] = generate_wearable_equipment() + generate_stored_equipment() + generate_random_pmc_primary())
		. = ..(H, L)

//PMC elite/weapon specialist.
/datum/job/pmc/elite_responder
	title = "PMC Elite"
	paygrade = "PMC3"
	total_positions = 2
	spawn_positions = 2
	minimal_player_age = 7
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)

/datum/job/pmc/elite_responder/gunner
	title = "PMC Gunner"
	skills_type = /datum/skills/smartgunner/pmc

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
				WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
				WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/veteran/PMC,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC,
				WEAR_FACE = /obj/item/clothing/mask/gas/PMC,
				WEAR_HEAD = /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner,
				WEAR_BACK = /obj/item/smartgun_powerpack/snow,
				WEAR_EYES = /obj/item/clothing/glasses/night/m56_goggles
				)

	generate_stored_equipment()
		. = list(
				SLOW_WAIST = /obj/item/weapon/gun/pistol/vp70,
				WEAR_J_STORE = /obj/item/weapon/gun/smartgun/dirty,
				WEAR_L_STORE = /obj/item/storage/pouch/magazine/pistol/pmc_vp70,
				WEAR_IN_BACK = /obj/item/explosive/plastique,
				WEAR_ACCESSORY = /obj/item/clothing/tie/storage/webbing,
				WEAR_IN_ACCESSORY = /obj/item/explosive/grenade/phosphorus,
				WEAR_IN_ACCESSORY = /obj/item/explosive/grenade/smokebomb,
				WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/pistol/vp70,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/quickclot,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/Oxycodone
				)

/datum/job/pmc/elite_responder/sharpshooter
	title = "PMC Sharpshooter"
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/specialist/pmc

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
				WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
				WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/veteran/PMC,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper,
				WEAR_EYES = /obj/item/clothing/glasses/m42_goggles,
				WEAR_HEAD = /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper
				)

	generate_stored_equipment()
		. = list(
				SLOW_WAIST = /obj/item/weapon/gun/pistol/vp70,
				WEAR_J_STORE = /obj/item/weapon/gun/rifle/sniper/elite,
				WEAR_L_STORE = /obj/item/storage/pouch/magazine/large/pmc_sniper,
				WEAR_IN_BACK = /obj/item/device/flashlight,
				WEAR_ACCESSORY = /obj/item/clothing/tie/storage/black_vest,
				WEAR_IN_BACK = /obj/item/ammo_magazine/pistol/vp70,
				WEAR_IN_ACCESSORY = /obj/item/device/flashlight/flare,
				WEAR_IN_ACCESSORY = /obj/item/device/flashlight/flare,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/quickclot,
				WEAR_IN_JACKET = /obj/item/stack/medical/bruise_pack
				)

/datum/job/pmc/elite_responder/ninja
	title = "PMC Ninja"
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/ninja

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
				WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC,
				WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
				WEAR_WAIST = /obj/item/storage/belt/knifepouch,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC,
				WEAR_BACK = /obj/item/weapon/katana
				)

	generate_stored_equipment()
		. = list(
				WEAR_IN_BACK = /obj/item/device/binoculars,
				WEAR_R_STORE = /obj/item/storage/pouch/magazine/large/pmc_rifle,
				WEAR_L_STORE = /obj/item/storage/pouch/general/large,
				WEAR_J_STORE = /obj/item/weapon/gun/rifle/m41a/elite,
				WEAR_ACCESSORY = /obj/item/clothing/tie/storage/black_vest,
				WEAR_IN_BACK = /obj/item/ammo_magazine/rifle/extended,
				WEAR_IN_ACCESSORY = /obj/item/explosive/grenade/frag/PMC,
				WEAR_IN_ACCESSORY = /obj/item/device/flashlight,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/quickclot,
				WEAR_IN_JACKET = /obj/item/stack/medical/advanced/bruise_pack
				)

/datum/job/pmc/elite_responder/commando
	title = "PMC Commando"
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/commando

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
				WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC/commando,
				WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC/commando,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/veteran/PMC/commando,
				SLOW_WAIST = /obj/item/storage/belt/grenade,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando,
				WEAR_FACE = /obj/item/clothing/mask/gas/PMC,
				WEAR_HEAD = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando,
				WEAR_BACK = /obj/item/storage/backpack/commando
				)

	generate_stored_equipment()
		. = list(
				WEAR_L_STORE = /obj/item/storage/pouch/bayonet/full,
				WEAR_IN_BACK = /obj/item/explosive/plastique,
				WEAR_IN_BACK = /obj/item/explosive/plastique,
				WEAR_IN_BACK = /obj/item/storage/firstaid/regular,
				WEAR_IN_BACK = /obj/item/device/flashlight
				)

	equip(mob/living/carbon/human/H, L[] = generate_wearable_equipment() + generate_stored_equipment() + generate_random_pmc_primary())
		. = ..(H, L)

//PMC team leader, the one in charge.
/datum/job/pmc/team_leader
	title = "PMC Leader"
	paygrade = "PMC4"
	supervisors = "the W-Y corporate office"
	total_positions = 2
	spawn_positions = 2
	minimal_player_age = 10
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_PMC_WHITE, ACCESS_WY_CORPORATE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_PMC_WHITE, ACCESS_WY_CORPORATE)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/SL/pmc

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/distress/PMC,
				WEAR_BODY = /obj/item/clothing/under/marine/veteran/PMC/leader,
				WEAR_FEET = /obj/item/clothing/shoes/veteran/PMC,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/veteran/PMC,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/veteran/PMC/leader,
				WEAR_EYES = /obj/item/clothing/glasses/hud/health,
				WEAR_FACE = /obj/item/clothing/mask/gas/PMC/leader,
				WEAR_HEAD = /obj/item/clothing/head/helmet/marine/veteran/PMC/leader,
				WEAR_BACK = /obj/item/storage/backpack/satchel
				)

	generate_stored_equipment()
		. = list(
				SLOW_WAIST = /obj/item/weapon/gun/pistol/vp78,
				WEAR_J_STORE = /obj/item/weapon/gun/shotgun/combat,
				WEAR_IN_BACK = /obj/item/device/binoculars,
				WEAR_R_STORE = /obj/item/storage/pouch/magazine/pistol/pmc_vp78,
				WEAR_IN_BACK = /obj/item/ammo_magazine/shotgun,
				WEAR_IN_BACK = /obj/item/ammo_magazine/shotgun/buckshot,
				WEAR_IN_BACK = /obj/item/ammo_magazine/shotgun/incendiary,
				WEAR_IN_BACK = /obj/item/weapon/baton,
				WEAR_IN_BACK = /obj/item/device/flashlight,
				WEAR_IN_BACK = /obj/item/explosive/grenade/frag/PMC,
				WEAR_ACCESSORY = /obj/item/clothing/tie/storage/webbing,
				WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/pistol/vp70,
				WEAR_IN_ACCESSORY = /obj/item/ammo_magazine/pistol/vp70,
				WEAR_IN_ACCESSORY = /obj/item/explosive/grenade/smokebomb,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/quickclot,
				WEAR_IN_JACKET = /obj/item/reagent_container/hypospray/autoinjector/Bicard
				)
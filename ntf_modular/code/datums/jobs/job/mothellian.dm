/datum/job/mothellian
	supervisors = "your squad leader and their veterans"
	job_category = JOB_CAT_UNASSIGNED
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_MOTHELLIAN
	minimap_icon = "freelancer"
	outfit = /datum/outfit/job/mothellian
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_BANK_ACCOUNT
	shadow_languages = list(/datum/language/moth)

/datum/job/mothellian/return_spawn_type(datum/preferences/prefs) // I know, full laziness on my side, moving on.
	switch(prefs?.species)
		if("Mothellian")
			if(!(SSticker.mode?.round_type_flags & MODE_HUMAN_ONLY))
				return /mob/living/carbon/human/species/moth
		else
			return /mob/living/carbon/human/species/moth

//What all freelancers have shared in between them
/datum/outfit/job/mothellian
	name = "Mothellian"
	jobtype = /datum/job/mothellian

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/rebreather/scarf/freelancer
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/mothellian
	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/frelancer/mothellian/base
	back = /obj/item/storage/backpack/lightpack
	l_pocket = /obj/item/storage/pouch/medkit/firstaid

/datum/outfit/job/mothellian/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife, SLOT_IN_BOOT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/burger/tofu, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/flask/marine, SLOT_IN_BACKPACK)

//Freelancer Standard
/datum/job/mothellian/standard
	title = "Mothellian Standard"
	paygrade = "MTH1"
	display_order = JOB_DISPLAY_ORDER_MOFFS
	outfit = /datum/outfit/job/mothellian/standard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/mothellian/standard/one,
		/datum/outfit/job/mothellian/standard/two,
		/datum/outfit/job/mothellian/standard/three,
	)

/datum/outfit/job/mothellian/standard
	name = "Mothellian Standard"
	jobtype = /datum/job/mothellian/standard

/datum/outfit/job/mothellian/standard/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/mothellian/standard/one
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_pocket = /obj/item/storage/pouch/shotgun

/datum/outfit/job/mothellian/standard/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

///m16 ugl
/datum/outfit/job/mothellian/standard/two
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl
	r_pocket = /obj/item/storage/pouch/grenade

/datum/outfit/job/mothellian/standard/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///tx11
/datum/outfit/job/mothellian/standard/three
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	r_pocket = /obj/item/storage/pouch/grenade

/datum/outfit/job/mothellian/standard/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

/datum/job/mothellian/standard/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the glorious Mothellian Republic!
You were born on one of the many planets under the umbrella of the Mothellian Republic. In the Republic, every member is deeply versed in the art of trade and exchange, Material wealth a key component to the betterment of your species!
You serve in the Mothellian Military in order to bring profit to your family and clan, everyone contributes! You are a grunt soldier, do your best to protect your medics and listen to your Leader or the Veterans!"}

//Mothellian Medic
/datum/job/mothellian/medic
	title = "Mothellian Medic"
	paygrade = "MTH2"
	display_order = JOB_DISPLAY_ORDER_MOFFS
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/mothellian/medic

/datum/outfit/job/mothellian/medic
	name = "Mothellian Medic"
	jobtype = /datum/job/mothellian/medic

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian/unique/medic
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/famas/freelancermedic
	head = /obj/item/clothing/head/frelancer/mothellian/medic
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic
	l_pocket = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/mothellian/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)

/datum/job/mothellian/medic/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the glorious Mothellian Republic!
You were born on one of the many planets under the umbrella of the Mothellian Republic. In the Republic, every member is deeply versed in the art of trade and exchange, Material wealth a key component to the betterment of your species!
You serve in the Mothellian Military in order to bring profit to your family and clan, everyone contributes! You are a Medic, you follow the orders of the Leader, or if not available, a Veteran. Your job is to make sure everyone makes it home!"}

//Mothellian engineer
/datum/job/mothellian/engi
	title = "Mothellian Technician"
	paygrade = "MTH3"
	display_order = JOB_DISPLAY_ORDER_MOFFS
	skills_type = /datum/skills/combat_engineer
	outfit = /datum/outfit/job/mothellian/engi

/datum/outfit/job/mothellian/engi
	name = "Mothellian Technician"
	jobtype = /datum/job/mothellian/engi

	glasses = /obj/item/clothing/glasses/meson
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian/unique/engi
	suit_store = /obj/item/storage/holster/belt/ts34/full
	head = /obj/item/clothing/head/frelancer/mothellian/engineer
	r_pocket = /obj/item/storage/pouch/electronics/full
	l_pocket = /obj/item/storage/pouch/construction/equippedengineer
	back = /obj/item/storage/backpack/marine/engineerpack
	belt = /obj/item/storage/belt/utility/full


/datum/outfit/job/mothellian/engi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/deployable_floodlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_SUIT)

/datum/job/mothellian/engi/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the glorious Mothellian Republic!
You were born on one of the many planets under the umbrella of the Mothellian Republic. In the Republic, every member is deeply versed in the art of trade and exchange, Material wealth a key component to the betterment of your species!
You serve in the Mothellian Military in order to bring profit to your family and clan, everyone contributes!"}


//Mothellian Veteran. Generic term for 'better equipped dude'
/datum/job/mothellian/grenadier
	title = "Mothellian Veteran"
	paygrade = "MTH4"
	supervisors = "your squad leader"
	display_order = JOB_DISPLAY_ORDER_MOFFS
	outfit = /datum/outfit/job/mothellian/grenadier
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/mothellian/grenadier/one,
		/datum/outfit/job/mothellian/grenadier/two,
		/datum/outfit/job/mothellian/grenadier/three,
	)

/datum/outfit/job/mothellian/grenadier
	name = "Mothellian Veteran"
	jobtype = /datum/job/mothellian/grenadier

	head = /obj/item/clothing/head/frelancer/mothellian/veteran

/datum/outfit/job/mothellian/grenadier/one
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/mothellian/veteran
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer
	r_pocket = /obj/item/storage/pouch/grenade

/datum/outfit/job/mothellian/grenadier/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///machine gunner
/datum/outfit/job/mothellian/grenadier/two
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/m412l1_hpr/freelancer

/datum/outfit/job/mothellian/grenadier/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///actual grenadier
/datum/outfit/job/mothellian/grenadier/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_pocket = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/mothellian/grenadier/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)

/datum/job/mothellian/grenadier/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the glorious Mothellian Republic!
You were born on one of the many planets under the umbrella of the Mothellian Republic. In the Republic, every member is deeply versed in the art of trade and exchange, Material wealth a key component to the betterment of your species!
You serve in the Mothellian Military in order to bring profit to your family and clan, everyone contributes! You are a Veteran, You've been at this for a loooong time, act like it. You follow the orders of the Leader, though if they die, it falls on you to guide your men and make sure they make it home."}

//Mothellian Leader
/datum/job/mothellian/leader
	title = "Mothellian Leader"
	paygrade = "MTH5"
	supervisors = "yourself"
	display_order = JOB_DISPLAY_ORDER_MOFFS
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/mothellian/leader
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/mothellian/leader/one,
		/datum/outfit/job/mothellian/leader/two,
		/datum/outfit/job/mothellian/leader/three,
	)
	shadow_languages = list(/datum/language/xenocommon)

/datum/outfit/job/mothellian/leader
	name = "Mothellian Leader"
	jobtype = /datum/job/mothellian/leader

/datum/outfit/job/mothellian/leader
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/mothellian/veteran
	head = /obj/item/clothing/head/frelancer/mothellian/beret
	glasses = /obj/item/clothing/glasses/hud/health

/datum/outfit/job/mothellian/leader/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/mothellian/leader/one
	belt = /obj/item/storage/belt/grenade/b17
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian/unique/leader
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_pocket = /obj/item/storage/pouch/shotgun

/datum/outfit/job/mothellian/leader/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

///tx11
/datum/outfit/job/mothellian/leader/two
	belt = /obj/item/belt_harness/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian/unique/leader/two
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancertwo
	r_pocket = /obj/item/storage/pouch/grenade

/datum/outfit/job/mothellian/leader/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///tx55
/datum/outfit/job/mothellian/leader/three
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/mothellian/unique/leader/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_pocket = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/mothellian/leader/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)

/datum/job/mothellian/leader/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the glorious Mothellian Republic!
You were born on one of the many planets under the umbrella of the Mothellian Republic. In the Republic, every member is deeply versed in the art of trade and exchange, Material wealth a key component to the betterment of your species!
You serve in the Mothellian Military in order to bring profit to your family and clan, everyone contributes! You are the Leader, after years of hard work and service, you have been deemed vastly capable in leading men into battle and thus are in charge of your squad, take care of them and make sure they make it home. Unless told otherwise, it is the most important asset to protect."}

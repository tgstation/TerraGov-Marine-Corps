/datum/job/clf
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_CLF


//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	outfit = /datum/outfit/job/clf/standard


/datum/outfit/job/clf/standard
	name = "CLF Standard"
	jobtype = /datum/job/clf/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/weapon/gun/smg/uzi/clf
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/clf
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/strawhat
	suit_store = /obj/item/weapon/gun/smg/uzi/clf
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/zoom, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/zoom, SLOT_IN_BACKPACK)


// CLF Grenadier
/datum/job/clf/grenadier
	title = "CLF Grenadier"
	paygrade = "CLF3"
	outfit = /datum/outfit/job/clf/grenadier

/datum/outfit/job/clf/grenadier
	name = "CLF Grenadier"
	jobtype = /datum/job/clf/grenadier

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/grenade/wp
	ears = /obj/item/radio/headset/distress/dutch
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	w_uniform = /obj/item/clothing/under/colonist/clf
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/marine/harness/boomvest
	head = /obj/item/clothing/head/tgmcberet/green
	gloves = /obj/item/clothing/gloves/black
	suit_store = /obj/item/weapon/gun/smg/uzi/clf
	l_store = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/clf/grenadier/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)


//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/clf/medic


/datum/outfit/job/clf/medic
	name = "CLF Medic"
	jobtype = /datum/job/clf/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/combatLifesaver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/clf
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia/medic
	head = /obj/item/clothing/head/tgmcberet/bloodred
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/uzi/clf
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/russian_red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF4"
	outfit = /datum/outfit/job/clf/leader


/datum/outfit/job/clf/leader
	name = "CLF Leader"
	jobtype = /datum/job/clf/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/pistol/m4a3/officer
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia/leader
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/militia
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/launcher/rocket/sadar/wp
	r_store = /obj/item/storage/pouch/general/medium
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/sadar/wp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/sadar/wp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/sadar/wp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/sadar/wp, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/scout, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)

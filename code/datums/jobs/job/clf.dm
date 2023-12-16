/datum/job/clf
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_CLF


//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	outfit = /datum/outfit/job/clf/standard/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/standard/uzi,
		/datum/outfit/job/clf/standard/skorpion,
		/datum/outfit/job/clf/standard/mpi_km,
		/datum/outfit/job/clf/standard/shotgun,
		/datum/outfit/job/clf/standard/garand,
		/datum/outfit/job/clf/standard/fanatic,
		/datum/outfit/job/clf/standard/som_smg,
	)

//the base loadout for all clf standards
/datum/outfit/job/clf/standard
	name = "CLF Standard"
	jobtype = /datum/job/clf/standard

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/strawhat
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/uzi
	belt = /obj/item/storage/belt/knifepouch
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness


/datum/outfit/job/clf/standard/uzi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/skorpion
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

/datum/outfit/job/clf/standard/skorpion/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/mpi_km
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard


/datum/outfit/job/clf/standard/mpi_km/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/shotgun
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/standard

/datum/outfit/job/clf/standard/shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/fanatic
	head = /obj/item/clothing/head/headband/rambo
	wear_suit = /obj/item/clothing/suit/storage/marine/boomvest
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

/datum/outfit/job/clf/standard/fanatic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/som_smg
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/smg/som/basic


/datum/outfit/job/clf/standard/som_smg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/garand
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/garand


/datum/outfit/job/clf/standard/garand/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/clf/medic/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/medic/uzi,
		/datum/outfit/job/clf/medic/skorpion,
		/datum/outfit/job/clf/medic/paladin,
	)

//the base loadout for all clf medics
/datum/outfit/job/clf/medic
	name = "CLF Medic"
	jobtype = /datum/job/clf/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/distress/dutch
	head = /obj/item/clothing/head/tgmcberet/bloodred
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	l_store = /obj/item/storage/pouch/medical_injectors/medic
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/medic/uzi
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	r_store = /obj/item/storage/holster/flarepouch

/datum/outfit/job/clf/medic/uzi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/grenade_launcher/single_shot/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)

/datum/outfit/job/clf/medic/skorpion
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness
	r_store = /obj/item/storage/holster/flarepouch

/datum/outfit/job/clf/medic/skorpion/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/grenade_launcher/single_shot/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)

/datum/outfit/job/clf/medic/paladin
	suit_store = /obj/item/weapon/gun/shotgun/pump/cmb/mag_harness
	r_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/clf/medic/paladin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)

//CLF Specialist
/datum/job/clf/specialist
	title = "CLF Specialist"
	skills_type = /datum/skills/crafty
	outfit = /datum/outfit/job/clf/specialist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/specialist/dpm,
		/datum/outfit/job/clf/specialist/clf_heavyrifle,
		/datum/outfit/job/clf/specialist/clf_heavymachinegun,
	)

//The base loadout for all CLF Specialists
/datum/outfit/job/clf/specialist
	name = "CLF Specialist"
	jobtype = /datum/job/clf/specialist

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/helmet/marine
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid


/datum/outfit/job/clf/specialist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_R_POUCH)

/datum/outfit/job/clf/specialist/dpm
	suit_store = /obj/item/weapon/gun/rifle/dpm

/datum/outfit/job/clf/specialist/dpm/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/specialist/clf_heavyrifle
	suit_store = /obj/item/weapon/gun/clf_heavyrifle
	back = /obj/item/shotgunbox/clf_heavyrifle
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/job/clf/specialist/clf_heavyrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/specialist/clf_heavymachinegun
	suit_store = /obj/item/weapon/gun/icc_hmg
	belt = /obj/item/storage/belt/sparepouch
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/clf/specialist/clf_heavymachinegun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)


//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	skills_type = /datum/skills/sl/clf
	outfit = /datum/outfit/job/clf/leader/assault_rifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/leader/assault_rifle,
		/datum/outfit/job/clf/leader/mpi_km,
		/datum/outfit/job/clf/leader/som_rifle,
		/datum/outfit/job/clf/leader/upp_rifle,
		/datum/outfit/job/clf/leader/lmg_d,
	)

//the base loadout for all clf leaders
/datum/outfit/job/clf/leader
	name = "CLF Leader"
	jobtype = /datum/job/clf/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/militia
	glasses = /obj/item/clothing/glasses/hud/health
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_R_POUCH)

/datum/outfit/job/clf/leader/assault_rifle
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl

/datum/outfit/job/clf/leader/assault_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/mpi_km/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/som_rifle
	suit_store = /obj/item/weapon/gun/rifle/som/basic
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/som_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/upp_rifle
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer/standard

/datum/outfit/job/clf/leader/upp_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/lmg_d
	suit_store = /obj/item/weapon/gun/rifle/lmg_d/magharness
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/lmg_d/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

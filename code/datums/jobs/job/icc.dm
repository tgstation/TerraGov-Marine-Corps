/datum/job/icc
	job_category = JOB_CAT_MARINE
	access = ALL_ICC_ACCESS
	minimal_access = ALL_ICC_ACCESS
	skills_type = /datum/skills/craftier
	faction = FACTION_ICC
	minimap_icon = "icc"

/datum/job/icc/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are part of the colonial militia that formed shortly after Xenomorph invasion,
after ransacking the armories of the colonies owned by NTC, you took arms to fight against the Xenomorph assault.
Though soon they turned less lethal, danger still persists, especially those that are alone, namely survivors. Which is your job to protect now.
You are all colonists hired by Ninetails, Novamed, TRANSCo and Archercorp, depending on your initial assignments. That's why you are here in this cursed planet to begin with.
For that CM is closer to NTC and the corps than the rest, they gave your families or just you hope and funds to live comfortably back in earth and you a possibiity of a new begginning until it is all taken away. CM believes the other factions to be vultures on top of a stillborn colonization."}


//ICC Standard
/datum/job/icc/standard
	title = "CM Standard"
	paygrade = "CMH"
	multiple_outfits = TRUE
	outfit = /datum/outfit/job/icc/standard/mpi_km
	outfits = list(
		/datum/outfit/job/icc/standard/mpi_km,
		/datum/outfit/job/icc/standard/icc_pdw,
		/datum/outfit/job/icc/standard/icc_battlecarbine,
		/datum/outfit/job/icc/standard/icc_assaultcarbine,
	)

/datum/outfit/job/icc
	name = "CM Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/icc/webbing
	belt = /obj/item/storage/belt/marine/icc
	ears = /obj/item/radio/headset/distress/icc
	w_uniform = /obj/item/clothing/under/icc/webbing
	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc
	gloves = /obj/item/clothing/gloves/marine/icc
	head = /obj/item/clothing/head/helmet/marine/icc
	mask = /obj/item/clothing/mask/gas/icc

/datum/outfit/job/icc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcaridine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

// Basic standard equipment
/datum/outfit/job/icc/standard
	name = "CM Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc/insulated
	r_pocket = /obj/item/storage/pouch/pistol/icc
	l_pocket = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	back = /obj/item/storage/backpack/lightpack/icc


/datum/outfit/job/icc/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/icc_dpistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/icc_dpistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/icc_dpistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/icc_dpistol, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)

/datum/outfit/job/icc/standard/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard

/datum/outfit/job/icc/standard/mpi_km/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BELT)

/datum/outfit/job/icc/standard/icc_pdw
	suit_store = /obj/item/weapon/gun/smg/icc_pdw/standard

/datum/outfit/job/icc/standard/icc_pdw/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_pdw, SLOT_IN_BELT)

/datum/outfit/job/icc/standard/icc_battlecarbine
	suit_store = /obj/item/weapon/gun/rifle/icc_battlecarbine/standard

/datum/outfit/job/icc/standard/icc_battlecarbine/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_battlecarbine, SLOT_IN_BELT)

/datum/outfit/job/icc/standard/icc_assaultcarbine
	suit_store = /obj/item/weapon/gun/rifle/icc_assaultcarbine

/datum/outfit/job/icc/standard/icc_assaultcarbine/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_assaultcarbine, SLOT_IN_BELT)

//ICC Guard
/datum/job/icc/guard
	title = "CM Guard"
	paygrade = "CM3"
	outfit = /datum/outfit/job/icc/guard/coilgun
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/icc/guard/coilgun,
		/datum/outfit/job/icc/guard/icc_autoshotgun,
		/datum/outfit/job/icc/guard/icc_bagmg,
	)

/datum/outfit/job/icc/guard
	name = "CM Guard"
	jobtype = /datum/job/icc/guard

	shoes = /obj/item/clothing/shoes/marine/icc/guard/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard


/datum/outfit/job/icc/guard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_ACCESSORY)


/datum/outfit/job/icc/guard/coilgun
	suit_store = /obj/item/weapon/gun/launcher/rocket/icc
	back = /obj/item/weapon/gun/rifle/icc_coilgun
	l_pocket = /obj/item/storage/pouch/explosive/icc
	r_pocket = /obj/item/storage/pouch/explosive/icc

/datum/outfit/job/icc/guard/coilgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc/heat, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/icc/heat, SLOT_IN_L_POUCH)


	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)

/datum/outfit/job/icc/guard/icc_autoshotgun
	suit_store = /obj/item/weapon/gun/rifle/icc_coilgun
	back = /obj/item/weapon/gun/rifle/icc_autoshotgun/guard
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

/datum/outfit/job/icc/guard/icc_autoshotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun/frag, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun/frag, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_autoshotgun/frag, SLOT_IN_L_POUCH)

/datum/outfit/job/icc/guard/icc_bagmg
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard/heavy
	head = /obj/item/clothing/head/helmet/marine/icc/guard/heavy
	suit_store = /obj/item/weapon/gun/rifle/icc_coilgun
	back = /obj/item/storage/holster/icc_mg/full
	belt = /obj/item/ammo_magazine/icc_mg/belt
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

/datum/outfit/job/icc/guard/icc_bagmg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_R_POUCH)


//ICC Medic
/datum/job/icc/medic
	title = "CM Medic"
	paygrade = "CM2"
	skills_type = /datum/skills/combat_medic/crafty
	multiple_outfits = TRUE
	outfit = /datum/outfit/job/icc/medic/icc_machinepistol
	outfits = list(
		/datum/outfit/job/icc/medic/icc_machinepistol,
		/datum/outfit/job/icc/medic/icc_sharpshooter,
	)

/datum/outfit/job/icc/medic
	name = "CM Medic"
	jobtype = /datum/job/icc/medic

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc
	back = /obj/item/storage/backpack/lightpack/icc
	belt = /obj/item/storage/belt/lifesaver/icc/ert
	glasses = /obj/item/clothing/glasses/hud/health

/datum/outfit/job/icc/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcaridine, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/icc_dpistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/icc_dpistol, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

/datum/outfit/job/icc/medic/icc_machinepistol
	suit_store = /obj/item/weapon/gun/smg/icc_machinepistol/medic
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

/datum/outfit/job/icc/medic/icc_machinepistol/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol/hp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol/hp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol/hp, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/icc_machinepistol, SLOT_IN_BACKPACK)

/datum/outfit/job/icc/medic/icc_sharpshooter
	suit_store = /obj/item/weapon/gun/rifle/icc_sharpshooter/medic
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

/datum/outfit/job/icc/medic/icc_sharpshooter/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_sharpshooter, SLOT_IN_L_POUCH)

/datum/job/icc/leader
	title = "CM Leader"
	paygrade = "CM2"
	outfit = /datum/outfit/job/icc/leader/icc_heavyshotgun
	skills_type = /datum/skills/sl/icc
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/icc/leader/icc_heavyshotgun,
		/datum/outfit/job/icc/leader/icc_confrontationrifle,
	)


/datum/outfit/job/icc/leader
	name = "CM Leader"
	jobtype = /datum/job/icc/leader

	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	back = /obj/item/storage/backpack/lightpack/icc/guard
	l_pocket = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	r_pocket = /obj/item/storage/pouch/construction/icc/full


/datum/outfit/job/icc/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)

/datum/outfit/job/icc/leader/icc_heavyshotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/icc_heavyshotgun/icc_leader
	belt = /obj/item/storage/belt/shotgun/icc/mixed

/datum/outfit/job/icc/leader/icc_confrontationrifle
	belt = /obj/item/storage/belt/marine/icc
	suit_store = /obj/item/weapon/gun/rifle/icc_confrontationrifle/leader

/datum/outfit/job/icc/leader/icc_confrontationrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_confrontationrifle, SLOT_IN_BELT)

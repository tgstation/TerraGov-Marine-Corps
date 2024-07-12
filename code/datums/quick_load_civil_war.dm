/*!
 * Any loadout that is intended for civil war vendors.
 */

///When making new loadouts, remember to also add the typepath to the list under init_civil_war_loadouts() or else it won't show up in the vendor

/datum/outfit/quick/civil_war
	name = "Civil War base"
	desc = "Base for redcoat and bluecoat loadouts."
	require_job = FALSE

	shoes = /obj/item/clothing/shoes/marinechief
	head = /obj/item/clothing/head/redcoat
	belt = /obj/item/storage/belt/shotgun/martini/full
	back = /obj/item/weapon/gun/shotgun/double/martini
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/holster/flarepouch/full

/datum/outfit/quick/civil_war/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)

/datum/outfit/quick/civil_war/bluecoat
	name = "Bluecoat"
	jobtype = "Bluecoat"
	desc = "Tally Ho! Show those redcoats a piece of your independence!"

	w_uniform = /obj/item/clothing/under/marine/striped
	mask = /obj/item/clothing/mask/bandanna/delta

/datum/outfit/quick/civil_war/redcoat
	name = "Redcoat"
	jobtype = "Redcoat"
	desc = "God save the queen! Show those rebels the might of an empire!"

	w_uniform = /obj/item/clothing/under/redcoat
	mask = /obj/item/clothing/mask/bandanna/alpha

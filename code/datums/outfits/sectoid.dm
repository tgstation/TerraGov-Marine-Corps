/datum/outfit/job/sectoid
	name = "Sectoid Grunt"
	jobtype = /datum/job/sectoid

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/marine/sectoid
	head = /obj/item/clothing/head/helmet/sectoid
	ears = /obj/item/radio/headset/distress/sectoid
	w_uniform = /obj/item/clothing/under/sectoid
	glasses = /obj/item/clothing/glasses/night/sectoid
	shoes = /obj/item/clothing/shoes/sectoid
	wear_suit = /obj/item/clothing/suit/armor/sectoid
	gloves = /obj/item/clothing/gloves/sectoid
	r_pocket = /obj/item/stack/medical/heal_pack/gauze/sectoid
	l_pocket = /obj/item/explosive/grenade/sectoid
	back = /obj/item/weapon/gun/rifle/sectoid_rifle

	var/list/abilities = list(
		/datum/action/ability/activable/sectoid/mindmeld,
		/datum/action/ability/activable/sectoid/mindfray,
	)

/datum/outfit/job/sectoid/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.set_species("Sectoid")

	H.name = GLOB.namepool[/datum/namepool/sectoid].random_name(H)
	H.real_name = H.name

	for(var/ability in abilities)
		H.add_ability(ability)

/datum/outfit/job/sectoid/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BELT)

/datum/outfit/job/sectoid/psionic
	abilities = list(
		/datum/action/ability/activable/sectoid/mindmeld,
		/datum/action/ability/activable/sectoid/mindfray,
		/datum/action/ability/activable/sectoid/reknit_form,
		/datum/action/ability/activable/sectoid/stasis,
	)

/datum/outfit/job/sectoid/leader
	name = "Sectoid Leader"
	jobtype = /datum/job/sectoid/leader
	wear_suit = /obj/item/clothing/suit/armor/sectoid/shield
	abilities = list(
		/datum/action/ability/activable/sectoid/mindmeld/greater,
		/datum/action/ability/activable/sectoid/mindfray,
		/datum/action/ability/activable/sectoid/reknit_form/greater,
		/datum/action/ability/activable/sectoid/stasis,
		/datum/action/ability/activable/sectoid/fuse,
		/datum/action/ability/activable/psionic_interact,
		/datum/action/ability/activable/sectoid/reanimate,
	)

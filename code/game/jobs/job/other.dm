/datum/job/other
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/other/colonist
	title = "Colonist"
	comm_title = "CLN"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)
	equipment = TRUE

/datum/job/other/colonist/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()

	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(S, WEAR_FEET)
	H.equip_to_slot(new /obj/item/storage/pouch/survival/full(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/radio(H), WEAR_R_STORE)


/datum/job/other/passenger
	title = "Passenger"
	comm_title = "PAS"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)


/datum/job/other/pizza
	title = "Pizza Deliverer"
	idtype = /obj/item/card/id/centcom
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE

/datum/job/other/pizza/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/backpack/satchel/B = new /obj/item/storage/backpack/satchel(H)
	B.contents += new /obj/item/device/flashlight
	B.contents += new /obj/item/reagent_container/food/drinks/cans/thirteenloko
	B.contents += new /obj/item/pizzabox/vegetable
	B.contents += new /obj/item/pizzabox/mushroom
	B.contents += new /obj/item/pizzabox/meat
	B.contents += new /obj/item/ammo_magazine/pistol/holdout
	B.contents += new /obj/item/ammo_magazine/pistol/holdout


	H.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(H), WEAR_FEET)
	H.equip_to_slot_or_del(B, WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/device/radio(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(H), WEAR_L_STORE)

/datum/job/other/spatial_agent
	title = "Spatial Agent"
	idtype = /obj/item/card/id/centcom
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE
	skills_type = /datum/skills/spatial_agent

/datum/job/other/spatial_agent/generate_entry_conditions(mob/living/carbon/human/sa/H)
	. = ..()
	H.add_language("English")
	H.add_language("Sainja")
	H.add_language("Xenomorph")
	H.add_language("Hivemind")
	H.add_language("Russian")
	H.add_language("Tradeband")
	H.add_language("Gutter")

/datum/job/other/spatial_agent/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_commander/sa(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/sa(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/officer/chief/sa(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sa(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
/datum/job/other
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/other/colonist
	title = "Colonist"
	comm_title = "CLN"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)

/datum/job/other/colonist/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot(new /obj/item/weapon/combat_knife(H), WEAR_L_STORE)
	H.equip_to_slot(new /obj/item/device/flashlight(H), WEAR_R_STORE)

/datum/job/other/passenger
	title = "Passenger"
	comm_title = "PAS"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)

/datum/job/other/pizza
	title = "Pizza Deliverer"
	comm_title = "PAS"
	idtype = /obj/item/card/id/centcom
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE

/datum/job/other/pizza/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/device/radio(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/vegetable(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/mushroom(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/meat(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/thirteenloko(H.back), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(H.back), WEAR_IN_BACK)
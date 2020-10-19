//halo//

/obj/item/clothing/suit/covenant/


//	var/list/species_allowed = list("Sangheili","Unggoy", "Kigyar")

/obj/item/clothing/suit/covenant/sangheili
	name = "sangheili combat harness"
	icon = 'icons/obj/clothing/covenant/sangheili.dmi'
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/bible,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun,
		/obj/item/storage/belt/knifepouch)
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50) 		//identical to standard URF as of 10/16/20
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	siemens_coefficient = 0.9
	w_class = WEIGHT_CLASS_NORMAL
	supporting_limbs = NONE
	blood_overlay_type = "suit"
	shield_state = "shield-blue"
	sprite_sheets = list("Sangheili" = 'icons/mob/species/sangheili/suit.dmi')
//	species_allowed = "Sangheili"

/obj/item/clothing/suit/covenant/sangheili/minor
	name = "Minor Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Minors."
	icon_state = "minor_chest"
	item_state = "minor_chest"

/obj/item/clothing/suit/covenant/sangheili/ranger
	name = "Ranger Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Rangers."
	icon_state = "ranger_chest"
	item_state = "ranger_chest"

/obj/item/clothing/suit/covenant/sangheili/officer
	name = "Officer Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Officers."
	icon_state = "officer_chest"
	item_state = "officer_chest"

/obj/item/clothing/suit/covenant/sangheili/specops
	name = "Special Ops Sangheili Combat Harness"
	desc = "A harness designed specifically for Special Operations Sangheili."
	icon_state = "specops_chest"
	item_state = "specops_chest"

/obj/item/clothing/suit/covenant/sangheili/ultra
	name = "Ultra Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Ultras."
	icon_state = "ultra_chest"
	item_state = "ultra_chest"

/obj/item/clothing/suit/covenant/sangheili/general
	name = "General Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Generals."
	icon_state = "general_chest"
	item_state = "general_chest"

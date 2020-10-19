//halo//

/obj/item/clothing/suit/covenant/
	sprite_sheet_id = 2 //Sets which sheet to use. Defaults to 0

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

/obj/item/clothing/suit/covenant/sangheili/minor
	name = "Minor Sangheili Combat Harness"
	desc = "A harness designed specifically for Sangheili Minors."
	icon_state = "minor_chest"
	item_state = "minor_chest"







/* Broken, but good reference for things we may need later
/obj/item/clothing/suit/storage/covenant/sangheili
	icon = 'icons/obj/clothing/covenant/sangheili.dmi'
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50) 		//identical to standard URF as of 10/16/20
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	slowdown = SLOWDOWN_ARMOR_MEDIUM
//	var/locate_cooldown = 0 //Cooldown for SL locator
//	var/list/armor_overlays //Might come in handy for shields?
//	actions_types = list(/datum/action/item_action/toggle)
//	flags_armor_features = ARMOR_LAMP_OVERLAY
	w_class = WEIGHT_CLASS_HUGE
	time_to_unequip = 2 SECONDS
	time_to_equip = 2 SECONDS
//	pockets = /obj/item/storage/internal/suit/covenant


/obj/item/storage/internal/suit/covenant //Check in on this when weapons are in.
	bypass_w_limit = list(
		/obj/item/cell/lasgun
	)
	max_storage_space = 3 //Depending on cell size and loadout options, this may need to be changed.
*/
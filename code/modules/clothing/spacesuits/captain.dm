//Captain's Spacesuit
/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	permeability_coefficient = 0.01
	armor = list("melee" = 65, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 25, "acid" = 25)

//Captain's space suit This is not the proper path but I don't currently know enough about how this all works to mess with it.
/obj/item/clothing/suit/armor/captain
	name = "Captain's armor"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	item_state = "capspacesuit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/tank/emergency_oxygen, /obj/item/flashlight,/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/weapon/baton,/obj/item/restraints/handcuffs)
	slowdown = 1.5
	armor = list("melee" = 65, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 25, "acid" = 25)
	flags_inventory = NOPRESSUREDMAGE
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7

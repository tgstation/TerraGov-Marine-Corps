/**
	Modular armor and helmets that has no slots other than mods should go here, as modular.dm is getting very bloated.
*/

/obj/item/clothing/suit/modular/pas11x
	name = "\improper PAS-X pattern flak vest"
	desc = "A common Personal Armor Systems flak vest, made with some attachment points and very light padding for armor. Use it to toggle the built-in flashlight."
	soft_armor = list("melee" = 5, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	icon_state = "pas11"
	item_state = "pas11"

	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,

		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/integrated,
	)

	icon_state_variants = list(
		"green",
		"black",
		"brown",
		"white",
	)

	current_variant = "black"

/obj/item/clothing/suit/modular/pas11x/update_icon()
	. = ..()
	if(item_state == icon_state)
		return
	item_state = icon_state

// Helmets //

/obj/item/clothing/head/modular/marine/m10x
	name = "\improper M10X pattern marine helmet"
	desc = "A standard M10 Pattern Helmet with attach points. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/mob/modular/m10.dmi'
	icon_state = "helmet_icon"
	icon_override = null
	item_state = "helmet"
	item_state_worn = TRUE
	item_state_slots = null
	item_icons = list(
		slot_head_str = 'icons/mob/modular/m10.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	greyscale_colors = null
	greyscale_config = null
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/antenna,

		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	visorless_offset_x = 0
	visorless_offset_y = 0

	icon_state_variants = list(
		"green",
		"black",
		"brown",
		"white",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/marine/m10x/standard

/obj/item/clothing/head/modular/marine/m10x/tech
	name = "\improper M10X technician helmet"


/obj/item/clothing/head/modular/marine/m10x/corpsman
	name = "\improper M10X corpsman helmet"

/obj/item/clothing/head/modular/marine/m10x/heavy
	name = "\improper M10XE pattern marine helmet"
	desc = "A standard M10XE Pattern Helmet. This is a modified version of the M10X helmet, offering an enclosed visor apparatus."
	icon_state = "heavyhelmet_icon"
	item_state = "heavyhelmet"

/obj/item/clothing/head/modular/marine/m10x/leader
	name = "\improper M11X pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)

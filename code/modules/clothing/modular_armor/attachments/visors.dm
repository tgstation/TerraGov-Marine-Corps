/**
 *  Visors
 *  Visors are slightly different than the other armor types. They allow emissives. If visor_emissive_on is TRUE then it will be applying an emissve to it.
 * 	If allow_emissive is TRUE, Right clicking the Parent item will toggle the emissive.
*/

/obj/item/armor_module/armor/visor
	name = "standard visor"
	slot = ATTACHMENT_SLOT_VISOR
	greyscale_config = /datum/greyscale_config/modular_helmet_visor
	///Initial hex color we use when applying the visor color
	greyscale_colors = VISOR_PALETTE_GOLD
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	colorable_colors = list(
		"Default" = list(
			"Gold" = VISOR_PALETTE_GOLD,
			"Silver" = VISOR_PALETTE_SILVER,
			"Black" = VISOR_PALETTE_BLACK,
		),
		"Red" = list(
			"Red" = VISOR_PALETTE_RED,
		),
		"Green" = list(
			"Green" = VISOR_PALETTE_GREEN,
		),
		"Purple" = list(
			"Purple" = VISOR_PALETTE_PURPLE,
			"Magenta" = VISOR_PALETTE_MAGENTA,
		),
		"Blue" = list(
			"Blue" = VISOR_PALETTE_BLUE,
			"Ice Blue" = VISOR_PALETTE_ICE,
			"Sky Blue" = VISOR_PALETTE_SKY_BLUE,
		),
		"Yellow" = list(
			"Honey" = VISOR_PALETTE_HONEY,
			"Metallic Bronze" = VISOR_PALETTE_METALLIC_BRONZE,
		),
		"Orange" = list(
			"Orange" = VISOR_PALETTE_ORANGE,
		),
		"Pink" = list(
			"Salmon" = VISOR_PALETTE_SALMON,
			"Pearl Pink" = VISOR_PALETTE_PEARL_PINK,
		),
	)
	secondary_color = TRUE
	flags_item_map_variant = NONE
	///whether this helmet should be using its emissive overlay or not
	var/visor_emissive_on = TRUE
	///Whether or not the helmet is allowed to turn its emissive on or off.
	var/allow_emissive = TRUE

/obj/item/armor_module/armor/visor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, .proc/toggle_emissive)
	if(visor_emissive_on)
		parent.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	update_icon()

/obj/item/armor_module/armor/visor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE)
	parent.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	update_icon()
	return ..()

///Toggles the visors emmisiveness if allowed.
/obj/item/armor_module/armor/visor/proc/toggle_emissive(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!greyscale_config || !allow_emissive|| (parent && user.get_inactive_held_item() != parent) || (!parent && user.get_inactive_held_item() != src))
		return
	visor_emissive_on = !visor_emissive_on
	if(visor_emissive_on)
		parent?.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	else
		parent?.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	to_chat(user, span_notice("You turn [ visor_emissive_on ? "on" : "off" ] \the [src]'s internal lighting."))
	update_icon()
	parent.update_icon()
	return COMPONENT_NO_ATTACK_HAND

/obj/item/armor_module/armor/visor/extra_examine(datum/source, mob/user)
	. = ..()
	if(!istype(greyscale_config, /datum/greyscale_config/modular_helmet_visor))
		return
	to_chat(user, "Right click the helmet to toggle the visor internal lighting.")

/obj/item/armor_module/armor/visor/marine
	name = "\improper Jaeger Pattern Infantry visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Infantry class of helmet."
	icon_state = "infantry_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor

/obj/item/armor_module/armor/visor/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/skirmisher

/obj/item/armor_module/armor/visor/marine/scout
	name = "\improper Jaeger Pattern Scout visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/scout

/obj/item/armor_module/armor/visor/marine/assault
	name = "\improper Jaeger Pattern Assault visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/assault

/obj/item/armor_module/armor/visor/marine/eva
	name = "\improper Jaeger Pattern EVA visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/eva

/obj/item/armor_module/armor/visor/marine/eva/skull
	name = "\improper Jaeger Pattern EVA Skull visor"
	icon_state = "eva_skull_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/eva/skull

/obj/item/armor_module/armor/visor/marine/eod
	name = "\improper Jaeger Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for EOD class of helmet."
	icon_state = "eod_infantry_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/eod

/obj/item/armor_module/armor/visor/marine/helljumper
	name = "\improper Jaeger Pattern Helljumper visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for Helljumper class of helmet."
	icon_state = "helljumper_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/helljumper

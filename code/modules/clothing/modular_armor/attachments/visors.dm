/**
 *  Visors
 *  Visors are slightly different than the other armor types. They allow emissives. If visor_emissive_on is TRUE then it will be applying an emissve to it.
 * 	If allow_emissive is TRUE, Right clicking the Parent item will toggle the emissive.
*/

/obj/item/armor_module/greyscale/visor
	name = "standard visor"
	icon = 'icons/mob/modular/jaeger_helmets.dmi'
	slot = ATTACHMENT_SLOT_VISOR
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	greyscale_config = /datum/greyscale_config/visors
	greyscale_colors = COLOR_VERY_LIGHT_GRAY
	secondary_color = TRUE
	///whether this helmet should be using its emissive overlay or not
	var/visor_emissive_on = TRUE
	///Whether or not the helmet is allowed to turn its emissive on or off.
	var/allow_emissive = TRUE

/obj/item/armor_module/greyscale/visor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, .proc/toggle_emissive)
	if(visor_emissive_on)
		parent.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, greyscale_config, greyscale_colors)
	update_icon()

/obj/item/armor_module/greyscale/visor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE)
	parent.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, greyscale_config, greyscale_colors)
	update_icon()
	return ..()

///Toggles the visors emmisiveness if allowed.
/obj/item/armor_module/greyscale/visor/proc/toggle_emissive(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!allow_emissive|| (parent && user.get_inactive_held_item() != parent) || (!parent && user.get_inactive_held_item() != src))
		return
	visor_emissive_on = !visor_emissive_on
	if(visor_emissive_on)
		parent?.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, greyscale_config, greyscale_colors)
	else
		parent?.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, greyscale_config, greyscale_colors)
	to_chat(user, span_notice("You turn [ visor_emissive_on ? "on" : "off" ] \the [src]'s internal lighting."))
	update_icon()
	parent.update_icon()
	return COMPONENT_NO_ATTACK_HAND

/obj/item/armor_module/greyscale/visor/extra_examine(datum/source, mob/user)
	. = ..()
	if(!allow_emissive)
		return
	to_chat(user, "Right click the helmet to toggle the visor internal lighting.")

/obj/item/armor_module/greyscale/visor/marine
	name = "\improper Jaeger Pattern Infantry visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Infantry class of helmet."
	icon_state = "infantry_visor"

/obj/item/armor_module/greyscale/visor/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor"

/obj/item/armor_module/greyscale/visor/marine/scout
	name = "\improper Jaeger Pattern Scout visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor"

/obj/item/armor_module/greyscale/visor/marine/helljumper
	name = "\improper Jaeger Pattern hell Jumper visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Hell Jumper class of helmet."
	icon_state = "helljumper_visor"

/obj/item/armor_module/greyscale/visor/marine/eva
	name = "\improper Jaeger Pattern EVA visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor"

/obj/item/armor_module/greyscale/visor/marine/eva/skull
	name = "\improper Jaeger Pattern EVA Skull visor"
	icon_state = "eva_skull_visor"

/obj/item/armor_module/greyscale/visor/marine/assault
	name = "\improper Jaeger Pattern Assault visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor"

/obj/item/armor_module/greyscale/visor/marine/eod
	name = "\improper Jaeger Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EOD class of helmet."
	icon_state = "eod_visor"

/obj/item/armor_module/greyscale/visor/marine/gungnir
	name = "\improper Jaeger Pattern Gungnir visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Gungnir class of helmet."
	icon_state = "gungnir_visor"

/obj/item/armor_module/greyscale/visor/robot
	name = "\improper XN-1 upper armor plating visor"
	desc = "The visor attachment of the XN-1 upper armor plating."
	icon = 'icons/mob/modular/robot_helmets.dmi'
	icon_state = "robot_medium_visor"
	greyscale_config = /datum/greyscale_config/visors/robot

/obj/item/armor_module/greyscale/visor/robot/light
	name = "\improper XN-1-L upper armor plating visor"
	desc = "The visor attachment of the XN-1-L upper armor plating."
	icon_state = "robot_light_visor"

/obj/item/armor_module/greyscale/visor/robot/heavy
	name = "\improper XN-1-H upper armor plating visor"
	desc = "The visor attachment of the XN-1-H upper armor plating."
	icon_state = "robot_heavy_visor"

//old jaeger
/obj/item/armor_module/greyscale/visor/marine/old
	name = "\improper Jaeger Pattern Infantry visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Infantry class of helmet."
	greyscale_config = /datum/greyscale_config/visors/old
	icon_state = "infantry_visor"

/obj/item/armor_module/greyscale/visor/marine/old/skirmisher
	name = "\improper Jaeger Pattern Skirmisher visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor"

/obj/item/armor_module/greyscale/visor/marine/old/scout
	name = "\improper Jaeger Pattern Scout visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor"

/obj/item/armor_module/greyscale/visor/marine/old/eva
	name = "\improper Jaeger Pattern EVA visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor"

/obj/item/armor_module/greyscale/visor/marine/old/eva/skull
	name = "\improper Jaeger Pattern EVA Skull visor"
	icon_state = "eva_skull_visor"

/obj/item/armor_module/greyscale/visor/marine/old/assault
	name = "\improper Jaeger Pattern Assault visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor"

/obj/item/armor_module/greyscale/visor/marine/old/eod
	name = "\improper Jaeger Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EOD class of helmet."
	icon_state = "eod_visor"

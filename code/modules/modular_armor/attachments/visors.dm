/**
 *  Visors
 *  Visors are slightly different than the other armor types. They allow emissives. If visor_emissive_on is TRUE then it will be applying an emissve to it.
 * 	If allow_emissive is TRUE, Right clicking the Parent item will toggle the emissive.
*/

/obj/item/armor_module/armor/visor
	name = "standard visor"
	slot = ATTACHMENT_SLOT_VISOR
	///Initial hex color we use when applying the visor color
	greyscale_colors = "#f7fb58"
	flags_attach_features = ATTACH_SAME_ICON
	///whether this helmet should be using its emissive overlay or not
	var/visor_emissive_on = TRUE
	///Whether or not the helmet is allowed to turn its emissive on or off.
	var/allow_emissive = TRUE


/obj/item/armor_module/armor/visor/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "Click the visor with paint to color the visor.")

/obj/item/armor_module/armor/visor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY_ALTERNATE, .proc/handle_color)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/extra_examine)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, .proc/toggle_emissive)
	if(visor_emissive_on)
		parent.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	update_icon()

/obj/item/armor_module/armor/visor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, list(COMSIG_CLICK_RIGHT, COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY_ALTERNATE))
	parent.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	update_icon()
	return ..()

///Colors the visor when the parent is right clicked with facepaint.
/obj/item/armor_module/armor/visor/proc/handle_color(datum/source, obj/I, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, /atom/proc/attackby, I, user)
	return COMPONENT_NO_AFTERATTACK

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

///Relays the extra controls to the user when the parent is examined.
/obj/item/armor_module/armor/visor/proc/extra_examine(datum/source, mob/user)
	to_chat(user, "Right click the helmet with paint to color the visor internal lighting.")
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
	greyscale_config = /datum/greyscale_config/modular_helmet_visor_skull

/obj/item/armor_module/armor/visor/marine/eod
	name = "\improper Jaeger Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for EOD class of helmet."
	icon_state = "eod_infantry_visor"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/eod

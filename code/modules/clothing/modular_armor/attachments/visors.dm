/**
 *  Visors
 *  Visors are slightly different than the other armor types. They allow emissives. If visor_emissive_on is TRUE then it will be applying an emissve to it.
 * 	If allow_emissive is TRUE, Right clicking the Parent item will toggle the emissive.
*/

/obj/item/armor_module/armor/visor
	name = "standard visor"
	icon_state = "visor"
	slot = ATTACHMENT_SLOT_VISOR
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	greyscale_config = /datum/greyscale_config/visors
	greyscale_colors = VISOR_PALETTE_GOLD
	colorable_colors = VISOR_PALETTES_LIST
	secondary_color = TRUE
	flags_item_map_variant = NONE

	///whether this helmet should be using its emissive overlay or not
	var/visor_emissive_on = TRUE
	///Whether or not the helmet is allowed to turn its emissive on or off.
	var/allow_emissive = TRUE

/obj/item/armor_module/armor/visor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(toggle_emissive))
	if(visor_emissive_on)
		parent.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, icon)
	update_icon()

/obj/item/armor_module/armor/visor/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE)
	parent.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, icon)
	update_icon()
	return ..()

///Toggles the visors emmisiveness if allowed.
/obj/item/armor_module/armor/visor/proc/toggle_emissive(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!allow_emissive|| (parent && user.get_inactive_held_item() != parent) || (!parent && user.get_inactive_held_item() != src))
		return
	visor_emissive_on = !visor_emissive_on
	if(visor_emissive_on)
		parent?.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, icon)
	else
		parent?.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, icon_state, icon)
	to_chat(user, span_notice("You turn [ visor_emissive_on ? "on" : "off" ] \the [src]'s internal lighting."))
	update_icon()
	parent.update_icon()
	return COMPONENT_NO_ATTACK_HAND

/obj/item/armor_module/armor/visor/extra_examine(datum/source, mob/user)
	. = ..()
	if(!allow_emissive)
		return
	to_chat(user, "Right click the helmet to toggle the visor internal lighting.")

/obj/item/armor_module/armor/visor/marine
	name = "\improper Jaeger Pattern Infantry visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Infantry class of helmet."
	icon_state = "infantry_visor"

/obj/item/armor_module/armor/visor/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor"

/obj/item/armor_module/armor/visor/marine/scout
	name = "\improper Jaeger Pattern Scout visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor"

/obj/item/armor_module/armor/visor/marine/helljumper
	name = "\improper Jaeger Pattern hell Jumper visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Hell Jumper class of helmet."
	icon_state = "helljumper_visor"

/obj/item/armor_module/armor/visor/marine/ranger
	name = "\improper Jaeger Pattern Ranger visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Ranger class of helmet."
	icon_state = "ranger_visor"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/traditional
	name = "\improper Jaeger Pattern Traditional Ranger visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Traditional Ranger class of helmet."
	icon_state = "traditional_visor"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/trooper
	name = "\improper Jaeger Pattern Trooper visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Trooper class of helmet."
	icon_state = "trooper_visor"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/kabuto
	name = "\improper Style Pattern Kabuto visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Kabuto class of helmet."
	icon_state = "kabuto_visor"

/obj/item/armor_module/armor/visor/marine/hotaru
	name = "\improper Style Pattern Hotaru visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Hotaru class of helmet."
	icon_state = "hotaru_visor"

/obj/item/armor_module/armor/visor/marine/dashe
	name = "\improper Style Pattern Dashe visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Dashe class of helmet."
	icon_state = "dashe_visor"

/obj/item/armor_module/armor/visor/marine/eva
	name = "\improper Jaeger Pattern EVA visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor"

/obj/item/armor_module/armor/visor/marine/eva/skull
	name = "\improper Jaeger Pattern EVA Skull visor"
	icon_state = "eva_visor"
	attachments_by_slot = list(ATTACHMENT_SLOT_CAPE_HIGHLIGHT)
	attachments_allowed = list(/obj/item/armor_module/armor/visor_glyph)
	starting_attachments = list(/obj/item/armor_module/armor/visor_glyph)

/obj/item/armor_module/armor/visor/marine/assault
	name = "\improper Jaeger Pattern Assault visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor"

/obj/item/armor_module/armor/visor/marine/eod
	name = "\improper Jaeger Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EOD class of helmet."
	icon_state = "eod_visor"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/gungnir
	name = "\improper Jaeger Pattern Gungnir visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Gungnir class of helmet."
	icon_state = "gugnir"
	greyscale_config = /datum/greyscale_config/visors/greyscale
	colorable_allowed = COLOR_WHEEL_ALLOWED
	greyscale_colors = LIGHT_COLOR_GREEN

//Robots
/obj/item/armor_module/armor/visor/marine/robot
	name = "\improper XN-1 upper armor plating visor"
	desc = "The visor attachment of the XN-1 upper armor plating."
	icon_state = "r_medium"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/robot/light
	name = "\improper XN-1-L upper armor plating visor"
	desc = "The visor attachment of the XN-1-L upper armor plating."
	icon_state = "r_light"

/obj/item/armor_module/armor/visor/marine/robot/heavy
	name = "\improper XN-1-H upper armor plating visor"
	desc = "The visor attachment of the XN-1-H upper armor plating."
	icon_state = "r_heavy"


//Xenonaut
/obj/item/armor_module/armor/visor/marine/xenonaut
	name = "\improper Xenonaut heavy visor"
	desc = "The visor attachment of the Xenonaut heavy helmet"
	icon_state = "xenonaut"


//old jaeger
/obj/item/armor_module/armor/visor/marine/old
	name = "\improper Jaeger Pattern Infantry visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Infantry class of helmet."
	icon_state = "infantry_visor_old"

/obj/item/armor_module/armor/visor/marine/old/skirmisher
	name = "\improper Jaeger Pattern Skirmisher visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor_old"

/obj/item/armor_module/armor/visor/marine/old/scout
	name = "\improper Jaeger Pattern Scout visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor_old"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/old/eva
	name = "\improper Jaeger Pattern EVA visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor_old"

/obj/item/armor_module/armor/visor/marine/old/eva/skull
	name = "\improper Jaeger Pattern EVA Skull visor"
	icon_state = "eva_visor_old"
	attachments_by_slot = list(ATTACHMENT_SLOT_CAPE_HIGHLIGHT)
	attachments_allowed = list(/obj/item/armor_module/armor/visor_glyph/old)
	starting_attachments = list(/obj/item/armor_module/armor/visor_glyph/old)

/obj/item/armor_module/armor/visor/marine/old/assault
	name = "\improper Jaeger Pattern Assault visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor_old"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/armor_module/armor/visor/marine/old/eod
	name = "\improper Pattern EOD visor"
	desc = "The visor attachment of the Jaeger modular helmets. This one is designed for the EOD class of helmet."
	icon_state = "eod_visor_old"
	colorable_allowed = COLOR_WHEEL_ALLOWED|PRESET_COLORS_ALLOWED

//Hardsuit Helmet Visors
/obj/item/armor_module/armor/visor/marine/fourvisor
	name = "\improper FleckTex Mark V helmet visor"
	desc = "The visor attachment of the FleckTex WY-01 series modular helmets. This one is designed for the Mark V Breacher class of helmet."
	icon_state = "fourvisor_visor"

/obj/item/armor_module/armor/visor/marine/foureyevisor
	name = "\improper FleckTex Mark III helmet visor"
	desc = "The visor attachment of the FleckTex WY-01 series modular helmets. This one is designed for the Mark III Marauder class of helmet."
	icon_state = "foureye_visor"

/obj/item/armor_module/armor/visor/marine/markonevisor
	name = "\improper FleckTex Mark I helmet visor"
	desc = "The visor attachment of the FleckTex WY-01 series modular helmets. This one is designed for the Mark I Raider class of helmet."
	icon_state = "markone_visor"


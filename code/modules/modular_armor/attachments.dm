
/obj/item/armor_module
	name = "armor module"
	desc = "A dis-figured armor module, in its prime this would've been a key item in your modular armor... now its just trash."
	icon = 'icons/mob/modular/modular_armor.dmi'

	var/obj/item/clothing/suit/modular/parent

	///Slot the attachment is able to occupy.
	var/slot
	///Proc typepath that is called when this is attached to something.
	var/on_attach = .proc/on_attach
	///Proc typepath that is called when this is detached from something.
	var/on_detach = .proc/on_detach
	///Proc typepath that is called when this is item is being attached to something. Returns TRUE if it can attach.
	var/can_attach = .proc/can_attach
	///Pixel shift for the item overlay on the X axis.
	var/pixel_shift_x = 0
	///Pixel shift for the item overlay on the Y axis.
	var/pixel_shift_y = 0
	///Bitfield flags of various features.
	var/flags_attach_features = ATTACH_REMOVABLE
	///Time it takes to attach.
	var/attach_delay = 2 SECONDS
	///Time it takes to detach.
	var/detach_delay = 2 SECONDS

	///Light modifier for attachment to an armor piece
	var/light_mod = 0
	slowdown = 0

/obj/item/armor_module/Initialize()
	. = ..()
	AddElement(/datum/element/attachment, slot, icon, on_attach, on_detach, null, can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay)

/// Called before a module is attached.
/obj/item/armor_module/proc/can_attach(obj/item/attaching_to, mob/user)
	if(!istype(attaching_to, /obj/item/clothing/suit/modular) && !istype(attaching_to, /obj/item/clothing/head/modular))
		return FALSE
	return TRUE

/// Called when the module is added to the armor.
/obj/item/armor_module/proc/on_attach(obj/item/attaching_to, mob/user)
	SEND_SIGNAL(attaching_to, COMSIG_ARMOR_MODULE_ATTACHING, user, src)
	parent = attaching_to
	parent.set_light_range(parent.light_range + light_mod)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown

/// Called when the module is removed from the armor.
/obj/item/armor_module/proc/on_detach(obj/item/detaching_from, mob/user)
	SEND_SIGNAL(detaching_from, COMSIG_ARMOR_MODULE_DETACHED, user, src)
	parent.set_light_range(parent.light_range - light_mod)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	parent = null

/obj/item/armor_module/ui_action_click(mob/user, datum/action/item_action/action)
	activate(user)

///Called on ui_action_click. Used for activating the module.
/obj/item/armor_module/proc/activate(mob/living/user)
	return

/**
 *      Chestplates
 *
 */

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// The additional armor provided by equipping this piece.
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

	greyscale_config = /datum/greyscale_config/modularchest_infantry
	greyscale_colors = "#444732"

	///optional assoc list of colors we can color this armor
	var/list/colorable_colors
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON

/obj/item/armor_module/armor/Initialize()
	. = ..()
	item_state = initial(icon_state) + "_a"
	update_icon()

///Will force faction colors on this armor module
/obj/item/armor_module/armor/proc/limit_colorable_colors(faction)
	switch(faction)
		if(FACTION_TERRAGOV)
			set_greyscale_colors("#2A4FB7")
			colorable_colors = list(
				"blue" = "#2A4FB7",
				"aqua" = "#2098A0",
				"purple" = "#871F8F",
			)
		if(FACTION_TERRAGOV_REBEL)
			set_greyscale_colors("#CC2C32")
			colorable_colors = list(
				"red" = "#CC2C32",
				"orange" = "#BC4D25",
				"yellow" = "#B7B21F",
			)

/obj/item/armor_module/armor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return

	var/new_color
	if(colorable_colors)
		new_color = colorable_colors[tgui_input_list(user, "Pick a color", "Pick color", colorable_colors)]
	else
		new_color = input(user, "Pick a color", "Pick color") as null|color

	if(!new_color)
		return

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return

	set_greyscale_colors(new_color)
	paint.uses--
	update_icon()

/obj/item/armor_module/armor/chest
	icon_state = "infantry_chest"
	greyscale_config = /datum/greyscale_config/modularchest_infantry
	slot = ATTACHMENT_SLOT_CHESTPLATE

/obj/item/armor_module/armor/chest/marine
	name = "\improper Jaeger Pattern Medium Infantry chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_chest"
	soft_armor = list("melee" = 15, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 15)
	slowdown = 0.3
	greyscale_config = /datum/greyscale_config/modularchest_infantry

/obj/item/armor_module/armor/chest/marine/skirmisher
	name = "\improper Jaeger Pattern Light Skirmisher chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_chest"
	soft_armor = list("melee" = 10, "bullet" = 15, "laser" = 15, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modularchest_skirmisher

/obj/item/armor_module/armor/chest/marine/skirmisher/scout
	name = "\improper Jaeger Pattern Light Scout chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_chest"
	greyscale_config = /datum/greyscale_config/modularchest_scout

/obj/item/armor_module/armor/chest/marine/assault
	name = "\improper Jaeger Pattern Heavy Assault chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_chest"
	soft_armor = list("melee" = 20, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 20)
	slowdown = 0.5
	greyscale_config = /datum/greyscale_config/modularchest_assault

/obj/item/armor_module/armor/chest/marine/eva //Medium armor alt look
	name = "\improper Jaeger Pattern Medium EVA chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_chest"
	greyscale_config = /datum/greyscale_config/modularchest_eva

/obj/item/armor_module/armor/chest/marine/assault/eod //Heavy armor alt look
	name = "\improper Jaeger Pattern Heavy EOD chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_chest"
	greyscale_config = /datum/greyscale_config/modularchest_eod


/*
 * Leg Pieces
*/

/obj/item/armor_module/armor/legs
	icon = null
	icon_state = "infantry_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_infantry
	slot = ATTACHMENT_SLOT_KNEE

/obj/item/armor_module/armor/legs/marine
	name = "\improper Jaeger Pattern Infantry leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_legs"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modularlegs_infantry

/obj/item/armor_module/armor/legs/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_skirmisher

/obj/item/armor_module/armor/legs/marine/scout
	name = "\improper Jaeger Pattern Scout leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_scout

/obj/item/armor_module/armor/legs/marine/assault
	name = "\improper Jaeger Pattern Assault leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_assault

/obj/item/armor_module/armor/legs/marine/eva
	name = "\improper Jaeger Pattern EVA leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_eva

/obj/item/armor_module/armor/legs/marine/eod
	name = "\improper Jaeger Pattern EOD leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_legs"
	greyscale_config = /datum/greyscale_config/modularlegs_eva


/** 
 * Arms pieces 
*/

/obj/item/armor_module/armor/arms
	icon = null
	icon_state = "infantry_arms"
	greyscale_config = /datum/greyscale_config/modulararms_infantry
	slot = ATTACHMENT_SLOT_SHOULDER

/obj/item/armor_module/armor/arms/marine
	name = "\improper Jaeger Pattern Infantry arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modulararms_infantry

/obj/item/armor_module/armor/arms/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_arms"
	greyscale_config = /datum/greyscale_config/modulararms_skirmisher

/obj/item/armor_module/armor/arms/marine/scout
	name = "\improper Jaeger Pattern Scout arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_arms"
	greyscale_config = /datum/greyscale_config/modulararms_scout

/obj/item/armor_module/armor/arms/marine/assault
	name = "\improper Jaeger Pattern Assault arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_arms"
	greyscale_config = /datum/greyscale_config/modulararms_assault

/obj/item/armor_module/armor/arms/marine/eva
	name = "\improper Jaeger Pattern EVA arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_arms"
	greyscale_config = /datum/greyscale_config/modulararms_eva

/obj/item/armor_module/armor/arms/marine/eod
	name = "\improper Jaeger Pattern EOD arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_arms"
	greyscale_config = /datum/greyscale_config/modulararms_eod


/*
	Visors
*/

/obj/item/armor_module/armor/visor
	name = "standard visor"
	slot = ATTACHMENT_SLOT_VISOR
	///Initial hex color we use when applying the visor color
	greyscale_colors = "#f7fb58"
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_REMOVABLE
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
	RegisterSignal(parent, COMSIG_CLICK_RIGHT, .proc/toggle_emissive)
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
	INVOKE_ASYNC(src, /obj/item/armor_module/armor/attackby, I, user)
	return COMPONENT_NO_AFTERATTACK

///Toggles the visors emmisiveness if allowed.
/obj/item/armor_module/armor/visor/proc/toggle_emissive(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!greyscale_config || !allow_emissive)
		return
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(living_user.get_active_held_item() != parent && living_user.get_inactive_held_item() != parent)
		return
	visor_emissive_on = !visor_emissive_on
	if(visor_emissive_on)
		parent?.AddElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	else
		parent?.RemoveElement(/datum/element/special_clothing_overlay/modular_helmet_visor, HEAD_LAYER, greyscale_config, greyscale_colors)
	to_chat(user, span_notice("You turn [ visor_emissive_on ? "on" : "off" ] \the [src]'s internal lighting."))
	parent.update_icon()
	update_icon()
	return COMSIG_MOB_CLICK_CANCELED

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

/obj/item/armor_module/armor/visor/metal
	name = "standard metal visor"
	greyscale_colors = "#4c4c4d"
	visor_emissive_on = FALSE
	allow_emissive = FALSE

/obj/item/armor_module/armor/visor/metal/marine
	name = "\improper Jaeger Pattern Infantry faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the Infantry class of helmet."
	icon_state = "infantry_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal

/obj/item/armor_module/armor/visor/metal/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the Skirmisher class of helmet."
	icon_state = "skirmisher_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal/skirmisher

/obj/item/armor_module/armor/visor/metal/marine/scout
	name = "\improper Jaeger Pattern Scout faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the Scout class of helmet."
	icon_state = "scout_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal/scout

/obj/item/armor_module/armor/visor/metal/marine/assault
	name = "\improper Jaeger Pattern Assault faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the Assault class of helmet."
	icon_state = "assault_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal/assault

/obj/item/armor_module/armor/visor/metal/marine/eva
	name = "\improper Jaeger Pattern EVA faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the EVA class of helmet."
	icon_state = "eva_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal/eva

/obj/item/armor_module/armor/visor/metal/marine/eva/skull
	name = "\improper Jaeger Pattern EVA Skull faceplate"
	icon_state = "eva_skull_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor_skull/metal

/obj/item/armor_module/armor/visor/metal/marine/eod
	name = "\improper Jaeger Pattern EOD faceplate"
	desc = "An alternate visor to the standard. This one is far cheaper and just as effective as the finest metals are far cheaper than the finest glass alloys of the same strength. This one is designed for the EOD class of helmet."
	icon_state = "eod_infantry_visor_metal"
	greyscale_config = /datum/greyscale_config/modular_helmet_visor/metal/eod


/*
*   Modules
*/
/obj/item/armor_module/module
	name = "broken armor module"
	desc = "You better be debugging."

/** Shoulder lamp strength module */
/obj/item/armor_module/module/better_shoulder_lamp
	name = "\improper Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeleton's mounted flashlight."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_lamp"
	item_state = "mod_lamp_a"
	slowdown = 0
	light_mod = 4 /// The boost to armor shoulder light
	slot = ATTACHMENT_SLOT_MODULE

/** Mini autodoc module */
/obj/item/armor_module/module/valkyrie_autodoc
	name = "\improper Valkyrie Automedical Armor System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Has a variety of chemicals it can inject, as well as automatically securing the bones and body of the wearer, to minimize the impact of broken bones or mangled limbs in the field. Will definitely impact mobility."
	icon_state = "mod_autodoc"
	item_state = "mod_autodoc_a"
	slowdown = 0.25
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/valkyrie_autodoc/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/list/tricord = list(/datum/reagent/medicine/tricordrazine)
	var/list/tramadol = list(/datum/reagent/medicine/tramadol)
	/// This will do nothing without the autodoc update
	var/list/supported_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT)
	parent.AddComponent(/datum/component/suit_autodoc, 4 MINUTES, tricord, tricord, tricord, tricord, tramadol, 0.5)
	parent.AddElement(/datum/element/limb_support, supported_limbs)


/obj/item/armor_module/valkyrie_autodoc/on_detach(obj/item/detaching_from, mob/user)
	var/datum/component/suit_autodoc/autodoc = parent.GetComponent(/datum/component/suit_autodoc)
	autodoc.RemoveComponent()
	var/list/supported_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT)
	parent.RemoveElement(/datum/element/limb_support, supported_limbs)
	return ..()


/** Fire poof module */
/obj/item/armor_module/module/fire_proof
	name = "\improper Surt Pyrotechnical Insulation System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniacs' first stop to survival. Will impact mobility somewhat."
	icon_state = "mod_fire"
	item_state = "mod_fire_a"
	hard_armor = list("fire" = 200)
	slowdown = 0.4
	/// How much the suit light is modified by
	light_mod = -2
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/fire_proof/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/module/fire_proof/on_detach(obj/item/detaching_from, mob/user)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


/** Extra armor module */
/obj/item/armor_module/module/tyr_extra_armor
	name = "\improper Mark 2 Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armor"
	item_state = "mod_armor_a"
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/tyr_extra_armor/mark1
	name = "\improper Mark 1 Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. This older version has worse protection. Will definitely impact mobility."
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.4

/obj/item/armor_module/module/tyr_head
	name = "Tyr Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to most damaging hazards, like bullets and melee."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "tyr_head"
	item_state = "tyr_head_a"
	soft_armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/** Environment protecttion module */
/obj/item/armor_module/module/mimir_environment_protection
	name = "\improper Mark 2 Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This newer version provides a large amount of resistance to acid. Best paired with the Mimir Environmental Helmet System and a gas mask. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	slowdown = 0.2
	var/siemens_coefficient_mod = -0.9
	var/permeability_coefficient_mod = -1
	var/gas_transfer_coefficient_mod = -1
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/mimir_environment_protection/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.siemens_coefficient += siemens_coefficient_mod
	parent.permeability_coefficient += permeability_coefficient_mod
	parent.gas_transfer_coefficient += siemens_coefficient_mod

/obj/item/armor_module/module/mimir_environment_protection/on_detach(obj/item/detaching_from, mob/user)
	parent.siemens_coefficient -= siemens_coefficient_mod
	parent.permeability_coefficient -= permeability_coefficient_mod
	parent.gas_transfer_coefficient -= siemens_coefficient_mod
	return ..()

// The mark 1 version, made to protect you from just gas.
/obj/item/armor_module/module/mimir_environment_protection/mark1
	name = "\improper Mark 1 Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This older version provides a small amount of protection to acid. Best paired with the Mimir Environmental Helmet System. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list("bio" = 15, "rad" = 10, "acid" = 15)
	slowdown = 0.2 //So it isn't literally 100% better than running stock jaeger.

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet
	name = "Mark 2 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This newer model provides a large amount of protection to acid. Best paired with the Mimir Environmental Resistance System. Will impact mobility when attached."
	icon_state = "mimir_head"
	item_state = "mimir_head_a"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	slowdown = 0
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1 //gas protection
	name = "Mark 1 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This older version provides a small amount of protection to acid. Best paired with the Mimir Environmental Resistance System and a gas mask."
	soft_armor = list("bio" = 15, "acid" = 15)

//Explosive defense armor
/obj/item/armor_module/module/hlin_explosive_armor
	name = "Hlin Explosive Compensation Module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Uses a complex set of armor plating and compensation to lessen the effect of explosions, at the cost of making the user slower."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_boomimmune"
	item_state = "mod_boomimmune_a"
	soft_armor = list("bomb" = 40)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE

/** Extra armor module */
/obj/item/armor_module/module/ballistic_armor
	name = "\improper Ballistic Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns against bullets and nothing else. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff"
	item_state = "mod_ff_a"
	soft_armor = list("melee" = 0, "bullet" = 40, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/chemsystem
	name = "Vali chemical enhancement module"
	desc = "A module that enhances the strength of reagents in the body. Requires a special substance, gathered from xenomorph lifeforms, to function.\nThis substance needs to be gathered using an applicable wepon or tool."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_chemsystem"
	item_state = "mod_chemsystem_a"
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/chemsystem/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/chem_booster)

/obj/item/armor_module/module/chemsystem/on_detach(obj/item/detaching_from, mob/user)
	var/datum/component/chem_booster/chemsystem = parent.GetComponent(/datum/component/chem_booster)
	chemsystem.RemoveComponent()
	return ..()

/*
*   Helmet
*/

/obj/item/armor_module/module/welding
	name = "Welding Helmet Module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this module can be flipped up or down to function as a welding mask."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	item_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	active = FALSE
	var/eye_protection_mod = 2

/obj/item/armor_module/module/welding/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/clothing_tint, TINT_5, active)

/obj/item/armor_module/module/welding/on_detach(obj/item/detaching_from, mob/user)
	parent.GetComponent(/datum/component/clothing_tint)
	var/datum/component/clothing_tint/tints = parent?.GetComponent(/datum/component/clothing_tint)
	tints.RemoveComponent()
	return ..()

/obj/item/armor_module/module/welding/activate(mob/living/user)
	if(active)
		DISABLE_BITFIELD(parent.flags_inventory, COVEREYES)
		DISABLE_BITFIELD(parent.flags_inv_hide, HIDEEYES)
		DISABLE_BITFIELD(parent.flags_armor_protection, EYES)
		parent.eye_protection -= eye_protection_mod // reset to the users base eye
	else
		ENABLE_BITFIELD(parent.flags_inventory, COVEREYES)
		ENABLE_BITFIELD(parent.flags_inv_hide, HIDEEYES)
		ENABLE_BITFIELD(parent.flags_armor_protection, EYES)
		parent.eye_protection += eye_protection_mod

	active = !active
	SEND_SIGNAL(parent, COMSIG_ITEM_TOGGLE_ACTION, user)
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = initial(icon_state) + "[active ? "_active" : ""]"
	item_state = icon_state + "_a"
	parent.update_overlays()
	user.update_inv_head()


/obj/item/armor_module/module/binoculars
	name = "Binocular Helmet Module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, can be flipped down to view into the distance."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "binocular_head"
	item_state = "binocular_head_a"
	active = FALSE
	flags_item = DOES_NOT_NEED_HANDS
	zoom_tile_offset = 11
	zoom_viewsize = 12
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/obj/item/armor_module/module/binoculars/activate(mob/living/user)
	zoom(user)

	active = !active
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = initial(icon_state) + "[active ? "_active" : ""]"
	item_state = icon_state + "_a"
	parent.update_icon()
	user.update_inv_head()
	return COMSIG_MOB_CLICK_CANCELED

/obj/item/armor_module/module/binoculars/zoom_item_turnoff(datum/source, mob/living/user)
	if(isliving(source))
		activate(source)
	else
		activate(user)

/obj/item/armor_module/module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this module is able to provide quick readuts of the users coordinates."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	item_state = "antenna_head_a"
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/obj/item/armor_module/module/antenna/activate(mob/living/user)
	var/turf/location = get_turf(src)
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
		QDEL_NULL(beacon_datum)
		user.show_message(span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console"), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
		return
	if(!is_ground_level(user.z))
		to_chat(user, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_METAL)
		to_chat(user, span_warning("You have to be outside or under a glass ceiling to activate this."))
		return
	beacon_datum = new /datum/supply_beacon(user.name, user.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_PARENT_QDELETING, .proc/clean_beacon_datum)
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))

/// Signal handler to nullify beacon datum
/obj/item/armor_module/module/antenna/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null


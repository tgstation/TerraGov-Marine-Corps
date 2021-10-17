/**
 ** Modules
 *	These include the helmet and regular armor modules. Basically these are the subtypes of any armor 'system'.
 */
/obj/item/armor_module/module
	name = "broken armor module"
	desc = "You better be debugging."

/**
 * Shoulder lamp strength module
 */
/obj/item/armor_module/module/better_shoulder_lamp
	name = "\improper Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeleton's mounted flashlight."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_lamp"
	item_state = "mod_lamp_a"
	slowdown = 0
	light_mod = 4 /// The boost to armor shoulder light
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_lamp_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_lamp_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_lamp_xn")

/**
 * Mini autodoc module
 */
/obj/item/armor_module/module/valkyrie_autodoc
	name = "\improper Valkyrie Automedical Armor System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Has a variety of chemicals it can inject, as well as automatically securing the bones and body of the wearer, to minimize the impact of broken bones or mangled limbs in the field. Will definitely impact mobility."
	icon_state = "mod_autodoc"
	item_state = "mod_autodoc_a"
	slowdown = 0.25
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_autodoc_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_autodoc_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_autodoc_xn")
	var/static/list/supported_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT)

/obj/item/armor_module/module/valkyrie_autodoc/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/list/tricord = list(/datum/reagent/medicine/tricordrazine)
	var/list/tramadol = list(/datum/reagent/medicine/tramadol)
	/// This will do nothing without the autodoc update
	parent.AddComponent(/datum/component/suit_autodoc, 4 MINUTES, tricord, tricord, tricord, tricord, tramadol, 0.5)
	parent.AddElement(/datum/element/limb_support, supported_limbs)


/obj/item/armor_module/module/valkyrie_autodoc/on_detach(obj/item/detaching_from, mob/user)
	qdel(parent.GetComponent(/datum/component/suit_autodoc))
	parent.RemoveElement(/datum/element/limb_support, supported_limbs)
	return ..()


/**
 * Fire poof module
*/
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
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_fire_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_fire_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_fire_xn")

/obj/item/armor_module/module/fire_proof/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/module/fire_proof/on_detach(obj/item/detaching_from, mob/user)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


/**
 * Extra armor module
*/
/obj/item/armor_module/module/tyr_extra_armor
	name = "\improper Mark 2 Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armor"
	item_state = "mod_armor_a"
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_armor_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_armor_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_armor_xn")

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
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "tyr_head_xn")

/**
 * Environment protecttion module
*/
/obj/item/armor_module/module/mimir_environment_protection
	name = "\improper Mark 2 Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This newer version provides a large amount of resistance to acid. Best paired with the Mimir Environmental Helmet System and a gas mask. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_biohazard_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_biohazard_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_biohazard_xn")
	///siemens coefficient mod for gas protection.
	var/siemens_coefficient_mod = -0.9
	///permeability coefficient mod for gas protection.
	var/permeability_coefficient_mod = -1
	///gas transfer coefficient mod for gas protection.
	var/gas_transfer_coefficient_mod = -1

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
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "mimir_head_xn")

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
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_boomimmune_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_boomimmune_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_boomimmune_xn")

/**
 * Extra armor module
*/
/obj/item/armor_module/module/ballistic_armor
	name = "\improper Ballistic Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns against bullets and nothing else. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff"
	item_state = "mod_ff_a"
	soft_armor = list("melee" = 0, "bullet" = 40, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_ff_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_ff_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_ff_xn")

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

/**
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
	///Mod for extra eye protection when activated.
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
	parent.update_icon()
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
	if(active)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, .proc/zoom_item_turnoff)
		return
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)

/obj/item/armor_module/module/binoculars/zoom_item_turnoff(datum/source, mob/living/user)
	if(isliving(source))
		activate(source)
	else
		activate(user)
	return COMSIG_MOB_CLICK_CANCELED

/obj/item/armor_module/module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this module is able to provide quick readuts of the users coordinates."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	item_state = "antenna_head_a"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

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


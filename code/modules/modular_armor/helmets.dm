
/** Helmet attachments */
/obj/item/helmet_module/welding
	name = "Welding Helmet Module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this module can be flipped up or down to function as a welding mask."
	icon_state = "welding_head_obj"
	item_state = "welding_head_inactive"
	module_type = ARMOR_MODULE_TOGGLE

	active = FALSE
	var/eye_protection_mod = 2

/obj/item/helmet_module/welding/do_attach(mob/living/user, obj/item/clothing/head/modular/parent)
	. = ..()
	parent.AddComponent(/datum/component/clothing_tint, TINT_5, active)

/obj/item/helmet_module/welding/do_detach(mob/living/user, obj/item/clothing/head/modular/parent)
	parent.GetComponent(/datum/component/clothing_tint)
	var/datum/component/clothing_tint/tints = parent?.GetComponent(/datum/component/clothing_tint)
	tints.RemoveComponent()
	return ..()

/obj/item/helmet_module/welding/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
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
	item_state = "welding_head_[active ? "" : "in"]active"
	parent.update_overlays()
	user.update_inv_head()


/obj/item/helmet_module/attachable/mimir_environment_protection
	name = "Mark 2 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This newer model provides a large amount of protection to acid. Best paired with the Mimir Environmental Resistance System. Will impact mobility when attached."
	icon_state = "mimir_head_obj"
	item_state = "mimir_head"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	module_type = ARMOR_MODULE_TOGGLE
	var/siemens_coefficient_mod = -0.9
	var/permeability_coefficient_mod = -1
	var/gas_transfer_coefficient_mod = -1

/obj/item/helmet_module/attachable/mimir_environment_protection/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.siemens_coefficient += siemens_coefficient_mod
	parent.permeability_coefficient += permeability_coefficient_mod
	parent.gas_transfer_coefficient += siemens_coefficient_mod

/obj/item/helmet_module/attachable/mimir_environment_protection/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.siemens_coefficient -= siemens_coefficient_mod
	parent.permeability_coefficient -= permeability_coefficient_mod
	parent.gas_transfer_coefficient -= siemens_coefficient_mod
	return ..()

/obj/item/helmet_module/attachable/mimir_environment_protection/mark1 //gas protection
	name = "Mark 1 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This older version provides a small amount of protection to acid. Best paired with the Mimir Environmental Resistance System and a gas mask."
	icon_state = "mimir_head_obj"
	item_state = "mimir_head"
	soft_armor = list("bio" = 15, "acid" = 15)


/obj/item/helmet_module/binoculars
	name = "Binocular Helmet Module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, can be flipped down to view into the distance."
	icon_state = "binocular_head_obj"
	item_state = "binocular_head_inactive"
	module_type = ARMOR_MODULE_TOGGLE
	active = FALSE
	flags_item = DOES_NOT_NEED_HANDS

/obj/item/helmet_module/binoculars/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
	if(!active && !zoom)
		zoom(user, 11, 12)
	else
		if(zoom)
			zoom(user)

	active = !active
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	item_state = "binocular_head_[active ? "" : "in"]active"
	parent.update_overlays()
	user.update_inv_head()
	return COMSIG_MOB_CLICK_CANCELED

/obj/item/helmet_module/binoculars/zoom_item_turnoff(datum/source, mob/living/user)
	toggle_module(user)

/obj/item/helmet_module/binoculars/onzoom(mob/living/user)
	RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_MOUSEDOWN), .proc/toggle_module)//No shooting while zoomed
	RegisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/zoom_item_turnoff)

/obj/item/helmet_module/binoculars/onunzoom(mob/living/user)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_MOUSEDOWN))
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/helmet_module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this module is able to provide quick readuts of the users coordinates."
	icon_state = "antenna_head_obj"
	item_state = "antenna_head"
	module_type = ARMOR_MODULE_TOGGLE
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/helmet_module/antenna/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
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
/obj/item/helmet_module/antenna/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

/obj/item/helmet_module/attachable/tyr_head
	name = "Tyr Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to most damaging hazards, like bullets and melee."
	icon_state = "tyr_head_obj"
	item_state = "tyr_head"
	soft_armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

/obj/item/helmet_module/attachable/tyr_head/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)

/obj/item/helmet_module/attachable/tyr_head/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	return ..()

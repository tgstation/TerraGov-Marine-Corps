
/** Helmet attachments */
/obj/item/helmet_module/welding
	name = "Welding Helmet Module"
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
		parent.eye_protection += eye_protection_mod // reset to the users base eye
	else
		ENABLE_BITFIELD(parent.flags_inventory, COVEREYES)
		ENABLE_BITFIELD(parent.flags_inv_hide, HIDEEYES)
		ENABLE_BITFIELD(parent.flags_armor_protection, EYES)
		parent.eye_protection -= eye_protection_mod

	active = !active
	to_chat(user, "<span class='notice'>You toggle \the [src]. [active ? "enabling" : "disabling"] it.</span>")
	item_state = "welding_head_[active ? "" : "in"]active"
	parent.update_overlays()


/obj/item/helmet_module/attachable/mimir_environment_protection
	name = "Mimir Environmental Helmet System"
	desc = "Designed for mounting on a Jaeger Helmet. When attached, this system provides substantial resistance to environmental hazards, such as gases, acidic elements, and radiological exposure. Best paired with the Mimir Environmental Resistance System. Will impact mobility when attached."
	icon_state = "mimir_head_obj"
	item_state = "mimir_head"
	soft_armor = list("bio" = 20, "rad" = 50, "acid" = 20)
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

/obj/item/helmet_module/binoculars
	name = "Binocular Helmet Module"
	icon_state = "binocular_head_obj"
	item_state = "binocular_head_inactive"
	module_type = ARMOR_MODULE_TOGGLE
	active = FALSE
	flags_item = DOES_NOT_NEED_HANDS

/obj/item/helmet_module/binoculars/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
	if(!active && !zoom)
		RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CLIENT_MOUSEDOWN), .proc/toggle_module) //No shooting while zoomed
		zoom(user, 11, 12)
	else
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CLIENT_MOUSEDOWN))
		if(zoom)
			zoom(user)

	active = !active
	to_chat(user, "<span class='notice'>You toggle \the [src]. [active ? "enabling" : "disabling"] it.</span>")
	item_state = "binocular_head_[active ? "" : "in"]active"
	parent.update_overlays()

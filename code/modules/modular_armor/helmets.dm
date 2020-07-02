
/** Helmet attachments */
/obj/item/helmet_module/welding
	name = "Welding Helmet Module"
	icon_state = "welding_head_obj"
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

/obj/item/helmet_module/binoculars
	name = "Binocular Helmet Module"
	icon_state = "binocular_head_obj"
	item_state = "binocular_head"
	module_type = ARMOR_MODULE_TOGGLE
	active = FALSE

/obj/item/helmet_module/binoculars/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
	if(!active && !zoom)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/toggle_module)
		RegisterSignal(user, COMSIG_CLIENT_MOUSEDOWN, .proc/toggle_module)//No shooting while zoomed
		zoom(user, 11, 12)
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		if(zoom)
			zoom(user)

	active = !active
	to_chat(user, "<span class='notice'>You toggle \the [src]. [active ? "enabling" : "disabling"] it.</span>")

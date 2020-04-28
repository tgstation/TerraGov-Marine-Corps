
/** Helmet attachments */
/obj/item/helmet_module/welding
	name = "welding thing"
	icon_state = "mod_welding"
	module_type = ARMOR_MODULE_TOGGLE

	active = FALSE
	var/eye_protection = 2

/obj/item/helmet_module/welding/do_attach(mob/living/user, obj/item/clothing/head/modular/parent)
	. = ..()
	parent?.AddComponent(/datum/component/clothing_tint, TINT_5, active)

/obj/item/helmet_module/welding/do_detach(mob/living/user, obj/item/clothing/head/modular/parent)
	parent?.GetComponent(/datum/component/clothing_tint)
	var/datum/component/clothing_tint/tints = parent?.GetComponent(/datum/component/clothing_tint)
	tints.RemoveComponent()
	return ..()

/obj/item/helmet_module/welding/toggle_module(mob/living/user, obj/item/clothing/head/modular/parent)
	if(active)
		DISABLE_BITFIELD(parent.flags_inventory, COVEREYES)
		DISABLE_BITFIELD(parent.flags_inv_hide, HIDEEYES)
		DISABLE_BITFIELD(parent.flags_armor_protection, EYES)
		eye_protection = 0
	else
		ENABLE_BITFIELD(parent.flags_inventory, COVEREYES)
		ENABLE_BITFIELD(parent.flags_inv_hide, HIDEEYES)
		ENABLE_BITFIELD(parent.flags_armor_protection, EYES)
		eye_protection = initial(eye_protection)

	active = !active
	to_chat(user, "<span class='notice'>You toggle \the [src]. [active ? "enabling" : "disabling"] it.</span>")

/**
	Modular armor attachments

	These are utilty attachments that equip into module slots on modular armor
*/
/obj/item/armor_module/attachable/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(LAZYLEN(parent.installed_modules) >= parent.max_modules)
		if(!silent)
			to_chat(user,"<span class='warning'>There are too many pieces installed already.</span>")
		return FALSE
	if(LAZYFIND(parent.installed_modules, src))
		if(!silent)
			to_chat(user,"<span class='warning'>That module is already installed.</span>")
		return FALSE

/obj/item/armor_module/attachable/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	LAZYADD(parent.installed_modules, src)


/obj/item/armor_module/attachable/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	LAZYREMOVE(parent.installed_modules, src)
	return ..()


/** Shoulder lamp strength module */
/obj/item/armor_module/attachable/better_shoulder_lamp
	name = "\improper Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeleton's mounted flashlight. Doesn’t really slow you down."
	icon_state = "mod_lamp_icon"
	item_state = "mod_lamp"
	var/power_boost = 4 /// The boost to armor shoulder light

/obj/item/armor_module/attachable/better_shoulder_lamp/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.light_strength += power_boost

/obj/item/armor_module/attachable/better_shoulder_lamp/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.light_strength -= power_boost
	return ..()


/** Mini autodoc module */
/obj/item/armor_module/attachable/valkyrie_autodoc
	name = "\improper Valkyrie Automedical Armor System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Has a variety of chemicals it can inject, as well as automatically securing the bones and body of the wearer, to minimize the impact of broken bones or mangled limbs in the field. Will definitely impact mobility."
	icon_state = "mod_autodoc_icon"
	item_state = "mod_autodoc"
	slowdown = 0.25

/obj/item/armor_module/attachable/valkyrie_autodoc/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	var/list/tricord = list(/datum/reagent/medicine/tricordrazine)
	var/list/tramadol = list(/datum/reagent/medicine/tramadol)
	/// This will do nothing without the autodoc update
	var/list/supported_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT)
	parent.AddComponent(/datum/component/suit_autodoc, 4 MINUTES, tricord, tricord, tricord, tricord, tramadol, 0.5)
	parent.AddElement(/datum/element/limb_support, supported_limbs)


/obj/item/armor_module/attachable/valkyrie_autodoc/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	var/datum/component/suit_autodoc/autodoc = parent.GetComponent(/datum/component/suit_autodoc)
	autodoc.RemoveComponent()
	var/list/supported_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT)
	parent.RemoveElement(/datum/element/limb_support, supported_limbs)
	return ..()


/** Fire poof module */
/obj/item/armor_module/attachable/fire_proof
	name = "\improper Surt Pyrotechnical Insulation System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniacs' first stop to survival. Will impact mobility somewhat."
	icon_state = "mod_fire_icon"
	item_state = "mod_fire"
	hard_armor = list("fire" = 200)
	slowdown = 0.4
	/// How much the suit light is modified by
	var/light_mod = -2

/obj/item/armor_module/attachable/fire_proof/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.light_strength += light_mod
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/attachable/fire_proof/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.light_strength -= light_mod
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


/** Extra armor module */
/obj/item/armor_module/attachable/tyr_extra_armor
	name = "\improper Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. Will definitely impact mobility."
	icon_state = "mod_armor_icon"
	item_state = "mod_armor"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.3

/obj/item/armor_module/attachable/tyr_extra_armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/tyr_extra_armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	return ..()


/** Environment protecttion module */
/obj/item/armor_module/attachable/mimir_environment_protection
	name = "\improper Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, acidic elements, and radiological exposure. Best paired with the Mimir Environmental Helmet System. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon_state = "mod_biohazard_icon"
	item_state = "mod_biohazard"
	soft_armor = list("bio" = 20, "rad" = 50, "acid" = 20)
	slowdown = 0.2
	module_type = ARMOR_MODULE_TOGGLE
	var/siemens_coefficient_mod = -0.9
	var/permeability_coefficient_mod = -1
	var/gas_transfer_coefficient_mod = -1

/obj/item/armor_module/attachable/mimir_environment_protection/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.siemens_coefficient += siemens_coefficient_mod
	parent.permeability_coefficient += permeability_coefficient_mod
	parent.gas_transfer_coefficient += siemens_coefficient_mod
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/mimir_environment_protection/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.siemens_coefficient -= siemens_coefficient_mod
	parent.permeability_coefficient -= permeability_coefficient_mod
	parent.gas_transfer_coefficient -= siemens_coefficient_mod
	parent.slowdown -= slowdown
	return ..()

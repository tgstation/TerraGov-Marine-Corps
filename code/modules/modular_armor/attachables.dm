/**
	Modular armor attachments

	These are utilty attachments that equip into module slots on modular armor

*/

/obj/item/armor_module/attachable
	icon = 'icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/attachable/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(LAZYLEN(parent.installed_modules) >= parent.max_modules)
		if(!silent)
			to_chat(user,span_warning("There are too many pieces installed already."))
		return FALSE
	if(LAZYFIND(parent.installed_modules, src))
		if(!silent)
			to_chat(user,span_warning("That module is already installed."))
		return FALSE

/obj/item/armor_module/attachable/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	LAZYADD(parent.installed_modules, src)


/obj/item/armor_module/attachable/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	LAZYREMOVE(parent.installed_modules, src)
	return ..()


/** Shoulder lamp strength module */
/obj/item/armor_module/attachable/better_shoulder_lamp
	name = "\improper Mark 2 Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeleton's mounted flashlight. Slows you down minorly."
	icon_state = "mod_lamp_icon"
	item_state = "mod_lamp"
	slowdown = 0
	var/power_boost = 5 /// The boost to armor shoulder light

/obj/item/armor_module/attachable/better_shoulder_lamp/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.set_light_range(parent.light_range + power_boost)

/obj/item/armor_module/attachable/better_shoulder_lamp/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.set_light_range(parent.light_range - power_boost)
	return ..()

/obj/item/armor_module/attachable/better_shoulder_lamp/mark1
	name = "\improper Mark 1 Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeleton's mounted flashlight. Slows you down minorly."
	power_boost = 4 /// The boost to armor shoulder light
	slowdown = 0.1

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
	parent.set_light_range(parent.light_range + light_mod)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/attachable/fire_proof/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.set_light_range(parent.light_range - light_mod)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


/** Extra armor module */
/obj/item/armor_module/attachable/tyr_extra_armor
	name = "\improper Mark 2 Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. Will definitely impact mobility."
	icon_state = "mod_armor_icon"
	item_state = "mod_armor"
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	slowdown = 0.3

/obj/item/armor_module/attachable/tyr_extra_armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/tyr_extra_armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	return ..()

/obj/item/armor_module/attachable/tyr_extra_armor/mark1
	name = "\improper Mark 1 Tyr Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns. This older version has worse protection. Will definitely impact mobility."
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.4


/** Environment protecttion module */
/obj/item/armor_module/attachable/mimir_environment_protection
	name = "\improper Mark 2 Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This newer version provides a large amount of resistance to acid. Best paired with the Mimir Environmental Helmet System and a gas mask. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon_state = "mod_biohazard_icon"
	item_state = "mod_biohazard"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
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

// The mark 1 version, made to protect you from just gas.
/obj/item/armor_module/attachable/mimir_environment_protection/mark1
	name = "\improper Mark 1 Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, biological and radiological exposure. This older version provides a small amount of protection to acid. Best paired with the Mimir Environmental Helmet System. Will impact mobility." // Add the toggable thing to the description when you are done, okay? ~XS300
	icon_state = "mod_biohazard_icon"
	item_state = "mod_biohazard"
	soft_armor = list("bio" = 15, "rad" = 10, "acid" = 15)
	slowdown = 0.2 //So it isn't literally 100% better than running stock jaeger.
	module_type = ARMOR_MODULE_TOGGLE

/obj/item/armor_module/attachable/hlin_explosive_armor
	name = "Hlin Explosive Compensation Module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Uses a complex set of armor plating and compensation to lessen the effect of explosions, at the cost of making the user slower."
	icon_state = "mod_boomimmune_icon"
	item_state = "mod_boomimmune"
	soft_armor = list("bomb" = 40)
	slowdown = 0.2

/obj/item/armor_module/attachable/hlin_explosive_armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/hlin_explosive_armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	return ..()

/** Extra armor module */
/obj/item/armor_module/attachable/ballistic_armor
	name = "\improper Ballistic Armor Reinforcement"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeleton conventional armor patterns against bullets and nothing else. Will definitely impact mobility."
	icon_state = "mod_ff_icon"
	item_state = "mod_ff"
	soft_armor = list("melee" = 0, "bullet" = 40, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	slowdown = 0.2

/obj/item/armor_module/attachable/ballistic_armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/ballistic_armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.slowdown -= slowdown
	return ..()

/obj/item/armor_module/attachable/chemsystem
	name = "Vali chemical enhancement module"
	desc = "A module that enhances the strength of reagents in the body. Requires a special substance, gathered from xenomorph lifeforms, to function.\nThis substance needs to be gathered using an applicable wepon or tool."
	icon_state = "mod_chemsystem_icon"
	item_state = "mod_chemsystem"

/obj/item/armor_module/attachable/chemsystem/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.AddComponent(/datum/component/chem_booster)

/obj/item/armor_module/attachable/chemsystem/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	var/datum/component/chem_booster/chemsystem = parent.GetComponent(/datum/component/chem_booster)
	chemsystem.RemoveComponent()
	return ..()

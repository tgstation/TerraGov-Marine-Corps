/**
	Modular armor attachments

	These are utilty attachments that equip into module slots on modular armor
*/

/** Shoulder lamp stength module */
/obj/item/armor_module/attachable/better_shoulder_lamp
	name = "Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeletons mounted flashlight. Doesn’t really slow you down."
	icon_state = "mod_lamp_icon"
	item_state = "mod_lamp"
	var/power_boost = 4 /// The boost to armor shoulder light

/obj/item/armor_module/attachable/better_shoulder_lamp/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.light_strength += power_boost
	parent.update_overlays()

/obj/item/armor_module/attachable/better_shoulder_lamp/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.light_strength -= power_boost
	return ..()


/** Shoulder lamp stength module */
/obj/item/armor_module/attachable/valkyrie_autodoc
	name = "Valkyrie Automedical Armor System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Has a variety of chemicals it can inject, as well as automatically securing the bones and body of the wearer, to minimise the impact of broken bones or mangled limbs in the field. Will definitely impact mobility."
	icon_state = "mod_autodoc_icon"
	item_state = "mod_autodoc"

/obj/item/armor_module/attachable/valkyrie_autodoc/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	var/list/tricord = list(/datum/reagent/medicine/tricordrazine)
	var/list/tramadol = list(/datum/reagent/medicine/tramadol)
	parent?.AddComponent(/datum/component/suit_autodoc, 2.5 MINUTES, tricord, tricord, tricord, tricord, tramadol, 0.5)
	parent.update_overlays()


/obj/item/armor_module/attachable/valkyrie_autodoc/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	var/datum/component/suit_autodoc/autodoc = parent?.GetComponent(/datum/component/suit_autodoc)
	autodoc.RemoveComponent()
	return ..()


/** Fire poof module */
/obj/item/armor_module/attachable/fire_proof
	name = "Surt Pyrotechnical Insulation System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniacs first stop to survival. Will impact mobility somewhat."
	icon_state = "mod_fire_icon"
	item_state = "mod_fire"
	armor = list("fire" = 100)

/obj/item/armor_module/attachable/fire_proof/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(src.armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.update_overlays()

/obj/item/armor_module/attachable/fire_proof/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(src.armor)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


/** Extra armor module */
/obj/item/armor_module/attachable/tyr_extra_armor
	name = "Tyr Armor Reinforcement"
	desc = "designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeletons conventional armor patterns. Will definitely impact mobility."
	icon_state = "mod_armor_icon"
	item_state = "mod_armor"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 10

/obj/item/armor_module/attachable/tyr_extra_armor/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.slowdown += slowdown
	parent.update_overlays()

/obj/item/armor_module/attachable/tyr_extra_armor/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(armor)
	parent.slowdown -= slowdown
	return ..()


/** Environment protecttion module */
/obj/item/armor_module/attachable/mimir_environment_protection
	name = "Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, acidic elements, and radiological exposure. Best paired with the Mimir Environmental Helmet System. Will impact mobility when active. Must be toggled to function.."
	icon_state = "mod_biohazard_icon"
	item_state = "mod_biohazard"
	armor = list("bio" = 50, "rad" = 50, "acid" = 50)
	slowdown = 10
	module_type = ARMOR_MODULE_TOGGLE
	var/siemens_coefficient_mod = -0.9
	var/permeability_coefficient_mod = -1
	var/gas_transfer_coefficient_mod = -1

/obj/item/armor_module/attachable/mimir_environment_protection/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.siemens_coefficient += siemens_coefficient_mod
	parent.permeability_coefficient += permeability_coefficient_mod
	parent.gas_transfer_coefficient += siemens_coefficient_mod
	parent.slowdown += slowdown
	parent.update_overlays()

/obj/item/armor_module/attachable/mimir_environment_protection/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(armor)
	parent.siemens_coefficient -= siemens_coefficient_mod
	parent.permeability_coefficient -= permeability_coefficient_mod
	parent.gas_transfer_coefficient -= siemens_coefficient_mod
	parent.slowdown -= slowdown
	return ..()

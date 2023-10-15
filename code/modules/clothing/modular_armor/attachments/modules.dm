/**
 ** Modules
 *	These include the helmet and regular armor modules. Basically these are the subtypes of any armor 'system'.
 */
/obj/item/armor_module/module
	name = "broken armor module"
	desc = "You better be debugging."


/**
 * PT belt
 */

/obj/item/armor_module/module/pt_belt
	name = "\improper physical training reflective belt"
	desc = "Sergeant Major ordered marines to wear reflective belt to ensure marines' safety. You can speculate what danger entail a PT belt."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "pt_belt"
	item_state = "pt_belt_a"
	slot = ATTACHMENT_SLOT_BELT

/**
 * Shoulder lamp strength module
 */
/obj/item/armor_module/module/better_shoulder_lamp
	name = "\improper Baldur Light Amplification System"
	desc = "Designed for mounting on modular armor. Substantially increases the power output of your modular armor's mounted flashlight. Be the light in the darkness."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_lamp"
	item_state = "mod_lamp_a"
	slowdown = 0
	light_mod = 4 /// The boost to armor shoulder light
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_lamp_xn")

/**
 * Mini autodoc module
 */
/obj/item/armor_module/module/valkyrie_autodoc
	name = "\improper Valkyrie Automedical Armor System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on modular armor. This module has advanced medical systems that inject tricordrazine and tramadol based on the user's needs, as well as automatically securing the bones and body of the wearer, effectively splinting them until professional medical attention can be admistered. Will definitely impact mobility."
	icon_state = "mod_autodoc"
	item_state = "mod_autodoc_a"
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_autodoc_xn")
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

/obj/item/armor_module/module/valkyrie_autodoc/som
	name = "\improper Apollo Automedical Armor System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed to be mounted on SOM combat armor, or internally inside Gorgon assault armor. This module has advanced medical systems that inject tricordrazine and tramadol based on the user's needs, as well as automatically securing the bones and body of the wearer, effectively splinting them until professional medical attention can be admistered. Will definitely impact mobility."
	icon_state = "mod_autodoc_som"
	item_state = "mod_autodoc_som_a"
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/som/heavy/leader = "")

/**
 * Fire poof module
*/
/obj/item/armor_module/module/fire_proof
	name = "\improper Surt Pyrotechnical Insulation System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on modular armor. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniac's first stop to survival. Will impact mobility."
	icon_state = "mod_fire"
	item_state = "mod_fire_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 35, ACID = 0)
	slowdown = 0.4
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_fire_xn")

/obj/item/armor_module/module/fire_proof/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.flags_armor_features |= ARMOR_FIRE_RESISTANT

/obj/item/armor_module/module/fire_proof/on_detach(obj/item/detaching_from, mob/user)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.flags_armor_features &= ~ARMOR_FIRE_RESISTANT
	return ..()

/obj/item/armor_module/module/fire_proof/som
	name = "\improper Hades Incendiary Insulation System"
	desc = "Designed for mounting on modular SOM armor. Provides excellent resistance to fire and prevents combustion. As it is not a sealed system, it does not completely protect the user from the heat of fire. Will impact mobility."
	icon_state = "mod_fire_som"
	item_state = "mod_fire_som_a"

/obj/item/armor_module/module/fire_proof_helmet

	name = "\improper Surt Pyrotechnical Insulation Helmet System"
	desc = "Designed for mounting on a modular helmet. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniac's first stop to survival."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_fire_head"
	item_state = "mod_fire_head_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 35, ACID = 0)
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "mod_fire_head_xn")

/**
 * Extra armor module
*/
/obj/item/armor_module/module/tyr_extra_armor
	name = "\improper Mark 2 Tyr Armor Reinforcement"
	desc = "Designed for mounting on modular armor. A substantial amount of additional armor plating designed to grant the user extra protection against threats, ranging from xeno slashes to friendly fire incidents. This newer version has improved protection. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armor"
	item_state = "mod_armor_a"
	attachment_layer = COLLAR_LAYER
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 15, ACID = 15)
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_armor_xn")

/obj/item/armor_module/module/tyr_extra_armor/mark1
	name = "\improper Mark 1 Tyr Armor Reinforcement"
	desc = "Designed for mounting on modular armor. A substantial amount of additional armor plating designed to grant the user extra protection against threats, ranging from xeno slashes to friendly fire incidents. This older version has worse protection. Will greatly impact mobility."
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slowdown = 0.4

/obj/item/armor_module/module/tyr_extra_armor/som
	name = "\improper Lorica Armor Reinforcement"
	desc = "Designed for mounting on modular SOM armor. A substantial amount of additional armor plating designed to grant the user extra protection against all forms of damage. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "lorica_armor"
	item_state = "lorica_armor_a"
	attachment_layer = null
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 10, ACID = 5)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/tyr_head
	name = "Tyr Helmet System"
	desc = "Designed for mounting on a modular helmet. When attached, this system provides substantial resistance to most damaging hazards, ranging from xeno slashes to friendly fire incidents."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "tyr_head"
	item_state = "tyr_head_a"
	soft_armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "tyr_head_xn")

/obj/item/armor_module/module/hod_head
	name = "\improper Hod Helmet System"
	desc = "Designed for mounting on a modular helmet. When attached, this system provides substantial resistance to most gunshot wounds by providing high internal padding within the helmet's structure."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff_head"
	item_state = "mod_ff_head_a"
	soft_armor = list(MELEE = 0, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/**
 * Environment protection module
*/
/obj/item/armor_module/module/mimir_environment_protection
	name = "\improper Mark 2 Mimir Environmental Resistance System"
	desc = "Designed for mounting on modular armor. This newer model provides great resistance to acid, biological, and radiological attacks. Pairing this with a Mimir helmet module and mask will make the user impervious to xeno gas clouds. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 0, ACID = 30)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_biohazard_xn")
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

/obj/item/armor_module/module/mimir_environment_protection/mark1
	name = "\improper Mark 1 Mimir Environmental Resistance System"
	desc = "Designed for mounting on modular armor. This older model provides minor resistance to acid, biological, and radiological attacks. Pairing this with a Mimir helmet module and mask will make the user impervious to xeno gas clouds. Will impact mobility."
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, FIRE = 0, ACID = 15)
	slowdown = 0.2

//SOM version
/obj/item/armor_module/module/mimir_environment_protection/som
	name = "\improper Mithridatius Hostile Environment System"
	desc = "Designed for mounting on modular SOM armor. This module appears to be designed to protect the user from the effects of radiological attacks, although also provides improved resistance against other environmental threats such as acid and gas. Pairing this with a Mithridatius helmet module and mask will make the user impervious to gas clouds. Will impact mobility."
	icon_state = "mithridatius"
	item_state = "mithridatius_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 25, FIRE = 0, ACID = 20)

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet
	name = "Mark 2 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a modular helmet. This newer model provides great resistance to acid, biological, and even radiological attacks. Pairing this with a Mimir suit module and mask will make the user impervious to xeno gas clouds."
	icon_state = "mimir_head"
	item_state = "mimir_head_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 0, ACID = 30)
	slowdown = 0
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "mimir_head_xn")

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1 //gas protection
	name = "Mark 1 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a modular helmet. This older model provides minor resistance to acid and biological attacks. Pairing this with a Mimir suit module and mask will make the user impervious to xeno gas clouds."
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, FIRE = 0, ACID = 15)

//Explosive defense armor
/obj/item/armor_module/module/hlin_explosive_armor
	name = "Hlin Explosive Compensation Module"
	desc = "Designed for mounting on modular armor. Uses a complex set of armor plating and compensation to lessen the effect of explosions. Will impact mobility"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_boomimmune"
	item_state = "mod_boomimmune_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 40, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_bombimmune_xn")

/**
 * Extra armor module
*/
/obj/item/armor_module/module/ballistic_armor
	name = "\improper Hod Accident Prevention Plating"
	desc = "Designed for mounting on modular armor. A substantial amount of additional reflective ballistic armor plating designed to reduce the impact of friendly fire incidents, will lessen the affects of bullets and lasers. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff"
	item_state = "mod_ff_a"
	soft_armor = list(MELEE = 0, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_ff_xn")

/obj/item/armor_module/module/chemsystem
	name = "Vali chemical enhancement module"
	desc = "Designed for mounting on modular armor. This experimental module runs on green blood taken from xenos with harvester class weapons; Green blood heals the user and boosts any chems in the suit injection system. \nUse the suit menu to connect harvester class weapons, control the injection system, find chem boost information, and more."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_chemsystem"
	item_state = "mod_chemsystem_a"
	slot = ATTACHMENT_SLOT_MODULE
	///Lets us keep track of what icon state we're in
	var/chemsystem_is_active = FALSE

/obj/item/armor_module/module/chemsystem/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/datum/component/chem_booster/chemsystem = parent.AddComponent(/datum/component/chem_booster)
	RegisterSignal(chemsystem, COMSIG_CHEMSYSTEM_TOGGLED, PROC_REF(update_module_icon))

/obj/item/armor_module/module/chemsystem/on_detach(obj/item/detaching_from, mob/user)
	var/datum/component/chem_booster/chemsystem = parent.GetComponent(/datum/component/chem_booster)
	UnregisterSignal(chemsystem, COMSIG_CHEMSYSTEM_TOGGLED)
	chemsystem.RemoveComponent()
	return ..()

///Updates the module on the armor to glow or not
/obj/item/armor_module/module/chemsystem/proc/update_module_icon(datum/source, toggle)
	SIGNAL_HANDLER
	chemsystem_is_active = toggle
	update_icon()
	parent.update_icon()

/obj/item/armor_module/module/chemsystem/update_icon_state()
	if(chemsystem_is_active)
		icon_state = "mod_chemsystem_active"
		return
	icon_state = initial(icon_state)

/obj/item/armor_module/module/eshield
	name = "Svalinn Energy Shield System"
	desc = "A brand new innovation in armor systems, this module creates a shield around the user that is capable of negating all damage. If it sustains too much it will deactivate, and leave the user vulnerable."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_eshield"
	item_state = "mod_eshield_a"
	slot = ATTACHMENT_SLOT_MODULE
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = -5, FIRE = 0, ACID = -5)
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_eshield_xn")

	///Current shield Health
	var/shield_health = 0
	///Maximum shield Health
	var/max_shield_health = 40
	///Amount to recharge per tick, processes once every two seconds.
	var/recharge_rate = 10

	///Spark system used to generate sparks when the armor takes damage
	var/datum/effect_system/spark_spread/spark_system

	///Shield color when the shield is 0 - 33% full
	var/shield_color_low = COLOR_MAROON
	///Shield color when the shield is 33 - 66% full
	var/shield_color_mid = COLOR_MOSTLY_PURE_RED
	///Shield color when the shield is 66% to full
	var/shield_color_full = COLOR_BLUE_LIGHT
	///Current shield color
	var/current_color
	///Delay it takes to start recharging again after the shield has been damaged.
	var/damaged_shield_cooldown = 10 SECONDS
	///Holds id for a timer which triggers recharge start. Null if not currently delayed.
	var/recharge_timer

/obj/item/armor_module/module/eshield/Initialize(mapload)
	. = ..()
	spark_system = new()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/armor_module/module/eshield/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/armor_module/module/eshield/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_equip))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(handle_unequip))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(parent_examine))


/obj/item/armor_module/module/eshield/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_EXAMINE))
	return ..()

///Called to give extra info on parent examine.
/obj/item/armor_module/module/eshield/proc/parent_examine(datum/source, mob/examiner)
	SIGNAL_HANDLER
	to_chat(examiner, span_notice("Recharge Rate: [recharge_rate/2] health per second\nCurrent Shield Health: [shield_health]\nMaximum Shield Health: [max_shield_health]\n"))
	if(!recharge_timer)
		return
	to_chat(examiner, span_warning("Charging is delayed! It will start recharging again in [timeleft(recharge_timer) / 10] seconds!"))

///Handles starting the shield when the parent is equiped to the correct slot.
/obj/item/armor_module/module/eshield/proc/handle_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_WEAR_SUIT || !isliving(equipper))
		return
	if(!recharge_timer)
		START_PROCESSING(SSobj, src)
		playsound(equipper, 'sound/items/eshield_recharge.ogg', 40)

	RegisterSignal(equipper, COMSIG_LIVING_SHIELDCALL, PROC_REF(handle_shield))

///Handles removing the shield when the parent is unequipped
/obj/item/armor_module/module/eshield/proc/handle_unequip(datum/source, mob/unequipper, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_WEAR_SUIT || !isliving(unequipper))
		return
	UnregisterSignal(unequipper, COMSIG_LIVING_SHIELDCALL)
	STOP_PROCESSING(SSobj, src)
	unequipper.remove_filter("eshield")
	shield_health = 0

///Adds the correct proc callback to the shield list for intercepting damage.
/obj/item/armor_module/module/eshield/proc/handle_shield(datum/source, list/affecting_shields, dam_type)
	SIGNAL_HANDLER
	if(!shield_health)
		return
	affecting_shields += CALLBACK(src, PROC_REF(intercept_damage))

///Handles the interception of damage.
/obj/item/armor_module/module/eshield/proc/intercept_damage(attack_type, incoming_damage, damage_type, silent)
	if(attack_type == COMBAT_TOUCH_ATTACK) //Touch attack so runners can pounce
		return incoming_damage
	STOP_PROCESSING(SSobj, src)
	deltimer(recharge_timer)
	var/shield_left = shield_health - incoming_damage
	var/mob/living/affected = parent.loc
	affected.remove_filter("eshield")
	if(shield_left > 0)
		shield_health = shield_left
		switch(shield_left / max_shield_health)
			if(0 to 0.33)
				affected.add_filter("eshield", 2, outline_filter(1, shield_color_low))
			if(0.33 to 0.66)
				affected.add_filter("eshield", 2, outline_filter(1, shield_color_mid))
			if(0.66 to 1)
				affected.add_filter("eshield", 2, outline_filter(1, shield_color_full))
		spark_system.start()
	else
		shield_health = 0
		recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown + 1, TIMER_STOPPABLE) //Gives it a little extra time for the cooldown.
		return -shield_left
	recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown, TIMER_STOPPABLE)
	return 0

///Starts the shield recharging after it has been broken.
/obj/item/armor_module/module/eshield/proc/begin_recharge()
	recharge_timer = null
	if(!ishuman(parent.loc))
		return
	var/mob/living/carbon/human/wearer = parent.loc
	if(wearer.wear_suit != parent)
		return
	playsound(wearer, 'sound/items/eshield_recharge.ogg', 40)
	START_PROCESSING(SSobj, src)


/obj/item/armor_module/module/eshield/process()
	shield_health = min(shield_health + recharge_rate, max_shield_health)
	if(shield_health == max_shield_health) //Once health is full, we don't need to process until the next time we take damage.
		STOP_PROCESSING(SSobj, src)
		return
	var/new_color
	switch(shield_health/max_shield_health)
		if(0 to 0.2)
			playsound(parent.loc, 'sound/items/eshield_down.ogg', 40)
			new_color = (shield_color_low != current_color) ? shield_color_low : null
		if(0.2 to 0.6)
			new_color = (shield_color_mid != current_color) ? shield_color_mid : null
		if(0.6 to 1)
			new_color = (shield_color_full != current_color) ? shield_color_full : null
	if(!new_color)
		return
	var/mob/living/affected = parent.loc
	affected.remove_filter("eshield")
	affected.add_filter("eshield", 2, outline_filter(1, new_color))

//original Martian design, donutsteel
/obj/item/armor_module/module/eshield/som
	name = "Aegis Energy Dispersion Module"
	desc = "A sophisticated shielding unit, designed to disperse the energy of incoming impacts, rendering them harmless to the user. If it sustains too much it will deactivate, and leave the user vulnerable. It is unclear if this was a purely  SOM designed module, or whether it was reverse engineered from the TGMC's 'Svalinn' shield system which was developed around the same time."


// ***************************************
// *********** Jetpack Module
// ***************************************
#define JETPACK_FUEL_USE 5

/obj/item/armor_module/module/jetpack
	name = "Jetpack module"
	desc = "Designed for mounting on modular armor. A high powered jetpack with enough fuel to send a person flying for a short while. It allows for fast and agile movement on the battlefield. <b>Alt right click or middleclick to fly to a destination when the jetpack is active.</b>"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_jetpack"
	item_state = "mod_jetpack_a"
	slot = ATTACHMENT_SLOT_MODULE
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = -5, FIRE = 0, ACID = -5)
	/// This module's custom action.
	var/datum/action/item_action/toggle/jetpack_action/module_action
	/// Whether the module's VFX are active or not.
	var/module_visuals = FALSE

/obj/item/armor_module/module/jetpack/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_equip))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(handle_unequip))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(parent_examine))

/obj/item/armor_module/module/jetpack/on_detach(obj/item/detaching_from, mob/user)
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED, COMSIG_ATOM_EXAMINE))

/obj/item/armor_module/module/jetpack/update_icon_state()
	if(module_visuals)
		icon_state = "[icon_state]_active"
		return
	icon_state = initial(icon_state)

/// Gives the appropriate action whenever the parent is equipped.
/obj/item/armor_module/module/jetpack/proc/handle_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_WEAR_SUIT || !isliving(equipper))
		return
	var/datum/action/item_action/toggle/jetpack_action/new_action = new(src)
	new_action?.give_action(equipper)

/// Removes the appropriate action whenever the parent is unequipped.
/obj/item/armor_module/module/jetpack/proc/handle_unequip(datum/source, mob/unequipper, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_WEAR_SUIT || !isliving(unequipper))
		return
	module_action?.remove_action(unequipper)

/// Gives additional information about this module.
/obj/item/armor_module/module/jetpack/proc/parent_examine(datum/source, mob/examiner)
	SIGNAL_HANDLER
	if(module_action)
		to_chat(examiner, span_notice("The jetpack has [module_action.fuel_left]/[initial(module_action.fuel_left)] fuel left, equaling to [module_action.fuel_left/JETPACK_FUEL_USE] uses.\n"))

/// Toggles visuals.
/obj/item/armor_module/module/jetpack/proc/toggle_visuals()
	module_visuals = !module_visuals
	update_icon()


// ***************************************
// *********** Jetpack Action
// ***************************************
#define VREF_MUTABLE_JETPACK_USES "VREF_JETPACK_USES"
#define JETPACK_CONTROL_MIDDLE_CLICK "Middle Click"
#define JETPACK_CONTROL_SHIFT_CLICK "Shift Click"
#define JETPACK_CONTROL_ALT_RIGHT_CLICK "Alt wRight Click"
#define JETPACK_HOVER_SPEED 1
#define JETPACK_HOVER_TIME 1 SECONDS
#define JETPACK_COOLDOWN_TIME 10 SECONDS

/datum/action/item_action/toggle/jetpack_action
	name = "Jetpack"
	action_icon_state = "jetpack_3"
	/// Whether this action can be activated using middle click.
	var/can_middle_click = TRUE
	/// Whether this action can be activated using shift + click.
	var/can_shift_click = TRUE
	/// Whether this action can be activated using alt + right click.
	var/can_alt_rclick = TRUE
	/// Amount of fuel left in the jetpack. Starting value is assumed to be the maximum amount of fuel.
	var/fuel_left = 75

/datum/action/item_action/toggle/jetpack_action/give_action(mob/M)
	. = ..()
	var/mutable_appearance/uses_counter = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	uses_counter.pixel_x = 16
	uses_counter.pixel_y = -4
	uses_counter.maptext = MAPTEXT("[fuel_left/JETPACK_FUEL_USE]/[initial(fuel_left)/JETPACK_FUEL_USE]")
	visual_references[VREF_MUTABLE_JETPACK_USES] = uses_counter

/datum/action/item_action/toggle/jetpack_action/remove_action(mob/M)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_JETPACK_USES])
	visual_references[VREF_MUTABLE_JETPACK_USES] = null
	if(toggled)
		if(can_middle_click)
			UnregisterSignal(owner, COMSIG_MOB_MIDDLE_CLICK)
		if(can_shift_click)
			UnregisterSignal(owner, COMSIG_MOB_CLICK_SHIFT)
		if(can_alt_rclick)
			UnregisterSignal(owner, COMSIG_MOB_CLICK_ALT_RIGHT)

/datum/action/item_action/toggle/jetpack_action/update_button_icon()
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_JETPACK_USES])
	var/mutable_appearance/uses_counter = visual_references[VREF_MUTABLE_JETPACK_USES]
	uses_counter.maptext = MAPTEXT("[fuel_left/JETPACK_FUEL_USE]/[initial(fuel_left)/JETPACK_FUEL_USE]")
	visual_references[VREF_MUTABLE_JETPACK_USES] = uses_counter
	button.add_overlay(visual_references[VREF_MUTABLE_JETPACK_USES])
	if(fuel_left >= initial(fuel_left))
		action_icon_state = "jetpack_3"
		return
	if(fuel_left >= initial(fuel_left) * 0.5)
		action_icon_state = "jetpack_2"
		return
	if(fuel_left >= JETPACK_FUEL_USE)
		action_icon_state = "jetpack_1"
		return
	action_icon_state = "jetpack_0"

/datum/action/item_action/toggle/jetpack_action/alternate_action_activate()
	. = ..()
	var/list/radial_options = list(
		JETPACK_CONTROL_MIDDLE_CLICK = image('icons/mob/actions.dmi', icon_state = "middle_click"),
		JETPACK_CONTROL_SHIFT_CLICK = image('icons/mob/actions.dmi', icon_state = "shift_click"),
		JETPACK_CONTROL_ALT_RIGHT_CLICK = image('icons/mob/actions.dmi', icon_state = "alt_rclick"),
		)
	var/control_choice = show_radial_menu(owner, src, radial_options, radius = 35, require_near = TRUE)
	if(!control_choice)
		return
	switch(control_choice)
		if(JETPACK_CONTROL_MIDDLE_CLICK)
			can_middle_click = !can_middle_click
			owner.balloon_alert("Middle click [can_middle_click? "enabled" : "disabled"]")
		if(JETPACK_CONTROL_SHIFT_CLICK)
			can_shift_click = !can_shift_click
			owner.balloon_alert("Shift + Click [can_shift_click? "enabled" : "disabled"]")
		if(JETPACK_CONTROL_ALT_RIGHT_CLICK)
			can_alt_rclick = !can_alt_rclick
			owner.balloon_alert("Alt + Right click [can_alt_rclick? "enabled" : "disabled"]")
	update_controls()

/datum/action/item_action/toggle/jetpack_action/action_activate()
	toggled = !toggled
	set_toggle(toggled)
	owner.balloon_alert(owner, "Toggled [toggled? "on" : "off"]!")
	update_controls()

/// Updates controls based on item preferences.
/datum/action/item_action/toggle/jetpack_action/proc/update_controls()
	if(!toggled)
		if(can_middle_click)
			UnregisterSignal(owner, COMSIG_MOB_MIDDLE_CLICK)
		if(can_shift_click)
			UnregisterSignal(owner, COMSIG_MOB_CLICK_SHIFT)
		if(can_alt_rclick)
			UnregisterSignal(owner, COMSIG_MOB_CLICK_ALT_RIGHT)
		return
	if(can_middle_click)
		RegisterSignal(owner, COMSIG_MOB_MIDDLE_CLICK, PROC_REF(use_jetpack))
	if(can_shift_click)
		RegisterSignal(owner, COMSIG_MOB_CLICK_SHIFT, PROC_REF(use_jetpack))
	if(can_alt_rclick)
		RegisterSignal(owner, COMSIG_MOB_CLICK_ALT_RIGHT, PROC_REF(use_jetpack))

/// Makes the user fly towards the target atom.
/datum/action/item_action/toggle/jetpack_action/proc/use_jetpack(datum/source, atom/A)
	SIGNAL_HANDLER
	if(!holder_item || !istype(holder_item, /obj/item/armor_module/module/jetpack))
		return
	if(!can_use_jetpack(A))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/hover_distance = calculate_distance(human_owner)
	if(!hover_distance)
		owner.balloon_alert("Too heavy!")
		return
	fuel_left -= JETPACK_FUEL_USE
	update_button_icon()
	var/obj/item/armor_module/module/jetpack/holder_jetpack = holder_item
	holder_jetpack.toggle_visuals()
	new /obj/effect/temp_visual/smoke(get_turf(human_owner))
	playsound(human_owner, 'sound/items/jetpack_sound.ogg',45)
	human_owner.fly_at(A, hover_distance, JETPACK_HOVER_SPEED, JETPACK_HOVER_TIME)
	addtimer(CALLBACK(holder_item, TYPE_PROC_REF(/obj/item/armor_module/module/jetpack, toggle_visuals)), JETPACK_HOVER_TIME)
	TIMER_COOLDOWN_START(src, COOLDOWN_JETPACK, JETPACK_COOLDOWN_TIME)

/// Checks if we can use the jetpack, otherwise giving feedback to the user.
/datum/action/item_action/toggle/jetpack_action/proc/can_use_jetpack(atom/A)
	if(!ishuman(owner) || !A)
		return
	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.incapacitated() || human_owner.lying_angle)
		return
	if(fuel_left < JETPACK_FUEL_USE)
		human_owner.balloon_alert(human_owner, "No fuel")
		return
	if(human_owner.buckled)
		human_owner.balloon_alert(human_owner, "Cannot while buckled")
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_JETPACK))
		human_owner.balloon_alert(human_owner, "On cooldown, wait [S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_JETPACK) * 0.1]s")
		return
	if(human_owner.do_actions)
		return
	if(!do_after(user = human_owner, delay = 0.3 SECONDS, needhand = FALSE, target = A, ignore_turf_checks = TRUE))
		return
	return TRUE

/// Calculates the hover distance of the jetpack based on the user's current slowdown.
/datum/action/item_action/toggle/jetpack_action/proc/calculate_distance(proc_owner)
	if(!proc_owner || !ishuman(proc_owner))
		return 0
	var/mob/living/carbon/human/human_owner = proc_owner
	var/current_slowdown = human_owner.additive_flagged_slowdown(SLOWDOWN_IMPEDE_JETPACK)
	switch(current_slowdown)
		if(0 to 0.35) // Light armor or unarmored users.
			return 7
		if(0.35 to 0.75) // Medium and heavy armor users, although lighter armor types with shield can also achieve this.
			return 5
		if(0.75 to 1.2) // Heavier setups, achievable through Tyr modules or heavy armors with shield.
			return 3
		if(1.2 to INFINITY) // Anything heavier than previous cases.
			return 2

/*
/obj/item/jetpack_marine/afterattack(obj/target, mob/user, proximity_flag) //refuel at fueltanks when we run out of fuel
	if(!istype(target, /obj/structure/reagent_dispensers/fueltank) || !proximity_flag)
		return ..()
	var/obj/structure/reagent_dispensers/fueltank/FT = target
	if(FT.reagents.total_volume == 0)
		balloon_alert(user, "No fuel")
		return

	var/fuel_transfer_amount = min(FT.reagents.total_volume, (fuel_max - fuel_left))
	FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	fuel_left += fuel_transfer_amount
	fuel_indicator = FUEL_INDICATOR_FULL
	change_fuel_indicator()
	update_icon()
	playsound(loc, 'sound/effects/refill.ogg', 30, 1, 3)
	balloon_alert(user, "Refilled")

/obj/item/jetpack_marine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/ammo_magazine/flamer_tank))
		return
	var/obj/item/ammo_magazine/flamer_tank/FT = I
	if(FT.current_rounds == 0)
		balloon_alert(user, "No fuel")
		return

	var/fuel_transfer_amount = min(FT.current_rounds, (fuel_max - fuel_left))
	FT.current_rounds -= fuel_transfer_amount
	fuel_left += fuel_transfer_amount
	fuel_indicator = FUEL_INDICATOR_FULL
	change_fuel_indicator()
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	balloon_alert(user, "Refilled")
	update_icon()
*/


/obj/item/armor_module/module/style
	name = "\improper Armor Equalizer"
	desc = "Designed for mounting on conventional clothing, this grants it a level of reinforcement against attacks."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armor"
	slot = ATTACHMENT_SLOT_CHESTPLATE

	var/codex_info = {"<BR>This item is part of the <b>Style Line.</b><BR>
	<BR>The <b>Style Line</b> is a line of equipment designed to provide as much style as possible without compromising the user's protection.
	This line of equipment accepts <b>Equalizer modules</b>, which allow the user to alter any given piece of equipment's protection according to their preferences.<BR>
	<BR>This is an <b>Equalizer module</b>. Equalizer modules create an invisible mesh over the user's body that grants protection against many dangers, adjusting itself in such a way that their movements remain unimpeded."}

/obj/item/armor_module/module/style/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/armor_module/module/style/light_armor
	name = "\improper Light Armor Equalizer"
	icon_state = "style_light"
	item_state = "style_light_a"
	soft_armor = list(MELEE = 35, BULLET = 55, LASER = 55, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 45, ACID = 45)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/armor_module/module/style/medium_armor
	name = "\improper Medium Armor Equalizer"
	icon_state = "style_medium"
	item_state = "style_medium_a"
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 65, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 55)
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/armor_module/module/style/heavy_armor
	name = "\improper Heavy Armor Equalizer"
	icon_state = "style_heavy"
	item_state = "style_heavy_a"
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	slowdown = SLOWDOWN_ARMOR_HEAVY

/**
 *   Helmet Modules
*/
/obj/item/armor_module/module/welding
	name = "Welding Helmet Module"
	desc = "Designed for mounting on a modular helmet. This module can be toggled on or off to function as welding protection for your delicate eyes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	item_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "welding_head_xn")
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	active = FALSE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE
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
	icon_state = base_icon + "[active ? "_active" : ""]"
	item_state = icon_state + "_a"
	parent.update_icon()
	user.update_inv_head()

/obj/item/armor_module/module/welding/som
	name = "Integrated Welding Helmet Module"
	desc = "Built in welding module for a SOM engineering helmet. This module can be toggled on or off to function as welding protection for your delicate eyes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head_som"
	item_state = "welding_head_som_a"
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB

/obj/item/armor_module/module/welding/superior
	name = "Superior Welding Helmet Module"
	desc = "Designed for mounting on a modular helmet. This more expensive module can be toggled on or off to function as welding protection for your delicate eyes, strangely smells like potatoes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	item_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "welding_head_superior_xn")
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	active = FALSE
	prefered_slot = SLOT_HEAD

/obj/item/armor_module/module/welding/superior/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/clothing_tint, TINT_4, active)

/obj/item/armor_module/module/binoculars
	name = "Binocular Helmet Module"
	desc = "Designed for mounting on a modular helmet. Can be flipped down to view into the distance."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "binocular_head"
	item_state = "binocular_head_a"
	active = FALSE
	flags_item = DOES_NOT_NEED_HANDS
	zoom_tile_offset = 11
	zoom_viewsize = 12
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE

/obj/item/armor_module/module/binoculars/activate(mob/living/user)
	zoom(user)
	if(active == zoom) //Zooming failed for some reason and didn't change
		return
	active = zoom
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = initial(icon_state) + "[active ? "_active" : ""]"
	item_state = icon_state + "_a"
	parent.update_icon()
	user.update_inv_head()
	if(active)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(zoom_item_turnoff))
		return
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)

/obj/item/armor_module/module/binoculars/zoom_item_turnoff(datum/source, mob/living/user)
	if(isliving(source))
		activate(source)
	else
		activate(user)
	return COMSIG_MOB_CLICK_CANCELED

/obj/item/armor_module/module/binoculars/artemis_mark_two // a little cheating with subtypes
	name = "\improper Mark 2 Freyr Helmet Module"
	desc = "Designed for mounting on a modular helmet. The Freyr module is designed with an overlay visor that clarifies the user's vision, allowing them to see clearly even in the harshest of circumstances. This version is enhanced and allows the marine to peer through the visor, akin to binoculars."
	icon_state = "artemis_head"
	item_state = "artemis_head_mk2_a"
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "artemis_head_mk2_xn", /obj/item/clothing/head/modular/marine/old/open = "artemis_head_mk2_xn", /obj/item/clothing/head/modular/m10x/heavy = "artemis_head_mk2")

/obj/item/armor_module/module/binoculars/artemis_mark_two/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/blur_protection)

/obj/item/armor_module/module/artemis
	name = "\improper Mark 1 Freyr Helmet Module"
	desc = "Designed for mounting on a modular helmet. The Freyr module is designed with an overlay visor that clarifies the user's vision, allowing them to see clearly even in the harshest of circumstances."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "artemis_head"
	item_state = "artemis_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "artemis_head_xn", /obj/item/clothing/head/modular/marine/old/open = "artemis_head_xn", /obj/item/clothing/head/modular/m10x/heavy = "artemis_head")
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB
	prefered_slot = SLOT_HEAD

/obj/item/armor_module/module/artemis/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/blur_protection)

/obj/item/armor_module/module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a modular Helmet. This module is able to provide a readout of the user's coordinates and connect to the shipside supply console."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	item_state = "antenna_head_a"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/armor_module/module/antenna/Destroy()
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
	return ..()

/obj/item/armor_module/module/antenna/activate(mob/living/user)
	var/turf/location = get_turf(src)
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
		user.show_message(span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console"), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
		return
	if(!is_ground_level(user.z))
		to_chat(user, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(user, span_warning("This won't work if you're standing deep underground."))
		return FALSE
	beacon_datum = new /datum/supply_beacon(user.name, user.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_QDELETING, PROC_REF(clean_beacon_datum))
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))

/// Signal handler to nullify beacon datum
/obj/item/armor_module/module/antenna/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

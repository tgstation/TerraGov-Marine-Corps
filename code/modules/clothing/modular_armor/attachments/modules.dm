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
	worn_icon_state = "pt_belt_a"
	slot = ATTACHMENT_SLOT_BELT
	attach_features_flags = ATTACH_NO_HANDS

/**
 * Shoulder lamp strength module
 */
/obj/item/armor_module/module/better_shoulder_lamp
	name = "\improper Baldur light amplification system"
	desc = "Designed for mounting on modular armor. Substantially increases the power output of your modular armor's mounted flashlight. Be the light in the darkness."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_lamp"
	worn_icon_state = "mod_lamp_a"
	slowdown = 0
	light_mod = 4 /// The boost to armor shoulder light
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_lamp_xn", /obj/item/clothing/suit/modular/tdf = "", /obj/item/clothing/suit/storage/marine/freelancer = "")

/**
 * Mini autodoc module
 */
/obj/item/armor_module/module/valkyrie_autodoc
	name = "\improper Valkyrie automedical system"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on modular armor. This module has advanced medical systems that inject tricordrazine and tramadol based on the user's needs, as well as automatically securing the bones and body of the wearer, effectively splinting them until professional medical attention can be admistered. Will definitely impact mobility."
	icon_state = "mod_autodoc"
	worn_icon_state = "mod_autodoc_a"
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_autodoc_xn", /obj/item/clothing/suit/modular/tdf = "", /obj/item/clothing/suit/storage/marine/freelancer = "")

/obj/item/armor_module/module/valkyrie_autodoc/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	var/list/tricord = list(/datum/reagent/medicine/tricordrazine)
	var/list/tramadol = list(/datum/reagent/medicine/tramadol)
	/// This will do nothing without the autodoc update
	parent.AddComponent(/datum/component/suit_autodoc, 4 MINUTES, tricord, tricord, tricord, tricord, tramadol, 0.5)
	parent.AddElement(/datum/element/limb_support)

/obj/item/armor_module/module/valkyrie_autodoc/on_detach(obj/item/detaching_from, mob/user)
	detaching_from.remove_component(/datum/component/suit_autodoc)
	detaching_from.RemoveElement(/datum/element/limb_support)
	return ..()

/obj/item/armor_module/module/valkyrie_autodoc/som
	name = "\improper Apollo automedical system"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed to be mounted on SOM combat armor, or internally inside Gorgon assault armor. This module has advanced medical systems that inject tricordrazine and tramadol based on the user's needs, as well as automatically securing the bones and body of the wearer, effectively splinting them until professional medical attention can be admistered. Will definitely impact mobility."
	icon_state = "mod_autodoc_som"
	worn_icon_state = "mod_autodoc_som_a"
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/som/heavy/leader = "")

/**
 * Fire poof module
*/
/obj/item/armor_module/module/fire_proof
	name = "\improper Surt thermal insulation system"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on modular armor. It shields you from the effects of fire, and prevents you from being set alight by any means. Wearing this in combination with the corresponding helmet module will render you completely impervious to fire. Will definitely impact mobility."
	icon_state = "mod_fire"
	worn_icon_state = "mod_fire_a"
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 40, ACID = -10)
	slowdown = 0.4
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_fire_xn", /obj/item/clothing/suit/modular/tdf/heavy = "mod_fire_tdf", /obj/item/clothing/suit/storage/marine/freelancer = "")

/obj/item/armor_module/module/fire_proof/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.armor_features_flags |= ARMOR_FIRE_RESISTANT

/obj/item/armor_module/module/fire_proof/on_detach(obj/item/detaching_from, mob/user)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.armor_features_flags &= ~ARMOR_FIRE_RESISTANT
	return ..()

/obj/item/armor_module/module/fire_proof_helmet
	name = "\improper Surt thermal insulation system helmet module"
	desc = "Designed for mounting on a modular helmet. It shields you from the effects of fire, and prevents you from being set alight by any means. Wearing this in combination with the corresponding helmet module will render you completely impervious to fire. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_fire_head"
	worn_icon_state = "mod_fire_head_a"
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 40, ACID = -10)
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "mod_fire_head_xn", /obj/item/clothing/head/modular/tdf = "")

/obj/item/armor_module/module/fire_proof/som
	name = "\improper Hades incendiary insulation system"
	desc = "Designed for mounting on modular SOM armor. It provides near-immunity to the effects of fire, and prevents you from being set alight by any means. Wearing this in combination with the corresponding helmet module will render you completely impervious to fire. Will not actually provide any resistance against volkite weaponry. Will impact mobility."
	icon_state = "mod_fire_som"
	worn_icon_state = "mod_fire_som_a"
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 35, ACID = -10)

/**
 * Extra armor module
*/

/obj/item/armor_module/module/tyr_extra_armor
	name = "\improper Tyr Mk.2 armor reinforcement system"
	desc = "Designed for mounting on modular armor. A substantial amount of additional all-around armor plating designed to grant the user extra protection against any kind of threat. This newer version has improved protection, and will impact mobility less than its predecessor."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armor"
	worn_icon_state = "mod_armor_a"
	attachment_layer = COLLAR_LAYER
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 15, ACID = 15)
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_armor_xn", /obj/item/clothing/suit/modular/tdf = "")

/obj/item/armor_module/module/tyr_extra_armor/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	attaching_to.AddComponent(/datum/component/stun_mitigation, slot_override = SLOT_WEAR_SUIT, shield_cover = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50))

/obj/item/armor_module/module/tyr_extra_armor/on_detach(obj/item/detaching_from, mob/user)
	detaching_from.remove_component(/datum/component/stun_mitigation)
	return ..()

/obj/item/armor_module/module/tyr_extra_armor/mark1
	name = "\improper Tyr Mk.1 armor reinforcement system"
	desc = "Designed for mounting on modular armor. A decent amount of additional all-around armor plating designed to grant the user extra protection against any kind of threat. This older version has worse protection. Will greatly impact mobility."
	icon_state = "mod_armor_lower"
	worn_icon_state = "mod_armor_lower_a"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slowdown = 0.4

/obj/item/armor_module/module/tyr_head
	name = "\improper Tyr armor reinforcement system helmet module"
	desc = "Designed for mounting on a modular helmet. A substantial amount of all-around armour plating designed to grant the user extra protection against any kind of threat."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "tyr_head"
	worn_icon_state = "tyr_head_a"
	soft_armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "tyr_head_xn", /obj/item/clothing/head/modular/tdf = "")

/obj/item/armor_module/module/tyr_extra_armor/som
	name = "\improper Lorica armor reinforcement system"
	desc = "Designed for mounting on modular SOM armor. A substantial amount of additional armor plating designed to grant the user extra protection against all forms of damage. Will definitely impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "lorica_armor"
	worn_icon_state = "lorica_armor_a"
	attachment_layer = null
	soft_armor = list(MELEE = 10, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 10, ACID = 5)

/*
	Friendly fire module
*/

/obj/item/armor_module/module/ballistic_armor
	name = "\improper Hod ballistic deflection system"
	desc = "Designed for mounting on modular armor. Contains large amounts of ballistic armor plating, as well as energetically reflective and thermally dissipative material that grant it a high level of defense against bullets and lasers alike. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff"
	worn_icon_state = "mod_ff_a"
	soft_armor = list(MELEE = 0, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/hod_head
	name = "\improper Hod ballistic deflection system helmet module"
	desc = "Designed for mounting on a modular helmet. Contains large amounts of ballistic armor plating, as well as energetically reflective and thermally dissipative material that grant it a high level of defense against bullets and lasers alike. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff_head"
	worn_icon_state = "mod_ff_head_a"
	soft_armor = list(MELEE = 0, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slot = ATTACHMENT_SLOT_HEAD_MODULE

/**
 * Environment protection module
*/
/obj/item/armor_module/module/mimir_environment_protection
	name = "\improper Mimir Mk.2 environmental resistance system"
	desc = "Designed for mounting on modular armor. This newer model provides great resistance to acid, as well as biological and radiological threats. Pairing this with a Mimir helmet module and a gas mask will make the user impervious to gas attacks. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_biohazard"
	worn_icon_state = "mod_biohazard_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 0, ACID = 30)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_biohazard_xn", /obj/item/clothing/suit/modular/tdf = "", /obj/item/clothing/suit/storage/marine/freelancer = "")
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

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet
	name = "\improper Mimir Mk.2 environmental resistance system helmet module"
	desc = "Designed for mounting on a modular helmet. This newer model provides great resistance to acid, as well as biological and radiological threats. Pairing this with a Mimir suit module and a gas mask will make the user impervious to gas attacks."
	icon_state = "mimir_head"
	worn_icon_state = "mimir_head_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 0, ACID = 30)
	slowdown = 0
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "mimir_head_xn", /obj/item/clothing/head/modular/tdf = "")

/obj/item/armor_module/module/mimir_environment_protection/mark1
	name = "\improper Mimir Mk.1 environmental resistance system"
	desc = "Designed for mounting on modular armor. This older model provides minor resistance to acid, as well as biological, and radiological threats. Pairing this with a Mimir helmet module and mask will make the user highly resistant to gas attacks, but will not provide immunity. Will impact mobility."
	icon_state = "mod_biohazard"
	worn_icon_state = "mod_biohazard_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, FIRE = 0, ACID = 15)
	slowdown = 0.2

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1 //gas protection
	name = "\improper Mimir Mk.1 environmental resistance system helmet module"
	desc = "Designed for mounting on a modular helmet. This older model provides minor resistance to acid, as well as biological, and radiological threats. Pairing this with a Mimir helmet module and mask will make the user highly resistant to gas attacks, but will not provide immunity. Will impact mobility."
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, FIRE = 0, ACID = 15)

//SOM version
/obj/item/armor_module/module/mimir_environment_protection/som
	name = "\improper Mithridatius hostile environment protection system"
	desc = "Designed for mounting on modular SOM armor. This module appears to be designed to protect the user from the effects of radiological attacks, although it also provides improved resistance against other environmental threats such as acids and gasses. Pairing this with a Mithridatius helmet module and mask will make the user impervious to gas clouds. Will impact mobility."
	icon_state = "mithridatius"
	worn_icon_state = "mithridatius_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 25, FIRE = 0, ACID = 20)

/*
	Explosive defense armor
*/

/obj/item/armor_module/module/hlin_explosive_armor
	name = "\improper Hlin explosive compensation system"
	desc = "Designed for mounting on modular armor. Uses a complex set of armor plating and compensation to lessen the effect of explosions. Will impact mobility"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_boomimmune"
	worn_icon_state = "mod_boomimmune_a"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 40, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/storage/marine/freelancer = "")

/*
	chemical enhancement module
*/

/obj/item/armor_module/module/chemsystem
	name = "\improper Vali chemical enhancement module"
	desc = "Designed for mounting on modular armor. This experimental module runs on green blood taken from xenos with harvester class weapons; Green blood heals the user and boosts any chems in the suit injection system. \nUse the suit menu to connect harvester class weapons, control the injection system, find chem boost information, and more."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_chemsystem"
	worn_icon_state = "mod_chemsystem_a"
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
	. = ..()
	if(chemsystem_is_active)
		icon_state = "mod_chemsystem_active"
		return
	icon_state = initial(icon_state)

/*////////////////////////
	energy shield module
*/////////////////////////

/obj/item/armor_module/module/eshield
	name = "\improper Svalinn energy shield system"
	desc = "A brand new innovation in armor systems, this module creates a shield around the user that is capable of negating all damage at the cost of increased vulnerability to melee, biological, and acid attacks. If it sustains too much damage it will deactivate, and leave the user vulnerable until it recharges."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_eshield"
	worn_icon_state = "mod_eshield_a"
	slot = ATTACHMENT_SLOT_MODULE
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = -5, FIRE = 0, ACID = -5)
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = null, /obj/item/clothing/suit/modular/tdf = "")

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

/obj/item/armor_module/module/eshield/emp_act(severity)
	. = ..()
	if(!isliving(parent.loc))
		return
	var/mob/living/affected = parent.loc
	affected.remove_filter("eshield")

	playsound(src, 'sound/magic/lightningshock.ogg', 50, FALSE)
	spark_system.start()
	shield_health = 0

	STOP_PROCESSING(SSobj, src)
	deltimer(recharge_timer)
	recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown * 3 / severity, TIMER_STOPPABLE)

///Called to give extra info on parent examine.
/obj/item/armor_module/module/eshield/proc/parent_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Recharge Rate: [recharge_rate/2] health per second")
	examine_list += span_notice("Current Shield Health: [shield_health]")
	examine_list += span_notice("Maximum Shield Health: [max_shield_health]")
	if(!recharge_timer)
		return
	examine_list += span_warning("Charging is delayed! It will start recharging again in [timeleft(recharge_timer) / 10] seconds!")

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

/obj/item/armor_module/module/eshield/overclocked
	max_shield_health = 75
	damaged_shield_cooldown = 5 SECONDS
	shield_color_low = COLOR_MAROON
	shield_color_mid = LIGHT_COLOR_RED_ORANGE
	shield_color_full = LIGHT_COLOR_ELECTRIC_CYAN

//original Martian design, donutsteel
/obj/item/armor_module/module/eshield/som
	name = "\improper Aegis energy dispersion system"
	desc = "A sophisticated shielding unit, designed to disperse the energy of incoming impacts, rendering them harmless to the user. If it sustains too much it will deactivate, and leave the user vulnerable. It is unclear if this was a purely  SOM designed module, or whether it was reverse engineered from the TGMC's 'Svalinn' shield system which was developed around the same time."

/obj/item/armor_module/module/eshield/som/overclocked
	max_shield_health = 75
	damaged_shield_cooldown = 5 SECONDS
	shield_color_low = COLOR_MAROON
	shield_color_mid = LIGHT_COLOR_RED_ORANGE
	shield_color_full = LIGHT_COLOR_ELECTRIC_CYAN

/*
	Loki illusion projection
*/

/obj/item/armor_module/module/mirage
	name = "\improper Loki illusion projection system"
	desc = "Designed for mounting on modular armor. This module creates a holographic projection of the user while simultaneously rendering them invisible for a short duration, which can be used to distract enemies and draw their fire."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_illusion"
	worn_icon_state = "mod_illusion_a"
	slowdown = 0
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_MODULE
	toggle_signal = COMSIG_KB_ARMORMODULE
	COOLDOWN_DECLARE(mirage_cooldown)

/obj/item/armor_module/module/mirage/activate(mob/living/user)
	if(!COOLDOWN_FINISHED(src, mirage_cooldown))
		balloon_alert(user, "wait [COOLDOWN_TIMELEFT(src, mirage_cooldown)*0.1] seconds!")
		return
	var/alpha_mod = user.alpha * 0.95
	user.alpha -= alpha_mod
	var/mob/illusion/mirage_nade/fake = new(get_turf(user), user, null, 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_mirage), user, alpha_mod, fake), 15)
	COOLDOWN_START(src, mirage_cooldown, 30 SECONDS)

/// just cleans up the alpha on both the user and the fake
/obj/item/armor_module/module/mirage/proc/end_mirage(mob/user, alpha_mod, mob/illusion/mirage_nade/fake)
	user.alpha += alpha_mod
	fake.alpha = user.alpha


#define ARMORLOCK_DURATION 6 SECONDS
#define ARMORLOCK_SIEMENS_COEFF -0.9
#define ARMORLOCK_PERMEABILITY_COEFF -1
#define ARMORLOCK_GAS_TRANSFER_COEFF -1

/obj/item/armor_module/module/armorlock
	name = "\improper Thor armor lock system"
	desc = "Designed for mounting on modular armor. This module seals gaps in the armor when activated, making the user unable to do any actions but increasing their armor."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_armorlock"
	worn_icon_state = "mod_armorlock_a"
	slowdown = 0.1
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_MODULE
	toggle_signal = COMSIG_KB_ARMORMODULE
	COOLDOWN_DECLARE(armorlock_cooldown)
	///This is the armor amounts we will be adding and removing when armor lock is activated
	var/datum/armor/locked_armor_mod = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)

/obj/item/armor_module/module/armorlock/Initialize(mapload)
	. = ..()
	locked_armor_mod = getArmor(arglist(locked_armor_mod))

/obj/item/armor_module/module/armorlock/Destroy()
	. = ..()
	locked_armor_mod = null

/obj/item/armor_module/module/armorlock/activate(mob/living/user)
	if(!COOLDOWN_FINISHED(src, armorlock_cooldown))
		balloon_alert(user, "wait [COOLDOWN_TIMELEFT(src, armorlock_cooldown)*0.1] seconds!")
		return

	user.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_STOPS_TANK_COLLISION, TRAIT_IMMOBILE, TRAIT_INCAPACITATED), REF(src))
	user.move_resist = MOVE_FORCE_OVERPOWERING
	user.log_message("has been armor locked for [ARMORLOCK_DURATION] ticks", LOG_ATTACK, color="pink")

	var/image/shield_overlay = image('icons/effects/effects.dmi', null, "armorlock")
	user.overlays += shield_overlay
	user.status_flags |= GODMODE
	playsound(user, 'sound/items/armorlock.ogg', 50)


	addtimer(CALLBACK(src, PROC_REF(end_armorlock), user, shield_overlay), ARMORLOCK_DURATION)
	COOLDOWN_START(src, armorlock_cooldown, 45 SECONDS)

///handles cleanup after the lock is finished
/obj/item/armor_module/module/armorlock/proc/end_armorlock(mob/living/user, image/shield_overlay)
	user.overlays -= shield_overlay
	user.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_STOPS_TANK_COLLISION, TRAIT_IMMOBILE, TRAIT_INCAPACITATED), REF(src))
	user.move_resist = initial(user.move_resist)
	user.status_flags &= ~GODMODE

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
	worn_icon_state = "style_light_a"
	soft_armor = MARINE_ARMOR_LIGHT
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/armor_module/module/style/medium_armor
	name = "\improper Medium Armor Equalizer"
	icon_state = "style_medium"
	worn_icon_state = "style_medium_a"
	soft_armor = MARINE_ARMOR_MEDIUM
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/armor_module/module/style/heavy_armor
	name = "\improper Heavy Armor Equalizer"
	icon_state = "style_heavy"
	worn_icon_state = "style_heavy_a"
	soft_armor = MARINE_ARMOR_HEAVY
	slowdown = SLOWDOWN_ARMOR_HEAVY

/**
 *   Helmet Modules
*/
/obj/item/armor_module/module/welding
	name = "\improper HM-3 welding visor helmet module"
	desc = "Designed for mounting on a modular helmet. This module can be toggled on or off to function as welding protection for your delicate eyes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	worn_icon_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	active = FALSE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "welding_head_xn", /obj/item/clothing/head/modular/tdf = "")
	///Mod for extra eye protection when activated.
	var/eye_protection_mod = 2

/obj/item/armor_module/module/welding/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/clothing_tint, TINT_5, active)

/obj/item/armor_module/module/welding/on_detach(obj/item/detaching_from, mob/user)
	detaching_from.remove_component(/datum/component/clothing_tint)
	return ..()

/obj/item/armor_module/module/welding/activate(mob/living/user)
	if(active)
		DISABLE_BITFIELD(parent.inventory_flags, COVEREYES)
		DISABLE_BITFIELD(parent.inv_hide_flags, HIDEEYES)
		DISABLE_BITFIELD(parent.armor_protection_flags, EYES)
		parent.eye_protection -= eye_protection_mod // reset to the users base eye
	else
		ENABLE_BITFIELD(parent.inventory_flags, COVEREYES)
		ENABLE_BITFIELD(parent.inv_hide_flags, HIDEEYES)
		ENABLE_BITFIELD(parent.armor_protection_flags, EYES)
		parent.eye_protection += eye_protection_mod

	active = !active
	SEND_SIGNAL(parent, COMSIG_ITEM_TOGGLE_ACTION, user)
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = base_icon + "[active ? "_active" : ""]"
	worn_icon_state = icon_state + "_a"
	parent.update_icon()
	user.update_inv_head()

/obj/item/armor_module/module/welding/som
	name = "integrated welding visor helmet module"
	desc = "Built in welding module for a SOM engineering helmet. This module can be toggled on or off to function as welding protection for your delicate eyes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head_som"
	worn_icon_state = "welding_head_som_a"
	attach_features_flags = ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB

/obj/item/armor_module/module/welding/superior
	name = "\improper HM-33 superior welding visor helmet module"
	desc = "Designed for mounting on a modular helmet. This more expensive module can be toggled on or off to function as welding protection for your delicate eyes, strangely smells like potatoes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	worn_icon_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	active = FALSE
	prefered_slot = SLOT_HEAD
	variants_by_parent_type = list(/obj/item/clothing/head/modular/m10x = "welding_head_superior_xn", /obj/item/clothing/head/modular/tdf = "")

/obj/item/armor_module/module/welding/superior/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/clothing_tint, TINT_4, active)

/obj/item/armor_module/module/binoculars
	name = "\improper HM-6 binocular helmet module"
	desc = "Designed for mounting on a modular helmet. Can be flipped down to view into the distance."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "binocular_head"
	worn_icon_state = "binocular_head_a"
	active = FALSE
	item_flags = DOES_NOT_NEED_HANDS
	zoom_tile_offset = 11
	zoom_viewsize = 12
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE

/obj/item/armor_module/module/binoculars/activate(mob/living/user)
	if(!(user.client.eye == user) && !(user.client.eye == user.loc))
		to_chat(user, span_warning("You're looking through something else right now."))
		return
	zoom(user)
	if(active == zoom) //Zooming failed for some reason and didn't change
		return
	active = zoom
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = initial(icon_state) + "[active ? "_active" : ""]"
	worn_icon_state = icon_state + "_a"
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
	name = "\improper Freyr Mk.2 visual assistance helmet system"
	desc = "Designed for mounting on a modular helmet. The Freyr module is designed with an overlay visor that clarifies the user's vision, allowing them to see clearly even in the harshest of circumstances. This version is enhanced and allows the marine to peer through the visor, akin to binoculars."
	icon_state = "artemis_head"
	worn_icon_state = "artemis_head_mk2_a"

/obj/item/armor_module/module/binoculars/artemis_mark_two/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/blur_protection)

/obj/item/armor_module/module/artemis
	name = "\improper Freyr Mk.1 visual assistance helmet system"
	desc = "Designed for mounting on a modular helmet. The Freyr module is designed with an overlay visor that clarifies the user's vision, allowing them to see clearly even in the harshest of circumstances."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "artemis_head"
	worn_icon_state = "artemis_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB
	prefered_slot = SLOT_HEAD

/obj/item/armor_module/module/artemis/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/blur_protection)

#define COMMS_OFF 0
#define COMMS_SETTING 1
#define COMMS_SETUP 2

/obj/item/armor_module/module/antenna
	name = "\improper HM-9 antenna helmet module"
	desc = "Designed for mounting on a modular helmet. This module is able to shield against the interference of caves, allowing for normal messaging in shallow caves, and only minor interference when deep."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	worn_icon_state = "antenna_head_a"
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	toggle_signal = COMSIG_KB_HELMETMODULE
	///If the comms system is configured.
	var/comms_setup = FALSE
	///ID of the startup timer
	var/startup_timer_id

/obj/item/armor_module/module/antenna/handle_actions(datum/source, mob/user, slot)
	if(slot != prefered_slot)
		UnregisterSignal(user, COMSIG_CAVE_INTERFERENCE_CHECK)
		comms_setup = COMMS_OFF
		if(startup_timer_id)
			deltimer(startup_timer_id)
			startup_timer_id = null
	else
		RegisterSignal(user, COMSIG_CAVE_INTERFERENCE_CHECK, PROC_REF(on_interference_check))
		start_sync(user)
	return ..()

///Handles interacting with caves checking for if anything is reducing (or increasing) interference.
/obj/item/armor_module/module/antenna/proc/on_interference_check(source, list/inplace_interference)
	SIGNAL_HANDLER
	if(comms_setup != COMMS_SETUP)
		return
	inplace_interference[1] = max(0, inplace_interference[1] - 1)

/obj/item/armor_module/module/antenna/activate(mob/living/user)
	if(comms_setup == COMMS_SETTING)
		to_chat(user, span_notice("Your Antenna module is still in the process of starting up!"))
		return
	if(comms_setup == COMMS_SETUP)
		var/turf/location = get_turf(user)
		user.show_message(span_notice("The [src] beeps and states, \"Uplink data: LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_TYPE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
		return

///Begins the startup sequence.
/obj/item/armor_module/module/antenna/proc/start_sync(mob/living/user)
	if(comms_setup != COMMS_OFF) //Guh?
		return
	to_chat(user, span_notice("Setting up Antenna communication relay. Please wait."))
	comms_setup = COMMS_SETTING
	startup_timer_id = addtimer(CALLBACK(src, PROC_REF(finish_startup), user), ANTENNA_SYNCING_TIME, TIMER_STOPPABLE)

///Finishes startup, rendering the module effective.
/obj/item/armor_module/module/antenna/proc/finish_startup(mob/living/user)
	comms_setup = COMMS_SETUP
	user.show_message(span_notice("[src] beeps twice and states: \"Antenna configuration complete. Relay system active.\""), EMOTE_TYPE_AUDIBLE, span_notice("[src] vibrates twice."))
	startup_timer_id = null


#undef COMMS_OFF
#undef COMMS_SETTING
#undef COMMS_SETUP

/obj/item/armor_module/module/night_vision
	name = "\improper BE-35 night vision kit"
	desc = "Installation kit for the BE-35 night vision system. Slightly impedes movement."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "night_vision"
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_NO_HANDS
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	slowdown = 0.1
	///The goggles this module deploys
	var/obj/item/clothing/glasses/night_vision/mounted/attached_goggles

/obj/item/armor_module/module/night_vision/Initialize(mapload)
	. = ..()
	attached_goggles = new /obj/item/clothing/glasses/night_vision/mounted(src)

/obj/item/armor_module/module/night_vision/examine(mob/user)
	. = ..()
	. += attached_goggles.battery_status()
	. += "To eject the battery, [span_bold("click")] [src] with an empty hand. To insert a battery, [span_bold("click")] [src] with a compatible cell."

///Called when the parent is examined; relays battery info
/obj/item/armor_module/module/night_vision/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += attached_goggles.battery_status()
	examine_text += "To eject the battery, [span_bold("CTRL + SHIFT + left-click")] [src] with an empty hand. To insert a battery, [span_bold("click")] [src] with a compatible cell."

/obj/item/armor_module/module/night_vision/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(on_click))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(deploy))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(undeploy))

/obj/item/armor_module/module/night_vision/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(parent, COMSIG_ITEM_UNEQUIPPED)
	return ..()

///Called when the parent is clicked on with an open hand; to take out the battery
/obj/item/armor_module/module/night_vision/proc/on_click(datum/source, mob/user)
	SIGNAL_HANDLER
	attached_goggles.eject_battery(user)

///Called when the parent is hit by object; to insert a battery
/obj/item/armor_module/module/night_vision/proc/on_attackby(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(attached_goggles.insert_battery(I, user))
		return COMPONENT_NO_AFTERATTACK

/obj/item/armor_module/module/night_vision/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() == src && attached_goggles.eject_battery(user))
		return
	return ..()

/obj/item/armor_module/module/night_vision/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(attached_goggles.insert_battery(I, user))
		return COMPONENT_NO_AFTERATTACK

///Called when the parent is equipped; deploys the goggles
/obj/item/armor_module/module/night_vision/proc/deploy(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!ishuman(user) || prefered_slot != slot)	//Must be human for the following procs to work
		return

	var/mob/living/carbon/human/wearer = user
	if(wearer.glasses && !wearer.dropItemToGround(wearer.glasses))
		//This only happens if the wearer has a head item that can't be dropped
		to_chat(wearer, span_warning("Could not deploy night vision system due to [wearer.head]!"))
		return

	INVOKE_ASYNC(wearer, TYPE_PROC_REF(/mob/living/carbon/human, equip_to_slot), attached_goggles, SLOT_GLASSES)

///Called when the parent is unequipped; undeploys the goggles
/obj/item/armor_module/module/night_vision/proc/undeploy(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	//See if goggles are deployed
	if(attached_goggles.loc == src)
		return

	//The goggles should not be anywhere but on the wearer's face; but if it's not, just yoink it back to the module
	if(attached_goggles.loc == user)
		user.temporarilyRemoveItemFromInventory(attached_goggles, TRUE)
	attached_goggles.forceMove(src)

/obj/item/armor_module/module/night_vision/Destroy()
	QDEL_NULL(attached_goggles)
	return ..()


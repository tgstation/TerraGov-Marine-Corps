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

#define COMMS_OFF 0
#define COMMS_SETTING 1
#define COMMS_SETUP 2

/obj/item/armor_module/module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a modular Helmet. This module is able to shield against the interference of caves, allowing for normal messaging in shallow caves, and only minor interference when deep."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	item_state = "antenna_head_a"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
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
		user.show_message(span_notice("The [src] beeps and states, \"Uplink data: LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
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
	user.show_message(span_notice("[src] beeps twice and states: \"Antenna configuration complete. Relay system active.\""), EMOTE_AUDIBLE, span_notice("[src] vibrates twice."))
	startup_timer_id = null


#undef COMMS_OFF
#undef COMMS_SETTING
#undef COMMS_SETUP

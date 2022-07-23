/**
 ** Modules
 *	These include the helmet and regular armor modules. Basically these are the subtypes of any armor 'system'.
 */
/obj/item/armor_module/module
	name = "broken armor module"
	desc = "You better be debugging."

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
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_lamp_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_lamp_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_lamp_xn")

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
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_autodoc_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_autodoc_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_autodoc_xn")
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


/**
 * Fire poof module
*/
/obj/item/armor_module/module/fire_proof
	name = "\improper Surt Pyrotechnical Insulation System"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	desc = "Designed for mounting on modular armor. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniacs' first stop to survival. Will impact mobility."
	icon_state = "mod_fire"
	item_state = "mod_fire_a"
	hard_armor = list("fire" = 200)
	slowdown = 0.4
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_fire_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_fire_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_fire_xn")

/obj/item/armor_module/module/fire_proof/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/module/fire_proof/on_detach(obj/item/detaching_from, mob/user)
	parent.max_heat_protection_temperature -= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	return ..()


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
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	slowdown = 0.3
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_armor_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_armor_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_armor_xn")

/obj/item/armor_module/module/tyr_extra_armor/mark1
	name = "\improper Mark 1 Tyr Armor Reinforcement"
	desc = "Designed for mounting on modular armor. A substantial amount of additional armor plating designed to grant the user extra protection against threats, ranging from xeno slashes to friendly fire incidents. This older version has worse protection. Will greatly impact mobility."
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.4

/obj/item/armor_module/module/tyr_head
	name = "Tyr Helmet System"
	desc = "Designed for mounting on a modular Helmet. When attached, this system provides substantial resistance to most damaging hazards, ranging from xeno slashes to friendly fire incidents."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "tyr_head"
	item_state = "tyr_head_a"
	soft_armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "tyr_head_xn", /obj/item/clothing/head/modular/marine/m10x/leader = "tyr_head_xn")

/**
 * Environment protecttion module
*/
/obj/item/armor_module/module/mimir_environment_protection
	name = "\improper Mark 2 Mimir Environmental Resistance System"
	desc = "Designed for mounting on modular armor. This newer model provides great resistance to acid, biological, and radiological attacks. Pairing this with a Mimir helmet module and mask will make the user impervious to xeno gas clouds. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_biohazard"
	item_state = "mod_biohazard_a"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_biohazard_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_biohazard_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_biohazard_xn")
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
	soft_armor = list("bio" = 15, "rad" = 10, "acid" = 15)
	slowdown = 0.2

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet
	name = "Mark 2 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a modular helmet. This newer model provides great resistance to acid, biological, and even radiological attacks. Pairing this with a Mimir suit module and mask will make the user impervious to xeno gas clouds."
	icon_state = "mimir_head"
	item_state = "mimir_head_a"
	soft_armor = list("bio" = 40, "rad" = 50, "acid" = 30)
	slowdown = 0
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "mimir_head_xn", /obj/item/clothing/head/modular/marine/m10x/leader = "mimir_head_xn")

/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1 //gas protection
	name = "Mark 1 Mimir Environmental Helmet System"
	desc = "Designed for mounting on a modular helmet. This older model provides minor resistance to acid and biological attacks. Pairing this with a Mimir suit module and mask will make the user impervious to xeno gas clouds."
	soft_armor = list("bio" = 15, "acid" = 15)

//Explosive defense armor
/obj/item/armor_module/module/hlin_explosive_armor
	name = "Hlin Explosive Compensation Module"
	desc = "Designed for mounting on modular armor. Uses a complex set of armor plating and compensation to lessen the effect of explosions. Will impact mobility"
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_boomimmune"
	item_state = "mod_boomimmune_a"
	soft_armor = list("bomb" = 40)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_bombimmune_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_bombimmune_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_bombimmune_xn")

/**
 * Extra armor module
*/
/obj/item/armor_module/module/ballistic_armor
	name = "\improper Hod Accident Prevention Plating"
	desc = "Designed for mounting on modular armor. A substantial amount of additional reflective ballistic armor plating designed to reduce the impact of friendly fire incidents, will lessen the affects of bullets and lasers. Will impact mobility."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_ff"
	item_state = "mod_ff_a"
	soft_armor = list("melee" = 0, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	slowdown = 0.2
	slot = ATTACHMENT_SLOT_MODULE
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_ff_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_ff_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_ff_xn")

/obj/item/armor_module/module/chemsystem
	name = "Vali chemical enhancement module"
	desc = "Designed for mounting on modular armor. This experimental module runs on green blood taken from xenos with harvester class weapons; Green blood heals the user and boosts any chems in the suit injection system. \nUse the suit menu to connect harvester class weapons, control the injection system, find chem boost information, and more."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_chemsystem"
	item_state = "mod_chemsystem_a"
	slot = ATTACHMENT_SLOT_MODULE

/obj/item/armor_module/module/chemsystem/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	parent.AddComponent(/datum/component/chem_booster)

/obj/item/armor_module/module/chemsystem/on_detach(obj/item/detaching_from, mob/user)
	var/datum/component/chem_booster/chemsystem = parent.GetComponent(/datum/component/chem_booster)
	chemsystem.RemoveComponent()
	return ..()


/obj/item/armor_module/module/eshield
	name = "Arrowhead Energy Shield System"
	desc = "A brand new innovation in armor systems, this module creates a shield around the user that is capable of negating all damage. If it sustains too much it will deactivate, and leave the user vulnerable."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_eshield"
	item_state = "mod_eshield_a"
	slot = ATTACHMENT_SLOT_MODULE
	slowdown = 0.3
	soft_armor = list("melee" = -10, "bullet" = -5, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = -5, "rad" = 0, "fire" = 0, "acid" = -5)
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_eshield_xn", /obj/item/clothing/suit/modular/xenonauten/light = "mod_eshield_xn", /obj/item/clothing/suit/modular/xenonauten/heavy = "mod_eshield_xn")

	///Current shield Health
	var/shield_health = 0
	///Maximum shield Health
	var/max_shield_health = 40
	///Amount to recharge per tick, processes once every two seconds.
	var/recharge_rate = 8

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


/obj/item/armor_module/module/eshield/Initialize()
	. = ..()
	spark_system = new()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/armor_module/module/eshield/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/armor_module/module/eshield/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/handle_equip)
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, .proc/handle_unequip)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/parent_examine)


/obj/item/armor_module/module/eshield/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_EQUIPPED, COMSIG_PARENT_EXAMINE))
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

	RegisterSignal(equipper, COMSIG_LIVING_SHIELDCALL, .proc/handle_shield)

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
	affecting_shields += CALLBACK(src, .proc/intercept_damage)

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
				affected.add_filter("eshield", 1, outline_filter(1, shield_color_low))
			if(0.33 to 0.66)
				affected.add_filter("eshield", 1, outline_filter(1, shield_color_mid))
			if(0.66 to 1)
				affected.add_filter("eshield", 1, outline_filter(1, shield_color_full))
		spark_system.start()
	else
		shield_health = 0
		recharge_timer = addtimer(CALLBACK(src, .proc/begin_recharge), damaged_shield_cooldown + 1, TIMER_STOPPABLE) //Gives it a little extra time for the cooldown.
		return -shield_left
	recharge_timer = addtimer(CALLBACK(src, .proc/begin_recharge), damaged_shield_cooldown, TIMER_STOPPABLE)
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
	affected.add_filter("eshield", 1, outline_filter(1, new_color))



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
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "welding_head_xn", /obj/item/clothing/head/modular/marine/m10x/leader = "welding_head_xn")
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	active = FALSE
	prefered_slot = SLOT_HEAD
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

/obj/item/armor_module/module/welding/superior
	name = "Superior Welding Helmet Module"
	desc = "Designed for mounting on a modular helmet. This more expensive module can be toggled on or off to function as welding protection for your delicate eyes, strangely smells like potatoes."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "welding_head"
	item_state = "welding_head_a"
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	variants_by_parent_type = list(/obj/item/clothing/head/modular/marine/m10x = "welding_head_superior_xn", /obj/item/clothing/head/modular/marine/m10x/leader = "welding_head_superior_xn")
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

/obj/item/armor_module/module/binoculars/activate(mob/living/user)
	zoom(user)
	active = !active
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	icon_state = initial(icon_state) + "[active ? "_active" : ""]"
	item_state = icon_state + "_a"
	parent.update_icon()
	user.update_inv_head()
	if(active)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, .proc/zoom_item_turnoff)
		return
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)

/obj/item/armor_module/module/binoculars/zoom_item_turnoff(datum/source, mob/living/user)
	if(isliving(source))
		activate(source)
	else
		activate(user)
	return COMSIG_MOB_CLICK_CANCELED

/obj/item/armor_module/module/antenna
	name = "Antenna helmet module"
	desc = "Designed for mounting on a modular Helmet. This module is able to provide a readout of the user's coordinates and connect to the shipside supply console."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "antenna_head"
	item_state = "antenna_head_a"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/armor_module/module/antenna/activate(mob/living/user)
	var/turf/location = get_turf(src)
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
		QDEL_NULL(beacon_datum)
		user.show_message(span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console"), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
		return
	if(!is_ground_level(user.z))
		to_chat(user, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	beacon_datum = new /datum/supply_beacon(user.name, user.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_PARENT_QDELETING, .proc/clean_beacon_datum)
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))

/// Signal handler to nullify beacon datum
/obj/item/armor_module/module/antenna/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null


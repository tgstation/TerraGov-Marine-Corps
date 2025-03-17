//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "rig-civilian"
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)
	allowed = list(/obj/item/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	heat_protection_flags = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in [user.loc]")
		return
	on = !on

	if(on)
		set_light(brightness_on,brightness_on)
		icon_state = "[initial(icon_state)]_light"
	else
		set_light(0)
		icon_state = initial(icon_state)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	update_action_button_icons()

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-civilian"
	slowdown = 1
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit)
	heat_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

//Engineering rig
/obj/item/clothing/head/helmet/space/rig/engineering
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig-engineering"
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)

/obj/item/clothing/suit/space/rig/engineering
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	slowdown = 1
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/storage/bag/ore,/obj/item/t_scanner,/obj/item/tool/pickaxe, /obj/item/tool/rcd)

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/engineering/chief
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig-white"

/obj/item/clothing/suit/space/rig/engineering/chief
	icon_state = "rig-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig-mining"
	soft_armor = list(MELEE = 50, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 55, BIO = 100, FIRE = 5, ACID = 5)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	soft_armor = list(MELEE = 50, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 55, BIO = 100, FIRE = 5, ACID = 5)
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/suit_cooling_unit,/obj/item/weapon/twohanded/sledgehammer)
	equip_delay_self = 20
	unequip_delay_self = 20

//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig-syndie"
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 35, BIO = 100, FIRE = 15, ACID = 15)
	siemens_coefficient = 0.6


/obj/item/clothing/suit/space/rig/syndi
	icon_state = "rig-syndie"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	slowdown = 1
	w_class = WEIGHT_CLASS_NORMAL
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 35, BIO = 100, FIRE = 15, ACID = 15)
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/weapon/energy/sword,/obj/item/restraints/handcuffs)
	siemens_coefficient = 0.6


//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig-wiz"
	resistance_flags = UNACIDABLE
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 35, BIO = 100, FIRE = 20, ACID = 20)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	slowdown = 1
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = UNACIDABLE
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 35, BIO = 100, FIRE = 20, ACID = 20)
	siemens_coefficient = 0.7

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig-medical"
	soft_armor = list(MELEE = 30, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 25, BIO = 100, FIRE = 5, ACID = 5)

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical)
	soft_armor = list(MELEE = 30, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 25, BIO = 100, FIRE = 5, ACID = 5)

	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig-sec"
	soft_armor = list(MELEE = 60, BULLET = 10, LASER = 30, ENERGY = 5, BOMB = 45, BIO = 100, FIRE = 5, ACID = 5)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	soft_armor = list(MELEE = 60, BULLET = 10, LASER = 30, ENERGY = 5, BOMB = 45, BIO = 100, FIRE = 5, ACID = 5)
	allowed = list(/obj/item/weapon/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/weapon/baton)
	siemens_coefficient = 0.7


//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig-atmos"
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	soft_armor = list(MELEE = 40, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 5, ACID = 5)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

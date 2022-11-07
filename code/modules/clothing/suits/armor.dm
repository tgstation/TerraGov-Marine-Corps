
/obj/item/clothing/suit/armor
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = CHEST|GROIN
	flags_cold_protection = CHEST|GROIN
	flags_heat_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6
	w_class = WEIGHT_CLASS_HUGE
	allowed = list(/obj/item/weapon/gun)//Guns only.


/obj/item/clothing/suit/armor/mob_can_equip(mob/M, slot, disable_warning)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M
	if(!H.w_uniform)
		to_chat(H, span_warning("You need to be wearing somethng under this to be able to equip it."))
		return FALSE



//armored vest

/obj/item/clothing/suit/armor/vest
	name = "armored vest"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	permeability_coefficient = 0.8
	flags_armor_protection = CHEST
	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 10, BOMB = 15, BIO = 0, FIRE = 10, ACID = 10)
	allowed = list (
		/obj/item/flashlight,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/holster/blade
	)


/obj/item/clothing/suit/armor/vest/dutch
	name = "armored jacket"
	desc = "It's hot in the jungle. Sometimes it's hot and heavy, and sometimes it's hell on earth."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "dutch_armor"
	flags_armor_protection = CHEST|GROIN

/obj/item/clothing/suit/armor/vest/admiral
	name = "admiral's jacket"
	desc = "An armoured jacket with gold regalia"
	icon_state = "admiral_jacket"
	item_state = "admiral_jacket"
	flags_armor_protection = CHEST|GROIN|ARMS
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armorsec"
	item_state = "armorsec"
	slowdown = SLOWDOWN_ARMOR_MEDIUM //prevents powergaming marine by swapping armor.

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's jacket"
	desc = "An armoured jacket with silver rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "warden_jacket"
	flags_armor_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 80, ENERGY = 50, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "bulletproof"
	blood_overlay_type = "armor"
	flags_armor_protection = CHEST
	soft_armor = list(MELEE = 30, BULLET = 55, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 0, ACID = 15)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 5)
	siemens_coefficient = 0.7
	permeability_coefficient = 0.9
	time_to_unequip = 20
	time_to_equip = 20
	allowed = list(
		/obj/item/weapon/gun/,
		/obj/item/flashlight,
		/obj/item/storage/holster/blade,
		/obj/item/storage/belt/gun/pistol/m4a3,
		/obj/item/storage/belt/gun/m44,
	)

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	slowdown = 1.2
	soft_armor = list(MELEE = 65, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 10, ACID = 10)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEJUMPSUIT
	flags_item = SYNTH_RESTRICTED
	siemens_coefficient = 0.5
	permeability_coefficient = 0.7
	time_to_unequip = 20
	time_to_equip = 20

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	item_state = "swat"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
	slowdown = 1
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, FIRE = 25, ACID = 25)
	flags_inventory = BLOCKSHARPOBJ|NOPRESSUREDMAGE
	flags_item = SYNTH_RESTRICTED
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6


/obj/item/clothing/suit/armor/swat/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = CHEST|ARMS


/obj/item/clothing/suit/armor/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "detective-armor"
	blood_overlay_type = "armor"
	flags_armor_protection = CHEST|GROIN
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 50, BULLET = 15, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 10, ACID = 10)


//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "Reactive Shield Armor"
	desc = "Highly experimental armor. Do not use outside of controlled lab conditions."
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	slowdown = 1
	flags_atom = CONDUCT
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/reactive/Initialize()
	. = ..()
	AddComponent(/datum/component/shield/overhealth)

/obj/item/clothing/suit/armor/reactive/red
	shield_state = "shield-red"

/obj/item/clothing/suit/armor/rugged
	name = "rugged armor"
	desc = "A suit of armor used by workers in dangerous environments."
	icon_state = "swatarmor"
	item_state = "swatarmor"
	var/obj/item/weapon/gun/holstered = null
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_item = SYNTH_RESTRICTED
	slowdown = 0
	soft_armor = list(MELEE = 50, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 50, BIO = 40, FIRE = 50, ACID = 50)
	siemens_coefficient = 0.7


/obj/item/clothing/suit/armor/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = NODROP|DELONDROP
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 40, BIO = 40, FIRE = 40, ACID = 40)
	allowed = list()//how would you put a gun onto a field of energy?

/obj/item/clothing/suit/armor/sectoid/shield
	name = "powerful psionic field"
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 40, BIO = 40, FIRE = 40, ACID = 40)

/obj/item/clothing/suit/armor/sectoid/shield/Initialize()
	. = ..()
	AddComponent(/datum/component/shield/overhealth)


//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcom
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
	flags_inventory = NONE
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.90
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/tdome
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/armor/tdome/red
	name = "Thunderdome suit (red)"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tdome/green
	name = "Thunderdome suit (green)"
	desc = "Pukish armor."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tactical
	name = "tactical armor"
	desc = "A suit of armor most often used by Special Weapons and Tactics squads. Includes padded vest with pockets along with shoulder and kneeguards."
	icon_state = "swatarmor"
	item_state = "swatarmor"
	var/obj/item/weapon/gun/holstered = null
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_item = SYNTH_RESTRICTED
	slowdown = 1
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 40, BOMB = 20, BIO = 0, FIRE = 40, ACID = 40)
	siemens_coefficient = 0.7


/obj/item/clothing/suit/armor/tactical/verb/holster()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.stat) return

	if(!holstered)
		if(!istype(usr.get_active_held_item(), /obj/item/weapon/gun))
			to_chat(usr, span_notice("You need your gun equiped to holster it."))
			return
		var/obj/item/weapon/gun/W = usr.get_active_held_item()
		if (W.w_class > 3)
			to_chat(usr, span_warning("This gun won't fit in \the belt!"))
			return
		holstered = usr.get_active_held_item()
		usr.drop_held_item()
		holstered.loc = src
		usr.visible_message(span_notice(" \The [usr] holsters \the [holstered]."), "You holster \the [holstered].")
	else
		if(istype(usr.get_active_held_item(),/obj) && istype(usr.get_inactive_held_item(),/obj))
			to_chat(usr, span_warning("You need an empty hand to draw the gun!"))
		else
			if(usr.a_intent == INTENT_HARM)
				usr.visible_message(span_warning(" \The [usr] draws \the [holstered], ready to shoot!"), \
				span_warning(" You draw \the [holstered], ready to shoot!"))
			else
				usr.visible_message(span_notice(" \The [usr] draws \the [holstered], pointing it at the ground."), \
				span_notice(" You draw \the [holstered], pointing it at the ground."))
			usr.put_in_hands(holstered)
		holstered = null

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A set of armor worn by members of the NanoTrasen Emergency Response Team."
	icon_state = "ertarmor_cmd"
	item_state = "ertarmor_cmd"
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 40, BOMB = 20, BIO = 0, FIRE = 40, ACID = 40)

//Captain
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A set of armor worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A set of armor worn by security members of the NanoTrasen Emergency Response Team. Has red highlights."
	icon_state = "ertarmor_sec"
	item_state = "ertarmor_sec"

//Engineer
/obj/item/clothing/suit/armor/vest/ert/engineer
	name = "emergency response team engineer armor"
	desc = "A set of armor worn by engineering members of the NanoTrasen Emergency Response Team. Has orange highlights."
	icon_state = "ertarmor_eng"
	item_state = "ertarmor_eng"

//Medical
/obj/item/clothing/suit/armor/vest/ert/medical
	name = "emergency response team medical armor"
	desc = "A set of armor worn by medical members of the NanoTrasen Emergency Response Team. Has red and white highlights."
	icon_state = "ertarmor_med"
	item_state = "ertarmor_med"


/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 65, BULLET = 30, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 10, ACID = 10)
	flags_inventory = NONE
	flags_inv_hide = HIDEJUMPSUIT
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	flags_inv_hide = NONE
	siemens_coefficient = 0.6
	flags_armor_protection = CHEST|ARMS


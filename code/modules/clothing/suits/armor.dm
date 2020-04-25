
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
		to_chat(H, "<span class='warning'>You need to be wearing somethng under this to be able to equip it.</span>")
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
	armor = list("melee" = 20, "bullet" = 30, "laser" = 25, "energy" = 10, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)

/obj/item/clothing/suit/armor/vest/pilot
	name = "\improper M70 flak jacket"
	desc = "A flak jacket used by dropship pilots to protect themselves while flying in the cockpit. Excels in protecting the wearer against high-velocity solid projectiles."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "pilot"
	sprite_sheet_id = 1
	blood_overlay_type = "armor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	armor = list("melee" = 35, "bullet" = 45, "laser" = 45, "energy" = 20, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 25)
	slowdown = 0.25
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun/m4a3,
		/obj/item/storage/belt/gun/m44)

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
	armor = list("melee" = 10, "bullet" = 10, "laser" = 80, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "bulletproof"
	blood_overlay_type = "armor"
	flags_armor_protection = CHEST
	armor = list("melee" = 20, "bullet" = 50, "laser" = 25, "energy" = 10, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	siemens_coefficient = 0.7
	permeability_coefficient = 0.9
	time_to_unequip = 20
	time_to_equip = 20

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	slowdown = SLOWDOWN_ARMOR_HEAVY
	armor = list("melee" = 80, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEJUMPSUIT
	siemens_coefficient = 0.5
	permeability_coefficient = 0.7
	time_to_unequip = 20
	time_to_equip = 20

/obj/item/clothing/suit/armor/riot/marine
	name = "\improper M5 riot control armor"
	desc = "A heavily modified suit of M2 MP Armor used to supress riots from buckethead marines. Slows you down a lot."
	icon_state = "riot"
	item_state = "swat"
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	armor = list("melee" = 70, "bullet" = 70, "laser" = 35, "energy" = 20, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)

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
	armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 25, "acid" = 25)
	flags_inventory = BLOCKSHARPOBJ|NOPRESSUREDMAGE
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
	armor = list("melee" = 50, "bullet" = 15, "laser" = 50, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)


//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "Reactive Shield Armor"
	desc = "Highly experimental armor. Do not use outside of controlled lab conditions."
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	slowdown = 1
	flags_atom = CONDUCT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

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
	slowdown = 0
	armor = list("melee" = 50, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	siemens_coefficient = 0.7


/obj/item/clothing/suit/armor/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = NODROP|DELONDROP
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 55, "bullet" = 55, "laser" = 35, "energy" = 20, "bomb" = 40, "bio" = 40, "rad" = 10, "fire" = 40, "acid" = 40)
	allowed = list()//how would you put a gun onto a field of energy?

/obj/item/clothing/suit/armor/sectoid/shield
	name = "powerful psionic field"
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 55, "bullet" = 55, "laser" = 35, "energy" = 20, "bomb" = 40, "bio" = 40, "rad" = 10, "fire" = 40, "acid" = 40)

/obj/item/clothing/suit/armor/sectoid/shield/Initialize()
	. = ..()
	AddComponent(/datum/component/shield/overhealth)


//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
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
	slowdown = 1
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 40, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 40)
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
			to_chat(usr, "<span class='notice'>You need your gun equiped to holster it.</span>")
			return
		var/obj/item/weapon/gun/W = usr.get_active_held_item()
		if (W.w_class > 3)
			to_chat(usr, "<span class='warning'>This gun won't fit in \the belt!</span>")
			return
		holstered = usr.get_active_held_item()
		usr.drop_held_item()
		holstered.loc = src
		usr.visible_message("<span class='notice'> \The [usr] holsters \the [holstered].</span>", "You holster \the [holstered].")
	else
		if(istype(usr.get_active_held_item(),/obj) && istype(usr.get_inactive_held_item(),/obj))
			to_chat(usr, "<span class='warning'>You need an empty hand to draw the gun!</span>")
		else
			if(usr.a_intent == INTENT_HARM)
				usr.visible_message("<span class='warning'> \The [usr] draws \the [holstered], ready to shoot!</span>", \
				"<span class='warning'> You draw \the [holstered], ready to shoot!</span>")
			else
				usr.visible_message("<span class='notice'> \The [usr] draws \the [holstered], pointing it at the ground.</span>", \
				"<span class='notice'> You draw \the [holstered], pointing it at the ground.</span>")
			usr.put_in_hands(holstered)
		holstered = null

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A set of armor worn by members of the NanoTrasen Emergency Response Team."
	icon_state = "ertarmor_cmd"
	item_state = "ertarmor_cmd"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 40, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 40)

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
	armor = list("melee" = 65, "bullet" = 30, "laser" = 50, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
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

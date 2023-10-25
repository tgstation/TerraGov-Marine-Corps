// MARINE STORAGE ARMOR


/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard TerraGov Marine Corps M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/obj/clothing/suits/marine_armor.dmi'
	icon_state = ""
	item_state = "armor"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_armor.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	soft_armor = list(MELEE = 40, BULLET = 60, LASER = 60, ENERGY = 45, BOMB = 45, BIO = 45, FIRE = 45, ACID = 50)
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	slowdown = 0.5
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/instrument,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore,
		/obj/item/storage/holster/belt,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
		/obj/item/tool/pickaxe/plasmacutter,
	)
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/list/armor_overlays
	actions_types = list(/datum/action/item_action/toggle/suit_toggle)
	flags_armor_features = ARMOR_LAMP_OVERLAY
	flags_item = SYNTH_RESTRICTED|IMPEDE_JETPACK
	w_class = WEIGHT_CLASS_HUGE
	equip_delay_self = 2 SECONDS
	unequip_delay_self = 2 SECONDS
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/clothing/suit/storage/marine/Initialize(mapload)
	. = ..()
	armor_overlays = list("lamp") //Just one for now, can add more later.
	update_icon()

/obj/item/clothing/suit/storage/marine/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_armor_features & ARMOR_LAMP_OVERLAY)
		I = image(icon, src, flags_armor_features & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else
		armor_overlays["lamp"] = null
	user?.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	if(inhands)
		return
	. = ..()
	var/mutable_appearance/new_overlay
	for(var/i in armor_overlays)
		new_overlay = armor_overlays[i]
		if(new_overlay)
			new_overlay = mutable_appearance(item_icons[slot_wear_suit_str], new_overlay.icon_state)
			standing.overlays += new_overlay

/obj/item/clothing/suit/storage/marine/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot turn the light on while in [user.loc]."))
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ARMOR_LIGHT))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src)
		return
	turn_light(user, !light_on)
	return TRUE

/obj/item/clothing/suit/storage/marine/item_action_slot_check(mob/user, slot)
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_WEAR_SUIT)
		return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/marine/mech_pilot
	name = "\improper PAS-13 pattern mech pilot armor"
	desc = "A somewhat sparsely armored but robust armored vest, still in use despite the rise of exoskeleton armor due to ease of use and manufacturing. While the suit is a bit more encumbering to wear with the mech pilot uniform, it offers the them a degree of protection that they otherwise do not enjoy outside their mech."
	icon_state = "mech_pilot_suit"
	item_state = "mech_pilot_suit"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	soft_armor = list(MELEE = 45, BULLET = 55, LASER = 55, ENERGY = 20, BOMB = 45, BIO = 30, FIRE = 25, ACID = 35)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/riot
	name = "\improper M5 riot control armor"
	desc = "A heavily modified suit of M2 MP Armor used to supress riots from buckethead marines and their guns. Slows you down a lot."
	icon_state = "marine_riot"
	slowdown = 1.3
	soft_armor = list(MELEE = 65, BULLET = 110, LASER = 110, ENERGY = 10, BOMB = 60, BIO = 50, FIRE = 50, ACID = 30)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore,
		/obj/item/storage/holster/belt,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
	)
	flags_item_map_variant = NONE

//===========================SPECIALIST================================


/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nHas an automated diagnostics and medical system for keeping its wearer alive."
	icon_state = "xarmor"
	soft_armor = list(MELEE = 75, BULLET = 80, LASER = 80, ENERGY = 85, BOMB = 85, BIO = 70, FIRE = 85, ACID = 70)
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	supporting_limbs = CHEST | GROIN | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_LEFT | LEG_RIGHT | FOOT_LEFT | FOOT_RIGHT | HEAD //B18 effectively stabilizes these.
	resistance_flags = UNACIDABLE
	obj_flags = AUTOBALANCE_CHECK

/obj/item/clothing/suit/storage/marine/specialist/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/suit_autodoc)
	AddComponent(/datum/component/stun_mitigation, slot_override = SLOT_WEAR_SUIT, shield_cover = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50))
	AddElement(/datum/element/limb_support, supporting_limbs)
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.b18_in_use += src

/obj/item/clothing/suit/storage/marine/specialist/Destroy()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.b18_in_use -= src
	return ..()

/obj/item/clothing/suit/storage/marine/specialist/valhalla
	obj_flags = NONE

/obj/item/clothing/suit/storage/marine/B17
	name = "\improper B17 defensive armor"
	desc = "The older brother of the B18. Practically an armored EOD suit made for use by close quarter explosive experts."
	icon_state = "grenadier"
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 50, ENERGY = 55, BOMB = 100, BIO = 55, FIRE = 75, ACID = 65)
	max_heat_protection_temperature = HEAVYARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	obj_flags = AUTOBALANCE_CHECK

/obj/item/clothing/suit/storage/marine/B17/Initialize(mapload, ...)
	. = ..()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.b17_in_use += src

/obj/item/clothing/suit/storage/marine/B17/Destroy()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.b17_in_use -= src
	return ..()

/obj/item/clothing/suit/storage/marine/B17/valhalla
	obj_flags = NONE

////////////////////////////////

/obj/item/clothing/suit/storage/marine/ship_tech
	name = "\improper PAS-09 pattern technician armor"
	desc = "A somewhat outdated but robust armored vest, still in use despite the rise of exoskeleton armor due to ease of use and manufacturing. It offers more protection against the exotic dangers that technicians face."
	icon_state = "tanker"
	soft_armor = list(MELEE = 40, BULLET = 55, LASER = 60, ENERGY = 45, BOMB = 60, BIO = 45, FIRE = 45, ACID = 65)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/officer
	name = "\improper PAS-N3 pattern officer armor"
	desc = "A well-crafted suit of a Navy Personal Armor System typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field."
	icon_state = "officer"
	soft_armor = list(MELEE = 40, BULLET = 60, LASER = 60, ENERGY = 45, BOMB = 45, BIO = 45, FIRE = 45, ACID = 50)
	slowdown = 0.5
	flags_item_map_variant = NONE
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/hailer,
		/obj/item/storage/holster/blade,
		/obj/item/storage/holster/belt,
	)

/obj/item/clothing/suit/storage/marine/officer/req
	name = "\improper PAS-N2 pattern MA armor"
	desc = "A standard TerraGov Navy N2 Personal Armor System. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"

/*=============================PMCS==================================*/

/obj/item/clothing/suit/storage/marine/veteran
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/ert_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	flags_armor_features = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/marine/veteran/pmc
	name = "\improper M4 pattern PMC armor"
	desc = "A common armor vest that is designed for high-profile security operators and corporate mercenaries in mind."
	icon_state = "pmc_armor"
	soft_armor = list(MELEE = 55, BULLET = 70, LASER = 60, ENERGY = 38, BOMB = 50, BIO = 15, FIRE = 38, ACID = 45)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife,
	)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/veteran/pmc/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the M4 body armor, it is designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_armor"
	soft_armor = list(MELEE = 60, BULLET = 75, LASER = 65, ENERGY = 65, BOMB = 60, BIO = 50, FIRE = 50, ACID = 45)


/obj/item/clothing/suit/storage/marine/veteran/pmc/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon_state = "pmc_sniper"
	soft_armor = list(MELEE = 55, BULLET = 65, LASER = 55, ENERGY = 60, BOMB = 75, BIO = 10, FIRE = 60, ACID = 60)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDELOWHAIR

/obj/item/clothing/suit/storage/marine/veteran/pmc/gunner
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard M4 body armor. Hooked up with harnesses and straps allowing the user to carry a smartgun."
	icon_state = "pmc_heavyarmor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list(MELEE = 65, BULLET = 80, LASER = 70, ENERGY = 70, BOMB = 80, BIO = 30, FIRE = 65, ACID = 65)
	flags_item_map_variant = NONE

/*===========================Death Commando============================*/
/obj/item/clothing/suit/storage/marine/veteran/pmc/commando
	name = "\improper PMC commando armor"
	desc = "A heavily armored suit built by who-knows-what for elite operations. It is a fully self-contained system and is heavily corrosion resistant."
	icon_state = "commando_armor"
	soft_armor = list(MELEE = 90, BULLET = 120, LASER = 200, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	attachments_by_slot = list(ATTACHMENT_SLOT_STORAGE)
	attachments_allowed = list(/obj/item/armor_module/storage/grenade)
	starting_attachments = list(/obj/item/armor_module/storage/grenade)
	supporting_limbs = CHEST | GROIN | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_LEFT | LEG_RIGHT | FOOT_LEFT | FOOT_RIGHT | HEAD //B18 effectively stabilizes these.
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/storage/marine/veteran/pmc/commando/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/suit_autodoc)
	AddElement(/datum/element/limb_support, supporting_limbs)

/*===========================I.o.M================================*/

/obj/item/clothing/suit/storage/marine/imperial
	name = "\improper Imperial Guard flak armour"
	desc = "A cheap, mass produced armour worn by the Imperial Guard, which are also cheap and mass produced. You can make out what appears to be <i>Cadia stands</i> carved into the armour."
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/ert_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "guardarmor"
	soft_armor = list(MELEE = 75, BULLET = 65, LASER = 60, ENERGY = 60, BOMB = 50, BIO = 0, FIRE = 60, ACID = 60)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/imperial/sergeant
	// SL armour, better than flak, covers more
	name = "\improper Imperial Guard sergeant armour"
	desc = "A body armour that offers much better protection than the flak armour."
	icon_state = "guardSLarmor"
	soft_armor = list(MELEE = 85, BULLET = 85, LASER = 85, ENERGY = 85, BOMB = 85, BIO = 25, FIRE = 85, ACID = 85)
	light_range = 6 // better light

/obj/item/clothing/suit/storage/marine/imperial/medicae
	name = "\improper Imperial Guard medicae armour"
	desc = "An armour worn by the medicae of the Imperial Guard."
	icon_state = "guardmedicarmor"

/obj/item/clothing/suit/storage/marine/imperial/sergeant/veteran
	name = "\improper Imperial Guard carapace armour"
	desc = "A heavy full body armour that protects the wearer a lot more than the flak armour, also slows down considerably."
	icon_state = "guardvetarmor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list(MELEE = 90, BULLET = 90, LASER = 90, ENERGY = 90, BOMB = 90, BIO = 30, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/storage/marine/imperial/power
	// Should this maybe require recharging?
	name = "\improper salvaged Space Marine power armour"
	desc = "A power armour that was once broken, is functional once again. However this version isn't as powerful as the real power armour."
	//icon_state
	soft_armor = list(MELEE = 75, BULLET = 60, LASER = 55, ENERGY = 40, BOMB = 45, BIO = 15, FIRE = 40, ACID = 40)
	light_range = 6

/obj/item/clothing/suit/storage/marine/imperial/commissar
	name = "\improper commissar coat"
	desc = "A armored coat worn by commissars of the Imperial Army."
	icon_state = "commissar_coat"
	item_state = "commissar_coat"
	soft_armor = list(MELEE = 75, BULLET = 60, LASER = 55, ENERGY = 40, BOMB = 45, BIO = 15, FIRE = 40, ACID = 40)

/*===========================U.S.L================================*/

/obj/item/clothing/suit/storage/faction
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/ert_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	soft_armor = list(MELEE = 50, BULLET = 40, LASER = 35, ENERGY = 20, BOMB = 25, BIO = 10, FIRE = 20, ACID = 20)
	siemens_coefficient = 0.7
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/twohanded,
	)
	flags_armor_features = ARMOR_LAMP_OVERLAY
	flags_item = SYNTH_RESTRICTED
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/armor_overlays["lamp"]
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/suit/storage/faction/Initialize(mapload, ...)
	. = ..()
	armor_overlays = list("lamp")
	update_icon()

/obj/item/clothing/suit/storage/faction/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_armor_features & ARMOR_LAMP_OVERLAY)
		I = image(icon, src, flags_armor_features & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()


/obj/item/clothing/suit/storage/faction/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot turn the light on while in [user.loc]."))
		return

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ARMOR_LIGHT))
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src) return

	turn_light(user, !light_on)
	return 1

/obj/item/clothing/suit/storage/faction/item_action_slot_check(mob/user, slot)
	if(!ishuman(user)) return FALSE
	if(slot != SLOT_WEAR_SUIT) return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/faction/UPP
	name = "\improper UM5 personal armor"
	desc = "Standard body armor of the USL pirates, the UM5 (United Medium MK5) is a medium body armor, roughly on par with the venerable M3 pattern body armor in service with the TGMC."
	icon_state = "upp_armor"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list(MELEE = 55, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 55, BIO = 10, FIRE = 60, ACID = 60)

/// Modified version of the armor for HvH combat. Stats are based on medium armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/hvh
	soft_armor = list(MELEE = 55, BULLET = 75, LASER = 75, ENERGY = 60, BOMB = 60, BIO = 45, FIRE = 60, ACID = 65)


/obj/item/clothing/suit/storage/faction/UPP/commando
	name = "\improper UM5CU personal armor"
	desc = "A modification of the UM5, designed for stealth operations."
	icon_state = "upp_armor_commando"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/// Modified version of the armor for HvH combat. Stats are based on medium armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/commando/hvh
	soft_armor = list(MELEE = 55, BULLET = 75, LASER = 75, ENERGY = 60, BOMB = 60, BIO = 45, FIRE = 60, ACID = 65)

/obj/item/clothing/suit/storage/faction/UPP/heavy
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the USL pirates, the UH7 (United Heavy MK7) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 60, BOMB = 60, BIO = 10, FIRE = 60, ACID = 60)

/// Modified version of the armor for HvH combat. Stats are based on heavy armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/heavy/hvh
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 65, BOMB = 60, BIO = 60, FIRE = 60, ACID = 70)

/obj/item/clothing/suit/storage/marine/smartgunner/UPP
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the USL pirates, the UH7 (United Heavy MK7) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 60, BOMB = 60, BIO = 10, FIRE = 60, ACID = 60)

/// Modified version of the armor for HvH combat. Stats are based on heavy armor, with tyr mark 2.
/obj/item/clothing/suit/storage/marine/smartgunner/UPP/hvh
	soft_armor = list(MELEE = 60, BULLET = 80, LASER = 80, ENERGY = 65, BOMB = 60, BIO = 60, FIRE = 60, ACID = 70)

//===========================FREELANCER================================

/obj/item/clothing/suit/storage/faction/freelancer
	name = "\improper freelancer cuirass"
	desc = "A armored protective chestplate scrapped together from various plates. It keeps up remarkably well, as the craftsmanship is solid, and the design mirrors such armors in the UPP and the TGMC."
	icon_state = "freelancer_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 40, BIO = 10, FIRE = 60, ACID = 50)
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_MODULE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/storage/faction/freelancer/leader
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_MODULE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer,
	)

/obj/item/clothing/suit/storage/faction/freelancer/leader/two
	attachments_allowed = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer_two,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer_two,
	)

/obj/item/clothing/suit/storage/faction/freelancer/leader/three
	attachments_allowed = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer_three,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/ammo_mag/freelancer_three,
	)

/obj/item/clothing/suit/storage/faction/freelancer/medic
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_MODULE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical/freelancer,
	)
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical/freelancer,
	)



//this one is for CLF
/obj/item/clothing/suit/storage/faction/militia
	name = "\improper colonial militia hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. "
	icon_state = "rebel_armor"
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 30, BOMB = 60, BIO = 30, FIRE = 30, ACID = 30)
	allowed = list(
		/obj/item/weapon/twohanded,
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/baseballbat,
	)
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	blood_overlay_type = "coat"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	allowed = list(
		/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
		/obj/item/storage/holster/belt,
	)

/obj/item/clothing/suit/storage/RO
	name = "\improper RO jacket"
	desc = "A green jacket worn by TGMC personnel. The back has the flag of the TerraGov on it."
	icon_state = "RO_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS

/*===========================HELGHAST - MERCENARY================================*/

/obj/item/clothing/suit/storage/marine/veteran/mercenary
	name = "\improper K12 ceramic plated armor"
	desc = "A set of grey, heavy ceramic armor with dark blue highlights. It is the standard uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_heavy_armor"
	soft_armor = list(MELEE = 75, BULLET = 62, LASER = 42, ENERGY = 38, BOMB = 40, BIO = 15, FIRE = 38, ACID = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife,
	)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner
	name = "\improper Y8 armored miner vest"
	desc = "A set of beige, light armor built for protection while mining. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_miner_armor"
	soft_armor = list(MELEE = 50, BULLET = 42, LASER = 42, ENERGY = 38, BOMB = 25, BIO = 15, FIRE = 38, ACID = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife,
	)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer
	name = "\improper Z7 armored engineer vest"
	desc = "A set of blue armor with yellow highlights built for protection while building in highly dangerous environments. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_engineer_armor"
	soft_armor = list(MELEE = 55, BULLET = 52, LASER = 42, ENERGY = 38, BOMB = 30, BIO = 15, FIRE = 38, ACID = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife,
	)

/obj/item/clothing/suit/storage/marine/som
	name = "\improper S12 hauberk"
	desc = "A heavily modified piece of mining equipment remade for general purpose combat use. It's light but practically gives no armor."
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/ert_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "som_armor"
	item_state = "som_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 55, BIO = 55, FIRE = 55, ACID = 55)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/som/veteran
	name = "\improper S12 combat Hauberk"
	desc = "A heavily modified piece of mining equipment remade for general purpose combat use. Seems to have been modifed much further than other pieces like it. Heavier but tougher because of it."
	icon_state = "som_armor_veteran"
	item_state = "som_armor_veteran"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list(MELEE = 65, BULLET = 70, LASER = 70, ENERGY = 55, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/suit/storage/marine/som/leader
	name = "\improper S13 leader hauberk"
	desc = "A heavily modified modified piece of mining equipment remade for general purpose combat use. Modified extensively than other pieces like it but heavier because of it."
	icon_state = "som_armor_leader"
	item_state = "som_armor_leader"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list(MELEE = 55, BULLET = 50, LASER = 40, ENERGY = 55, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/suit/storage/marine/icc
	name = "\improper Modelle/16 combat armor"
	desc = "A piece of ICC body armor, worn durning boarding actions by personnel in close quarters, as most ICC personnel serve dual purpose roles as ad-hoc marines, due to personnel shortages. Protects well from most sources, particularly explosions."
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/ert_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "icc"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 70, BIO = 10, FIRE = 60, ACID = 50)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/icc/guard
	name = "\improper Modelle/19 combat armor"
	desc = "A piece of ICCGF body armor, worn by specialized infantry. Most Infantry actions in the ICC forces are done by adhoc personnel due to constant shortages of manpower, however most real Infantry divisions are of high quality, and are better known as 'Guardsmen'.  Protects well from most sources, and will entirely protect from explosions."
	icon_state = "icc_guard"
	soft_armor = list(MELEE = 60, BULLET = 65, LASER = 40, ENERGY = 60, BOMB = 85, BIO = 10, FIRE = 55, ACID = 40)

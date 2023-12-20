
/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	item_state = "helmet"
	accuracy_mod = 0
	soft_armor = list(MELEE = 50, BULLET = 15, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 0, FIRE = 10, ACID = 10)
	flags_atom = CONDUCT
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	flags_cold_protection = HEAD
	flags_heat_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	w_class = WEIGHT_CLASS_NORMAL
	flags_armor_features = ARMOR_NO_DECAP
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks. It covers your ears."
	icon_state = "riot"
	soft_armor = list(MELEE = 82, BULLET = 15, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 2, FIRE = 5, ACID = 5)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDETOPHAIR
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/helmet/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	soft_armor = list(MELEE = 80, BULLET = 60, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEARS
	flags_armor_protection = NONE
	siemens_coefficient = 0.8
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/helmet/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = NONE

/obj/item/clothing/head/helmet/hop
	name = "crew resource's hat"
	desc = "A stylish hat that both protects you from enraged former-crewmembers and gives you a false sense of authority."
	icon_state = "hopcap"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = NONE

/obj/item/clothing/head/helmet/formalcaptain
	name = "parade hat"
	desc = "No one in a commanding position should be without a perfect, white hat of ultimate authority."
	icon_state = "officercap"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = NONE

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	item_state = "swat"
	soft_armor = list(MELEE = 80, BULLET = 60, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 10, FIRE = 25, ACID = 25)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	anti_hug = 1
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	item_state = "thunderdome"
	soft_armor = list(MELEE = 80, BULLET = 60, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	item_state = "gladiator"
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEALLHAIR
	siemens_coefficient = 1

/*===========================MARINES HELMETS=================================
=======================================================================*/


/obj/item/clothing/head/helmet/marine
	name = "\improper M10 pattern marine helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/obj/clothing/headwear/marine_helmets.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/marine_helmets.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "helmet"
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	max_integrity = 5
	var/list/helmet_overlays
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS
	attachments_by_slot = list(
		ATTACHMENT_SLOT_STORAGE,
	)
	attachments_allowed = list(
		/obj/item/armor_module/storage/helmet,
	)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	///marine helmet behaviour flags
	var/flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_STORE_GARB
	/// items that fit in the helmet: strict type = iconstate to show
	var/static/list/allowed_helmet_items = list(
		/obj/item/tool/lighter/random = "helmet_lighter_",
		/obj/item/tool/lighter/zippo = "helmet_lighter_zippo",
		/obj/item/storage/box/matches = "helmet_matches",
		/obj/item/storage/fancy/cigarettes = "helmet_cig_kpack",
		/obj/item/storage/fancy/cigarettes/kpack = "helmet_cig_kpack",
		/obj/item/storage/fancy/cigarettes/luckystars = "helmet_cig_ls",
		/obj/item/storage/fancy/cigarettes/dromedaryco = "helmet_cig_kpack",
		/obj/item/storage/fancy/cigarettes/lady_finger = "helmet_cig_lf",
		/obj/item/toy/deck = "helmet_card_card",
		/obj/item/toy/handcard = "helmet_card_card",
		/obj/item/reagent_containers/food/drinks/flask/marine = "helmet_canteen",
		/obj/item/reagent_containers/food/snacks/enrg_bar = "helmet_snack_eat",
		/obj/item/reagent_containers/food/snacks/packaged_burrito = "helmet_snack_burrito",
		/obj/item/clothing/glasses/mgoggles = "goggles",
		/obj/item/clothing/glasses/mgoggles/prescription = "goggles",
		/obj/item/clothing/glasses/hud/medgoggles = "goggles",
		/obj/item/clothing/glasses/hud/medgoggles/prescription = "goggles",
		/obj/item/clothing/glasses/night/optgoggles = "optgoggles",
		/obj/item/clothing/glasses/night/optgoggles/prescription = "optgoggles",
		/obj/item/clothing/glasses/meson/enggoggles = "enggoggles",
		/obj/item/clothing/glasses/meson/enggoggles/prescription = "enggoggles",
		/obj/item/clothing/head/hairflower = "flower_pin",
	)

/obj/item/clothing/head/helmet/marine/Initialize(mapload)
	. = ..()
	helmet_overlays = list("damage","band","item") //To make things simple.

/obj/item/clothing/head/helmet/marine/update_icon()
	if(!attachments_by_slot[ATTACHMENT_SLOT_STORAGE])
		return
	if(!istype(attachments_by_slot[ATTACHMENT_SLOT_STORAGE], /obj/item/armor_module/storage))
		return
	var/obj/item/armor_module/storage/armor_storage = attachments_by_slot[ATTACHMENT_SLOT_STORAGE]

	if(length(armor_storage.storage.contents) && (flags_marine_helmet & HELMET_GARB_OVERLAY))
		if(!helmet_overlays["band"])
			var/image/I = image('icons/obj/clothing/headwear/marine_hats.dmi', src, "helmet_band")
			helmet_overlays["band"] = I

		if(!helmet_overlays["item"])
			var/obj/O = armor_storage.storage.contents[1]
			if(O.type in allowed_helmet_items)
				var/image/I = image('icons/obj/clothing/headwear/marine_hats.dmi', src, "[allowed_helmet_items[O.type]][O.type == /obj/item/tool/lighter/random ? O:clr : ""]")
				helmet_overlays["item"] = I

	else
		if(helmet_overlays["item"])
			var/image/RI = helmet_overlays["item"]
			helmet_overlays["item"] = null
			qdel(RI)
		if(helmet_overlays["band"])
			var/image/J = helmet_overlays["band"]
			helmet_overlays["band"] = null
			qdel(J)

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()

/obj/item/clothing/head/helmet/marine/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	if(inhands)
		return
	. = ..()
	var/mutable_appearance/M
	for(var/i in helmet_overlays)
		M = helmet_overlays[i]
		if(M)
			M = mutable_appearance('icons/mob/modular/modular_helmet_storage.dmi',M.icon_state)
			standing.overlays += M

/obj/item/clothing/head/helmet/marine/specialist
	name = "\improper B18 helmet"
	desc = "The B18 Helmet that goes along with the B18 Defensive Armor. It's heavy, reinforced, and protects more of the face."
	icon_state = "minigunner_helmet"
	soft_armor = list(MELEE = 75, BULLET = 80, LASER = 75, ENERGY = 65, BOMB = 70, BIO = 65, FIRE = 65, ACID = 65)
	flags_inv_hide = HIDEALLHAIR|HIDEEARS
	flags_item = SYNTH_RESTRICTED
	resistance_flags = UNACIDABLE
	anti_hug = 6
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)

/obj/item/clothing/head/helmet/marine/grenadier
	name = "\improper B17 helmet"
	desc = "A heavy duty helmet created to complement the B17 marine armor. Practically explosive proof. Unless you stand next to a nuke or something like that."
	icon_state = "grenadier_helmet"
	soft_armor = list(MELEE = 75, BULLET = 70, LASER = 60, ENERGY = 65, BOMB = 100, BIO = 60, FIRE = 65, ACID = 60)
	flags_inv_hide = HIDEALLHAIR|HIDEEARS
	max_heat_protection_temperature = HEAVYARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	resistance_flags = UNACIDABLE
	flags_item = SYNTH_RESTRICTED
	anti_hug = 4
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT|ITEM_ICE_PROTECTION)

/obj/item/clothing/head/helmet/marine/pilot
	name = "\improper M30 tactical helmet"
	desc = "The M30 tactical helmet has an left eyepiece filter used to filter tactical data. It is used by pilots in the TGN. This one is in gunmetal blue."
	icon_state = "helmetp2"
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR
	flags_marine_helmet = NONE
	flags_item_map_variant = null

/obj/item/clothing/head/helmet/marine/pilot/green
	name = "\improper M30 tactical helmet"
	desc = "The M30 tactical helmet has an left eyepiece filter used to filter tactical data. It is used by pilots in the TGN. This one is in green."
	icon_state = "helmetp"

/obj/item/clothing/head/helmet/marine/mech_pilot
	name = "\improper M12C pattern neurolink helmet"
	icon_state = "mech_pilot_helmet"
	desc = "A lightweight helmet with a small port in the back. Offers lower response times for TGMC mech pilots by integrating them directly into their mech suit's systems, though it certainly doesn't make them smarter."
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/riot
	name = "M8 riot helmet"
	desc = "It's a modified version of the widely used Riot Helmets for use against angry jarheads. Boasts high ballistic protection"
	icon_state = "marine_riot"
	soft_armor = list(MELEE = 65, BULLET = 110, LASER = 110, ENERGY = 5, BOMB = 50, BIO = 50, FIRE = 50, ACID = 30)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDETOPHAIR
	flags_item = SYNTH_RESTRICTED

/*=============================PMCS==================================
=======================================================================*/

/obj/item/clothing/head/helmet/marine/veteran
	icon = 'icons/obj/clothing/headwear/ert_headwear.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/helmet/marine/veteran/pmc
	name = "\improper PMC tactical helmet"
	desc = "A protective helmet made from flexible aramid materials. Standard issue protection for a lot of security firms."
	icon_state = "pmc_helmet"
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 60, ENERGY = 55, BOMB = 60, BIO = 50, FIRE = 55, ACID = 55)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NONE
	flags_marine_helmet = NONE

/obj/item/clothing/head/helmet/marine/veteran/pmc/leader
	name = "\improper PMC beret"
	desc = "The pinacle of fashion for any aspiring mercenary leader. Designed to protect the head from light impacts."
	icon_state = "officer_hat"
	soft_armor = list(MELEE = 70, BULLET = 70, LASER = 65, ENERGY = 55, BOMB = 60, BIO = 50, FIRE = 55, ACID = 60)

/obj/item/clothing/head/helmet/marine/veteran/pmc/sniper
	name = "\improper PMC sniper helmet"
	desc = "A helmet worn by PMC Marksmen"
	icon_state = "pmc_sniper_hat"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 65, BULLET = 75, LASER = 55, ENERGY = 60, BOMB = 70, BIO = 50, FIRE = 60, ACID = 60)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR

/obj/item/clothing/head/helmet/marine/veteran/pmc/gunner
	name = "\improper PMC gunner helmet"
	desc = "A modification of the standard helmet used by a lot of security firms, has a visor for added protection."
	icon_state = "pmc_heavyhelmet"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 75, BULLET = 85, LASER = 80, ENERGY = 65, BOMB = 80, BIO = 50, FIRE = 65, ACID = 65)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR

/obj/item/clothing/head/helmet/marine/veteran/pmc/commando
	name = "\improper PMC commando helmet"
	desc = "A fully enclosed, armored helmet made for Nanotrasen elite commandos."
	icon_state = "commando_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 95, BULLET = 120, LASER = 200, ENERGY = 200, BOMB = 90, BIO = 100, FIRE = 90, ACID = 95)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	eye_protection = 2
	anti_hug = 50
	resistance_flags = UNACIDABLE

/*==========================DISTRESS=================================
=======================================================================*/

/*=========================Imperium==================================*/

/obj/item/clothing/head/helmet/marine/imperial
	name = "\improper Imperial Guard flak helmet"
	desc = "A standard Imperial Guard helmet that goes with the flak armour, it is also mass produced, and it can save your life, maybe."
	icon = 'icons/obj/clothing/headwear/ert_headwear.dmi'
	icon_state = "guardhelm"
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	item_state = "guardhelm"
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 85, BULLET = 75, LASER = 70, ENERGY = 70, BOMB = 60, BIO = 50, FIRE = 50, ACID = 50)

/obj/item/clothing/head/helmet/marine/imperial/sergeant
	name = "\improper Imperial Guard sergeant helmet"
	desc = "A helmet that goes with the sergeant armour, unlike the flak variant, this one will actually protect you."
	icon_state = "guardhelm"
	soft_armor = list(MELEE = 85, BULLET = 85, LASER = 85, ENERGY = 85, BOMB = 85, BIO = 50, FIRE = 80, ACID = 80)

/obj/item/clothing/head/helmet/marine/imperial/sergeant/veteran
	name = "\improper Imperial Guard carapace helmet"
	desc = "A helmet that goes with the heavy carapace armour, this is some serious protection."
	icon_state = "guardvethelm"
	soft_armor = list(MELEE = 90, BULLET = 90, LASER = 90, ENERGY = 90, BOMB = 90, BIO = 30, FIRE = 90, ACID = 90)

/obj/item/clothing/head/helmet/UPP
	name = "\improper UM4 helmet"
	desc = "A skirted helmet designed for use with the UM/UH system."
	icon = 'icons/obj/clothing/headwear/ert_headwear.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "upp_helmet1"
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 70, BULLET = 55, LASER = 40, ENERGY = 35, BOMB = 35, BIO = 5, FIRE = 35, ACID = 35)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/UPP/heavy
	name = "\improper UH7 helmet"
	icon_state = "upp_helmet_heavy"
	soft_armor = list(MELEE = 90, BULLET = 85, LASER = 60, ENERGY = 65, BOMB = 85, BIO = 5, FIRE = 65, ACID = 65)
	resistance_flags = UNACIDABLE
	anti_hug = 3

//head rag

/obj/item/clothing/head/helmet/specrag
	name = "specialist head-rag"
	desc = "A hat worn by heavy-weapons operators to block sweat."
	icon = 'icons/obj/clothing/headwear/marine_hats.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/marine_hats.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "spec"
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 15, BOMB = 10, BIO = 0, FIRE = 15, ACID = 15)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS

/*===========================HELGHAST - MERCENARY================================
=====================================================================*/

/obj/item/clothing/head/helmet/marine/veteran/mercenary
	name = "\improper K12 ceramic helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_heavy_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 60, BOMB = 70, BIO = 10, FIRE = 60, ACID = 60)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = NONE

/obj/item/clothing/head/helmet/marine/veteran/mercenary/miner
	name = "\improper Y8 miner helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_miner_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 45, ENERGY = 55, BOMB = 55, BIO = 10, FIRE = 55, ACID = 55)


/obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer
	name = "\improper Z7 engineer helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_engineer_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 55, BULLET = 60, LASER = 45, ENERGY = 55, BOMB = 60, BIO = 10, FIRE = 55, ACID = 55)



/obj/item/clothing/head/helmet/marine/som
	name = "\improper S6 combat helmet"
	desc = "A helmet with origns of heavily modified head protection used back in the mining colonies. Protection from threats is bad but it's better than nothing."
	icon = 'icons/obj/clothing/headwear/ert_headwear.dmi'
	icon_state = "som_helmet"
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	item_state = "som_helmet"
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NONE
	flags_marine_helmet = NONE


/obj/item/clothing/head/helmet/marine/som/veteran
	name = "\improper S7 combat helmet"
	desc = "A helmet of origins off of heavily modified helmets used back in the mining colonies. Seems to have extensive modification."
	icon_state = "som_helmet_veteran"
	item_state = "som_helmet_veteran"
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 35, BOMB = 30, BIO = 50, FIRE = 35, ACID = 50)


/obj/item/clothing/head/helmet/marine/som/leader
	name = "\improper S8 combat helmet"
	desc = "A helmet of origins off of heavily modified helmets used back in the mining colonies."
	icon_state = "som_helmet_leader"
	item_state = "som_helmet_leader"
	soft_armor = list(MELEE = 55, BULLET = 65, LASER = 65, ENERGY = 30, BOMB = 20, BIO = 50, FIRE = 30, ACID = 50)

/obj/item/clothing/head/helmet/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = DELONDROP
	soft_armor = list(MELEE = 65, BULLET = 60, LASER = 30, ENERGY = 20, BOMB = 25, BIO = 40, FIRE = 20, ACID = 20)
	anti_hug = 5

/obj/item/clothing/head/helmet/sectoid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SECTOID_TRAIT)

/obj/item/clothing/head/helmet/marine/icc
	name = "\improper Modelle/20 combat helmet"
	desc = "A regular ICCAF helmet, used by all branches of its forces. It is made to fit in both a utility and combat role with noticeably high resistance to explosions and bullets. "
	icon = 'icons/obj/clothing/headwear/ert_headwear.dmi'
	icon_state = "icc"
	item_icons = list(
		slot_head_str = 'icons/mob/clothing/headwear/ert_headwear.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	item_state = "icc"
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 70, BIO = 10, FIRE = 60, ACID = 50)

/obj/item/clothing/head/helmet/marine/icc/guard
	name = "\improper Modelle/21 combat helmet"
	desc = "A high-quality ICCGF helmet, mostly seen worn by the ICC's highest quality troops, better well known as 'Guardsmen'. Like most helmets of the ICC it is made to fit a utility and combat role with noticeably high resistance to explosions and bullets."
	icon_state = "icc_guard"
	item_state = "icc_guard"
	soft_armor = list(MELEE = 60, BULLET = 65, LASER = 40, ENERGY = 60, BOMB = 80, BIO = 10, FIRE = 55, ACID = 40)

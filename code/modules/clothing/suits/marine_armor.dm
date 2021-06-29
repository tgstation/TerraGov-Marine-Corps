// MARINE STORAGE ARMOR


/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard TerraGov Marine Corps M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "3"
	item_state = "armor"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi')
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 45, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	slowdown = 0.5
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/bible,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
	)
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/list/armor_overlays
	actions_types = list(/datum/action/item_action/toggle)
	flags_armor_features = ARMOR_LAMP_OVERLAY
	flags_item = SYNTH_RESTRICTED|IMPEDE_JETPACK
	w_class = WEIGHT_CLASS_HUGE
	time_to_unequip = 2 SECONDS
	time_to_equip = 2 SECONDS
	pockets = /obj/item/storage/internal/suit/marine
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/storage/internal/suit/marine
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/cell/lasgun,
	)
	max_storage_space = 6

/obj/item/clothing/suit/storage/marine/Initialize()
	. = ..()
	armor_overlays = list("lamp") //Just one for now, can add more later.
	update_icon()

/obj/item/clothing/suit/storage/marine/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_armor_features & ARMOR_LAMP_OVERLAY)
		I = image('icons/obj/clothing/cm_suits.dmi', src, flags_armor_features & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else
		armor_overlays["lamp"] = null
	user?.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/apply_custom(image/standing)
	var/image/I
	for(var/i in armor_overlays)
		I = armor_overlays[i]
		if(I)
			I = image('icons/mob/suit_1.dmi',src,I.icon_state)
			standing.overlays += I


/obj/item/clothing/suit/storage/marine/Destroy()
	if(pockets)
		QDEL_NULL(pockets)
	return ..()

/obj/item/clothing/suit/storage/marine/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
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

/obj/item/clothing/suit/storage/marine/M3HB
	name = "\improper M3-H pattern marine armor"
	desc = "A standard Marine M3 Heavy Build Pattern Chestplate. Increased protection at the cost of slowdown."
	icon_state = "1"
	soft_armor = list("melee" = 65, "bullet" = 70, "laser" = 70, "energy" = 30, "bomb" = 60, "bio" = 50, "rad" = 20, "fire" = 50, "acid" = 55)
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/storage/marine/M3LB
	name = "\improper M3-LB pattern marine armor"
	desc = "A standard Marine M3 Light Build Pattern Chestplate. Lesser encumbrance and protection."
	icon_state = "2"
	soft_armor = list("melee" = 45, "bullet" = 55, "laser" = 55, "energy" = 20, "bomb" = 45, "bio" = 30, "rad" = 10, "fire" = 25, "acid" = 35)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	light_range = 8 //because it's LIGHT armor, get it?

/obj/item/clothing/suit/storage/marine/harness
	name = "\improper M3 pattern marine harness"
	desc = "A standard Marine M3 Pattern Harness. No encumbrance and no protection."
	icon_state = "10"
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	slowdown = 0
	flags_atom = NONE

/obj/item/clothing/suit/storage/marine/M3IS
	name = "\improper M3-IS pattern marine armor"
	desc = "A standard Marine M3 Integrated Storage Pattern Chestplate. Increased encumbrance and storage capacity."
	icon_state = "4"
	soft_armor = list("melee" = 60, "bullet" = 65, "laser" = 65, "energy" = 20, "bomb" = 50, "bio" = 35, "rad" = 10, "fire" = 35, "acid" = 50)
	slowdown = SLOWDOWN_ARMOR_HEAVY
	pockets = /obj/item/storage/internal/suit/marine/M3IS

/obj/item/storage/internal/suit/marine/M3IS
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 15 // Same as satchel
	max_w_class = 3

/obj/item/clothing/suit/storage/marine/M3E
	name = "\improper M3-E pattern marine armor"
	desc = "A standard Marine M3 Edge Pattern Chestplate. High protection against cuts and slashes, but very little padding against bullets or explosions."
	icon_state = "5"
	soft_armor = list("melee" = 70, "bullet" = 10, "laser" = 15, "energy" = 20, "bomb" = 15, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

/obj/item/clothing/suit/storage/marine/M3P
	name = "\improper M3-P pattern marine armor"
	desc = "A standard Marine M3 Padded Pattern Chestplate. Better protection against bullets and explosions, with limited thermal shielding against energy weapons, but worse against melee."
	icon_state = "6"
	soft_armor = list("melee" = 20, "bullet" = 80, "laser" = 25, "energy" = 10, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 65)
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS

/obj/item/clothing/suit/storage/marine/M3P/tanker
	name = "\improper PAS-09 pattern tanker armor"
	desc = "A somewhat outdated but robust armored vest, still in use despite the rise of exoskeleton armor due to ease of use and manufacturing. While the suit is a bit more encumbering to wear with the crewman uniform, it offers the loader a degree of protection that would otherwise not be enjoyed."
	icon_state = "tanker"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT)

/obj/item/clothing/suit/storage/marine/M3P/tech
	name = "\improper PAS-09 pattern technician armor"
	desc = "A somewhat outdated but robust armored vest, still in use despite the rise of exoskeleton armor due to ease of use and manufacturing. It offers more protection against the exotic dangers that technicians face."
	icon_state = "tanker"
	soft_armor = list("melee" = 40, "bullet" = 55, "laser" = 60, "energy" = 45, "bomb" = 60, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 65)
	flags_item_map_variant = NONE


/obj/item/clothing/suit/storage/marine/leader
	name = "\improper PAS-10 pattern leader armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Use it to toggle the built-in flashlight."
	icon_state = "7"
	soft_armor = list("melee" = 40, "bullet" = 55, "laser" = 55, "energy" = 40, "bomb" = 40, "bio" = 40, "rad" = 15, "fire" = 40, "acid" = 45)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	light_range = 8
	pockets = /obj/item/storage/internal/suit/leader

/obj/item/storage/internal/suit/leader
	storage_slots = 3
	max_storage_space = 12
	max_w_class = 3

/obj/item/clothing/suit/storage/marine/MP
	name = "\improper PAS-N2 pattern MA armor"
	desc = "A standard TerraGov Navy N2 Personal Armor System. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 45, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)
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
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun,
	)

/obj/item/clothing/suit/storage/marine/MP/WO
	icon_state = "warrant_officer"
	name = "\improper PAS-N3 pattern MA armor"
	desc = "A well-crafted suit of Personal Armor System typically distributed to Command Masters at Arms. Useful for letting your men know who is in charge."

/obj/item/clothing/suit/storage/marine/MP/admiral
	icon_state = "admiral"
	name = "\improper PAS-N3 pattern admiral armor"
	desc = "A well-crafted suit of Personal Armor System with a gold shine. It looks very expensive, but shockingly fairly easy to carry and wear."
	w_class = WEIGHT_CLASS_NORMAL
	soft_armor = list("melee" = 40, "bullet" = 65, "laser" = 60, "energy" = 45, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "\improper PAS-N3 pattern officer armor"
	desc = "A well-crafted suit of a Navy Personal Armor System typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field."

/obj/item/clothing/suit/storage/marine/smartgunner
	name = "M26 combat harness"
	desc = "A heavy protective vest designed to be worn with the T26 smart machinegun system. \nIt has specially designed straps and reinforcement to carry the smart machinegun drums inside of it."
	icon_state = "8"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list("melee" = 45, "bullet" = 65, "laser" = 65, "energy" = 35, "bomb" = 35, "bio" = 30, "rad" = 10, "fire" = 35, "acid" = 45)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/mine,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/weapon/gun/smartgun,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun,
		/obj/item/storage/belt/sparepouch,
	)
	pockets = /obj/item/storage/internal/suit/marine/smartgunner

/obj/item/storage/internal/suit/marine/smartgunner
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/standard_smartmachinegun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/cell/lasgun,
	)
	max_storage_space = 6

/obj/item/clothing/suit/storage/marine/smartgunner/fancy
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories. This luxury model appears to belong to the CO. You feel like you probably could get fired for touching this.."
	icon_state = "8fancy"

// MARINE PAS-11 vests, the new armor. It is basically equivalent to a modular armor with general storage on it.

/obj/item/clothing/suit/storage/marine/pasvest
	name = "\improper PAS-11 pattern armored vest"
	desc = "A somewhat outdated but robust armored vest, still in use despite the rise of exoskeleton armor due to ease of use and manufacturing. Tougher than it looks. Use it to toggle the built-in flashlight."
	icon_state = "2"
	soft_armor = list("melee" = 40, "bullet" = 60, "laser" = 60, "energy" = 45, "bomb" = 45, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 50)
	slowdown = 0.5 //a bit less
	light_range = 6


//===========================SPECIALIST================================


/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nHas an automated diagnostics and medical system for keeping its wearer alive."
	icon_state = "xarmor"
	soft_armor = list("melee" = 70, "bullet" = 75, "laser" = 75, "energy" = 80, "bomb" = 80, "bio" = 65, "rad" = 20, "fire" = 80, "acid" = 65)
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	supporting_limbs = CHEST | GROIN | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_LEFT | LEG_RIGHT | FOOT_LEFT | FOOT_RIGHT | HEAD //B18 effectively stabilizes these.
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/storage/marine/specialist/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/suit_autodoc)
	AddElement(/datum/element/limb_support, supporting_limbs)
	SSmonitor.stats.b18_in_use += src

/obj/item/clothing/suit/storage/marine/specialist/Destroy()
	. = ..()
	SSmonitor.stats.b18_in_use -= src

/obj/item/clothing/suit/storage/marine/B17
	name = "\improper B17 defensive armor"
	desc = "The older brother of the B18. Practically an armored EOD suit made for use by close quarter explosive experts."
	icon_state = "grenadier"
	soft_armor = list("melee" = 70, "bullet" = 70, "laser" = 45, "energy" = 50, "bomb" = 100, "bio" = 50, "rad" = 20, "fire" = 70, "acid" = 60)
	max_heat_protection_temperature = HEAVYARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/suit/storage/marine/B17/Initialize(mapload, ...)
	. = ..()
	SSmonitor.stats.b17_in_use += src

/obj/item/clothing/suit/storage/marine/B17/Destroy()
	. = ..()
	SSmonitor.stats.b17_in_use -= src

/obj/item/clothing/suit/storage/marine/M3T
	name = "\improper M3-T light armor"
	desc = "A custom set of M3 armor designed for users of long ranged explosive weaponry."
	icon_state = "demolitionist"
	soft_armor = list("melee" = 55, "bullet" = 50, "laser" = 40, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 10, "fire" = 25, "acid" = 25)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun/launcher/rocket)

/obj/item/clothing/suit/storage/marine/M3S
	name = "\improper M3-S light armor"
	desc = "A custom set of M3 armor designed for TGMC Scouts."
	icon_state = "scout_armor"
	soft_armor = list("melee" = 55, "bullet" = 65, "laser" = 65, "energy" = 25, "bomb" = 35, "bio" = 30, "rad" = 10, "fire" = 25, "acid" = 30)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/M35
	name = "\improper M35 armor"
	desc = "A custom set of M35 armor designed for use by TGMC Pyrotechnicians. Contains thick kevlar shielding, partial environmental shielding and thermal dissipators."
	icon_state = "pyro_armor"
	hard_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 0)
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 30, "bio" = 30, "rad" = 50, "fire" = 90, "acid" = 45)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS

/obj/item/clothing/suit/storage/marine/sniper
	name = "\improper M3 pattern recon armor"
	desc = "A custom modified set of M3 armor designed for recon missions."
	icon_state = "marine_sniper"
	soft_armor = list("melee" = 55, "bullet" = 60, "laser" = 60, "energy" = 25, "bomb" = 30, "bio" = 30, "rad" = 10, "fire" = 25, "acid" = 25)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/sniper/jungle
	name = "\improper M3 pattern marksman armor"
	icon_state = "marine_sniperm"


/*=============================PMCS==================================*/

/obj/item/clothing/suit/storage/marine/veteran
	flags_armor_features = ARMOR_LAMP_OVERLAY
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS

/obj/item/clothing/suit/storage/marine/veteran/PMC
	name = "\improper M4 pattern PMC armor"
	desc = "A common armor vest that is designed for high-profile security operators and corporate mercenaries in mind."
	icon_state = "pmc_armor"
	soft_armor = list("melee" = 45, "bullet" = 60, "laser" = 60, "energy" = 38, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 45)
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


/obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the M4 body armor, it is designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_armor"
	soft_armor = list("melee" = 50, "bullet" = 65, "laser" = 65, "energy" = 65, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 45)


/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon_state = "pmc_sniper"
	soft_armor = list("melee" = 45, "bullet" = 55, "laser" = 55, "energy" = 60, "bomb" = 65, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDELOWHAIR

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard M4 body armor. Hooked up with harnesses and straps allowing the user to carry a smartgun."
	icon_state = "pmc_heavyarmor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list("melee" = 55, "bullet" = 70, "laser" = 70, "energy" = 70, "bomb" = 70, "bio" = 30, "rad" = 20, "fire" = 65, "acid" = 65)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	name = "\improper PMC commando armor"
	desc = "A heavily armored suit built by who-knows-what for elite operations. It is a fully self-contained system and is heavily corrosion resistant."
	icon_state = "commando_armor"
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	soft_armor = list("melee" = 90, "bullet" = 120, "laser" = 200, "energy" = 90, "bomb" = 90, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
	resistance_flags = UNACIDABLE

/*===========================DISTRESS================================*/

/obj/item/clothing/suit/storage/marine/veteran/wolves
	name = "\improper H1 Steel Wolves vest"
	desc = "A protective vest worn by Steel Wolves mercenaries."
	icon_state = "wolf_armor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list("melee" = 70, "bullet" = 70, "laser" = 50, "energy" = 60, "bomb" = 50, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT

/obj/item/clothing/suit/storage/marine/veteran/dutch
	name = "\improper D2 armored vest"
	desc = "A protective vest worn by some seriously experienced mercs."
	icon_state = "dutch_armor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list("melee" = 55, "bullet" = 55, "laser" = 55, "energy" = 65, "bomb" = 70, "bio" = 10, "rad" = 10, "fire" = 65, "acid" = 30)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT


/*===========================I.o.M================================*/

/obj/item/clothing/suit/storage/marine/imperial
	name = "\improper Imperial Guard flak armour"
	desc = "A cheap, mass produced armour worn by the Imperial Guard, which are also cheap and mass produced. You can make out what appears to be <i>Cadia stands</i> carved into the armour."
	icon_state = "guardarmor"
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 60, "energy" = 60, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	flags_item_map_variant = NONE

/obj/item/clothing/suit/storage/marine/imperial/sergeant
	// SL armour, better than flak, covers more
	name = "\improper Imperial Guard sergeant armour"
	desc = "A body armour that offers much better protection than the flak armour."
	icon_state = "guardSLarmor"
	soft_armor = list("melee" = 85, "bullet" = 85, "laser" = 85, "energy" = 85, "bomb" = 85, "bio" = 25, "rad" = 25, "fire" = 85, "acid" = 85)
	light_range = 6 // better light
	pockets = /obj/item/storage/internal/suit/imperial

/obj/item/storage/internal/suit/imperial
	storage_slots = 3
	max_storage_space = 6

/obj/item/clothing/suit/storage/marine/imperial/medicae
	name = "\improper Imperial Guard medicae armour"
	desc = "An armour worn by the medicae of the Imperial Guard."
	icon_state = "guardmedicarmor"

/obj/item/clothing/suit/storage/marine/imperial/sergeant/veteran
	name = "\improper Imperial Guard carapace armour"
	desc = "A heavy full body armour that protects the wearer a lot more than the flak armour, also slows down considerably."
	icon_state = "guardvetarmor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list("melee" = 90, "bullet" = 90, "laser" = 90, "energy" = 90, "bomb" = 90, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 90)

/obj/item/clothing/suit/storage/marine/imperial/power
	// Should this maybe require recharging?
	name = "\improper salvaged Space Marine power armour"
	desc = "A power armour that was once broken, is functional once again. However this version isn't as powerful as the real power armour."
	//icon_state
	soft_armor = list("melee" = 75, "bullet" = 60, "laser" = 55, "energy" = 40, "bomb" = 45, "bio" = 15, "rad" = 15, "fire" = 40, "acid" = 40)
	light_range = 6
	pockets = /obj/item/storage/internal/suit/imperial

/obj/item/clothing/suit/storage/marine/imperial/power/astartes
	// This should either be admin only or only given to one person
	name = "\improper Space Marine power armour"
	desc = "You feel a chill running down your spine just looking at this. This is the power armour that the Space Marines wear themselves. The servos inside the power armour allow you to move at incredible speeds."
	//icon_state
	slowdown = SLOWDOWN_ARMOR_LIGHT // beefed up space marine inside an armor that boosts speed
	soft_armor = list("melee" = 95, "bullet" = 95, "laser" = 95, "energy" = 95, "bomb" = 95, "bio" = 95, "rad" = 95, "fire" = 95, "acid" = 95)

/obj/item/clothing/suit/storage/marine/imperial/commissar
	name = "\improper commissar coat"
	desc = "A armored coat worn by commissars of the Imperial Army."
	icon_state = "commissar_coat"
	item_state = "commissar_coat"
	soft_armor = list("melee" = 75, "bullet" = 60, "laser" = 55, "energy" = 40, "bomb" = 45, "bio" = 15, "rad" = 15, "fire" = 40, "acid" = 40)

/*===========================U.S.L================================*/

/obj/item/clothing/suit/storage/faction
	icon = 'icons/obj/clothing/cm_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi')
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	soft_armor = list("melee" = 50, "bullet" = 40, "laser" = 35, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
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
		/obj/item/storage/large_holster/machete,
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
		I = image('icons/obj/clothing/cm_suits.dmi', src, flags_armor_features & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()


/obj/item/clothing/suit/storage/faction/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
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
	soft_armor = list("melee" = 55, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 55, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

/// Modified version of the armor for HvH combat. Stats are based on medium armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/hvh
	soft_armor = list("melee" = 55, "bullet" = 75, "laser" = 75, "energy" = 60, "bomb" = 60, "bio" = 45, "rad" = 45, "fire" = 60, "acid" = 65)


/obj/item/clothing/suit/storage/faction/UPP/commando
	name = "\improper UM5CU personal armor"
	desc = "A modification of the UM5, designed for stealth operations."
	icon_state = "upp_armor_commando"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/// Modified version of the armor for HvH combat. Stats are based on medium armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/commando/hvh
	soft_armor = list("melee" = 55, "bullet" = 75, "laser" = 75, "energy" = 60, "bomb" = 60, "bio" = 45, "rad" = 45, "fire" = 60, "acid" = 65)

/obj/item/clothing/suit/storage/faction/UPP/heavy
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the USL pirates, the UH7 (United Heavy MK7) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list("melee" = 65, "bullet" = 65, "laser" = 65, "energy" = 60, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

/// Modified version of the armor for HvH combat. Stats are based on heavy armor, with tyr mark 2.
/obj/item/clothing/suit/storage/faction/UPP/heavy/hvh
	soft_armor = list("melee" = 60, "bullet" = 80, "laser" = 80, "energy" = 65, "bomb" = 60, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 70)

/obj/item/clothing/suit/storage/marine/smartgunner/UPP
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the USL pirates, the UH7 (United Heavy MK7) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	soft_armor = list("melee" = 65, "bullet" = 65, "laser" = 65, "energy" = 60, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

/// Modified version of the armor for HvH combat. Stats are based on heavy armor, with tyr mark 2.
/obj/item/clothing/suit/storage/marine/smartgunner/UPP/hvh
	soft_armor = list("melee" = 60, "bullet" = 80, "laser" = 80, "energy" = 65, "bomb" = 60, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 70)

//===========================FREELANCER================================

/obj/item/clothing/suit/storage/faction/freelancer
	name = "\improper freelancer cuirass"
	desc = "A armored protective chestplate scrapped together from various plates. It keeps up remarkably well, as the craftsmanship is solid, and the design mirrors such armors in the UPP and the TGMC."
	icon_state = "freelancer_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	soft_armor = list("melee" = 50, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 40, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 50)

//this one is for CLF
/obj/item/clothing/suit/storage/militia
	name = "\improper colonial militia hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. "
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "rebel_armor"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi')
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection =CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_item = SYNTH_RESTRICTED
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30)
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
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/baseballbat,
	)
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	blood_overlay_type = "coat"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	allowed = list(
		/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun,
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
	soft_armor = list("melee" = 75, "bullet" = 62, "laser" = 42, "energy" = 38, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
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
	soft_armor = list("melee" = 50, "bullet" = 42, "laser" = 42, "energy" = 38, "bomb" = 25, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
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
	soft_armor = list("melee" = 55, "bullet" = 52, "laser" = 42, "energy" = 38, "bomb" = 30, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
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
	icon_state = "som_armor"
	item_state = "som_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 55, "rad" = 55, "fire" = 55, "acid" = 55)
	flags_item_map_variant = NONE


/// Modified version of the armor for HvH combat. Stats are on medium armor.
/obj/item/clothing/suit/storage/marine/som/hvh
	soft_armor = list("melee" = 50, "bullet" = 60, "laser" = 60, "energy" = 55, "bomb" = 55, "bio" = 55, "rad" = 55, "fire" = 55, "acid" = 55)


/obj/item/clothing/suit/storage/marine/som/veteran
	name = "\improper S12 combat Hauberk"
	desc = "A heavily modified piece of mining equipment remade for general purpose combat use. Seems to have been modifed much further than other pieces like it. Heavier but tougher because of it."
	icon_state = "som_armor_veteran"
	item_state = "som_armor_veteran"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list("melee" = 65, "bullet" = 70, "laser" = 70, "energy" = 55, "bomb" = 55, "bio" = 55, "rad" = 55, "fire" = 55, "acid" = 60)

// Modified version of the armor for HvH combat. Stats are based on heavy armor with mark 2 tyr.
/obj/item/clothing/suit/storage/marine/som/veteran/hvh
	soft_armor = list("melee" = 65, "bullet" = 80, "laser" = 80, "energy" = 65, "bomb" = 60, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 70)


/obj/item/clothing/suit/storage/marine/som/leader
	name = "\improper S13 leader hauberk"
	desc = "A heavily modified modified piece of mining equipment remade for general purpose combat use. Modified extensively than other pieces like it but heavier because of it."
	icon_state = "som_armor_leader"
	item_state = "som_armor_leader"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	soft_armor = list("melee" = 55, "bullet" = 50, "laser" = 40, "energy" = 55, "bomb" = 55, "bio" = 55, "rad" = 55, "fire" = 55, "acid" = 60)

/// Modified version of the armor for HvH combat. Stats are based on medium armor with mark 2 tyr.
/obj/item/clothing/suit/storage/marine/som/leader/hvh
	soft_armor = list("melee" = 55, "bullet" = 75, "laser" = 75, "energy" = 60, "bomb" = 60, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 65)

///Available by default
#define LOADOUT_ITEM_ROUNDSTART_OPTION (1<<0)
///This is the default option for this slot
#define LOADOUT_ITEM_DEFAULT_CHOICE (1<<1)
///Available for unlock by default
#define LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE (1<<2)

GLOBAL_LIST_INIT(campaign_loadout_slots, list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_EYES, ITEM_SLOT_EARS, \
ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_ID, ITEM_SLOT_BELT, ITEM_SLOT_BACK, ITEM_SLOT_R_POCKET, ITEM_SLOT_L_POCKET, ITEM_SLOT_SUITSTORE))

//List of all loadout_item datums
GLOBAL_LIST_INIT_TYPED(campaign_loadout_item_type_list, /datum/loadout_item, init_glob_loadout_item_list())

/proc/init_glob_loadout_item_list()
	. = list()
	for(var/type in subtypesof(/datum/loadout_item))
		var/datum/loadout_item/item_type = new type
		if(!length(item_type.jobs_supported))
			qdel(item_type)
			continue
		.[item_type.type] = item_type

//List of all loadout_item datums by job, excluding ones that must be unlocked //now including those
GLOBAL_LIST_INIT(campaign_loadout_items_by_role, init_campaign_loadout_items_by_role())

/proc/init_campaign_loadout_items_by_role()
	. = list()
	for(var/job in GLOB.campaign_jobs)
		.[job] = list()
		for(var/i in GLOB.campaign_loadout_item_type_list)
			var/datum/loadout_item/option = GLOB.campaign_loadout_item_type_list[i]
			//if(!(option.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_OPTION) && !(option.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE))
			//	continue
			if(option.jobs_supported && !(job in option.jobs_supported))
				continue
			.[job] += option

//represents an equipable item
//Are singletons
/datum/loadout_item
	///Item name
	var/name
	///Item desc
	var/desc
	///Addition desc for special reqs such as black/whitelist
	var/req_desc
	///Typepath of the actual item this datum represents
	var/obj/item/item_typepath
	///UI icon for this item
	var/ui_icon = "b18" //placeholder
	///inventory slot it is intended to go into
	var/item_slot

	var/loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION
	///Cost to unlock this option
	var/unlock_cost = 0
	///Cost to use this option
	var/purchase_cost = 0
	///The amount of this available per mission. -1 for unlimited
	var/quantity = -1
	///Job types that this perk is available to
	var/list/jobs_supported
	///assoc list by slot of items required for this to be equipped. Requires only 1 out of the list
	var/list/item_whitelist
	///assoc list by slot of items blacklisted for this to be equipped
	var/list/item_blacklist
	//do we need a post equip gear list?

/datum/loadout_item/New()
	. = ..()
	if(loadout_item_flags & LOADOUT_ITEM_DEFAULT_CHOICE)
		jobs_supported = GLOB.campaign_jobs

///Attempts to add an item to a loadout
/datum/loadout_item/proc/item_checks(datum/outfit_holder/outfit_holder)
	if(length(item_whitelist) && !whitelist_check(outfit_holder))
		return FALSE
	if(length(item_blacklist) && !blacklist_check(outfit_holder))
		return FALSE
	return TRUE

///checks if a loadout has one or more whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit_holder/outfit_holder)
	for(var/whitelist_item in item_whitelist)
		var/type_to_check = outfit_holder.equipped_things["[item_whitelist[whitelist_item]]"]?.item_typepath
		if(type_to_check == whitelist_item)
			return TRUE
	return FALSE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit_holder/outfit_holder)
	for(var/blacklist_item in item_blacklist)
		var/type_to_check = outfit_holder.equipped_things["[item_blacklist[blacklist_item]]"]?.item_typepath
		if(type_to_check == blacklist_item)
			return FALSE
	return TRUE

///Any post equip things related to this item
/datum/loadout_item/proc/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	return role_post_equip(wearer, loadout)

///A separate post equip proc for role specific code. Split for more flexible parent overriding
/datum/loadout_item/proc/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)	return

//suits
/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/empty
	name = "no suit"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/light_shield
	name = "Light shielded armor"
	desc = "Light armor with a Svallin shield module. Provides excellent mobility but lower protection."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/light/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/medium_shield
	name = "Medium shielded armor"
	desc = "Medium armor with a Svallin shield module. Provides balanced mobility and protection."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_shield
	name = "Heavy shielded armor"
	desc = "Heavy armor with a Svallin shield module. Provides excellent protection but lower mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_surt
	name = "Heavy Surt armor"
	desc = "Heavy armor with a Surt fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	jobs_supported = list(SQUAD_MARINE)
	quantity = 1 //testing purposes only

/datum/loadout_item/suit_slot/heavy_tyr
	name = "Heavy Tyr armor"
	desc = "Heavy armor with a Tyr extra armor module. Provides incredible protection at the cost of with further reduced mobility."
	req_desc = "Requires a ALF-51B."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER) //todo: probably make a separate instance for SG's
	quantity = 1 //testing purposes only
	item_whitelist = list(
		/obj/item/weapon/gun/rifle/alf_machinecarbine/assault = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/smg/m25/magharness = ITEM_SLOT_SUITSTORE,
	) //testing purposes only

/datum/loadout_item/suit_slot/medium_mimir
	name = "Medium Mimir armor"
	desc = "Medium armor with a Mimir environmental protection module. Provides respectable armor and total immunity to chemical attacks, and improved radiological protection. Has modest mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/mimir
	jobs_supported = list(SQUAD_CORPSMAN)

//helmets
/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD

/datum/loadout_item/helmet/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

/datum/loadout_item/helmet/empty
	name = "no helmet"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/standard
	name = "M10X helmet"
	desc = "A standard TGMC combat helmet. Apply to head for best results."
	item_typepath = /obj/item/clothing/head/modular/m10x
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/helmet/leader
	name = "M11X helmet"
	desc = "An upgraded helmet for protecting upgraded brains."
	item_typepath = /obj/item/clothing/head/modular/m10x/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/helmet/surt
	name = "M10X-Surt helmet"
	desc = "A standard combat helmet with a Surt fireproof module."
	req_desc = "Requires a suit with a Surt module."
	item_typepath = /obj/item/clothing/head/modular/m10x/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/clothing/suit/modular/xenonauten/heavy/surt = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/helmet/tyr
	name = "M10X-Tyr helmet"
	desc = "A standard combat helmet with a Tyr extra armor module."
	req_desc = "Requires a suit with a Tyr module."
	item_typepath = /obj/item/clothing/head/modular/m10x/tyr
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)
	item_whitelist = list(
		/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/helmet/mimir
	name = "M10X-Mimir helmet"
	desc = "A standard combat helmet with a Mimir environmental protection module."
	req_desc = "Requires a suit with a Mimir module."
	item_typepath = /obj/item/clothing/head/modular/m10x/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	item_whitelist = list(
		/obj/item/clothing/suit/modular/xenonauten/mimir = ITEM_SLOT_OCLOTHING,
	)




//uniform
/datum/loadout_item/uniform
	item_slot = ITEM_SLOT_ICLOTHING

/datum/loadout_item/uniform/empty
	name = "no uniform"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/uniform/marine_standard
	name = "TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	item_typepath = /obj/item/clothing/under/marine/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/red_fatigue
	name = "Big Red fatigues"
	desc = "Originated from Big Red. Designed for dry, low humid, and Mars-eqse environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They make you feel like one with the desert, \
	forged by the beating Sun. Rumors had it that it can recycle your sweat and urine for drinkable water!"
	item_typepath = /obj/item/clothing/under/marine/red_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/striped_fatigue
	name = "Striped fatigues"
	desc = "A simple set of camo pants and a striped shirt."
	item_typepath = /obj/item/clothing/under/marine/striped/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/lv_fatigue
	name = "LV-624 fatigues"
	desc = "Originated from LV-624. Designed for wet, high humid, and jungle environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. \
	Somewhere, someone is playing 'Fortunate Sons' in the background, and you can smell napalm and Agent Orange in the air..."
	item_typepath = /obj/item/clothing/under/marine/lv_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/orion_fatigue
	name = "Orion fatigues"
	desc = "Originated from Orion Military Outpost. Designed for ship and urban environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They're the definition of over-funded ideas, \
	least they look neat. It is very likely that a boot fresh from boot camp to buy this at the BX with his E-1 pay because of how tacticool it looks."
	item_typepath = /obj/item/clothing/under/marine/orion_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/marine_corpsman
	name = "corpsman fatigues"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/under/marine/corpsman/corpman_vest
	jobs_supported = list(SQUAD_CORPSMAN)

//gloves
/datum/loadout_item/gloves
	item_slot = ITEM_SLOT_GLOVES

/datum/loadout_item/gloves/empty
	name = "no gloves"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/marine_gloves
	name = "Combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/gloves/marine_black_gloves
	name = "Black combat gloves"
	desc = "Standard issue marine tactical gloves but black! It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine/black
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

//eyes
/datum/loadout_item/eyes
	item_slot = ITEM_SLOT_EYES

/datum/loadout_item/eyes/empty
	name = "no eyewear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/eyes/ballistic_goggles
	name = "Ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	item_typepath = /obj/item/clothing/glasses/mgoggles
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/eyes/health_hud
	name = "HealthMate HUD"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/hud/health
	jobs_supported = list(SQUAD_CORPSMAN, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/eyes/mesons
	name = "Optical meson scanner"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/meson
	jobs_supported = list(SQUAD_ENGINEER)
	purchase_cost = 12 //test only

/datum/loadout_item/eyes/welding
	name = "Welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	item_typepath = /obj/item/clothing/glasses/welding
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER)

//ears
/datum/loadout_item/ears
	item_slot = ITEM_SLOT_EARS

/datum/loadout_item/ears/empty
	name = "no headset"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/ears/marine_standard
	name = "Standard headset"
	desc = "A headset, allowing for communication with your team and access to the tactical minimap. You're in for a bad time if you don't use this."
	item_typepath = /obj/item/radio/headset/mainship/marine
	jobs_supported = list(SQUAD_MARINE)

//mask
/datum/loadout_item/mask
	item_slot = ITEM_SLOT_MASK

/datum/loadout_item/mask/empty
	name = "no mask"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/mask/standard
	name = "Standard gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	item_typepath = /obj/item/clothing/mask/gas
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/mask/tactical
	name = "Tactical gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air. This one is supposedly more tactical than the standard model."
	item_typepath = /obj/item/clothing/mask/gas/tactical
	jobs_supported = list(SQUAD_MARINE)

//feet
/datum/loadout_item/feet
	item_slot = ITEM_SLOT_FEET

/datum/loadout_item/feet/empty
	name = "no footwear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/feet/marine_boots
	name = "Combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/full
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/feet/marine_brown_boots
	name = "Brown combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/brown/full
	jobs_supported = list(SQUAD_MARINE)

//belt
/datum/loadout_item/belt
	item_slot = ITEM_SLOT_BELT

/datum/loadout_item/belt/empty
	name = "no belt"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/ammo_belt
	name = "ammo belt"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	item_typepath = /obj/item/storage/belt/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/belt/sparepouch
	name = "G8 storage pouch"
	desc = "A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines."
	item_typepath = /obj/item/storage/belt/sparepouch
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/shotgun_mixed
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Loaded full of buckshot and flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/mixed
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster
	name = "SMG-25 holster"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. \
	This version is designed for the SMG-25, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	item_typepath = /obj/item/storage/holster/m25
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m25/holstered(wearer), SLOT_IN_HOLSTER)

/datum/loadout_item/belt/machete
	name = "Machete"
	desc = "A large leather scabbard carrying a M2132 machete. It can be strapped to the back, waist or armor. Extremely dangerous against human opponents - if you can get close enough."
	item_typepath = /obj/item/storage/holster/blade/machete/full
	jobs_supported = list(SQUAD_MARINE)

//back
/datum/loadout_item/back
	item_slot = ITEM_SLOT_BACK

/datum/loadout_item/back/empty
	name = "no backpack"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/marine_satchel
	name = "Satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel. Carries less than a backpack, but items can be drawn instantly."
	item_typepath = /obj/item/storage/backpack/marine/satchel
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/back/marine_backpack
	name = "Backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield. Carries more than a satchel but has a draw delay."
	item_typepath = /obj/item/storage/backpack/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/back/flamer_tank
	name = "Flame tank"
	desc = "A specialized fuel tank for use with the FL-84 flamethrower and FL-240 incinerator unit."
	req_desc = "Requires a FL-84 flamethrower."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/back/jetpack
	name = "Heavy jetpack"
	desc = "An upgraded jetpack with enough fuel to send a person flying for a short while with extreme force. \
	It provides better mobility for heavy users and enough thrust to be used in an aggressive manner. \
	Alt right click or middleclick to fly to a destination when the jetpack is equipped. Will collide with hostiles"
	req_desc = "Requires a SMG-25 or ALF-51B."
	item_typepath = /obj/item/jetpack_marine/heavy
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/gun/smg/m25/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/rifle/alf_machinecarbine/assault = ITEM_SLOT_SUITSTORE,
	)

//r_pocket
/datum/loadout_item/r_pocket
	item_slot = ITEM_SLOT_R_POCKET

/datum/loadout_item/r_pocket/empty
	name = "no right pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/r_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "Standard marine first-aid pouch. Contains a basic set of medical supplies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/marine_standard_grenades
	name = "Standard grenades"
	desc = "A pouch carrying a set of six standard support grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/shotgun
	name = "Shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo. Contains buckshot shells."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/shotgun
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

/datum/loadout_item/r_pocket/marine_construction
	name = "Construction pouch"
	desc = "A pouch containing an assortment of construction supplies. Allows for the rapid establishment of fortified positions."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/construction
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/marine_construction/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/half, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/full, SLOT_IN_R_POUCH)

//l_pocket
/datum/loadout_item/l_pocket
	item_slot = ITEM_SLOT_L_POCKET

/datum/loadout_item/l_pocket/empty
	name = "no left pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/l_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "Standard marine first-aid pouch. Contains a basic set of medical supplies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/marine_standard_grenades
	name = "Grenade pouch"
	desc = "A pouch carrying a set of six standard support grenades. Includes smoke grenades of both lethal and nonlethal varieties, as well as stun grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/shotgun
	name = "Shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo. Contains Flechette shells."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/shotgun
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)

/datum/loadout_item/l_pocket/marine_construction
	name = "Construction pouch"
	desc = "A pouch containing an assortment of construction supplies. Allows for the rapid establishment of fortified positions."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/construction
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/marine_construction/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/half, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/full, SLOT_IN_L_POUCH)

//suit_store
/datum/loadout_item/suit_store
	item_slot = ITEM_SLOT_SUITSTORE

/datum/loadout_item/suit_store/empty
	name = "no suit stored"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun
	///Ammo type this gun will use
	var/ammo_type

/datum/loadout_item/suit_store/main_gun/New()
	. = ..()
	if(ammo_type)
		return
	var/obj/item/weapon/gun/weapon_type = item_typepath
	ammo_type = weapon_type::default_ammo_type

/datum/loadout_item/suit_store/main_gun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)

/datum/loadout_item/suit_store/main_gun/marine
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle
	name = "AR-12"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. \
	The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle
	name = "Laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	unlock_cost = 2
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_laser_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine
	name = "AR-18"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/standard

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle
	name = "AR-11"
	desc = "The Keckler and Hoch AR-11 is the former standard issue rifle of the TGMC. Most of them have been mothballed into storage long ago, but some still pop up in marine or mercenary hands. \
	It is known for its large magazine size and great burst fire, but rather awkward to use, especially during combat. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle
	name = "BR-64"
	desc = "The San Cristo Arms BR-64 is the TerraGov Marine Corps main battle rifle. It is known for its consistent ability to perform well at most ranges, and medium range stopping power with bursts. \
	It is mostly used by people who prefer a bigger round than the average. Uses 10x26.5smm caseless caliber."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_br/standard

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle
	name = "AR-21"
	desc = "The Kauser AR-21 is a versatile rifle is developed to bridge a gap between higher caliber weaponry and a normal rifle. It fires a strong 10x25mm round, which has decent stopping power. \
	It however suffers in magazine size and movement capablity compared to smaller peers."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x25mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf
	name = "ALF-51B"
	desc = "The Kauser ALF-51B is an unoffical modification of a ALF-51, or better known as the AR-18 carbine, modified to SMG length of barrel, rechambered for a stronger round, and belt based. \
	Truly the peak of CQC. Useless past that. Aiming is impossible. Uses 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault

/datum/loadout_item/suit_store/main_gun/marine/alf/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg
	name = "MG-60"
	desc = "The Raummetall MG-60 general purpose machinegun is the TGMC's current standard GPMG. \
	Though usually seen mounted on vehicles, it is sometimes used by infantry to hold chokepoints or suppress enemies, or in rare cases for marching fire. It uses 10x26mm boxes."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg
	name = "MG-27"
	desc = "The MG-27 is the SG-29s aging IFF-less cousin, made for rapid accurate machinegun fire in a short amount of time, you could use it while standing, not a great idea. \
	Use the tripod for actual combat. It uses 10x27mm boxes."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/standard_mmg/machinegunner

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg
	name = "Laser machinegun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. \
	High efficiency modulators ensure the TE-M has an extremely high fire count, and multiple firemodes makes it a flexible infantry support gun. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/flamer
	name = "FL-84"
	desc = "The FL-84 flamethrower is the current standard issue flamethrower of the TGMC, and is used for area control and urban combat. Use unique action to use hydro cannon"
	req_desc = "Requires a suit with a Surt module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/heavy/surt = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/shotgun
	name = "SH-35"
	desc = "The Terran Armories SH-35 is the shotgun used by the TerraGov Marine Corps. \
	It's used as a close quarters tool when someone wants something more suited for close range than most people, or as an odd sidearm on your back for emergencies. \
	Uses 12 gauge shells. Requires a pump, which is the Unique Action key."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/shotgun/pump/t35/standard

/datum/loadout_item/suit_store/main_gun/marine/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(wearer), SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout
	name = "Laser carbine-S"
	desc = "A TerraGov standard issue laser carbine, otherwise known as TE-C for short. Has multiple firemodes for tactical flexibility. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine
	name = "AR-18-S"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition. \
	This particular example has an underbarrel grenade launcher and a top mounted motion sensor. Good for scouting out enemy positions."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield
	name = "SMG-25 & riot shield"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. \
	A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine. \
	This one comes with a TL-172 defensive shield, intended for use with Tyr heavy armor."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine, SLOT_L_HAND)
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

	//todo: second smg-25 for assault marine loadout, or figure that out in some other way

/datum/loadout_item/suit_store/main_gun/marine/standard_smg
	name = "SMG-25"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. \
	A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle
	name = "BR-8"
	desc ="The BR-8 is a light specialized scout rifle, mostly used by light infantry and scouts. \
	It's designed to be useable at all ranges by being very adaptable to different situations due to the ability to use different ammo types. Has IFF.  Takes specialized overpressured 10x28mm rounds."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx8/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/scanner(wearer), SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)

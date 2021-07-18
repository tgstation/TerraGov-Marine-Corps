#define MARINE_CAN_BUY_UNIFORM (1 << 0)
#define MARINE_CAN_BUY_SHOES (1 << 1)
#define MARINE_CAN_BUY_HELMET (1 << 2)
#define MARINE_CAN_BUY_ARMOR (1 << 3)
#define MARINE_CAN_BUY_GLOVES (1 << 4)
#define MARINE_CAN_BUY_EAR (1 << 5)
#define MARINE_CAN_BUY_BACKPACK (1 << 6)
#define MARINE_CAN_BUY_R_POUCH (1 << 7)
#define MARINE_CAN_BUY_L_POUCH (1 << 8)
#define MARINE_CAN_BUY_BELT (1 << 9)
#define MARINE_CAN_BUY_GLASSES (1 << 10)
#define MARINE_CAN_BUY_MASK (1 << 11)
#define MARINE_CAN_BUY_ESSENTIALS (1 << 12)
#define MARINE_CAN_BUY_ATTACHMENT (1 << 13)
#define MARINE_CAN_BUY_ATTACHMENT2 (1 << 14)

#define MARINE_CAN_BUY_WEBBING (1 << 15)
#define MARINE_CAN_BUY_MODULE (1 << 16)
#define MARINE_CAN_BUY_ARMORMOD (1 << 17)

#define MARINE_CAN_BUY_ALL ((1 << 18) - 1)

#define CAT_ESS "ESSENTIALS"
#define CAT_STD "STANDARD EQUIPMENT"
#define CAT_SHO "SHOES"
#define CAT_HEL "HATS"
#define CAT_AMR "ARMOR"
#define CAT_GLO "GLOVES"
#define CAT_EAR "EAR"
#define CAT_BAK "BACKPACK"
#define CAT_POU "POUCHES"
#define CAT_WEB "WEBBING"
#define CAT_BEL "BELT"
#define CAT_MAS "MASKS"
#define CAT_ATT "GUN ATTACHMENTS"
#define CAT_MOD "JAEGER STORAGE MODULES"
#define CAT_ARMMOD "JAEGER ARMOR MODULES"

#define CAT_MEDSUP "MEDICAL SUPPLIES"
#define CAT_ENGSUP "ENGINEERING SUPPLIES"
#define CAT_LEDSUP "LEADER SUPPLIES"

GLOBAL_LIST_INIT(marine_selector_cats, list(
		CAT_MOD = list(MARINE_CAN_BUY_MODULE),
		CAT_ARMMOD = list(MARINE_CAN_BUY_ARMORMOD),
		CAT_STD = list(MARINE_CAN_BUY_UNIFORM),
		CAT_SHO = list(MARINE_CAN_BUY_SHOES),
		CAT_HEL = list(MARINE_CAN_BUY_HELMET),
		CAT_AMR = list(MARINE_CAN_BUY_ARMOR),
		CAT_GLO = list(MARINE_CAN_BUY_GLOVES),
		CAT_EAR = list(MARINE_CAN_BUY_EAR),
		CAT_BAK = list(MARINE_CAN_BUY_BACKPACK),
		CAT_WEB = list(MARINE_CAN_BUY_WEBBING),
		CAT_POU = list(MARINE_CAN_BUY_R_POUCH,MARINE_CAN_BUY_L_POUCH),
		CAT_BEL = list(MARINE_CAN_BUY_BELT),
		CAT_GLA = list(MARINE_CAN_BUY_GLASSES),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
		CAT_ESS = list(MARINE_CAN_BUY_ESSENTIALS),
		CAT_MEDSUP = null,
		CAT_ENGSUP = null,
		CAT_LEDSUP = null,
	))

#define METAL_PRICE_IN_GEAR_VENDOR 2
#define PLASTEEL_PRICE_IN_GEAR_VENDOR 4
#define SANDBAG_PRICE_IN_GEAR_VENDOR 5

GLOBAL_LIST_INIT(engineer_gear_listed_products, list(
		/obj/effect/essentials_set/engi = list(CAT_ESS, "Essential Engineer Set", 0, "white"),
		/obj/item/stack/sheet/metal/small_stack = list(CAT_ENGSUP, "Metal x10", METAL_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/stack/sheet/plasteel/small_stack = list(CAT_ENGSUP, "Plasteel x10", PLASTEEL_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/stack/sandbags_empty/half = list(CAT_ENGSUP, "Sandbags x25", SANDBAG_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/tool/pickaxe/plasmacutter = list(CAT_ENGSUP, "Plasma cutter", 20, "black"),
		/obj/item/storage/box/minisentry = list(CAT_ENGSUP, "UA-580 point defense sentry kit", 26, "black"),
		/obj/item/explosive/plastique = list(CAT_ENGSUP, "Plastique explosive", 3, "black"),
		/obj/item/detpack = list(CAT_ENGSUP, "Detonation pack", 5, "black"),
		/obj/item/tool/shovel/etool = list(CAT_ENGSUP, "Entrenching tool", 1, "black"),
		/obj/item/binoculars/tactical/range = list(CAT_ENGSUP, "Range Finder", 10, "black"),
		/obj/item/cell/high = list(CAT_ENGSUP, "High capacity powercell", 1, "black"),
		/obj/item/storage/box/explosive_mines = list(CAT_ENGSUP, "M20 mine box", 18, "black"),
		/obj/item/storage/box/explosive_mines/large = list(CAT_ENGSUP, "Large M20 mine box", 35, "black"),
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_ENGSUP, "Pack of Razorburn grenades", 11, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_ENGSUP, "Razorburn canister", 7, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_ENGSUP, "Razorburn grenade", 3, "black"),
		/obj/item/multitool = list(CAT_ENGSUP, "Multitool", 1, "black"),
		/obj/item/circuitboard/general = list(CAT_ENGSUP, "General circuit board", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_ENGSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/item/stack/voucher/sentry = list(CAT_ENGSUP, "UA 571-C Base defense sentry voucher", 26, "black"),
	))

GLOBAL_LIST_INIT(medic_gear_listed_products, list(
		/obj/effect/essentials_set/medic = list(CAT_ESS, "Essential Medic Set", 0, "white"),
		/obj/item/storage/pill_bottle/meralyne = list(CAT_MEDSUP, "Meralyne pills", 16, "orange"),
		/obj/item/storage/pill_bottle/dermaline = list(CAT_MEDSUP, "Dermaline pills", 16, "orange"),
		/obj/item/storage/pill_bottle/paracetamol = list(CAT_MEDSUP, "Paracetamol pills", 8, "orange"),
		/obj/item/storage/pill_bottle/tricordrazine = list(CAT_MEDSUP, "Tricordrazine pills", 8, "black"),
		/obj/item/storage/syringe_case/meralyne = list(CAT_MEDSUP, "syringe Case (120u Meralyne)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/meralyne = list(CAT_MEDSUP, "hypospray (60u Meralyne)", 8, "orange"), //half the units of the mera case half the price
		/obj/item/storage/syringe_case/dermaline = list(CAT_MEDSUP, "syringe Case (120u Dermaline)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/dermaline = list(CAT_MEDSUP, "hypospray (60u dermaline)", 8, "orange"), //half the units of the derm case half the price
		/obj/item/storage/syringe_case/meraderm = list(CAT_MEDSUP, "syringe Case (120u Meraderm)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/meraderm = list(CAT_MEDSUP, "hypospray (60u Meraderm)", 8, "orange"), //half the units of the meraderm case half the price
		/obj/item/storage/syringe_case/nanoblood = list(CAT_MEDSUP, "syringe Case (120u Nanoblood)", 5, "black"),
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = list(CAT_MEDSUP, "hypospray (60u Nanoblood)", 3, "black"), //bit more than half of the nanoblood case
		/obj/item/storage/syringe_case/tricordrazine = list(CAT_MEDSUP, "syringe Case (120u Tricordrazine)", 5, "black"),
		/obj/item/reagent_containers/hypospray/advanced/tricordrazine = list(CAT_MEDSUP, "hypospray (60u Tricordrazine)", 3, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_MEDSUP, "Injector (Advanced)", 5, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = list(CAT_MEDSUP, "Injector (QuickclotPlus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = list(CAT_MEDSUP, "Injector (Peridaxon Plus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_MEDSUP, "Injector (Synaptizine)", 4, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline = list(CAT_MEDSUP, "Injector (Neuraline)", 14, "orange"),
		/obj/item/reagent_containers/hypospray/advanced = list(CAT_MEDSUP, "Advanced hypospray", 2, "black"),
		/obj/item/reagent_containers/hypospray/advanced/big = list(CAT_MEDSUP, "Big hypospray", 10, "black"),
		/obj/item/clothing/glasses/hud/health = list(CAT_MEDSUP, "Medical HUD glasses", 2, "black"),
	))

GLOBAL_LIST_INIT(leader_gear_listed_products, list(
		/obj/effect/essentials_set/leader = list(CAT_ESS, "Essential SL Set", 0, "white"),
		/obj/item/beacon/supply_beacon = list(CAT_LEDSUP, "Supply beacon", 10, "black"),
		/obj/item/beacon/orbital_bombardment_beacon = list(CAT_LEDSUP, "Orbital beacon", 15, "black"),
		/obj/item/tool/shovel/etool = list(CAT_LEDSUP, "Entrenching tool", 1, "black"),
		/obj/item/stack/sandbags_empty/half = list(CAT_LEDSUP, "Sandbags x25", SANDBAG_PRICE_IN_GEAR_VENDOR, "black"),
		/obj/item/explosive/plastique = list(CAT_LEDSUP, "Plastique explosive", 3, "black"),
		/obj/item/detpack = list(CAT_LEDSUP, "Detonation pack", 5, "black"),
		/obj/item/explosive/grenade/smokebomb = list(CAT_LEDSUP, "Smoke grenade", 2, "black"),
		/obj/item/explosive/grenade/cloakbomb = list(CAT_LEDSUP, "Cloak grenade", 7, "black"),
		/obj/item/explosive/grenade/incendiary = list(CAT_LEDSUP, "M40 HIDP incendiary grenade", 3, "black"),
		/obj/item/explosive/grenade/frag = list(CAT_LEDSUP, "M40 HEDP grenade", 3, "black"),
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_LEDSUP, "Pack of Razorburn grenades", 24, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_LEDSUP, "Razorburn canister", 21, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_LEDSUP, "Razorburn grenade", 6, "black"),
		/obj/item/weapon/gun/flamer = list(CAT_LEDSUP, "Flamethrower", 12, "black"),
		/obj/item/ammo_magazine/flamer_tank = list(CAT_LEDSUP, "Flamethrower tank", 4, "black"),
		/obj/item/whistle = list(CAT_LEDSUP, "Whistle", 5, "black"),
		/obj/item/radio = list(CAT_LEDSUP, "Station bounced radio", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_LEDSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/item/motiondetector = list(CAT_LEDSUP, "Motion detector", 5, "black"),
		/obj/item/storage/firstaid/adv = list(CAT_LEDSUP, "Advanced firstaid kit", 10, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_MEDSUP, "Injector (Synaptizine)", 10, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_MEDSUP, "Injector (Advanced)", 15, "orange"),
		/obj/item/storage/box/zipcuffs = list(CAT_LEDSUP, "Ziptie box", 5, "black"),
		/obj/structure/closet/bodybag/tarp = list(CAT_LEDSUP, "V1 thermal-dampening tarp", 5, "black"),
		/obj/item/storage/box/m94/cas = list(CAT_LEDSUP, "CAS flare box", 10, "orange"),
		/obj/item/deployable_camera = list(CAT_LEDSUP, "Deployable Overwatch Camera", 2, "orange"),
	))

///Assoc list linking the job title with their specific points vendor
GLOBAL_LIST_INIT(job_specific_points_vendor, list(
	SQUAD_ENGINEER = GLOB.engineer_gear_listed_products,
	SQUAD_CORPSMAN = GLOB.medic_gear_listed_products,
	SQUAD_LEADER = GLOB.leader_gear_listed_products,
))


//List of all visible and accessible slot on the loadout maker
GLOBAL_LIST_INIT(visible_item_slot_list, list(
	slot_head_str,
	slot_back_str,
	slot_wear_mask_str,
	slot_glasses_str,
	slot_w_uniform_str,
	slot_wear_suit_str,
	slot_gloves_str,
	slot_shoes_str,
	slot_s_store_str,
	slot_belt_str,
	slot_l_store_str,
	slot_r_store_str,
))

///List of all additional item slot used by the admin loadout build mode
GLOBAL_LIST_INIT(additional_admin_item_slot_list, list(
	slot_l_hand_str,
	slot_r_hand_str,
	slot_wear_id_str,
	slot_ear_str,
))

///All the vendor types which the automated loadout vendor can take items from
GLOBAL_LIST_INIT(loadout_linked_vendor, list(
	/obj/machinery/vending/marine/shared,
	/obj/machinery/vending/uniform_supply,
	/obj/machinery/vending/armor_supply,
	/obj/machinery/vending/marineFood,
	/obj/machinery/vending/MarineMed,
))

GLOBAL_LIST_INIT(marine_clothes_listed_products, list(
		/obj/effect/essentials_set/basic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/effect/essentials_set/basicmodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "Utility belt", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "orange"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "orange"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt harness", 0, "black"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/standard = list(CAT_HEL, "Regular helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/med_lolipops  = list(CAT_POU, "Combat lolipop pouch", 0,"orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0,"black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0,"black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0,"black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0,"black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0,"orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0,"black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0,"orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0,"black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0,"black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0,"black"),
		/obj/item/attachable/scope/mini = list(CAT_ATT, "Mini scope", 0,"black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0,"orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0,"black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0,"black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0,"black"),
		/obj/item/clothing/mask/bandanna = list(CAT_MAS, "Tan bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/green = list(CAT_MAS, "Green bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/white = list(CAT_MAS, "White bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/black = list(CAT_MAS, "Black bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/skull = list(CAT_MAS, "Skull bandanna", 0,"black"),
	))

GLOBAL_LIST_INIT(engineer_clothes_listed_products, list(
		/obj/effect/essentials_set/basic_engineer = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_engineermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel/tech = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "Welderpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/utility/full = list(CAT_BEL, "Tool belt", 0, "white"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/tech  = list(CAT_HEL, "Regular engineer helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/construction = list(CAT_POU, "Construction pouch", 0, "orange"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tools pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/med_lolipops  = list(CAT_POU, "Combat lolipop pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(medic_clothes_listed_products, list(
		/obj/effect/essentials_set/basic_medic = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_medicmodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel/corpsman = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/clothing/tie/storage/white_vest/medic = list(CAT_WEB, "Corpsman white vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/medicLifesaver = list(CAT_BEL, "Lifesaver medic belt", 0, "orange"),
		/obj/item/storage/belt/medical = list(CAT_BEL, "Medical belt", 0, "black"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/corpsman  = list(CAT_HEL, "Regular corpsman helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/autoinjector/advanced/full = list(CAT_POU, "Advanced Autoinjector pouch", 0, "orange"),
		/obj/item/storage/pouch/hypospray/corps/full = list(CAT_POU, "Advanced hypospray pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit/full = list(CAT_POU, "Medkit pouch", 0, "orange"),
		/obj/item/storage/pouch/med_lolipops  = list(CAT_POU, "Combat lolipop pouch", 0,"orange"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(smartgunner_clothes_listed_products, list(
		/obj/effect/essentials_set/basic_smartgunner = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_smartgunnermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/standard = list(CAT_HEL, "Regular helmet", 0, "black"),
		/obj/item/clothing/head/helmet/marine/heavy = list(CAT_HEL, "Heavy helmet", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "orange"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "orange"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "orange"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/med_lolipops  = list(CAT_POU, "Combat lolipop pouch", 0,"orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(leader_clothes_listed_products, list(
		/obj/effect/essentials_set/basic_squadleader = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_squadleadermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/leader  = list(CAT_HEL, "Regular leader helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/med_lolipops  = list(CAT_POU, "Combat lolipop pouch", 0,"orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

///Assoc list linking the job title with their specific clothes vendor
GLOBAL_LIST_INIT(job_specific_clothes_vendor, list(
	SQUAD_MARINE = GLOB.marine_clothes_listed_products,
	SQUAD_ENGINEER = GLOB.engineer_clothes_listed_products,
	SQUAD_CORPSMAN = GLOB.medic_clothes_listed_products,
	SQUAD_SMARTGUNNER = GLOB.smartgunner_clothes_listed_products,
	SQUAD_LEADER = GLOB.leader_clothes_listed_products,
))

GLOBAL_LIST_INIT(loadout_role_essential_set, list(
	SQUAD_ENGINEER = list (
		/obj/item/explosive/plastique = 1,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/clothing/gloves/marine/insulated = 1,
		/obj/item/cell/high = 1,
		/obj/item/tool/shovel/etool = 1,
		/obj/item/lightreplacer = 1,
		/obj/item/circuitboard/general = 1,
	),
	SQUAD_CORPSMAN = list(
		/obj/item/bodybag/cryobag = 1,
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/roller/medevac = 1,
		/obj/item/medevac_beacon = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/storage/firstaid/adv = 1,
		/obj/item/clothing/glasses/hud/health = 1,
	),
	SQUAD_SMARTGUNNER = list(
		/obj/item/clothing/glasses/night/m56_goggles = 1,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun = 1,
		/obj/item/ammo_magazine/standard_smartmachinegun = 3,
	),
	SQUAD_LEADER = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/beacon/supply_beacon = 2,
		/obj/item/beacon/orbital_bombardment_beacon = 1,
		/obj/item/whistle = 1,
		/obj/item/radio = 1,
		/obj/item/motiondetector = 1,
		/obj/item/binoculars/tactical = 1,
		/obj/item/pinpointer/pool = 1,
		/obj/item/clothing/glasses/hud/health = 1,
	)
))

///Items that should be saved in loadouts no matter what
GLOBAL_LIST_INIT(bypass_loadout_check_item, typecacheof(list(
	/obj/item/clothing/under/marine,
)))

///Storage items that will always have their default content
GLOBAL_LIST_INIT(bypass_storage_content_save, typecacheof(list(
	/obj/item/storage/box/MRE,
	/obj/item/storage/pill_bottle/packet,
)))

///List of all supported job titles by the loadout vendors
GLOBAL_LIST_INIT(loadout_job_supported, list(
	SQUAD_MARINE,
	SQUAD_ENGINEER,
	SQUAD_CORPSMAN,
	SQUAD_SMARTGUNNER,
	SQUAD_LEADER,
))


//Defines use for the visualisation of loadouts
#define NO_OFFSET "0%"
#define NO_SCALING 1
#define MODULAR_ARMOR_OFFSET_Y "-10%"
#define MODULAR_ARMOR_SCALING 1.2

///The maximum number of loadouts one player can have
#define MAXIMUM_LOADOUT 50

/// The currently accepted loadout version, all other loadouts will be erased from savefiles
#define CURRENT_LOADOUT_VERSION 5

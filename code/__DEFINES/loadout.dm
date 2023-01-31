
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
#define CAT_GLA "GLASSES"
#define CAT_MAS "MASKS"
#define CAT_MOD "JAEGER STORAGE MODULES"
#define CAT_ARMMOD "JAEGER ARMOR MODULES"

#define CAT_MEDSUP "MEDICAL SUPPLIES"
#define CAT_ENGSUP "ENGINEERING SUPPLIES"
#define CAT_LEDSUP "LEADER SUPPLIES"
#define CAT_SGSUP "SMARTGUNNER SUPPLIES"
#define CAT_LOAD "LOADOUT"


GLOBAL_LIST_INIT(marine_selector_cats, list(
		CAT_MOD = 1,
		CAT_ARMMOD = 1,
		CAT_STD = 1,
		CAT_SHO = 1,
		CAT_HEL = 1,
		CAT_AMR = 1,
		CAT_GLO = 1,
		CAT_EAR = 1,
		CAT_BAK = 1,
		CAT_WEB = 1,
		CAT_BEL = 1,
		CAT_GLA = 1,
		CAT_MAS = 1,
		CAT_ESS = 1,
		CAT_POU = 2,
	))

#define METAL_PRICE_IN_GEAR_VENDOR 2
#define PLASTEEL_PRICE_IN_GEAR_VENDOR 4
#define SANDBAG_PRICE_IN_GEAR_VENDOR 5

GLOBAL_LIST_INIT(marine_gear_listed_products, list())

GLOBAL_LIST_INIT(engineer_gear_listed_products, list(
		/obj/effect/vendor_bundle/engi = list(CAT_ESS, "Essential Engineer Set", 0, "white"),
		/obj/item/stack/sheet/metal/small_stack = list(CAT_ENGSUP, "Metal x10", METAL_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/stack/sheet/plasteel/small_stack = list(CAT_ENGSUP, "Plasteel x10", PLASTEEL_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/stack/sandbags_empty/half = list(CAT_ENGSUP, "Sandbags x25", SANDBAG_PRICE_IN_GEAR_VENDOR, "orange"),
		/obj/item/weapon/shield/riot/marine/deployable = list(CAT_ENGSUP, "TL-182 deployable shield", 3, "orange"),
		/obj/item/tool/weldingtool/hugetank = list(CAT_ENGSUP, "High-capacity industrial blowtorch", 5, "black"),
		/obj/item/clothing/glasses/welding/superior = list(CAT_ENGSUP, "Superior welding goggles", 2, "black"),
		/obj/item/armor_module/module/welding/superior = list(CAT_ENGSUP, "Superior welding module", 2, "black"),
		/obj/item/tool/pickaxe/plasmacutter = list(CAT_ENGSUP, "Plasma cutter", 20, "black"),
		/obj/item/explosive/plastique = list(CAT_ENGSUP, "Plastique explosive", 2, "black"),
		/obj/item/detpack = list(CAT_ENGSUP, "Detonation pack", 5, "black"),
		/obj/item/storage/box/minisentry = list(CAT_ENGSUP, "ST-580 point defense sentry kit", 50, "black"),
		/obj/structure/closet/crate/uav_crate = list(CAT_ENGSUP, "Iguana Unmanned Vehicle", 50, "black"),
		/obj/item/attachable/buildasentry = list(CAT_ENGSUP, "Build-A-Sentry Attachment", 30, "black"),
		/obj/item/binoculars/tactical/range = list(CAT_ENGSUP, "Range Finder", 10, "black"),
		/obj/item/ai_target_beacon = list(CAT_ENGSUP, "AI remote targeting module", 10, "black"),
		/obj/item/tool/handheld_charger = list(CAT_ENGSUP, "Hand-held cell charger", 3, "black"),
		/obj/item/cell/high = list(CAT_ENGSUP, "High capacity powercell", 1, "black"),
		/obj/item/cell/rtg/small = list(CAT_ENGSUP, "Recharger powercell", 5, "black"),
		/obj/item/cell/rtg/large = list(CAT_ENGSUP, "Large recharger powercell", 15, "black"),
		/obj/effect/teleporter_linker = list(CAT_ENGSUP, "Teleporters", 25, "black"),
		/obj/item/storage/box/explosive_mines = list(CAT_ENGSUP, "M20 mine box", 18, "black"),
		/obj/item/storage/box/explosive_mines/large = list(CAT_ENGSUP, "Large M20 mine box", 35, "black"),
		/obj/item/minelayer = list(CAT_ENGSUP, "M21 APRDS \"Minelayer\"", 5, "black"),
		/obj/item/minerupgrade/overclock = list(CAT_ENGSUP, "Mining well overclock upgrade", 4, "black"),
		/obj/item/minerupgrade/reinforcement = list(CAT_ENGSUP, "Mining well reinforcement upgrade", 4, "black"),
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_ENGSUP, "Pack of Razorburn grenades", 11, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_ENGSUP, "Razorburn canister", 7, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_ENGSUP, "Razorburn grenade", 3, "black"),
	))

GLOBAL_LIST_INIT(medic_gear_listed_products, list(
		/obj/effect/vendor_bundle/medic = list(CAT_ESS, "Essential Medic Set", 0, "white"),
		/obj/item/storage/pill_bottle/meralyne = list(CAT_MEDSUP, "Meralyne pills", 16, "orange"),
		/obj/item/storage/pill_bottle/dermaline = list(CAT_MEDSUP, "Dermaline pills", 16, "orange"),
		/obj/item/storage/pill_bottle/paracetamol = list(CAT_MEDSUP, "Paracetamol pills", 8, "black"),
		/obj/item/storage/syringe_case/meralyne = list(CAT_MEDSUP, "syringe Case (120u Meralyne)", 16, "black"),
		/obj/item/reagent_containers/hypospray/advanced/meralyne = list(CAT_MEDSUP, "hypospray (60u Meralyne)", 8, "black"), //half the units of the mera case half the price
		/obj/item/storage/syringe_case/dermaline = list(CAT_MEDSUP, "syringe Case (120u Dermaline)", 16, "black"),
		/obj/item/reagent_containers/hypospray/advanced/dermaline = list(CAT_MEDSUP, "hypospray (60u dermaline)", 8, "black"), //half the units of the derm case half the price
		/obj/item/storage/syringe_case/meraderm = list(CAT_MEDSUP, "syringe Case (120u Meraderm)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/meraderm = list(CAT_MEDSUP, "hypospray (60u Meraderm)", 8, "black"), //half the units of the meraderm case half the price
		/obj/item/storage/syringe_case/nanoblood = list(CAT_MEDSUP, "syringe Case (120u Nanoblood)", 5, "black"),
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = list(CAT_MEDSUP, "hypospray (60u Nanoblood)", 3, "orange"), //bit more than half of the nanoblood case
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_MEDSUP, "Injector (Advanced)", 5, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = list(CAT_MEDSUP, "Injector (QuickclotPlus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = list(CAT_MEDSUP, "Injector (Peridaxon Plus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_MEDSUP, "Injector (Synaptizine)", 4, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline = list(CAT_MEDSUP, "Injector (Neuraline)", 14, "orange"),
		/obj/item/reagent_containers/hypospray/advanced = list(CAT_MEDSUP, "Hypospray", 2, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/big = list(CAT_MEDSUP, "Big hypospray", 10, "orange"),
		/obj/item/clothing/glasses/hud/health = list(CAT_MEDSUP, "Medical HUD glasses", 2, "black"),
		/obj/item/defibrillator/gloves = list(CAT_MEDSUP, "Advanced medical gloves", 5, "black"),
	))

GLOBAL_LIST_INIT(leader_gear_listed_products, list(
		/obj/effect/vendor_bundle/leader = list(CAT_ESS, "Essential SL Set", 0, "white"),
		/obj/item/whistle = list(CAT_LEDSUP, "Whistle", 5, "black"),
		/obj/item/beacon/supply_beacon = list(CAT_LEDSUP, "Supply beacon", 10, "black"),
		/obj/item/fulton_extraction_pack = list(CAT_LEDSUP, "Fulton Extraction Pack", 20, "orange"),
		/obj/item/deployable_camera = list(CAT_LEDSUP, "Deployable Overwatch Camera", 2, "orange"),
		/obj/item/stack/sandbags_empty/half = list(CAT_LEDSUP, "Sandbags x25", SANDBAG_PRICE_IN_GEAR_VENDOR, "black"),
		/obj/item/explosive/plastique = list(CAT_LEDSUP, "Plastique explosive", 2, "black"),
		/obj/item/detpack = list(CAT_LEDSUP, "Detonation pack", 5, "black"),
		/obj/item/assembly/signaler = list(CAT_LEDSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/structure/closet/bodybag/tarp = list(CAT_LEDSUP, "V1 thermal-dampening tarp", 5, "black"),
		/obj/item/explosive/grenade/smokebomb/cloak = list(CAT_LEDSUP, "Cloak grenade", 7, "black"),
		/obj/item/explosive/grenade/incendiary = list(CAT_LEDSUP, "M40 HIDP incendiary grenade", 3, "black"),
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_LEDSUP, "Pack of Razorburn grenades", 24, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_LEDSUP, "Razorburn canister", 21, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_LEDSUP, "Razorburn grenade", 6, "black"),
		/obj/item/weapon/gun/flamer/big_flamer/marinestandard = list(CAT_LEDSUP, "FL-84 flamethrower", 12, "black"),
		/obj/item/ammo_magazine/flamer_tank = list(CAT_LEDSUP, "Flamethrower tank", 4, "black"),
		/obj/item/storage/backpack/marine/radiopack = list(CAT_LEDSUP, "Radio Pack", 15, "black"),
		/obj/item/storage/firstaid/adv = list(CAT_LEDSUP, "Advanced firstaid kit", 10, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_LEDSUP, "Injector (Synaptizine)", 10, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_LEDSUP, "Injector (Advanced)", 15, "orange"),
	))

//A way to give them everything at once that still works with loadouts would be nice, but barring that make sure that your point calculation is set up so they don't get more than what they're supposed to
GLOBAL_LIST_INIT(smartgunner_gear_listed_products, list(
	/obj/item/clothing/glasses/night/m56_goggles = list(CAT_ESS, "KLTD Smart Goggles", 0, "white"),
	/obj/item/weapon/gun/rifle/standard_smartmachinegun = list(CAT_SGSUP, "SG-29 Smartmachinegun", 29, "orange"), //If a smartgunner buys a SG-29, then they will have 16 points to purchase 4 SG-29 drums
	/obj/item/ammo_magazine/standard_smartmachinegun = list(CAT_SGSUP, "SG-29 Ammo Drum", 4, "black"),
	/obj/item/weapon/gun/minigun/smart_minigun = list(CAT_SGSUP, "SG-85 Handheld Gatling Gun", 27, "orange"), //If a smartgunner buys a SG-85, then they should be able to buy only 1 powerpack and 2 ammo bins
	/obj/item/ammo_magazine/minigun_powerpack/smartgun =  list(CAT_SGSUP, "SG-85 Powerpack", 10, "black"),
	/obj/item/ammo_magazine/packet/smart_minigun = list(CAT_SGSUP, "SG-85 Ammo Bin", 4, "black"),
	))


///Assoc list linking the job title with their specific points vendor
GLOBAL_LIST_INIT(job_specific_points_vendor, list(
	SQUAD_MARINE = GLOB.marine_gear_listed_products,
	SQUAD_ENGINEER = GLOB.engineer_gear_listed_products,
	SQUAD_CORPSMAN = GLOB.medic_gear_listed_products,
	SQUAD_LEADER = GLOB.leader_gear_listed_products,
	SQUAD_SMARTGUNNER = GLOB.smartgunner_gear_listed_products,
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

///All the vendor types which the automated loadout vendor can take items from.
GLOBAL_LIST_INIT(loadout_linked_vendor, list(
	FACTION_NEUTRAL = list(
		/obj/machinery/vending/weapon,
		/obj/machinery/vending/uniform_supply,
		/obj/machinery/vending/armor_supply,
		/obj/machinery/vending/marineFood,
		/obj/machinery/vending/MarineMed,
		/obj/machinery/vending/cigarette,
		/obj/machinery/vending/tool,
	),
	FACTION_TERRAGOV = list(
		/obj/machinery/vending/weapon/hvh/team_one,
		/obj/machinery/vending/uniform_supply,
		/obj/machinery/vending/armor_supply/loyalist,
		/obj/machinery/vending/marineFood,
		/obj/machinery/vending/MarineMed,
		/obj/machinery/vending/cigarette,
		/obj/machinery/vending/tool,
	),
	FACTION_TERRAGOV_REBEL = list(
		/obj/machinery/vending/weapon/hvh,
		/obj/machinery/vending/uniform_supply,
		/obj/machinery/vending/armor_supply/rebel,
		/obj/machinery/vending/marineFood,
		/obj/machinery/vending/MarineMed/rebel,
		/obj/machinery/vending/medical/rebel,
		/obj/machinery/vending/cigarette,
		/obj/machinery/vending/tool,
	),
	FACTION_VALHALLA = list(
		/obj/machinery/vending/weapon/valhalla,
		/obj/machinery/vending/uniform_supply,
		/obj/machinery/vending/armor_supply,
		/obj/machinery/vending/marineFood,
		/obj/machinery/vending/MarineMed/valhalla,
		/obj/machinery/vending/cigarette,
	),
	SQUAD_CORPSMAN = list(
		/obj/machinery/vending/medical/shipside,
	)
))

GLOBAL_LIST_INIT(marine_clothes_listed_products, list(
		/obj/effect/vendor_bundle/basic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/robot = list(CAT_STD, "Essential Combat Robot Kit", 0, "white"),
		/obj/effect/vendor_bundle/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_light = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/clothing/suit/modular/xenonauten/rownin = list(CAT_AMR, "Rownin Skeleton", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/light = list(CAT_AMR, "Combat robot light armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot = list(CAT_AMR, "Combat robot medium armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/heavy = list(CAT_AMR, "Combat robot heavy armor plating", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/armor_module/storage/uniform/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "Utility belt", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "orange"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "orange"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt harness", 0, "black"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/robot/light = list(CAT_HEL, "Light head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot = list(CAT_HEL, "Medium head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/heavy = list(CAT_HEL, "Heavy head robotic armor plating", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "First aid pouch", 0,"orange"),
		/obj/item/storage/pouch/medical_injectors/firstaid = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0,"black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0,"black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0,"black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0,"black"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Arrowhead Energy Shield System", 0 , "black"),
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
		/obj/effect/vendor_bundle/basic_engineer = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger_engineer = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/robot = list(CAT_STD, "Essential Combat Robot Kit", 0, "white"),
		/obj/item/clothing/glasses/welding = list(CAT_GLA, "Welding Goggles", 0, "white"),
		/obj/item/clothing/glasses/meson = list(CAT_GLA, "Optical Meson Scanner", 0, "white"),
		/obj/effect/vendor_bundle/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/robot/light = list(CAT_AMR, "Combat robot light armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot = list(CAT_AMR, "Combat robot medium armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/heavy = list(CAT_AMR, "Combat robot heavy armor plating", 0, "black"),
		/obj/effect/vendor_bundle/xenonauten_light = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel/tech = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/holster/blade/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "Welderpack", 0, "black"),
		/obj/item/storage/backpack/marine/radiopack = list(CAT_BAK, "Radio Pack", 0, "black"),
		/obj/item/storage/backpack/dispenser = list(CAT_BAK, "Dispenser", 0, "black"),
		/obj/item/armor_module/storage/uniform/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/utility/full = list(CAT_BEL, "Tool belt", 0, "white"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/beret/eng = list(CAT_HEL, "Engineering beret", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/light = list(CAT_HEL, "Light head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot = list(CAT_HEL, "Medium head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/heavy = list(CAT_HEL, "Heavy head robotic armor plating", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/construction = list(CAT_POU, "Construction pouch", 0, "orange"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tools pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "First aid pouch", 0, "orange"),
		/obj/item/storage/pouch/medical_injectors/firstaid = list(CAT_POU, "Combat injector pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Arrowhead Energy Shield System", 0 , "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(medic_clothes_listed_products, list(
		/obj/effect/vendor_bundle/basic_medic = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger_medic = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/robot = list(CAT_STD, "Essential Combat Robot Kit", 0, "white"),
		/obj/effect/vendor_bundle/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_light = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/robot/light = list(CAT_AMR, "Combat robot light armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot = list(CAT_AMR, "Combat robot medium armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/heavy = list(CAT_AMR, "Combat robot heavy armor plating", 0, "black"),
		/obj/item/storage/backpack/marine/satchel/corpsman = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/armor_module/storage/uniform/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/armor_module/storage/uniform/white_vest = list(CAT_WEB, "Corpsman white vest", 0, "black"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/lifesaver/full = list(CAT_BEL, "Lifesaver belt", 0, "orange"),
		/obj/item/storage/belt/rig/medical = list(CAT_BEL, "Rig belt", 0, "black"),
		/obj/item/storage/belt/hypospraybelt = list(CAT_BEL, "Hypospray belt", 0, "black"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/robot/light = list(CAT_HEL, "Light head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot = list(CAT_HEL, "Medium head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/heavy = list(CAT_HEL, "Heavy head robotic armor plating", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/medical_injectors/medic = list(CAT_POU, "Advanced Autoinjector pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit/medic = list(CAT_POU, "Medkit pouch", 0, "orange"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Arrowhead Energy Shield System", 0 , "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(smartgunner_clothes_listed_products, list(
		/obj/effect/vendor_bundle/basic_smartgunner = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger_smartgunner = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/robot = list(CAT_STD, "Essential Combat Robot Kit", 0, "white"),
		/obj/effect/vendor_bundle/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_light = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/robot/light = list(CAT_AMR, "Combat robot light armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot = list(CAT_AMR, "Combat robot medium armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/heavy = list(CAT_AMR, "Combat robot heavy armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/light = list(CAT_HEL, "Light head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot = list(CAT_HEL, "Medium head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/heavy = list(CAT_HEL, "Heavy head robotic armor plating", 0, "black"),
		/obj/item/armor_module/storage/uniform/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "orange"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "orange"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "orange"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/medical_injectors/firstaid = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "First aid pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	))

GLOBAL_LIST_INIT(leader_clothes_listed_products, list(
		/obj/effect/vendor_bundle/basic_squadleader = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger_squadleader = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/robot = list(CAT_STD, "Essential Combat Robot Kit", 0, "white"),
		/obj/effect/vendor_bundle/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/vendor_bundle/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/vendor_bundle/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/vendor_bundle/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "orange"),
		/obj/effect/vendor_bundle/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/vendor_bundle/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/effect/vendor_bundle/xenonauten_light/leader = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium/leader = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy/leader = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/robot/light = list(CAT_AMR, "Combat robot light armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot = list(CAT_AMR, "Combat robot medium armor plating", 0, "black"),
		/obj/item/clothing/suit/storage/marine/robot/heavy = list(CAT_AMR, "Combat robot heavy armor plating", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/holster/blade/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/armor_module/storage/uniform/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/robot/light = list(CAT_HEL, "Light head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot = list(CAT_HEL, "Medium head robotic armor plating", 0, "black"),
		/obj/item/clothing/head/helmet/marine/robot/heavy = list(CAT_HEL, "Heavy head robotic armor plating", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/medical_injectors/firstaid = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "First aid pouch", 0, "orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Arrowhead Energy Shield System", 0 , "black"),
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
		/obj/item/clothing/gloves/marine/insulated = 1,
		/obj/item/cell/high = 1,
		/obj/item/lightreplacer = 1,
		/obj/item/circuitboard/apc = 1,
		/obj/item/clothing/under/marine/engineer = 1,
		/obj/item/tool/surgery/solderingtool = 1,
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
		/obj/item/clothing/under/marine/corpsman = 1,
	),
	SQUAD_SMARTGUNNER = list(
		/obj/item/clothing/glasses/night/m56_goggles = 1,
	),
	SQUAD_LEADER = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/beacon/supply_beacon = 2,
		/obj/item/whistle = 1,
		/obj/item/binoculars/tactical = 1,
		/obj/item/pinpointer = 1,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/clothing/head/modular/marine/m10x/leader = 1,
	)
))

///Storage items that will always have their default content
GLOBAL_LIST_INIT(bypass_storage_content_save, typecacheof(list(
	/obj/item/storage/box/MRE,
	/obj/item/storage/pill_bottle/packet,
)))

//Defines use for the visualisation of loadouts
#define NO_OFFSET "0%"
#define NO_SCALING 1
#define MODULAR_ARMOR_OFFSET_Y "-10%"
#define MODULAR_ARMOR_SCALING 1.2

///The maximum number of loadouts one player can have
#define MAXIMUM_LOADOUT 50

/// The current loadout version
#define CURRENT_LOADOUT_VERSION 10

GLOBAL_LIST_INIT(accepted_loadout_versions, list(5, 6, 7, 8, 9, 10))

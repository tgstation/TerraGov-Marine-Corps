

/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	item_state_worn = TRUE
	flags_equip_slot = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	w_class = WEIGHT_CLASS_BULKY
	allow_drawing_method = TRUE



/obj/item/storage/belt/equipped(mob/user, slot)
	if(slot == SLOT_BELT)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/belt/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()

/obj/item/storage/belt/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		/obj/item/clothing/mask/luchador,
	)

/*============================//MARINE BELTS\\==================================
=======================================================================*/

/obj/item/storage/belt/utility
	name = "\improper M276 pattern toolbelt rig" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version lacks any combat functionality, and is commonly used by engineers to transport important tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wrench,
		/obj/item/tool/crowbar,
		/obj/item/stack/cable_coil,
		/obj/item/tool/multitool,
		/obj/item/flashlight,
		/obj/item/t_scanner,
		/obj/item/tool/analyzer,
		/obj/item/tool/taperoll/engineering,
		/obj/item/tool/extinguisher/mini,
		/obj/item/tool/shovel/etool,
	)

/obj/item/storage/belt/utility/full/Initialize(mapload)
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/tool/weldingtool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/tool/multitool(src)


/obj/item/storage/belt/utility/atmostech/Initialize(mapload)
	. = ..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/t_scanner(src)

/obj/item/storage/belt/medical_small
	name = "\improper M276 pattern light medical rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This lightweight configuration is often used for bulk carrying of medical supplies by marines."
	icon_state = "medicalbelt_small"
	item_state = "medicbag"
	storage_slots = 15
	max_storage_space = 30
	max_w_class = 3
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/dropper,
	)

/obj/item/storage/belt/lifesaver
	name = "\improper M276 pattern lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical,
	)

/obj/item/storage/belt/lifesaver/full/Initialize(mapload)  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/isotonic(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/quick/Initialize(mapload)  //quick load for combat patrol
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/full/upp
	name ="\improper Type 41 pattern lifesaver bag"
	desc = "The Type 41 load rig is the standard-issue LBE of the UPP military. This configuration mounts a satchel filled with a range of injectors and light medical supplies, common among medics and partisans."
	icon_state = "medicbag_upp"
	item_state = "medicbag_upp"


/obj/item/storage/belt/lifesaver/som
	name = "\improper S17 lifesaver bag"
	desc = "A belt with heavy origins from the belt used by paramedics and doctors in the old mining colonies."
	icon_state = "medicbag_som"
	item_state = "medicbag_som"

/obj/item/storage/belt/lifesaver/som/ert/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/som/quick/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/icc
	name = "\improper Modelle/129 lifesaver bag"
	desc = "A medical belt made from synthetic tan fibres, carries just about anything you would need to respond to traumatic injury in combat."
	icon_state = "medicbag_icc"
	item_state = "medicbag_icc"

/obj/item/storage/belt/lifesaver/icc/ert/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/rig
	name = "\improper M276 pattern medical storage rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport medical supplies and heavier medical tools."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 16
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 42

	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/stack/medical,
		/obj/item/bodybag,
		/obj/item/defibrillator,
		/obj/item/roller,
		/obj/item/tool/research,
	)

/obj/item/storage/belt/rig/medical/Initialize(mapload)  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/isotonic(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/bodybag/cryobag(src)
	new /obj/item/roller(src)
	new /obj/item/defibrillator(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/rig/research/Initialize(mapload)  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/defibrillator(src)
	new /obj/item/tool/research/excavation_tool(src)
	new /obj/item/tool/research/xeno_analyzer(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/hypospraybelt
	name = "\improper M276 pattern hypospray belt"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport hyposprays and reagent containers. You could probably fit a syringe case too."
	icon_state = "hypospraybelt"
	item_state = "medicbag"
	storage_slots = 21
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/syringe_case,
	)

/obj/item/storage/belt/hypospraybelt/Initialize(mapload)  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/bicaridine(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/tramadol(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/bicaridine(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/kelotane(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/tramadol(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/combatmix(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/dylovene(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/isotonic(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/spaceacillin(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/quickclot(src)
	new /obj/item/reagent_containers/hypospray/advanced/imialky(src)
	new /obj/item/reagent_containers/hypospray/advanced/hypervene(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/security
	name = "\improper M276 pattern security rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This configuration is commonly seen among TGMC Military Police and peacekeepers, though it can hold some light munitions."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 21
	can_hold = list(
		/obj/item/explosive/grenade/flashbang,
		/obj/item/explosive/grenade/chem_grenade/teargas,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/handful,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/weapon/baton,
		/obj/item/weapon/gun/energy/taser,
		/obj/item/tool/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/flashlight,
		/obj/item/radio/headset,
		/obj/item/tool/taperoll/police,
	)

	cant_hold = list(
		/obj/item/weapon/gun,
	)



/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 21

/obj/item/storage/belt/marine
	name = "\improper M276 pattern ammo load rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	icon_state = "marinebelt"
	item_state = "marinebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 18
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/explosive/grenade/flare/civilian,
		/obj/item/explosive/grenade/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/ammo_magazine/railgun,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_containers/food/snacks,
	)

/obj/item/storage/belt/marine/t18/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)

/obj/item/storage/belt/marine/t12/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)

/obj/item/storage/belt/marine/standard_skirmishrifle/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_skirmishrifle(src)

/obj/item/storage/belt/marine/standard_battlerifle/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)

/obj/item/storage/belt/marine/t90/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)

/obj/item/storage/belt/marine/secondary/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/smg/m25(src)
	new /obj/item/ammo_magazine/smg/m25(src)
	new /obj/item/ammo_magazine/smg/m25(src)
	new /obj/item/ammo_magazine/smg/m25(src)
	new /obj/item/ammo_magazine/smg/m25(src)
	new /obj/item/ammo_magazine/smg/m25(src)

/obj/item/storage/belt/marine/antimaterial/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper(src)

/obj/item/storage/belt/marine/tx8/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)

/obj/item/storage/belt/marine/combat_rifle/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)

/obj/item/storage/belt/marine/alf_machinecarbine/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)
	new /obj/item/ammo_magazine/rifle/alf_machinecarbine(src)

/obj/item/storage/belt/marine/auto_shotgun/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx15_slug(src)
	new /obj/item/ammo_magazine/rifle/tx15_slug(src)
	new /obj/item/ammo_magazine/rifle/tx15_slug(src)
	new /obj/item/ammo_magazine/rifle/tx15_flechette(src)
	new /obj/item/ammo_magazine/rifle/tx15_flechette(src)
	new /obj/item/ammo_magazine/rifle/tx15_flechette(src)

/obj/item/storage/belt/marine/te_cells/Initialize(mapload)
	. = ..()
	new /obj/item/cell/lasgun/lasrifle(src)
	new /obj/item/cell/lasgun/lasrifle(src)
	new /obj/item/cell/lasgun/lasrifle(src)
	new /obj/item/cell/lasgun/lasrifle(src)
	new /obj/item/cell/lasgun/lasrifle(src)
	new /obj/item/cell/lasgun/lasrifle(src)

/obj/item/storage/belt/marine/oicw/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)

/obj/item/storage/belt/marine/smartgun/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)

/obj/item/storage/belt/marine/target_rifle/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_smarttargetrifle(src)

/obj/item/storage/belt/marine/upp
	name = "\improper Type 41 pattern load rig"
	desc = "The Type 41 load rig is the standard-issue LBE of the USL pirates. The primary function of this belt is to provide easy access to mags for the Type 71 during operations. Despite being designed for the Type 71 weapon system, the pouches are modular enough to fit other types of ammo and equipment."
	icon_state = "upp_belt"
	item_state = "upp_belt"

//version full of type 71 mags
/obj/item/storage/belt/marine/upp/full/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)

/obj/item/storage/belt/marine/som
	name = "\improper S18 ammo belt"
	desc = "A belt with origins traced to the M276 ammo belt and some old colony security."
	icon_state = "som_belt"
	item_state = "som_belt"

/obj/item/storage/belt/marine/som/som_rifle/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/som(src)
	new /obj/item/ammo_magazine/rifle/som(src)
	new /obj/item/ammo_magazine/rifle/som(src)
	new /obj/item/ammo_magazine/rifle/som(src)
	new /obj/item/ammo_magazine/rifle/som(src)
	new /obj/item/ammo_magazine/rifle/som(src)

/obj/item/storage/belt/marine/som/som_rifle_ap/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/som/ap(src)
	new /obj/item/ammo_magazine/rifle/som/ap(src)
	new /obj/item/ammo_magazine/rifle/som/ap(src)
	new /obj/item/ammo_magazine/rifle/som/ap(src)
	new /obj/item/ammo_magazine/rifle/som/ap(src)
	new /obj/item/ammo_magazine/rifle/som/ap(src)

/obj/item/storage/belt/marine/som/som_smg/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/smg/som(src)
	new /obj/item/ammo_magazine/smg/som(src)
	new /obj/item/ammo_magazine/smg/som(src)
	new /obj/item/ammo_magazine/smg/som(src)
	new /obj/item/ammo_magazine/smg/som(src)
	new /obj/item/ammo_magazine/smg/som(src)

/obj/item/storage/belt/marine/som/som_smg_ap/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/smg/som/ap(src)
	new /obj/item/ammo_magazine/smg/som/ap(src)
	new /obj/item/ammo_magazine/smg/som/ap(src)
	new /obj/item/ammo_magazine/smg/som/ap(src)
	new /obj/item/ammo_magazine/smg/som/ap(src)
	new /obj/item/ammo_magazine/smg/som/ap(src)

/obj/item/storage/belt/marine/som/volkite/Initialize(mapload)
	. = ..()
	new /obj/item/cell/lasgun/volkite(src)
	new /obj/item/cell/lasgun/volkite(src)
	new /obj/item/cell/lasgun/volkite(src)
	new /obj/item/cell/lasgun/volkite(src)
	new /obj/item/cell/lasgun/volkite(src)
	new /obj/item/cell/lasgun/volkite(src)

/obj/item/storage/belt/marine/som/mpi_plum/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/plum(src)

/obj/item/storage/belt/marine/som/mpi_black/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/black(src)

/obj/item/storage/belt/marine/som/carbine/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine(src)

/obj/item/storage/belt/marine/som/carbine_black/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)
	new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black(src)

/obj/item/storage/belt/marine/icc
	name = "\improper Modello/120 ammo belt"
	desc = "A belt purpose made to carry ammo, made with a tan synthetic fibre."
	icon_state = "icc_belt"

/obj/item/storage/belt/marine/sectoid
	name = "\improper strange ammo belt"
	desc = "A belt made of a strong but unusual fabric, with clips to hold your equipment."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/explosive/grenade,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/tool/crowbar,
	)

/obj/item/storage/belt/shotgun
	name = "\improper shotgun shell load rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets."
	icon_state = "shotgunbelt"
	item_state = "shotgunbelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 14
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 28
	can_hold = list(/obj/item/ammo_magazine/handful)


/obj/item/storage/belt/shotgun/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/M = I
		if(CHECK_BITFIELD(M.flags_magazine, MAGAZINE_HANDFUL))
			return ..()
		if(M.flags_magazine & MAGAZINE_REFILLABLE)
			if(!M.current_rounds)
				to_chat(user, span_warning("[M] is empty."))
				return

			if(length(contents) >= storage_slots)
				to_chat(user, span_warning("[src] is full."))
				return


			to_chat(user, span_notice("You start refilling [src] with [M]."))
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(M.create_handful(), 1, user)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, span_notice("You refill [src] with [M]."))
			return TRUE

	return ..()

/obj/item/storage/belt/shotgun/flechette/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/mixed/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/som
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather."
	icon_state = "shotgunbelt_som"

/obj/item/storage/belt/shotgun/som/flechette/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/som/mixed/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/icc
	name = "\improper Modelle/121 shell load rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets, made with a synthetic tan fibre."
	icon_state = "shotgunbelt_icc"

/obj/item/storage/belt/shotgun/icc/flechette/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/icc/mixed/Initialize(mapload, ...)
	. = ..()
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/buckshot(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)
	new /obj/item/ammo_magazine/handful/flechette(src)

/obj/item/storage/belt/shotgun/martini
	name = "martini henry ammo belt"
	desc = "A belt good enough for holding all your .577/400 ball rounds."
	icon_state = ".557_belt"
	storage_slots = 12
	max_storage_space = 24

	draw_mode = 1

	flags_atom = DIRLOCK

/obj/item/storage/belt/shotgun/martini/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/item/storage/belt/shotgun/martini/update_icon()
	if(!length(contents))
		icon_state = initial(icon_state) + "_e"
		return
	icon_state = initial(icon_state)

	var/holding = round((length(contents) + 1) / 2)
	setDir(holding + round(holding/3))

/obj/item/storage/belt/shotgun/martini/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/new_mag = I
		if(new_mag.caliber != CALIBER_557)
			to_chat(user, span_notice("[src] can only be filled with .557/440 ball rifle rounds."))
			return
	. = ..()
	update_icon()

/obj/item/storage/belt/shotgun/martini/attack_hand(mob/living/user)
	if (loc != user)
		. = ..()
		for(var/mob/M in content_watchers)
			close(M)

	if(!draw_mode || !ishuman(user) && !length(contents))
		open(user)

	if(!length(contents))
		return

	var/obj/item/I = contents[length(contents)]
	if(!istype(I, /obj/item/ammo_magazine/handful))
		return

	var/obj/item/ammo_magazine/handful/existing_handful = I

	if(existing_handful.current_rounds == 1)
		user.put_in_hands(existing_handful)
		return

	existing_handful.create_handful(user, 1)
	update_icon()


/obj/item/storage/belt/knifepouch
	name="\improper M276 pattern knife rig"
	desc="The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is specially designed with six holsters to store throwing knives. Not commonly issued, but kept in service."
	icon_state="knifebelt"
	item_state="knifebelt"
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_TINY
	max_storage_space = 6
	draw_mode = TRUE
	can_hold = list(/obj/item/stack/throwing_knife)

/obj/item/storage/belt/knifepouch/Initialize(mapload)
	. = ..()
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)

/obj/item/storage/belt/grenade
	name="\improper M276 pattern M40 HEDP rig"
	desc="The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt"
	item_state="grenadebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 9
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 27
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/standard/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)

/obj/item/storage/belt/grenade/som
	name = "\improper S16 pattern grenade rig"
	desc = "A simple harness system available in many configurations. This version is designed to carry bulk quantities of grenades."
	icon_state = "grenadebelt_som"

/obj/item/storage/belt/grenade/som/standard/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/incendiary/som(src)
	new /obj/item/explosive/grenade/incendiary/som(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)

/obj/item/storage/belt/grenade/b17
	name = "\improper M276 pattern M40 HEDP rig Mk II"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 16
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 48
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/b17/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)

/obj/item/storage/belt/sparepouch
	name = "\improper G8 general utility pouch"
	desc = "A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines."
	storage_slots = null
	max_storage_space = 9
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	icon_state = "sparepouch"
	item_state = "sparepouch"

/obj/item/storage/belt/sparepouch/som
	name = "standard utility pouch"
	desc = "A small, lightweight pouch that can be clipped onto armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines. Made from genuine SOM leather."
	icon_state = "sparepouch_som"
	item_state = "som_belt"

/obj/item/storage/belt/protein_pack
	name = "\improper protein pack load rig"
	desc = "A storage belt designed to hold mass amounts of protein packs for those particuarly hungry marines."
	icon_state = "p_belt"
	item_state = "shotgunbelt"
	storage_slots = 20
	max_storage_space = 20
	max_w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/snacks/protein_pack)
	sprite_slots = 4

/obj/item/storage/belt/protein_pack/Initialize(mapload)
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/protein_pack(src)

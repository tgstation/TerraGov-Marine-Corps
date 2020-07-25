//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/guns/interact/rifle_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/cocked.ogg'
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	load_method = MAGAZINE //codex
	aim_slowdown = 0.35
	wield_delay = 0.6 SECONDS
	gun_skill_category = GUN_SKILL_RIFLES

	burst_amount = 3
	burst_delay = 0.2 SECONDS
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 40
	recoil_unwielded = 4
	damage_falloff_mult = 0.5


/obj/item/weapon/gun/rifle/unique_action(mob/user)
	return cock(user)


/obj/item/weapon/gun/rifle/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/rifle/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

//-------------------------------------------------------
//T-18 Carbine

/obj/item/weapon/gun/rifle/standard_carbine
    name = "\improper T-18 carbine"
    desc = "The T-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Lacks an automatic fire mode, but has a burst fire mode to improve damage output. Uses 10x24mm caseless ammunition."
    icon_state = "t18"
    item_state = "t18"
    fire_sound = "sound/weapons/guns/fire/t18.ogg"
   	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
    unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
    reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
    caliber = "10x24mm caseless" //codex
    max_shells = 32 //codex
   	force = 20
    current_mag = /obj/item/ammo_magazine/rifle/standard_carbine
    attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/stock/t18stock,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/compensator,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/attached_gun/shotgun)

    flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
    gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
    starting_attachment_types = list(/obj/item/attachable/stock/t18stock)
    attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 10, "rail_y" = 19, "under_x" = 18, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)

    fire_delay = 0.3 SECONDS
    burst_delay = 0.125 SECONDS
    accuracy_mult = 1.10
    scatter = -5
    burst_amount = 4
    aim_slowdown = 0.30
    damage_falloff_mult = 0.9

//-------------------------------------------------------
//T-12 Assault Rifle

/obj/item/weapon/gun/rifle/standard_assaultrifle
    name = "\improper T-12 assault rifle"
    desc = "The T-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the T-18 carbine replaced it. It's however still used widely despite that. The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
    icon_state = "t12"
    item_state = "t12"
    fire_sound = "sound/weapons/guns/fire/t18.ogg"
   	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
    unload_sound = 'sound/weapons/guns/interact/t18_unload.ogg'
    reload_sound = 'sound/weapons/guns/interact/t18_reload.ogg'
    caliber = "10x24mm caseless" //codex
    max_shells = 50 //codex
    force = 20
    current_mag = /obj/item/ammo_magazine/rifle/standard_assaultrifle
    attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/stock/t12stock,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/compensator,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun)

    flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
    gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST, GUN_FIREMODE_AUTOMATIC)
    starting_attachment_types = list(/obj/item/attachable/stock/t12stock)
    attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 17,"rail_x" = 4, "rail_y" = 23, "under_x" = 20, "under_y" = 11, "stock_x" = 0, "stock_y" = 13)

    fire_delay = 0.2 SECONDS
    burst_delay = 0.15 SECONDS
    accuracy_mult = 1.15
    scatter = -10
    wield_delay = 0.7 SECONDS
    burst_amount = 3
    aim_slowdown = 0.4
    damage_falloff_mult = 0.5


//-------------------------------------------------------
//T-64 DMR

/obj/item/weapon/gun/rifle/standard_dmr
	name = "\improper T-64 designated marksman rifle"
	desc = "The T-64 DMR is the TerraGov Marine Corps designated marksman rifle. It is rather well-known for it's very consistent target placement at longer than usual range, it however lacks a burst fire mode or an automatic mode. It is mostly used by people who prefer to do more careful shooting than most. Uses 10x27 caliber."
	icon_state = "t64"
	item_state = "t64"
	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = "sound/weapons/guns/fire/DMR.ogg"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = "10x27mm caseless" //codex
	aim_slowdown = 0.05 SECONDS
	wield_delay = 0.7 SECONDS
	force = 20
	max_shells = 10 //codex
	current_mag = /obj/item/ammo_magazine/rifle/standard_dmr
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/compensator,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/gyro,
						/obj/item/attachable/stock/dmr,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_CAN_POINTBLANK
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/dmr, /obj/item/attachable/scope/mini)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 13, "rail_y" = 18, "under_x" = 24, "under_y" = 13, "stock_x" = 14, "stock_y" = 10)

	fire_delay = 0.8 SECONDS
	accuracy_mult = 1.25
	scatter = -15
	burst_amount = 1


//-------------------------------------------------------
//M41A PULSE RIFLE

/obj/item/weapon/gun/rifle/m41a1
	name = "\improper M41A1 pulse rifle"
	desc = "An outdated rifle for the TerraGov Marine Corps, carried by a few coporate mercenaries,the M41A1 is a very rare sight in TerraGov systems. Uses 10x24mm caseless ammunition."
	icon_state = "m41a1"
	item_state = "m41a1"
	muzzleflash_iconstate = "muzzle_flash_medium"
	fire_sound = "gun_pulse"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	caliber = "10x24mm caseless" //codex
	max_shells = 40 //codex
	current_mag = /obj/item/ammo_magazine/rifle
	attachable_allowed = list(
						/obj/item/attachable/quickfire,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/compensator,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/rifle,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

	fire_delay = 0.25 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.15
	scatter = -10


//-------------------------------------------------------
//M41A PMC VARIANT

/obj/item/weapon/gun/rifle/m41a1/elite
	name = "\improper M41A2 battle rifle"
	desc = "A refined and redesigned version of the tried and tested M41A1 Pulse Rifle. Given only to elite units."
	icon_state = "m41a2"
	item_state = "m41a2"
	current_mag = /obj/item/ammo_magazine/rifle/ap

	flags_item_map_variant = NONE

	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	damage_mult = 1.5
	scatter = 0


//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/weapon/gun/rifle/m41a
	name = "\improper M41A pulse rifle"
	desc = "An older design of the pulse rifle used by the TerraGov Marine Corps. Uses 10x24mm caseless ammunition."
	icon_state = "m41a"
	item_state = "m41a"
	fire_sound = "gun_pulse"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	aim_slowdown = 0.5
	wield_delay = 1.35 SECONDS
	max_shells = 95 //codex
	current_mag = /obj/item/ammo_magazine/rifle/m41a
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/reddot,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/compensator,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

	burst_amount = 4
	burst_delay = 1.5
	accuracy_mult = 1.10
	scatter = -10



//-------------------------------------------------------

/obj/item/weapon/gun/rifle/ak47
	name = "\improper AK-47 assault rifle"
	desc = "A crude, cheaply produced assault rifle capable of automatic fire. A replicant of the 1947 Kalashnikov rifle made with wood coloured plating, chambering the orginal 7.62x39mm round. Despite lacking attachment points, remains a popular product on the black market with its cheap cost and armor punching rounds."
	icon_state = "ak47"
	item_state = "ak47"
	caliber = "7.62x39mm" //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	max_shells = 40 //codex
	fire_sound = 'sound/weapons/guns/fire/ak47-1.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak47_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/ak47
	aim_slowdown = 0.7
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/flashlight)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 17, "under_x" = 24, "under_y" = 13, "stock_x" = 17, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/stock/ak47)

	accuracy_mult = 1
	burst_amount = 1
	fire_delay = 0.25 SECONDS
	scatter = 5
	wield_delay = 0.7 SECONDS



/obj/item/weapon/gun/rifle/ak47/carbine
	name = "\improper AK-47U battle carbine"
	desc = "A crude, cheaply produced battle carbine copy capable of automatic fire, a shortened version of the Kalashnikov rifle. Commonly found in the hands of criminals or mercenaries."
	icon_state = "mar30"
	item_state = "mar30"
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = null

	fire_delay = 0.25 SECONDS
	burst_amount = 3
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.5



//-------------------------------------------------------
//M16 RIFLE

/obj/item/weapon/gun/rifle/m16
	name = "\improper FN M16A4 assault rifle"
	desc = "A light, versatile assault rifle with a 30 round magazine, chambered to fire the 5.56x45mm NATO cartridge. The 4th generation in the M16 platform, this FN variant has added automatic fire selection and retains relevance among mercenaries and militias thanks to its high customizability."
	icon_state = "m16"
	item_state = "m16"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = "5.56x45mm" //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/m16-1.ogg'
	unload_sound = 'sound/weapons/guns/interact/m16_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m16_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16
	aim_slowdown = 0.4
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/m16sight,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 4, "rail_y" = 18, "under_x" = 22, "under_y" = 15, "stock_x" = 19, "stock_y" = 13)
	starting_attachment_types = list(/obj/item/attachable/stock/m16, /obj/item/attachable/m16sight)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.3
	wield_delay = 0.5 SECONDS
	damage_mult = 1.2



//-------------------------------------------------------
//T-42 Light Machine Gun

/obj/item/weapon/gun/rifle/standard_lmg
	name = "\improper T-42 light machine gun"
	desc = "The T-42 LMG is the TGMC's current standard non-IFF-capable LMG. It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. It uses 10x24mm ammunition."
	icon_state = "t42"
	item_state = "t42"
	caliber = "10x24mm caseless" //codex
	max_shells = 120 //codex
	force = 30
	aim_slowdown = 0.6
	wield_delay = 1.4 SECONDS
	fire_sound =  'sound/weapons/guns/fire/rifle.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	current_mag = /obj/item/ammo_magazine/standard_lmg
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/compensator,
						/obj/item/attachable/stock/t42stock,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/t42stock)
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 4, "rail_y" = 20, "under_x" = 16, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
	fire_delay = 0.2 SECONDS
	burst_amount = 1
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 0.9
	scatter = 20
	scatter_unwielded = 80

//-------------------------------------------------------
//M41AE2 Heavy Pulse Rifle

/obj/item/weapon/gun/rifle/m41ae2_hpr
    name = "\improper M41AE2 heavy pulse rifle"
    desc = "A large weapon capable of laying down supressing fire, based on the M41A pulse rifle platform. Went under field testing, however it failed to surpass its trials and was replaced by the T-42 light machine gun."
    icon_state = "m41ae2"
    item_state = "m41ae2"
    caliber = "10x24mm caseless" //codex
    max_shells = 200 //codex
    aim_slowdown = 0.8
    wield_delay = 2 SECONDS
    fire_sound =  'sound/weapons/guns/fire/rifle.ogg'
    dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
    unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
    reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
    current_mag = /obj/item/ammo_magazine/m41ae2_hpr
    attachable_allowed = list(
                        /obj/item/attachable/extended_barrel,
                        /obj/item/attachable/reddot,
                        /obj/item/attachable/verticalgrip,
                        /obj/item/attachable/angledgrip,
                        /obj/item/attachable/flashlight,
                        /obj/item/attachable/bipod,
                        /obj/item/attachable/stock/rifle,
                        /obj/item/attachable/compensator,
                        /obj/item/attachable/magnetic_harness,
                        /obj/item/attachable/scope)

    flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_LOAD_INTO_CHAMBER
    gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
    gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
    attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 23, "under_x" = 24, "under_y" = 12, "stock_x" = 24, "stock_y" = 14)

    fire_delay = 0.4 SECONDS
    burst_amount = 5
    burst_delay = 0.1 SECONDS
    accuracy_mult_unwielded = 0.5
    accuracy_mult = 1.05
    scatter = 15
    scatter_unwielded = 80
    recoil_unwielded = 5


//-------------------------------------------------------
//USL TYPE 71 RIFLE

/obj/item/weapon/gun/rifle/type71
	name = "\improper Type 71 pulse rifle"
	desc = "The primary rifle of the USL forces, the Type 71 is a reliable rifle chambered in 7.62x39mm, firing in two round bursts to conserve ammunition. A newer model for surpression roles to comply with overmatch doctrines is in progress and only issued to a limited number of pirates in the USL."
	icon_state = "type71"
	item_state = "type71"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = "7.62x39mm" //codex
	max_shells = 40 //codex
	fire_sound = 'sound/weapons/guns/fire/type71.ogg'
	unload_sound = 'sound/weapons/guns/interact/type71_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/type71_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/type71_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/type71
	aim_slowdown = 0.6
	wield_delay = 0.7 SECONDS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)

	fire_delay = 0.25 SECONDS
	burst_amount = 2
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.8


/obj/item/weapon/gun/rifle/type71/flamer
	name = "\improper Type 71 pulse rifle"
	desc = " This appears to be a less common variant of the usual Type 71, with an undermounted flamethrower and improved iron sights."
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 20, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	starting_attachment_types = list(/obj/item/attachable/attached_gun/flamer/unremovable)

/obj/item/weapon/gun/rifle/type71/carbine
	name = "\improper Type 71 pulse carbine"
	desc = "A carbine variant of the Type 71 pulse rifle for quicker aiming. A surpression model in addition to the main rifle is in progress."
	icon_state = "type71c"
	item_state = "type71c"
	wield_delay = 0.2 SECONDS //Carbine is more lightweight


/obj/item/weapon/gun/rifle/type71/carbine/commando
	name = "\improper Type 73 'Commando' pulse carbine"
	desc = "An much rarer variant of the standard Type 71, this version contains an integrated supressor, a scope, and lots of fine-tuning. Many parts have been replaced, filed down, and improved upon. As a result, this variant is rarely seen issued outside of commando units."
	icon_state = "type73"
	item_state = "type73"
	wield_delay = 0 //Ends up being .5 seconds due to scope
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
	starting_attachment_types = list(/obj/item/attachable/suppressor/unremovable/invisible, /obj/item/attachable/scope/unremovable)

	fire_delay = 0.3 SECONDS
	burst_amount = 2
	accuracy_mult = 2
	accuracy_mult_unwielded = 0.8
	damage_mult = 1.3


//-------------------------------------------------------
//SX-16 AUTOMATIC SHOTGUN (It acts more like a rifle then a shotgun, so it makes sense to put it here)

/obj/item/weapon/gun/rifle/sx16
	name = "\improper SX-16 automatic shotgun"
	desc = "An automatic shotgun with an impressive rate of fire. It uses 16 gauge magazines of either buckshot, slug or flechette. The SX-16 only recently left field testing, and is one of the more recent additions to the TGMC's arsenal, replacing the ZX-76 because of reliability issues."
	icon_state = "sx16"
	item_state = "sx16"
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = "16 gauge" //codex
	max_shells = 15 //codex
	current_mag = /obj/item/ammo_magazine/rifle/sx16_buckshot
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/stock/sx16,
						/obj/item/attachable/sx16barrel)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/sx16, /obj/item/attachable/sx16barrel)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 18, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 10, "stock_y" = 14)
	gun_skill_category = GUN_SKILL_SHOTGUNS

	fire_delay = 0.7 SECONDS
	burst_amount = 1

//-------------------------------------------------------
//TX-16 AUTOMATIC SHOTGUN

/obj/item/weapon/gun/rifle/standard_autoshotgun
	name = "\improper TX-15 automatic shotgun"
	desc = "The TX-15 Automatic Assault Shotgun, produced by Terran Armories. Another iteration of the ZX series of firearms, taking over the SX as the semi-automatic shotgun provided to the TGMC. Compared to the SX, this Shotgun is rifled, and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12 round magazines."
	icon_state = "tx15"
	item_state = "tx15"
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	caliber = "16 gauge" //codex
	max_shells = 12 //codex
	force = 20
	current_mag = /obj/item/ammo_magazine/rifle/tx15_slug
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/bayonetknife,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/stock/tx15,
						/obj/item/attachable/compensator,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel
						)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/tx15)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 16,"rail_x" = 12, "rail_y" = 17, "under_x" = 24, "under_y" = 11, "stock_x" = 26, "stock_y" = 13)
	gun_skill_category = GUN_SKILL_SHOTGUNS

	fire_delay = 1 SECONDS
	accuracy_mult = 1.15
	burst_amount = 1

//-------------------------------------------------------
//T-29 Smart Machine Gun (It's more of a rifle than the SG.)

/obj/item/weapon/gun/rifle/standard_smartmachinegun
	name = "\improper T-29 smart machine gun"
	desc = "The T-29 LMG is the TGMC's current standard IFF-capable medium machine gun. It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	icon_state = "t29"
	item_state = "t29"
	caliber = "10x26mm caseless" //codex
	max_shells = 300 //codex
	force = 30
	aim_slowdown = 0.95
	wield_delay = 1.3 SECONDS
	fire_sound = "gun_smartgun"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	current_mag = /obj/item/ammo_magazine/standard_smartmachinegun
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/t42barrel,
						/obj/item/attachable/bipod,
						/obj/item/attachable/stock/dmr,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	starting_attachment_types = list(/obj/item/attachable/stock/t29stock, /obj/item/attachable/t29barrel)
	gun_skill_category = GUN_SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 12, "stock_y" = 13)
	fire_delay = 0.25 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.2
	scatter = -20
	scatter_unwielded = 80



//-------------------------------------------------------
//Sectoid Rifle

/obj/item/weapon/gun/rifle/sectoid_rifle
	name = "\improper alien rifle"
	desc = "An unusual gun of alien origin. It is lacking a trigger or any obvious way to fire it."
	icon_state = "alien_rifle"
	item_state = "alien_rifle"
	fire_sound = 'sound/weapons/guns/fire/alienplasma.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	max_shells = 20//codex stuff
	ammo = /datum/ammo/energy/plasma
	muzzleflash_iconstate = "muzzle_flash_pulse"
	current_mag = /obj/item/ammo_magazine/rifle/sectoid_rifle
	wield_delay = 0.4 SECONDS

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

	fire_delay = 0.5 SECONDS
	burst_amount = 3
	accuracy_mult = 2
	accuracy_mult_unwielded = 0.8

//only sectoids can fire it
/obj/item/weapon/gun/rifle/sectoid_rifle/able_to_fire(mob/user)
	. = ..()
	if(!.)
		return
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!(H.species.species_flags & USES_ALIEN_WEAPONS))
		to_chat(user, "<span class='warning'>There's no trigger on this gun, you have no idea how to fire it!</span>")
		return FALSE
	return TRUE


//-------------------------------------------------------
//Spess FAMAS.

/obj/item/weapon/gun/rifle/famas
	name = "\improper FAMAS assault rifle"
	desc = "This FAMAS rifle is an update to the original design, modifed extensively to modernize it and to make it spaceworthy. Uses 6.5x40mm caseless."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "famas"
	item_state = "famas"
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = "6.5x40mm caseless" //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/FAMAS_Firing.ogg'
	dry_fire_sound = 'sound/weapons/guns/interact/FAMAS_Click.ogg'
	unload_sound = 'sound/weapons/guns/interact/m16_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/FAMAS_Reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/famas
	aim_slowdown = 0.4
	attachable_allowed = list(
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 4, "rail_y" = 18, "under_x" = 22, "under_y" = 15, "stock_x" = 19, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.2
	scatter = -20
	scatter_unwielded = 80


//-------------------------------------------------------
//Spess AK


/obj/item/weapon/gun/rifle/famas/ak40vm
	name = "\improper AK-40VM assault rifle"
	desc = "A tried and true design, this AK has been modified extensively from the original design to be spaceworthy. Fires 9x30mm caseless."
	icon_state = "ak40"
	item_state = "ak40"
	caliber = "9x30mm caseless" //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/AK-SPESS_Firing.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak47_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/AK-SPESS_Reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/ak40vm

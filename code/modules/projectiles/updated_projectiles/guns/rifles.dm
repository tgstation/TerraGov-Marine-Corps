//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg'
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	origin_tech = "combat=4;materials=3"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = 4
	force = 15
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	load_method = MAGAZINE //codex
	aim_slowdown = SLOWDOWN_ADS_RIFLE
	wield_delay = WIELD_DELAY_NORMAL
	gun_skill_category = GUN_SKILL_RIFLES

/obj/item/weapon/gun/rifle/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)
	damage_falloff_mult = CONFIG_GET(number/combat_define/med_damage_falloff_mult)

/obj/item/weapon/gun/rifle/unique_action(mob/user)
	cock(user)

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
//M41A PULSE RIFLE

/obj/item/weapon/gun/rifle/m41a
	name = "\improper M41A1 pulse rifle"
	desc = "The standard issue rifle of the TerraGov Marine Corps. Commonly carried by most combat personnel. Uses 10x24mm caseless ammunition."
	icon_state = "m41a1"
	item_state = "m41a1"
	fire_sound = "gun_pulse"
	caliber = "10x24mm caseless" //codex
	max_shells = 40 //codex
	current_mag = /obj/item/ammo_magazine/rifle
	attachable_allowed = list(
						/obj/item/attachable/quickfire,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
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

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

/obj/item/weapon/gun/rifle/m41a/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/vlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


//variant without ugl attachment
/obj/item/weapon/gun/rifle/m41a/stripped
	starting_attachment_types = list()

//-------------------------------------------------------
//M41A PMC VARIANT

/obj/item/weapon/gun/rifle/m41a/elite
	name = "\improper M41A2 battle rifle"
	desc = "A refined and redesigned version of the tried and tested M41A1 Pulse Rifle. Given only to elite units."
	icon_state = "m41a2"
	item_state = "m41a2"
	origin_tech = "combat=7;materials=5"
	current_mag = /obj/item/ammo_magazine/rifle/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER


/obj/item/weapon/gun/rifle/m41a/elite/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/max_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/weapon/gun/rifle/m41aMK1
	name = "\improper M41A pulse rifle"
	desc = "An older design of the pulse rifle commonly used by the TerraGov Marine Corps. Uses 10x24mm caseless ammunition."
	icon_state = "m41a"
	item_state = "m41a"
	fire_sound = "gun_pulse"
	max_shells = 95 //codex
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

/obj/item/weapon/gun/rifle/m41aMK1/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/min_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)



//-------------------------------------------------------
//MAR-40 AK/FN FAL clone

/obj/item/weapon/gun/rifle/mar40
	name = "\improper MAR-40 battle rifle"
	desc = "A cheap, reliable assault rifle chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries."
	icon_state = "mar40"
	item_state = "mar40"
	caliber = "7.62x93mm" //codex
	max_shells = 40 //codex
	origin_tech = "combat=4;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/gun_mar40.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/mar40
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/slavic,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/scope/slavic)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

/obj/item/weapon/gun/rifle/mar40/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


/obj/item/weapon/gun/rifle/mar40/carbine
	name = "\improper MAR-30 battle carbine"
	desc = "A cheap, reliable assault rifle chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries. This is the carbine variant."
	icon_state = "mar30"
	item_state = "mar30"
	fire_sound = 'sound/weapons/gun_mar40.ogg'

/obj/item/weapon/gun/rifle/mar40/carbine/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/low_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/low_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


//-------------------------------------------------------
//M16 RIFLE

/obj/item/weapon/gun/rifle/m16
	name = "\improper M16 rifle"
	desc = "An old, reliable design first adopted by the U.S. military in the 1960s. Something like this belongs in a museum of war history. It is chambered in 5.56x45mm."
	icon_state = "m16"
	item_state = "m16"
	caliber = "5.56x45mm" //codex
	max_shells = 20 //codex
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_mar40.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun
						)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 22, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 13)

/obj/item/weapon/gun/rifle/m16/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/min_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)

//-------------------------------------------------------
//M41AE2 HEAVY PULSE RIFLE

/obj/item/weapon/gun/rifle/lmg
	name = "\improper M41AE2 heavy pulse rifle"
	desc = "A large weapon capable of laying down supressing fire. Currently undergoing field testing. Like it's smaller brother, the M41A1, the M41AE2 is chambered in 10mm."
	icon_state = "m41ae2"
	item_state = "m41ae2"
	caliber = "10x24mm caseless" //codex
	max_shells = 300 //codex
	wield_delay = WIELD_DELAY_NORMAL + WIELD_DELAY_VERY_FAST
	origin_tech = "combat=5;materials=4"
	fire_sound =  'sound/weapons/gun_rifle.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/lmg
	attachable_allowed = list(
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/stock/rifle,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_LOAD_INTO_CHAMBER
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 23, "under_x" = 24, "under_y" = 12, "stock_x" = 24, "stock_y" = 14)

/obj/item/weapon/gun/rifle/lmg/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value) * 2
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/max_recoil_value)


//-------------------------------------------------------


//-------------------------------------------------------
//UPP TYPE 71 RIFLE

/obj/item/weapon/gun/rifle/type71
	name = "\improper Type 71 pulse rifle"
	desc = "The primary service rifle of the UPP forces, the Type 71 is a reliable rifle chambered in 7.62x39mm, firing in two round bursts to conserve ammunition."
	icon_state = "type71"
	item_state = "type71"
	caliber = "7.62x39mm" //codex
	max_shells = 40 //codex
	origin_tech = "combat=4;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/gun_type71.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/type71
	wield_delay = 4

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_BURST_ON|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER

/obj/item/weapon/gun/rifle/type71/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/low_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


/obj/item/weapon/gun/rifle/type71/toggle_burst()
	to_chat(usr, "<span class='warning'>This weapon can only fire in bursts!</span>")


/obj/item/weapon/gun/rifle/type71/flamer
	name = "\improper Type 71 pulse rifle"
	desc = " This appears to be a less common variant of the usual Type 71, with an undermounted flamethrower and improved iron sights."
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 20, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	starting_attachment_types = list(/obj/item/attachable/attached_gun/flamer/unremovable)

/obj/item/weapon/gun/rifle/type71/carbine
	name = "\improper Type 71 pulse carbine"
	icon_state = "type71c"
	item_state = "type71c"
	wield_delay = 2 //Carbine is more lightweight


/obj/item/weapon/gun/rifle/type71/carbine/commando
	name = "\improper Type 71 'Commando' pulse carbine"
	desc = "An much rarer variant of the standard Type 71, this version contains an integrated supressor, a scope, and lots of fine-tuning. Many parts have been replaced, filed down, and improved upon. As a result, this variant is rarely seen issued outside of commando units and officer cadres."
	icon_state = "type73"
	item_state = "type73"
	wield_delay = 0 //Ends up being .5 seconds due to scope
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
	starting_attachment_types = list(/obj/item/attachable/suppressor/unremovable/invisible, /obj/item/attachable/scope/unremovable)

/obj/item/weapon/gun/rifle/type71/carbine/commando/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/low_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)

//-------------------------------------------------------

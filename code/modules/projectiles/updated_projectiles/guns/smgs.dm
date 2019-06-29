/obj/item/weapon/gun/smg
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg' //Could use a unique sound.
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_m39.ogg'
	type_of_casings = "bullet"
	load_method = MAGAZINE //codex
	force = 8
	w_class = 4
	movement_acc_penalty_mult = 3
	wield_delay = WIELD_DELAY_FAST
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_SMGS

/obj/item/weapon/gun/smg/unique_action(mob/user)
	return cock(user)

/obj/item/weapon/gun/smg/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/smg/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

//-------------------------------------------------------
//M39 SMG

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 submachinegun"
	desc = "Armat Battlefield Systems M39 submachinegun. A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	icon_state = "m39"
	item_state = "m39"
	caliber = "10x20mm caseless" //codex
	max_shells = 40 //codex
	flags_equip_slot = ITEM_SLOT_BACK
	current_mag = /obj/item/ammo_magazine/smg/m39
	type_of_casings = null
	attachable_allowed = list(
						/obj/item/attachable/quickfire,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/stock/smg,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/gyro)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 14, "rail_y" = 22, "under_x" = 24, "under_y" = 16, "stock_x" = 24, "stock_y" = 16)

/obj/item/weapon/gun/smg/m39/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/mlow_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/high_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)





//-------------------------------------------------------

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B2 submachinegun"
	desc = "Armat Battlefield Systems M39 submachinegun, B2 variant. This reliable weapon fires armor piercing 10x20mm rounds and is used by elite troops."
	icon_state = "m39b2"
	item_state = "m39b2"
	origin_tech = "combat=6;materials=5"
	current_mag = /obj/item/ammo_magazine/smg/m39/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER

/obj/item/weapon/gun/smg/m39/elite/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/low_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)



//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/weapon/gun/smg/mp5
	name = "\improper MP5 submachinegun"
	desc = "A German design, this was one of the most widely used submachine guns in the world. It's still possible to find this firearm in the hands of collectors or gun fanatics."
	icon_state = "mp5"
	item_state = "mp5"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 30 //codex
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gun_mp5.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp5
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)

/obj/item/weapon/gun/smg/mp5/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/high_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/med_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)


//-------------------------------------------------------
//MP27, based on the grease gun

/obj/item/weapon/gun/smg/mp7
	name = "\improper MP27 submachinegun"
	desc = "An archaic design going back hundreds of years, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms."
	icon_state = "mp7"
	item_state = "mp7"
	caliber = "4.6x30mm" //codex
	max_shells = 30 //codex
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gun_mp7.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp7
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)

/obj/item/weapon/gun/smg/mp7/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/high_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/high_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/weapon/gun/smg/skorpion
	name = "\improper CZ-81 submachinegun"
	desc = "A robust, 20th century firearm that's a combination of pistol and submachinegun. Fires .32ACP caliber rounds from a 20 round magazine."
	icon_state = "skorpion"
	item_state = "skorpion"
	caliber = ".32 ACP" //codex
	max_shells = 20 //codex
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gun_skorpion.ogg'
	current_mag = /obj/item/ammo_magazine/smg/skorpion
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 22, "under_x" = 23, "under_y" = 15, "stock_x" = 23, "stock_y" = 15)

/obj/item/weapon/gun/smg/skorpion/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/hmed_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)


/obj/item/weapon/gun/smg/skorpion/upp
	icon_state = "skorpion_u"
	item_state = "skorpion_u"

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere."
	icon_state = "ppsh"
	item_state = "ppsh"
	caliber = "7.62x25mm" //codex
	max_shells = 35 //codex
	origin_tech = "combat=3;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/gun_ppsh.ogg'
	current_mag = /obj/item/ammo_magazine/smg/ppsh
	attachable_allowed = list(
						/obj/item/attachable/compensator,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15)

/obj/item/weapon/gun/smg/ppsh/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/max_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/min_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value) + CONFIG_GET(number/combat_define/low_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)



//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/weapon/gun/smg/uzi
	name = "\improper GAL9 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age. Turn on burst mode for maximum firepower."
	icon_state = "uzi"
	item_state = "uzi"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 32 //codex
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/uzi.ogg'
	current_mag = /obj/item/ammo_magazine/smg/uzi
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

/obj/item/weapon/gun/smg/uzi/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/vlow_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/high_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) - CONFIG_GET(number/combat_define/hmed_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

	movement_acc_penalty_mult = CONFIG_GET(number/combat_define/min_movement_acc_penalty)

//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/weapon/gun/smg/p90
	name = "\improper FN FP9000 Submachinegun"
	desc = "An archaic design, but one that's stood the test of time. Fires fast armor piercing rounds."
	icon_state = "FP9000"
	item_state = "FP9000"
	caliber = "5.7x28mm" //codex
	max_shells = 50 //codex
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_p90.ogg'
	current_mag = /obj/item/ammo_magazine/smg/p90
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 20, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

/obj/item/weapon/gun/smg/p90/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)

	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/high_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value) + CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/low_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

//-------------------------------------------------------

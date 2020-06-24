/obj/item/weapon/gun/smg
	fire_sound = 'sound/weapons/guns/fire/m39.ogg'
	unload_sound = 'sound/weapons/guns/interact/smg_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/smg_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/smg_cocked.ogg'
	type_of_casings = "bullet"
	muzzleflash_iconstate = "muzzle_flash_light"
	load_method = MAGAZINE //codex
	force = 8
	w_class = WEIGHT_CLASS_BULKY
	movement_acc_penalty_mult = 3
	wield_delay = 0.4 SECONDS
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	gun_skill_category = GUN_SKILL_SMGS

	fire_delay = 0.3 SECONDS
	burst_amount = 3
	recoil_unwielded = 0.5


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
// T-19 Machinepistol. It fits here more.

/obj/item/weapon/gun/smg/standard_machinepistol
	name = "\improper T-19 machinepistol"
	desc = "The T-19 is the TerraGov Marine Corps standard-issue machine pistol. It's known for it's low recoil and scatter when used one handed. It's usually carried by specialized troops who do not have the space to carry a much larger gun like medics and engineers. It uses 10x20mm caseless rounds."
	icon_state = "t19"
	item_state = "t19"
	caliber = "10x20mm caseless" //codex
	max_shells = 30 //codex
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	current_mag = /obj/item/ammo_magazine/smg/standard_machinepistol
	type_of_casings = null
	w_class = WEIGHT_CLASS_NORMAL
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/stock/t19stock,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/gyro)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 17,"rail_x" = 9, "rail_y" = 20, "under_x" = 21, "under_y" = 12, "stock_x" = 24, "stock_y" = 10)

	accuracy_mult = 1.5
	accuracy_mult_unwielded = 0.85
	recoil_unwielded = 0
	scatter = 15
	fire_delay = 0.15 SECONDS
	scatter_unwielded = 0 //Made to be used one handed.
	aim_slowdown = 0.15
	burst_amount = 5
	movement_acc_penalty_mult = 0

//-------------------------------------------------------
// War is hell. Not glorious.

/obj/item/weapon/gun/smg/standard_smg
	name = "\improper T-90 submachinegun"
	desc = "The T-90 is the TerraGov Marine Corps standard issue SMG. Its known for it's compact size and ease of use inside the field. It's usually carried by troops who want a lightweight firearm to rush with. It uses 10x20mm caseless rounds."
	fire_sound = 'sound/weapons/guns/fire/t90.ogg'
	icon_state = "t90"
	item_state = "t90"
	caliber = "10x20mm caseless" //codex
	max_shells = 50 //codex
	flags_equip_slot = ITEM_SLOT_BACK
	wield_delay = 0.5 SECONDS
	force = 20
	current_mag = /obj/item/ammo_magazine/smg/standard_smg
	type_of_casings = null
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 15,"rail_x" = 22, "rail_y" = 22, "under_x" = 17, "under_y" = 15, "stock_x" = 24, "stock_y" = 10)

	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.8
	scatter = 0
	fire_delay = 0.165 SECONDS
	scatter_unwielded = 30
	aim_slowdown = 0.25
	burst_amount = 0

//-------------------------------------------------------
//M39 SMG

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 submachinegun"
	desc = "The Armat Battlefield Systems M39 submachinegun, an outdated design within the TGMC inventory. A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	icon_state = "m39"
	item_state = "m39"
	caliber = "10x20mm caseless" //codex
	max_shells = 40 //codex
	flags_equip_slot = ITEM_SLOT_BACK
	current_mag = /obj/item/ammo_magazine/smg/m39
	type_of_casings = null
	attachable_allowed = list(
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

	flags_item_map_variant = (ITEM_JUNGLE_VARIANT)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 14, "rail_y" = 22, "under_x" = 24, "under_y" = 16, "stock_x" = 24, "stock_y" = 16)

	accuracy_mult = 0.95
	accuracy_mult_unwielded = 0.9
	scatter = 20
	fire_delay = 0.175 SECONDS
	scatter_unwielded = 30
	aim_slowdown = 0.15
	burst_amount = 3


/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B2 submachinegun"
	desc = "The Armat Battlefield Systems M39 submachinegun, B2 variant. This reliable weapon fires armor piercing 10x20mm rounds and is used by elite troops."
	icon_state = "m39b2"
	item_state = "m39b2"
	current_mag = /obj/item/ammo_magazine/smg/m39/ap

	flags_item_map_variant = NONE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

	burst_amount = 4
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.95
	damage_mult = 1.2
	aim_slowdown = 0.4
	scatter = 10


//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/weapon/gun/smg/mp5
	name = "\improper MP5 submachinegun"
	desc = "A German design, this was one of the most widely used submachine guns in the world. It's still possible to find this firearm in the hands of collectors or gun fanatics."
	icon_state = "mp5"
	item_state = "mp5"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/mp5.ogg'
	unload_sound = 'sound/weapons/guns/interact/mp5_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/mp5_reload.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp5
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.2 SECONDS
	burst_amount = 4
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 1.05
	scatter = 15
	scatter_unwielded = 40
	damage_mult = 1.30
	aim_slowdown = 0.35
	wield_delay = 0.5 SECONDS


//-------------------------------------------------------
//MP27, based on the grease gun

/obj/item/weapon/gun/smg/mp7
	name = "\improper MP27 submachinegun"
	desc = "An archaic design going back hundreds of years, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms, though it somehow got into the hands of colonial rebels."
	icon_state = "mp7"
	item_state = "mp7"
	caliber = "4.6x30mm" //codex
	max_shells = 30 //codex
	fire_sound = 'sound/weapons/guns/fire/mp7.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp7
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)

	fire_delay = 0.3 SECONDS
	burst_delay = 0.2 SECONDS
	burst_amount = 4
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 1.25
	scatter = 35
	scatter_unwielded = 45
	damage_mult = 1.2

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/weapon/gun/smg/skorpion
	name = "\improper CZ-81 submachinegun"
	desc = "A robust, 20th century firearm that's a combination of pistol and submachinegun. Fires .32ACP caliber rounds from a 20 round magazine."
	icon_state = "skorpion"
	item_state = "skorpion"
	caliber = ".32 ACP" //codex
	max_shells = 20 //codex
	fire_sound = 'sound/weapons/guns/fire/skorpion.ogg'
	unload_sound = 'sound/weapons/guns/interact/skorpion_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/skorpion_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/skorpion_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/smg/skorpion
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 22, "under_x" = 23, "under_y" = 15, "stock_x" = 23, "stock_y" = 15)

	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.75
	scatter_unwielded = 40
	fire_delay = 0.15 SECONDS
	aim_slowdown = 0.3


/obj/item/weapon/gun/smg/skorpion/upp
	icon_state = "skorpion_u"
	item_state = "skorpion_u"

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "A replica of a 20th century USSR model submachinegun that many terrorist organizations had copied all over the years. Despite its small-hitting firepower, its reliablity, extreme longevity and high firepower rate proves useful for the hands of the user."
	icon_state = "ppsh"
	item_state = "ppsh"
	caliber = "7.62x25mm" //codex
	max_shells = 35 //codex
	fire_sound = 'sound/weapons/guns/fire/ppsh.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/ppsh_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/ppsh_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/ppsh_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ppsh_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/smg/ppsh
	attachable_allowed = list(
						/obj/item/attachable/compensator,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15)

	fire_delay = 0.125 SECONDS
	burst_amount = 6
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.65
	scatter = 25
	scatter_unwielded = 45
	aim_slowdown = 0.8
	wield_delay = 0.8 SECONDS


//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/weapon/gun/smg/uzi
	name = "\improper GAL9 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age. Put the fire mode to full auto for maximum firepower."
	icon_state = "uzi"
	item_state = "uzi"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 32 //codex
	fire_sound = 'sound/weapons/guns/fire/uzi.ogg'
	unload_sound = 'sound/weapons/guns/interact/uzi_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/uzi_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/uzi_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/smg/uzi
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

	fire_delay = 0.175 SECONDS
	burst_amount = 4
	accuracy_mult_unwielded = 0.85
	scatter = 15
	scatter_unwielded = 60
	aim_slowdown = 0.15
	wield_delay = 0.5 SECONDS

//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/weapon/gun/smg/p90
	name = "\improper FN FP9000 submachinegun"
	desc = "An archaic design, but one that's stood the test of time. Fires fast 5.7mm armor piercing rounds."
	icon_state = "FP9000"
	item_state = "FP9000"
	caliber = "5.7x28mm" //codex
	max_shells = 50 //codex
	fire_sound = 'sound/weapons/guns/fire/p90.ogg'
	unload_sound = 'sound/weapons/guns/interact/p90_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/p90_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/p90_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/smg/p90
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 20, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

	fire_delay = 0.175 SECONDS
	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.65
	scatter_unwielded = 60
	scatter = 10
	aim_slowdown = 0.5
	wield_delay = 0.65 SECONDS

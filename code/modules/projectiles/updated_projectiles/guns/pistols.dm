//Base pistol for inheritance/
//--------------------------------------------------

/obj/item/weapon/gun/pistol
	icon_state = "" //Defaults to revolver pistol when there's no sprite.
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/gun_pistol_cocked.ogg'
	load_method = MAGAZINE //codex
	origin_tech = "combat=3;materials=2"
	matter = list("metal" = 2000)
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = 3
	force = 6
	movement_acc_penalty_mult = 2
	wield_delay = WIELD_DELAY_VERY_FAST //If you modify your pistol to be two-handed, it will still be fast to aim
	fire_sound = 'sound/weapons/gun_servicepistol.ogg'
	type_of_casings = "bullet"
	gun_skill_category = GUN_SKILL_PISTOLS
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER

/obj/item/weapon/gun/pistol/unique_action(mob/user)
	cock(user)

/obj/item/weapon/gun/pistol/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/pistol/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/weapon/gun/pistol/m4a3
	name = "\improper C-22A service pistol"
	desc = "A C22A service pistol, military variant. Uses 9mm pistol rounds. The standard issue sidearm of the TerraGov Marine Corps."
	icon_state = "m4a3"
	item_state = "m4a3"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 12 //codex
	current_mag = /obj/item/ammo_magazine/pistol
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/m4a3/Initialize()
	. = ..()
	select_gamemode_skin(/obj/item/weapon/gun/pistol/m4a3)

/obj/item/weapon/gun/pistol/m4a3/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/pistol/m4a3/custom
	name = "\improper C-22TG service pistol"
	desc = "A C22TG service pistol, TerraGov custom variant, manufactured by Armsdealer's Concord. Uses 9mm pistol rounds. The standard issue sidearm of the TerraGov Marine Corps.  It has an ivory-colored grip and a slide that has been carefully polished. Normally issued to low-ranking officers."
	icon_state = "m4a3c"
	item_state = "m4a3c"

/obj/item/weapon/gun/pistol/m4a3/custom/Initialize()
	. = ..()
	select_gamemode_skin(/obj/item/weapon/gun/pistol/m4a3/custom)

/obj/item/weapon/gun/pistol/m4a3/custom/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/vlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/low_hit_damage_mult)

//-------------------------------------------------------
//M4A3 45 //Inspired by the 1911

/obj/item/weapon/gun/pistol/m1911
	name = "\improper C-45 service pistol"
	desc = "A C45 service pistol. Chambered in .45. Hits harder than its 9mm sibling, the C-22, in exchange for lower ammo capacity."
	icon_state = "m4a345"
	item_state = "m1911"
	caliber = ".45 ACP" //codex
	max_shells = 7 //codex
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_glock.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/m1911
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/m1911/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/low_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

/obj/item/weapon/gun/pistol/m1911/custom
	name = "\improper C-45E custom pistol"
	desc = "A C45E custom pistol. It lacks an auto magazine eject feature, so it's not recommended for beginners."
	icon_state = "m1911"
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/quickfire)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/m1911/custom/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/vlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/low_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

//-------------------------------------------------------
//Beretta 92FS, the gun McClane carries around in Die Hard. Very similar to the service pistol, all around.

/obj/item/weapon/gun/pistol/b92fs
	name = "\improper MaxSec2 pistol"
	desc = "A MaxSecurity2 pistol. It is chambered in 9mm. This sidearm was prominently issued to Space Authority forces, during the 2100s, where it saw much use against rioters on Mars."
	icon_state = "b92fs"
	item_state = "b92fs"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 15 //codex
	current_mag = /obj/item/ammo_magazine/pistol/b92fs
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/b92fs/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/pistol/b92fs/raffica
	name = "\improper MaxSec4 pistol"
	desc = "A MaxSecurity4 Pistol. It is chambered in 9mm, and capable of burst fire. This is the current sidearm in use by Space Authority, now TerraGov, for its specialized security teams. Features a vertical foregrip at the front of the trigger guard, to improve stability during burst fire."
	icon_state = "b93r"
	item_state = "b93r"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 20 //codex
	current_mag = /obj/item/ammo_magazine/pistol/b93r
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 21, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire)

/obj/item/weapon/gun/pistol/b92fs/raffica/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/vlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/high_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/pistol/b92fs/M9
	name = "\improper LowSec1 pistol"
	desc = "A LowSecurity1 tranquilizer pistol. Fires tranq darts.Created by a rival company as a nonlethal alternative to Armsdealer's Concord MaxSec series."
	icon_state = "m9"
	item_state = "m9"
	caliber = "9x19mm tranquilizer" //codex
	max_shells = 12 //codex
	current_mag =/obj/item/ammo_magazine/pistol/b92fstranq
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 21, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)
	starting_attachment_types = list(
									/obj/item/attachable/lasersight,
									/obj/item/attachable/suppressor
									)
/obj/item/weapon/gun/pistol/b92fs/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) - CONFIG_GET(number/combat_define/max_hit_damage_mult)


//-------------------------------------------------------
//DEAGLE //Deagle Brand Deagle

/obj/item/weapon/gun/pistol/heavy
	name = "\improper CI-MkI pistol"
	desc = "A Callisto Impact MkI heavy pistol. It is chambered in .50ae. The unfortunate person to get shot by this, will feel like they were just hit by the Jovian moon it's named after. It has something engraved on the side of the slide: <i>'Si vis pacem, para bellum.'</i>"
	icon_state = "deagle"
	item_state = "deagle"
	caliber = ".50 AE" //codex
	max_shells = 7 //codex
	fire_sound = 'sound/weapons/gun_44mag.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/heavy
	force = 13
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 9, "rail_y" = 23, "under_x" = 22, "under_y" = 14, "stock_x" = 20, "stock_y" = 17)

/obj/item/weapon/gun/pistol/heavy/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/max_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/high_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/med_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)

/obj/item/weapon/gun/pistol/heavy/gold
	icon_state = "g_deagle"
	item_state = "g_deagle"
//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/weapon/gun/pistol/c99
	name = "\improper CS pistol"
	desc = "A C-S pistol. Mercenary variant. Comes with a built in suppresor. This one is already loaded with .22 HP rounds. The go to choice for clandestine operatives."
	icon_state = "pk9"
	item_state = "pk9"
	caliber = ".22 LR" //codex
	max_shells = 12 //codex
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/gun_c99.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/c99
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
	//Making the gun have an invisible silencer since it's supposed to have one.
	starting_attachment_types = list(/obj/item/attachable/suppressor/unremovable/invisible)

/obj/item/weapon/gun/pistol/c99/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/pistol/c99/russian
	icon_state = "pk9r"
	item_state = "pk9r"

/obj/item/weapon/gun/pistol/c99/upp
	desc = "A C-S pistol. UPPToBeRemoved variant. Comes with a built in suppresor. This one is already loaded with .22 HP rounds. The go to choice for clandestine operatives."
	icon_state = "pk9u"
	item_state = "pk9u"

/obj/item/weapon/gun/pistol/c99/upp/tranq
	desc = "A C-S pistol. Nonlethal variant. Comes with a built in suppresor. This variant takes low recoil .22 dart rounds, making it a formidable tranquilizer gun. The go to choice for clandestine operatives."
	current_mag = /obj/item/ammo_magazine/pistol/c99t

//-------------------------------------------------------
//KT-42 //Inspired by the .44 Auto Mag pistol

/obj/item/weapon/gun/pistol/kt42
	name = "\improper K77-V pistol"
	desc = "A K77-V pistol. Chambered in .44. This handcannon hits hard, and is more than capable of giving its wielder the power to take the law, into their own hands."
	icon_state = "kt42"
	item_state = "kt42"
	caliber = ".44 magnum" //codex
	max_shells = 7 //codex
	fire_sound = 'sound/weapons/gun_kt42.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/automatic
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 17)

/obj/item/weapon/gun/pistol/kt42/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 2
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/min_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/med_recoil_value)

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/weapon/gun/pistol/holdout
	name = "Last Chance pistol"
	desc = "A Last Chance pistol. Chambered in .22. This pistol is ridiculously easy to conceal, but it is only ever used as a last resort, due to its weak stopping power."
	icon_state = "holdout"
	item_state = "holdout"
	caliber = ".22 LR" //codex
	max_shells = 5 //codex
	origin_tech = "combat=2;materials=1"
	fire_sound = 'sound/weapons/gun_pistol_holdout.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/holdout
	w_class = 1
	force = 2
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 17, "under_y" = 15, "stock_x" = 22, "stock_y" = 17)

/obj/item/weapon/gun/pistol/holdout/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

//-------------------------------------------------------
//.45 MARSHALS PISTOL //Inspired by the Browning Hipower

/obj/item/weapon/gun/pistol/highpower
	name = "\improper TG-T-67 pistol"
	desc = "A TG-T-67 pistol. Chambered in 9mm AP rounds. It is issued only to the high ranking personnel of the TGMC, AND TGSF."
	icon_state = "highpower"
	item_state = "highpower"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 13 //codex
	fire_sound = 'sound/weapons/gun_kt42.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/highpower
	force = 10
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 18, "under_y" = 15, "stock_x" = 16, "stock_y" = 15)

/obj/item/weapon/gun/pistol/highpower/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 2
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/max_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/min_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/med_recoil_value)

//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/weapon/gun/pistol/vp70
	name = "\improper PXM5 combat pistol"
	desc = "A PXM5 combat pistol, chambered in 9mm AP rounds. It's capable of three round bursts. The PXM5 is standard issue for Nanotrasen response teams."
	icon_state = "88m4"
	item_state = "88m4"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 18 //codex
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/vp70.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/vp70
	force = 8
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/stock/vp70)
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 18, "stock_y" = 11)

/obj/item/weapon/gun/pistol/vp70/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/min_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/high_hit_damage_mult)
	recoil_unwielded = CONFIG_GET(number/combat_define/min_recoil_value)

//-------------------------------------------------------
//VP78

/obj/item/weapon/gun/pistol/vp78
	name = "\improper PXM10 pistol"
	desc = "A PXM10 pistol. Chambered in 9mm. More often than not, these powerful sidearms find themselves in the hands of wealthy Nanotrasen personnel."
	icon_state = "vp78"
	item_state = "vp78"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 18 //codex
	origin_tech = "combat=4;materials=4"
	fire_sound = 'sound/weapons/gun_pistol_large.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/vp78
	force = 8
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 24, "under_x" = 23, "under_y" = 13, "stock_x" = 23, "stock_y" = 13)

/obj/item/weapon/gun/pistol/vp78/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/min_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/med_recoil_value)

//-------------------------------------------------------
/*
Auto 9 The gun RoboCop uses. A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.
It is a modified Beretta 93R, and can fire three round burst or single fire. Whether or not anyone else aside RoboCop can use it is not established.
*/

/obj/item/weapon/gun/pistol/auto9
	name = "\improper EX-MOD-099 pistol"
	desc = "The EX-MOD-099. A pistol with great versatility, made possible by its select-fire capability. Burst mode allows it to fire three round bursts. Built by an Armsdealer's Concord manufacturer, based in Detroit, in honor of a fallen law enforcer."
	icon_state = "auto9"
	item_state = "auto9"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 50 //codex
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_pistol_large.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/auto9
	force = 15
	attachable_allowed = list()

/obj/item/weapon/gun/pistol/auto9/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/med_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/min_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/min_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/med_recoil_value)

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.

/obj/item/weapon/gun/pistol/chimp
	name = "\improper BANAN-007 pistol"
	desc = "A sidearm an Armsdealer's Concord manufacturer was tasked with making. Who it was for? Good luck finding out."
	icon_state = "c70"
	item_state = "c70"
	caliber = ".70 Mankey" //codex
	max_shells = 300 //codex
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	current_mag = /obj/item/ammo_magazine/pistol/chimp
	fire_sound = 'sound/weapons/gun_chimp70.ogg'
	w_class = 3
	force = 8
	type_of_casings = null
	gun_skill_category = GUN_SKILL_PISTOLS
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER

/obj/item/weapon/gun/pistol/holdout/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/low_burst_value)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

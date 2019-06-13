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
	fire_sound = 'sound/weapons/gun_pistol.ogg'
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
	return cock(user)

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
	name = "\improper M4A3 service pistol"
	desc = "An M4A3 Colt Service Pistol, the standard issue sidearm of the TerraGov Marine Corps. Uses 9mm pistol rounds."
	icon_state = "m4a3"
	item_state = "m4a3"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 12 //codex
	fire_sound = 'sound/weapons/gun_pistol_service.ogg'
	current_mag = /obj/item/ammo_magazine/pistol
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/m4a3/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/pistol/m4a3/custom
	name = "\improper M4A3 custom pistol"
	desc = "An M4A3 Service Pistol, the standard issue sidearm of the TerraGov Marine Corps. Uses 9mm pistol rounds. This one has an ivory-colored grip and has a slide carefully polished yearly by a team of orphan children. Looks like it belongs to a low-ranking officer."
	icon_state = "m4a3c"
	item_state = "m4a3c"

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
	name = "\improper M4A3 service pistol (.45)"
	desc = "A standard M4A3 chambered in .45. Has a smaller magazine capacity, but packs a better punch."
	icon_state = "m4a345"
	item_state = "m1911"
	caliber = ".45 ACP" //codex
	max_shells = 7 //codex
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_colt.ogg'
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
	name = "\improper M1911A1 Custom pistol"
	desc = "A 20th century military firearm that received several modifications. It seems to have been lovingly taken care of and passed down the family. Lacks an auto magazine eject feature"
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
	name = "\improper Beretta 92FS pistol"
	desc = "A popular police firearm in the 20th century, often employed by hardboiled cops while confronting terrorists. A classic of its time, chambered in 9mm."
	icon_state = "b92fs"
	item_state = "b92fs"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 15 //codex
	fire_sound = 'sound/weapons/gun_beretta.ogg'
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
	name = "\improper Beretta 93R pistol"
	desc = "A variant of a classic pistol, modified to allow for bursts. It is fitted with a vertical foregrip at the front end of the trigger guard to provide better stability when firing."
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
	name = "\improper M9 Custom pistol"
	desc = "A 20th century military firearm customized for special forces use, fires tranq darts to take down enemies nonlethally"
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
	name = "\improper Desert Eagle"
	desc = "A pistol chambered in.50ae that comes with a serious kick. This one is engraved, <i>'Peace through superior firepower.'</i>"
	icon_state = "deagle"
	item_state = "deagle"
	caliber = ".50 AE" //codex
	max_shells = 7 //codex
	fire_sound = 'sound/weapons/gun_deagle.ogg'
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
	name = "\improper Korovin PK-9 pistol"
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is loaded with the more common .22 hollowpoint rounds and appears to be a mercenary version."
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
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is loaded with the more common .22 hollowpoint rounds and appears to be a UPP model."
	icon_state = "pk9u"
	item_state = "pk9u"

/obj/item/weapon/gun/pistol/c99/upp/tranq
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is usually loaded with special low-recoil .22 dart rounds, which act as a dangerous tranquilizer."
	current_mag = /obj/item/ammo_magazine/pistol/c99t

//-------------------------------------------------------
//KT-42 //Inspired by the .44 Auto Mag pistol

/obj/item/weapon/gun/pistol/kt42
	name = "\improper KT-42 automag"
	desc = "The KT-42 Automag is an archaic but reliable design, going back many decades. There have been many versions and variations, but the 42 is by far the most common. You can't go wrong with this handcannon."
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
	name = "holdout pistol"
	desc = "A tiny pistol meant for hiding in hard-to-reach areas. Best not ask where it came from."
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
	name = "\improper Highpower automag"
	desc = "A Colonial Marshals issued, powerful semi-automatic pistol chambered in armor piercing 9mm caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	icon_state = "highpower"
	item_state = "highpower"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 13 //codex
	fire_sound = 'sound/weapons/gun_hp.ogg'
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
	name = "\improper 88 Mod 4 combat pistol"
	desc = "A powerful sidearm issued mainly to Nanotrasen response teams, but issued to the TGMC in small numbers, based on the original VP70 more than a century ago. Fires 9mm armor piercing rounds and is capable of 3-round burst."
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
	name = "\improper VP78 pistol"
	desc = "A massive, formidable automatic handgun chambered in 9mm squash-head rounds. Commonly seen in the hands of wealthy Nanotrasen members."
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
	name = "\improper Auto-9 pistol"
	desc = "An advanced, select-fire machine pistol capable of three round burst. Last seen cleaning up the mean streets of Detroit."
	icon_state = "auto9"
	item_state = "auto9"
	caliber = "9x19mm Parabellum" //codex
	max_shells = 50 //codex
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_auto9.ogg'
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
	name = "\improper CHIMP70 pistol"
	desc = "A powerful sidearm issued mainly to highly trained elite assassin necro-cyber-agents."
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

/obj/item/weapon/gun/pistol/knife
	name = "\improper Knife"
	desc = "There are a surprisingly large amount of attachment points on this.... knife."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "elite_knife"
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/gun_pistol_cocked.ogg'
	origin_tech = "combat=3;materials=2"
	matter = list("metal" = 2000)
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = 3
	force = 25
	movement_acc_penalty_mult = 10
	wield_delay = WIELD_DELAY_VERY_FAST
	fire_sound = 'sound/weapons/gun_pistol_service.ogg'
	type_of_casings = "bullet"
	gun_skill_category = GUN_SKILL_PISTOLS
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 14,"rail_x" = 9, "rail_y" = 17, "under_x" = 23, "under_y" = 11, "stock_x" = 23, "stock_y" = 10)
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
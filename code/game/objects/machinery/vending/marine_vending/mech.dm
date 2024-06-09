//Mech equipment vendor

/obj/machinery/vending/mech_vendor
	name = "\improper Mech equipment vendor"
	desc = "An automated rack hooked up to a colossal storage of items."
	icon_state = "requisitionop"
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	wrenchable = FALSE
	products = list(
		"Weapon" = list(
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/pistol = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/burstpistol = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/smg = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/burstrifle = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/assault_rifle = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/shotgun = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/greyscale_lmg = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/light_cannon = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_rifle = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_projector = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_smg = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/heavy_cannon = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/minigun = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/grenadelauncher = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/flamethrower = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rpg = -1,
			/obj/item/mecha_parts/mecha_equipment/laser_sword = -1,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_spear = -1,
		),
		"Ammo" = list(
			/obj/item/mecha_ammo/vendable/lmg = -1,
			/obj/item/mecha_ammo/vendable/rifle = -1,
			/obj/item/mecha_ammo/vendable/burstrifle = -1,
			/obj/item/mecha_ammo/vendable/shotgun = -1,
			/obj/item/mecha_ammo/vendable/lightcannon = -1,
			/obj/item/mecha_ammo/vendable/heavycannon = -1,
			/obj/item/mecha_ammo/vendable/smg = -1,
			/obj/item/mecha_ammo/vendable/burstpistol = -1,
			/obj/item/mecha_ammo/vendable/pistol = -1,
			/obj/item/mecha_ammo/vendable/rpg = -1,
			/obj/item/mecha_ammo/vendable/minigun = -1,
			/obj/item/mecha_ammo/vendable/grenade = -1,
			/obj/item/mecha_ammo/vendable/flamer = -1,
		),
		"Equipment" = list(
			/obj/item/mecha_parts/mecha_equipment/armor/melee = -1,
			/obj/item/mecha_parts/mecha_equipment/armor/acid = -1,
			/obj/item/mecha_parts/mecha_equipment/armor/explosive = -1,
			/obj/item/mecha_parts/mecha_equipment/generator/greyscale = -1,
			/obj/item/mecha_parts/mecha_equipment/generator/greyscale/upgraded = -1,
			/obj/item/mecha_parts/mecha_equipment/energy_optimizer = -1,
			/obj/item/mecha_parts/mecha_equipment/melee_core = -1,
			/obj/item/mecha_parts/mecha_equipment/ability/dash = -1,
			/obj/item/mecha_parts/mecha_equipment/ability/smoke/cloak_smoke = -1,
		),
	)

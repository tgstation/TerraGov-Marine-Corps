// Fallow weapons are below.
/obj/item/armored_weapon/icc_lvrt_sarden
	name = "\improper EM-2600 'SARDEN' Autocannon"
	desc = "A 30mm Autocannon for the LVRT 'Fallow'. A surprisingly powerful autocannon. Sadly, beltfeeding system was lost in the slew of budget cuts related to the system. It is loaded with 4 round clips."
	icon_state = "icc_lvrt_autocannon"
	fire_sound = SFX_AC_FIRE
	interior_fire_sound = list('sound/vehicles/weapons/tank_autocannon_interior_fire_1.ogg', 'sound/vehicles/weapons/tank_autocannon_interior_fire_2.ogg')
	ammo = /obj/item/ammo_magazine/tank/sarden_clip
	accepted_ammo = list(/obj/item/ammo_magazine/tank/sarden_clip, /obj/item/ammo_magazine/tank/sarden_clip/high_explosive)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	variance = 2
	projectile_delay = 0.65 SECONDS
	rearm_time = 0.5 SECONDS
	hud_state_empty = "rifle_empty"

/obj/item/armored_weapon/icc_lvrt_cannon
	name = "\improper EM-2500 Low Velocity Cannon"
	desc = "A 76mm low velocity cannon for the LVRT 'Fallow'. It has slow travel speed and solid explosive performance. It is loaded with 76mm shells."
	icon_state = "icc_lvrt_cannon"
	fire_sound = SFX_AC_FIRE
	interior_fire_sound = list('sound/vehicles/weapons/tank_autocannon_interior_fire_1.ogg', 'sound/vehicles/weapons/tank_autocannon_interior_fire_2.ogg')
	ammo = /obj/item/ammo_magazine/tank/icc_lowvel_cannon
	accepted_ammo = list(/obj/item/ammo_magazine/tank/icc_lowvel_cannon, /obj/item/ammo_magazine/tank/icc_lowvel_cannon/high_explosive)
	variance = 0
	projectile_delay = 1.5 SECONDS
	rearm_time = 1.5 SECONDS
	hud_state_empty = "rifle_empty"

// generic coax

/obj/item/armored_weapon/icc_coaxial
	name = "EM-94 Coaxial Chain gun (10x26mm)"
	desc = "A beltfed coaxial with ICC markings that spews lead. Requires the Barrel shroud and power system of a vehicle to use in any way shape and form. Can use either standard ML-41 Boxes or vehicle specific boxes."
	icon_state = "icc_lvrt_coax"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mg60.ogg'
	armored_weapon_flags = MODULE_SECONDARY|MODULE_FIXED_FIRE_ARC
	ammo = /obj/item/ammo_magazine/icc_mg
	accepted_ammo = list(/obj/item/ammo_magazine/icc_mg)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	projectile_delay = 0.15 SECONDS
	variance = 5
	rearm_time = 3 SECONDS
	hud_state_empty = "rifle_empty"

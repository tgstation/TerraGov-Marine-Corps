obj/item/weapon/gun/energy/plasmarifle
	name = "Type-25 Directed Energy Rifle"
	desc = "todo"
	icon = 'icons/halo/weapons/covenantweaponsprites.dmi'
	icon_state = "Plasma Rifle"
	item_state = "plasmarifle"
	reload_sound = 'sound/weapons/guns/interact/rifle_reload.ogg'
	fire_sound = 'sound/halo/plasrifle3burst.ogg'
	load_method = CELL
	ammo = /datum/ammo/energy/plasmarifle
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	muzzleflash_iconstate = "muzzle_blue"
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	overcharge = FALSE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY
	aim_slowdown = 0.75
	wield_delay = 1 SECONDS
	gun_skill_category = GUN_SKILL_RIFLES

	fire_delay = 3
	accuracy_mult = 1.5
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 80 //Heavy and unwieldy
	damage_falloff_mult = 0.5
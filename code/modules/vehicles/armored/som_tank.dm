//3x4
/obj/vehicle/sealed/armored/multitile/som_tank
	name = "\improper Malleus hover tank"
	desc = "A terrifying behemoth, the Malleus pattern hover tank is the SOM's main battle tank. Combining excellent mobility and formidable weaponry, it has earned a fearsome reputation among TerraGov forces that have faced it."
	icon = 'icons/obj/armored/3x3/som_tank.dmi'
	turret_icon = 'icons/obj/armored/3x3/som_tank_gun.dmi'
	damage_icon_path = 'icons/obj/armored/3x3/tank_damage.dmi' //to update
	icon_state = "tank"
	hitbox = /obj/hitbox/rectangle/som_tank
	interior = /datum/interior/armored
	minimap_icon_state = "tank"
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT //leave as is or??
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_HEADLIGHTS
	pixel_x = -65
	pixel_y = -80
	max_integrity = 900
	soft_armor = list(MELEE = 65, BULLET = 75 , LASER = 80, ENERGY = 85, BOMB = 75, BIO = 100, FIRE = 100, ACID = 60)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.7, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)
	permitted_weapons = list(/obj/item/armored_weapon/volkite_cardanelle, /obj/item/armored_weapon/volkite_cardanelle/particle, /obj/item/armored_weapon/volkite_cardanelle/coilgun)
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom) //revisit
	max_occupants = 4
	move_delay = 0.3 SECONDS
	ram_damage = 100
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
	)
	engine_sound = null

/obj/vehicle/sealed/armored/multitile/som_tank/Initialize(mapload)
	. = ..()
	add_filter("shadow", 2, drop_shadow_filter(0, -8, 1))
	animate_hover()

/obj/vehicle/sealed/armored/multitile/som_tank/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/armored/strafe, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/armored/multitile/som_tank/setDir(newdir)
	. = ..()
	swivel_turret(null, newdir)

/obj/vehicle/sealed/armored/multitile/som_tank/swivel_turret(atom/A, new_weapon_dir)
	if(new_weapon_dir != dir)
		return FALSE
	if(turret_overlay.dir == new_weapon_dir)
		return FALSE
	turret_overlay.setDir(new_weapon_dir)
	return TRUE

///Animates the bob for the tank and its desants
/obj/vehicle/sealed/armored/multitile/som_tank/proc/animate_hover()
	var/list/hover_list = list(src)
	if(length(hitbox.tank_desants))
		hover_list += hitbox.tank_desants
	for(var/atom/atom AS in hover_list)
		animate(atom, time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE|ANIMATION_END_NOW, pixel_y = 3)
		animate(time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE, pixel_y = -3)


/obj/item/armored_weapon/volkite_cardanelle
	name = "Volkite Cardanelle" //update
	desc = "desc here" //update
	icon_state = "volkite"
	fire_sound = 'sound/weapons/guns/fire/volkite_1.ogg'
	weapon_slot = MODULE_PRIMARY
	ammo = /obj/item/ammo_magazine/tank/volkite_cardanelle
	accepted_ammo = list(/obj/item/ammo_magazine/tank/volkite_cardanelle)
	fire_mode = GUN_FIREMODE_AUTOMATIC
	variance = 5
	projectile_delay = 0.1 SECONDS
	rearm_time = 3 SECONDS
	maximum_magazines = 5
	hud_state_empty = "battery_empty_flash"

/obj/item/ammo_magazine/tank/volkite_cardanelle
	name = "volkite cardanelle cell" //update
	desc = "A primary armament cannon magazine" //update
	caliber = CALIBER_84MM
	icon_state = "volkite_turret"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/energy/volkite/heavy
	max_rounds = 180

/obj/item/armored_weapon/volkite_cardanelle/particle
	name = "Volkite Cardanelle" //update
	desc = "desc here" //update
	icon_state = "particle_beam"

/obj/item/armored_weapon/volkite_cardanelle/coilgun
	name = "Volkite Cardanelle" //update
	desc = "desc here" //update
	icon_state = "coilgun"

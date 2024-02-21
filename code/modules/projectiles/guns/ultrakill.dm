/**
 * Marksman revolver, shoots lasers that bounces off of coins, increasing in damage for each bounce
 * Has an unremovable coin launcher underbarrel attachment
 */
/obj/item/weapon/gun/pistol/coin_pistol
	name = "\improper Marksman Pistol"
	desc = "The Marksman Pistol is a prototype gun that has subpar damage but comes with a set of coins that can be shot to ricochet bullets right into enemy weakpoints and potentially double it's damage."
	icon = 'icons/obj/items/guns/pistols64.dmi'
	icon_state = "n_t76"
	//icon_state = "ukr-marksman"
	item_state = "ukr-marksman"
	caliber = CALIBER_MARKSMAN_PISTOL //codex
	max_shells = -1 //codex
	fire_sound = 'sound/weapons/guns/fire/marksmanalt.ogg' //same bullets, same sound
	reload_sound = 'sound/weapons/guns/interact/tp14_reload.ogg'
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT_LOCKED //|AMMO_RECIEVER_CLOSED #TESTING
	default_ammo_type = /obj/item/ammo_magazine/pistol/coin_bullet
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/coin_bullet)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/energy/coin_launcher,
	)
	starting_attachment_types = list(/obj/item/weapon/gun/energy/coin_launcher)

	flags_gun_features = GUN_IFF|GUN_SMOKE_PARTICLES|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = SKILL_SMARTGUN
	actions_types = list()

	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 13, "rail_y" = 23, "under_x" = 19, "under_y" = 13, "stock_x" = 21, "stock_y" = 17)

	aim_slowdown = 0
	wield_delay = 0.1 SECONDS
	fire_delay = 1 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 1
	scatter = -1
	scatter_unwielded = 0
	recoil = -2
	recoil_unwielded = 2

/**
 * COIN LAUNCHER, the thing that actually shoots the coins for the main gun to bounce off of
 */
/obj/item/weapon/gun/energy/coin_launcher
	name = "Coin Launcher"
	desc = "Launches coins into the air to be shot at, generally found ontop of another gun."
	icon = 'icons/obj/items/guns/pistols64.dmi'
	icon_state = "n_t76"
	fire_sound = 'sound/weapons/guns/misc/cointoss.ogg'
	caliber = CALIBER_MARKSMAN_PISTOL
	slot = ATTACHMENT_SLOT_UNDER
	force = 5
	attachable_allowed = list()
	actions_types = list()
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT_LOCKED //|AMMO_RECIEVER_CLOSED #TESTING
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_WIELDED_FIRING_ONLY|GUN_ATTACHMENT_FIRE_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	flags_attach_features = NONE
	fire_delay = 5
	accuracy_mult = 1.25
	pixel_shift_x = 18
	pixel_shift_y = 16
	default_ammo_type = /obj/item/cell/coin_launcher
	allowed_ammo_types = list(/obj/item/cell/coin_launcher)
	max_rounds = 4
	rounds_per_shot = 1
	ammo_datum_type = /datum/ammo/bullet/coin

//-------------------------------------------------------
// Marksman revolver magazine
/obj/item/ammo_magazine/pistol/coin_bullet
	name = "\improper Marksman Pistol magazine"
	desc = "A marksman pistol magazine. This really shouldn't be outside..."
	caliber = CALIBER_MARKSMAN_PISTOL
	icon_state = "ukr-marksman"
	icon_state_mini = "mag_pistol"
	max_rounds = INFINITY
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol/coin_bullet

/datum/ammo/bullet/pistol/coin_bullet
	name = "marksman pistol bullet"
	flags_ammo_behavior = AMMO_HITSCAN
	accuracy = 10
	damage = 20
	accurate_range = 10
	penetration = 20
	sundering = 1

//-------------------------------------------------------
// Coin launcher magazine (It's a cell because it works via charge)
/obj/item/cell/coin_launcher
	name = "\improper Marksman Pistol magazine"
	desc = "A marksman pistol magazine. This really shouldn't be outside..."
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 4
	charge_amount = 1
	charge_delay = 3 SECONDS
	self_recharge = TRUE

/datum/ammo/bullet/coin ///the coin that gets fired from the coin launcher
	name = "marksman coin"
	icon_state = "plasma" //placeholder
	shell_speed = 0.1
	damage = 5
	flags_ammo_behavior = AMMO_SPECIAL_PROCESS|AMMO_LEAVE_TURF

	/// When a coin has been activated, is is marked as used, so that it is taken out of consideration for any further ricochets
	var/used = FALSE

/datum/ammo/bullet/coin/ammo_process(obj/projectile/proj, damage)
	. = ..()

	var/entered_turf = get_turf(proj)
	RegisterSignal(entered_turf, COMSIG_TURF_PROJECTILE_MANIPULATED, PROC_REF(handle_bounce))
	ADD_TRAIT(entered_turf, TRAIT_TURF_BULLET_MANIPULATION, REF(src))

/datum/ammo/bullet/coin/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	. = ..()
	UnregisterSignal(T, list(COMSIG_TURF_PROJECTILE_MANIPULATED))
	REMOVE_TRAIT(T, TRAIT_TURF_BULLET_MANIPULATION, REF(src))

///Reflects the laser projectile from the marksman revolver bouncing off of src
/datum/ammo/bullet/coin/proc/handle_bounce(datum/source, obj/projectile/bullet)
	SIGNAL_HANDLER

	var/perpendicular_angle = Get_Angle(get_turf(src), get_step(src, dir)) //the angle src is facing, get_turf because pixel_x or y messes with the angle
	bullet.distance_travelled = 0 //we're effectively firing it fresh
	var/new_angle = (perpendicular_angle + (perpendicular_angle - bullet.dir_angle - 180))
	if(new_angle < 0)
		new_angle += 360
	else if(new_angle > 360)
		new_angle -= 360
	bullet.firer = src
	bullet.fire_at(shooter = src, source = src, angle = new_angle, recursivity = TRUE)










	//if(line_of_sight()) //Another coin is nearby, direct the laser to it






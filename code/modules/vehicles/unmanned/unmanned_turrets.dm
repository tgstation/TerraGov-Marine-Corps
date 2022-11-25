/obj/item/uav_turret
	name = "light unmanned vehicle turret"
	desc = "The turret part of an unmanned vehicle."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_cannon_obj"
	///Turret type, used for assigning what we do on clicks
	var/turret_type = TURRET_TYPE_LIGHT
	///Ammo typepath we use when attached
	var/ammo_type = /datum/ammo/bullet/smg
	/// Amount of projectiles in this turret
	var/current_rounds = 150
	/// The max amount of projectiles in this turret
	var/max_rounds = 150
	///This var must match the unmanned vehicles turret_pattern then be added
	var/turret_pattern = PATTERN_TRACKED
	/// The fire rate of this turret in byond tick
	var/fire_delay = 1
	///Typepath of the ammo to reload it.
	var/magazine_type = /obj/item/ammo_magazine/box11x35mm


/obj/item/uav_turret/heavy
	name = "heavy unmanned vehicle turret"
	icon_state = "heavy_cannon_obj"
	turret_type = TURRET_TYPE_HEAVY
	ammo_type = /datum/ammo/bullet/machinegun
	fire_delay = 2
	current_rounds = 50
	max_rounds = 50
	magazine_type = /obj/item/ammo_magazine/box12x40mm //I think this is the correct one?

/obj/item/uav_turret/droid
	name = "droid energetic cannon"
	icon_state = "droidlaser_obj"
	turret_pattern = PATTERN_DROID
	turret_type = TURRET_TYPE_DROIDLASER
	ammo_type = /datum/ammo/energy/lasgun/marine/overcharge
	fire_delay = 1.5
	current_rounds = 300
	max_rounds = 300

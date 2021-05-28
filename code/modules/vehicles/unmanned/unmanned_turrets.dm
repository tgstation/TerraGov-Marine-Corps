/obj/item/uav_turret
	name = "light unmanned vehicle turret"
	desc = "The turret part of an unmanned vehicle."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_cannon_obj"
	///Ammo typepath we use when attached
	var/ammo_type = /datum/ammo/bullet/smg
	///This var must match the unmanned vehicles turret_pattern then be added 
	var/turret_pattern = PATTERN_TRACKED
	/// The fire rate of this turret in byond tick
	var/fire_delay = 5


/obj/item/uav_turret/heavy
	name = "heavy unmanned vehicle turret"
	icon_state = "heavy_cannon_obj"
	ammo_type = /datum/ammo/bullet/machinegun
	fire_delay = 8

/obj/item/uav_turret/droid
	name = "droid energetic cannon"
	icon_state = "droidlaser_obj"
	turret_pattern = PATTERN_DROID
	ammo_type = /datum/ammo/energy/droidblast

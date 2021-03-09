/obj/item/uav_turret
	name = "light unmanned vehicle turret"
	desc = "The turret part of an unmanned vehicle."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_cannon_obj"
	var/turret_type = TURRET_TYPE_LIGHT
	var/ammo_type = /datum/ammo/bullet/smg
	var/turret_pattern = PATTERN_TRACKED


/obj/item/uav_turret/heavy
	name = "heavy unmanned vehicle turret"
	icon_state = "heavy_cannon_obj"
	turret_type = TURRET_TYPE_HEAVY
	ammo_type = /datum/ammo/bullet/machinegun

/obj/item/uav_turret/droid
	name = "droid energetic cannon"
	icon_state = "droidlaser_obj"
	turret_pattern = PATTERN_DROID
	turret_type = TURRET_TYPE_DROIDLASER
	ammo_type = /datum/ammo/energy/droidblast

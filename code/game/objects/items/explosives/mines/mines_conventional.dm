/* Claymores - Directional fragment spray, small explosion */
/obj/item/mine/claymore
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps."
	icon_state = "m20"
	detonation_message = "makes a loud click."
	range = 3
	buffer_range = 1
	angle = 110
	disarm_delay = 1 SECONDS
	undeploy_delay = 2 SECONDS
	deploy_delay = 2 SECONDS
	weak_explosion_range = 2
	shrapnel_type = /datum/ammo/bullet/claymore_shrapnel
	shrapnel_range = 5
	mine_features = MINE_STANDARD_FLAGS|MINE_DIRECTIONAL

/obj/item/mine/claymore/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"
	range = 6
	angle = 60
	shrapnel_type = /datum/ammo/bullet/claymore_shrapnel/pmc
	shrapnel_range = 8

/* Land mines - explode when something walks on or near it */
/obj/item/mine/proximity
	name = "proximity mine"
	desc = "Detonates when it detects a nearby hostile."
	detonation_message = "beeps rapidly."
	detonation_sound = 'sound/machines/triple_beep.ogg'
	range = 3
	angle = 360
	detonation_delay = 1 SECONDS
	disarm_delay = 3 SECONDS
	undeploy_delay = 1 SECONDS
	deploy_delay = 1 SECONDS
	light_explosion_range = 2
	weak_explosion_range = 3
	blinding_range = 1
	launch_distance = 1
	mine_features = MINE_STANDARD_FLAGS|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_FIRE|MINE_VOLATILE_EXPLOSION

/obj/item/mine/pressure
	name = "land mine"
	desc = "Pressure activated high explosive. Watch your step."
	icon_state = "pressure"
	detonation_message = "whirs and clicks. Run."
	max_integrity = 250
	detonation_delay = 0.5 SECONDS
	disarm_delay = 5 SECONDS
	undeploy_delay = 3 SECONDS
	deploy_delay = 3 SECONDS
	uber_explosion_range = 1
	heavy_explosion_range = 3
	blinding_range = 1
	launch_distance = 5
	mine_features = MINE_PRESSURE_SENSITIVE|MINE_DISCERN_LIVING

/obj/item/mine/pressure/anti_tank
	name = "\improper M92 Valiant anti-tank mine"
	desc = "The M92 Valiant is a anti-tank mine designed by Armat Systems for use by the TerraGov Marine Corps against heavy armour, both tanks and mechs."
	icon_state = "m92"
	uber_explosion_range = 2
	heavy_explosion_range = 3
	weak_explosion_range = 4
	mine_features = MINE_PRESSURE_WEIGHTED|MINE_VOLATILE_EXPLOSION

/obj/item/mine/pressure/anti_tank/update_icon_state()
	. = ..()
	alpha = armed ? 50 : 255

/* Incendiary mines - primarily spread fire */
/obj/item/mine/incendiary
	name = "napalm mine"
	desc = "Incendiary mine variant with a napalm-based formula. Very sticky."
	icon_state = "incendiary"
	detonation_message = "hisses, releasing an inferno."
	detonation_sound = 'sound/weapons/guns/fire/tank_flamethrower.ogg'
	range = 3
	disarm_delay = 2 SECONDS
	undeploy_delay = 1 SECONDS
	deploy_delay = 1 SECONDS
	fire_range = 4
	fire_intensity = 10 SECONDS
	fire_duration = 4 SECONDS
	fire_damage = 10
	fire_stacks = 10
	fire_color = "green"
	mine_features = MINE_DISCERN_LIVING|MINE_ELECTRONIC|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_FIRE|MINE_VOLATILE_EXPLOSION

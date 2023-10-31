//Destroy mission objectives

/obj/structure/campaign_objective/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200) //require c4 normally
	///explosion smoke particle holder
	var/obj/effect/abstract/particle_holder/explosion_smoke

/obj/structure/campaign_objective/destruction_objective/Destroy()
	QDEL_NULL(explosion_smoke)
	return ..()

/obj/structure/campaign_objective/destruction_objective/plastique_act()
	qdel(src)

/obj/structure/campaign_objective/destruction_objective/plastique_time_mod(time)
	return max(time, 30)

//Howitzer
/obj/effect/landmark/campaign_structure/howitzer_objective
	name = "howitzer objective"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16

//MLRS
/obj/effect/landmark/campaign_structure/mlrs
	name = "MLRS objective"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "mlrs"
	pixel_y = -15
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/mlrs

/obj/structure/campaign_objective/destruction_objective/mlrs
	name = "\improper SOT-A1 MLRS"
	desc = "A massive multi launch rocket system on a tracked chassis. Can unleash a tremendous amount of firepower in a short amount of time."
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "mlrs"
	bound_height = 64
	bound_width = 128
	pixel_y = -15
	coverage = 100
	///intact or not
	var/destroyed_state = FALSE
	///destroyed vehicle smoke effect
	var/smoke_type = /particles/tank_wreck_smoke

/obj/structure/campaign_objective/destruction_objective/mlrs/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign_objective/destruction_objective/mlrs/update_icon_state()
	. = ..()
	if(destroyed_state)
		icon_state = "[initial(icon_state)]_broken"
	else
		icon_state = initial(icon_state)

/obj/structure/campaign_objective/destruction_objective/mlrs/update_overlays()
	. = ..()
	var/image/new_overlay = image(icon, src, "[icon_state]_overlay", ABOVE_MOB_LAYER, dir)
	. += new_overlay

/obj/structure/campaign_objective/destruction_objective/mlrs/plastique_act()
	disable()

/obj/structure/campaign_objective/destruction_objective/mlrs/disable()
	if(destroyed_state)
		return
	if(!QDELETED(src))
		destroyed_state = TRUE
		var/obj/effect/temp_visual/explosion/explosion = new /obj/effect/temp_visual/explosion(loc, 4, LIGHT_COLOR_LAVA, FALSE, TRUE)
		explosion.pixel_x = 56
		explosion_smoke = new(src, smoke_type)
		update_icon()
	return ..()

/particles/tank_wreck_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 1000
	height = 1000
	count = 300
	spawning = 5
	gradient = list("#333333", "#808080", "#FFFFFF")
	lifespan = 20
	fade = 45
	fadein = 3
	color = generator(GEN_NUM, 0, 0.025, NORMAL_RAND)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = generator(GEN_CIRCLE, 5, 5, SQUARE_RAND)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	position = list(76, 35, 0)
	gravity = list(1, 2)
	scale = 0.075
	grow = 0.04

/obj/effect/landmark/campaign_structure/tank
	name = "tank objective"
	icon_state = "tank"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	pixel_y = -15
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/mlrs/tank

/obj/structure/campaign_objective/destruction_objective/mlrs/tank
	name = "\improper tank"
	desc = "A massive multi launch rocket system on a tracked chassis. Can unleash a tremendous amount of firepower in a short amount of time."
	icon_state = "tank"

/obj/effect/landmark/campaign_structure/apc
	name = "apc objective"
	icon_state = "apc"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	pixel_y = -15
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/mlrs/apc

/obj/structure/campaign_objective/destruction_objective/mlrs/apc
	name = "\improper APC"
	desc = "A massive multi launch rocket system on a tracked chassis. Can unleash a tremendous amount of firepower in a short amount of time."
	icon_state = "apc"
	smoke_type = /particles/tank_wreck_smoke/apc

/particles/tank_wreck_smoke/apc
	position = list(87, 60, 0)

//Supply depot objectives
/obj/effect/landmark/campaign_structure/supply_objective
	name = "howitzer objective"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/supply_objective
	name = "SUPPLY_OBJECTIVE"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"

//Train
/obj/effect/landmark/campaign_structure/train
	name = "locomotive objective"
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid, /datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/supply_objective/train

/obj/structure/campaign_objective/destruction_objective/supply_objective/train
	name = "locomotive"
	desc = "A heavy duty maglev locomotive. Designed for moving large quantities of goods from point A to point B."
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	bound_width = 128

/obj/effect/landmark/campaign_structure/train/carriage
	name = "carriage objective"
	icon_state = "carriage_lit"
	spawn_object = /obj/structure/campaign_objective/destruction_objective/supply_objective/train/carriage_lit

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/carriage_lit
	name = "rail carriage"
	desc = "A heavy duty maglev carriage. I wonder what's inside?."
	icon_state = "carriage_lit"

//Phoron stack
/obj/effect/landmark/campaign_structure/phoron_stack
	name = "phoron crates"
	icon = 'icons/obj/structures/campaign/campaign_64.dmi'
	icon_state = "phoron_stack"
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid, /datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/supply_objective/phoron_stack

/obj/structure/campaign_objective/destruction_objective/supply_objective/phoron_stack
	name = "phoron crates"
	desc = "A stack of crates filled to the brim with valuable phoron."
	icon = 'icons/obj/structures/campaign/campaign_64.dmi'
	icon_state = "phoron_stack"
	bound_height = 32
	bound_width = 64

/obj/structure/campaign_objective/destruction_objective/supply_objective/phoron_stack/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign_objective/destruction_objective/supply_objective/phoron_stack/update_overlays()
	. = ..()
	var/image/new_overlay = image(icon, src, "[icon_state]_overlay", ABOVE_MOB_LAYER, dir)
	. += new_overlay

//NT base
/obj/effect/landmark/campaign_structure/nt_pod
	name = "Mysterious pod"
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "nt_pod"
	mission_types = list(/datum/campaign_mission/destroy_mission/base_rescue)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/nt_pod

/obj/structure/campaign_objective/destruction_objective/nt_pod
	name = "Mysterious pod"
	desc = "A large sealed pod, completely lacking any identifying markings. Who knows what's in it?."
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "nt_pod"
	layer = ABOVE_MOB_LAYER

/obj/structure/campaign_objective/destruction_objective/nt_pod/Destroy()
	playsound(loc, 'sound/voice/predalien_death.ogg', 75, 0)
	return ..()

//teleporter core
/obj/effect/landmark/campaign_structure/bluespace_core
	name = "Bluespace Core objective"
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	pixel_y = -18
	pixel_x = -16
	mission_types = list(/datum/campaign_mission/destroy_mission/teleporter_raid)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/bluespace_core

#define BLUESPACE_CORE_OK "bluespace_core_ok"
#define BLUESPACE_CORE_UNSTABLE "bluespace_core_unstable"
#define BLUESPACE_CORE_BROKEN "bluespace_core_broken"

/obj/structure/campaign_objective/destruction_objective/bluespace_core
	name = "\improper Bluespace Teleportation Displacement Core"
	desc = "An incredibly sophisticated piece of bluespace technology that is the engine behind any number of quantum entangled bluespace teleporter devices in the system."
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	bound_height = 64
	bound_width = 64
	pixel_y = -18
	pixel_x = -16
	var/status = BLUESPACE_CORE_OK

/obj/structure/campaign_objective/destruction_objective/bluespace_core/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign_objective/destruction_objective/bluespace_core/update_icon_state()
	. = ..()
	if(status == BLUESPACE_CORE_BROKEN)
		icon_state = "bsd_core_broken"
	else
		icon_state = "bsd_core"

/obj/structure/campaign_objective/destruction_objective/bluespace_core/update_overlays()
	. = ..()
	switch(status)
		if(BLUESPACE_CORE_OK)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_s", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_UNSTABLE)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_u", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_BROKEN)
			. += image(icon, icon_state = "top_overlay_broken", layer = ABOVE_MOB_LAYER)

///Changes the status of the object
/obj/structure/campaign_objective/destruction_objective/bluespace_core/proc/change_status(new_status)
	if(status == new_status)
		return
	status = new_status
	update_icon()
	if(status == BLUESPACE_CORE_BROKEN)
		disable()

/obj/structure/campaign_objective/destruction_objective/bluespace_core/plastique_act()
	if(status == BLUESPACE_CORE_OK)
		change_status(BLUESPACE_CORE_UNSTABLE)
	else if(status == BLUESPACE_CORE_UNSTABLE)
		change_status(BLUESPACE_CORE_BROKEN)

//airbase
/obj/structure/prop/som_fighter
	name = "\improper Harbinger"
	desc = "A state of the art Harbinger class fighter. The premier fighter for SOM forces in space and atmosphere, bristling with high tech systems and weapons."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	density = TRUE
	allow_pass_flags = PASS_AIR

/obj/effect/landmark/campaign_structure/harbinger
	name = "\improper Harbinger"
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	mission_types = list(/datum/campaign_mission/destroy_mission/airbase)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/harbinger

/obj/structure/campaign_objective/destruction_objective/harbinger
	name = "\improper Harbinger"
	desc = "A state of the art harbinger class fighter. The premier fighter for SOM forces in space and atmosphere, bristling with high tech systems and weapons."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	bound_height = 2
	bound_width = 3
	bound_x = -32
	layer = ABOVE_MOB_LAYER

/obj/effect/landmark/campaign_structure/viper
	name = "\improper Viper"
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "fighter_loaded"
	pixel_x = -33
	pixel_y = -10
	mission_types = list(/datum/campaign_mission/destroy_mission/airbase/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/viper

/obj/structure/campaign_objective/destruction_objective/viper
	name = "\improper Viper"
	desc = "A viper MK.III fightcraft. Effective in atmosphere and space, the viper has been a reliable and versatile workhorse in the TerraGov navy for decades."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "fighter_loaded"
	pixel_x = -33
	pixel_y = -10
	bound_height = 2
	bound_width = 3
	bound_x = -32
	layer = ABOVE_MOB_LAYER

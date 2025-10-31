//Destroy mission objectives

/obj/structure/campaign_objective/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200) //require c4 normally
	faction = FACTION_TERRAGOV
	allow_pass_flags = PASSABLE|PASS_WALKOVER
	objective_flags = CAMPAIGN_OBJECTIVE_DEL_ON_DISABLE
	///explosion smoke particle holder
	var/obj/effect/abstract/particle_holder/explosion_smoke

/obj/structure/campaign_objective/destruction_objective/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/campaign_objective/destruction_objective/Destroy()
	QDEL_NULL(explosion_smoke)
	return ..()

/obj/structure/campaign_objective/destruction_objective/update_icon_state()
	. = ..()
	if(objective_flags & CAMPAIGN_OBJECTIVE_DISABLED)
		icon_state = "[initial(icon_state)]_broken"
	else
		icon_state = initial(icon_state)

/obj/structure/campaign_objective/destruction_objective/disable()
	. = ..()
	if(!.)
		return
	if((objective_flags & CAMPAIGN_OBJECTIVE_EXPLODE_ON_DISABLE))
		var/turf/det_turf = pick(locs)
		do_explosion(det_turf)
	if(objective_flags & CAMPAIGN_OBJECTIVE_DEL_ON_DISABLE)
		qdel(src)
		return
	disable_effects()

/obj/structure/campaign_objective/destruction_objective/can_plastique(mob/user, obj/plastique)
	if(user.faction == faction)
		to_chat(user, "[span_warning("You're meant to protect this!")]")
		return FALSE
	return ..()

/obj/structure/campaign_objective/destruction_objective/plastique_act(mob/living/plastique_user)
	if(plastique_user && plastique_user.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[plastique_user.ckey]
		personal_statistics.mission_objective_destroyed += (faction != plastique_user.faction ? 1 : -1)
	disable()

/obj/structure/campaign_objective/destruction_objective/plastique_time_mod(time)
	return max(time, 30)

///Explodes on destruction
/obj/structure/campaign_objective/destruction_objective/proc/do_explosion(turf/det_turf)
	explosion(det_turf, 0, 2, 4)

///Any special effects on disable if NOT deleted
/obj/structure/campaign_objective/destruction_objective/proc/disable_effects()
	update_icon()

//Howitzer
/obj/effect/landmark/campaign_structure/howitzer_objective
	name = "howitzer objective"
	icon = 'icons/obj/machines/deployable/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/obj/machines/deployable/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16
	faction = FACTION_SOM
	objective_flags = CAMPAIGN_OBJECTIVE_DEL_ON_DISABLE|CAMPAIGN_OBJECTIVE_EXPLODE_ON_DISABLE

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
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	bound_height = 64
	bound_width = 128
	pixel_y = -15
	coverage = 100
	objective_flags = CAMPAIGN_OBJECTIVE_EXPLODE_ON_DISABLE
	///destroyed vehicle smoke effect
	var/smoke_type = /particles/tank_wreck_smoke

/obj/structure/campaign_objective/destruction_objective/mlrs/do_explosion(turf/det_turf)
	explosion(det_turf, 2, 3, 5)

/obj/structure/campaign_objective/destruction_objective/mlrs/disable_effects()
	var/obj/effect/temp_visual/explosion/explosion = new /obj/effect/temp_visual/explosion(loc, 4, LIGHT_COLOR_LAVA, FALSE, TRUE)
	explosion.pixel_x = 56
	explosion_smoke = new(src, smoke_type)
	update_icon()

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
	name = "\improper M34A2 Longstreet Light Tank"
	desc = "A giant piece of armor with a big gun, good for blowing stuff up."
	icon_state = "tank"

/obj/effect/landmark/campaign_structure/apc
	name = "apc objective"
	icon_state = "apc"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	pixel_y = -15
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/mlrs/apc

/obj/structure/campaign_objective/destruction_objective/mlrs/apc
	name = "\improper M577 armored personnel carrier"
	desc = "A giant piece of armor for carrying troops in relative safety. Still has a pretty big gun."
	icon_state = "apc"
	smoke_type = /particles/tank_wreck_smoke/apc

/particles/tank_wreck_smoke/apc
	position = list(87, 60, 0)

//Supply depot objectives
/obj/structure/campaign_objective/destruction_objective/supply_objective
	name = "SUPPLY_OBJECTIVE"
	icon = 'icons/obj/machines/deployable/howitzer.dmi'
	icon_state = "howitzer_deployed"

//Train
/obj/effect/landmark/campaign_structure/train
	name = "locomotive objective"
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid, /datum/campaign_mission/destroy_mission/supply_raid/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/supply_objective/train

/obj/structure/campaign_objective/destruction_objective/supply_objective/train
	name = "locomotive"
	desc = "A heavy duty maglev locomotive. Designed for moving large quantities of goods from point A to point B."
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
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
	faction = FACTION_SOM

//NT base
/obj/effect/landmark/campaign_structure/nt_pod
	name = "Mysterious pod"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "alien_pod"
	mission_types = list(/datum/campaign_mission/destroy_mission/base_rescue)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/nt_pod

/obj/structure/campaign_objective/destruction_objective/nt_pod
	name = "Mysterious pod"
	desc = "A large sealed pod, containing something huge and monstrous in its murky center."
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "alien_pod"
	bound_height = 64
	bound_width = 64
	pixel_y = 10

/obj/structure/campaign_objective/destruction_objective/nt_pod/Destroy()
	playsound(loc, 'sound/voice/predalien/death.ogg', 75, 0)
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
	faction = FACTION_SOM
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
			. += image(icon, icon_state = "bsd_c_s", layer = ABOVE_MOB_LAYER)
		if(BLUESPACE_CORE_UNSTABLE)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_u", layer = ABOVE_MOB_LAYER)
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

/obj/structure/campaign_objective/destruction_objective/bluespace_core/plastique_act(mob/living/plastique_user)
	if(status == BLUESPACE_CORE_OK)
		change_status(BLUESPACE_CORE_UNSTABLE)
	else if(status == BLUESPACE_CORE_UNSTABLE)
		if(plastique_user && plastique_user.ckey)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[plastique_user.ckey]
			personal_statistics.mission_objective_destroyed += (faction != plastique_user.faction ? 1 : -1)
		change_status(BLUESPACE_CORE_BROKEN)

//airbase
/obj/effect/landmark/campaign_structure/harbinger
	name = "harbinger"
	icon = 'icons/obj/structures/prop/mainship_96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	mission_types = list(/datum/campaign_mission/destroy_mission/airbase)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/harbinger

/obj/structure/campaign_objective/destruction_objective/harbinger
	name = "harbinger"
	desc = "A state of the art harbinger class fighter. The premier fighter for SOM forces in space and atmosphere, bristling with high tech systems and weapons."
	icon = 'icons/obj/structures/prop/mainship_96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	bound_height = 64
	bound_width = 96
	bound_x = -32
	allow_pass_flags = PASSABLE
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	faction = FACTION_SOM

/obj/effect/landmark/campaign_structure/viper
	name = "\improper Viper"
	icon = 'icons/obj/structures/prop/mainship_96.dmi'
	icon_state = "fighter_loaded"
	pixel_x = -33
	pixel_y = -10
	mission_types = list(/datum/campaign_mission/destroy_mission/airbase/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/viper

/obj/structure/campaign_objective/destruction_objective/viper
	name = "\improper Viper"
	desc = "A viper MK.III fightcraft. Effective in atmosphere and space, the viper has been a reliable and versatile workhorse in the TerraGov navy for decades."
	icon = 'icons/obj/structures/prop/mainship_96.dmi'
	icon_state = "fighter_loaded"
	pixel_x = -33
	pixel_y = -10
	bound_height = 64
	bound_width = 96
	bound_x = -32
	allow_pass_flags = PASSABLE
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP

/obj/effect/landmark/campaign_structure/underground_fuel_tank
	name = "fuel access point"
	desc = "A fuel access point for the large underground fuel tanks beneath the airstrip. No smoking within 15 meters."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "manhole"
	mission_types = list(/datum/campaign_mission/destroy_mission/airbase/som)
	spawn_object = /obj/structure/campaign_objective/destruction_objective/underground_fuel_tank

/obj/structure/campaign_objective/destruction_objective/underground_fuel_tank
	name = "fuel access point"
	desc = "A fuel access point for the large underground fuel tanks beneath the airstrip. No smoking within 15 meters."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "manhole"
	density = FALSE

/obj/structure/campaign_objective/destruction_objective/underground_fuel_tank/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/campaign_objective/destruction_objective/underground_fuel_tank/LateInitialize()
	. = ..()
	for(var/obj/effect/explosion_holder/campaign_objective/det in GLOB.campaign_structures)
		det.linked_objective = src


/obj/effect/explosion_holder
	name = "explosion holder"

///Explodes
/obj/effect/explosion_holder/proc/detonate()
	explosion(src, 3, 4, 5)
	qdel(src)

/obj/effect/explosion_holder/campaign_objective
	///The trigger object that will cause src to detonate
	var/linked_objective

/obj/effect/explosion_holder/campaign_objective/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, PROC_REF(on_objective_destruction))
	GLOB.campaign_structures += src

/obj/effect/explosion_holder/campaign_objective/Destroy()
	linked_objective = null
	GLOB.campaign_structures -= src
	return ..()

///Detonates if our linked objective is destroyed
/obj/effect/explosion_holder/campaign_objective/proc/on_objective_destruction(datum/source, obj/structure/campaign_objective/destruction_objective/destroyed)
	SIGNAL_HANDLER
	if(destroyed != linked_objective)
		return
	addtimer(CALLBACK(src, PROC_REF(detonate)), rand(0.2 SECONDS, 2.5 SECONDS))
	linked_objective = null

/obj/effect/explosion_holder/campaign_objective/airbase_fuel
	name = "airbase fueltank explosion holder"

/obj/effect/explosion_holder/campaign_objective/airbase_fuel/detonate()
	explosion(src, 7, 8, 9, 12, flame_range = 10)
	qdel(src)

//Groundside landmarks that dictate where players deploy in hvh modes
#define PATROL_POINT_RAPPEL_EFFECT "patrol_point_rappel_effect"
#define RAPPEL_DURATION 0.6 SECONDS
#define RAPPEL_HEIGHT 128

/obj/effect/landmark/patrol_point
	name = "Patrol exit point"
	icon = 'icons/effects/campaign_effects.dmi'
	faction = FACTION_TERRAGOV
	///ID to link with an associated start point
	var/id = null
	///minimap icon state
	var/minimap_icon = "patrol_1"
	///List of open turfs around the point to deploy onto
	var/list/deploy_turfs

/obj/effect/landmark/patrol_point/Initialize(mapload)
	. = ..()
	GLOB.patrol_point_list += src
	RegisterSignals(SSdcs, list(COMSIG_GLOB_GAMEMODE_LOADED, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED), PROC_REF(finish_setup))

///Finishes setup after we know what gamemode it is
/obj/effect/landmark/patrol_point/proc/finish_setup(datum/source, mode_override = FALSE)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_GAMEMODE_LOADED, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED))
	if(!(SSticker?.mode?.round_type_flags & MODE_TWO_HUMAN_FACTIONS) && !mode_override)
		return
	SSminimaps.add_marker(src, GLOB.faction_to_minimap_flag[faction], image('icons/UI_icons/map_blips_large.dmi', null, minimap_icon, MINIMAP_BLIPS_LAYER))

	deploy_turfs = filled_circle_turfs(src, 5)
	for(var/turf/turf AS in deploy_turfs)
		if(turf.density || isspaceturf(turf))
			deploy_turfs -= turf
			continue
		for(var/atom/movable/AM AS in turf)
			if(!AM.density)
				continue
			deploy_turfs -= turf
			break

/obj/effect/landmark/patrol_point/Destroy()
	GLOB.patrol_point_list -= src
	return ..()

///Moves the AM and sets up the effects
/obj/effect/landmark/patrol_point/proc/do_deployment(atom/movable/movable_to_move, list/mobs_moving)
	var/turf/target_turf = loc
	if(!isarmoredvehicle(movable_to_move)) //multitile vehicles can have clipping issues otherwise
		target_turf = pick(deploy_turfs)

	if(ismob(mobs_moving))
		mobs_moving = list(mobs_moving)

	if(isliving(movable_to_move))
		var/mob/living_to_move = movable_to_move
		new /atom/movable/effect/rappel_rope(target_turf)
		living_to_move.trainteleport(target_turf)
		add_spawn_protection(living_to_move)
	else
		movable_to_move.forceMove(target_turf)
		if(isvehicle(movable_to_move))
			var/obj/vehicle/moved_vehicle = movable_to_move
			mobs_moving += moved_vehicle.occupants

	movable_to_move.add_filter(PATROL_POINT_RAPPEL_EFFECT, 2, drop_shadow_filter(y = -RAPPEL_HEIGHT, color = COLOR_TRANSPARENT_SHADOW, size = 4))
	var/shadow_filter = movable_to_move.get_filter(PATROL_POINT_RAPPEL_EFFECT)

	var/current_layer = movable_to_move.layer
	movable_to_move.pixel_z += RAPPEL_HEIGHT
	movable_to_move.layer = FLY_LAYER

	animate(movable_to_move, pixel_z = movable_to_move.pixel_z - RAPPEL_HEIGHT, time = RAPPEL_DURATION)
	animate(shadow_filter, y = 0, size = 0.9, time = RAPPEL_DURATION, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(end_rappel), movable_to_move, current_layer, mobs_moving), RAPPEL_DURATION)

	for(var/user in mobs_moving)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HVH_DEPLOY_POINT_ACTIVATED, user)

///Temporarily applies godmode to prevent spawn camping
/obj/effect/landmark/patrol_point/proc/add_spawn_protection(mob/living/user)
	user.ImmobilizeNoChain(RAPPEL_DURATION) //looks weird if they can move while rappeling
	user.status_flags |= GODMODE
	addtimer(CALLBACK(src, PROC_REF(remove_spawn_protection), user), 10 SECONDS)

///Ends the rappel effects
/obj/effect/landmark/patrol_point/proc/end_rappel(atom/movable/movable_to_move, original_layer, list/mobs_moving)
	movable_to_move.remove_filter(PATROL_POINT_RAPPEL_EFFECT)
	movable_to_move.layer = original_layer
	SEND_SIGNAL(movable_to_move, COMSIG_MOVABLE_PATROL_DEPLOYED, TRUE, 1.5, 2)
	if(ismecha(movable_to_move) || isarmoredvehicle(movable_to_move))
		new /obj/effect/temp_visual/rappel_dust(movable_to_move.loc, 3)
		playsound(movable_to_move.loc, 'sound/effects/alien/behemoth/stomp.ogg', 40, TRUE)
	for(var/user in mobs_moving)
		shake_camera(user, 0.2 SECONDS, 0.5)

///Removes spawn protection godmode
/obj/effect/landmark/patrol_point/proc/remove_spawn_protection(mob/user)
	user.status_flags &= ~GODMODE

/obj/effect/landmark/patrol_point/tgmc_11
	name = "TGMC exit point 1"
	id = "TGMC_1"
	icon_state = "blue_1"

/obj/effect/landmark/patrol_point/tgmc_21
	name = "TGMC exit point 2"
	id = "TGMC_2"
	icon_state = "blue_2"
	minimap_icon = "patrol_2"

/obj/effect/landmark/patrol_point/som
	faction = FACTION_SOM

/obj/effect/landmark/patrol_point/som/som_11
	name = "SOM exit point 1"
	icon_state = "red_1"
	id = "SOM_1"
	minimap_icon = "som_patrol_1"

/obj/effect/landmark/patrol_point/som/som_21
	name = "SOM exit point 2"
	id = "SOM_2"
	icon_state = "red_2"
	minimap_icon = "som_patrol_2"


/atom/movable/effect/rappel_rope
	name = "rope"
	icon = 'icons/obj/structures/prop/mainship.dmi'
	icon_state = "rope"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

//Rope animation for standard deploy points
/atom/movable/effect/rappel_rope/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/effects/rappel.ogg', 50, TRUE, falloff = 2)
	playsound(loc, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	balloon_alert_to_viewers("!!!")
	visible_message(span_userdanger("You see a dropship fly overhead and begin dropping ropes!"))
	ropeanimation()

///Starts the rope animation
/atom/movable/effect/rappel_rope/proc/ropeanimation()
	flick("rope_deploy", src)
	addtimer(CALLBACK(src, PROC_REF(ropeanimation_stop)), 2 SECONDS)

///End the animation and qdels
/atom/movable/effect/rappel_rope/proc/ropeanimation_stop()
	flick("rope_up", src)
	QDEL_IN(src, 5)

#undef PATROL_POINT_RAPPEL_EFFECT
#undef RAPPEL_DURATION
#undef RAPPEL_HEIGHT

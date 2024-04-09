//Groundside landmarks that dictate where players deploy in hvh modes
#define PATROL_POINT_RAPPEL_EFFECT "patrol_point_rappel_effect"
#define RAPPEL_DURATION 0.6 SECONDS
#define RAPPEL_HEIGHT 128

/obj/effect/landmark/patrol_point
	name = "Patrol exit point"
	icon = 'icons/effects/campaign_effects.dmi'
	icon_state = "blue_1"
	///ID to link with an associated start point
	var/id = null
	///Faction this belongs to for minimap purposes
	var/faction = FACTION_TERRAGOV
	///minimap icon state
	var/minimap_icon = "patrol_1"

/obj/effect/landmark/patrol_point/Initialize(mapload)
	. = ..()
	//adds the exit points to the glob, and the start points link to them in lateinit
	GLOB.patrol_point_list += src
	if(!(SSticker?.mode?.round_type_flags & MODE_TWO_HUMAN_FACTIONS))
		return
	SSminimaps.add_marker(src, GLOB.faction_to_minimap_flag[faction], image('icons/UI_icons/map_blips.dmi', null, minimap_icon))

/obj/effect/landmark/patrol_point/Destroy()
	GLOB.patrol_point_list -= src
	return ..()

/obj/effect/landmark/patrol_point/proc/do_deployment(atom/movable/movable_to_move, mob/living/user)
	if(isliving(movable_to_move))
		var/mob/living_to_move = movable_to_move
		new /atom/movable/effect/rappel_rope(loc)
		living_to_move.trainteleport(loc)
		add_spawn_protection(living_to_move)
	else
		movable_to_move.forceMove(loc)

	movable_to_move.add_filter(PATROL_POINT_RAPPEL_EFFECT, 2, drop_shadow_filter(y = -RAPPEL_HEIGHT, color = COLOR_TRANSPARENT_SHADOW, size = 4))
	var/shadow_filter = movable_to_move.get_filter(PATROL_POINT_RAPPEL_EFFECT)

	var/current_layer = movable_to_move.layer
	movable_to_move.pixel_y += RAPPEL_HEIGHT
	movable_to_move.layer = FLY_LAYER

	animate(movable_to_move, pixel_y = movable_to_move.pixel_y - RAPPEL_HEIGHT, time = RAPPEL_DURATION)
	animate(shadow_filter, y = 0, size = 0.9, time = RAPPEL_DURATION, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(end_rappel), user, movable_to_move, current_layer), RAPPEL_DURATION)

	if(!user)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HVH_DEPLOY_POINT_ACTIVATED, user)

///Temporarily applies godmode to prevent spawn camping
/obj/effect/landmark/patrol_point/proc/add_spawn_protection(mob/living/user)
	user.ImmobilizeNoChain(RAPPEL_DURATION) //looks weird if they can move while rappeling
	user.status_flags |= GODMODE
	addtimer(CALLBACK(src, PROC_REF(remove_spawn_protection), user), 10 SECONDS)

///Ends the rappel effects
/obj/effect/landmark/patrol_point/proc/end_rappel(mob/living/user, atom/movable/movable_to_move, original_layer)
	movable_to_move.remove_filter(PATROL_POINT_RAPPEL_EFFECT)
	movable_to_move.layer = original_layer
	SEND_SIGNAL(movable_to_move, COMSIG_MOVABLE_PATROL_DEPLOYED, TRUE, 1.5, 2)
	if(ismecha(movable_to_move))
		new /obj/effect/temp_visual/rappel_dust(loc, 3)
		playsound(loc, 'sound/effects/behemoth/behemoth_stomp.ogg', 40, TRUE)
	shake_camera(user, 0.2 SECONDS, 0.5)

///Removes spawn protection godmode
/obj/effect/landmark/patrol_point/proc/remove_spawn_protection(mob/user)
	user.status_flags &= ~GODMODE

/obj/effect/landmark/patrol_point/tgmc_11
	name = "TGMC exit point 11"
	id = "TGMC_11"

/obj/effect/landmark/patrol_point/tgmc_12
	name = "TGMC exit point 12"
	id = "TGMC_12"

/obj/effect/landmark/patrol_point/tgmc_13
	name = "TGMC exit point 13"
	id = "TGMC_13"

/obj/effect/landmark/patrol_point/tgmc_14
	name = "TGMC exit point 14"
	id = "TGMC_14"

/obj/effect/landmark/patrol_point/tgmc_21
	name = "TGMC exit point 21"
	id = "TGMC_21"
	icon_state = "blue_2"
	minimap_icon = "patrol_2"

/obj/effect/landmark/patrol_point/tgmc_22
	name = "TGMC exit point 22"
	id = "TGMC_22"
	icon_state = "blue_2"
	minimap_icon = "patrol_2"

/obj/effect/landmark/patrol_point/tgmc_23
	name = "TGMC exit point 23"
	id = "TGMC_23"
	icon_state = "blue_2"
	minimap_icon = "patrol_2"

/obj/effect/landmark/patrol_point/tgmc_24
	name = "TGMC exit point 24"
	id = "TGMC_24"
	icon_state = "blue_2"
	minimap_icon = "patrol_2"

/obj/effect/landmark/patrol_point/som
	faction = FACTION_SOM
	icon_state = "red_1"
	minimap_icon = "som_patrol_1"

/obj/effect/landmark/patrol_point/som/som_11
	name = "SOM exit point 11"
	id = "SOM_11"

/obj/effect/landmark/patrol_point/som/som_12
	name = "SOM exit point 12"
	id = "SOM_12"

/obj/effect/landmark/patrol_point/som/som_13
	name = "SOM exit point 13"
	id = "SOM_13"

/obj/effect/landmark/patrol_point/som/som_14
	name = "SOM exit point 14"
	id = "SOM_14"

/obj/effect/landmark/patrol_point/som/som_21
	name = "SOM exit point 21"
	id = "SOM_21"
	icon_state = "red_2"
	minimap_icon = "som_patrol_2"

/obj/effect/landmark/patrol_point/som/som_22
	name = "SOM exit point 22"
	id = "SOM_22"
	icon_state = "red_2"
	minimap_icon = "som_patrol_2"

/obj/effect/landmark/patrol_point/som/som_23
	name = "SOM exit point 23"
	id = "SOM_23"
	icon_state = "red_2"
	minimap_icon = "som_patrol_2"

/obj/effect/landmark/patrol_point/som/som_24
	name = "SOM exit point 24"
	id = "SOM_24"
	icon_state = "red_2"
	minimap_icon = "som_patrol_2"

/atom/movable/effect/rappel_rope
	name = "rope"
	icon = 'icons/Marine/mainship_props.dmi'
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
	balloon_alert_to_viewers("You see a dropship fly overhead and begin dropping ropes!")
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

/obj/structure/resin/resin_maw
	name = "resin maw"
	desc = "A giant burrowing maw created with the remains of a silo. The mouth is agape and it looks alive." //Need better name and desc
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "tunnel_closed"
	resistance_flags = UNACIDABLE
	max_integrity = 2000
	bound_width = 96
	bound_height = 96
	/// Where is the center turf of this multitile object
	var/turf/center_turf
	///Which hive does this item belong too. Will always be regular hive
	var/datum/hive_status/associated_hive
	/// The other part of this resin maw
	var/obj/structure/resin/resin_maw/exit
	/// The eye object used to target the exit
	var/mob/camera/aiEye/remote/burrower_camera/eye
	/// What mob is actually targeting the exit turf
	var/mob/current_user
	/// If the resin maw is already tunneling or has finished it
	var/tunneling = FALSE
	/// The list of turf that will not entrave the exit
	var/list/whitelist_turfs = list(/turf/open/ground, /turf/open/floor)
	/// Which part of the maw is this
	var/is_origin_of_resin_maw = TRUE
	/// The actions gave to the user when controling the maw
	var/list/grantable_actions
	/// The action of leaving the maw when you are piloting it
	var/datum/action/innate/leave_maw/off_action
	/// The action of seting the exit zone for the head of the maw
	var/datum/action/innate/select_exit_location/chose_head_location


/obj/structure/resin/resin_maw/Initialize()
	. = ..()
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	off_action = new
	chose_head_location = new
	grantable_actions = list()
	center_turf = get_step(src, NORTHEAST)
	GLOB.xeno_resin_maws += src
	START_PROCESSING(SSprocessing, src)
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)

/obj/structure/resin/resin_maw/Destroy()
	GLOB.xeno_resin_maws -= src
	associated_hive.handle_silo_death_timer()
	for(var/mob/living/carbon/xenomorph/xeno AS in src)
		xeno.forceMove(center_turf)
	xeno_message("The [is_origin_of_resin_maw? "tail" :"head"] of the resin maw has been destroyed!", "xenoannounce", hivenumber = associated_hive.hivenumber)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/resin/resin_maw/ex_act(severity) //Explosion immune
	return

/obj/structure/resin/resin_maw/fire_act() // Fire immune
	return

/obj/structure/resin/resin_maw/update_icon_state()
	. = ..()
	if(exit)
		icon_state = "tunnel_opened"
		return
	icon_state = "tunnel_closed"

///Digging is starting, we notify everyone and kill all silos
/obj/structure/resin/resin_maw/proc/start_digging(turf/target)
	message_admins("A resin maw started digging at [AREACOORD(src)]!")
	priority_announce("Warning: unusual seismic readings detected. Our data suggests that an unidentified entity is starting to burrow under the area of operations, likely affiliated by Xenomorphs. Terminate it as soon as possible.", title = "TGMC Intel Division")
	xeno_message("A resin maw has started digging and will emerge at its destination in 5 minutes", "xenoannounce", hivenumber = associated_hive.hivenumber, target = src)
	for(var/silo in GLOB.xeno_resin_silos)
		qdel(silo)
	SSpoints.xeno_points_by_hive[associated_hive.hivenumber] = 0
	tunneling = TRUE
	addtimer(CALLBACK(src, .proc/prepare_emerge, target), 10 SECONDS)

///We create the ripples to signify where will the maw emerge
/obj/structure/resin/resin_maw/proc/prepare_emerge(turf/middle_target)
	var/list/turf/target_turfs = list()
	for(var/x in -3 to 3)
		for(var/y in -3 to 3)
			var/turf/target = locate(middle_target.x + x, middle_target.y + y, middle_target.z)
			new /obj/effect/abstract/ripple(target, 5 SECONDS)
			target_turfs += target
	addtimer(CALLBACK(src, .proc/emerge, target_turfs), 5 SECONDS)

///Create the exit point of this resin maw
/obj/structure/resin/resin_maw/proc/emerge(list/turf/target_turfs)
	playsound_z(loc.z, "sound/effects/maw_opening.ogg")
	for(var/turf/target AS in target_turfs)
		for(var/atom/to_destroy AS in target)
			if(isliving(to_destroy))
				var/mob/living/to_gib = to_destroy
				to_gib.gib()
				continue
			qdel(to_destroy)
	exit = new /obj/structure/resin/resin_maw(target_turfs[17]) //picking the 17th turf makes the resin maw perfectly centered in the destruction zone
	exit.is_origin_of_resin_maw = FALSE
	exit.exit = src
	update_icon()
	exit.update_icon()
	tunneling = FALSE
	for(var/mob/living/carbon/xenomorph/xeno AS in src)
		xeno.forceMove(exit.center_turf)
	for(var/mob/living/nearby_mob AS in GLOB.mob_living_list)
		if(!istype(nearby_mob, /mob/living/carbon/human))
			continue
		if(get_dist(nearby_mob, exit.center_turf) > 10)
			continue
		if(nearby_mob.buckled)
			to_chat(nearby_mob, "<span class='warning'>You are jolted against [nearby_mob.buckled]!</span>")
			shake_camera(nearby_mob, 3, 1)
		else
			to_chat(nearby_mob, "<span class='warning'>The floor jolts under your feet!</span>")
			shake_camera(nearby_mob, 10, 1)
			nearby_mob.Knockdown(5 SECONDS)

/obj/structure/resin/resin_maw/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!do_after(X, 2 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	if(exit)
		X.forceMove(exit.center_turf)
		return
	if(tunneling)
		X.forceMove(src)
		give_action_by_type(/datum/action/innate/leave_maw, X)
		return
	if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT) || !is_origin_of_resin_maw)
		return
	createEye()
	give_eye_control(X)

/// Create the camera mob used to target the exit point
/obj/structure/resin/resin_maw/proc/createEye()
	eye = new /mob/camera/aiEye/remote/burrower_camera(null, src)
	eye.origin = src
	for(var/x_off in -1 to 1)
		for(var/y_off in -1 to 1)
			var/image/I = image('icons/effects/alphacolors.dmi', loc, "red")
			I.loc = locate(loc.x + x_off, loc.y + y_off, loc.z)
			I.layer = ABOVE_NORMAL_TURF_LAYER
			I.plane = 0
			I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			eye.placement_images[I] = list(x_off, y_off)

/// Give the necessary actions to be able to target the exit point
/obj/structure/resin/resin_maw/proc/give_actions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		grantable_actions += off_action

	if(chose_head_location)
		chose_head_location.target = user
		chose_head_location.give_action(user)
		grantable_actions += chose_head_location

/// Set the remote control variable of the user
/obj/structure/resin/resin_maw/proc/give_eye_control(mob/user)
	user.loc = src
	give_actions(user)
	current_user = user
	eye.eye_user = user
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(loc)
	var/list/to_add = list()
	to_add += eye.placement_images
	to_add += eye.placed_images
	user.client.images += to_add
	user.client.eye = eye
	user.update_sight()

/obj/structure/resin/resin_maw/remove_eye_control(mob/user)
	for(var/V in grantable_actions)
		var/datum/action/A = V
		A.remove_action(user)
	grantable_actions.Cut()
	for(var/V in eye.visibleCameraChunks)
		var/datum/camerachunk/camera_chunk = V
		camera_chunk.remove(eye)
	if(user.client)
		user.reset_perspective(null)
		if(eye.visible_icon && user.client)
			user.client.images -= eye.user_image
	eye.eye_user = null
	user.remote_control = null
	user.reset_perspective(eye)
	user.loc = loc
	current_user = null
	user.unset_interaction()
	var/list/to_remove = list()
	to_remove += eye.placement_images
	to_remove += eye.placed_images
	user.client.images -= to_remove
	user.client.eye = user
	user.update_sight()

/// Check if the exit point is not blocked by walls
/obj/structure/resin/resin_maw/proc/checkExitSpot()
	var/turf/eyeturf = get_turf(eye)
	. = TRUE
	var/list/image_cache = eye.placement_images
	for(var/i in 1 to image_cache.len)
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		var/skip = FALSE
		if(SSshuttle.hidden_shuttle_turfs[T])
			I.icon_state = "red"
			. = FALSE
			continue
		for(var/type in whitelist_turfs)
			if(ispath(T.type, type))
				I.icon_state = "green"
				skip = TRUE
				break
		if(!skip)
			I.icon_state = "red"
			. = FALSE

/mob/camera/aiEye/remote/burrower_camera
	name = "burrower camera"
	visible_icon = FALSE
	use_static = USE_STATIC_NONE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/aiEye/remote/burrower_camera/setLoc(T)
	. = ..()
	var/obj/structure/resin/resin_maw/maw = origin
	maw?.checkExitSpot()

/mob/camera/aiEye/remote/burrower_camera/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	return TRUE

/datum/action/innate/leave_maw
	name = "Leave the maw"
	background_icon_state = "template2"
	action_icon_state = "evasion" //Need icon

/datum/action/innate/leave_maw/Activate()
	if(!target)
		remove_action(owner)
		var/obj/structure/resin/resin_maw/maw = owner.loc
		owner.forceMove(maw.loc) //Ew
		return
	var/mob/living/xeno_owner = target
	var/mob/camera/aiEye/remote/burrower_camera/eye = xeno_owner.remote_control
	var/obj/structure/resin/resin_maw/maw = eye.origin
	maw.remove_eye_control(target)

/datum/action/innate/select_exit_location
	name = "Start digging"
	background_icon_state = "template2"
	action_icon_state = "oldbuild_tunnel" //Need icon

/datum/action/innate/select_exit_location/Activate()
	var/mob/living/xeno_owner = target
	var/mob/camera/aiEye/remote/burrower_camera/eye = xeno_owner.remote_control
	var/obj/structure/resin/resin_maw/maw = eye.origin
	if(!maw.checkExitSpot())
		to_chat(target, "<span class='warning'>The maw cannot go there.</span>")
		return
	maw.start_digging(eye.loc)
	maw.remove_eye_control(xeno_owner)

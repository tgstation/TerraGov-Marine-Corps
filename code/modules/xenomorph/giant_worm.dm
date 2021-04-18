/obj/structure/resin/giant_worm
	name = "giant worm"
	desc = "A giant burrowing worm created with the remains of a silo" //Need better name and desc
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "resin_silo"
	resistance_flags = UNACIDABLE
	bound_width = 96
	bound_height = 96
	/// Where is the center turf of this multitile object
	var/turf/center_turf
	///Which hive does this item belong too. Will always be regular hive
	var/datum/hive_status/associated_hive
	/// The other part of this giant worm
	var/obj/structure/resin/giant_worm/exit
	/// The eye object used to target the exit
	var/mob/camera/aiEye/remote/burrower_camera/eye
	/// What mob is actually targeting the exit turf
	var/mob/current_user
	/// If the giant worm is already tunneling or has finished it
	var/tunneling = FALSE
	/// The list of turf that will not entrave the exit
	var/list/whitelist_turfs = list(/turf/open/ground, /turf/open/floor)
	/// Which part of the worm is this
	var/tail = TRUE
	/// The actions gave to the user when controling the worm
	var/list/actions
	/// The action of leaving the worm when you are piloting it
	var/datum/action/innate/leave_worm/off_action
	/// The action of seting the exit zone for the head of the worm
	var/datum/action/innate/select_exit_location/chose_head_location


/obj/structure/resin/giant_worm/Initialize()
	. = ..()
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	off_action = new
	chose_head_location = new
	actions = list()

///Digging is starting, we enter end game mode
/obj/structure/resin/giant_worm/proc/start_digging(turf/target)
	message_admins("A giant worm started digging at [AREACOORD(src)]")
	priority_announce("Sismic signal detected. An unknow object is burrowing into your direction") //Could use better name
	for(var/obj/structure/resin/silo/silo AS in GLOB.xeno_resin_silos)
		silo.destroy_silently()
	SSpoints.xeno_points_by_hive[associated_hive.hivenumber] = 0
	tunneling = TRUE
	addtimer(CALLBACK(src, .proc/emerge, target), 5 SECONDS)

/obj/structure/resin/giant_worm/proc/emerge(turf/target)
	exit = new /obj/structure/resin/giant_worm(locate(target.x-1, target.y -1, target.z))
	exit.tail = FALSE
	



/obj/structure/resin/giant_worm/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		return 
	createEye()
	give_eye_control(X)


/obj/structure/resin/giant_worm/proc/createEye()
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

/obj/structure/resin/giant_worm/proc/give_actions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(chose_head_location)
		chose_head_location.target = user
		chose_head_location.give_action(user)
		actions += chose_head_location

/obj/structure/resin/giant_worm/proc/give_eye_control(mob/user)
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

/obj/structure/resin/giant_worm/remove_eye_control(mob/user)
	for(var/V in actions)
		var/datum/action/A = V
		A.remove_action(user)
	actions.Cut()
	for(var/V in eye.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eye)
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

/obj/structure/resin/giant_worm/proc/checkExitSpot()
	var/turf/eyeturf = get_turf(eye)
	. = TRUE
	var/list/image_cache = eye.placement_images
	for(var/i in 1 to image_cache.len)
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		var/skip = FALSE
		for(var/type in whitelist_turfs)
			if(ispath(T.type, type))
				I.icon_state = "green"
				skip = TRUE
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
	..()
	var/obj/structure/resin/giant_worm/worm = origin
	worm?.checkExitSpot()

/mob/camera/aiEye/remote/burrower_camera/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	return TRUE

/datum/action/innate/leave_worm
	name = "Leave the worm"
	background_icon_state = "template2"
	action_icon_state = "camera_off" //Need icon

/datum/action/innate/leave_worm/Activate()
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/burrower_camera/eye = C.remote_control
	var/obj/structure/resin/giant_worm/worm = eye.origin
	worm.remove_eye_control(target)

/datum/action/innate/select_exit_location
	name = "Start digging"
	background_icon_state = "template2"
	action_icon_state = "camera_off" //Need icon

/datum/action/innate/select_exit_location/Activate()
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/burrower_camera/eye = C.remote_control
	var/obj/structure/resin/giant_worm/worm = eye.origin
	if(!worm.checkExitSpot())
		to_chat(target, "<span class='warning'>The worm head will not fit here")
		return
	worm.start_digging(eye.loc)
	worm.remove_eye_control(C)

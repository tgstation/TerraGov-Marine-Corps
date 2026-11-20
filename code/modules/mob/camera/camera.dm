// Camera mob, used by AI camera. TODO really needa a refactor up to recent tg code
/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	resistance_flags = RESIST_ALL
	status_flags = GODMODE | INCORPOREAL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT // No one can see us
	sight = SEE_SELF
	move_on_shuttle = FALSE
	///TODO DELETE THIS VAR
	var/call_life = FALSE //TRUE if Life() should be called on this camera every tick of the mobs subystem, as if it were a living mob
	/// List of [camera chunks][/datum/camerachunk] visible to this camera.
	/// Please don't interface with this directly. Use the [cameranet][/datum/cameranet].
	VAR_FINAL/list/datum/camerachunk/visibleCameraChunks = list()
	/// If TRUE, the eye will cover turfs hidden to the cameranet with static. TODO see tgs use_visibility and replace with that
	var/use_static = TRUE
	var/static_visibility_range = 16
	var/datum/cameranet/parent_cameranet
	/// Client this eye last showed static to
	var/client/static_client
	///The z level whose static we last showed to static_client
	var/static_z


/mob/camera/Initialize(mapload, cameranet, new_faction)
	. = ..()
	if(call_life)
		GLOB.living_cameras += src
	parent_cameranet = cameranet ? cameranet : GLOB.cameranet


/mob/camera/Destroy()
	for(var/datum/camerachunk/chunk in visibleCameraChunks)
		chunk.remove(src)
	static_client = null
	static_z = null
	if(call_life)
		GLOB.living_cameras -= src
	return ..()

#define STATIC_SCREEN_MARGIN_X 7
#define STATIC_SCREEN_MARGIN_Y 9

/// Returns a range of static we want to show, a fullscreen plus some margin
/mob/camera/proc/get_static_range()
	var/client/viewer = GetViewerClient()
	if(!viewer)
		return list(static_visibility_range, static_visibility_range)
	var/list/view_size = getviewsize(viewer.view)
	return list(FLOOR((view_size[1] - 1) / 2, 1) + STATIC_SCREEN_MARGIN_X, FLOOR((view_size[2] - 1) / 2, 1) + STATIC_SCREEN_MARGIN_Y)

#undef STATIC_SCREEN_MARGIN_X
#undef STATIC_SCREEN_MARGIN_Y

/// Update shown static on the client
/mob/camera/proc/sync_static_client()
	var/turf/eye_turf = get_turf(src)
	set_static_client(use_static ? GetViewerClient() : null, eye_turf?.z)

///Moves the static of every chunk we watch from our old static client and z level to the new ones
/mob/camera/proc/set_static_client(client/new_client, new_z)
	if(new_client == static_client && new_z == static_z)
		return
	var/client/old_client = static_client
	var/old_z = static_z
	static_client = new_client
	static_z = new_z
	for(var/datum/camerachunk/chunk as anything in visibleCameraChunks)
		chunk.hide_static(old_client, old_z)
		chunk.show_static(new_client, new_z)

/mob/camera/update_sight()
	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)
	return ..()

/mob/camera/forceMove(atom/destination)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE, TRUE)
	var/turf/old_turf = get_turf(oldloc)
	var/turf/new_turf = get_turf(src)
	if(old_turf?.z != new_turf?.z && length(visibleCameraChunks))
		parent_cameranet.visibility(src)

/**
 * Getter proc for getting the current user's client.
 *
 * The base version of this proc returns null.
 * Subtypes are expected to overload this proc and make it return something meaningful.
 */
/mob/camera/proc/GetViewerClient()
	RETURN_TYPE(/client)
	SHOULD_BE_PURE(TRUE)

	return null

/mob/camera/drop_held_item()
	return


/mob/camera/drop_all_held_items()
	return


/mob/camera/emote(act, m_type, message, intentional = FALSE)
	return

/mob/camera/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/camera/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

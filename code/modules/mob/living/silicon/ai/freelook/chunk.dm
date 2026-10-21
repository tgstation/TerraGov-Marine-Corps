
// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the AI Eye to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	///turfs our cameras cant see but are inside our grid
	var/list/obscuredTurfs = list()
	///turfs our cameras can see inside our grid
	var/list/visibleTurfs = list()
	///cameras that can see into our grid
	var/list/cameras = list()
	///The cameranet this chunk belongs to
	var/datum/cameranet/parent_cameranet
	///list of all turfs
	var/list/turfs = list()
	///camera mobs that can see turfs in our grid
	var/list/seenby = list()
	///images currently in use on obscured turfs.
	var/list/active_static_images = list()

	var/changed = FALSE
	var/list/camera_visible_turfs = list()
	var/list/moved_cameras = list()
	var/needs_full_update = TRUE
	var/last_full_update = 0
	var/x = 0
	var/y = 0
	var/lower_z
	var/upper_z

/// Add a camera eye to the chunk, then update if changed.
/datum/camerachunk/proc/add(mob/camera/eye)
	eye.visibleCameraChunks += src
	seenby += eye
	if(changed)
		update()

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_static)
		client.images += active_static_images

/// Remove a camera eye from the chunk
/datum/camerachunk/proc/remove(mob/camera/eye)
	eye.visibleCameraChunks -= src
	seenby -= eye

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_static && seenby.len == 0)
		client.images -= active_static_images

/// Called when a chunk has changed. I.E: A wall was deleted.
/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

/**
 * Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
 * instead be flagged to update the next time an AI Eye moves near it.
 *
 * update_delay_buffer is used for cameras that are moving around, which are cyborg inbuilt cameras and
 * mecha onboard cameras. This buffer should be usually lower than the CAMERA_CHUNK_UPDATE_DELAY config because
 * otherwise a moving camera can run out of its own view before updating static.
 */
/datum/camerachunk/proc/hasChanged(update_now = 0, update_delay_buffer)
	needs_full_update = TRUE
	queue_update(update_now, update_delay_buffer)

/datum/camerachunk/proc/queue_update(update_now = 0, update_delay_buffer)
	if(isnull(update_delay_buffer))
		update_delay_buffer = CONFIG_GET(number/camera_chunk_update_delay)
	if(seenby.len || update_now)
		addtimer(CALLBACK(src, PROC_REF(update)), update_delay_buffer, TIMER_UNIQUE)
	else
		changed = TRUE

/datum/camerachunk/proc/camera_moved(obj/machinery/camera/moved_camera)
	moved_cameras[moved_camera] = TRUE
	queue_update(update_delay_buffer = CONFIG_GET(number/camera_chunk_move_update_delay))

/datum/camerachunk/proc/remove_camera(obj/machinery/camera/removed_camera)
	for(var/z_key in cameras)
		cameras[z_key] -= removed_camera
	camera_visible_turfs -= removed_camera
	moved_cameras -= removed_camera
	queue_update(update_delay_buffer = CONFIG_GET(number/camera_chunk_move_update_delay))

/datum/camerachunk/proc/get_camera_visible_turfs(obj/machinery/camera/checked_camera)
	if(QDELETED(checked_camera) || !checked_camera.can_use())
		return
	var/turf/camera_turf = get_turf(checked_camera)
	if(!camera_turf || camera_turf.z < lower_z || camera_turf.z > upper_z)
		return
	var/turf/point = locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), camera_turf.z)
	if(get_dist(point, camera_turf) > CHUNK_SIZE + (CHUNK_SIZE / 2))
		return
	. = list()
	for(var/turf/vis_turf in checked_camera.can_see())
		if(turfs[vis_turf])
			.[vis_turf] = vis_turf


/// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.
/// Accepts an optional partial_update argument, that blocks any calls out to chunks that could affect us, like above or below
/datum/camerachunk/proc/update(partial_update = FALSE)
	if(needs_full_update || world.time >= last_full_update + CONFIG_GET(number/camera_chunk_full_update_interval))
		camera_visible_turfs = list()
		for(var/z_level in lower_z to upper_z)
			for(var/obj/machinery/camera/current_camera as anything in cameras["[z_level]"])
				var/list/camera_turfs = get_camera_visible_turfs(current_camera)
				if(camera_turfs)
					camera_visible_turfs[current_camera] = camera_turfs
		needs_full_update = FALSE
		last_full_update = world.time
	else
		for(var/obj/machinery/camera/moved_camera as anything in moved_cameras)
			var/list/camera_turfs = get_camera_visible_turfs(moved_camera)
			if(camera_turfs)
				camera_visible_turfs[moved_camera] = camera_turfs
			else
				camera_visible_turfs -= moved_camera
	moved_cameras.Cut()

	var/list/updated_visible_turfs = list()
	for(var/obj/machinery/camera/visible_camera as anything in camera_visible_turfs)
		for(var/turf/vis_turf as anything in camera_visible_turfs[visible_camera])
			updated_visible_turfs[vis_turf] = vis_turf

	///new turfs that we couldnt see last update but can now
	var/list/newly_visible_turfs = updated_visible_turfs - visibleTurfs
	///turfs that we could see last update but cant see now
	var/list/newly_obscured_turfs = visibleTurfs - updated_visible_turfs

	for(var/mob/camera/client_eye as anything in seenby)
		var/client/client = client_eye.GetViewerClient()
		if(!client)
			continue

		client.images -= active_static_images

	for(var/turf/visible_turf as anything in newly_visible_turfs)
		var/image/static_image = obscuredTurfs[visible_turf]
		if(!static_image)
			continue

		active_static_images -= static_image
		obscuredTurfs -= visible_turf

	for(var/turf/obscured_turf as anything in newly_obscured_turfs)
		if(obscuredTurfs[obscured_turf] || istype(obscured_turf, /turf/open/ai_visible))
			continue

		var/image/static_image = turfs[obscured_turf]
		if(!static_image)
			stack_trace("somehow a camera chunk used a turf it didn't contain!!")
			break

		obscuredTurfs[obscured_turf] = static_image
		active_static_images += static_image
	visibleTurfs = updated_visible_turfs

	changed = FALSE

	for(var/mob/camera/client_eye as anything in seenby)
		var/client/client = client_eye.GetViewerClient()
		if(!client)
			continue

		client.images += active_static_images

/// Create a new camera chunk, since the chunks are made as they are needed.
/datum/camerachunk/New(x, y, lower_z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)

	src.x = x
	src.y = y
	src.lower_z = lower_z
	var/turf/upper_turf = get_highest_turf(locate(x, y, lower_z))
	src.upper_z = upper_turf.z

	var/list/all_local_cameras = list()
	for(var/z_level in lower_z to upper_z)
		var/list/local_cameras = list()
		for(var/obj/machinery/camera/camera in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z_level)))
			if(camera.can_use())
				local_cameras += camera

		for(var/mob/living/silicon/sillycone in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z_level)))
			if(sillycone.builtInCamera?.can_use())
				local_cameras += sillycone.builtInCamera

		cameras["[z_level]"] = local_cameras

		var/image/mirror_from = GLOB.cameranet.obscured_images[GET_Z_PLANE_OFFSET(z_level) + 1]
		var/turf/chunk_corner = locate(x, y, z_level)
		for(var/turf/lad as anything in CORNER_BLOCK(chunk_corner, CHUNK_SIZE, CHUNK_SIZE)) //we use CHUNK_SIZE for width and height here as it handles subtracting 1 from those two parameters by itself
			var/image/our_image = new /image(mirror_from)
			our_image.loc = lad
			turfs[lad] = our_image

		all_local_cameras += local_cameras

	for(var/obj/machinery/camera/camera as anything in all_local_cameras)
		var/list/camera_turfs = get_camera_visible_turfs(camera)
		if(!camera_turfs)
			continue
		camera_visible_turfs[camera] = camera_turfs
		for(var/turf/vis_turf as anything in camera_turfs)
			visibleTurfs[vis_turf] = vis_turf
	needs_full_update = FALSE
	last_full_update = world.time

	for(var/turf/obscured_turf as anything in turfs - visibleTurfs)
		var/image/new_static = turfs[obscured_turf]
		active_static_images += new_static
		obscuredTurfs[obscured_turf] = new_static

#undef CHUNK_SIZE

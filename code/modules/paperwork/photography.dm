#define CAMERA_NO_GHOSTS 0
#define CAMERA_SEE_GHOSTS_BASIC 1
#define CAMERA_SEE_GHOSTS_ORBIT 2
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 21

/datum/picture
	var/picture_name = "picture"
	var/picture_desc = "This is a picture."
	/// List of weakrefs pointing at mobs that appear in this photo
	var/list/mobs_seen = list()
	/// List of weakrefs pointing at dead mobs that appear in this photo
	var/list/dead_seen = list()
	var/caption
	var/icon/picture_image
	var/icon/picture_icon
	var/logpath //If the picture has been logged this is the path.
	var/id //this var is NOT protected because the worst you can do with this that you couldn't do otherwise is overwrite photos, and photos aren't going to be used as attack logs/investigations anytime soon.
	var/psize_x = 96
	var/psize_y = 96

/datum/picture/New(name, desc, mobs_spotted, dead_spotted, image, icon, size_x, size_y, caption_, autogenerate_icon)
	if(!isnull(name))
		picture_name = name
	if(!isnull(desc))
		picture_desc = desc
	if(!isnull(mobs_spotted))
		for(var/mob/seen as anything in mobs_spotted)
			mobs_seen += WEAKREF(seen)
	if(!isnull(dead_spotted))
		for(var/mob/seen as anything in dead_spotted)
			dead_seen += WEAKREF(seen)
	if(!isnull(image))
		picture_image = image
	if(!isnull(icon))
		picture_icon = icon
	if(!isnull(psize_x))
		psize_x = size_x
	if(!isnull(psize_y))
		psize_y = size_y
	if(!isnull(caption_))
		caption = caption_
	if(autogenerate_icon && !picture_icon && picture_image)
		regenerate_small_icon()


/datum/picture/proc/get_small_icon(iconstate)
	if(!picture_icon)
		regenerate_small_icon(iconstate)
	return picture_icon

/datum/picture/proc/regenerate_small_icon(iconstate)
	if(!picture_image)
		return
	var/icon/small_img = icon(picture_image)
	var/icon/ic = icon('icons/obj/items/items.dmi', iconstate ? iconstate : "photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img, ICON_OVERLAY, 13, 13)
	picture_icon = ic

/datum/picture/serialize_list(list/options, list/semvers)
	. = ..()

	.["id"] = id
	.["desc"] = picture_desc
	.["name"] = picture_name
	.["caption"] = caption
	.["pixel_size_x"] = psize_x
	.["pixel_size_y"] = psize_y
	.["logpath"] = logpath

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

/datum/picture/deserialize_list(list/input, list/options)
	if((SCHEMA_VERSION in options) && (options[SCHEMA_VERSION] != "1.0.0"))
		CRASH("Invalid schema version for datum/picture: [options[SCHEMA_VERSION]] (expected 1.0.0)")
	. = ..()
	if(!.)
		return .

	if(!input["logpath"] || !fexists(input["logpath"]) || !input["id"] || !input["pixel_size_x"] || !input["pixel_size_y"])
		return FALSE

	picture_image = icon(file(input["logpath"]))
	logpath = input["logpath"]
	id = input["id"]
	psize_x = input["pixel_size_x"]
	psize_y = input["pixel_size_y"]
	if(input["caption"])
		caption = input["caption"]
	if(input["desc"])
		picture_desc = input["desc"]
	if(input["name"])
		picture_name = input["name"]

/proc/load_photo_from_disk(id, location)
	var/datum/picture/P = load_picture_from_disk(id)
	if(istype(P))
		var/obj/item/photo/p = new(location, P)
		return p

/proc/load_picture_from_disk(id)
	var/pathstring = log_path_from_picture_ID(id)
	if(!pathstring)
		return
	var/path = file(pathstring)
	if(!fexists(path))
		return
	var/dir_index = findlasttext(pathstring, "/")
	var/dir = copytext(pathstring, 1, dir_index)
	var/json_path = file("[dir]/metadata.json")
	if(!fexists(json_path))
		return
	var/list/json = json_decode(file2text(json_path))
	if(!json[id])
		return
	var/datum/picture/P = new

	// Old photos were saved as, and I shit you not, encoded JSON strings.
	if (istext(json[id]))
		P.deserialize_json(json[id])
	else
		P.deserialize_list(json[id])

	return P

/proc/log_path_from_picture_ID(id)
	if(!istext(id))
		return
	. = "data/picture_logs/"
	var/list/data = splittext(id, "_")
	if(data.len < 3)
		return null
	var/mode = data[1]
	switch(mode)
		if("L")
			if(data.len < 5)
				return null
			var/timestamp = data[2]
			var/year = copytext_char(timestamp, 1, 5)
			var/month = copytext_char(timestamp, 5, 7)
			var/day = copytext_char(timestamp, 7, 9)
			var/round = data[4]
			. += "[year]/[month]/[day]/round-[round]"
		if("O")
			var/list/path = data.Copy(2, data.len)
			. += path.Join("")
		else
			return null
	var/n = data[data.len]
	. += "/[n].png"

//BE VERY CAREFUL WITH THIS PROC, TO AVOID DUPLICATION.
/datum/picture/proc/log_to_file()
	if(!picture_image)
		return
	if(!CONFIG_GET(flag/log_pictures))
		return
	if(logpath)
		return //we're already logged
	var/number = GLOB.picture_logging_id++
	var/finalpath = "[GLOB.picture_log_directory]/[number].png"
	fcopy(icon(picture_image, dir = SOUTH, frame = 1), finalpath)
	logpath = finalpath
	id = "[GLOB.picture_logging_prefix][number]"
	var/jsonpath = "[GLOB.picture_log_directory]/metadata.json"
	jsonpath = file(jsonpath)
	var/list/json
	if(fexists(jsonpath))
		json = json_decode(file2text(jsonpath))
		fdel(jsonpath)
	else
		json = list()
	json[id] = serialize_list(semvers = list())
	WRITE_FILE(jsonpath, json_encode(json))

/datum/picture/proc/Copy(greyscale = FALSE, cropx = 0, cropy = 0)
	var/datum/picture/P = new
	P.picture_name = picture_name
	P.picture_desc = picture_desc
	if(picture_image)
		P.picture_image = icon(picture_image)	//Copy, not reference.
	if(picture_icon)
		P.picture_icon = icon(picture_icon)
	P.psize_x = psize_x - cropx * 2
	P.psize_y = psize_y - cropy * 2
	if(greyscale)
		if(picture_image)
			P.picture_image.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		if(picture_icon)
			P.picture_icon.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	if(cropx || cropy)
		if(picture_image)
			P.picture_image.Crop(cropx, cropy, psize_x - cropx, psize_y - cropy)
		P.regenerate_small_icon()
	return P


/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/device.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	worn_icon_state = "electropack"
	w_class = WEIGHT_CLASS_TINY


/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "photo"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	worn_icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	var/datum/picture/picture
	var/scribble		//Scribble on the back.


/obj/item/photo/Initialize(mapload, datum/picture/P, datum_name = TRUE, datum_desc = TRUE)
	set_picture(P, datum_name, datum_desc, TRUE)
	return ..()


/obj/item/photo/update_icon_state()
	. = ..()
	if(!istype(picture) || !picture.picture_image)
		return
	var/icon/I = picture.get_small_icon()
	if(I)
		icon = I


/obj/item/photo/attack_self(mob/user)
	user.examinate(src)


/obj/item/photo/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		show(user)
	else
		. += span_warning("You need to get closer to get a good look at this photo!")


/obj/item/photo/proc/set_picture(datum/picture/P, setname, setdesc, name_override = FALSE)
	if(!istype(P))
		return
	picture = P
	update_icon()
	if(P.caption)
		scribble = P.caption
	if(setname && P.picture_name)
		if(name_override)
			name = P.picture_name
		else
			name = "photo - [P.picture_name]"
	if(setdesc && P.picture_desc)
		desc = P.picture_desc


/obj/item/photo/proc/show(mob/user)
	if(!istype(picture) || !picture.picture_image)
		to_chat(user, span_warning("[src] seems to be blank..."))
		return
	var/width_height = "width"
	if(picture.psize_y > picture.psize_x)
		// if we're a tall picture, swap our focus to height to stay in frame
		width_height = "height"
	user << browse_rsc(picture.picture_image, "tmp_photo.png")
	user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' [width_height]='480' style='image-rendering:pixelated' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=photo_showing;size=480x608")
	onclose(user, "[name]")


/obj/item/photo/verb/rename()
	set name = "Rename Photo"
	set category = "IC.Object"
	set src in usr

	var/n_name = stripped_input(usr, "What would you like to label the photo?", "Photo Labelling")
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == CONSCIOUS && !usr.incapacitated())
		name = "photo[(n_name ? "- '[n_name]'" : null)]"


/obj/item/camera
	name = "camera"
	icon = 'icons/obj/device.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	worn_icon_state = "camera"
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	w_class = WEIGHT_CLASS_SMALL
	atom_flags = CONDUCT
	interaction_flags = INTERACT_REQUIRES_DEXTERITY
	var/flash_enabled = TRUE
	var/state_on = "camera"
	var/state_off = "camera_off"
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/cooldown = 64
	var/blending = FALSE		//lets not take pictures while the previous is still processing!
	var/see_ghosts = CAMERA_NO_GHOSTS //for the spoop of it
	var/sound/custom_sound
	var/silent = FALSE
	var/picture_size_x = 2
	var/picture_size_y = 2
	var/picture_size_x_min = 1
	var/picture_size_y_min = 1
	var/picture_size_x_max = 4
	var/picture_size_y_max = 4
	var/can_customise = TRUE
	var/default_picture_name


/obj/item/camera/proc/adjust_zoom(mob/user)
	var/desired_x = input(user, "How high do you want the camera to shoot, between [picture_size_x_min] and [picture_size_x_max]?", "Zoom", picture_size_x) as num
	var/desired_y = input(user, "How wide do you want the camera to shoot, between [picture_size_y_min] and [picture_size_y_max]?", "Zoom", picture_size_y) as num
	picture_size_x = min(clamp(desired_x, picture_size_x_min, picture_size_x_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	picture_size_y = min(clamp(desired_y, picture_size_y_min, picture_size_y_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)


/obj/item/camera/AltClick(mob/user)
	if(!can_interact(user))
		return
	adjust_zoom(user)


/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return


/obj/item/camera/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, span_notice("[src] still has some film in it!"))
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, span_notice("You insert [I] into [src]."))
		qdel(I)
		pictures_left = pictures_max


/obj/item/camera/examine(mob/user)
	. = ..()
	. += "It has [pictures_left] photos left."


/obj/item/camera/proc/can_target(atom/target, mob/user, prox_flag)
	if(!on || blending || !pictures_left)
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(istype(user))
		if(isAI(user) && !GLOB.cameranet.checkTurfVis(T))
			return FALSE
		else if(user.client && !(get_turf(target) in get_hear(user.client.view, user)))
			return FALSE
		else if(!(get_turf(target) in get_hear(WORLD_VIEW, user)))
			return FALSE
	else					//user is an atom
		if(!(get_turf(target) in view(WORLD_VIEW, user)))
			return FALSE
	return TRUE


/obj/item/camera/afterattack(atom/target, mob/user, flag)
	if(!can_target(target, user, flag))
		return

	on = FALSE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown)
	icon_state = state_off

	INVOKE_ASYNC(src, PROC_REF(captureimage), target, user, flag, picture_size_x - 1, picture_size_y - 1)


/obj/item/camera/proc/cooldown()
	UNTIL(!blending)
	icon_state = state_on
	on = TRUE


/obj/item/camera/proc/show_picture(mob/user, datum/picture/selection)
	var/obj/item/photo/P = new(src, selection)
	P.show(user)
	to_chat(user, P.desc)
	qdel(P)


/obj/item/camera/proc/captureimage(atom/target, mob/user, flag, size_x = 1, size_y = 1)
	if(flash_enabled)
		flash_lighting_fx(8, light_power, light_color)
	blending = TRUE
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		blending = FALSE
		return FALSE
	size_x = clamp(size_x, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	size_y = clamp(size_y, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	var/list/desc = list("This is a photo of an area of [size_x+1] meters by [size_y+1] meters.")
	var/list/mobs_spotted = list()
	var/list/dead_spotted = list()
	var/ai_user = isAI(user)
	var/list/seen
	var/list/viewlist = (user?.client)? getviewsize(user.client.view) : getviewsize(WORLD_VIEW)
	var/viewr = max(viewlist[1], viewlist[2]) + max(size_x, size_y)
	var/viewc = user.client? user.client.eye : target
	seen = get_hear(viewr, viewc)
	var/list/turfs = list()
	var/list/mobs = list()
	var/clone_area = SSmapping.request_turf_block_reservation(size_x * 2 + 1, size_y * 2 + 1, 1)

	var/width = size_x * 2 + 1
	var/height = size_y * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, width, height, -size_x, -size_y))
		while(istype(placeholder, /turf/open/openspace)) //Multi-z photography
			placeholder = GET_TURF_BELOW(placeholder)
			if(!placeholder)
				break

		if(placeholder && ((ai_user && GLOB.cameranet.checkTurfVis(placeholder)) || (placeholder in seen)))
			turfs += placeholder
			for(var/mob/M in placeholder)
				mobs += M
	for(var/i in mobs)
		var/mob/M = i
		mobs_spotted += M
		if(M.stat == DEAD)
			dead_spotted += M
		desc += M.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size
	var/icon/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	get_icon.Blend("#000", ICON_UNDERLAY)

	var/datum/picture/P = new("picture", desc.Join(" "), mobs_spotted, dead_spotted, get_icon, null, psize_x, psize_y)
	after_picture(user, P, flag)
	blending = FALSE


/obj/item/camera/proc/after_picture(mob/user, datum/picture/picture, has_proximity)
	printpicture(user, picture)
	if(!silent)
		if(istype(custom_sound))
			playsound(loc, custom_sound, 75, 1, -3)
		else
			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)


/obj/item/camera/proc/printpicture(mob/user, datum/picture/picture) //Normal camera proc for creating photos
	var/obj/item/photo/p = new(get_turf(src), picture)
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(p)
		pictures_left--
		to_chat(user, span_notice("[pictures_left] photos left."))
		var/customise = "No"
		if(can_customise)
			customise = tgui_alert(user, "Do you want to customize the photo?", "Customization", list("Yes", "No"))
		if(customise == "Yes")
			var/name1 = stripped_input(user, "Set a name for this photo, or leave blank. 32 characters max.", "Name", max_length = 32)
			var/desc1 = stripped_input(user, "Set a description to add to photo, or leave blank. 128 characters max.", "Caption", max_length = 128)
			var/caption = stripped_input(user, "Set a caption for this photo, or leave blank. 256 characters max.", "Caption", max_length = 256)
			if(name1)
				picture.picture_name = name1
			if(desc1)
				picture.picture_desc = "[desc1] - [picture.picture_desc]"
			if(caption)
				picture.caption = caption
		else
			if(default_picture_name)
				picture.picture_name = default_picture_name

	p.set_picture(picture, TRUE, TRUE)
	if(CONFIG_GET(flag/picture_logging_camera))
		picture.log_to_file()

/obj/effect/appearance_clone/New(loc, atom/A) //Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(istype(A))
		appearance = A.appearance
		dir = A.dir
		if(ismovable(A))
			var/atom/movable/AM = A
			step_x = AM.step_x
			step_y = AM.step_y

	return ..()


#define PHYSICAL_POSITION(atom) ((atom.y * ICON_SIZE_Y) + (atom.pixel_y))

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/atoms = list()
	var/list/lighting = list()
	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	var/mutable_appearance/backdrop = mutable_appearance('icons/mob/screen/generic.dmi', "flash")
	backdrop.blend_mode = BLEND_OVERLAY
	backdrop.color = "#292319"

	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height && size_x >= 0 && size_y > 0)
		var/turf/bottom_left = clone_area.bottom_left_turfs[1]
		var/cloned_center_x = round(bottom_left.x + ((total_x - 1) / 2))
		var/cloned_center_y = round(bottom_left.y + ((total_y - 1) / 2))
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, bottom_left.z)
			if(!(newT in clone_area.reserved_turfs)) //sanity check so we don't overwrite other areas somehow
				continue
			atoms += new /obj/effect/appearance_clone(newT, T)
			if(T.loc.icon_state)
				atoms += new /obj/effect/appearance_clone(newT, T.loc)
			if(T.static_lighting_object)
				var/obj/effect/appearance_clone/lighting_overlay = new(newT)
				lighting_overlay.appearance = T.static_lighting_object.current_underlay
				lighting_overlay.underlays += backdrop
				lighting_overlay.blend_mode = BLEND_MULTIPLY
				lighting += lighting_overlay
			for(var/i in T.contents)
				var/atom/A = i
				if(!A.invisibility || (see_ghosts && isobserver(A)))
					atoms += new /obj/effect/appearance_clone(newT, A)
		skip_normal = TRUE
		wipe_atoms = TRUE
		center = locate(cloned_center_x, cloned_center_y, bottom_left.z)

	if(!skip_normal)
		for(var/i in turfs)
			var/turf/T = i
			atoms += T
			if(T.static_lighting_object)
				var/obj/effect/appearance_clone/lighting_overlay = new(T)
				lighting_overlay.appearance = T.static_lighting_object.current_underlay
				lighting_overlay.underlays += backdrop
				lighting_overlay.blend_mode = BLEND_MULTIPLY
				lighting += lighting_overlay
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && isobserver(A)))
						continue
				atoms += A
			CHECK_TICK
	var/icon/res = icon('icons/blanks/96x96.dmi', "nothing")
	res.Scale(psize_x, psize_y)
	atoms += lighting

	var/list/sorted = list()
	var/j
	for(var/i in 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.plane > c.plane)
				continue
			if(c2.plane < c.plane)
				break
			var/c_position = PHYSICAL_POSITION(c)
			var/c2_position = PHYSICAL_POSITION(c2)
			// If you are above me, I layer above you
			if(c2_position - 32 >= c_position)
				break
			// If I am above you you will always layer above me
			if(c2_position <= c_position - 32)
				continue
			if(c2.layer < c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15

	if(!skip_normal) //these are not clones
		for(var/atom/A in sorted)
			var/xo = (A.x - center.x) * ICON_SIZE_X + A.pixel_x + xcomp
			var/yo = (A.y - center.y) * ICON_SIZE_Y + A.pixel_y + ycomp
			if(ismovable(A))
				var/atom/movable/AM = A
				xo += AM.step_x
				yo += AM.step_y
			var/icon/img = getFlatIcon(A, no_anim = TRUE)
			res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
			CHECK_TICK
	else
		for(var/X in sorted) //these are clones
			var/obj/effect/appearance_clone/clone = X
			var/icon/img = getFlatIcon(clone, no_anim = TRUE)
			if(!img)
				CHECK_TICK
				continue
			// Center of the image in X
			var/xo = (clone.x - center.x) * ICON_SIZE_X + clone.pixel_x + xcomp + clone.step_x
			// Center of the image in Y
			var/yo = (clone.y - center.y) * ICON_SIZE_Y + clone.pixel_y + ycomp + clone.step_y

			if(clone.transform) // getFlatIcon doesn't give a snot about transforms.
				var/datum/decompose_matrix/decompose = clone.transform.decompose()
				// Scale in X, Y
				if(decompose.scale_x != 1 || decompose.scale_y != 1)
					var/base_w = img.Width()
					var/base_h = img.Height()
					// scale_x can be negative
					img.Scale(base_w * abs(decompose.scale_x), base_h * decompose.scale_y)
					if(decompose.scale_x < 0)
						img.Flip(EAST)
					xo -= base_w * (decompose.scale_x - SIGN(decompose.scale_x)) / 2 * SIGN(decompose.scale_x)
					yo -= base_h * (decompose.scale_y - 1) / 2
				// Rotation
				if(decompose.rotation != 0)
					img.Turn(decompose.rotation)
				// Shift
				xo += decompose.shift_x
				yo += decompose.shift_y

			res.Blend(img, blendMode2iconMode(clone.blend_mode), xo, yo)
			CHECK_TICK

	if(wipe_atoms)
		QDEL_LIST(atoms)
	else
		QDEL_LIST(lighting)

	return res

#undef PHYSICAL_POSITION

/obj/item/camera/oldcamera
	name = "Old Camera"
	desc = "An old, slightly beat-up digital camera, with a cheap photo printer taped on. It's a nice shade of blue."
	icon_state = "oldcamera"
	pictures_left = 30


#undef CAMERA_NO_GHOSTS
#undef CAMERA_SEE_GHOSTS_BASIC
#undef CAMERA_SEE_GHOSTS_ORBIT
#undef CAMERA_PICTURE_SIZE_HARD_LIMIT

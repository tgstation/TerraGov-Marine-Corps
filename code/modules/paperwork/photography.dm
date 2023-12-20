#define CAMERA_NO_GHOSTS 0
#define CAMERA_SEE_GHOSTS_BASIC 1
#define CAMERA_SEE_GHOSTS_ORBIT 2
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 21

/datum/picture
	var/picture_name = "picture"
	var/picture_desc = "This is a picture."
	var/list/mobs_seen = list()
	var/list/dead_seen = list()
	var/caption
	var/icon/picture_image
	var/icon/picture_icon
	var/psize_x = 96
	var/psize_y = 96

/datum/picture/New(name, desc, mobs_spotted, dead_spotted, image, icon, size_x, size_y, caption_, autogenerate_icon)
	if(!isnull(name))
		picture_name = name
	if(!isnull(desc))
		picture_desc = desc
	if(!isnull(mobs_spotted))
		mobs_seen = mobs_spotted
	if(!isnull(dead_spotted))
		dead_seen = dead_spotted
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


/datum/picture/proc/get_small_icon()
	if(!picture_icon)
		regenerate_small_icon()
	return picture_icon


/datum/picture/proc/regenerate_small_icon()
	if(!picture_image)
		return
	var/icon/small_img = icon(picture_image)
	var/icon/ic = icon('icons/obj/items/items.dmi', "photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img, ICON_OVERLAY, 13, 13)
	picture_icon = ic


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
	item_state = "electropack"
	w_class = WEIGHT_CLASS_TINY


/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "photo"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	var/datum/picture/picture
	var/scribble		//Scribble on the back.


/obj/item/photo/Initialize(mapload, datum/picture/P, datum_name = TRUE, datum_desc = TRUE)
	set_picture(P, datum_name, datum_desc, TRUE)
	return ..()


/obj/item/photo/update_icon()
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
	user << browse_rsc(picture.picture_image, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='480' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=photo_showing;size=480x608")
	onclose(user, "[name]")


/obj/item/photo/verb/rename()
	set name = "Rename Photo"
	set category = "Object"
	set src in usr

	var/n_name = stripped_input(usr, "What would you like to label the photo?", "Photo Labelling")
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == CONSCIOUS && !usr.incapacitated())
		name = "photo[(n_name ? "- '[n_name]'" : null)]"


/obj/item/camera
	name = "camera"
	icon = 'icons/obj/device.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "camera"
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
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
	var/clone_area = SSmapping.RequestBlockReservation(size_x * 2 + 1, size_y * 2 + 1)
	for(var/turf/T in block(locate(target_turf.x - size_x, target_turf.y - size_y, target_turf.z), locate(target_turf.x + size_x, target_turf.y + size_y, target_turf.z)))
		if((ai_user && GLOB.cameranet.checkTurfVis(T)) || (T in seen))
			turfs += T
			for(var/mob/M in T)
				mobs += M
	for(var/i in mobs)
		var/mob/M = i
		mobs_spotted += M
		if(M.stat == DEAD)
			dead_spotted += M
		desc += M.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size
	var/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	temp.Blend("#000", ICON_OVERLAY)
	temp.Scale(psize_x, psize_y)
	temp.Blend(get_icon, ICON_OVERLAY)

	var/datum/picture/P = new("picture", desc.Join(" "), mobs_spotted, dead_spotted, temp, null, psize_x, psize_y)
	after_picture(user, P, flag)
	blending = FALSE


/obj/item/camera/proc/after_picture(mob/user, datum/picture/picture, has_proximity)
	printpicture(user, picture)


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


/obj/effect/appearance_clone/New(loc, atom/A) //Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(istype(A))
		appearance = A.appearance
		dir = A.dir
		if(ismovableatom(A))
			var/atom/movable/AM = A
			step_x = AM.step_x
			step_y = AM.step_y

	return ..()


/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/atoms = list()
	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height && size_x >= 0 && size_y > 0)
		var/cloned_center_x = round(clone_area.bottom_left_coords[1] + ((total_x - 1) / 2))
		var/cloned_center_y = round(clone_area.bottom_left_coords[2] + ((total_y - 1) / 2))
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, clone_area.bottom_left_coords[3])
			if(!(newT in clone_area.reserved_turfs))		//sanity check so we don't overwrite other areas somehow
				continue
			atoms += new /obj/effect/appearance_clone(newT, T)
			if(T.loc.icon_state)
				atoms += new /obj/effect/appearance_clone(newT, T.loc)
			for(var/i in T.contents)
				var/atom/A = i
				if(!A.invisibility || (see_ghosts && isobserver(A)))
					atoms += new /obj/effect/appearance_clone(newT, A)
		skip_normal = TRUE
		wipe_atoms = TRUE
		center = locate(cloned_center_x, cloned_center_y, clone_area.bottom_left_coords[3])

	if(!skip_normal)
		for(var/i in turfs)
			var/turf/T = i
			atoms += T
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && isobserver(A)))
						continue
				atoms += A
			CHECK_TICK

	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(psize_x, psize_y)

	var/list/sorted = list()
	var/j
	for(var/i in 1 to length(atoms))
		var/atom/c = atoms[i]
		for(j = length(sorted), j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15


	for(var/atom/A in sorted)
		var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp
		var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp
		if(ismovableatom(A))
			var/atom/movable/AM = A
			xo += AM.step_x
			yo += AM.step_y
		var/icon/img = getFlatIcon(A)
		if(img)
			res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
		CHECK_TICK

	if(!silent)
		if(istype(custom_sound))				//This is where the camera actually finishes its exposure.
			playsound(loc, custom_sound, 75, 1, -3)
		else
			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	if(wipe_atoms)
		QDEL_LIST(atoms)

	return res


/obj/item/camera/oldcamera
	name = "Old Camera"
	desc = "An old, slightly beat-up digital camera, with a cheap photo printer taped on. It's a nice shade of blue."
	icon_state = "oldcamera"
	pictures_left = 30


#undef CAMERA_NO_GHOSTS
#undef CAMERA_SEE_GHOSTS_BASIC
#undef CAMERA_SEE_GHOSTS_ORBIT
#undef CAMERA_PICTURE_SIZE_HARD_LIMIT

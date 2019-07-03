/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	desc = "A wonderful yet fake friend."
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	var/icon/human_image
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/mob/living/owner

	var/datum/action/innate/imaginary_join/join
	var/datum/action/innate/imaginary_hide/hide


/mob/camera/imaginary_friend/Login()
	. = ..()
	setup_friend()
	Show()


/mob/camera/imaginary_friend/Logout()
	. = ..()
	deactivate()


/mob/camera/imaginary_friend/Initialize(mapload, mob/owner)
	. = ..()

	src.owner = owner
	copy_known_languages_from(owner, TRUE)

	join = new
	join.give_action(src)
	hide = new
	hide.give_action(src)


/mob/camera/imaginary_friend/proc/setup_friend()
	name = client.prefs.real_name
	real_name = name
	gender = client.prefs.gender
	human_image = get_flat_human_icon(null, SSjob.GetJobType(/datum/job/other/spatial_agent), client.prefs)


/mob/camera/imaginary_friend/proc/Show()
	if(!client)
		return

	owner.client?.images.Remove(current_image)

	client.images.Remove(current_image)

	current_image = image(human_image, src, layer = MOB_LAYER, dir = dir)
	current_image.override = TRUE
	current_image.name = name
	if(hidden)
		current_image.alpha = 150

	if(!hidden && owner.client)
		owner.client.images |= current_image

	client.images |= current_image


/mob/camera/imaginary_friend/Destroy()
	owner.client?.images.Remove(human_image)

	client?.images.Remove(human_image)

	return ..()


/mob/camera/imaginary_friend/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	if(!message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return

		if(client.handle_spam_prevention(message, MUTE_IC))
			return

	friend_talk(message)


/mob/camera/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	to_chat(src, compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode))


/mob/camera/imaginary_friend/proc/friend_talk(message)
	message = capitalize(trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	log_talk(message, LOG_SAY, tag = "imaginary friend")

	var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[say_quote(message)]</span></span>"
	var/dead_rendered = "<span class='game say'><span class='name'>[name] (Imaginary friend of [owner])</span> <span class='message'>[say_quote(message)]</span></span>"

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")

	var/image/I = image('icons/mob/talk.dmi', src, "default[say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/flick_overlay, I, owner.client ? list(client, owner.client) : list(client), 3 SECONDS)

	for(var/i in GLOB.dead_mob_list)
		var/mob/M = i
		if(isnewplayer(M))
			continue
		var/link = FOLLOW_LINK(M, owner)
		to_chat(M, "[link] [dead_rendered]")


/mob/camera/imaginary_friend/Move(newloc, Dir = 0)
	if(world.time < move_delay)
		return FALSE

	if(get_dist(src, owner) > 9)
		recall()
		move_delay = world.time + 10
		return FALSE

	forceMove(newloc)
	move_delay = world.time + 1


/mob/camera/imaginary_friend/forceMove(atom/destination)
	dir = get_dir(get_turf(src), destination)
	loc = destination
	Show()


/mob/camera/imaginary_friend/proc/recall()
	if(QDELETED(owner))
		deactivate()
		return FALSE
	if(loc == owner)
		return FALSE
	forceMove(owner)


/mob/camera/imaginary_friend/proc/deactivate()
	icon = human_image
	log_admin("[key_name(src)] stopped being imaginary friend of [key_name(owner)].")
	message_admins("[ADMIN_TPMONTY(src)] stopped being imaginary friend of [ADMIN_TPMONTY(owner)].")
	ghostize()
	qdel(src)


/mob/camera/imaginary_friend/toggle_typing_indicator(emoting)
	return


/datum/action/innate/imaginary_join
	name = "Join"
	desc = "Join your owner, following them from inside their mind."

	icon_icon_state = "joinmob"
	button_icon_state = "template2"


/datum/action/innate/imaginary_join/Activate()
	var/mob/camera/imaginary_friend/I = owner
	I.recall()


/datum/action/innate/imaginary_hide
	name = "Hide"
	desc = "Hide yourself from your owner's sight."

	icon_icon_state = "hidemob"
	button_icon_state = "template2"


/datum/action/innate/imaginary_hide/Activate()
	active = TRUE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = FALSE
	I.Show()
	name = "Hide"
	desc = "Hide yourself from your owner's sight."
	icon_icon_state = "hidemob"
	update_button_icon()


/datum/action/innate/imaginary_hide/Deactivate()
	active = FALSE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = TRUE
	I.Show()
	name = "Show"
	desc = "Become visible to your owner."
	icon_icon_state = "unhidemob"
	update_button_icon()
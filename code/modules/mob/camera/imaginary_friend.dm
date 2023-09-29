/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	desc = "A wonderful yet fake friend."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_OBSERVER
	stat = DEAD // Keep hearing ghosts and other IFs
	invisibility = INVISIBILITY_MAXIMUM
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	var/icon/human_image
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/mob/living/owner

	//HUD toggles
	var/xeno_mobhud = FALSE
	var/med_squad_mobhud = FALSE

	var/datum/action/innate/imaginary_join/join
	var/datum/action/innate/imaginary_hide/hide

	var/list/outfit_choices = list(/datum/job/spatial_agent,
									/datum/job/spatial_agent/galaxy_red,
									/datum/job/spatial_agent/galaxy_blue,
									/datum/job/spatial_agent/xeno_suit,
									/datum/job/spatial_agent/marine_officer,
									)

/mob/camera/imaginary_friend/Login()
	. = ..()
	setup_friend()
	Show()


/mob/camera/imaginary_friend/Logout()
	. = ..()
	deactivate()


/mob/camera/imaginary_friend/Initialize(mapload, mob/owner)
	. = ..()

	if(!owner)
		return INITIALIZE_HINT_QDEL
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
	var/outfit_choice = tgui_input_list(usr, "Choose your appearance:", "[src]", outfit_choices)
	if(!outfit_choice)
		outfit_choice = outfit_choices[1]
	human_image = get_flat_human_icon(null, SSjob.GetJobType(outfit_choice), client.prefs)


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
	if(owner?.client)
		owner.client?.images.Remove(human_image)

	client?.images.Remove(human_image)

	return ..()

/mob/camera/imaginary_friend/verb/toggle_darkness()
	set category = "Imaginary Friend"
	set name = "Toggle Darkness"

	switch(lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	update_sight()

/mob/camera/imaginary_friend/verb/update_outfit()
	set category = "Imaginary Friend"
	set name = "Change Appearance"

	var/outfit_choice = tgui_input_list(usr, "Choose your appearance:", "[src]", outfit_choices)
	if(!outfit_choice)
		return
	human_image = get_flat_human_icon(null, SSjob.GetJobType(outfit_choice), client.prefs)
	Show()

/mob/camera/imaginary_friend/verb/toggle_xeno_mobhud()
	set category = "Imaginary Friend"
	set name = "Toggle Xeno Status HUD"

	xeno_mobhud = !xeno_mobhud
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_XENO_STATUS]
	xeno_mobhud ? H.add_hud_to(src) : H.remove_hud_from(src)
	to_chat(src, span_notice("You have [xeno_mobhud ? "enabled" : "disabled"] the Xeno Status HUD."))

/mob/camera/imaginary_friend/verb/toggle_human_mobhud()
	set category = "Imaginary Friend"
	set name = "Toggle Human Status HUD"

	med_squad_mobhud = !med_squad_mobhud
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
	med_squad_mobhud ? H.add_hud_to(src) : H.remove_hud_from(src)
	H = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	med_squad_mobhud ? H.add_hud_to(src) : H.remove_hud_from(src)
	H = GLOB.huds[DATA_HUD_SQUAD_SOM]
	med_squad_mobhud ? H.add_hud_to(src) : H.remove_hud_from(src)
	to_chat(src, span_notice("You have [med_squad_mobhud ? "enabled" : "disabled"] the Human Status HUD."))

/mob/camera/imaginary_friend/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	if(!message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(is_banned_from(ckey, "IC"))
			to_chat(src, span_warning("You are banned from IC chat."))
			return

		if(client.handle_spam_prevention(message, MUTE_IC))
			return

	friend_talk(message)


/mob/camera/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(client?.prefs.chat_on_map && (client.prefs.see_chat_non_mob || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans, message_mode)
	to_chat(src, compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode))


/mob/camera/imaginary_friend/proc/friend_talk(message)
	message = capitalize(trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	log_talk(message, LOG_SAY, tag = "imaginary friend")

	var/rendered = "<span class='game say'>[span_name("[name]")] [span_message("[say_quote(message)]")]</span>"
	var/dead_rendered = "<span class='game say'>[span_name("[name] (Imaginary friend of [owner])")] [span_message("[say_quote(message)]")]</span>"

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")
	if(!hidden) // runechat if we are visible
		if(owner.client?.prefs.chat_on_map)
			owner.create_chat_message(src, owner.get_default_language(), message)
		if(client?.prefs.chat_on_map)
			create_chat_message(src, get_default_language(), message)

	//speech bubble
	var/mutable_appearance/MA = mutable_appearance('icons/mob/talk.dmi', src, "default[say_test(message)]", FLY_LAYER)
	MA.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), MA, owner.client ? list(client, owner.client) : list(client), 3 SECONDS)

	for(var/i in GLOB.dead_mob_list)
		var/mob/M = i
		if(isnewplayer(M) || src == i)
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
	log_admin("[key_name(src)] stopped being imaginary friend of [key_name(owner)].")
	message_admins("[ADMIN_TPMONTY(src)] stopped being imaginary friend of [ADMIN_TPMONTY(owner)].")
	ghostize()
	qdel(src)


/mob/camera/imaginary_friend/ghostize()
	icon = human_image
	return ..()

/datum/action/innate/imaginary_join
	name = "Join"
	desc = "Join your owner, following them from inside their mind."

	action_icon_state = "joinmob"
	background_icon_state = "template2"


/datum/action/innate/imaginary_join/Activate()
	var/mob/camera/imaginary_friend/I = owner
	I.recall()


/datum/action/innate/imaginary_hide
	name = "Hide"
	desc = "Hide yourself from your owner's sight."

	action_icon_state = "hidemob"
	background_icon_state = "template2"


/datum/action/innate/imaginary_hide/Activate()
	active = TRUE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = TRUE
	I.Show()
	name = "Show"
	desc = "Become visible to your owner."
	action_icon_state = "unhidemob"
	update_button_icon()


/datum/action/innate/imaginary_hide/Deactivate()
	active = FALSE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = FALSE
	I.Show()
	name = "Hide"
	desc = "Hide yourself from your owner's sight."
	action_icon_state = "hidemob"
	update_button_icon()

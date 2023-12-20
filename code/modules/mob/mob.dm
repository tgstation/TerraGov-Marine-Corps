
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.offered_mob_list -= src
	for(var/alert in alerts)
		clear_alert(alert, TRUE)
	if(length(observers))
		for(var/mob/dead/observes AS in observers)
			observes.reset_perspective(null)
	ghostize()
	clear_fullscreens()
	if(mind)
		stack_trace("Found a reference to an undeleted mind in mob/Destroy(). Mind name: [mind.name]. Mind mob: [mind.current]")
		mind = null
	if(hud_used)
		QDEL_NULL(hud_used)
	if(s_active)
		s_active.hide_from(src)
	unset_machine()
	for(var/a in actions)
		var/datum/action/action_to_remove = a
		action_to_remove.remove_action(src)
	set_focus(null)
	return ..()

/mob/Initialize(mapload)
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	set_focus(src)
	prepare_huds()
	. = ..()
	if(islist(skills))
		set_skills(getSkills(arglist(skills)))
	else if(!skills)
		set_skills(getSkills())
	else if(!istype(skills, /datum/skills))
		stack_trace("Invalid type [skills.type] found in .skills during /mob Initialize()")
	update_config_movespeed()
	update_movespeed(TRUE)
	log_mob_tag("\[[tag]\] CREATED: [key_name(src)]")
	become_hearing_sensitive()

/mob/proc/show_message(msg, type, alt_msg, alt_type, avoid_highlight)
	if(!client)
		return FALSE

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	to_chat(src, msg)
	return TRUE


/mob/living/show_message(msg, type, alt_msg, alt_type, avoid_highlight)
	if(!client)
		return FALSE

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type == EMOTE_VISIBLE && eye_blind) //Vision related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type

		if(type == EMOTE_AUDIBLE && isdeaf(src)) //Hearing related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type
				if(type == EMOTE_VISIBLE && eye_blind)
					return FALSE

	if(stat == UNCONSCIOUS && type == EMOTE_AUDIBLE)
		to_chat(src, "<i>... You can almost hear something ...</i>")
		return FALSE
	to_chat(src, msg, avoid_highlighting = avoid_highlight)
	return TRUE

/**
 * Show a message to all player mobs who sees this atom
 * Show a message to the src mob (if the src is a mob)
 * Use for atoms performing visible actions
 * message is output to anyone who can see, e.g. "The [src] does something!"
 * self_message (optional) is what the src mob sees e.g. "You do something!"
 * blind_message (optional) is what blind people will hear e.g. "You hear something!"
 * vision_distance (optional) define how many tiles away the message can be seen.
 * ignored_mob (optional) doesn't show any message to a given mob if TRUE.
 */
/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob, visible_message_flags = NONE, emote_prefix)
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/range = 7
	if(vision_distance)
		range = vision_distance

	var/raw_msg = message
	if(visible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"

	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue

		if(M == ignored_mob)
			continue

		var/msg = message

		if(M == src && self_message) //the src always see the main message or self message
			msg = self_message

			if((visible_message_flags & COMBAT_MESSAGE) && M.client.prefs.mute_self_combat_messages)
				continue

		else
			if(M.see_invisible < invisibility || (T != loc && T != src)) //if src is invisible to us or is inside something (and isn't a turf),
				if(!blind_message) // then people see blind message if there is one, otherwise nothing.
					continue

				msg = blind_message

			if((visible_message_flags & COMBAT_MESSAGE) && M.client.prefs.mute_others_combat_messages)
				continue

		if(visible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, visible_message_flags) && !is_blind(M))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = visible_message_flags)

		M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)


///Returns the client runechat visible messages preference according to the message type.
/atom/proc/rc_vc_msg_prefs_check(mob/target, visible_message_flags = NONE)
	if(!target.client?.prefs.chat_on_map || !target.client.prefs.see_chat_non_mob)
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.see_rc_emotes)
		return FALSE
	return TRUE

/mob/rc_vc_msg_prefs_check(mob/target, message, visible_message_flags = NONE)
	if(!target.client?.prefs.chat_on_map)
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.see_rc_emotes)
		return FALSE
	return TRUE



// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message, audible_message_flags = NONE, emote_prefix)
	var/range = 7
	var/raw_msg = message
	if(hearing_distance)
		range = hearing_distance
	if(audible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"
	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		if(audible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, audible_message_flags) && !isdeaf(M))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = audible_message_flags)
		M.show_message(msg, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


/**
 * Show a message to all mobs in earshot of this atom
 * Use for objects performing audible actions
 * message is the message output to anyone who can hear.
 * deaf_message (optional) is what deaf people will see.
 * hearing_distance (optional) is the range, how many tiles away the message can be heard.
 */
/atom/proc/audible_message(message, deaf_message, hearing_distance, self_message, audible_message_flags = NONE, emote_prefix)
	var/range = 7
	var/raw_msg = message
	if(hearing_distance)
		range = hearing_distance
	if(audible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"
	for(var/mob/M in get_hearers_in_view(range, src))
		if(audible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, audible_message_flags))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = audible_message_flags)
		M.show_message(message, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


///This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		equip_to_slot_if_possible(W, slot, FALSE) // equiphere


///Attempts to put an item in either hand
/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = FALSE, warning = FALSE, redraw_mob = TRUE)
	if(equip_to_slot_if_possible(W, SLOT_L_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	else if(equip_to_slot_if_possible(W, SLOT_R_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	return FALSE

/**
 * This is a SAFE proc. Use this instead of equip_to_splot()!
 * set del_on_fail to have it delete W if it fails to equip
 * unset redraw_mob to prevent the mob from being redrawn at the end.
 */
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, ignore_delay = TRUE, del_on_fail = FALSE, warning = TRUE, redraw_mob = TRUE, override_nodrop = FALSE)
	if(!istype(W) || QDELETED(W)) //This qdeleted is to prevent stupid behavior with things that qdel during init, like say stacks
		return FALSE
	if(!W.mob_can_equip(src, slot, warning, override_nodrop))
		if(del_on_fail)
			qdel(W)
			return FALSE
		if(warning)
			to_chat(src, span_warning("You are unable to equip that."))
		return FALSE
	if(W.equip_delay_self && !ignore_delay)
		if(!do_after(src, W.equip_delay_self, NONE, W, BUSY_ICON_FRIENDLY))
			to_chat(src, "You stop putting on \the [W]")
			return FALSE
		equip_to_slot(W, slot) //This proc should not ever fail.
		//This will unwield items -without- triggering lights.
		if(CHECK_BITFIELD(W.flags_item, TWOHANDED))
			W.unwield(src)
		return TRUE
	else
		equip_to_slot(W, slot) //This proc should not ever fail.
		//This will unwield items -without- triggering lights.
		if(CHECK_BITFIELD(W.flags_item, TWOHANDED))
			W.unwield(src)
		return TRUE

/**
*This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
*In most cases you will want to use equip_to_slot_if_possible()
*/
/mob/proc/equip_to_slot(obj/item/W as obj, slot, bitslot = FALSE)
	return

///This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds starts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, override_nodrop = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, FALSE, override_nodrop)

/// Tries to equip an item to the slot provided, otherwise tries to put it in hands, if hands are full the item is deleted
/mob/proc/equip_to_slot_or_hand(obj/item/W, slot, override_nodrop = FALSE)
	if(!equip_to_slot_if_possible(W, slot, TRUE, FALSE, FALSE, FALSE, override_nodrop))
		put_in_any_hand_if_possible(W, TRUE, FALSE)

///Attempts to store an item in a valid location based on SLOT_EQUIP_ORDER
/mob/proc/equip_to_appropriate_slot(obj/item/W, ignore_delay = TRUE)
	if(!istype(W))
		return FALSE

	for(var/slot in SLOT_EQUIP_ORDER)
		if(equip_to_slot_if_possible(W, slot, ignore_delay, FALSE, FALSE, FALSE))
			return TRUE

	return FALSE

///Checks an inventory slot for an item that can be drawn that is directly stored, or inside another storage item, and draws it if possible
/mob/proc/draw_from_slot_if_possible(slot)
	if(!slot)
		return FALSE

	var/obj/item/I = get_item_by_slot(slot)

	if(!I)
		return FALSE

	//This is quite horrible, there's probably a better way to do it.
	//Each actual inventory slot has more than one slot define associated with it.
	//The defines below are for specific items in specific slots, which allows for a much more specific draw order, i.e. drawing a weapon from a slot which would otherwise be lower in the order
	if(slot == SLOT_IN_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon))))
		return FALSE
	if(slot == SLOT_IN_S_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/belt/knifepouch))))
		return FALSE
	if(slot == SLOT_IN_B_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon))))
		return FALSE
	if(slot == SLOT_IN_ACCESSORY && (!istype(I, /obj/item/clothing/under)))
		return FALSE
	if(slot == SLOT_IN_L_POUCH && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/pouch/pistol))))
		return FALSE
	if(slot == SLOT_IN_R_POUCH && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/pouch/pistol))))
		return FALSE

	//calls on the item to return a suitable item to be equipped
	var/obj/item/found = I.do_quick_equip(src)
	if(!found)
		return FALSE
	if(CHECK_BITFIELD(found.flags_inventory, NOQUICKEQUIP))
		return FALSE
	temporarilyRemoveItemFromInventory(found)
	put_in_hands(found)
	return TRUE

/mob/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Player Panel"] = "?_src_=vars;[HrefToken()];playerpanel=[REF(src)]"


/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")

/mob/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["default_language"])
		var/language = text2path(href_list["default_language"])
		var/datum/language_holder/H = get_language_holder()

		if(!H.has_language(language))
			return

		H.selected_default_language = language
		if(isliving(src))
			var/mob/living/L = src
			L.language_menu()

/mob/living/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	if(QDELETED(AM) || QDELETED(usr) || src == AM || !isturf(loc) || !Adjacent(AM) || status_flags & INCORPOREAL)	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return FALSE

	if(!AM.can_be_pulled(src, force))
		return FALSE

	if(throwing || incapacitated())
		return FALSE

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return FALSE
	else if(l_hand && r_hand)
		if(!suppress_message)
			to_chat(src, span_warning("Cannot grab, lacking free hands to do so!"))
		return FALSE

	AM.add_fingerprint(src, "pull")

	changeNext_move(CLICK_CD_GRABBING)

	if(AM.pulledby)
		if(!suppress_message)
			AM.visible_message(span_danger("[src] has pulled [AM] from [AM.pulledby]'s grip."),
				span_danger("[src] has pulled you from [AM.pulledby]'s grip."), null, null, src)
			to_chat(src, span_notice("You pull [AM] from [AM.pulledby]'s grip!"))
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.

	var/atom/movable/buckle = AM.is_buckled()
	if(buckle)
		if(buckle.anchored)
			return
		return start_pulling(buckle)

	AM.set_glide_size(glide_size)

	pulling = AM
	AM.pulledby = src
	AM.glide_modifier_flags |= GLIDE_MOD_PULLED

	var/obj/item/grab/grab_item = new /obj/item/grab()
	grab_item.grabbed_thing = AM
	if(!put_in_hands(grab_item)) //placing the grab in hand failed, grab is dropped, deleted, and we stop pulling automatically.
		CRASH("Failed to put grab_item in the hands of [src]")

	if(!suppress_message)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)


	hud_used?.pull_icon?.icon_state = "pull"

	if(ismob(AM))
		var/mob/pulled_mob = AM
		log_combat(src, pulled_mob, "grabbed")
		do_attack_animation(pulled_mob, ATTACK_EFFECT_GRAB)

		if(!suppress_message)
			visible_message(span_warning("[src] has grabbed [pulled_mob] passively!"), null, null, 5)

		if(pulled_mob.mob_size > MOB_SIZE_HUMAN || !(pulled_mob.status_flags & CANPUSH))
			grab_item.icon_state = "!reinforce"

		set_pull_offsets(pulled_mob)

	update_pull_movespeed()

	return AM.pull_response(src) //returns true if the response doesn't break the pull

//how a movable atom reacts to being pulled.
//returns true if the pull isn't severed by the response
/atom/movable/proc/pull_response(mob/puller)
	return TRUE

/**
 * Buckle to another mob
 * You can buckle on mobs if you're next to them since most are dense
 * Turns you to face the other mob too
 */
/mob/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(buckling_mob.buckled)
		return FALSE
	if(buckling_mob.loc != loc && !buckling_mob.forceMove(loc))
		return FALSE
	return ..()

///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1
///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	. = 9
	if(!isliving(seat))
		return
	var/mob/living/L = seat
	if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
		return 0


/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"

/mob/serialize_list(list/options, list/semvers)
	. = ..()

	.["tag"] = tag
	.["name"] = name
	.["ckey"] = ckey
	.["key"] = key

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

/mob/proc/get_paygrade()
	return ""

// facing verbs
/mob/proc/canface()
	if(!canmove)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE


/mob/proc/facedir(ndir)
	if(!canface())
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOB_FACE_DIR, ndir)
	setDir(ndir)
	if(buckled && !buckled.anchored)
		buckled.setDir(ndir)
	return TRUE


/proc/is_species(A, species_datum)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(istype(H.species, species_datum))
			return TRUE
	return FALSE

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	overlay_fullscreen("pain", /atom/movable/screen/fullscreen/pain, 1)
	clear_fullscreen("pain")

///Called to update the stat var, returns a boolean to indicate if it has been handled.
/mob/proc/update_stat()
	return FALSE

/mob/proc/can_inject()
	return reagents

/mob/proc/get_idcard(hand_first)
	return

/mob/proc/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/forceMove(atom/destination)
	. = ..()
	if(!.)
		return
	stop_pulling()
	if(buckled)
		buckled.unbuckle_mob(src)


/mob/proc/trainteleport(atom/destination)
	if(!destination || anchored)
		return FALSE //Gotta go somewhere and be able to move
	if(!pulling)
		return forceMove(destination) //No need for a special proc if there's nothing being pulled.
	pulledby?.stop_pulling() //The leader of the choo-choo train breaks the pull
	var/list/conga_line = list()
	var/end_of_conga = FALSE
	var/mob/S = src
	conga_line += S
	if(S.buckled)
		if(S.buckled.anchored)
			S.buckled.unbuckle_mob(S) //Unbuckle the first of the line if anchored.
		else
			conga_line += S.buckled
	while(!end_of_conga)
		var/atom/movable/A = S.pulling
		if(A in conga_line || A.anchored) //No loops, nor moving anchored things.
			end_of_conga = TRUE
			break
		conga_line += A
		var/mob/M = A
		if(istype(M)) //Is a mob
			if(M.buckled && !(M.buckled in conga_line))
				if(M.buckled.anchored)
					conga_line -= A //Remove from the conga line if on anchored buckles.
					end_of_conga = TRUE //Party is over, they won't be dragging anyone themselves.
					break
				else
					conga_line += M.buckled //Or bring the buckles along.
			var/mob/living/L = M
			if(istype(L))
				L.smokecloak_off()
			if(M.pulling)
				S = M
			else
				end_of_conga = TRUE
		else if(isobj(A)) //Not a mob.
			var/obj/O = A
			for(var/m in O.buckled_mobs)
				conga_line += m
				var/mob/buckled_mob = m
				if(!buckled_mob.pulling)
					continue
				buckled_mob.stop_pulling() //No support for wheelchair trains yet.
			var/obj/structure/bed/B = O
			if(istype(B) && B.buckled_bodybag)
				conga_line += B.buckled_bodybag
			end_of_conga = TRUE //Only mobs can continue the cycle.
	for(var/atom/movable/AM in conga_line)
		AM.forceMove(destination)
	return TRUE


/mob/proc/set_interaction(atom/movable/AM)
	if(interactee)
		if(interactee == AM) //already set
			return
		else
			unset_interaction()
	interactee = AM
	interactee.on_set_interaction(src)


/mob/proc/unset_interaction()
	if(interactee)
		interactee.on_unset_interaction(src)
		interactee = null


/mob/proc/add_emote_overlay(image/emote_overlay, remove_delay = TYPING_INDICATOR_LIFETIME)
	emote_overlay.appearance_flags = APPEARANCE_UI_TRANSFORM
	emote_overlay.plane = ABOVE_LIGHTING_PLANE
	emote_overlay.layer = ABOVE_HUD_LAYER
	overlays += emote_overlay

	if(remove_delay)
		addtimer(CALLBACK(src, PROC_REF(remove_emote_overlay), emote_overlay, TRUE), remove_delay)


/mob/proc/remove_emote_overlay(image/emote_overlay, delete)
	overlays -= emote_overlay
	if(delete)
		qdel(emote_overlay)


/mob/proc/spin(spintime, speed)
	set waitfor = FALSE
	var/D = dir
	if(spintime < 1 || speed < 1 || !spintime || !speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed


/mob/proc/is_muzzled()
	return FALSE

/// Adds this list to the output to the stat browser
/mob/proc/get_status_tab_items()
	. = list("") //we want to offset unique stuff from standard stuff
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_GET_STATUS_TAB_ITEMS, src, .)
	SEND_SIGNAL(src, COMSIG_MOB_GET_STATUS_TAB_ITEMS, .)

// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective(null) set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/new_eye)
	if(!client)
		return

	if(new_eye)
		if(ismovable(new_eye))
			//Set the new eye unless it's us
			if(new_eye != src)
				client.perspective = EYE_PERSPECTIVE
				client.eye = new_eye
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else if(isturf(new_eye))
			//Set to the turf unless it's our current turf
			if(new_eye != loc)
				client.perspective = EYE_PERSPECTIVE
				client.eye = new_eye
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else
			return TRUE //no setting eye to stupid things like areas or whatever
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.eye = loc
	return TRUE

/mob/proc/update_joined_player_list(newname, oldname)
	if(newname == oldname)
		return
	if(!istext(newname) && !isnull(newname))
		stack_trace("[src] attempted to change its name from [oldname] to the non string value [newname]")
		return FALSE
	if(oldname)
		GLOB.joined_player_list -= oldname
	if(newname)
		GLOB.joined_player_list[newname] = TRUE


//This will update a mob's name, real_name, mind.name, GLOB.datacore records and id
/mob/proc/fully_replace_character_name(oldname, newname)
	if(!newname)
		return FALSE

	log_played_names(ckey, newname)

	if(GLOB.joined_player_list[oldname])
		update_joined_player_list(newname, oldname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key, newname) //Just in case the mind is unsynced at the moment.

	log_mob_tag("\[[tag]\] RENAMED: [key_name(src)]")

	return TRUE


/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/proc/sync_lighting_plane_alpha()
	if(!hud_used)
		return

	var/atom/movable/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
	if(L)
		L.alpha = lighting_alpha


/mob/proc/get_photo_description(obj/item/camera/camera)
	return "a ... thing?"


/mob/proc/can_interact_with(datum/D)
	return (D == src)

///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)


/mob/proc/update_names_joined_list(new_name, old_name)
	if(old_name)
		GLOB.real_names_joined -= old_name
	if(new_name)
		GLOB.real_names_joined[new_name] = TRUE

/// Updates the grab state of the mob and updates movespeed
/mob/setGrabState(newstate)
	. = ..()
	if(isnull(.))
		return
	if(grab_state == GRAB_PASSIVE)
		remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
	else if(. == GRAB_PASSIVE)
		add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, NONE, TRUE, BASE_GRAB_SLOWDOWN) //We cap this at 3 so we don't get utterly insane slowdowns for neck and other grabs.

/mob/set_throwing(new_throwing)
	. = ..()
	if(isnull(.))
		return
	if(throwing)
		ADD_TRAIT(src, TRAIT_IMMOBILE, THROW_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILE, THROW_TRAIT)

/mob/proc/set_stat(new_stat)
	SHOULD_CALL_PARENT(TRUE)
	if(new_stat == stat)
		return
	remove_all_indicators()
	. = stat //old stat
	stat = new_stat
	if(. == DEAD && client)
		//This would go on on_revive() but that is a mob/living proc
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
		personal_statistics.times_revived++
	SEND_SIGNAL(src, COMSIG_MOB_STAT_CHANGED, ., new_stat)

/// Cleanup proc that's called when a mob loses a client, either through client destroy or logout
/// Logout happens post client del, so we can't just copypaste this there. This keeps things clean and consistent
/mob/proc/become_uncliented()
	if(!canon_client)
		return

	for(var/foo in canon_client.player_details.post_logout_callbacks)
		var/datum/callback/CB = foo
		CB.Invoke()

	if(canon_client?.movingmob)
		LAZYREMOVE(canon_client.movingmob.client_mobs_in_contents, src)
		canon_client.movingmob = null

	clear_important_client_contents()
	canon_client = null

/mob/onTransitZ(old_z, new_z)
	. = ..()
	if(!client || !hud_used)
		return
	if(old_z == new_z)
		return
	if(is_ground_level(new_z))
		hud_used.remove_parallax(src)
		return
	hud_used.create_parallax(src)

/mob/proc/point_to_atom(atom/pointed_atom)
	var/turf/tile = get_turf(pointed_atom)
	if(!tile)
		return FALSE
	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/overlay/temp/point/big(our_tile, 0)
	visual.invisibility = invisibility
	animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y, time = 1.7, easing = EASE_OUT)
	SEND_SIGNAL(src, COMSIG_POINT_TO_ATOM, pointed_atom)
	return TRUE

/// Side effects of being sent to the end of round deathmatch zone
/mob/proc/on_eord(turf/destination)
	return

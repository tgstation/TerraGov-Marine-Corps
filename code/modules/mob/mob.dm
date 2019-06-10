
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	GLOB.offered_mob_list -= src
	ghostize()
	clear_fullscreens()
	return ..()

/mob/Initialize()
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	set_focus(src)
	prepare_huds()
	return ..()


/mob/Stat()
	. = ..()

	if(statpanel("Stats"))
		if(client)
			stat(null, "Ping: [round(client.lastping, 1)]ms (Average: [round(client.avgping, 1)]ms)")
		if(GLOB.round_id)
			stat("Round ID: [GLOB.round_id]")
		stat("Operation Time: [worldtime2text()]")
		stat("Current Map: [SSmapping.config?.map_name ? SSmapping.config.map_name : "Loading..."]")
		stat("Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")


	if(client?.holder?.rank?.rights)
		if(client.holder.rank.rights & (R_ADMIN|R_DEBUG))
			if(statpanel("MC"))
				stat("CPU:", "[world.cpu]")
				stat("Instances:", "[num2text(length(world.contents), 10)]")
				stat("World Time:", "[world.time]")
				GLOB.stat_entry()
				config.stat_entry()
				shuttle_controller?.stat_entry()
				lighting_controller.stat_entry()
				stat(null)
				if(Master)
					Master.stat_entry()
				else
					stat("Master Controller:", "ERROR")
				if(Failsafe)
					Failsafe.stat_entry()
				else
					stat("Failsafe Controller:", "ERROR")
				if(Master)
					stat(null)
					for(var/datum/controller/subsystem/SS in Master.subsystems)
						SS.stat_entry()
		if(client.holder.rank.rights & (R_ADMIN|R_MENTOR))
			if(statpanel("Tickets"))
				GLOB.ahelp_tickets.stat_entry()
		if(length(GLOB.sdql2_queries))
			if(statpanel("SDQL2"))
				stat("Access Global SDQL2 List", GLOB.sdql2_vv_statobj)
				for(var/i in GLOB.sdql2_queries)
					var/datum/SDQL2_query/Q = i
					Q.generate_stat()


	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			var/list/overrides = list()
			for(var/image/I in client.images)
				if(I.loc && I.loc.loc == listed_turf && I.override)
					overrides += I.loc
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(length(overrides) && (A in overrides))
					continue
				statpanel(listed_turf.name, null, A)


/mob/proc/prepare_huds()
	hud_list = new
	for(var/hud in hud_possible)
		hud_list[hud] = image('icons/mob/hud.dmi', src, "")


/mob/proc/show_message(msg, type, alt_msg, alt_type)
	if(!client)
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	to_chat(src, msg)


/mob/living/show_message(msg, type, alt_msg, alt_type)
	if(!client)
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type == EMOTE_VISIBLE && eye_blind) //Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type == EMOTE_AUDIBLE && isdeaf(src)) //Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type == EMOTE_VISIBLE && eye_blind)
					return

	if(stat == UNCONSCIOUS && type == EMOTE_AUDIBLE)
		to_chat(src, "<i>... You can almost hear something ...</i>")
	else
		to_chat(src, msg)

// Show a message to all player mobs who sees this atom
// Show a message to the src mob (if the src is a mob)
// Use for atoms performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// self_message (optional) is what the src mob sees e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// vision_distance (optional) define how many tiles away the message can be seen.
// ignored_mob (optional) doesn't show any message to a given mob if TRUE.

/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob)
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/range = 7
	if(vision_distance)
		range = vision_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue
		if(M == ignored_mob)
			continue

		var/msg = message

		if(M == src && self_message) //the src always see the main message or self message
			msg = self_message

		else if(M.see_invisible < invisibility || (T != loc && T != src)) //if src is invisible to us or is inside something (and isn't a turf),
			if(!blind_message) // then people see blind message if there is one, otherwise nothing.
				continue

			msg = blind_message

		M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)


// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		M.show_message(message, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


/mob/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	. += next_move_slowdown
	next_move_slowdown = 0

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		equip_to_slot_if_possible(W, slot, FALSE) // equiphere

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = FALSE, warning = FALSE, redraw_mob = TRUE)
	if(equip_to_slot_if_possible(W, SLOT_L_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	else if(equip_to_slot_if_possible(W, SLOT_R_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	return FALSE

//This is a SAFE proc. Use this instead of equip_to_splot()!
//set del_on_fail to have it delete W if it fails to equip
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, ignore_delay = TRUE, del_on_fail = FALSE, warning = TRUE, redraw_mob = TRUE, permanent = FALSE)
	if(!istype(W))
		return
	if(!W.mob_can_equip(src, slot, warning))
		if(del_on_fail)
			qdel(W)
		else if(warning)
			to_chat(src, "<span class='warning'>You are unable to equip that.</span>")
		return
	var/start_loc = W.loc
	if(W.time_to_equip && !ignore_delay)
		spawn(0)
			if(!do_after(src, W.time_to_equip, TRUE, W, BUSY_ICON_FRIENDLY))
				to_chat(src, "You stop putting on \the [W]")
			else
				equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
				if(permanent)
					W.flags_item |= NODROP
				if(W.loc == start_loc && get_active_held_item() != W)
					//They moved it from hands to an inv slot or vice versa. This will unzoom and unwield items -without- triggering lights.
					if(W.zoom)
						W.zoom(src)
					if(W.flags_item & TWOHANDED)
						W.unwield(src)
		return TRUE
	else
		equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
		if(permanent)
			W.flags_item |= NODROP
		if(W.loc == start_loc && get_active_held_item() != W)
			//They moved it from hands to an inv slot or vice versa. This will unzoom and unwield items -without- triggering lights.
			if(W.zoom)
				W.zoom(src)
			if(W.flags_item & TWOHANDED)
				W.unwield(src)
		return TRUE

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds starts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, permanent = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, FALSE, permanent)


/mob/proc/equip_to_appropriate_slot(obj/item/W, ignore_delay = TRUE)
	if(!istype(W))
		return FALSE

	for(var/slot in SLOT_EQUIP_ORDER)
		if(equip_to_slot_if_possible(W, slot, ignore_delay, FALSE, FALSE, FALSE))
			return TRUE

	return FALSE


/mob/proc/draw_from_slot_if_possible(slot)
	if(!slot)
		return FALSE

	var/obj/item/I = get_item_by_slot(slot)

	if(!I)
		return FALSE

	if(istype(I, /obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/B = I
		if(!B.current_gun)
			return FALSE
		var/obj/item/W = B.current_gun
		B.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/clothing/shoes/marine))
		var/obj/item/clothing/shoes/marine/S = I
		if(!S.knife)
			return FALSE
		put_in_hands(S.knife)
		S.knife = null
		S.update_icon()
		return TRUE
	else if(istype(I, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = I
		if(!U.hastie)
			return FALSE
		var/obj/item/clothing/tie/storage/T = U.hastie
		if(!istype(T) || !T.hold)
			return FALSE
		var/obj/item/storage/internal/S = T.hold
		if(!length(S.contents))
			return FALSE
		var/obj/item/W = S.contents[length(S.contents)]
		S.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if(!S.pockets)
			return FALSE
		var/obj/item/storage/internal/P = S.pockets
		if(!length(P.contents))
			return FALSE
		var/obj/item/W = P.contents[length(P.contents)]
		P.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		if(!length(S.contents))
			return FALSE
		var/obj/item/W = S.contents[length(S.contents)]
		S.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else
		doUnEquip(I)
		put_in_hands(I)
		return TRUE


/mob/proc/show_inv(mob/user)
	user.set_interaction(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return


/mob/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Player Panel"] = "?_src_=vars;[HrefToken()];playerpanel=[REF(src)]"


/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	getFiles(
		'html/postcardsmall.jpg',
		'html/somerights20.png',
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html',
		'html/chrome-wrench.png',
		'html/ban.png',
		'html/coding.png',
		'html/scales.png'
		)

	src << browse_rsc('html/changelog2015.html', "changelog2015.html")
	src << browse_rsc('html/changelog2016.html', "changelog2016.html")
	src << browse_rsc('html/changelog2017.html', "changelog2017.html")
	src << browse_rsc('html/changelog20181.html', "changelog20181.html")
	src << browse_rsc('html/changelog20182.html', "changelog20182.html")
	src << browse_rsc('html/changelog.html', "changelog.html")


	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "background-color=none;font-style=;")

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_interaction()
		src << browse(null, t1)

	else if(href_list["default_language"])
		var/language = text2path(href_list["default_language"])
		var/datum/language_holder/H = get_language_holder()

		if(!H.has_language(language))
			return

		H.selected_default_language = language
		if(isliving(src))
			var/mob/living/L = src
			L.language_menu()



/mob/MouseDrop(mob/M)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(!ishuman(M) && !ismonkey(M)) return
	if(!ishuman(src) && !ismonkey(src)) return
	if(M.lying || M.incapacitated())
		return
	show_inv(M)


/mob/living/start_pulling(atom/movable/AM, no_msg)
	if(QDELETED(AM) || QDELETED(usr) || src == AM || !isturf(loc) || !isturf(AM.loc) || !Adjacent(AM))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return FALSE

	if(!AM.can_be_pulled(src))
		return FALSE

	if(AM.anchored || AM.throwing)
		return FALSE

	if(throwing || incapacitated())
		return FALSE

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return FALSE

	var/mob/M
	if(ismob(AM))
		M = AM

	if(AM.pulledby && AM.pulledby.grab_level < GRAB_NECK)
		if(M)
			visible_message("<span class='warning'>[src] has broken [AM.pulledby]'s grip on [M]!</span>", null, null, 5)
		AM.pulledby.stop_pulling()

	pulling = AM
	AM.pulledby = src

	var/obj/item/grab/G = new /obj/item/grab()
	G.grabbed_thing = AM
	if(!put_in_hands(G)) //placing the grab in hand failed, grab is dropped, deleted, and we stop pulling automatically.
		return

	changeNext_move(CLICK_CD_RANGE)

	if(M)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

		flick_attack_overlay(M, "grab")

		log_combat(src, M, "grabbed")
		msg_admin_attack("[key_name(src)] grabbed [key_name(M)]" )

		if(!no_msg)
			visible_message("<span class='warning'>[src] has grabbed [M] [((ishuman(src) && ishuman(M)) && (zone_selected == "l_hand" || zone_selected == "r_hand")) ? "by their hands":"passively"]!</span>", null, null, 5)

		if(M.mob_size > MOB_SIZE_HUMAN || !(M.status_flags & CANPUSH))
			G.icon_state = "!reinforce"

	if(hud_used?.pull_icon)
		hud_used.pull_icon.icon_state = "pull"

	//Attempted fix for people flying away through space when cuffed and dragged.
	if(M)
		M.inertia_dir = 0

	return AM.pull_response(src) //returns true if the response doesn't break the pull

//how a movable atom reacts to being pulled.
//returns true if the pull isn't severed by the response
/atom/movable/proc/pull_response(mob/puller)
	return TRUE


/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		if(!M.stat)
			to_chat(src, message)


/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"


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

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	return


/mob/proc/facedir(var/ndir)
	if(!canface())
		return FALSE
	setDir(ndir)
	if(buckled && !buckled.anchored)
		buckled.setDir(ndir)
	return TRUE




/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return FALSE


/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(istype(H.species, species_datum))
			. = TRUE

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	overlay_fullscreen("pain", /obj/screen/fullscreen/pain, 1)
	clear_fullscreen("pain")

/mob/proc/get_visible_implants(var/class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	if(usr.stat)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(0)
	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		if(get_active_held_item())
			to_chat(src, "<span class='warning'>You need an empty hand for this!</span>")
			return FALSE
		to_chat(src, "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>")
	else
		if(get_active_held_item())
			to_chat(U, "<span class='warning'>You need an empty hand for this!</span>")
			return FALSE
		to_chat(U, "<span class='warning'>You attempt to get a good grip on [selection] in [S]'s body.</span>")

	if(!do_after(U, 80, TRUE, S, BUSY_ICON_GENERIC) || !istype(selection))
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>", null, 5)
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>", null, 5)
	valid_objects = get_visible_implants(0)
	if(valid_objects.len == 1) //Yanking out last object - removing verb.
		src.verbs -= /mob/proc/yank_out_object

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/datum/limb/affected

		for(var/datum/limb/E in H.limbs) //Grab the limb holding the implant.
			for(var/obj/item/O in E.implants)
				if(O == selection)
					affected = E
					break

		if(!affected) //Somehow, something fucked up. Somewhere.
			return

		affected.implants -= selection
		H.shock_stage+=20
		affected.take_damage_limb((selection.w_class * 3), 0, FALSE, TRUE)

		if(prob(selection.w_class * 5)) //I'M SO ANEMIC I COULD JUST -DIE-.
			var/datum/wound/internal_bleeding/I = new (min(selection.w_class * 5, 15))
			affected.wounds += I
			H.custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 1)

		if (ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	selection.loc = get_turf(src)
	return 1

/mob/proc/update_stat()
	return

/mob/proc/can_inject()
	return reagents

/mob/proc/canUseTopic(atom/movable/AM)
	return FALSE

/mob/proc/get_idcard(hand_first)
	return

/mob/proc/update_health_hud()
	return

/mob/proc/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/on_stored_atom_del(atom/movable/AM)
	if(istype(AM, /obj/item))
		temporarilyRemoveItemFromInventory(AM, TRUE) //unequip before deletion to clear possible item references on the mob.

/mob/forceMove(atom/destination)
	stop_pulling()
	if(pulledby)
		pulledby.stop_pulling()
	if(buckled)
		buckled.unbuckle()
	return ..()

/mob/proc/trainteleport(atom/destination)
	if(!destination || anchored)
		return FALSE //Gotta go somewhere and be able to move
	if(!pulling)
		return forceMove(destination) //No need for a special proc if there's nothing being pulled.
	pulledby?.stop_pulling() //The leader of the choo-choo train breaks the pull
	var/atom/movable/list/conga_line[0]
	var/end_of_conga = FALSE
	var/mob/S = src
	conga_line += S
	if(S.buckled)
		if(S.buckled.anchored)
			S.buckled.unbuckle() //Unbuckle the first of the line if anchored.
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
		else //Not a mob.
			var/obj/O = A
			if(istype(O) && O.buckled_mob) //But can have a mob associated.
				conga_line += O.buckled_mob
				if(O.buckled_mob.pulling) //Unlikely, but who knows? A train of wheelchairs?
					S = O.buckled_mob
					continue
			var/obj/structure/bed/B = O
			if(istype(B) && B.buckled_bodybag)
				conga_line += B.buckled_bodybag
			end_of_conga = TRUE //Only mobs can continue the cycle.
	var/area/new_area = get_area(destination)
	for(var/atom/movable/AM in conga_line)
		var/oldLoc
		if(AM.loc)
			oldLoc = AM.loc
			AM.loc.Exited(AM,destination)
		AM.loc = destination
		AM.loc.Entered(AM,oldLoc)
		var/area/old_area
		if(oldLoc)
			old_area = get_area(oldLoc)
		if(new_area && old_area != new_area)
			new_area.Entered(AM,oldLoc)
		for(var/atom/movable/CR in destination)
			if(CR in conga_line)
				continue
			CR.Crossed(AM)
		if(oldLoc)
			AM.Moved(oldLoc)
		var/mob/M = AM
		if(istype(M))
			M.reset_perspective(destination)
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
	var/viewers = viewers()
	for(var/mob/M in viewers)
		if(!isobserver(M) && (M.stat != CONSCIOUS || isdeaf(M)))
			continue
		SEND_IMAGE(M, emote_overlay)

	if(remove_delay)
		addtimer(CALLBACK(src, .proc/remove_emote_overlay, client, emote_overlay, viewers), remove_delay)


/mob/proc/remove_emote_overlay(client/C, image/emote_overlay, list/viewers)
	if(C)
		C.images -= emote_overlay
	for(var/mob/M in viewers)
		if(M.client)
			M.client.images -= emote_overlay
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


// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective() set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/A)
	if(!client)
		return

	if(A)
		if(ismovableatom(A))
			//Set the the thing unless it's us
			if(A != src)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else if(isturf(A))
			//Set to the turf unless it's our current turf
			if(A != loc)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.eye = loc

	return TRUE


/mob/Moved(atom/oldloc, direction)
	if(client && (client.view != world.view || client.pixel_x || client.pixel_y))
		for(var/obj/item/item in contents)
			if(item.zoom)
				item.zoom(src)
				click_intercept = null
				break
	return ..()


//This will update a mob's name, real_name, mind.name, GLOB.datacore records and id
/mob/proc/fully_replace_character_name(oldname, newname)
	if(!newname)	
		return FALSE

	log_played_names(ckey, newname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key, newname) //Just in case the mind is unsynced at the moment.

	return TRUE


/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()


/mob/proc/sync_lighting_plane_alpha()
	return

/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	ghostize()
	clear_fullscreens()
	. = ..()
	return TA_PURGE_ME_NOW

/mob/Initialize()
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	prepare_huds()
	return ..()


/mob/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat("Operation Time: [worldtime2text()]")
		stat("The current map is: [GLOB.map_tag]")


	if(client?.holder?.rank?.rights)
		if(client.holder.rank.rights & (R_ADMIN|R_DEBUG))
			if(statpanel("MC"))
				stat("CPU:", "[world.cpu]")
				stat("Instances:", "[num2text(length(world.contents), 10)]")
				stat("World Time:", "[world.time]")
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


	if(length(tile_contents))
		if(statpanel("Tile Contents"))
			stat(tile_contents)


/mob/proc/prepare_huds()
	hud_list = new
	for(var/hud in hud_possible)
		hud_list[hud] = image('icons/mob/hud.dmi', src, "")

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)	return

	if (type)
		if(type & 1 && (sdisabilities & BLIND || is_blind()) )//Vision related
			if (!alt)
				return
			else
				msg = alt
				type = alt_type
		if (type & 2 && (sdisabilities & DEAF || isdeaf()))//Hearing related
			if (!alt)
				return
			else
				msg = alt
				type = alt_type
				if (type & 1 && (sdisabilities & BLIND))
					return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='emote'>... You can almost hear someone talking ...</span>")
	else
		to_chat(src, msg)


// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(message, self_message, blind_message, max_distance)
	var/view_dist = 7
	if(max_distance) view_dist = max_distance
	for(var/mob/M in viewers(view_dist, src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message, max_distance)
	var/view_dist = 7
	if(max_distance) view_dist = max_distance
	for(var/mob/M in viewers(view_dist, src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	. += next_move_slowdown
	next_move_slowdown = 0

/mob/proc/Life()
	if(client == null)
		away_timer++
	else
		away_timer = 0
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		equip_to_slot_if_possible(W, slot, 0) // equiphere

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, SLOT_L_HAND, 1, del_on_fail, disable_warning, redraw_mob))
		return 1
	else if(equip_to_slot_if_possible(W, SLOT_R_HAND, 1, del_on_fail, disable_warning, redraw_mob))
		return 1
	return 0

//This is a SAFE proc. Use this instead of equip_to_splot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, ignore_delay = TRUE, del_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, permanent = FALSE)
	if(!istype(W))
		return

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			qdel(W)
		else if(!disable_warning)
			to_chat(src, "<span class='warning'>You are unable to equip that.</span>")
		return
	var/start_loc = W.loc
	if(W.time_to_equip && !ignore_delay)
		spawn(0)
			if(!do_after(src, W.time_to_equip, TRUE, 5, BUSY_ICON_GENERIC))
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

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, permanent = 0)
	return equip_to_slot_if_possible(W, slot, 1, 1, 1, 0, permanent)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		SLOT_IN_HOLSTER,\
		SLOT_IN_S_HOLSTER,\
		SLOT_IN_B_HOLSTER,\
		SLOT_BACK,\
		SLOT_WEAR_ID,\
		SLOT_W_UNIFORM,\
		SLOT_ACCESSORY,\
		SLOT_WEAR_SUIT,\
		SLOT_WEAR_MASK,\
		SLOT_HEAD,\
		SLOT_SHOES,\
		SLOT_GLOVES,\
		SLOT_EARS,\
		SLOT_GLASSES,\
		SLOT_BELT,\
		SLOT_S_STORE,\
		SLOT_L_STORE,\
		SLOT_R_STORE,\
		SLOT_IN_BOOT,\
		SLOT_IN_STORAGE,\
		SLOT_IN_L_POUCH,\
		SLOT_IN_R_POUCH\
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W, ignore_delay = TRUE)
	if(!istype(W))
		return FALSE

	for(var/slot in slot_equipment_priority)
		if(equip_to_slot_if_possible(W, slot, ignore_delay, 0, 1, 1)) //del_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return TRUE

	return FALSE

/mob/proc/reset_view(atom/A)
	if (client)
		if (ismovableatom(A))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return


/mob/proc/show_inv(mob/user)
	user.set_interaction(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_BACK]'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return



/mob/proc/point_to_atom(atom/A, turf/T)
	//Squad Leaders and above have reduced cooldown and get a bigger arrow
	if(!mind || !mind.cm_skills || mind.cm_skills.leadership < SKILL_LEAD_TRAINED)
		recently_pointed_to = world.time + 50
		new /obj/effect/overlay/temp/point(T)

	else
		recently_pointed_to = world.time + 10
		new /obj/effect/overlay/temp/point/big(T)
	visible_message("<b>[src]</b> points to [A]", null, null, 5)
	return 1


/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>")

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = oldreplacetext(flavor_text, "\n", " ")
		if(lentext(msg) <= 40)
			return "<span class='notice'> [msg]</span>"
		else
			return "<span class='notice'> [copytext(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></span>"



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
		winset(src, "rpane.changelog", "background-color=none;font-style=;")

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_interaction()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, oldreplacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()
//	..()
	return


/mob/MouseDrop(mob/M)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(!ishuman(M) && !ismonkey(M)) return
	if(!ishuman(src) && !ismonkey(src)) return
	if(M.lying || M.is_mob_incapacitated())
		return
	show_inv(M)


//attempt to pull/grab something. Returns true upon success.
/mob/proc/start_pulling(atom/movable/AM, lunge, no_msg)
	return

/mob/living/start_pulling(atom/movable/AM, lunge, no_msg)
	if ( !AM || !usr || src==AM || !isturf(loc) || !isturf(AM.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if (AM.anchored || AM.throwing)
		return

	if(throwing || is_mob_incapacitated())
		return

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	var/mob/M
	if(ismob(AM))
		M = AM

	else if(istype(AM, /obj))
		AM.add_fingerprint(src)

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

	if(M)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

		flick_attack_overlay(M, "grab")

		log_combat(src, M, "grabbed")
		msg_admin_attack("[key_name(src)] grabbed [key_name(M)]" )

		if(!no_msg)
			visible_message("<span class='warning'>[src] has grabbed [M] [((ishuman(src) && ishuman(M)) && (zone_selected == "l_hand" || zone_selected == "r_hand")) ? "by their hands":"passively"]!</span>", null, null, 5)

		if(M.mob_size > MOB_SIZE_HUMAN || !(M.status_flags & CANPUSH))
			G.icon_state = "!reinforce"

	if(hud_used && hud_used.pull_icon) hud_used.pull_icon.icon_state = "pull1"

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

//handles up-down floaty effect in space
/mob/proc/make_floating(var/n)

	floatiness = n

	if(floatiness && !is_floating)
		start_floating()
	else if(!floatiness && is_floating)
		stop_floating()

/mob/proc/start_floating()

	is_floating = 1

	var/amplitude = 2 //maximum displacement from original position
	var/period = 36 //time taken for the mob to go up >> down >> original position, in deciseconds. Should be multiple of 4

	var/top = old_y + amplitude
	var/bottom = old_y - amplitude
	var/half_period = period / 2
	var/quarter_period = period / 4

	animate(src, pixel_y = top, time = quarter_period, easing = SINE_EASING|EASE_OUT, loop = -1)		//up
	animate(pixel_y = bottom, time = half_period, easing = SINE_EASING, loop = -1)						//down
	animate(pixel_y = old_y, time = quarter_period, easing = SINE_EASING|EASE_IN, loop = -1)			//back

/mob/proc/stop_floating()
	animate(src, pixel_y = old_y, time = 5, easing = SINE_EASING|EASE_IN) //halt animation
	//reset the pixel offsets to zero
	is_floating = 0

// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(stat==2)						return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(is_mob_restrained())					return 0
	return 1

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()

	var/laid_down = (stat || knocked_down || knocked_out || !has_legs() || resting || (status_flags & FAKEDEATH) || (pulledby && pulledby.grab_level >= GRAB_NECK))

	if(laid_down)
		if(!lying)
			lying = pick(90, 270)
	else
		lying = 0
	if(buckled)
		if(buckled.buckle_lying)
			if(!lying)
				lying = 90
		else
			lying = 0

	canmove =  !(stunned || frozen || laid_down)

	if(lying)
		density = FALSE
		drop_l_hand()
		drop_r_hand()
	else
		density = TRUE

	if(lying_prev != lying)
		update_transform()
		lying_prev = lying

	if(lying)
		if(layer == initial(layer)) //to avoid things like hiding larvas.
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)

	return canmove


/mob/proc/facedir(var/ndir)
	if(!canface())	return 0
	dir = ndir
	if(buckled && !buckled.anchored)
		buckled.dir = ndir
		buckled.handle_rotation()
	return 1




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

	if(usr.is_mob_restrained())
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

	if(!do_after(U, 80, TRUE, 5, BUSY_ICON_FRIENDLY))
		return
	if(!selection || !S || !U || !istype(selection))
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
		if(!isyautja(H))
			H.shock_stage+=20
		affected.take_damage((selection.w_class * 3), 0, 0, 1, "Embedded object extraction")

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

/mob/proc/get_idcard(hand_first)
	return

/mob/proc/update_health_hud()
	return

/mob/proc/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/proc/TurfAdjacent(var/turf/T)
	return T.AdjacentQuick(src)

/mob/on_stored_atom_del(atom/movable/AM)
	if(istype(AM, /obj/item))
		temporarilyRemoveItemFromInventory(AM, TRUE) //unequip before deletion to clear possible item references on the mob.

/mob/forceMove(atom/destination)
	stop_pulling()
	if(pulledby)
		pulledby.stop_pulling()
	if(buckled)
		buckled.unbuckle()
	. = ..()
	if(.)
		reset_view(destination)

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
			M.reset_view(destination)
	return TRUE

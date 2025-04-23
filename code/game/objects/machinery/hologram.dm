#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2

#define CAN_HEAR_MASTERS (1<<0)
#define CAN_HEAR_ACTIVE_HOLOCALLS (1<<1)
#define CAN_HEAR_RECORD_MODE (1<<2)
#define CAN_HEAR_ALL_FLAGS (CAN_HEAR_MASTERS|CAN_HEAR_ACTIVE_HOLOCALLS|CAN_HEAR_RECORD_MODE)

/obj/machinery/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	layer = MAP_SWITCH(ABOVE_OPEN_TURF_LAYER, LOW_OBJ_LAYER)
	plane = MAP_SWITCH(FLOOR_PLANE, GAME_PLANE)
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	max_integrity = 300

	/// associative lazylist of the form: list(mob calling us = hologram representing that mob).
	/// this is only populated for holopads answering calls from another holopad
	var/list/masters
	/// Holoray-mob link
	var/list/holorays
	/// To prevent request spam. ~Carn
	var/last_request = 0
	/// Change to change how far the AI can move away from the holopad before deactivating
	var/holo_range = 5
	var/temp = ""
	/// Array of /datum/holocalls that are calling US. this is only filled for holopads answering calls from another holopad
	var/list/holo_calls
	/// Currently outgoing holocall, cannot call any other holopads unless this is null.
	/// creating a new holocall from us to another holopad sets this var to that holocall datum
	var/datum/holocall/outgoing_call
	/// Replay hologram
	var/obj/effect/overlay/holo_pad_hologram/replay_holo
	/// Calls will be automatically answered after a couple rings, here for debugging
	var/static/force_answer_call = FALSE
	var/static/list/holopads = list()
	var/obj/effect/overlay/holoray/ray
	var/ringing = FALSE
	var/offset = FALSE
	var/on_network = TRUE
	///bitfield. used to turn on and off hearing sensitivity depending on if we can act on Hear() at all - meant for lowering the number of unessesary hearable atoms
	var/can_hear_flags = NONE


/obj/machinery/holopad/Initialize(mapload)
	. = ..()
	if(on_network)
		holopads += src

/obj/machinery/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/datum/holocall/holocall_to_disconnect AS in holo_calls)
		holocall_to_disconnect.ConnectionFailure(src)

	for (var/I in masters)
		clear_holo(I)

	holopads -= src
	return ..()

/obj/machinery/holopad/power_change()
	if(powered())
		machine_stat &= ~NOPOWER
	else
		machine_stat |= NOPOWER
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)


/obj/machinery/holopad/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Current projection range: <b>[holo_range]</b> units.")


/obj/machinery/holopad/interact(mob/user)
	. = ..()
	if(.)
		return

	if(outgoing_call)
		return

	var/dat
	if(temp)
		dat = temp
	else
		if(on_network)
			dat += "<a href='byond://?src=[REF(src)];AIrequest=1'>Request an AI's presence</a><br>"
			dat += "<a href='byond://?src=[REF(src)];Holocall=1'>Call another holopad</a><br>"

		if(LAZYLEN(holo_calls))
			dat += "=====================================================<br>"

		if(on_network)
			var/one_answered_call = FALSE
			var/one_unanswered_call = FALSE
			for(var/datum/holocall/HC AS in holo_calls)
				if(HC.connected_holopad != src)
					dat += "<a href='byond://?src=[REF(src)];connectcall=[REF(HC)]'>Answer call from [get_area(HC.calling_holopad)]</a><br>"
					one_unanswered_call = TRUE
				else
					one_answered_call = TRUE

			if(one_answered_call && one_unanswered_call)
				dat += "=====================================================<br>"
			//we loop twice for formatting
			for(var/datum/holocall/HC AS in holo_calls)
				if(HC.connected_holopad == src)
					dat += "<a href='byond://?src=[REF(src)];disconnectcall=[REF(HC)]'>Disconnect call from [HC.user]</a><br>"


	var/datum/browser/popup = new(user, "holopad", name, 300, 175)
	popup.set_content(dat)
	popup.open()

//setters
/**
 * setter for can_hear_flags. handles adding or removing the given flag on can_hear_flags and then adding hearing sensitivity or removing it depending on the final state
 * this is necessary because holopads are a significant fraction of the hearable atoms on station which increases the cost of procs that iterate through hearables
 * so we need holopads to not be hearable until it is needed
 *
 * * flag - one of the can_hear_flags flag defines
 * * set_flag - boolean, if TRUE sets can_hear_flags to that flag and might add hearing sensitivity if can_hear_flags was NONE before,
 * if FALSE unsets the flag and possibly removes hearing sensitivity
 */
/obj/machinery/holopad/proc/set_can_hear_flags(flag, set_flag = TRUE)
	if(!(flag & CAN_HEAR_ALL_FLAGS))
		return FALSE //the given flag doesnt exist

	if(set_flag)
		if(can_hear_flags == NONE)//we couldnt hear before, so become hearing sensitive
			become_hearing_sensitive()

		can_hear_flags |= flag
		return TRUE

	else
		can_hear_flags &= ~flag
		if(can_hear_flags == NONE)
			lose_hearing_sensitivity()

		return TRUE

///setter for adding/removing holocalls to this holopad. used to update the holo_calls list and can_hear_flags
///adds the given holocall if add_holocall is TRUE, removes if FALSE
/obj/machinery/holopad/proc/set_holocall(datum/holocall/holocall_to_update, add_holocall = TRUE)
	if(!istype(holocall_to_update))
		return FALSE

	if(add_holocall)
		set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS)
		LAZYADD(holo_calls, holocall_to_update)

	else
		LAZYREMOVE(holo_calls, holocall_to_update)
		if(!LAZYLEN(holo_calls))
			set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS, FALSE)

	return TRUE

///Disconnects all current holocalls from the holopad
/obj/machinery/holopad/proc/hangup_all_calls()
	for(var/datum/holocall/holocall_to_disconnect AS in holo_calls)
		holocall_to_disconnect.Disconnect(src)

/obj/machinery/holopad/Topic(href, href_list)
	. = ..()
	if(. || isAI(usr))
		return

	if(!is_operational())
		return

	if(href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<BR>"
			temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
				if(!AI.client)
					continue
				to_chat(AI, span_info("Your presence is requested at <a href='byond://?src=[REF(AI)];jumptoholopad=[REF(src)]'>\the [area]</a>."))
				playsound(AI, 'sound/machines/two_tones_beep.ogg', 30, 1)
				SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HOLOPAD_AI_CALLED, src)
		else
			temp = "A request for AI presence was already sent recently.<BR>"
			temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return

		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)

			var/result = tgui_input_list(usr, "Choose an area to call", "Holocall", callnames)
			if(QDELETED(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
				new /datum/holocall(usr, src, callnames[result])

	else if(href_list["connectcall"])
		var/datum/holocall/call_to_connect = locate(href_list["connectcall"]) in holo_calls
		if(!QDELETED(call_to_connect))
			call_to_connect.Answer(src)
		temp = ""

	else if(href_list["disconnectcall"])
		var/datum/holocall/call_to_disconnect = locate(href_list["disconnectcall"]) in holo_calls
		if(!QDELETED(call_to_disconnect))
			call_to_disconnect.Disconnect(src)
		temp = ""

	else if(href_list["mainmenu"])
		temp = ""
		if(outgoing_call)
			outgoing_call.Disconnect()

	else if(href_list["offset"])
		offset++
		if (offset > 4)
			offset = FALSE
		var/turf/new_turf
		if (!offset)
			new_turf = get_turf(src)
		else
			new_turf = get_step(src, GLOB.cardinals[offset])
		replay_holo.forceMove(new_turf)

	updateUsrDialog()

/obj/machinery/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!on_network)
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!LAZYLEN(masters) || !masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)

//this really should not be processing by default with how common holopads are
//everything in here can start processing if need be once first set and stop processing after being unset
/obj/machinery/holopad/process()
	if(LAZYLEN(masters))
		for(var/I in masters)
			var/mob/living/master = I
			var/mob/living/silicon/ai/AI = master
			if(!istype(AI))
				AI = null

			if(!is_operational() || !validate_user(master))
				clear_holo(master)

	if(outgoing_call)
		outgoing_call.Check()

	ringing = FALSE

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad != src)
			if(force_answer_call && world.time > (HC.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2)))
				HC.Answer(src)
				break
			if(outgoing_call)
				HC.Disconnect(src)//can't answer calls while calling
			else
				playsound(src, 'sound/machines/twobeep.ogg', 100)	//bring, bring!
				ringing = TRUE

	update_icon()

/obj/machinery/holopad/proc/activate_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		AI = null

	if(is_operational() && (!AI || AI.eyeobj.loc == loc))//If the projector has power and client eye is on it
		if (AI && istype(AI.current, /obj/machinery/holopad))
			to_chat(user, "[span_danger("ERROR:")] \black Image feed in progress.")
			return

		var/obj/effect/overlay/holo_pad_hologram/Hologram = new(loc)//Spawn a blank effect at the location.
		if(AI)
			Hologram.icon = AI.holo_icon
		else	//make it like real life
			Hologram.icon = user.icon
			Hologram.icon_state = user.icon_state
			Hologram.copy_overlays(user, TRUE)
			//codersprite some holo effects here
			Hologram.alpha = 100
			Hologram.add_atom_colour("#77abff", FIXED_COLOR_PRIORITY)
			Hologram.Impersonation = user

		Hologram.copy_known_languages_from(user,replace = TRUE)
		Hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
		Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		Hologram.anchored = TRUE
		Hologram.name = "[user.name] (Hologram)"//If someone decides to right click.
		Hologram.set_light(1, 2)	//hologram lighting
		move_hologram()

		set_holo(user, Hologram)
		visible_message(span_notice("A holographic image of [user] flickers to life before your eyes!"))

		return Hologram
	else
		to_chat(user, "[span_danger("ERROR:")] Unable to project hologram.")

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/holopad/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	for(var/datum/holocall/holocall_to_update AS in holo_calls)
		if(holocall_to_update.connected_holopad == src && speaker != holocall_to_update.hologram)
			holocall_to_update.user.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

	if(outgoing_call && speaker == outgoing_call.user)
		outgoing_call.hologram?.say(raw_message)


/obj/machinery/holopad/proc/SetLightsAndPower()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	use_power = total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE
	active_power_usage = HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users)
	if(total_users)
		set_light(1, 2)
	else
		set_light(0)
	update_icon()

/obj/machinery/holopad/update_icon_state()
	. = ..()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(ringing)
		icon_state = "holopad_ringing"
	else if(total_users)
		icon_state = "holopad1"
	else
		icon_state = "holopad0"

/obj/machinery/holopad/proc/set_holo(mob/living/user, obj/effect/overlay/holo_pad_hologram/h)
	LAZYSET(masters, user, h)
	LAZYSET(holorays, user, new /obj/effect/overlay/holoray(loc))
	set_can_hear_flags(CAN_HEAR_MASTERS)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI))
		AI.current = src
	SetLightsAndPower()
	update_holoray(user, get_turf(loc))
	return TRUE

/obj/machinery/holopad/proc/clear_holo(mob/living/user)
	qdel(masters[user]) // Get rid of user's hologram
	unset_holo(user)
	return TRUE

/obj/machinery/holopad/proc/unset_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI) && AI.current == src)
		AI.current = null
	LAZYREMOVE(masters, user) // Discard AI from the list of those who use holopad
	if(!LAZYLEN(masters))
		set_can_hear_flags(CAN_HEAR_MASTERS, set_flag = FALSE)
	qdel(holorays[user])
	LAZYREMOVE(holorays, user)
	SetLightsAndPower()
	return TRUE

//Try to transfer hologram to another pad that can project on T
/obj/machinery/holopad/proc/transfer_to_nearby_pad(turf/T,mob/holo_owner)
	var/obj/effect/overlay/holo_pad_hologram/h = masters[holo_owner]
	if(!h || h.HC) //Holocalls can't change source.
		return FALSE
	for(var/pad in holopads)
		var/obj/machinery/holopad/another = pad
		if(another == src)
			continue
		if(another.validate_location(T))
			unset_holo(holo_owner)
			if(another.masters && another.masters[holo_owner])
				another.clear_holo(holo_owner)
			another.set_holo(holo_owner, h)
			return TRUE
	return FALSE

/obj/machinery/holopad/proc/validate_user(mob/living/user)
	if(QDELETED(user) || user.incapacitated() || !user.client)
		return FALSE
	return TRUE

//Can we display holos there
//Area check instead of line of sight check because this is a called a lot if AI wants to move around.
/obj/machinery/holopad/proc/validate_location(turf/T,check_los = FALSE)
	if(T.z == z && get_dist(T, src) <= holo_range && T.loc == get_area(src))
		return TRUE
	else
		return FALSE

/obj/machinery/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(LAZYLEN(masters) && masters[user])
		var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
		var/transfered = FALSE
		if(!validate_location(new_turf))
			if(!transfer_to_nearby_pad(new_turf,user))
				clear_holo(user)
				return FALSE
			else
				transfered = TRUE
		//All is good.
		holo.abstract_move(new_turf)
		if(!transfered)
			update_holoray(user,new_turf)
	return TRUE


/obj/machinery/holopad/proc/update_holoray(mob/living/user, turf/new_turf)
	var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
	var/obj/effect/overlay/holoray/ray = holorays[user]
	var/disty = holo.y - ray.y
	var/distx = holo.x - ray.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M = matrix()
	if (get_dist(get_turf(holo),new_turf) <= 1)
		animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
	else
		ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)


/obj/effect/overlay/holo_pad_hologram
	var/mob/living/Impersonation
	var/datum/holocall/HC


/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(!QDELETED(HC))
		HC.Disconnect(HC.calling_holopad)
	return ..()


/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()


/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32
	alpha = 100


#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
#undef CAN_HEAR_MASTERS
#undef CAN_HEAR_ACTIVE_HOLOCALLS
#undef CAN_HEAR_RECORD_MODE
#undef CAN_HEAR_ALL_FLAGS

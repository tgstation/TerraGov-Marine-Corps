#define HOLOPAD_MAX_DIAL_TIME 200

/obj/machinery/holopad/remove_eye_control(mob/living/user)
	if(user.client)
		user.reset_perspective(null)
	user.remote_control = null


/datum/holocall
	///the one that called
	var/mob/living/user
	///the holopad that sent the call to another holopad
	var/obj/machinery/holopad/calling_holopad
	///the one that answered the call (may be null)
	var/obj/machinery/holopad/connected_holopad
	///populated with all holopads that are either being dialed or have that have answered us, will be cleared out to just connected_holopad once answered
	var/list/dialed_holopads

	///user's eye, once connected
	var/mob/camera/aiEye/remote/holo/eye
	///user's hologram, once connected
	var/obj/effect/overlay/holo_pad_hologram/hologram
	///hangup action
	var/datum/action/innate/end_holocall/hangup

	var/call_start_time

//creates a holocall made by `new_user` from `calling_pad` to `callees`
/datum/holocall/New(mob/living/new_user, obj/machinery/holopad/calling_pad, list/callees)
	call_start_time = world.time
	user = new_user
	calling_pad.outgoing_call = src
	calling_holopad = calling_pad
	dialed_holopads = list()

	for(var/obj/machinery/holopad/connected_holopad AS in callees)
		if(!QDELETED(connected_holopad) && connected_holopad.is_operational())
			dialed_holopads += connected_holopad
			connected_holopad.say("Incoming call.")
			connected_holopad.set_holocall(src)

	if(!length(dialed_holopads))
		calling_pad.say("Connection failure.")
		qdel(src)
		return


/datum/holocall/Destroy()
	QDEL_NULL(hangup)

	if(!QDELETED(eye))
		QDEL_NULL(eye)

	if(connected_holopad && !QDELETED(hologram))
		hologram = null
		connected_holopad.clear_holo(user)

	user = null

	//Hologram survived holopad destro
	if(!QDELETED(hologram))
		hologram.HC = null
		QDEL_NULL(hologram)

	for(var/obj/machinery/holopad/dialed_holopad AS in dialed_holopads)
		dialed_holopad.set_holocall(src, FALSE)
	dialed_holopads.Cut()

	if(calling_holopad) //if the call is answered, then calling_holopad wont be in dialed_holopads and thus wont have set_holocall(src, FALSE) called
		calling_holopad.outgoing_call = null
		calling_holopad.SetLightsAndPower()
		calling_holopad = null
	if(connected_holopad)
		connected_holopad.SetLightsAndPower()
		connected_holopad = null

	return ..()


//Gracefully disconnects a holopad `H` from a call. Pads not in the call are ignored. Notifies participants of the disconnection
/datum/holocall/proc/Disconnect(obj/machinery/holopad/H)
	if(H == connected_holopad)
		var/area/A = get_area(connected_holopad)
		calling_holopad.say("[A] holopad disconnected.")
	else if(H == calling_holopad && connected_holopad)
		connected_holopad.say("[user] disconnected.")

	ConnectionFailure(H, TRUE)


//Forcefully disconnects disconnected_holopad from a call. Pads not in the call are ignored.
/datum/holocall/proc/ConnectionFailure(obj/machinery/holopad/disconnected_holopad, graceful = FALSE)
	if(disconnected_holopad == connected_holopad || disconnected_holopad == calling_holopad)
		if(!graceful && disconnected_holopad != calling_holopad)
			calling_holopad.say("Connection failure.")
		qdel(src)
		return

	disconnected_holopad.set_holocall(src, FALSE)

	dialed_holopads -= disconnected_holopad
	if(!length(dialed_holopads))
		if(graceful)
			calling_holopad.say("Call rejected.")
		qdel(src)


///Answers a call made to answering_holopad which cannot be the calling holopad. Pads not in the call are ignored
/datum/holocall/proc/Answer(obj/machinery/holopad/answering_holopad)
	if(answering_holopad == calling_holopad)
		CRASH("A holopad tried to answer itself.")

	if(!(answering_holopad in dialed_holopads))
		return

	if(connected_holopad)
		CRASH("Multi-connection holocall")

	for(var/I in dialed_holopads)
		if(I == answering_holopad)
			continue
		Disconnect(I)

	for(var/I in answering_holopad.holo_calls)
		var/datum/holocall/HC = I
		if(HC != src)
			HC.Disconnect(answering_holopad)

	connected_holopad = answering_holopad

	if(!Check())
		return

	hologram = answering_holopad.activate_holo(user)
	hologram.HC = src

	//eyeobj code is horrid, this is the best copypasta I could make
	eye = new
	eye.origin = answering_holopad
	eye.eye_initialized = TRUE
	eye.eye_user = user
	eye.name = "Camera Eye ([user.name])"
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(answering_holopad.loc)

	hangup = new(eye, src)
	hangup.give_action(user)
	playsound(answering_holopad, 'sound/machines/ping.ogg', 100)
	answering_holopad.say("Connection established.")


//Checks the validity of a holocall and qdels itself if it's not. Returns TRUE if valid, FALSE otherwise
/datum/holocall/proc/Check()
	for(var/obj/machinery/holopad/dialed_holopad AS in dialed_holopads)
		if(!dialed_holopad.is_operational())
			ConnectionFailure(dialed_holopad)

	if(QDELETED(src))
		return FALSE

	. = !QDELETED(user) && !user.incapacitated() && !QDELETED(calling_holopad) && calling_holopad.is_operational() && user.loc == calling_holopad.loc

	if(.)
		if(!connected_holopad)
			. = world.time < (call_start_time + HOLOPAD_MAX_DIAL_TIME)
			if(!.)
				calling_holopad.say("No answer received.")
				calling_holopad.temp = ""

	if(!.)
		qdel(src)


/datum/action/innate/end_holocall
	name = "End Holocall"
	var/datum/holocall/hcall


/datum/action/innate/end_holocall/New(Target, datum/holocall/HC)
	. = ..()
	hcall = HC


/datum/action/innate/end_holocall/action_activate()
	hcall.Disconnect(hcall.calling_holopad)


//RECORDS
/datum/holorecord
	var/caller_name = "Unknown" //Caller name
	var/image/caller_image
	var/list/entries = list()
	var/language = /datum/language/common //Initial language, can be changed by HOLORECORD_LANGUAGE entries


/datum/holorecord/proc/set_caller_image(mob/user)
	var/olddir = user.dir
	user.setDir(SOUTH)
	caller_image = image(user)
	user.setDir(olddir)


/mob/camera/aiEye/remote/holo/setLoc()
	. = ..()
	var/obj/machinery/holopad/H = origin
	H?.move_hologram(eye_user, loc)

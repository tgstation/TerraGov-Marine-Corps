/obj/machinery/bot
	name = "generic utility robot"
	desc = "a generic utility robot, you shouldn't be seeing this in game. If you do ahelp."
	icon = 'icons/obj/aibots.dmi'
	density = FALSE
	anchored = FALSE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	///Keeps track of how many items or whatever have been cleaned
	var/counter = 0
	///So It doesnt infinitely look for an exit and crash the server
	var/stuck_counter = 0
	///strings used on doing an action like cleaning
	var/list/sentences = list()
	///strings used on activating the bot
	var/list/awakeningsentences = list()
	///strings used on shutting down the robot
	var/list/shutdownsentences = list()
	///is the robot active
	var/is_active = FALSE
	///can the robot be turned on or off
	var/alter_operating_mode = FALSE
	///animation to play when the robot is started by hand
	var/activation_animation = null
	///animation to play when the robot is started by hand
	var/deactivation_animation = null
	///icon to set while active
	var/active_icon_state = null


/obj/machinery/bot/Initialize(mapload)
	. = ..()
	if(SStts.tts_enabled)
		var/static/todays_voice
		if(!todays_voice)
			todays_voice = pick(SStts.available_speakers)
		voice = todays_voice
	RegisterSignal(src, COMSIG_AREA_EXITED, PROC_REF(turn_around))
	if(is_active)
		icon_state = active_icon_state
		start_processing()

/obj/machinery/bot/Destroy()
	stop_processing()
	return ..()

///Turns the bot around when it leaves an area to make sure it doesnt wander off
/obj/machinery/bot/proc/turn_around(datum/target)
	SIGNAL_HANDLER
	visible_message(span_warning("The [src] beeps angrily as it is moved out of it's designated area!"))
	step_to(src, get_step(src,REVERSE_DIR(dir)))

/obj/machinery/bot/process()
	var/list/dirs = CARDINAL_DIRS - REVERSE_DIR(dir)
	var/turf/selection
	var/newdir
	for(var/i=1 to length(dirs))
		newdir = pick_n_take(dirs)
		selection = get_step(src, newdir)
		if(!selection.density)
			break
		newdir = null
	if(!newdir)
		say("DOOR STUCK, DOOOOR STUCK, AAAAAAH!")
		return
	step_to(src, get_step(src,newdir))

/obj/machinery/bot/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "A panel on the top says it has cleaned [counter] items!"

/obj/machinery/bot/proc/reactivate()
	stuck_counter = 0
	if(!is_active) //no reactivation if somebody shut us off
		return
	start_processing()

/obj/machinery/bot/Bump(atom/A)
	. = ..()
	if(++stuck_counter <= 3)
		step_to(src, get_step(src, turn(dir, pick(90, -90))))
		return
	visible_message(span_warning("The [src] beeps angrily as it get stuck!"))
	stop_processing()
	addtimer(CALLBACK(src, PROC_REF(reactivate)), 20 SECONDS)

/obj/machinery/bot/attack_hand(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!alter_operating_mode)
		to_chat(user, "This robot doesn't have a switch.")
		return
	if(user.a_intent != INTENT_HELP)
		return
	switch(tgui_alert(user, "Do you you want to turn the [src] [is_active ? "off" : "on"]?" , "Cleanbot activation", list("No", "Yes")))
		if("Yes")
			if(is_active)
				if(length(shutdownsentences))
					say(pick(shutdownsentences))
				is_active = FALSE
				stop_processing()
			else
				if(length(awakeningsentences))
					say(pick(awakeningsentences))
				is_active = TRUE
				start_processing()

/obj/machinery/bot/attack_ai(mob/user)
	if(!alter_operating_mode)
		to_chat(user, "This robot has a firewall and cannot be remotely accessed.")
		return
	if(is_active)
		balloon_alert_to_viewers("Powers off")
		is_active = FALSE
		if(deactivation_animation)
			flick("[deactivation_animation]", src)
		if(length(shutdownsentences))
			say(pick(shutdownsentences))
		icon_state = "[initial(icon_state)]"
		stop_processing()
	else
		balloon_alert_to_viewers("Powers on")
		is_active = TRUE
		if(activation_animation)
			flick("[activation_animation]", src)
		if(length(awakeningsentences))
			say(pick(awakeningsentences))
		say(pick(awakeningsentences))
		icon_state = active_icon_state
		start_processing()

//these bots are mostly for decoration, you can't turn them on by default
/obj/machinery/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	density = FALSE
	anchored = FALSE

/obj/machinery/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	density = TRUE
	anchored = TRUE

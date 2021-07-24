/obj/vehicle/unmanned/droid
	name = "XN-43-H combat droid"
	desc = "A prototype combat droid, first deployed as a prototype to fight the xeno menace in the frontier sytems."
	icon_state = "droidcombat"
	move_delay = 2.4
	max_integrity = 300
	anchored = TRUE // no wheels
	turret_pattern = PATTERN_DROID
	gunnoise = 'sound/weapons/guns/fire/laser.ogg'


/obj/vehicle/unmanned/droid/process() //play beepy noise every 5 seconds for effect while active
	if(prob(40))
		return
	var/soundfile = "sound/runtime/drone/drone[rand(1,12)].ogg"
	soundfile = file(soundfile)
	if(!fexists(soundfile))
		return
	playsound(src, soundfile, 50)

/obj/vehicle/unmanned/droid/on_link(obj/item/unmanned_vehicle_remote/remote)
	RegisterSignal(src, COMSIG_REMOTECONTROL_CHANGED, .proc/on_remote_toggle)

/obj/vehicle/unmanned/droid/on_unlink(obj/item/unmanned_vehicle_remote/remote)
	UnregisterSignal(src, COMSIG_REMOTECONTROL_CHANGED)

///Called when remote control is taken, plays a neat sound effect aong other things
/obj/vehicle/unmanned/droid/proc/on_remote_toggle(datum/source, is_on, mob/user)
	SIGNAL_HANDLER
	if(is_on)
		playsound(src, 'sound/machines/drone/weapons_engaged.ogg', 70)
		START_PROCESSING(SSslowprocess, src)
		user.overlay_fullscreen("machine", /obj/screen/fullscreen/machine)
	else
		playsound(src, 'sound/machines/drone/droneoff.ogg', 70)
		STOP_PROCESSING(SSslowprocess, src)
		user.clear_fullscreen("machine", 5)


///stealth droid, like the normal droid but with stealthing ability on rclick
/obj/vehicle/unmanned/droid/scout
	name = "XN-43-S combat droid"
	desc = "A prototype scout droid, rigged with top-of-the line cloaking technology to hide itself from view."
	icon_state = "droidscout"
	move_delay = 2
	max_integrity = 250
	var/cloaktimer

/obj/vehicle/unmanned/droid/scout/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(ishuman(user))
		to_chat(user, "Use <b>right click</b> when piloting the droid to activate its cloaking systems.")

/obj/vehicle/unmanned/droid/scout/on_remote_toggle(datum/source, is_on, mob/user)
	. = ..()
	if(is_on)
		RegisterSignal(user, COMSIG_MOB_CLICK_RIGHT, .proc/cloak_drone)
	else
		UnregisterSignal(user, COMSIG_MOB_CLICK_RIGHT)

///runs checks for cloaking then begins to cloak it
/obj/vehicle/unmanned/droid/scout/proc/cloak_drone(datum/source)
	SIGNAL_HANDLER
	if(cloaktimer)
		deactivate_cloak()
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DRONE_CLOAK))
		return
	apply_wibbly_filters(src)
	playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, TRUE)
	INVOKE_ASYNC(src, .proc/start_cloak, source)

///Plays effects and doafter effects for the drone
/obj/vehicle/unmanned/droid/scout/proc/start_cloak(mob/user)
	if(!do_after(user, 3 SECONDS, FALSE, src))
		to_chat(user, span_warning(" WARNING. Cloak activation failed; Error code 423: Subject moved during activation."))
		remove_wibbly_filters(src)
		return
	remove_wibbly_filters(src)
	playsound(src, 'sound/effects/pred_cloakon.ogg', 60, TRUE)
	alpha = CLOAK_IMPLANT_ALPHA
	cloaktimer = addtimer(CALLBACK(src, .proc/deactivate_cloak), 12 SECONDS, TIMER_STOPPABLE)

///Deactivates the cloak when someone turns it off or its forced off
/obj/vehicle/unmanned/droid/scout/proc/deactivate_cloak()
	if(cloaktimer)
		deltimer(cloaktimer)
		cloaktimer = null
	playsound(src, 'sound/effects/pred_cloakoff.ogg', 60, TRUE)
	alpha = initial(alpha)
	TIMER_COOLDOWN_START(src, COOLDOWN_DRONE_CLOAK, 12 SECONDS)

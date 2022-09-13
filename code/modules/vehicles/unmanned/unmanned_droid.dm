/obj/vehicle/unmanned/droid
	name = "XN-43-H combat droid"
	desc = "A prototype combat droid, first deployed as a prototype to fight the xeno menace in the frontier sytems."
	icon_state = "droidcombat"
	move_delay = 3
	max_integrity = 150
	turret_pattern = PATTERN_DROID
	can_interact = TRUE
	gunnoise = 'sound/weapons/guns/fire/laser.ogg'
	spawn_equipped_type = /obj/item/uav_turret/droid
	unmanned_flags = HAS_LIGHTS|OVERLAY_TURRET
	///Existing signal for Supply console.
	var/datum/supply_beacon/beacon_datum
	var/datum/action/antenna/antenna

/obj/vehicle/unmanned/droid/Initialize()
	. = ..()
	antenna = new

/obj/vehicle/unmanned/droid/process() //play beepy noise every 5 seconds for effect while active
	if(prob(90))
		return
	var/soundfile = "sound/runtime/drone/drone[rand(1,12)].ogg"
	soundfile = file(soundfile)
	if(!fexists(soundfile))
		return
	playsound(src, soundfile, 50)

/obj/vehicle/unmanned/droid/on_remote_toggle(datum/source, is_on, mob/user)
	. = ..()
	if(is_on)
		playsound(src, 'sound/machines/drone/weapons_engaged.ogg', 70)
		START_PROCESSING(SSslowprocess, src)
		user.overlay_fullscreen("machine", /obj/screen/fullscreen/machine)
		antenna.give_action(user)
		RegisterSignal(user, COMSIG_UNMANNED_COORDINATES, .proc/activate_antenna)
	else
		playsound(src, 'sound/machines/drone/droneoff.ogg', 70)
		STOP_PROCESSING(SSslowprocess, src)
		user.clear_fullscreen("machine", 5)
		antenna.remove_action(user)
		UnregisterSignal(user, COMSIG_UNMANNED_COORDINATES)

/obj/vehicle/unmanned/droid/Destroy(datum/source, mob/user)
	. = ..()
	user.clear_fullscreen("machine", 5)
	antenna.remove_action(user)
	UnregisterSignal(user, COMSIG_UNMANNED_COORDINATES)

///stealth droid, like the normal droid but with stealthing ability on rclick
/obj/vehicle/unmanned/droid/scout
	name = "XN-43-S combat droid"
	desc = "A prototype scout droid, rigged with top-of-the line cloaking technology to hide itself from view."
	icon_state = "droidscout"
	move_delay = 2
	max_integrity = 200
	spawn_equipped_type = null
	unmanned_flags = GIVE_NIGHT_VISION|OVERLAY_TURRET
	turret_pattern = NO_PATTERN
	var/cloaktimer

/obj/vehicle/unmanned/droid/scout/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(ishuman(user))
		. += "Use <b>right click</b> when piloting the droid to activate its cloaking systems."

/obj/vehicle/unmanned/droid/scout/on_remote_toggle(datum/source, is_on, mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UNMANNED_ABILITY_UPDATED)

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
	cloaktimer = addtimer(CALLBACK(src, .proc/deactivate_cloak), 1 MINUTES, TIMER_STOPPABLE)

///Deactivates the cloak when someone turns it off or its forced off
/obj/vehicle/unmanned/droid/scout/proc/deactivate_cloak()
	if(cloaktimer)
		deltimer(cloaktimer)
		cloaktimer = null
	playsound(src, 'sound/effects/pred_cloakoff.ogg', 60, TRUE)
	alpha = initial(alpha)
	TIMER_COOLDOWN_START(src, COOLDOWN_DRONE_CLOAK, 12 SECONDS)

///Proc used for the supply link feature, activate to appear as an antenna
/obj/vehicle/unmanned/droid/proc/activate_antenna(datum/source, mob/user)
	SIGNAL_HANDLER

	user = source

	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
		QDEL_NULL(beacon_datum)
		to_chat(source, (span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console")))
		return
	if(!is_ground_level(z))
		to_chat(source, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	beacon_datum = new /datum/supply_beacon(user.name, src.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_PARENT_QDELETING, .proc/clean_beacon_datum)
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [loc.x]. LATITUDE [loc.y]. Area ID: [get_area(src)]\""))

///removes the beacon when we delete the droid
/obj/vehicle/unmanned/droid/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

/datum/action/antenna
	name = "Use Antenna"
	action_icon_state = "rally_minions"

/datum/action/antenna/action_activate()
	SEND_SIGNAL(owner, COMSIG_UNMANNED_COORDINATES)

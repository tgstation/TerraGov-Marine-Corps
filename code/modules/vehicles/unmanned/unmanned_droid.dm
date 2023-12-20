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
	allow_pass_flags = PASS_AIR
	unmanned_flags = HAS_LIGHTS|OVERLAY_TURRET
	/// Existing signal for Supply console.
	var/datum/supply_beacon/beacon_datum
	/// Action to activate suppply antenna.
	var/datum/action/antenna/antenna
	/// The mob controlling the droid remotely
	var/datum/weakref/remote_user

/obj/vehicle/unmanned/droid/Initialize(mapload)
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
		remote_user = WEAKREF(user)
		playsound(src, 'sound/machines/drone/weapons_engaged.ogg', 70)
		START_PROCESSING(SSslowprocess, src)
		user.overlay_fullscreen("machine", /atom/movable/screen/fullscreen/machine)
		antenna.give_action(user)
		RegisterSignal(user, COMSIG_UNMANNED_COORDINATES, PROC_REF(activate_antenna))
	else
		remote_user = null
		playsound(src, 'sound/machines/drone/droneoff.ogg', 70)
		STOP_PROCESSING(SSslowprocess, src)
		user.clear_fullscreen("machine", 5)
		antenna.remove_action(user)
		UnregisterSignal(user, COMSIG_UNMANNED_COORDINATES)

/obj/vehicle/unmanned/droid/Destroy()
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
	if(!remote_user) //No remote user, no need to do this.
		return ..()
	var/mob/living/living_user = remote_user.resolve()
	if(!living_user)
		return
	living_user.clear_fullscreen("machine", 5)
	antenna.remove_action(living_user)
	UnregisterSignal(living_user, COMSIG_UNMANNED_COORDINATES)
	if(isAI(living_user))
		var/mob/living/silicon/ai/AI = living_user
		AI.eyeobj?.forceMove(get_turf(src))
	return ..()

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
	SEND_SIGNAL(src, COMSIG_UNMANNED_ABILITY_UPDATED, CLOAK_ABILITY)

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
	INVOKE_ASYNC(src, PROC_REF(start_cloak), source)

///Plays effects and doafter effects for the drone
/obj/vehicle/unmanned/droid/scout/proc/start_cloak(mob/user)
	if(!do_after(user, 3 SECONDS, IGNORE_HELD_ITEM, src))
		to_chat(user, span_warning(" WARNING. Cloak activation failed; Error code 423: Subject moved during activation."))
		remove_wibbly_filters(src)
		return
	remove_wibbly_filters(src)
	playsound(src, 'sound/effects/pred_cloakon.ogg', 60, TRUE)
	alpha = CLOAK_IMPLANT_ALPHA
	cloaktimer = addtimer(CALLBACK(src, PROC_REF(deactivate_cloak)), 1 MINUTES, TIMER_STOPPABLE)

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
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
		to_chat(source, (span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console")))
		return
	if(!is_ground_level(z))
		to_chat(source, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	beacon_datum = new /datum/supply_beacon(user.name, src.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_QDELETING, PROC_REF(clean_beacon_datum))
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [loc.x]. LATITUDE [loc.y]. Area ID: [get_area(src)]\""))

///removes the beacon when we delete the droid
/obj/vehicle/unmanned/droid/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

/datum/action/antenna
	name = "Use Antenna"
	action_icon_state = "signal_transmit"

/datum/action/antenna/action_activate()
	SEND_SIGNAL(owner, COMSIG_UNMANNED_COORDINATES)

/obj/vehicle/unmanned/droid/ripley
	name = "XN-27-C cargo droid"
	desc = "A cargo droid, rigged with experimental technology to allow AI control. The claw is not standard and cannot grasp warheads."
	icon = 'icons/obj/powerloader.dmi'
	icon_state = "ai_powerloader"
	move_delay = 7
	max_integrity = 550
	spawn_equipped_type = null
	unmanned_flags = GIVE_NIGHT_VISION
	turret_pattern = NO_PATTERN
	soft_armor = list(MELEE = 60, BULLET = 20, LASER = 10, ENERGY = 20, BOMB = 80, BIO = 0, FIRE = 100, ACID = 100)
	//what the ripley is currently carrying
	var/atom/movable/cargo
	///used to prevent spam grabbing and dropping by the AI
	COOLDOWN_DECLARE(clamp_cooldown)

/obj/vehicle/unmanned/droid/ripley/on_remote_toggle(datum/source, is_on, mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UNMANNED_ABILITY_UPDATED, CARGO_ABILITY)

///grab an eligible atom and store it, if we already have an atom place it on the ground
/obj/vehicle/unmanned/droid/ripley/proc/handle_cargo(mob/user, atom/target, params)
	///used to hold whatever we're grabbing
	var/obj/clamptarget = target
	if(is_ground_level(z) && !isdropshiparea(get_area(src))) //AI powerloader is confined to shipside or the alamo
		to_chat(user, "Connection too weak, return the droid shipside first.")
		return
	if(!COOLDOWN_CHECK(src, clamp_cooldown))
		return
	if(cargo && Adjacent(target) && istype(target, /obj/structure/closet))
		var/obj/structure/closet/attackedcloset = clamptarget
		attackedcloset.toggle()
	else if(cargo)
		to_chat(user, "You unload [cargo].")
		cargo.forceMove(drop_location())
		cargo = null
		return
	if(ismob(clamptarget) || isvehicle(clamptarget) ||  isturf(clamptarget) || istype(clamptarget, /obj/machinery/nuclearbomb))
		return
	if(!Adjacent(target) || clamptarget.anchored == TRUE)
		return
	if(locate(/mob) in clamptarget.contents) //keep the droid from loading people or mobs in its cargo
		to_chat(user, "[icon2html(src, user)][span_notice("[target] contains a living organism, cannot load.")]")
		return
	if(!cargo)
		balloon_alert_to_viewers("Loads [clamptarget]")
		clamptarget.anchored = TRUE
		cargo = clamptarget
		clamptarget.forceMove(src)
		clamptarget.anchored = initial(clamptarget.anchored)
		to_chat(user, "[icon2html(src, user)][span_notice("[target] successfully loaded.")]") //AIs usually can't see balloon_alerts, send them a to_chat instead
	COOLDOWN_START(src, clamp_cooldown, 1 SECONDS)
	playsound(src, 'sound/mecha/hydraulic.ogg', 50, FALSE, -6)

/obj/vehicle/unmanned/droid/ripley/Destroy()
	if(cargo)
		cargo.forceMove(get_turf(src))
		cargo = null
	. = ..()

/datum/fire_support
	///Fire support name
	var/name = "misc firesupport"
	///icon_state for radial menu
	var/icon_state
	///define name of the firesupport, used for assoc
	var/fire_support_type
	///How frequently this canbe used
	var/cooldown_duration = 2 MINUTES
	///Holder for the cooldown timer
	var/cooldown_timer
	///Number of uses available. Negative for no limit
	var/uses = -1
	///Special behavior flags
	var/fire_support_flags = FIRESUPPORT_AVAILABLE
	///How far the fire support can land from the target turf
	var/scatter_range = 6
	///How many impacts per use
	var/impact_quantity = 1
	///Chat message when initiating fire support
	var/initiate_chat_message = "TARGET ACQUIRED. FIRE SUPPORT INBOUND."
	///screentext message when initiating fire support
	var/initiate_screen_message = "fire support inbound."
	///Screentext message title
	var/initiate_title = "Garuda-1"
	///Portrait used for screentext message
	var/portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/pilot
	///Initiating sound effect
	var/initiate_sound = 'sound/effects/dropship_sonic_boom.ogg'
	///Delay between initiation and impact
	var/delay_to_impact = 4 SECONDS
	///visual when impact starts
	var/start_visual = /obj/effect/temp_visual/dropship_flyby
	///sound when impact starts
	var/start_sound = 'sound/effects/casplane_flyby.ogg'

/datum/fire_support/New()
	. = ..()
	if(uses > 0)
		disable()

///Enables the firesupport option
/datum/fire_support/proc/enable_firesupport(additional_uses)
	uses += additional_uses
	fire_support_flags |= FIRESUPPORT_AVAILABLE

///Disables the firesupport entirely
/datum/fire_support/proc/disable(clear_uses = TRUE)
	if(clear_uses)
		uses = 0
	fire_support_flags &= ~FIRESUPPORT_AVAILABLE

///Initiates fire support proc chain
/datum/fire_support/proc/initiate_fire_support(turf/target_turf, mob/user)
	if(!uses || !(fire_support_flags & FIRESUPPORT_AVAILABLE))
		to_chat(user, span_notice("FIRE SUPPORT UNAVAILABLE"))
		return
	uses --
	addtimer(CALLBACK(src, PROC_REF(start_fire_support), target_turf), delay_to_impact)

	if(initiate_sound)
		playsound(target_turf, initiate_sound, 100)
	if(initiate_chat_message)
		to_chat(user, span_notice(initiate_chat_message))
	if(portrait_type && initiate_title && initiate_screen_message)
		user.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(initiate_title, initiate_screen_message, LEFT_ALIGN_TEXT), portrait_type)

///Actually begins the fire support attack
/datum/fire_support/proc/start_fire_support(turf/target_turf)
	cooldown_timer = addtimer(VARSET_CALLBACK(src, cooldown_timer, null), cooldown_duration, TIMER_STOPPABLE)
	select_target(target_turf)

	if(start_visual)
		new start_visual(target_turf)
	if(start_sound)
		playsound(target_turf, start_sound, 100)

///Selects the final target turf(s) and calls impact procs
/datum/fire_support/proc/select_target(turf/target_turf)
	var/list/turf_list = RANGE_TURFS(scatter_range, target_turf)
	for(var/i = 1 to impact_quantity)
		var/turf/impact_turf = pick(turf_list)
		addtimer(CALLBACK(src, PROC_REF(do_impact), impact_turf), 0.15 SECONDS * i)

///The actual impact of the fire support
/datum/fire_support/proc/do_impact(turf/target_turf)
	return

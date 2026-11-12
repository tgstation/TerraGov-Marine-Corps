/obj/machinery/button/mrap
	name = "comm booster switch"
	desc = "This switch controls the vehicle built in communication booster array. While active, communications is boosted in a radius around the vehicle in low signal areas such as caves."
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "warning"
	pixel_y = 17
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner
	///Last location of owner when processing
	var/last_loc
	///Activation status
	var/activated = FALSE
	///Currently boosted areas
	var/list/area_list = list()
	///Areas within this range are boosted
	var/boost_range = 25
	/// The looping sound that plays when the bike is operating
	var/datum/looping_sound/comm_booster/boost_sound

/obj/machinery/button/mrap/Initialize(mapload, ndir)
	. = ..()
	boost_sound = new()

/obj/machinery/button/mrap/Destroy()
	end_boost()
	QDEL_NULL(boost_sound)
	return ..()

/obj/machinery/button/mrap/link_interior(datum/interior/link)
	owner = link.container

/obj/machinery/button/mrap/Initialize(mapload, ndir)
	. = ..()
	setDir(ndir)

/obj/machinery/button/mrap/setDir(newdir)
	. = ..()
	pixel_x = 0
	pixel_y = 17 //todo: default button code needs to be de-snowflaked

/obj/machinery/button/mrap/update_icon_state()
	if(activated)
		icon_state = "warning_on"
	else
		icon_state = "warning_off"

/obj/machinery/button/mrap/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(!length(area_list))
		desc += " It doesn't appear to be active right now."
		return
	var/list/boosted_list = list()
	for(var/area/boost_area AS in area_list)
		boosted_list += "[boost_area.name]"
	desc += "<BR><BR>Currently boosting communication strength in the following areas: <b>[english_list(boosted_list)].</b>"

/obj/machinery/button/mrap/activate(mob/living/user)
	playsound(loc, 'sound/machines/switch.ogg', 100, FALSE, MEDIUM_SOUND_RANGE)

	if(activated)
		end_boost()
		visible_message(span_warning("Comm booster shutting down."))
		return
	start_boost()

/obj/machinery/button/mrap/process()
	var/current_loc = get_turf(owner)
	if(current_loc == last_loc) //no point cycling if we haven't moved
		return
	last_loc = current_loc

	for(var/area/old_area AS in area_list)
		old_area.area_flags &= ~BETTER_RADIO

	area_list = get_areas_in_range(boost_range, owner)
	var/is_boosting = FALSE
	for(var/area/new_area AS in area_list)
		if(new_area.ceiling < CEILING_UNDERGROUND) //currently there is no benefit above ground
			area_list -= new_area
			continue
		is_boosting = TRUE
		new_area.area_flags |= BETTER_RADIO

	if(!is_boosting) //if we are not comm boosting any areas where it actually matters, we stop boosting
		visible_message(span_warning("All areas in range have nominal radio strength. Shutting down booster."))
		end_boost()
		return PROCESS_KILL

	update_appearance(UPDATE_DESC)

///Starts comm boosting
/obj/machinery/button/mrap/proc/start_boost()
	if(process() == PROCESS_KILL)
		return

	START_PROCESSING(SSslowprocess, src)

	activated = TRUE
	update_appearance()
	flick("warning_success", src)

	visible_message(span_warning("Comm booster starting up."))
	boost_sound.start(src)

///Stops comm boosting
/obj/machinery/button/mrap/proc/end_boost()
	STOP_PROCESSING(SSslowprocess, src)
	if(activated)
		boost_sound.stop(src)
	activated = FALSE
	last_loc = null
	area_list = null
	update_appearance()
	flick("warning_fail", src)


/datum/looping_sound/comm_booster
	mid_sounds = list(
		'sound/machines/tcomms/tcomms_mid1.ogg'=1,
		'sound/machines/tcomms/tcomms_mid2.ogg'=1,
		'sound/machines/tcomms/tcomms_mid3.ogg'=1,
		'sound/machines/tcomms/tcomms_mid4.ogg'=1,
		'sound/machines/tcomms/tcomms_mid5.ogg'=1,
		'sound/machines/tcomms/tcomms_mid6.ogg'=1,
		'sound/machines/tcomms/tcomms_mid7.ogg'=1,
	)
	mid_length = 2 SECONDS
	volume = 8
	falloff = 4
	range = MEDIUM_SOUND_RANGE

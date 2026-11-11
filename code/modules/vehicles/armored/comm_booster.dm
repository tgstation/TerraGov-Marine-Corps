/obj/machinery/button/mrap
	name = "comm booster switch"
	desc = "This switch controls the vehicle built in communication booster array. While active, and the vehicle is stationary, communications is boosted in low signal areas such as caves."
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "warning"
	pixel_z = 17
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

	var/activated = FALSE

/obj/machinery/button/mrap/link_interior(datum/interior/link)
	owner = link.container

/obj/machinery/button/mrap/Initialize(mapload, ndir)
	. = ..()
	setDir(ndir)

/obj/machinery/button/mrap/setDir(newdir)
	. = ..()
	pixel_w = 0
	pixel_z = 17 //todo: default button code needs to be de-snowflaked

/obj/machinery/button/mrap/update_icon_state()
	if(activated)
		icon_state = "warning_on"
	else
		icon_state = "warning_off"

/obj/machinery/button/mrap/activate(mob/living/user)
	playsound(loc, 'sound/machines/switch.ogg', 100, FALSE, MEDIUM_SOUND_RANGE)

	if(activated)
		activated = FALSE
		update_appearance(UPDATE_ICON_STATE)
		flick("warning_fail", src)
		end_boost()
		return

	activated = TRUE
	update_appearance(UPDATE_ICON_STATE)
	flick("warning_success", src)
	start_boost()


/obj/machinery/button/mrap/proc/start_boost()
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(comm_buff))
	RegisterSignal(owner, COMSIG_EXIT_AREA, PROC_REF(remove_comm_buff))
	comm_buff(new_area = get_area(owner))
	//change this to range based, and static. maybe???
	//get_areas_in_range(distance = 0, atom/center = usr)

/obj/machinery/button/mrap/proc/end_boost()
	UnregisterSignal(owner, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA))
	remove_comm_buff(old_area = get_area(owner))

/obj/machinery/button/mrap/proc/comm_buff(datum/source, area/new_area, atom/old_loc)
	SIGNAL_HANDLER
	new_area.area_flags |= BETTER_RADIO

/obj/machinery/button/mrap/proc/remove_comm_buff(datum/source, area/old_area, direction)
	SIGNAL_HANDLER
	old_area.area_flags &= ~BETTER_RADIO

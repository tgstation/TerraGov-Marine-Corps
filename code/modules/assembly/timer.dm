/obj/item/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	materials = list(/datum/material/metal = 500, /datum/material/glass = 50)
	attachable = TRUE
	interaction_flags = INTERACT_REQUIRES_DEXTERITY

	var/timing = FALSE
	var/time = 5
	var/saved_time = 5
	var/loop = FALSE
	var/hearing_range = 3


/obj/item/assembly/timer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/assembly/timer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/assembly/timer/examine(mob/user)
	. = ..()
	. += span_notice("The timer is [timing ? "counting down from [time]":"set for [time] seconds"].")


/obj/item/assembly/timer/activate()
	. = ..()
	if(!.)
		return FALSE//Cooldown check
	timing = !timing
	update_icon()
	return TRUE


/obj/item/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/obj/item/assembly/timer/proc/timer_end()
	if(!secured || next_activate > world.time)
		return FALSE
	pulse(FALSE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	if(loop)
		timing = TRUE
	update_icon()


/obj/item/assembly/timer/process()
	if(!timing)
		return
	time--
	if(time <= 0)
		timing = FALSE
		timer_end()
		time = saved_time


/obj/item/assembly/timer/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("timer_timing")
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()


/obj/item/assembly/timer/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!is_secured(user))
		return FALSE

	return TRUE


/obj/item/assembly/timer/interact(mob/user)
	. = ..()
	if(.)
		return

	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = "<B>Timing Unit</B>"
	dat += "<BR>[(timing ? "<A href='?src=[REF(src)];time=0'>Timing</A>" : "<A href='?src=[REF(src)];time=1'>Not Timing</A>")] [minute]:[second]"
	dat += "<BR><A href='?src=[REF(src)];tp=-30'>-</A> <A href='?src=[REF(src)];tp=-1'>-</A> <A href='?src=[REF(src)];tp=1'>+</A> <A href='?src=[REF(src)];tp=30'>+</A>"
	dat += "<BR><BR><A href='?src=[REF(src)];repeat=[(loop ? "0'>Stop repeating" : "1'>Set to repeat")]</A>"
	dat += "<BR><BR><A href='?src=[REF(src)];refresh=1'>Refresh</A>"

	var/datum/browser/popup = new(user, "timer", name)
	popup.set_content(dat)
	popup.open()


/obj/item/assembly/timer/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["time"])
		timing = text2num(href_list["time"])
		update_icon()

	if(href_list["repeat"])
		loop = text2num(href_list["repeat"])

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 1), 600)
		saved_time = time

	updateUsrDialog()

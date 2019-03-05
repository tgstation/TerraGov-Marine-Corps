/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(ACCESS_MARINE_MEDBAY)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1

	attack_paw(mob/user as mob)
		return

/obj/machinery/medical_help_button
	name = "Medical attention required"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A button for alerting doctors that you require assistance."
	var/active = FALSE
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/medical_help_button/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	add_fingerprint(user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] doesn't seem to be working.</span>")
		return
	if(active)
		return
	use_power(5)
	icon_state = "doorctrl1"

	var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
	AI.SetName("Lobby Notification System")
	AI.aiRadio.talk_into(AI,"<b>[user.name] is requesting medical attention at: [get_area(src)].</b>","MedSci","announces")
	qdel(AI)	
	visible_message("Remain calm, someone will be with you shortly.")

	active = TRUE
	addtimer(CALLBACK(src, .proc/icon_update_check), 10 SECONDS)

/obj/machinery/medical_help_button/proc/icon_update_check()
	active = FALSE
	if(!(machine_stat & NOPOWER))
		icon_state = "doorctrl0"

/obj/machinery/medical_help_button/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"
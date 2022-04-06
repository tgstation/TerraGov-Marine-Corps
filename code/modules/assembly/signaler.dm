/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	item_state = "signaler"
	materials = list(/datum/material/metal = 400, /datum/material/glass = 120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = TRUE

	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/delay = 0
	var/datum/radio_frequency/radio_connection
	var/hearing_range = 1


/obj/item/assembly/signaler/Initialize()
	. = ..()
	set_frequency(frequency)


/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()


/obj/item/assembly/signaler/activate()
	. = ..()
	if(!.) //cooldown processing
		return FALSE
	signal()
	return TRUE


/obj/item/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()


/obj/item/assembly/signaler/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!is_secured(user))
		return FALSE

	return TRUE


/obj/item/assembly/signaler/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
<A href='byond://?src=[REF(src)];send=1'>Send Signal</A><BR>
<B>Frequency/Code</B> for signaler:<BR>
Frequency:
[format_frequency(frequency)]
<A href='byond://?src=[REF(src)];set=freq'>Set</A><BR>

Code:
[code]
<A href='byond://?src=[REF(src)];set=code'>Set</A><BR>"}

	var/datum/browser/popup = new(user, "signaler", name)
	popup.set_content(dat)
	popup.open()


/obj/item/assembly/signaler/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["set"])
		if(href_list["set"] == "freq")
			var/new_freq = input(usr, "Input a new signalling frequency", "Remote Signaller Frequency", format_frequency(frequency)) as num|null
			if(!can_interact(usr))
				return
			new_freq = unformat_frequency(new_freq)
			new_freq = sanitize_frequency(new_freq, TRUE)
			set_frequency(new_freq)

		if(href_list["set"] == "code")
			var/new_code = input(usr, "Input a new signalling code", "Remote Signaller Code", code) as num|null
			if(!can_interact(usr))
				return
			new_code = round(new_code)
			new_code = clamp(new_code, 1, 100)
			code = new_code

	if(href_list["send"])
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_SIGNALLER_SEND))
			to_chat(usr, span_warning("[src] is still recharging..."))
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_SIGNALLER_SEND, 1 SECONDS)
		INVOKE_ASYNC(src, .proc/signal)

	updateUsrDialog()


/obj/item/assembly/signaler/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(issignaler(I))
		var/obj/item/assembly/signaler/signaler2 = I
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")


/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list("code" = code))
	radio_connection.post_signal(src, signal)


/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(!(wires & WIRE_RADIO_RECEIVE))
		return
	pulse(TRUE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE


/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)



// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/assembly/signaler/receiver
	var/on = FALSE


/obj/item/assembly/signaler/receiver/proc/toggle_safety()
	on = !on


/obj/item/assembly/signaler/receiver/activate()
	toggle_safety()
	return TRUE

/obj/item/assembly/signaler/receiver/examine(mob/user)
	. = ..()
	. += span_notice("The radio receiver is [on?"on":"off"].")


/obj/item/assembly/signaler/receiver/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..()

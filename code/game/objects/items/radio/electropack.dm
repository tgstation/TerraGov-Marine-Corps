/obj/item/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "electropack0"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/security_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/security_right.dmi',
	)
	worn_icon_state = "electropack"
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE


	var/on = TRUE
	var/code = 2
	var/frequency = FREQ_ELECTROPACK

/obj/item/electropack/Initialize(mapload)
	. = ..()
	SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/electropack/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/electropack/attack_hand(mob/living/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			to_chat(user, span_warning("You need help taking this off!"))
			return TRUE
	return ..()


/obj/item/electropack/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["freq"])
		SSradio.remove_object(src, frequency)
		frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
		SSradio.add_object(src, frequency, RADIO_SIGNALER)

	else if(href_list["code"])
		code += text2num(href_list["code"])
		code = round(code)
		code = min(100, code)
		code = max(1, code)

	else if(href_list["power"])
		on = !on
		icon_state = "electropack[on]"

	updateUsrDialog()


/obj/item/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on)
		var/mob/living/L = loc
		to_chat(L, span_danger("You feel a sharp shock!"))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.Paralyze(20 SECONDS)

	if(master)
		master.receive_signal()


/obj/item/electropack/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			return FALSE

	return TRUE


/obj/item/electropack/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
Turned [on ? "On" : "Off"] -
<A href='byond://?src=[REF(src)];power=1'>Toggle</A><BR>
<B>Frequency/Code</B> for electropack:<BR>
Frequency:
<A href='byond://?src=[REF(src)];freq=-10'>-</A>
<A href='byond://?src=[REF(src)];freq=-2'>-</A> [format_frequency(frequency)]
<A href='byond://?src=[REF(src)];freq=2'>+</A>
<A href='byond://?src=[REF(src)];freq=10'>+</A><BR>

Code:
<A href='byond://?src=[REF(src)];code=-5'>-</A>
<A href='byond://?src=[REF(src)];code=-1'>-</A> [code]
<A href='byond://?src=[REF(src)];code=1'>+</A>
<A href='byond://?src=[REF(src)];code=5'>+</A><BR>
"}

	var/datum/browser/popup = new(user, "electropack")
	popup.set_content(dat)
	popup.open()

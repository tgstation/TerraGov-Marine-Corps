/obj/item/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "electropack0"
	item_state = "electropack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE

	matter = list("metal" = 10000,"glass" = 2500)

	var/on = TRUE
	var/code = 2
	var/frequency = FREQ_ELECTROPACK

/obj/item/electropack/Initialize()
	. = ..()
	SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/electropack/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()


/obj/item/electropack/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			to_chat(user, "<span class='warning'>You need help taking this off!</span>")
			return
	return ..()


/obj/item/electropack/Topic(href, href_list)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = usr
	if(C.incapacitated() || C.back == src)
		return

	if(!(ishuman(C) || C.contents.Find(src)) && !C.contents.Find(master) && !(in_range(src, C) || isturf(loc)))
		return

	C.set_interaction(src)
	
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
		to_chat(L, "<span class='danger'>You feel a sharp shock!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.KnockDown(10)

	if(master)
		master.receive_signal()


/obj/item/electropack/attack_self(mob/user)
	if(!ishuman(user))
		return

	user.set_interaction(src)

	var/dat = {"
Turned [on ? "On" : "Off"] -
<A href='?src=[REF(src)];power=1'>Toggle</A><BR>
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
	user << browse(dat, "window=radio")
	onclose(user, "radio")

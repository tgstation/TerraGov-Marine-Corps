/obj/item/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	implant_color = "r"
	var/activation_emote = "chuckle"
	var/uses = 1


/obj/item/implant/freedom/Initialize()
	. = ..()
	activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	uses = rand(1, 5)


/obj/item/implant/freedom/trigger(emote, mob/living/carbon/source)
	if(uses < 1)	
		return FALSE
	
	if(emote == activation_emote)
		uses--
		to_chat(source, "You feel a faint click.")
		if(source.handcuffed)
			var/obj/item/W = source.handcuffed
			source.update_handcuffed(null)
			source.dropItemToGround(W)
		if(source.legcuffed)
			var/obj/item/W = source.legcuffed
			source.legcuffed = null
			source.update_inv_legcuffed()
			source.dropItemToGround(W)


/obj/item/implant/freedom/implanted(mob/living/carbon/source)
	source.mind.store_memory("Freedom implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.")
	to_chat(source, "The implanted freedom implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.")
	return TRUE


/obj/item/implant/freedom/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
	return dat

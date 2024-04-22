/obj/item/implant/freedom
	name = "freedom implant"
	desc = ""
	icon_state = "freedom"
	implant_color = "r"
	uses = 4


/obj/item/implant/freedom/activate()
	. = ..()
	uses--
	to_chat(imp_in, "<span class='hear'>I feel a faint click.</span>")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
	if(!uses)
		qdel(src)


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
<HR>
No Implant Specifics"}
	return dat


/obj/item/implanter/freedom
	name = "implanter (freedom)"
	imp_type = /obj/item/implant/freedom

/obj/item/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = ""
	imp_type = /obj/item/implant/freedom

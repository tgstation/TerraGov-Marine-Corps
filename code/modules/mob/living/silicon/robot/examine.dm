/mob/living/silicon/robot/examine(mob/user)
	if( (user.sdisabilities & BLIND || user.blinded || user.stat) && !istype(user,/mob/dead/observer) )
		user << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>[custom_name ? ", [modtype] [braintype]" : ""]!\n"
	msg += "<span class='warning'>"
	if (src.getBruteLoss())
		if (src.getBruteLoss() < maxHealth*0.5)
			msg += "It looks slightly dented. A welding tool would buff that out in no time.\n"
		else
			msg += "<B>It looks severely dented! A welding tool would buff that out in no time.</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < maxHealth*0.5)
			msg += "It looks slightly charred. Its internal wiring will need to be repaired with a cable coil.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped! Its internal wiring will need to be repaired with a cable coil.</B>\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"
	if(!has_power)
		msg += "<span class='warning'>It appears to be running on backup power.</span>\n"

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)	msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)			msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n"
	msg += "*---------*</span>"

	if(print_flavor_text()) msg += "\n[print_flavor_text()]\n"

	if (pose)
		if( findtext(pose,".",lentext(pose)) == 0 && findtext(pose,"!",lentext(pose)) == 0 && findtext(pose,"?",lentext(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"

	user << msg
	return

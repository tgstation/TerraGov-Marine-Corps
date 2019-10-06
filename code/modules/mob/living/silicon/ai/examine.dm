/mob/living/silicon/ai/examine(mob/user)

	var/msg = "<span class='info'>*---------*<br>"
	msg += "This is [icon2html(src, user)] <b>[src]</b>!<br>"
	
	if(stat == DEAD)
		msg += "<span class='deadsay'>It appears to be powered-down.</span><br>"
	else
		msg += "<span class='warning'>"
		if(getBruteLoss())
			if(getBruteLoss() < 30)
				msg += "It looks slightly dented.<br>"
			else
				msg += "<B>It looks severely dented!</B><br>"
		if(getFireLoss())
			if(getFireLoss() < 30)
				msg += "It looks slightly charred.<br>"
			else
				msg += "<B>Its casing is melted and heat-warped!</B><br>"

		if(stat == UNCONSCIOUS)
			msg += "It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".<br>"

		if(!client)
			msg += "[src]/Core.exe has stopped responding! Searching for a solution to the problem...<br>"

		msg += "</span>"
	
	msg += "*---------*</span>"

	to_chat(user, msg)

/mob/living/carbon/Xenomorph/proc/hivemind_name()
	return "<span class='game say'>Hivemind, <span class='name'>[name]</span>"


/mob/living/carbon/Xenomorph/Queen/hivemind_name()
	return "<font size='3' font color='purple'><i><span class='game say'>Hivemind, <span class='name'>[name]</span>"


/mob/living/carbon/Xenomorph/proc/hivemind_end()
	return ""


/mob/living/carbon/Xenomorph/Queen/hivemind_end()
	return "</font>"


/mob/living/carbon/Xenomorph/proc/render_hivemind_message(message)
	return message


/mob/living/carbon/Xenomorph/proc/hivemind_talk(message)
	if(!message || stat)
		return
	if(!hive)
		return

	if(!hive.living_xeno_queen && hive.xeno_queen_timer > QUEEN_DEATH_TIMER*0.5 && hivenumber == XENO_HIVE_NORMAL)
		to_chat(src, "<span class='warning'>The Queen is dead. The hivemind is weakened. Despair!</span>")
		return

	message = render_hivemind_message(message)

	log_talk(message, LOG_HIVEMIND)

	

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/S = i
		if(!S?.client?.prefs || !(S.client.prefs.toggles_chat & CHAT_GHOSTHIVEMIND))
			continue
		var/track = FOLLOW_LINK(S, src)
		S.show_message("[track] [hivemind_name()] <span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)

	hive.hive_mind_message(src, message)

	return TRUE


/mob/living/carbon/Xenomorph/proc/receive_hivemind_message(mob/living/carbon/Xenomorph/X, message)
	show_message("[X.hivemind_name()] <span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)


/mob/living/carbon/Xenomorph/Queen/receive_hivemind_message(mob/living/carbon/Xenomorph/X, message)
	if(ovipositor && X != src)
		show_message("(<a href='byond://?src=\ref[src];watch_xeno_number=[X.nicknumber]'>F</a>) [X.hivemind_name()] <span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)
	else
		return ..()


/mob/living/carbon/Xenomorph/get_saymode(message, talk_key)
	if(copytext(message, 1, 2) == ";")
		return SSradio.saymodes["a"]
	else if(copytext(message, 1, 3) == ".a" || copytext(message, 1, 3) == ":a")
		return SSradio.saymodes["a"]
	else
		return SSradio.saymodes[talk_key]
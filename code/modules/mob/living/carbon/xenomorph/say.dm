/**
	Called to create the prefix for xeno hivemind messages

	Used to apply styling for queen/shrike/hivemind/leaders, giving them largetext and specific colouring.
	This is also paired with [/mob/living/carbon/xenomorph/hivemind_end]
*/
/mob/living/carbon/xenomorph/proc/hivemind_start()
	return "<span class='hivemind [queen_chosen_lead?"xenoleader":""]'>Hivemind, [span_name("[name]")]"

/**
	Called to create the suffix for xeno hivemind messages

	This should be used to close off any opened elements from [/mob/living/carbon/xenomorph/hivemind_start].
*/
/mob/living/carbon/xenomorph/proc/hivemind_end()
	return "</span>"


/mob/living/carbon/xenomorph/queen/hivemind_start()
	return "<span class='hivemind xenoqueen'>Hivemind, [span_name("[name]")]"

/mob/living/carbon/xenomorph/king/hivemind_start()
	return "<span class='game say hivemind xenoshrike'>Hivemind, [span_name("[name]")]"

/mob/living/carbon/xenomorph/shrike/hivemind_start()
	return "<span class='hivemind xenoshrike'>Hivemind, [span_name("[name]")]"

/mob/living/carbon/xenomorph/hivemind/hivemind_start()
	return "<span class='hivemind xenohivemind'>[span_name("The Hivemind ([nicknumber])")]"


/mob/living/carbon/xenomorph/proc/render_hivemind_message(message)
	return message


/mob/living/carbon/xenomorph/proc/hivemind_talk(message)
	if(!message || stat)
		return
	if(!hive)
		return

	if(hivenumber == XENO_HIVE_NORMAL && !hive.living_xeno_ruler && hive.xeno_queen_timer && timeleft(hive.xeno_queen_timer) > QUEEN_DEATH_TIMER * 0.5)
		to_chat(src, span_warning("The ruler is dead. The hivemind is weakened. Despair!"))
		return

	message = render_hivemind_message(message)

	log_talk(message, LOG_HIVEMIND)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/S = i
		if(!S?.client?.prefs || !(S.client.prefs.toggles_chat & CHAT_GHOSTHIVEMIND))
			continue
		var/track = FOLLOW_LINK(S, src)
		S.show_message("[track] [hivemind_start()] [span_message("hisses, '[message]'")][hivemind_end()]", 2)

	hive.hive_mind_message(src, message)

	return TRUE

/mob/living/carbon/xenomorph/proc/receive_hivemind_message(mob/living/carbon/xenomorph/X, message)
	var/follow_link = X != src ? "<a href='byond://?src=[REF(src)];watch_xeno_name=[REF(X)]'>(F)</a> " : ""
	show_message("[follow_link][X.hivemind_start()][span_message(" hisses, '[message]'")][X.hivemind_end()]", 2)


/mob/living/carbon/xenomorph/get_saymode(message, talk_key)
	if(copytext(message, 1, 2) == ";")
		return SSradio.saymodes["a"]
	else if(copytext(message, 1, 3) == ".a" || copytext(message, 1, 3) == ":a")
		return SSradio.saymodes["a"]
	else
		return SSradio.saymodes[talk_key]

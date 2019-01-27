#define TYPING_INDICATOR_LIFETIME 3 SECONDS	//grace period after which typing indicator disappears regardless of text in chatbar

mob/var/typing
mob/var/last_typed
mob/var/last_typed_time

var/global/image/typing_indicator = image('icons/mob/talk.dmi', null, "typing")


/mob/proc/toggle_typing_indicator(var/type)
	if(!typing_indicator)
		return

	if(!client?.prefs?.toggles_chat & SHOW_TYPING)
		overlays -= typing_indicator
		return

	if(typing)
		overlays -= typing_indicator
		typing = FALSE

	else if(stat == CONSCIOUS)
		overlays += typing_indicator
		typing = TRUE


/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	toggle_typing_indicator()
	var/message = input("","say (text)") as text
	toggle_typing_indicator()

	if(!message)
		return

	say_verb(message)


/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	toggle_typing_indicator()
	var/message = input("", "me (text)") as text
	toggle_typing_indicator()

	if(!message)
		return

	me_verb(message)


/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing emote or say message."

	prefs.toggles_chat ^= SHOW_TYPING
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles_chat & SHOW_TYPING) ? "no longer" : "now"] display a typing indicator.")

	// Clear out any existing typing indicator.
	if(prefs.toggles_chat & SHOW_TYPING)
		if(istype(mob))
			mob.toggle_typing_indicator()

	feedback_add_details("admin_verb","TID") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
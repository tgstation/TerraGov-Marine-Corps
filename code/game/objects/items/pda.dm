/obj/item/pda
	name = "PDA"
	desc = "An AgyeI-12 PDA, a mixed use mobile device that also includes a neural interface module. Given out like candy by the megacorps to corporate employees, it's the most common and reliable PDA in the market."
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "pda_white"
	///Text to say when the pda is interacted with
	var/list/audio_log
	///Overlay for the pda if it has an audio log
	var/screen_overlay = "pda_on"
	var/dialog_delay = 1.5 SECONDS

/obj/item/pda/Initialize(mapload)
	. = ..()
	if(audio_log)
		update_appearance(UPDATE_OVERLAYS)

/obj/item/pda/update_overlays()
	. = ..()
	. += mutable_appearance(icon, screen_overlay)
	. += emissive_appearance(icon, screen_overlay, src)

/obj/item/pda/attack_self(mob/user)
	. = ..()
	play_log(user)

///Checks cooldown and plays the audio log
/obj/item/pda/proc/play_log(mob/user)
	if(!audio_log)
		return
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_PDA_PLAY))
		user.balloon_alert(user, "still playing!")
		return

	balloon_alert_to_viewers("begin log")
	if(SStts.tts_enabled && !voice)
		voice = pick(SStts.available_speakers)
	for(var/i = 1 to length(audio_log))
		addtimer(CALLBACK(src, PROC_REF(say_dialog), audio_log[i]), dialog_delay * i)

	TIMER_COOLDOWN_START(src, COOLDOWN_PDA_PLAY, 5 SECONDS)

/obj/item/pda/proc/say_dialog(text)
	say(text)

/obj/item/pda/red
	icon_state = "pda_red"

/obj/item/pda/green
	icon_state = "pda_green"

/obj/item/pda/blue
	icon_state = "pda_blue"

/obj/item/pda/purple
	icon_state = "pda_purple"

/obj/item/pda/large
	name = "tablet PDA"
	desc = "An AgyeI-35 TABPDA, a mixed use mobile device that also includes a neural interface module. A much more larger form of the standard PDA for ease of use."
	icon_state = "pda_large_white"
	screen_overlay = "pda_large_on"

/obj/item/pda/large/red
	icon_state = "pda_large_red"

/obj/item/pda/large/green
	icon_state = "pda_large_green"

/obj/item/pda/large/blue
	icon_state = "pda_large_blue"

/obj/item/pda/large/purple
	icon_state = "pda_large_purple"

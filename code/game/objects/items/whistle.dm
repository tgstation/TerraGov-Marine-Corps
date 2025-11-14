/obj/item/whistle
	name = "\improper whistle"
	desc = "A metal pea-whistle. Can be blown while held, or worn in the mouth"
	icon_state = "whistle"
	w_class = WEIGHT_CLASS_TINY
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_MASK

	var/volume = 60
	/// The range in tiles which whistle makes people warcry
	var/warcryrange = 5

/obj/item/whistle/attack_self(mob/user)
	. = ..()
	whistle_playsound(user)

/obj/item/whistle/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(user.wear_mask == src)
		whistle_playsound(user)

/obj/item/whistle/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.wear_mask == src)
		whistle_playsound(user)

/obj/item/whistle/proc/whistle_playsound(mob/user as mob)
	if(TIMER_COOLDOWN_RUNNING(user, COOLDOWN_WHISTLE_BLOW))
		user.balloon_alert(user, "catch your breath!")
		return

	user.visible_message(span_warning("[user] blows into [src]!"))
	playsound(get_turf(src), 'sound/items/whistle.ogg', volume, 1)

	if(TIMER_COOLDOWN_RUNNING(user, COOLDOWN_WHISTLE_WARCRY))
		to_chat(user, span_notice("You have to wait a while to rally your troops..."))
	else
		TIMER_COOLDOWN_START(user, COOLDOWN_WHISTLE_WARCRY, 1 MINUTES)
		for(var/mob/living/carbon/human/human in get_hearers_in_view(warcryrange, user.loc))
			human.emote("warcry", intentional = TRUE)
			CHECK_TICK

	TIMER_COOLDOWN_START(user, COOLDOWN_WHISTLE_BLOW, 3 SECONDS)

/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "voice"
	worn_icon_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	atom_flags = CONDUCT
	var/spamcheck = FALSE

/obj/item/hailer/attack_self(mob/user)
	if(spamcheck)
		return

	playsound(get_turf(src), 'sound/voice/halt.ogg', 25, 1)
	user.audible_message(span_warning("[user]'s [name] rasps, \"Halt! Security!\""))

	spamcheck = TRUE
	addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 2 SECONDS)

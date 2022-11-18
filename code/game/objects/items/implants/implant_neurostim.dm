/obj/item/implant/neurostim
	name = "neurostimulator implant"
	desc = "An implant which regulates nociception and sensory function. Benefits include pain reduction, improved balance, and improved resistance to overstimulation and disoritentation. To encourage compliance, negative stimulus is applied if the implant hears a (non-radio) spoken codeprhase. Implant may be degraded by the body's immune system over time, and thus may occasionally malfunction."
	icon_state = "implant_evil"
	flags_implant = ACTIVATE_ON_HEAR
	var/phrase = "supercalifragilisticexpialidocious"

/obj/item/implant/neurostim/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotrasen NX-35 Neurostimulator Implant<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Stimulates and regulates sensorimotor function to optimize performance. Benefits include improved balance, and improved resistance to overstimulation and disoritentation.<BR>
	<b>Special Features:</b> To encourage compliance, negative stimulus is applied if the implant recieves a specified codeprhase.<BR>
	<b>Integrity:</b> Implant will be degraded by the body's immune system and thus occasionally malfunction."}

/obj/item/implant/neurostim/on_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(findtext_char(message, phrase))
		activate()

/obj/item/implant/neurostim/activate(accidental = FALSE)
	. = ..()
	if(!.)
		return
	if(malfunction == MALFUNCTION_PERMANENT)
		return FALSE

	if(accidental) //was triggered by random chance or EMP
		playsound(implant_owner, 'sound/machines/buzz-two.ogg', 60, 1)
		implant_owner.visible_message(span_warning("Something buzzes inside [implant_owner][part ? "'s [part.display_name]" : ""]."))
	else
		playsound(implant_owner, 'sound/machines/twobeep.ogg', 60, 1)
		implant_owner.visible_message(span_warning("Something beeps inside [implant_owner][part ? "'s [part.display_name]" : ""]."))
	addtimer(CALLBACK(src, .proc/shock_sparks), 1 SECONDS)

///Plays a shocky animation
/obj/item/implant/neurostim/proc/shock_sparks()
	playsound(implant_owner, 'sound/effects/sparks2.ogg', 60, 1)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	addtimer(CALLBACK(src, .proc/shock_collar), 5)

///Shocks the owner for whatever reason
/obj/item/implant/neurostim/proc/shock_collar()
	implant_owner.visible_message(span_danger("[implant_owner] convulses in pain!"), span_danger("Excruciating pain shoots through [part ? "your [part.display_name]" : "you"]!"))
	implant_owner.flash_act(1, TRUE)
	implant_owner.AdjustStun(20 SECONDS)
	implant_owner.Paralyze(20 SECONDS)
	implant_owner.apply_damage(100, STAMINA, part)
	implant_owner.apply_damage(5, BURN, part)
	UPDATEHEALTH(implant_owner)

/obj/item/implant/neurostim/implant(mob/living/carbon/human/target, mob/living/user)
	var/p = stripped_input(user, "Choose activation phrase:")
	if(!p)
		return FALSE
	phrase = p
	user.mind.store_memory("[src] in [target] can be made to deliver negative stimulus by saying something containing the phrase ''[phrase]'', <B>say [phrase]</B> to attempt to activate.", 0, 0)
	to_chat(user, span_notice("[src] in [target] can be made to deliver negative stimulus by saying something containing the phrase ''[phrase]'', <B>say [phrase]</B> to attempt to activate."))
	return ..()


/obj/item/implant/neurostim/emp_act(severity)
	if(malfunction)
		return
	if (prob(80))
		activate(TRUE)
	else
		meltdown()

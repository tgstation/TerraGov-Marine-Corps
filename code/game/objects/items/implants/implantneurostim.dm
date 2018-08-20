/obj/item/implant/neurostim
	name = "neurostimulator implant"
	desc = "An implant which regulates nociception and sensory function. Benefits include pain reduction, improved balance, and improved resistance to overstimulation and disoritentation. To encourage compliance, negative stimulus is applied if the implant hears a (non-radio) spoken codeprhase. Implant may be degraded by the body's immune system over time, and thus may occasionally malfunction."
	var/phrase = "supercalifragilisticexpialidocious"
	var/last_activated = 0
	var/implant_age = 0 //number of ticks since being implanted
	icon_state = "implant_evil"

/obj/item/implant/neurostim/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Weyland-Yutani NX-35 Neurostimulator Implant<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Stimulates and regulates sensorimotor function to optimize performance. Benefits include improved balance, and improved resistance to overstimulation and disoritentation.<BR>
<b>Special Features:</b> To encourage compliance, negative stimulus is applied if the implant recieves a specified codeprhase.<BR>
<b>Integrity:</b> Implant will be degraded by the body's immune system and thus occasionally malfunction."}
	return dat

/obj/item/implant/neurostim/hear_talk(mob/M as mob, msg)
	hear(msg)
	return

/obj/item/implant/neurostim/hear(var/msg)
	msg = sanitize(msg)
	if(findtext(msg,phrase))
		activate(0)

/obj/item/implant/neurostim/activate(var/accidental = 0)
	set waitfor = 0

	if(malfunction == MALFUNCTION_PERMANENT)
		return
	if(world.time - last_activated < 50)
		return
	if(!imp_in)
		playsound(src, 'sound/machines/twobeep.ogg', 60, 1)
		return

	last_activated = world.time

	if(istype(imp_in, /mob/living/))
		var/mob/living/M = imp_in
		if(accidental) //was triggered by random chance or EMP
			playsound(M, 'sound/machines/buzz-two.ogg', 60, 1)
			imp_in.visible_message("<span class='warning'>Something buzzes inside [imp_in][part ? "'s [part.display_name]" : ""].</span>")
		else
			playsound(M, 'sound/machines/twobeep.ogg', 60, 1)
			imp_in.visible_message("<span class='warning'>Something beeps inside [imp_in][part ? "'s [part.display_name]" : ""].</span>")
		sleep(10)
		playsound(M, 'sound/effects/sparks2.ogg', 60, 1)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		sleep(5)

		M.visible_message("<span class='danger'>[M] convulses in pain!</span>", "<span class='danger'>Excruciating pain shoots through [part ? "your [part.display_name]" : "you"]!</span>")
		M.flash_eyes(1, TRUE)
		M.stunned += 10
		M.KnockDown(10)
		M.apply_damage(100, HALLOSS, part)
		M.apply_damage(5, BURN, part, 0, 0, 0, src)

	else
		playsound(src, 'sound/machines/twobeep.ogg', 60, 1)


/obj/item/implant/neurostim/implanted(mob/source, mob/user)
	var/p = sanitize(input(user, "Choose activation phrase:"))
	if(!p)
		return 0
	phrase = p
	user.mind.store_memory("[src] in [source] can be made to deliver negative stimulus by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(user, "<span class='notice'>[src] in [source] can be made to deliver negative stimulus by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.</span>")
	processing_objects.Add(src)
	return 1


/obj/item/implant/neurostim/process()

	if(!ismob(imp_in) || malfunction == MALFUNCTION_PERMANENT)
		processing_objects.Remove(src)
		return

	implant_age++

	if(prob(min(0.5, implant_age * 0.00005))) //becomes more likely to randomly activate over time
		activate(1)

	else if(world.time - last_activated > 600)
		if(istype(imp_in, /mob/living/carbon/))
			var/mob/living/carbon/M = imp_in

			var/neuraline_inject_amount = max(1-M.reagents.get_reagent_amount("neuraline"), 0)

			M.reagents.add_reagent("neuraline", neuraline_inject_amount, null, 1)


/obj/item/implant/neurostim/emp_act(severity)
	if (malfunction)
		return
	if (prob(80))
		activate(1)
	else
		meltdown()


/obj/item/implant/neurostim/meltdown()
	processing_objects.Remove(src)
	. = ..()


/obj/item/implant/neurostim/Dispose()
	processing_objects.Remove(src)
	. = ..()


/obj/item/implanter/neurostim
	name = "implanter"

	New()
		src.imp = new /obj/item/implant/neurostim(src)
		..()
		update()
		return
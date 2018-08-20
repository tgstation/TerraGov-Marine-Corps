/mob/proc/flash_pain()
	overlay_fullscreen("pain", /obj/screen/fullscreen/pain, 2)
	clear_fullscreen("pain")

mob/var/list/pain_stored = list()
mob/var/last_pain_message = ""
mob/var/next_pain_time = 0

// partname is the name of a body part
// amount is a num from 1 to 100
mob/living/carbon/proc/pain(var/partname, var/amount, var/force, var/burning = 0)
	if(stat >= DEAD || (world.time < next_pain_time && !force)) return
	if(reagent_pain_modifier < 0) return //any pain reduction
	if(analgesic) return

	var/msg
	if(amount > 10 && ishuman(src))
		var/mob/living/carbon/human/H = src

		var/datum/limb/right_hand = H.get_limb("r_hand")
		var/datum/limb/left_hand = H.get_limb("l_hand")
		if(!H.stat && amount > 50 && prob(amount * 0.1))
			msg = "You [pick("wince","shiver","grimace")] in pain"
			var/i
			for(var/datum/limb/O in list(right_hand, left_hand))
				if(!O || !O.is_usable()) continue //Not if the organ can't possibly function.
				if(O.name == "l_hand") 	drop_l_hand()
				else 					drop_r_hand()
				i++
			if(i) msg += ", [pick("fumbling with","struggling with","losing control of")] your [i < 2 ? "hand" : "hands"]"
			to_chat(H, "<span class='warning'>[msg].</span>")

	if(burning)
		switch(amount)
			if(1 to 10)
				msg = "<span class='warning'>Your [partname] burns.</span>"
			if(11 to 90)
				flash_weak_pain()
				msg = "<span class='danger'>Your [partname] burns badly!</span>"
			if(91 to 10000)
				flash_pain()
				msg = "<span class='HIGHDANGER'>OH GOD! Your [partname] is on fire!</span>"
	else
		switch(amount)
			if(1 to 10)
				msg = "<span class='warning'>Your [partname] hurts.</span>"
			if(11 to 90)
				flash_weak_pain()
				msg = "<span class='danger'>Your [partname] hurts badly.</span>"
			if(91 to 10000)
				flash_pain()
				msg = "<span class='HIGHDANGER'>OH GOD! Your [partname] is hurting terribly!</span>"
	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		to_chat(src, msg)
	next_pain_time = world.time + (100 - amount)


// message is the custom message to be displayed
// flash_strength is 0 for weak pain flash, 1 for strong pain flash
mob/living/carbon/human/proc/custom_pain(message, flash_strength)
	if(stat >= UNCONSCIOUS) return
	if(species && species.flags & NO_PAIN) return
	if(reagent_pain_modifier <= PAIN_REDUCTION_HEAVY) return //anything as or more powerful than tramadol
	if(analgesic) return

	var/msg = "<span class='danger'>[message]</span>"
	if(flash_strength >= 1) msg = "<span class='highdanger'>[message]</span>"

	// Anti message spam checks
	if(msg && ((msg != last_pain_message) || (world.time >= next_pain_time)))
		last_pain_message = msg
		to_chat(src, msg)
	next_pain_time = world.time + 100

mob/living/carbon/human/proc/handle_pain()
	if(stat >= UNCONSCIOUS) return 	// not when sleeping
	if(species && species.flags & NO_PAIN) return
	if(reagent_pain_modifier <= PAIN_REDUCTION_HEAVY) return //anything as or more powerful than tramadol
	if(analgesic) return

	var/maxdam = 0
	var/dam
	var/datum/limb/damaged_organ = null
	for(var/datum/limb/E in limbs)
		/*
		Amputated, dead, or missing limbs don't cause pain messages.
		Broken limbs that are also splinted do not cause pain messages either.
		*/
		if(E.status & (LIMB_NECROTIZED|LIMB_DESTROYED)) continue

		dam = E.get_damage()
		if(E.status & LIMB_BROKEN)
			if(E.status & LIMB_SPLINTED) dam -= E.min_broken_damage //If they have a splinted body part, and it's broken, we want to subtract bone break damage.
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)) )
			damaged_organ = E
			maxdam = dam
	if(damaged_organ)
		pain(damaged_organ.display_name, maxdam, 0)


	// Damage to internal organs hurts a lot.
	var/datum/limb/parent
	for(var/datum/internal_organ/I in internal_organs)
		if(I.damage > 2) if(prob(2))
			parent = get_limb(I.parent_limb)
			custom_pain("You feel a sharp pain in your [parent.display_name]!", 1)

	var/toxDamageMessage = null
	var/toxMessageProb = 1
	var/toxin_damage = getToxLoss()
	switch(toxin_damage)
		if(1 to 5)
			toxMessageProb = 1
			toxDamageMessage = "Your body stings slightly."
		if(6 to 10)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts a little."
		if(11 to 15)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts."
		if(15 to 25)
			toxMessageProb = 3
			toxDamageMessage = "Your whole body hurts badly."
		if(26 to INFINITY)
			toxMessageProb = 5
			toxDamageMessage = "Your body aches all over, it's driving you mad!"

	if(toxDamageMessage && prob(toxMessageProb)) custom_pain(toxDamageMessage, toxin_damage >= 35)

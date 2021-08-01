/// Slashes up the target
/datum/smite/bloodless
	name = "Bloodloss"

	var/bloodlossamount

/datum/smite/bloodless/configure(client/user)
	var/static/list/how_fucked_is_this_dude = list("A little", "A lot", "So fucking much", "FUCK THIS DUDE")
	bloodlossamount = input(user, "How much blood should this guy lose?") in how_fucked_is_this_dude

/datum/smite/bloodless/effect(client/user, mob/living/target)
	. = ..()
	if (!ishuman(target))
		to_chat(user, span_warning("Xenomorph blood is protected by the Queen Mother you silly goose. Aborting."), confidential = TRUE)
		return
	to_chat(target, span_userdanger("You feel your skin growing pale as your blood drains away..."), confidential = TRUE)
	switch (bloodlossamount)
		if ("A little")
			target.blood_volume = BLOOD_VOLUME_SAFE
		if ("A lot")
			target.blood_volume = BLOOD_VOLUME_OKAY
		if ("So fucking much")
			target.blood_volume = BLOOD_VOLUME_BAD 
		if ("FUCK THIS DUDE")
			target.blood_volume = BLOOD_VOLUME_SURVIVE 

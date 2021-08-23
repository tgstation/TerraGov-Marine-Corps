#define BLOOD_VOLUME_NOT_IDEAL 450

/// Drains targets blood
/datum/smite/bloodless
	name = "Bloodloss"

/datum/smite/bloodless/effect(client/user, mob/living/target)
	. = ..()

	if (!ishuman(target))
		to_chat(user, span_warning("Xenomorph blood is protected by the Queen Mother you silly goose. Aborting."), confidential = TRUE)
		return

	var/bloodlossamount = tgui_alert(usr, "How much blood should [target] lose?", "Bloodloss amount", list("A little", "A lot", "So fucking much", "FUCK THIS DUDE"))
	to_chat(target, span_userdanger("You feel your skin growing pale as your blood drains away..."), confidential = TRUE)
	
	switch (bloodlossamount)
		if ("A little")
			target.blood_volume = BLOOD_VOLUME_NOT_IDEAL //80% blood
		if ("A lot")
			target.blood_volume = BLOOD_VOLUME_OKAY //60% blood
		if ("So fucking much")
			target.blood_volume = BLOOD_VOLUME_BAD //40% blood
		if ("FUCK THIS DUDE")
			target.blood_volume = BLOOD_VOLUME_SURVIVE //20% blood

#undef BLOOD_VOLUME_NOT_IDEAL

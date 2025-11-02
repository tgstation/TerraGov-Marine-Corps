/mob/living/proc/get_taste_sensitivity()
	return TASTE_NORMAL

/mob/living/carbon/human/get_taste_sensitivity()
	return species.species_flags & IS_SYNTHETIC ? TASTE_DULL : species.taste_sensitivity //Useless right now as they can't eat, so TODO stuff.


// non destructively tastes a reagent container
/mob/proc/taste(datum/reagents/from, type = "chat")
	SHOULD_NOT_SLEEP(TRUE)
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_TASTE))
		return

	// Overwritten when necessary
	var/taste_sensitivity = TASTE_NORMAL
	var/text_output

	// Check if our tasting mob is living or dead.
	if(istype(src, /mob/living))
		var/mob/living/L = src

		// Since for some reason there's two different taste_sensitivity getters
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			taste_sensitivity = H.get_taste_sensitivity()
		else
			taste_sensitivity = L.get_taste_sensitivity()

		text_output = "You can taste [from.generate_taste_message(taste_sensitivity)]."
		TIMER_COOLDOWN_START(src, COOLDOWN_TASTE, 15 SECONDS)

		if(L.hallucination > 50 && prob(25))
			text_output = pick("spiders","dreams","nightmares","the future","the past","victory",\
			"defeat","pain","bliss","revenge","poison","time","space","death","life","truth","lies","justice","memory",\
			"regrets","your soul","suffering","music","noise","blood","hunger","the american way")

	else if(istype(src, /mob/dead))
		text_output = "It tastes like [from.generate_taste_message(taste_sensitivity)]."

	// People on the lobby screen are neither living nor dead
	else
		text_output = "You can taste [from.generate_taste_message(taste_sensitivity)]."
		TIMER_COOLDOWN_START(src, COOLDOWN_TASTE, 1 SECONDS)

	// All the ways we could display this output to the player
	switch(type)

		// For eating normally
		if("chat")
			to_chat(src, span_notice("[text_output]"))

		// For ghosts examining food
		if ("statpanel")
			return text_output

		// For previewing the flavor in the character creator
		if("popup")
			var/datum/browser/popup = new(src, "taste_preview", "<div align='center'>Taste Preview.</div>")
			var/dat = "<div>[text_output]</div>"
			popup.set_content(dat)
			ASYNC
				popup.open()

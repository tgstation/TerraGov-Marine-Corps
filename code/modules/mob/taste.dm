/mob/living/proc/get_taste_sensitivity()
	return TASTE_NORMAL

/mob/living/carbon/human/get_taste_sensitivity()
	return species.species_flags & IS_SYNTHETIC ? TASTE_DULL : species.taste_sensitivity //Useless right now as they can't eat, so TODO stuff.


// non destructively tastes a reagent container
/mob/living/proc/taste(datum/reagents/from)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_TASTE))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_TASTE, 15 SECONDS)

	var/taste_sensitivity = get_taste_sensitivity()
	var/text_output = from.generate_taste_message(taste_sensitivity)
	// We dont want to spam the same message over and over again at the
	// person. Give it a bit of a buffer.
	if(hallucination > 50 && prob(25))
		text_output = pick("spiders","dreams","nightmares","the future","the past","victory",\
		"defeat","pain","bliss","revenge","poison","time","space","death","life","truth","lies","justice","memory",\
		"regrets","your soul","suffering","music","noise","blood","hunger","the american way")
	to_chat(src, span_notice("You can taste [text_output]."))

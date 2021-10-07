/// Fattens the target
/datum/smite/ai_replacement
	name = "Replace by ai"

/datum/smite/ai_replacement/effect(client/user, mob/living/carbon/C)
	. = ..()

	if (!isxeno(C))
		to_chat(user, span_warning("Marines have no ai available, aborting!"))
		return

	var/mob/living/carbon/xenomorph/skill_less_xeno = C
	skill_less_xeno.replace_by_ai()

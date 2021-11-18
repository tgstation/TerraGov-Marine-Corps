/obj/item/implant/chem
	name = "chemical implant"
	desc = "A chemical implant containing a single use chemical cocktail which is added via syringe."
	allow_reagents = TRUE
	flags_implant = ACTIVATE_ON_HEAR|GRANT_ACTIVATION_ACTION
	var/used = FALSE
	var/activation_phrase = "aaaaaa help i dying help maint"

/obj/item/implant/chem/get_data()
	var/list/chems = list()
	for(var/datum/reagent/R AS in reagents.reagent_list)
		chems += "[R.volume] units of [R.name]<BR>"
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotrasen NX-44 ChemBoost Implant<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Upon activation injects a custom chemical mix into the user.<BR>
	<b>Current Chemical composition:</b>
	[chems.len ? jointext(chems, ""): "None!"]
	<b>Integrity:</b> Implant is [used ? "used" : "unused"]."}


/obj/item/implant/chem/on_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(findtext_char(message, activation_phrase))
		activate()

/obj/item/implant/chem/activate(accidental = FALSE)
	. = ..()
	if(!.)
		return
	if(malfunction == MALFUNCTION_PERMANENT)
		return FALSE
	if(used)
		to_chat(implant_owner, span_warning(" WARNING. Implant activation failed; Error code 345: Implant exhausted."))
		return FALSE
	playsound(implant_owner, 'sound/machines/buzz-two.ogg', 60, 1)
	reagents.trans_to(implant_owner, reagents.total_volume)
	used = TRUE

/obj/item/implant/chem/implant(mob/living/carbon/human/target, mob/living/user)
	activation_phrase = stripped_input(user, "Choose activation phrase:")
	if(!activation_phrase)
		return FALSE
	user.mind.store_memory("[src] in [target] will now activate by saying something containing the phrase ''[activation_phrase]'', <B>say [activation_phrase]</B> to attempt to activate.", 0, 0)
	to_chat(user, span_notice("[src] in [target] will now activate by saying something containing the phrase ''[activation_phrase]'', <B>say [activation_phrase]</B> to attempt to activate."))
	return ..()

/obj/item/implant/chem/blood
	name = "blood recovery implant"
	desc = "A chemical implant able to accelerate blood recovery, recovering lost blood."
	///Amount of blood added
	var/blood_amount = 200

/obj/item/implant/chem/blood/activate(accidental)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(implant_owner))
		return FALSE

	var/mob/living/carbon/carb_mob = implant_owner
	var/current_blood = carb_mob.blood_volume
	carb_mob.blood_volume += min(BLOOD_VOLUME_MAXIMUM - current_blood, blood_amount)

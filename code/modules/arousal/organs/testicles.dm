/obj/item/organ/genital/testicles
	name = "testicles"
	desc = "A male reproductive organ."
	icon_state = "testicles"
	icon = 'modular_skyrat/icons/obj/genitals/testicles.dmi'


/datum/internal_organ/genital/testicles
	name = "testicles"
	masturbation_verb = "massage"
	arousal_verb = "Your balls ache a little"
	unarousal_verb = "Your balls finally stop aching, again"
	organ_id = ORGAN_TESTICLES
	linked_organ_slot = "penis"
	genital_flags = CAN_MASTURBATE_WITH|MASTURBATE_LINKED_ORGAN|GENITAL_FLUID_PRODUCTION|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN
	size = BALLS_SIZE_MIN
	shape = DEF_BALLS_SHAPE
	fluid_id = /datum/reagent/consumable/semen

	var/size_name = "average"

/datum/internal_organ/genital/testicles/upon_link()
	size = linked_organ.size
	update_size()
	update_appearance()

/datum/internal_organ/genital/testicles/update_size()
	switch(size)
		if(BALLS_SIZE_MIN)
			size_name = "average"
		if(BALLS_SIZE_DEF)
			size_name = "enlarged"
		if(BALLS_SIZE_MAX)
			size_name = "engorged"
		else
			size_name = "nonexistant"

/datum/internal_organ/genital/testicles/genital_examine(mob/user)
	return "<span class='notice'>You see an [size_name] pair of testicles.</span>"

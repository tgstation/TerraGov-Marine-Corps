/obj/item/organ/brain
	name = "brain"
	max_integrity = 400 //They need to live awhile longer than other organs.
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain2"
	flags_atom = NONE
	force = 1.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacked", "slapped", "whacked")
	organ_type = /datum/internal_organ/brain
	organ_tag = "brain"

	var/mob/living/brain/brainmob = null

/obj/item/organ/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"


/obj/item/organ/brain/proc/transfer_identity(mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, span_notice("You feel slightly disoriented. That's normal when you're just a brain."))

/obj/item/organ/brain/examine(mob/user)
	. = ..()
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		. += "You can feel the small spark of life still left in this one."
	else
		. += "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/brain/removed(mob/living/target,mob/living/user)
	..()
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/brain/B = src
	if(istype(B) && istype(H))
		B.transfer_identity(target)

/obj/item/organ/brain/replaced(mob/living/target)

	if(target.key)
		target.ghostize()

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(target)
		else
			target.key = brainmob.key

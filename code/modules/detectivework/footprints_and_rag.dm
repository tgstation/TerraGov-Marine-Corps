/mob
	var/bloody_hands = 0
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/track_blood_type
	var/feet_blood_color

/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/clothing/shoes
	var/track_blood = 0

/obj/item/reagent_container/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 5
	flags_item = NOBLUDGEON

/obj/item/reagent_container/glass/rag/attack_self(mob/user)
	return

/obj/item/reagent_container/glass/rag/afterattack(atom/A as obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(iscarbon(A) && A.reagents && reagents.total_volume)
		var/mob/living/carbon/C = A
		var/reagentlist = pretty_string_from_reagent_list(reagents)
		var/log_object = "a damp rag containing [reagentlist]"
		if(user.a_intent == INTENT_HARM && !C.is_mouth_covered(check_limb = TRUE))
			reagents.reaction(C, INGEST)
			reagents.trans_to(C, reagents.total_volume)
			C.visible_message("<span class='danger'>[user] has smothered [C] with [src]!</span>", "<span class='danger'>[user] has smothered you with \the [src]!</span>", "<span class='italics'>You hear some struggling and muffled cries of surprise.</span>")
			log_combat(user, C, "smothered", log_object)
		else
			reagents.reaction(C, TOUCH)
			reagents.clear_reagents()
			C.visible_message("<span class='notice'>[user] has touched [C] with [src].</span>")
			log_combat(user, C, "touched", log_object)

	else if(istype(A) && src in user)
		user.visible_message("[user] starts to wipe down [A] with [src]!", "<span class='notice'>You start to wipe down [A] with [src]...</span>")
		if(do_after(user,30, TRUE, 5, BUSY_ICON_GENERIC))
			user.visible_message("[user] finishes wiping off [A]!", "<span class='notice'>You finish wiping off [A].</span>")
			A.clean_blood()
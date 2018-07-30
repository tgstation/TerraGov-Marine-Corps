/mob
	var/bloody_hands = 0
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/track_blood_type
	var/feet_blood_color

/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/clothing/shoes/
	var/track_blood = 0

/obj/item/reagent_container/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null
	flags_atom = FPRINT|OPENCONTAINER
	flags_item = NOBLUDGEON

/obj/item/reagent_container/glass/rag/attack_self(mob/user as mob)
	return

/obj/item/reagent_container/glass/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("\red \The [target] has been smothered with \the [src] by \the [user]!", "\red You smother \the [target] with \the [src]!", "You hear some struggling and muffled cries of surprise")
		src.reagents.reaction(target, TOUCH)
		spawn(5) src.reagents.clear_reagents()
		return
	else
		..()

/obj/item/reagent_container/glass/rag/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A) && src in user)
		user.visible_message("[user] starts to wipe down [A] with [src]!")
		if(do_after(user,30, TRUE, 5, BUSY_ICON_GENERIC))
			user.visible_message("[user] finishes wiping off the [A]!")
			A.clean_blood()
	return

/obj/item/reagent_container/glass/rag/examine(mob/user)
	user << "That's \a [src]."
	user << desc

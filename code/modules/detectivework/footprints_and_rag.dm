/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/clothing/shoes/
	var/track_blood = 0

/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	flags_item = NOBLUDGEON

/obj/item/reagent_containers/glass/rag/attack_self(mob/user as mob)
	return

/obj/item/reagent_containers/glass/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("<span class='warning'> \The [target] has been smothered with \the [src] by \the [user]!</span>", "<span class='warning'> You smother \the [target] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
		src.reagents.reaction(target, TOUCH)
		addtimer(CALLBACK(reagents, /datum/reagents.proc/clear_reagents), 5)
		return
	else
		..()

/obj/item/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A) && (src in user))
		user.visible_message("[user] starts to wipe down [A] with [src]!")
		if(do_after(user,30, TRUE, A, , BUSY_ICON_GENERIC))
			user.visible_message("[user] finishes wiping off the [A]!")
			A.clean_blood()
	return

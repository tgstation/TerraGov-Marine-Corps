/obj/structure/paper_bin
	name = "paper bin"
	icon = 'icons/obj/items/paper.dmi'
	density = FALSE
	anchored = FALSE
	icon_state = "paper_bin1"
	layer = LOWER_ITEM_LAYER
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = list()	//List of papers put in the bin for reference.


/obj/structure/paper_bin/MouseDrop(atom/over_object)
	if(over_object == usr && ishuman(usr) && !usr.restrained() && !usr.stat && (loc == usr || in_range(src, usr)))
		if(!usr.get_active_held_item())		//if active hand is empty
			attack_hand(usr, 1, 1)

	return


/obj/structure/paper_bin/attack_paw(mob/living/carbon/monkey/user)
	return attack_hand(user)


/obj/structure/paper_bin/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/response = ""
	if(!length(papers))
		response = alert(user, "Do you take regular paper, or Carbon copy paper?", "Paper type request", "Regular", "Carbon-Copy", "Cancel")
		if(response != "Regular" && response != "Carbon-Copy")
			return
	
	if(amount < 1)
		to_chat(user, "<span class='notice'>[src] is empty!</span>")
		return
	
	amount--
	update_icon()

	var/obj/item/paper/P
	if(length(papers))	//If there's any custom paper on the stack, use that instead of creating a new paper.
		P = papers[length(papers)]
		papers -= P
	else if(response == "Regular")
		P = new /obj/item/paper
	else if(response == "Carbon-Copy")
		P = new /obj/item/paper/carbon

	P.forceMove(user.loc)
	user.put_in_hands(P)
	to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")


/obj/structure/paper_bin/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper))
		if(!user.transferItemToLoc(I, src))
			return

		to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		LAZYADD(papers, I)
		amount++


/obj/structure/paper_bin/examine(mob/user)
	. = ..()
	if(amount)
		to_chat(user, "<span class='notice'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>")
	else
		to_chat(user, "<span class='notice'>There are no papers in the bin.</span>")


/obj/structure/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"

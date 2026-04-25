/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	anchored = TRUE


/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/items/paper.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/books_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/books_right.dmi',
	)
	icon_state = "newspaper"
	w_class = WEIGHT_CLASS_TINY	//Let's make it fit in trashbags!
	attack_verb = list("baps")

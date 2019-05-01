/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/suit

/obj/item/clothing/suit/storage/Initialize()
	. = ..()
	pockets = new pockets(src)

/obj/item/clothing/suit/storage/attack_hand(mob/user)
	if(pockets.handle_attack_hand(user))
		return ..(user)

/obj/item/clothing/suit/storage/MouseDrop(obj/over_object)
	if(pockets.handle_mousedrop(usr, over_object))
		return ..(over_object)

/obj/item/clothing/suit/storage/attackby(obj/item/W, mob/user)
	. = ..()
	return pockets.attackby(W, user)

/obj/item/clothing/suit/storage/emp_act(severity)
	pockets.emp_act(severity)
	return ..()

/obj/item/storage/internal/suit
	storage_slots = 2	//two slots
	max_w_class = 2		//fit only small items
	max_storage_space = 4

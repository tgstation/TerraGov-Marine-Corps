/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	storage_slots = 10
	icon_state = "wallet"
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/toy/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/tool/lighter,
		/obj/item/tool/match,
		/obj/item/paper,
		/obj/item/tool/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/tool/screwdriver,
		/obj/item/tool/stamp,
	)
	flags_equip_slot = ITEM_SLOT_ID

	///The front-most ID in this wallet; used in update_icon
	var/obj/item/card/id/front_id = null

/obj/item/storage/wallet/random
	spawns_prob = list(
		list(100, /obj/item/spacecash/c10,/obj/item/spacecash/c100,/obj/item/spacecash/c20,/obj/item/spacecash/c200,/obj/item/spacecash/c50, /obj/item/spacecash/c500),
		list(75, /obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/gold, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/iron),
		list(50, /obj/item/spacecash/c10,/obj/item/spacecash/c100,/obj/item/spacecash/c20,/obj/item/spacecash/c200,/obj/item/spacecash/c50, /obj/item/spacecash/c500),
	)

/obj/item/storage/wallet/remove_from_storage(obj/item/removed, atom/new_location)
	. = ..()
	if(. && removed == front_id)
		update_frontid(null)

/obj/item/storage/wallet/handle_item_insertion(obj/item/inserted)
	. = ..()
	if(. && isidcard(inserted))
		update_frontid(inserted)

///Updates the name of the wallet based on the provided idcard. Will always call update_icon
/obj/item/storage/wallet/proc/update_frontid(obj/item/card/id/idcard)
	if(!idcard)
		front_id = null
		name = initial(name)
	else
		front_id = idcard
		name = "[name] ([front_id])"

	update_icon()

/obj/item/storage/wallet/update_icon()
	if(front_id)
		icon_state = "[initial(icon_state)]id_[front_id.icon_state]"
		return
	icon_state = "wallet"

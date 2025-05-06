/datum/storage/wallet
	storage_slots = 10

/datum/storage/wallet/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
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
	))

/datum/storage/wallet/remove_from_storage(obj/item/item, atom/new_location, mob/user, silent = FALSE, bypass_delay = FALSE)
	. = ..()
	var/obj/item/storage/wallet/parent_wallet = parent
	if(item == parent_wallet.front_id)
		parent_wallet.front_id = null
		parent_wallet.name = initial(parent_wallet.name)
		parent_wallet.update_icon()

/datum/storage/wallet/handle_item_insertion(obj/item/item, prevent_warning = 0, mob/user)
	. = ..()
	var/obj/item/storage/wallet/parent_wallet = parent
	if(!parent_wallet.front_id && istype(item, /obj/item/card/id))
		parent_wallet.front_id = item
		parent_wallet.name = "[parent_wallet.name] ([parent_wallet.front_id])"
		parent_wallet.update_icon()

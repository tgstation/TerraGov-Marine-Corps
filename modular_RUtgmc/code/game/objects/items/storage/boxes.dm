/obj/item/storage/box/t500case
	name = "\improper R-500 special case"
	desc = "High-tech case made by BMSS for delivery their special weapons. Label on this case says: 'This is the greatest handgun ever made. Five bullets. More than enough to kill anything that moves'."
	icon = 'modular_RUtgmc/icons/obj/items/storage/storage.dmi'
	icon_state = "case"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = 1
	storage_slots = 5
	max_storage_space = 1
	can_hold = list(
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/lace/t500,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/weapon/gun/revolver/t500,
	)
	bypass_w_limit = list(
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/lace/t500,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/weapon/gun/revolver/t500,
	)

/obj/item/storage/box/t500case/Initialize()
	. = ..()
	new /obj/item/attachable/stock/t500stock(src)
	new /obj/item/attachable/lace/t500(src)
	new /obj/item/attachable/t500barrelshort(src)
	new /obj/item/attachable/t500barrel(src)
	new /obj/item/weapon/gun/revolver/t500(src)

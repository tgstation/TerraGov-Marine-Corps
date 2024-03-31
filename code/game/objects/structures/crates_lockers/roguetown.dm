/obj/structure/closet/crate/chest
	name = "chest"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "chestweird2"
	base_icon_state = "chestweird2"
	drag_slowdown = 2
	open_sound = 'sound/misc/chestopen.ogg'
	close_sound = 'sound/misc/chestclose.ogg'
	keylock = TRUE
	locked = FALSE
	sellprice = 1
	max_integrity = 200
	blade_dulling = DULLING_BASHCHOP
	mob_storage_capacity = 1
	allow_dense = FALSE

/obj/structure/closet/crate/chest/gold
	icon_state = "chestweird1"
	base_icon_state = "chestweird1"

//obj/structure/closet/crate/chest/Initialize(mapload)
//	. = ..()
//	base_icon_state = "chestweird2"
//	update_icon()

/obj/structure/closet/crate/chest/merchant
	lockid = "shop"
	locked = TRUE
	masterkey = TRUE

/obj/structure/closet/crate/chest/lootbox/PopulateContents()
	var/list/loot = list(/obj/item/cooking/pan=33,
		/obj/item/bomb=6,
		/obj/item/rogueweapon/huntingknife/idagger=33,
		/obj/item/clothing/suit/roguetown/armor/gambeson=33,
		/obj/item/clothing/suit/roguetown/armor/leather=33,
		/obj/item/roguestatue/gold/loot=1,
		/obj/item/ingot/iron=22,
		/obj/item/rogueweapon/huntingknife/cleaver=22,
		/obj/item/rogueweapon/mace=22,
		/obj/item/clothing/cloak/raincloak/mortus=22,
		/obj/item/reagent_containers/food/snacks/butter=22,
		/obj/item/clothing/mask/cigarette/pipe=10,
		/obj/item/clothing/mask/cigarette/pipe/westman=10,
		/obj/item/storage/box/matches=33,
		/obj/item/storage/backpack/rogue/satchel=33,
		/obj/item/storage/roguebag=33,
		/obj/item/roguegem=1,
		/obj/item/roguegem/blue=2,
		/obj/item/roguegem/violet=4,
		/obj/item/roguegem/green=6,
		/obj/item/roguegem/yellow=10,
		/obj/item/roguecoin/silver/pile=4,
		/obj/item/rogueweapon/pick=23,
		/obj/item/riddleofsteel=2,
		/obj/item/clothing/neck/roguetown/talkstone=2)
	if(prob(70))
		var/I = pickweight(loot)
		new I(src)

/obj/structure/closet/crate/roguecloset
	name = "closet"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	base_icon_state = "closet"
	icon_state = "closet"
	drag_slowdown = 4
	horizontal = FALSE
	allow_dense = FALSE
	open_sound = 'sound/foley/doors/creak.ogg'
	close_sound = 'sound/foley/latch.ogg'
	max_integrity = 200
	blade_dulling = DULLING_BASHCHOP
	dense_when_open = FALSE
	mob_storage_capacity = 2

/obj/structure/closet/crate/roguecloset/inn/south
	base_icon_state = "closet3"
	icon_state = "closet3"
	dir = SOUTH
	pixel_y = 16

/obj/structure/closet/crate/roguecloset/inn
	base_icon_state = "closet3"
	icon_state = "closet3"

/obj/structure/closet/crate/roguecloset/inn/chest
	base_icon_state = "woodchest"
	icon_state = "woodchest"

/obj/structure/closet/crate/roguecloset/dark
	base_icon_state = "closetdark"
	icon_state = "closetdark"

/obj/structure/closet/crate/roguecloset/lord
	keylock = TRUE
	lockid = "lord"
	locked = TRUE
	base_icon_state = "closetlord"
	icon_state = "closetlord"

/obj/structure/closet/crate/drawer
	name = "drawer"
	desc = "a wooden drawer."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "drawer5"
	base_icon_state = "drawer5"
	drag_slowdown = 2
	open_sound = 'sound/misc/chestopen.ogg'
	close_sound = 'sound/misc/chestclose.ogg'
	keylock = FALSE
	locked = FALSE
	sellprice = 1
	max_integrity = 50
	blade_dulling = DULLING_BASHCHOP
	mob_storage_capacity = 1
	allow_dense = FALSE

/obj/structure/closet/crate/drawer/inn
	name = "drawer"
	desc = "a wooden drawer."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "drawer5"
	base_icon_state = "drawer5"
	dir = SOUTH
	pixel_y = 16

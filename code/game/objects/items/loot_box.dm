/obj/item/loot_box
	name = "Loot box"
	desc = "A box of loot, what could be inside?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox"
	item_state = "lootbox"
	///list of the lowest probability drops
	var/list/legendary_list
	///list of rare propability drops
	var/list/rare_list
	///list of uncommon drops
	var/list/uncommon_list
	///list of common drops
	var/list/common_list
	///the odds of each loot category being picked
	var/list/weight_list = list(legendary_list = 10, rare_list = 20, uncommon_list = 30, common_list = 40)

/obj/item/loot_box/ex_act()
	qdel(src)

/obj/item/loot_box/attack_self(mob/user)
	var/obj/loot_pick
	switch(pickweight(weight_list))
		if("legendary_list")
			loot_pick = pick(legendary_list)
		if("rare_list")
			loot_pick = pick(rare_list)
		if("uncommon_list")
			loot_pick = pick(uncommon_list)
		if("common_list")
			loot_pick = pick(common_list)
	loot_pick = new loot_pick(get_turf(user))
	if(isitem(loot_pick))
		user.put_in_hands(loot_pick)
	user.visible_message("[user] pulled a [loot_pick.name] out of the [src]!")
	qdel(src)

/obj/item/loot_box/marine
	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
	)
	rare_list = list(
		/obj/vehicle/unmanned,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/weapon/gun/minigun,
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/weapon/gun/rifle/railgun,
		/obj/item/weapon/gun/rifle/standard_autosniper,
		/obj/item/weapon/gun/shotgun/zx76,
		/obj/item/storage/belt/champion,
	)
	uncommon_list = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/storage/fancy/crayons,
		/obj/item/weapon/claymore,
		/obj/vehicle/ridden/motorbike,
		/obj/item/weapon/gun/launcher/rocket/oneuse,
		/obj/item/weapon/gun/rifle/m412l1_hpr,
		/obj/item/weapon/gun/shotgun/som,
		/obj/item/loot_box/marine, //reroll time
	)
	common_list = list(
		/obj/item/clothing/head/strawhat,
		/obj/item/storage/bag/trash,
		/obj/item/toy/bikehorn,
		/obj/item/clothing/tie/horrible,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/banhammer,
	)

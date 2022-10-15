/obj/item/loot_box
	name = "Loot box"
	desc = "A box of loot, what could be inside?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox"
	item_state = "lootbox"
	var/list/legendary_list
	var/list/rare_list
	var/list/uncommon_list
	var/list/common_list
	var/list/weights = list(10, 20, 30, 40)

/obj/item/loot_box/ex_act()
	qdel(src)

/obj/item/loot_box/attack_self(mob/user)
	var/list/choices = list(legendary_list, rare_list, uncommon_list, common_list)
	var/loot_class = weightedprob(choices, weights)
	var/loot_pick = pick(loot_class)
	loot_pick = new loot_pick(loc)
	if(isitem)
		user.put_in_hands(loot_pick)
	user.visible_message("[user] pulled a [attached_item] out of the [src]!")
	qdel(src)

/obj/item/loot_box/proc/weightedprob(choices[], weights[])
	if(!choices || !weights)
		return null

    //Build a range of weights
	var/max_num = 0
	for(var/X in weights)
		if(isnum(X))
			max_num += X

    //Now roll in the range.
	var/weighted_num = rand(1,max_num)
	var/running_total, i
	//Loop through all possible choices
	for(i = 1; i <= choices.len; i++)
		if(i > weights.len)
			return null
		running_total += weights[i]
		//Once the current step is less than the roll, we have our winner.
		if(weighted_num <= running_total)
			return choices[i]

/obj/item/loot_box/marine
	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
	)
	rare_list = list(
		/obj/vehicle/ridden/motorbike,
		/obj/vehicle/unmanned,
		/obj/item/storage/belt/champion,
	)
	uncommon_list = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/storage/fancy/crayons,
		/obj/item/weapon/claymore,
		/obj/item/tool/soap/deluxe,
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

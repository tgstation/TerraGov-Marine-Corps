/obj/item/storage/pill_bottle/dice
	name = "pack of dice"
	desc = "It's a small container with dice inside."

/obj/item/storage/pill_bottle/dice/PopulateContents()
	new /obj/item/toy/dice(src)
	new /obj/item/toy/dice/d20(src)

/*
* Donut Box
*/

/obj/item/storage/donut_box
	icon = 'icons/obj/items/food/donuts.dmi'
	icon_state = "donutbox"
	name = "\improper Yum! donuts"
	desc = "A box of mouth watering \"<i>Yum!</i>\" brand donuts."
	///How many items spawn in src
	var/startswith = 6
	var/open = 0

/obj/item/storage/donut_box/Initialize(mapload)
	. = ..()
	storage_datum.set_holdable(can_hold_list = list(/obj/item/reagent_containers/food/snacks/donut))
	storage_datum.foldable = /obj/item/stack/sheet/cardboard
	storage_datum.storage_slots = 6

/obj/item/storage/donut_box/PopulateContents()
	for(var/i in 1 to startswith)
		new /obj/item/reagent_containers/food/snacks/donut/normal(src)
	update_icon()


/obj/item/storage/donut_box/attack_self(mob/user as mob)
	to_chat(user, "You [open ? "close [src]. Another time, then." : "open [src]. Mmmmm... donuts."]")
	open = !open
	update_icon()
	if(!length(contents))
		return ..()

/obj/item/storage/donut_box/update_icon_state()
	. = ..()
	if(!open)
		icon_state = "donutbox"
		return
	icon_state = "donutbox_o"

/obj/item/storage/donut_box/update_overlays()
	. = ..()
	if(!open)
		return
	var/i = 0
	for(var/obj/item/reagent_containers/food/snacks/donut/D in contents)
		i++
		var/image/img = image('icons/obj/items/food/donuts.dmi', "[D.overlay_state]-[i]")
		. += img // wtf

/obj/item/storage/donut_box/empty
	icon_state = "donutbox_o"
	startswith = 0

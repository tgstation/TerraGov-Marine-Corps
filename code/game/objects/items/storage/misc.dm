/obj/item/storage/pill_bottle/dice
	name = "pack of dice"
	desc = "It's a small container with dice inside."

/obj/item/storage/pill_bottle/dice/Initialize()
	. = ..()
	new /obj/item/toy/dice( src )
	new /obj/item/toy/dice/d20( src )

/*
* Donut Box
*/

/obj/item/storage/donut_box
	icon = 'icons/obj/items/food.dmi'
	icon_state = "donutbox"
	name = "\improper Yum! donuts"
	desc = "A box of mouth watering \"<i>Yum!</i>\" brand donuts."
	storage_slots = 6
	var/startswith = 6
	var/open = 0
	can_hold = list(/obj/item/reagent_containers/food/snacks/donut)
	foldable = /obj/item/stack/sheet/cardboard

/obj/item/storage/donut_box/Initialize()
	. = ..()
	for(var/i in 1 to startswith)
		new /obj/item/reagent_containers/food/snacks/donut/normal(src)
	update_icon()


/obj/item/storage/donut_box/attack_self(mob/user as mob)
	to_chat(user, "You [open ? "close [src]. Another time, then." : "open [src]. Mmmmm... donuts."]")
	open = !open
	update_icon()
	if(!contents.len)
		return ..()


/obj/item/storage/donut_box/update_icon()
	overlays.Cut()
	if(!open)
		icon_state = "donutbox"
		return
	icon_state = "donutbox_o"
	var/i = 0
	for(var/obj/item/reagent_containers/food/snacks/donut/D in contents)
		i++
		var/image/img = image('icons/obj/items/food.dmi', "[D.overlay_state]-[i]")
		overlays += img

/obj/item/storage/donut_box/empty
	icon_state = "donutbox_o"
	startswith = 0

/obj/item/storage/pill_bottle/dice
	name = "pack of dice"
	desc = "It's a small container with dice inside."

	New()
		..()
		new /obj/item/toy/dice( src )
		new /obj/item/toy/dice/d20( src )

/*
 * Donut Box
 */

/obj/item/storage/donut_box
	icon = 'icons/obj/items/food.dmi'
	icon_state = "donutbox"
	name = "donut box"
	storage_slots = 6
	var/startswith = 6
	can_hold = list("/obj/item/reagent_container/food/snacks/donut")
	foldable = /obj/item/stack/sheet/cardboard

/obj/item/storage/donut_box/New()
	..()
	for(var/i=1; i <= startswith; i++)
		new /obj/item/reagent_container/food/snacks/donut/normal(src)
	update_icon()
	return

/obj/item/storage/donut_box/update_icon()
	overlays.Cut()
	var/i = 0
	for(var/obj/item/reagent_container/food/snacks/donut/D in contents)
		var/image/img = image('icons/obj/items/food.dmi', D.overlay_state)
		img.pixel_x = i * 3
		overlays += img
		i++

/obj/item/storage/donut_box/empty
	icon_state = "donutbox0"
	startswith = 0

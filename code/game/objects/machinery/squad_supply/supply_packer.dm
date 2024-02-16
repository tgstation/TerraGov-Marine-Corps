/obj/structure/largecrate/packed
	name = "supplies crate"
	icon_state = "secure_crate"
	// This will contain all the item names inside the packed crate
	var/list/manifest = list("This crate contains:")
	//black list for anything under /obj/item that you dont want to be packable
	var/static/list/black_list = typecacheof(list())
	// while packing the entire FOB into a single crate would be funny propably not great idea
	var/max_items = 30

/obj/structure/largecrate/packed/Initialize(mapload)
	. = ..()
	pack()

/obj/structure/largecrate/packed/examine()
	. = ..()
	for(var/item in manifest)
		. += span_boldnotice(item)

/obj/structure/largecrate/packed/proc/pack()
	var/count = 0
	for(var/obj/item/thing in loc)
		if(is_type_in_typecache(thing,black_list))
			continue
		if(thing.anchored)
			continue
		thing.forceMove(src)
		manifest += thing.name
		count++
		if(count >= max_items)
			return

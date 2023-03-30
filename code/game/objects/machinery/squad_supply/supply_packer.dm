/obj/structure/largecrate/packed
	name = "supplies crate"
	icon_state = "secure_crate"
	var/list/manifest = list("This crate contains:")
	var/static/list/black_list = typecacheof(list(/obj/structure))
	var/max_items = 30 // while packing the entire FOB into a single crate would be funny propably not great idea

/obj/structure/largecrate/packed/Initialize()
	. = ..()
	pack()

/obj/structure/largecrate/packed/examine()
	. = ..()
	for(var/item in manifest)
		. += span_boldnotice(item)

/obj/structure/largecrate/packed/proc/pack()
	var/count = 0
	for(var/obj/thing in loc)
		if(count >= max_items)
			return
		if(is_type_in_typecache(thing,black_list))
			continue
		thing.forceMove(src)
		manifest += thing.name
		count++

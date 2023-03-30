/obj/structure/largecrate/packed
	name = "supplies crate"
	icon_state = "secure_crate"
	var/list/manifest = list("This crate contains:")
	var/static/list/black_list = typecacheof(list(/obj/structure))

/obj/structure/largecrate/packed/Initialize()
	. = ..()
	pack()

/obj/structure/largecrate/packed/examine()
	. = ..()
	for(var/item in manifest)
		. += span_notice(item)

/obj/structure/largecrate/packed/proc/pack()
	for(var/obj/thing in loc)
		if(is_type_in_typecache(thing,black_list))
			continue
		thing.forceMove(src)
		manifest += thing.name

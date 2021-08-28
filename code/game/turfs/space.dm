/turf/open/space
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	can_bloody = FALSE
	light_power = 0.25


/turf/open/space/basic/New()	//Do not convert to Initialize
	//This is used to optimize the map loader
	return


// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE)

/turf/open/space/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(FALSE) //prevent laggies
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	ENABLE_BITFIELD(flags_atom, INITIALIZED)

	vis_contents.Cut() //removes inherited overlays
	visibilityChanged()

	if(light_system != MOVABLE_LIGHT && light_power && light_range)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	update_icon()

	return INITIALIZE_HINT_NORMAL


/turf/open/space/update_icon_state()
	icon_state = SPACE_ICON_STATE


/turf/open/space/attack_paw(mob/living/carbon/human/user)
	return src.attack_hand(user)

/turf/open/space/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in src
		if(L)
			return
		var/obj/item/stack/rods/R = I
		if(!R.use(1))
			return

		to_chat(user, span_notice("Constructing support lattice ..."))
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		ReplaceWithLattice()

	else if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in src
		if(!L)
			to_chat(user, span_warning("The plating is going to need some support."))
			return

		var/obj/item/stack/tile/plasteel/S = I
		if(S.get_amount() < 1)
			return
		qdel(L)
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		S.build(src)
		S.use(1)


/turf/open/space/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		to_chat(arrived, span_danger("The cold vacuum instantly freezes you, maybe this was a bad idea?"))
		var/mob/living/spaceman = arrived
		spaceman.adjustFireLoss(600) //Death. Space shouldn't be entered.


/turf/open/space/sea //used on prison for flavor
	icon = 'icons/misc/beach.dmi'
	name = "sea"
	icon_state = "seadeep"
	plane = FLOOR_PLANE

/turf/open/space/sea/update_icon_state()
	return

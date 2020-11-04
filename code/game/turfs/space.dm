/turf/open/space
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	can_bloody = FALSE
	light_power = 0.25
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED


/turf/open/space/basic/New()	//Do not convert to Initialize
	//This is used to optimize the map loader
	return


// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE)

/turf/open/space/Initialize(mapload, ...)
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	ENABLE_BITFIELD(flags_atom, INITIALIZED)

	vis_contents.Cut() //removes inherited overlays
	visibilityChanged()

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE
	
	update_icon()

	return INITIALIZE_HINT_NORMAL


/turf/open/space/update_icon_state()
	icon_state = SPACE_ICON_STATE


/turf/open/space/attack_paw(mob/living/carbon/monkey/user)
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

		to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		ReplaceWithLattice()

	else if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in src
		if(!L)
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
			return

		var/obj/item/stack/tile/plasteel/S = I
		if(S.get_amount() < 1)
			return
		qdel(L)
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		S.build(src)
		S.use(1)


/turf/open/space/Entered(atom/movable/AM, atom/oldloc)
	. = ..()
	if(isliving(AM))
		var/mob/living/spaceman = AM
		spaceman.adjustFireLoss(600) //Death. Space shouldn't be entered.

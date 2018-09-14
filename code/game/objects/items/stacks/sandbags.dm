

//Empty sandbags
/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best to fill them up if you want to use them."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_stack"
	w_class = 3.0
	force = 2
	throwforce = 0
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	stack_id = "empty sandbags"

/obj/item/stack/sandbags_empty/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/tool/shovel))
		var/obj/item/tool/shovel/ET = W
		if(ET.dirt_amt)
			ET.dirt_amt -= 1
			ET.update_icon()
			var/obj/item/stack/sandbags/new_bags = new(user.loc)
			new_bags.add_to_stacks(user)
			var/obj/item/stack/sandbags_empty/E = src
			src = null
			var/replace = (user.get_inactive_hand() == E)
			playsound(user.loc, "rustle", 30, 1, 6)
			E.use(1)
			if(!E && replace)
				user.put_in_hands(new_bags)

	else if (istype(W, /obj/item/stack/snow))
		var/obj/item/stack/S = W
		var/obj/item/stack/sandbags/new_bags = new(user.loc)
		new_bags.add_to_stacks(user)
		S.use(1)
		use(1)
	else
		return ..()


//half a max stack
/obj/item/stack/sandbags_empty/half
	amount = 25

//max stack
/obj/item/stack/sandbags_empty/full
	amount = 50

//Full sandbags
/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags filled with sand. For now, just cumbersome, but soon to be used for fortifications."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_pile"
	w_class = 4.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hit", "bludgeoned", "whacked")
	stack_id = "sandbags"

/obj/item/stack/sandbags/large_stack
	amount = 25

/obj/item/stack/sandbags/attack_self(mob/living/user)
	add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(user.loc),/area/sulaco/hangar))  //HANGAR BUILDING
		to_chat(user, "<span class='warning'>No. This area is needed for the dropships and personnel.</span>")
		return

	if(!istype(user.loc, /turf/open))
		var/turf/open/OT = user.loc
		if(!OT.allow_construction)
			to_chat(user, "<span class='warning'>The sandbag barricade must be constructed on a proper surface!</span>")
			return

	//Using same safeties as other constructions
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density)
			if(O.flags_atom & ON_BORDER)
				if(O.dir == user.dir)
					to_chat(user, "<span class='warning'>There is already \a [O.name] in this direction!</span>")
					return
			else
				to_chat(user, "<span class='warning'>You need a clear, open area to build the sandbag barricade!</span>")
				return

	if(user.action_busy)
		return
	if(amount < 5)
		to_chat(user, "<span class='warning'>You need at least five [name] to do this.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts assembling a sandbag barricade.</span>",
	"<span class='notice'>You start assembling a sandbag barricade.</span>")

	if(!do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
		return
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density)
			if(!(O.flags_atom & ON_BORDER) || O.dir == user.dir)
				return
	var/obj/structure/barricade/sandbags/SB = new(user.loc, user.dir)
	user.visible_message("<span class='notice'>[user] assembles a sandbag barricade.</span>",
	"<span class='notice'>You assemble a sandbag barricade.</span>")
	SB.dir = user.dir
	SB.add_fingerprint(user)
	use(5)

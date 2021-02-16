


/obj/item/stack/snow
	name = "snow pile"
	desc = "Some snow pile."
	singular_name = "layer"
	icon_state = "snow_stack"
	w_class = WEIGHT_CLASS_HUGE
	force = 2
	throw_speed = 5
	throw_range = 1
	max_amount = 25


/obj/item/stack/snow/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/shovel))
		var/obj/item/tool/shovel/ET = I
		if(!isturf(loc))
			return

		if(ET.dirt_amt && ET.dirt_type == DIRT_TYPE_SNOW)
			if(amount < max_amount + ET.dirt_amt)
				amount += ET.dirt_amt
			else
				new /obj/item/stack/snow(loc, ET.dirt_amt)
			ET.dirt_amt = 0
			ET.update_icon()
			return

		to_chat(user, "<span class='notice'>You start taking snow from [src].</span>")
		playsound(user.loc, 'sound/effects/thud.ogg', 40, 1, 6)

		if(!do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
			return

		var/transf_amt = ET.dirt_amt_per_dig
		if(amount < ET.dirt_amt_per_dig)
			transf_amt = amount

		ET.dirt_amt = transf_amt
		ET.dirt_type = DIRT_TYPE_SNOW
		to_chat(user, "<span class='notice'>You take snow from [src].</span>")
		ET.update_icon()
		use(transf_amt)
		return TRUE


/obj/item/stack/snow/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(isopenturf(target))
		if(user.do_actions)
			return
		var/turf/open/T = target
		if(T.get_dirt_type() == DIRT_TYPE_SNOW)
			if(T.slayer >= 3)
				to_chat(user, "This ground is already full of snow.")
				return
			to_chat(user, "You start putting some snow back on the ground.")
			if(!do_after(user, 15, FALSE, target, BUSY_ICON_BUILD))
				return
			if(T.slayer >= 3)
				return
			to_chat(user, "You put a new snow layer on the ground.")
			T.slayer += 1
			T.update_icon(TRUE, FALSE)
			use(1)

/obj/item/stack/snow/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(T.get_dirt_type() != DIRT_TYPE_SNOW)
		to_chat(user, "<span class='warning'>You can't build a snow barricade at this location!</span>")
		return

	if(user.do_actions)
		return

	if(amount < 3)
		to_chat(user, "<span class='warning'>You need 3 layers of snow to build a barricade.</span>")
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

	user.visible_message("<span class='notice'>[user] starts assembling a snow barricade.</span>",
	"<span class='notice'>You start assembling a snow barricade.</span>")
	if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
		return
	if(amount < 3)
		return
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density)
			if(!(O.flags_atom & ON_BORDER) || O.dir == user.dir)
				return
	var/obj/structure/barricade/snow/SB = new(user.loc, user.dir)
	user.visible_message("<span class='notice'>[user] assembles a snow barricade.</span>",
	"<span class='notice'>You assemble a snow barricade.</span>")
	SB.setDir(user.dir)
	use(3)


/obj/item/stack/barbed_wire
	name = "barbed wire"
	desc = "A spiky length of wire."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "barbed_wire"
	flags_item = NOBLUDGEON
	singular_name = "length"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 5
	throw_speed = 5
	throw_range = 20
	attack_verb = list("hit", "whacked", "sliced")
	max_amount = 20
	merge_type = /obj/item/stack/barbed_wire

//small stack
/obj/item/stack/barbed_wire/small_stack
	amount = 5

//half stack
/obj/item/stack/barbed_wire/half_stack
	amount = 10

//full stack
/obj/item/stack/barbed_wire/full
	amount = 20

/obj/item/stack/barbed_wire/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/stack/rods))
		return

	var/obj/item/stack/rods/R = I
	if(R.amount < 8)
		to_chat(user, span_warning("You need [8 - R.amount] more [R] to make a razor wire obstacle!"))
		return
	if(amount < 2)
		to_chat(user, span_warning("You need at least [2 - amount] more [src] to make razorwire obstacles!"))
		return

	R.use(8)
	use(2)

	var/obj/structure/razorwire/M = new /obj/item/stack/razorwire(user.loc, 2)
	to_chat(user, span_notice("You combine the rods and barbed wire into [M]!"))

/obj/item/stack/razorwire
	name = "razor wire assembly"
	desc = "A bundle of barbed wire supported by metal rods. Used to deny access to areas under pain of entanglement and injury. A classic fortification since the 1900s."
	icon = 'icons/obj/structures/barbedwire.dmi'
	icon_state = "barbedwire_assembly"
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	throwforce = 10
	throw_range = 5
	attack_verb = list("hit", "whacked", "sliced")
	singular_name = "bundle"
	max_amount = 10
	merge_type = /obj/item/stack/razorwire


//small stack
/obj/item/stack/razorwire/small_stack
	amount = 5

//medium stack
/obj/item/stack/razorwire/half_stack
	amount = 10

//full stack
/obj/item/stack/razorwire/full
	amount = 20

/obj/item/stack/razorwire/attack_self(mob/user) //use barbed wire to deploy it
	if(!ishuman(usr))
		return

	var/turf/mystery_turf = get_step(user.loc,user.dir)
	if(!isopenturf(mystery_turf))
		to_chat(user, span_warning("We can't build here!"))
		return

	var/turf/open/target = mystery_turf

	if(check_blocked_turf(target)) //check if blocked
		to_chat(user, span_warning("There is insufficient room to deploy [src]!"))
		return

	if(!target.allow_construction) //We shouldn't be building here.
		to_chat(user, span_warning("We can't build here!"))
		return

	user.visible_message(span_notice("[user] starts assembling [src]."),
	span_notice("You start assembling [src]."))
	var/delay_assembly = SKILL_TASK_EASY
	if(user.skills.getRating(SKILL_ENGINEER)) //Higher skill lowers the delay.
		delay_assembly -= 0.5 SECONDS + user.skills.getRating(SKILL_ENGINEER) * 2

	if(do_after(user, delay_assembly, NONE, src, BUSY_ICON_BUILD))
		var/obj/structure/razorwire/M = new /obj/structure/razorwire(target)
		M.setDir(user.dir)
		user.visible_message(span_notice("[user] assembles a [M]."),
		span_notice("You assemble a [M]."))
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
		M.update_icon()
		use(1)
	user.record_structures_built()

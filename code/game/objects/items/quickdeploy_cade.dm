//An item thats meant to be a template for quickly deploying stuff like barricades
/obj/item/quikdeploy
	name = "QuikDeploy System"
	desc = "This is a QuikDeploy system, allows for extremely fast placement of various objects."
	icon = 'icons/obj/items/quikdeploy_cade.dmi'
	w_class = WEIGHT_CLASS_SMALL //While this is small, normal 50 stacks of metal is NORMAL so this is a bit on the bad space to cade ratio
	var/delay = 0 //Delay on deploying the thing
	var/atom/movable/thing_to_deploy = null

/obj/item/quikdeploy/examine(mob/user)
	. = ..()
	to_chat(user, "This QuikDeploy system seems to deploy a [thing_to_deploy.name].")

/obj/item/quikdeploy/attack_self(mob/user)
	to_chat(user, "<span class='warning'>You start to deploy onto the tile in front of you...")
	if(!do_after(usr, delay, TRUE, src, BUSY_ICON_BUILD))
		to_chat(user, "<span class='warning'>You decide against deploying something here.")
		return
	if(can_place(user)) //can_place() handles sending the error and success messages to the user
		var/obj/O = new thing_to_deploy(get_turf(user))
		O.setDir(user.dir)
		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		qdel(src)

/obj/item/quikdeploy/proc/can_place(mob/user)
	if(isnull(thing_to_deploy)) //Spaghetti or wrong type spawned
		to_chat(user, "<span class='warning'>This thing doesn't actually really do anything! Complain to whoever gave you this")
		return FALSE
	return TRUE

/obj/item/quikdeploy/cade
	thing_to_deploy = /obj/structure/barricade/metal
	icon_state = "metal"
	delay = 3 SECONDS

/obj/item/quikdeploy/cade/can_place(mob/user)
	. = ..()
	if(!.)
		return FALSE

	var/turf/mystery_turf = user.loc
	if(!isopenturf(mystery_turf))
		to_chat(user, "<span class='warning'>We can't build here!</span>")
		return FALSE

	var/turf/open/placement_loc = mystery_turf
	if(placement_loc.density || !placement_loc.allow_construction) //We shouldn't be building here.
		to_chat(user, "<span class='warning'>We can't build here!</span>")
		return FALSE

	for(var/obj/thing in user.loc)
		if(!thing.density) //not dense, move on
			continue
		if(!(thing.flags_atom & ON_BORDER)) //dense and non-directional, end
			to_chat(user, "<span class='warning'>No space here for a barricade.</span>")
			return FALSE
		if(thing.dir != user.dir)
			continue
		to_chat(user, "<span class='warning'>No space here for a barricade.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You plop down the barricade in front of you.")
	return TRUE

/obj/item/quikdeploy/cade/plasteel
	thing_to_deploy = /obj/structure/barricade/plasteel
	icon_state = "plasteel"

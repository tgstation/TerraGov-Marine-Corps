//An item that allows a very quick deployment of a barricade
/obj/item/quikdeploy_cade
	name = "QuikDeploy Barricade"
	desc = "This is a QuikDeploy barricade, allows for extremely fast laying of barricades. Usually found in specific vendors and cannot be picked back up."
	icon = 'icons/obj/items/quikdeploy_cade.dmi'
	icon_state = "metal"
	var/obj/thing_to_deploy = /obj/structure/barricade/metal
	w_class = WEIGHT_CLASS_SMALL //While this is small, normal 50 stacks of metal is NORMAL so this is a bit on the bad space to cade ratio

/obj/item/quikdeploy_cade/examine(mob/user)
	..()
	to_chat(user, "This QuikDeploy cade seems to deploy a [thing_to_deploy.name].")

/obj/item/quikdeploy_cade/attack_self(mob/user)
	to_chat(user, "You start to deploy the cade on your tile in front of you...")
	if(!do_after(usr, 2 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		to_chat(user, "You decide against putting the barricade here.")
		return
	var/check_build = TRUE
	//Copypasta crafting code
	for(var/obj/thing in get_turf(src))
		if(!istype(thing, thing_to_deploy))
			continue
		if(thing.dir != user.dir)
			continue
		check_build = FALSE
		break
	if(!isfloorturf(get_turf(src)))
		to_chat(usr, "<span class='warning'>You can only deploy something on top of a floor!!</span>")
		return
	for(var/obj/AM in get_turf(src))
		if(istype(AM,/obj/structure/grille))
			continue
		if(istype(AM,/obj/structure/table))
			continue
		if(!AM.density)
			continue
		if(AM.flags_atom & ON_BORDER && AM.dir != user.dir)
			if(istype(AM, /obj/structure/window))
				var/obj/structure/window/W = AM
				if(!W.is_full_window())
					continue
			else
				continue
		check_build = FALSE
		break
	if(!check_build)
		to_chat(user, "<span class='warning'>You can't deploy the barricade here!</span>")
		return
	var/obj/O = new thing_to_deploy(get_turf(user))
	O.setDir(user.dir)
	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	qdel(src)

/obj/item/quikdeploy_cade/plasteel
	thing_to_deploy = /obj/structure/barricade/plasteel
	icon_state = "plasteel"

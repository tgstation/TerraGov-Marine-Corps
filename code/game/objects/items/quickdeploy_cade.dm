//An item that allows a very quick deployment of a barricade
/obj/item/quikdeploy_cade
	name = "QuikDeploy Barricade"
	desc = "This is a QuikDeploy barricade, allows for extremely fast laying of barricades. Usually found in specific vendors and cannot be picked back up."
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
	for(var/obj/thing in loc)
		if(!istype(thing, thing_to_deploy))
			continue
		if(thing.dir != user.dir)
			continue
		to_chat(user, "<span class='warning'>You can't build \the [thing_to_deploy.name] on top of another!</span>")
		return
	var/obj/O = new thing_to_deploy(get_turf(user))
	O.setDir(user.dir)
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	qdel(src)

/obj/item/quikdeploy_cade/plasteel
	thing_to_deploy = /obj/structure/barricade/plasteel

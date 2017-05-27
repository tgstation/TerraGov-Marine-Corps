/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if (iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.slip(name, 4, 2)


/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (iscarbon(AM))
		var/mob/living/carbon/C =AM
		C.slip("soap", 3, 2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user << "<span class='notice'>You scrub \the [target.name] out.</span>"
		del(target)
	else
		user << "<span class='notice'>You clean \the [target.name].</span>"
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target, mob/user)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == "mouth" )
		user.visible_message("\red \the [user] washes \the [target]'s mouth out with soap!")
		return
	..()

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 25, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return
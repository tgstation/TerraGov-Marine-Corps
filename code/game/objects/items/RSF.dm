/*
CONTAINS:
RSF

*/

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/stored_matter = 30
	var/mode = 1
	w_class = 3.0

/obj/item/rsf/examine(mob/user)
	..()
	to_chat(user, "It currently holds [stored_matter]/30 fabrication-units.")

/obj/item/rsf/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/ammo_rcd))

		if ((stored_matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return

		qdel(W)

		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
		return

/obj/item/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 15, 0)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		return
	if (mode == 2)
		mode = 3
		to_chat(user, "Changed dispensing mode to 'Paper'")
		return
	if (mode == 3)
		mode = 4
		to_chat(user, "Changed dispensing mode to 'Pen'")
		return
	if (mode == 4)
		mode = 5
		to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		return
	if (mode == 5)
		mode = 6
		to_chat(user, "Changed dispensing mode to 'Cigarette'")
		return
	if (mode == 6)
		mode = 1
		to_chat(user, "Changed dispensing mode to 'Dosh'")
		return
	// Change mode

/obj/item/rsf/afterattack(atom/A, mob/user as mob, proximity)

	if(!proximity) return

	if(stored_matter <= 0)
		return

	if(!istype(A, /obj/structure/table) && !isfloorturf(A))
		return

	playsound(src.loc, 'sound/machines/click.ogg', 25, 1)
	var/obj/product

	switch(mode)
		if(1)
			product = new /obj/item/spacecash/c10()
		if(2)
			product = new /obj/item/reagent_container/food/drinks/drinkingglass()
		if(3)
			product = new /obj/item/paper()
		if(4)
			product = new /obj/item/tool/pen()
		if(5)
			product = new /obj/item/storage/pill_bottle/dice()
		if(6)
			product = new /obj/item/clothing/mask/cigarette()

	to_chat(user, "Dispensing [product ? product : "product"]...")
	product.loc = get_turf(A)

	stored_matter--
	to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
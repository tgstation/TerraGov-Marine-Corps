/obj/item/reagent_containers/food/snacks/breadslice/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/shard) || istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/csandwich/S = new(loc)
		S.attackby(I, user, params)
		qdel(src)

/obj/item/reagent_containers/food/snacks/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

/obj/item/reagent_containers/food/snacks/csandwich/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/sandwich_limit = 4
	for(var/obj/item/reagent_containers/food/snacks/breadslice/B in ingredients)
		sandwich_limit += 4

	if(length(contents) > sandwich_limit)
		to_chat(user, span_warning("If you put anything else on \the [src] it's going to collapse."))

	else if(istype(I, /obj/item/shard))
		to_chat(user, span_notice("You hide [I] in \the [src]."))
		user.transferItemToLoc(I, src)
		update()

	else if(istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, span_notice("You layer [I] over \the [src]."))
		var/obj/item/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.transferItemToLoc(I, src)
		ingredients += I
		update()

/obj/item/reagent_containers/food/snacks/csandwich/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/reagent_containers/food/snacks/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == ingredients.len)
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		var/image/I = new(src.icon, "sandwich_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		overlays += I

	var/image/T = new(src.icon, "sandwich_top")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (ingredients.len * 2)+1
	overlays += T

	name = lowertext("[fullname] sandwich")
	if(length_char(name) > 80) name = "[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich"
	w_class = CEILING(clamp((ingredients.len/2),1,3),1)

/obj/item/reagent_containers/food/snacks/csandwich/Destroy()
	for(var/obj/item/O in ingredients)
		qdel(O)
	. = ..()

/obj/item/reagent_containers/food/snacks/csandwich/examine(mob/user)
	. = ..()
	var/obj/item/O = pick(contents)
	. += span_notice("You think you can see [O] in there.")

/obj/item/reagent_containers/food/snacks/csandwich/attack(mob/M as mob, mob/user as mob, def_zone)

	var/obj/item/shard
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/shard))
			shard = O
			break

	var/mob/living/H
	if(istype(M,/mob/living))
		H = M

	if(H && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		to_chat(H, span_warning("You lacerate your mouth on a [shard.name] in the sandwich!"))
		H.adjustBruteLoss(5) //TODO: Target head if human.
	..()

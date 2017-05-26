
#define NO_DIRT				0
#define DIRT_TYPE_GROUND	1
#define DIRT_TYPE_MARS		2
#define DIRT_TYPE_SNOW		3

// Entrenching tool.
/obj/item/weapon/etool
	name = "entrenching tool"
	desc = "Used to dig holes and bash heads in. Folds in to fit in small spaces."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "etool"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 30
	throwforce = 2.0
	item_state = "crowbar"
	w_class = 4 //three for unfolded, 3 for folded. This should keep it outside backpacks until its folded, made it 3 because 2 lets you fit in pockets appearntly.
	origin_tech = "engineering=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	var/folded = 0 // 0 for unfolded, 1 for folded
	var/has_dirt = 0 // 0 for no dirt, 1 for brown dirt, 2 for snow, 3 for big red.

	//Update overlay
/obj/item/weapon/etool/update_icon()

	if(folded) icon_state = "etool_c"
	else icon_state = "etool"

	var/image/reusable/I = rnew(/image/reusable, list('icons/Marine/marine-items.dmi',src,"etool_dirt"))
	switch(has_dirt) // We can actually shape the color for what enviroment we dig up our dirt in.
		if(DIRT_TYPE_GROUND) I.color = "#512A09"
		if(DIRT_TYPE_MARS) I.color = "#EBEBEB"
		if(DIRT_TYPE_SNOW) I.color = "#FF5500"
	if(has_dirt)	overlays += I
	else
		overlays -= I
		cdel(I)

/obj/item/weapon/etool/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(has_dirt)
		user <<" You dump the dirt!"
		has_dirt = 0

	folded = !folded
	if(folded)
		w_class = 3
		force = 2
	else
		w_class = 4
		force = 30
	update_icon()

/obj/item/weapon/etool/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(folded) return
	if(!has_dirt)
		if(isturf(target))
			var/turf/T = target
			has_dirt = T.get_dirt_type()
			if(has_dirt)
				user <<"You dig up some dirt"
				update_icon()
	else
		user <<"you dump the dirt!"
		has_dirt = 0
		update_icon()


//what dirt type you can dig from this turf if any.
/turf/proc/get_dirt_type()
	return NO_DIRT

/turf/unsimulated/floor/gm/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/unsimulated/floor/mars/get_dirt_type()
	return DIRT_TYPE_MARS

/turf/unsimulated/floor/snow/get_dirt_type()
	return DIRT_TYPE_SNOW


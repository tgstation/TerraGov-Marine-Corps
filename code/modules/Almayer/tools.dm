//---- New Tools (Move these to a proper folder ASAP) ---

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
	var/has_dirt = 0 // 0 for no dirt, 1 for dirt
	var/dirt_type = 0 // what planet are we on? 1 for brown, 2 for snow, 3 for big red.

	//Update overlay
/obj/item/weapon/etool/update_icon()

	if(folded) icon_state = "etool_c"
	else icon_state = "etool"

	var/image/reusable/I = rnew(/image/reusable, list('icons/Marine/marine-items.dmi',src,"etool_dirt",layer))
	switch(dirt_type) // We can actually shape the color for what enviroment we dig up our dirt in.
		if(1) I.color = "#512A09"
		if(2) I.color = "#EBEBEB"
		if(3) I.color = "#FF5500"
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

/obj/item/weapon/etool/afterattack(atom/target, mob/user)
	if(!has_dirt && !folded)
		if(!istype(target, (/turf/unsimulated/floor/gm || /turf/unsimulated/floor/mars || /turf/unsimulated/floor/snow))) dirt_type = 0
		if(istype(target, /turf/unsimulated/floor/gm) && get_dist(user,target) <= 1)  dirt_type = 1
		if(istype(target, /turf/unsimulated/floor/mars) && get_dist(user,target) <= 1) dirt_type = 3
		if(istype(target, /turf/unsimulated/floor/snow) && get_dist(user,target) <= 1) dirt_type = 2
		if(dirt_type)
			has_dirt = 1
			user <<"You dig up some dirt"
		update_icon()
		return
	if(has_dirt && !folded)
		user <<"you dump the dirt!"
		has_dirt = 0
		update_icon()
		return
	else
		..()

// Empty sandbags.

/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best fill them up."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_stack"
	flags_atom = FPRINT
	w_class = 3.0
	force = 2
	throwforce = 0
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags_empty/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/etool))
		var/obj/item/weapon/etool/ET = W
		if(ET.has_dirt)
			var/obj/item/stack/sandbags/new_bags = new(usr.loc)
			new_bags.add_to_stacks(usr)
			var/obj/item/stack/sandbags_empty/E = src
			src = null
			var/replace = (user.get_inactive_hand()==E)
			E.use(1)
			ET.has_dirt = 0
			ET.update_icon()
			if (!E && replace)
				user.put_in_hands(new_bags)
		return
	..()

//Full sandbags.

/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags, filled often for extra protection"
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_pile"
	flags_atom = FPRINT
	w_class = 4.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGER BUILDING
		usr << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
		return

	if(!in_use)
		if(amount < 5)
			user << "\blue You need at least five sandbags to do this"
			return
		usr << "\blue Assembling sandbag barricade..."
		in_use = 1
		if (!do_after(usr, 20))
			in_use = 0
			return
		var/obj/structure/m_barricade/sandbags/SB = new /obj/structure/m_barricade/sandbags ( usr.loc )
		usr << "\blue You assemble a sandbag barricade!"
		SB.dir = usr.dir
		SB.update_icon()
		in_use = 0
		SB.add_fingerprint(usr)
		use(5)
	return


//Sandbags
/obj/structure/m_barricade/sandbags
	name = "sandbag barricade"
	desc = "Trusted since 1914"
	icon_state = "sandbag"
	health = 250 //Pretty tough. Changes sprites at 300 and 150.
	layer = 5

	New()
		update_icon()

/obj/structure/m_barricade/sandbags/Crossed(atom/movable/O)
	..()
	if(istype(O,/mob/living/carbon/Xenomorph/Crusher))
		var/mob/living/carbon/Xenomorph/M = O
		if(!M.stat)
			visible_message("<span class='danger'>[O] steamrolls through [src]!</span>")
 		destroy() //This fixes the weird bug where it wouldn't compile because it would say theres a unbalanced } + defining a proc within a proc.

/obj/structure/m_barricade/sandbags/update_icon()
	if(dir == NORTH) layer = 3
	icon_state = initial(icon_state)

/obj/structure/m_barricade/sandbags/update_health()
	if(health < 0) destroy()

/obj/structure/m_barricade/sandbags/attackby(obj/item/W as obj, mob/user as mob)
	if(!W) return

	//Otherwise, just hit it.
	if(force > 20)
		..()
		health -= W.force * 0.5
		update_health()

/obj/structure/m_barricade/sandbags/destroy()
	density = 0
	cdel(src)
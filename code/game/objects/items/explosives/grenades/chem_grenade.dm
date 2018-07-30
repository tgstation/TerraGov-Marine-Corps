/obj/item/explosive/grenade/chem_grenade
	name = "Grenade Casing"
	icon_state = "chemg"
	item_state = "flashbang"
	desc = "A hand made chemical grenade."
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly_holder/detonator = null
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/reagent_container/glass/beaker, /obj/item/reagent_container/glass/bottle)
	var/affected_area = 3

/obj/item/explosive/grenade/chem_grenade/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

/obj/item/explosive/grenade/chem_grenade/attack_self(mob/user as mob)
	if(stage <= 1)
		if(detonator)
			detonator.detached()
			usr.put_in_hands(detonator)
			detonator=null
			stage=0
			icon_state = initial(icon_state)
		else if(beakers.len)
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.put_in_hands(B)
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
	else
		..()

/obj/item/explosive/grenade/chem_grenade/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			user << "\red Assembly must contain one igniter."
			return
		if(!det.secured)
			user << "\red Assembly must be secured with screwdriver."
			return
		path = 1
		user << "\blue You add [W] to the metal casing."
		playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, 0, 6)
		user.temp_drop_inv_item(det)
		det.forceMove(src)
		detonator = det
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1
	else if(istype(W,/obj/item/tool/screwdriver) && path != 2)
		if(stage == 1)
			path = 1
			if(beakers.len)
				user << "\blue You lock the assembly."
				name = "grenade"
			else
//					user << "\red You need to add at least one beaker before locking the assembly."
				user << "\blue You lock the empty assembly."
				name = "fake grenade"
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 0, 6)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				user << "\red You trigger the assembly!"
				prime()
				return
			else
				user << "\blue You unlock the assembly."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 0, 6)
				name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 2)
			user << "\red The grenade can not hold more containers."
			return
		else
			if(W.reagents.total_volume)
				if(user.drop_held_item())
					user << "\blue You add \the [W] to the assembly."
					W.forceMove(src)
					beakers += W
					stage = 1
					name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				user << "\red \the [W] is empty."

/obj/item/explosive/grenade/chem_grenade/examine(mob/user)
	..()
	if(detonator)
		user << "With attached [detonator.name]"

/obj/item/explosive/grenade/chem_grenade/activate(mob/user as mob)
	if(active) return

	if(detonator)
		if(!isigniter(detonator.a_left))
			detonator.a_left.activate()
			active = 1
		if(!isigniter(detonator.a_right))
			detonator.a_right.activate()
			active = 1
	if(active)
		icon_state = initial(icon_state) + "_active"

		if(user)
			msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	return

/obj/item/explosive/grenade/chem_grenade/proc/primed(var/primed = 1)
	if(active)
		icon_state = initial(icon_state) + (primed?"_primed":"_active")

/obj/item/explosive/grenade/chem_grenade/prime()
	if(!stage || stage<2) return

	//if(prob(reliability))
	var/has_reagents = 0
	for(var/obj/item/reagent_container/glass/G in beakers)
		if(G.reagents.total_volume) has_reagents = 1

	active = 0
	if(!has_reagents)
		icon_state = initial(icon_state) +"_locked"
		playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, 1)
		return

	playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

	for(var/obj/item/reagent_container/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)

	if(!disposed) //the possible reactions didn't cdel src
		if(reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)

		if(istype(loc, /mob/living/carbon))		//drop dat grenade if it goes off in your hand
			var/mob/living/carbon/C = loc
			C.drop_inv_item_on_ground(src)
			C.throw_mode_off()

		invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
		spawn(50)		   //To make sure all reagents can work
			cdel(src)	   //correctly before deleting the grenade.


/obj/item/explosive/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_container/glass)
	origin_tech = "combat=3;materials=3"
	affected_area = 4


/obj/item/explosive/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

/obj/item/explosive/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("pacid", 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	stage = 2

/obj/item/explosive/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 15)
	B1.reagents.add_reagent("fuel",20)
	B2.reagents.add_reagent("phoron", 15)
	B2.reagents.add_reagent("sacid", 15)
	B1.reagents.add_reagent("fuel",20)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	path = 1
	stage = 2

/obj/item/explosive/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = 2
	path = 1

/obj/item/explosive/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"




/obj/item/explosive/grenade/chem_grenade/teargas
	name = "\improper M66 teargas grenade"
	desc = "Tear gas grenade used for nonlethal riot control. Please wear adequate gas protection."
	stage = 2

/obj/item/explosive/grenade/chem_grenade/teargas/New()
	..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src, 2) //~4 second timer

	beakers += B1
	beakers += B2

	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/teargas/attack_self(mob/user)
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
		return
	..()
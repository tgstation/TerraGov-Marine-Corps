/obj/structure/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/structures/fence.dmi'
	icon_state = "fence0"
	density = TRUE
	anchored = TRUE
	layer = WINDOW_LAYER
	max_integrity = 50
	var/cut = FALSE //Cut fences can be passed through
	var/junction = 0 //Because everything is terrible, I'm making this a fence-level var
	var/basestate = "fence"

//create_debris creates debris like shards and rods. This also includes the window frame for explosions
//If an user is passed, it will create a "user smashes through the window" message. AM is the item that hits
//Please only fire this after a hit
/obj/structure/fence/proc/healthcheck(make_hit_sound = 1, create_debris = 1, mob/user, atom/movable/AM)

	if(cut) //It's broken/cut, just a frame!
		return
	if(obj_integrity <= 0)
		if(user)
			user.visible_message("<span class='danger'>[user] smashes through [src][AM ? " with [AM]":""]!</span>")
		playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
		cut_grille()
	if(make_hit_sound)
		playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)

/obj/structure/fence/bullet_act(obj/item/projectile/Proj)
	//Tasers and the like should not damage windows.
	if(Proj.ammo.damage_type == HALLOSS || Proj.damage <= 0 || Proj.ammo.flags_ammo_behavior == AMMO_ENERGY)
		return FALSE

	obj_integrity -= Proj.damage * 0.3
	..()
	healthcheck()
	return TRUE

/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src) //Nope
		if(2)
			qdel(src)
		if(3)
			obj_integrity -= rand(25, 55)
			healthcheck(0, 1)

/obj/structure/fence/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	obj_integrity = max(0, obj_integrity - tforce)
	healthcheck()

/obj/structure/fence/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_generic(H, 25)

/obj/structure/fence/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/fence/attack_alien(mob/living/carbon/xenomorph/M)
	M.animation_attack_on(src)
	var/damage_dealt = 5
	M.visible_message("<span class='danger'>\The [M] mangles [src]!</span>", \
	"<span class='danger'>You mangle [src]!</span>", \
	"<span class='danger'>You hear twisting metal!</span>", 5)

	obj_integrity -= damage_dealt
	healthcheck()

//Used by attack_animal
/obj/structure/fence/proc/attack_generic(mob/living/user, damage = 0)
	obj_integrity -= damage
	user.animation_attack_on(src)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	healthcheck(1, 1, user)

/obj/structure/fence/attack_animal(mob/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)


/obj/structure/fence/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods) && obj_integrity < max_integrity)
		if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_PLASTEEL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to fix [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out how to fix [src]'s wiring.</span>")
			var/fumbling_time = 100 - 20 * user.mind.cm_skills.construction
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		var/obj/item/stack/rods/R = I
		var/amount_needed = 2
		if(obj_integrity)
			amount_needed = 1

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		user.visible_message("<span class='notice'>[user] starts repairing [src] with [R].</span>",
		"<span class='notice'>You start repairing [src] with [R]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_FRIENDLY))
			return

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		R.use(amount_needed)
		obj_integrity = max_integrity
		cut = 0
		density = TRUE
		update_icon()
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] repairs [src] with [R].</span>",
		"<span class='notice'>You repair [src] with [R]")

	else if(cut) //Cut/brokn grilles can't be messed with further than this
		return

	else if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		var/state = user.grab_level
		user.drop_held_item()
		switch(state)
			if(GRAB_PASSIVE)
				M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
				M.apply_damage(7)
				obj_integrity -= 10
			if(GRAB_AGGRESSIVE)
				M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
				if(prob(50))
					M.KnockDown(1)
				M.apply_damage(10)
				obj_integrity -= 25
			if(GRAB_NECK)
				M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
				M.KnockDown(5)
				M.apply_damage(20)
				obj_integrity -= 50

		healthcheck(1, 1, M) //The person thrown into the window literally shattered it

	else if(I.flags_item & NOBLUDGEON)
		return

	else if(iswirecutter(I))
		user.visible_message("<span class='notice'>[user] starts cutting through [src] with [I].</span>",
		"<span class='notice'>You start cutting through [src] with [I]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] cuts through [src] with [I].</span>",
		"<span class='notice'>You cut through [src] with [I]")
		cut_grille()

	else
		switch(I.damtype)
			if("fire")
				obj_integrity -= I.force
			if("brute")
				obj_integrity -= I.force * 0.1
		healthcheck(1, 1, user, I)


/obj/structure/fence/proc/cut_grille(create_debris = 1)
	if(create_debris)
		new /obj/item/stack/rods(loc)
	cut = 1
	density = 0
	update_icon() //Make it appear cut through!

/obj/structure/fence/New(Loc, start_dir = null, constructed = 0)
	..()

	if(start_dir)
		setDir(start_dir)

	update_nearby_icons()

/obj/structure/fence/Destroy()
	density = 0
	update_nearby_icons()
	. = ..()

/obj/structure/fence/Move()
	var/ini_dir = dir
	..()
	setDir(ini_dir)

//This proc is used to update the icons of nearby windows.
/obj/structure/fence/proc/update_nearby_icons()
	update_icon()
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/fence/W in get_step(src, direction))
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/fence/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src)
			return
		for(var/obj/structure/fence/W in orange(src, 1))
			if(abs(x - W.x) - abs(y - W.y)) //Doesn't count grilles, placed diagonally to src
				junction |= get_dir(src, W)
		if(cut)
			icon_state = "broken[basestate][junction]"
		else
			icon_state = "[basestate][junction]"

/obj/structure/fence/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		obj_integrity -= round(exposed_volume / 100)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

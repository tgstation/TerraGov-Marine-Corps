/obj/structure/window
	name = "window"
	desc = "A glass window. It looks thin and flimsy. A few knocks with anything should shatter it."
	icon = 'icons/obj/structures.dmi'
	icon_state = "window"
	density = 1
	layer = 3.2 //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1
	flags_atom = ON_BORDER
	var/health = 15
	var/state = 2
	var/reinf = 0
	var/basestate = "window"
	var/shardtype = /obj/item/weapon/shard
	var/obj/structure/window_frame/window_frame //For perspective windows,so the window frame doesn't magically dissapear
	var/windowknock_cooldown = 0

//create_debris creates debris like shards and rods. This also includes the window frame for explosions
//If an user is passed, it will create a "user smashes through the window" message. AM is the item that hits
//Please only fire this after a hit
/obj/structure/window/proc/healthcheck(make_hit_sound = 1, make_shatter_sound = 1, create_debris = 1, mob/user, atom/movable/AM)

	if(health <= 0)
		if(user)
			user.visible_message("<span class='danger'>[user] smashes through [src][AM ? "with [AM]":""]!</span>")
		if(make_shatter_sound)
			playsound(src, "shatter", 70, 1)
		if(create_debris)
			new shardtype(loc)
			if(is_full_window())
				new shardtype(loc)
			if(reinf) new /obj/item/stack/rods(loc)
			if(window_frame)
				var/obj/structure/window_frame/new_window_frame = new window_frame(loc)
				new_window_frame.icon_state = "[icon_state]_frame"
				new_window_frame.dir = dir
		del(src)
	else
		if(make_hit_sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)

	//Tasers and the like should not damage windows.
	if(Proj.ammo.damage_type == HALLOSS || Proj.damage <= 0 || Proj.ammo.flags_ammo_behavior == AMMO_ENERGY)
		return 0

	health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(125, 250)
			healthcheck(0, 1, 0)
		if(2)
			health -= rand(75, 125)
			healthcheck(0, 1)
		if(3)
			health -= rand(25, 75)
			healthcheck(0, 1)

//TODO: Make full windows a separate type of window.
//Once a full window, it will always be a full window, so there's no point
//having the same type for both.
/obj/structure/window/proc/is_full_window()
	return (dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(is_full_window())
		return 0 //Full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	health = max(0, health - tforce)
	if(health <= 7 && !reinf)
		anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
	healthcheck()

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, 'sound/effects/glassknock.ogg', 80, 1)

/obj/structure/window/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		health -= 500
		healthcheck(1, 1, 1, user)

	else if(user.a_intent == "hurt")

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.species.can_shred(H))
				attack_generic(H, 25)
				return

		if(windowknock_cooldown > world.time)
			return
		playsound(loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='warning'>[user] bangs against [src]!</span>",
		"<span class='warning'>You bang against [src]!</span>",
		"<span class='warning'>You hear a banging sound.</span>")
		windowknock_cooldown = world.time + 100
	else
		if(windowknock_cooldown > world.time)
			return
		playsound(loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>",
		"<span class='notice'>You knock on [src].</span>",
		"<span class='notice'>You hear a knocking sound.</span>")
		windowknock_cooldown = world.time + 100

/obj/structure/window/attack_paw(mob/user as mob)
	return attack_hand(user)

//Used by attack_animal
/obj/structure/window/proc/attack_generic(mob/user as mob, damage = 0)
	health -= damage
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	healthcheck(1, 1, 1, user)

/obj/structure/window/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attackby(obj/item/W as obj, mob/user as mob)
	if(!istype(W)) return //I really wish I did not need this
	if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting,/mob/living))
			var/mob/living/M = G.affecting
			var/state = G.state
			del(W) //Gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
					M.apply_damage(7)
					health -= 10
				if(2)
					M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					if(prob(50))
						M.Weaken(1)
					M.apply_damage(10)
					health -= 25
				if(3)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(20)
					health -= 50
			healthcheck(1, 1, 1, M) //The person thrown into the window literally shattered it
			return

	if(W.flags_atom & NOBLUDGEON) return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>")
		else if(reinf && state == 0)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>")
		else if(!reinf)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>")
	else if(istype(W, /obj/item/weapon/crowbar) && reinf && state <= 1)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		user << (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>")
	else
		health -= W.force
		if(health <= 7  && !reinf)
			anchored = 0
			update_nearby_icons()
			step(src, get_dir(user, src))
		healthcheck(1, 1, 1, user, W)
		..()
	return

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		usr << "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>"
		return 0

	update_nearby_tiles(need_rebuild = 1) //Compel updates before
	dir = turn(dir, 90)
	update_nearby_tiles(need_rebuild = 1)
	return


/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		usr << "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>"
		return 0

	update_nearby_tiles(need_rebuild = 1) //Compel updates before
	dir = turn(dir, 270)
	update_nearby_tiles(need_rebuild = 1)
	return

/obj/structure/window/New(Loc, start_dir = null, constructed = 0)
	..()

	//player-constructed windows
	if(constructed)
		anchored = 0

	if(start_dir)
		dir = start_dir

	update_nearby_tiles(need_rebuild = 1)
	update_nearby_icons()

/obj/structure/window/Del()
	density = 0
	update_nearby_tiles()
	update_nearby_icons()
	..()

/obj/structure/window/Move()
	var/ini_dir = dir
	update_nearby_tiles(need_rebuild = 1)
	..()
	dir = ini_dir
	update_nearby_tiles(need_rebuild = 1)

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src,direction) )
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src) return
		if(!is_full_window())
			icon_state = "[basestate]"
			return
		var/junction = 0 //Will be used to determine from which side the window is connected to other windows
		if(anchored)
			for(var/obj/structure/window/W in orange(src, 1))
				if(W.anchored && W.density	&& W.is_full_window()) //Only counts anchored, not-destroyed fill-tile windows.
					if(abs(x - W.x) - abs(y - W.y)) //Doesn't count windows, placed diagonally to src
						junction |= get_dir(src, W)
		if(opacity)
			icon_state = "[basestate][junction]"
		else
			if(reinf)
				icon_state = "[basestate][junction]"
			else
				icon_state = "[basestate][junction]"

		return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		health -= round(exposed_volume / 100)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronbasic
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "phoronwindow"
	icon_state = "phoronwindow"
	shardtype = /obj/item/weapon/shard/phoron
	health = 120

/obj/structure/window/phoronbasic/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		health -= round(exposed_volume / 1000)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronreinforced
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window with a rod matrice. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	basestate = "phoronrwindow"
	icon_state = "phoronrwindow"
	shardtype = /obj/item/weapon/shard/phoron
	reinf = 1
	health = 160

/obj/structure/window/phoronreinforced/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A glass window with a rod matrice. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	health = 40
	reinf = 1

/obj/structure/window/reinforced/toughened
	name = "safety glass"
	desc = "A very tough looking glass window with a special rod matrice, probably bullet proof."
	icon_state = "rwindow"
	basestate = "rwindow"
	health = 300
	reinf = 1

/obj/structure/window/New(Loc, constructed = 0)
	..()

	//player-constructed windows
	if(constructed)
		state = 0

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "A glass window with a rod matrice. It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "A glass window with a rod matrice. It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	health = 30

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A shuttle glass window with a rod matrice specialised for heat resistance. It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	health = 40
	reinf = 1
	dir = 5

	update_icon() //icon_state has to be set manually
		return

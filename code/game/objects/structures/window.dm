/obj/structure/window
	name = "window"
	desc = "A glass window. It looks thin and flimsy. A few knocks with anything should shatter it."
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "window"
	density = 1
	anchored = 1
	layer = WINDOW_LAYER
	flags_atom = ON_BORDER|FPRINT
	var/health = 15
	var/state = 2
	var/reinf = 0
	var/basestate = "window"
	var/shardtype = /obj/item/shard
	var/windowknock_cooldown = 0
	var/static_frame = 0 //True/false. If true, can't move the window
	var/junction = 0 //Because everything is terrible, I'm making this a window-level var
	var/not_damageable = 0
	var/not_deconstructable = 0

//create_debris creates debris like shards and rods. This also includes the window frame for explosions
//If an user is passed, it will create a "user smashes through the window" message. AM is the item that hits
//Please only fire this after a hit
/obj/structure/window/proc/healthcheck(make_hit_sound = 1, make_shatter_sound = 1, create_debris = 1, mob/user, atom/movable/AM)

	if(not_damageable)
		if(make_hit_sound) //We'll still make the noise for immersion's sake
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)
		return
	if(health <= 0)
		if(user)
			user.visible_message("<span class='danger'>[user] smashes through [src][AM ? " with [AM]":""]!</span>")
		if(make_shatter_sound)
			playsound(src, "shatter", 50, 1)
		shatter_window(create_debris)
	else
		if(make_hit_sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	//Tasers and the like should not damage windows.
	if(Proj.ammo.damage_type == HALLOSS || Proj.damage <= 0 || Proj.ammo.flags_ammo_behavior == AMMO_ENERGY)
		return 0

	if(!not_damageable) //Impossible to destroy
		health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/structure/window/ex_act(severity)
	if(not_damageable) //Impossible to destroy
		return
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
	if(!(flags_atom & ON_BORDER))
		return TRUE

/obj/structure/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(is_full_window())
		return 0 //Full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/CheckExit(atom/movable/O, turf/target)
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
	if(!not_damageable) //Impossible to destroy
		health = max(0, health - tforce)
		if(health <= 7 && !reinf && !static_frame)
			anchored = 0
			update_nearby_icons()
			step(src, get_dir(AM, src))
	healthcheck()

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, 'sound/effects/glassknock.ogg', 15, 1)

/obj/structure/window/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		if(!not_damageable) //Impossible to destroy
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
		playsound(loc, 'sound/effects/glassknock.ogg', 25, 1)
		user.visible_message("<span class='warning'>[user] bangs against [src]!</span>",
		"<span class='warning'>You bang against [src]!</span>",
		"<span class='warning'>You hear a banging sound.</span>")
		windowknock_cooldown = world.time + 100
	else
		if(windowknock_cooldown > world.time)
			return
		playsound(loc, 'sound/effects/glassknock.ogg', 15, 1)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>",
		"<span class='notice'>You knock on [src].</span>",
		"<span class='notice'>You hear a knocking sound.</span>")
		windowknock_cooldown = world.time + 100

/obj/structure/window/attack_paw(mob/user as mob)
	return attack_hand(user)

//Used by attack_animal
/obj/structure/window/proc/attack_generic(mob/living/user, damage = 0)
	if(!not_damageable) //Impossible to destroy
		health -= damage
	user.animation_attack_on(src)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	healthcheck(1, 1, 1, user)

/obj/structure/window/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/grab) && get_dist(src, user) < 2)
		if(isXeno(user)) return
		var/obj/item/grab/G = W
		if(istype(G.grabbed_thing, /mob/living))
			var/mob/living/M = G.grabbed_thing
			var/state = user.grab_level
			user.drop_held_item()
			switch(state)
				if(GRAB_PASSIVE)
					M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
					M.apply_damage(7)
					if(!not_damageable) //Impossible to destroy
						health -= 10
				if(GRAB_AGGRESSIVE)
					M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					if(prob(50))
						M.KnockDown(1)
					M.apply_damage(10)
					if(!not_damageable) //Impossible to destroy
						health -= 25
				if(GRAB_NECK)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.KnockDown(5)
					M.apply_damage(20)
					if(!not_damageable) //Impossible to destroy
						health -= 50
			healthcheck(1, 1, 1, M) //The person thrown into the window literally shattered it
		return

	if(W.flags_item & NOBLUDGEON) return

	if(istype(W, /obj/item/tool/screwdriver) && !not_deconstructable)
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>")
		else if(reinf && state == 0 && !static_frame)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>")
		else if(!reinf && !static_frame)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>")
		else if(static_frame && state == 0)
			disassemble_window()
	else if(istype(W, /obj/item/tool/crowbar) && reinf && state <= 1 && !not_deconstructable)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
		user << (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>")
	else
		if(!not_damageable) //Impossible to destroy
			health -= W.force
			if(health <= 7  && !reinf && !static_frame && !not_deconstructable)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
		healthcheck(1, 1, 1, user, W)
		..()
	return


/obj/structure/window/proc/disassemble_window()
	if(reinf)
		new /obj/item/stack/sheet/glass/reinforced(loc, 2)
	else
		new /obj/item/stack/sheet/glass/reinforced(loc, 2)
	cdel(src)


/obj/structure/window/proc/shatter_window(create_debris)
	if(create_debris)
		new shardtype(loc)
		if(is_full_window())
			new shardtype(loc)
		if(reinf)
			new /obj/item/stack/rods(loc)
	cdel(src)


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(static_frame)
		return 0
	if(not_deconstructable)
		return 0
	if(anchored)
		usr << "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>"
		return 0

	dir = turn(dir, 90)



/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(static_frame)
		return 0
	if(not_deconstructable)
		return 0
	if(anchored)
		usr << "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>"
		return 0

	dir = turn(dir, 270)


/obj/structure/window/New(Loc, start_dir = null, constructed = 0)
	..()

	//player-constructed windows
	if(constructed)
		anchored = 0

	if(start_dir)
		dir = start_dir

	update_nearby_icons()

/obj/structure/window/Dispose()
	density = 0
	update_nearby_icons()
	. = ..()

/obj/structure/window/Move()
	var/ini_dir = dir
	..()
	dir = ini_dir

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src, direction))
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

/obj/structure/window/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		if(!not_damageable)
			health -= round(exposed_volume / 100)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronbasic
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "phoronwindow"
	icon_state = "phoronwindow"
	shardtype = /obj/item/shard/phoron
	health = 120

/obj/structure/window/phoronbasic/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		health -= round(exposed_volume / 1000)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronreinforced
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window with a rod matrice. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	basestate = "phoronrwindow"
	icon_state = "phoronrwindow"
	shardtype = /obj/item/shard/phoron
	reinf = 1
	health = 160

/obj/structure/window/phoronreinforced/fire_act(exposed_temperature, exposed_volume)
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
	flags_atom = FPRINT

/obj/structure/window/shuttle/update_icon() //icon_state has to be set manually
	return

//Framed windows

/obj/structure/window/framed
	name = "theoretical window"
	layer = TABLE_LAYER
	static_frame = 1
	flags_atom = FPRINT
	var/window_frame //For perspective windows,so the window frame doesn't magically dissapear
	var/list/tiles_special = list(/obj/machinery/door/airlock,
		/obj/structure/window/framed,
		/obj/structure/girder,
		/obj/structure/window_frame)
	tiles_with = list(
		/turf/closed/wall)

/obj/structure/window/framed/New()
	spawn(0)
		relativewall()
		relativewall_neighbours()
	..()

/obj/structure/window/framed/Dispose()
	for(var/obj/effect/alien/weeds/weedwall/window/WW in loc)
		cdel(WW)
	. = ..()


/obj/structure/window/framed/is_full_window()
	return TRUE

/obj/structure/window/framed/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window/framed/update_icon()
	relativewall()


/obj/structure/window/framed/disassemble_window()
	if(window_frame)
		var/obj/structure/window_frame/WF = new window_frame(loc)
		WF.icon_state = "[WF.basestate][junction]_frame"
		WF.dir = dir
	..()

/obj/structure/window/framed/shatter_window(create_debris)
	if(window_frame)
		var/obj/structure/window_frame/new_window_frame = new window_frame(loc, TRUE)
		new_window_frame.icon_state = "[new_window_frame.basestate][junction]_frame"
		new_window_frame.dir = dir
	..()


/obj/structure/window/framed/proc/drop_window_frame()
	if(window_frame)
		var/obj/structure/window_frame/new_window_frame = new window_frame(loc, TRUE)
		new_window_frame.icon_state = "[new_window_frame.basestate][junction]_frame"
		new_window_frame.dir = dir
	cdel(src)

/obj/structure/window/framed/almayer
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "alm_rwindow0"
	basestate = "alm_rwindow"
	health = 100 //Was 600
	reinf = 1
	dir = 5
	window_frame = /obj/structure/window_frame/almayer

/obj/structure/window/framed/almayer/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	not_damageable = 1
	not_deconstructable = 1
	unacidable = 1
	health = 1000000 //Failsafe, shouldn't matter

/obj/structure/window/framed/almayer/requisitions
	name = "ultra-reinforced window"
	desc = "An ultra-reinforced window designed to keep requisitions a secure area."
	not_damageable = 1
	not_deconstructable = 1
	unacidable = 1
	health = 1000000 //Failsafe, shouldn't matter
	window_frame = /obj/structure/window_frame/almayer/requisitions

/obj/structure/window/framed/almayer/white
	icon_state = "white_rwindow0"
	basestate = "white_rwindow"
	window_frame = /obj/structure/window_frame/almayer/white



/obj/structure/window/framed/colony
	name = "window"
	icon_state = "col_window0"
	basestate = "col_window"
	window_frame = /obj/structure/window_frame/colony

/obj/structure/window/framed/colony/reinforced
	name = "reinforced window"
	icon_state = "col_rwindow0"
	basestate = "col_rwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	health = 100
	reinf = 1
	window_frame = /obj/structure/window_frame/colony/reinforced

/obj/structure/window/framed/colony/reinforced/tinted
	name =  "tinted reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it. This one is opaque. You have an uneasy feeling someone might be watching from the other side."
	opacity = 1

/obj/structure/window/framed/colony/reinforced/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	not_damageable = 1
	not_deconstructable = 1
	unacidable = 1
	health = 1000000 //Failsafe, shouldn't matter



//Chigusa windows

/obj/structure/window/framed/chigusa
	name = "reinforced window"
	icon_state = "chig_rwindow0"
	basestate = "chig_rwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	health = 100
	reinf = 1
	window_frame = /obj/structure/window_frame/chigusa



/obj/structure/window/framed/wood
	name = "window"
	icon_state = "wood_window0"
	basestate = "wood_window"
	window_frame = /obj/structure/window_frame/wood

/obj/structure/window/framed/wood/reinforced
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	health = 100
	reinf = 1
	icon_state = "wood_rwindow0"
	basestate = "wood_rwindow"
	window_frame = /obj/structure/window_frame/wood

//Prison windows


/obj/structure/window/framed/prison
	name = "window"
	icon_state = "wood_window0"
	basestate = "wood_window"
	window_frame = /obj/structure/window_frame/prison

/obj/structure/window/framed/prison/reinforced
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	health = 100
	reinf = 1
	icon_state = "prison_rwindow0"
	basestate = "prison_rwindow"
	window_frame = /obj/structure/window_frame/prison/reinforced

/obj/structure/window/framed/prison/reinforced/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one has an automatic shutter system to prevent any atmospheric breach."
	health = 200
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	var/triggered = 0 //indicates if the shutters have already been triggered

/obj/structure/window/framed/prison/reinforced/hull/Dispose()
	spawn_shutters()
	.=..()

/obj/structure/window/framed/prison/reinforced/hull/proc/spawn_shutters(var/from_dir = 0)
	if(triggered)
		return
	else
		triggered = 1
	if(!from_dir) //air escaping sound effect for original window
		playsound(src, 'sound/machines/hiss.ogg', 50, 1)
	for(var/direction in cardinal)
		if(direction == from_dir) continue //doesn't check backwards
		for(var/obj/structure/window/framed/prison/reinforced/hull/W in get_step(src,direction) )
			W.spawn_shutters(turn(direction,180))
	var/obj/machinery/door/poddoor/shutters/almayer/pressure/P = new(get_turf(src))
	switch(junction)
		if(4,5,8,9,12)
			P.dir = 2
		else
			P.dir = 4
	spawn(16)
		P.close()

/obj/structure/window/framed/prison/cell
	name = "cell window"
	icon_state = "prison_cellwindow0"
	basestate = "prison_cellwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	not_damageable = 1
	not_deconstructable = 1
	unacidable = 1
	health = 1000000 //Failsafe, shouldn't matter

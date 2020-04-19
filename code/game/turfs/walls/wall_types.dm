//----- Marine ship walls ---//

/turf/closed/wall/mainship
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/mainshipwalls.dmi'
	icon_state = "testwall0"
	walltype = "testwall"

	max_integrity = 3000 //Wall will break down to girders if damage reaches this point

	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = TRUE
	density = TRUE

/turf/closed/wall/mainship/handle_icon_junction(junction)
	if (!walltype)
		return
	//lets make some detailed randomized shit happen.
	var/r1 = rand(0,10) //Make a random chance for this to happen
	var/r2 = rand(0,3) // Which wall if we do choose it
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "mainship_deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"
	junctiontype = junction

/turf/closed/wall/mainship/nosmooth //for SD and other special walls
	tiles_with = list(/turf/closed/wall,/obj/structure/window/framed,/obj/structure/window_frame,/obj/structure/girder)

/turf/closed/wall/mainship/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	//icon_state = "testwall0_debug" //Uncomment to check hull in the map editor.
	walltype = "testwall"
	hull = 1 //Impossible to destroy or even damage. Used for outer walls that would breach into space, potentially some special walls

/turf/closed/wall/mainship/outer/reinforced
	name = "reinforced hull"

/turf/closed/wall/mainship/white
	walltype = "wwall"
	icon_state = "wwall0"

/turf/closed/wall/mainship/white/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"
	junctiontype = junction



/turf/closed/wall/mainship/research/can_be_dissolved()
	return FALSE

/turf/closed/wall/mainship/research/containment/wall
	name = "cell wall"
	tiles_with = null
	walltype = null

/turf/closed/wall/mainship/research/containment/wall/corner
	icon_state = "containment_wall_corner"

/turf/closed/wall/mainship/research/containment/wall/divide
	icon_state = "containment_wall_divide"

/turf/closed/wall/mainship/research/containment/wall/south
	icon_state = "containment_wall_s"

/turf/closed/wall/mainship/research/containment/wall/west
	icon_state = "containment_wall_w"

/turf/closed/wall/mainship/research/containment/wall/connect_e
	icon_state = "containment_wall_connect_e"

/turf/closed/wall/mainship/research/containment/wall/connect3
	icon_state = "containment_wall_connect3"

/turf/closed/wall/mainship/research/containment/wall/connect_w
	icon_state = "containment_wall_connect_w"

/turf/closed/wall/mainship/research/containment/wall/connect_w2
	icon_state = "containment_wall_connect_w2"

/turf/closed/wall/mainship/research/containment/wall/east
	icon_state = "containment_wall_e"

/turf/closed/wall/mainship/research/containment/wall/north
	icon_state = "containment_wall_n"

/turf/closed/wall/mainship/research/containment/wall/connect_e2
	icon_state = "containment_wall_connect_e2"

/turf/closed/wall/mainship/research/containment/wall/connect_s1
	icon_state = "containment_wall_connect_s1"

/turf/closed/wall/mainship/research/containment/wall/connect_s2
	icon_state = "containment_wall_connect_s2"

/turf/closed/wall/mainship/research/containment/wall/purple
	name = "cell window"
	icon_state = "containment_window"
	opacity = FALSE


/turf/closed/wall/desert
	name = "wall"
	icon = 'icons/turf/chigusa.dmi'
	icon_state = "chigusa0"
	walltype = "chigusa"

/turf/closed/wall/desert/handle_icon_junction(junction)
	if (!walltype)
		return
	//lets make some detailed randomized shit happen.
	var/r1 = rand(0,10) //Make a random chance for this to happen
	var/r2 = rand(0,2) // Which wall if we do choose it
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"

//tyson
/turf/closed/wall/tyson
	name = "outer wall"
	hull = TRUE

/turf/closed/wall/tyson/airlock
	name = "rusted airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	icon_state = "door_locked"

/turf/closed/wall/tyson/airlock/maint
	icon = 'icons/obj/doors/Doormaint.dmi'

/turf/closed/wall/tyson/poddoor
	name = "rusted poddoor"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"

/turf/closed/wall/tyson/r_wall
	icon_state = "rwall"

//Sulaco walls.
/turf/closed/wall/sulaco
	name = "spaceship hull"
	desc = "A huge chunk of metal used to separate rooms on spaceships from the cold void of space."
	icon = 'icons/turf/walls.dmi'
	icon_state = "sulaco0"
	hull = 0 //Can't be deconstructed

	max_integrity = 3000
	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this
	walltype = "sulaco" //Changes all the sprites and icons.


/turf/closed/wall/sulaco/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/open/floor/plating)
		if(2)
			if(prob(75))
				take_damage(rand(100, 250))
			else
				dismantle_wall(1, 1)
		if(3)
			take_damage(rand(0, 250))
	return

/turf/closed/wall/sulaco/hull
	name = "outer hull"
	desc = "A reinforced outer hull, probably to prevent breaches"
	hull = 1
	max_temperature = 50000 // Nearly impossible to melt
	walltype = "sulaco"


/turf/closed/wall/sulaco/unmeltable

/turf/closed/wall/sulaco/unmeltable/ex_act(severity) //Should make it indestructable
	return

/turf/closed/wall/sulaco/unmeltable/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/sulaco/unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return

/turf/closed/wall/sulaco/unmeltable/can_be_dissolved()
	return FALSE



/turf/closed/wall/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = TRUE
	hull = 1

/turf/closed/wall/indestructible/ex_act(severity)
	return

/turf/closed/wall/indestructible/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/indestructible/attackby(obj/item/I, mob/user, params)
	return

/turf/closed/wall/indestructible/can_be_dissolved()
	return 0

/turf/closed/wall/indestructible/mineral
	name = "impenetrable rock"
	icon_state = "rock_dark"

/turf/closed/wall/indestructible/bulkhead
	name = "bulkhead"
	desc = "It is a large metal bulkhead."
	icon_state = "hull"

/turf/closed/wall/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = FALSE

/turf/closed/wall/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/title.dmi'
	icon_state = "title_painting1"
//	icon_state = "title_holiday"
	layer = FLY_LAYER

/turf/closed/wall/indestructible/splashscreen/New()
	..()
	if(icon_state == "title_painting1")
		icon_state = "title_painting[rand(1,10)]"

/turf/closed/wall/indestructible/other
	icon_state = "r_wall"

// Mineral Walls

/turf/closed/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/mineral
	var/last_event = 0
	var/active = null
	tiles_with = list(/turf/closed/wall/mineral)

/turf/closed/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"
	//var/electro = 1
	//var/shocked = null

/turf/closed/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/closed/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"

/turf/closed/wall/mineral/diamond/thermitemelt(mob/user)
	return


/turf/closed/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"

/turf/closed/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"

/turf/closed/wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12, IRRADIATE)
				UPDATEHEALTH(L)
			for(var/turf/closed/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/closed/wall/mineral/uranium/attack_hand(mob/living/user)
	radiate()
	return ..()

/turf/closed/wall/mineral/uranium/attackby(obj/item/I, mob/user, params)
	. = ..()
	radiate()

/turf/closed/wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/closed/wall/mineral/phoron
	name = "phoron wall"
	desc = "A wall with phoron plating. This is definately a bad idea."
	icon_state = "phoron0"
	walltype = "phoron"
	mineral = "phoron"





//Misc walls

/turf/closed/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult0"
	walltype = "cult"


/turf/closed/wall/vault
	icon_state = "rockvault"

/turf/closed/wall/vault/New(location,type)
	..()
	icon_state = "[type]vault"




//Prison wall

/turf/closed/wall/prison
	name = "metal wall"
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "metal0"
	walltype = "metal"



//Wood wall

/turf/closed/wall/wood
	name = "wood wall"
	icon = 'icons/turf/wood.dmi'
	icon_state = "wood0"
	walltype = "wood"

/turf/closed/wall/wood/handle_icon_junction(junction)
	if (!walltype)
		return

	var/r1 = rand(0,10) //Make a random chance for this to happen
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "wood_variant"
	else
		icon_state = "[walltype][junction]"




//Xenomorph's Resin Walls

/turf/closed/wall/resin
	name = "resin wall"
	desc = "Weird slime solidified into a wall."
	icon = 'icons/Xeno/structures.dmi'
	icon_state = "resin0"
	walltype = "resin"
	max_integrity = 200
	layer = RESIN_STRUCTURE_LAYER
	tiles_with = list(/turf/closed/wall/resin, /turf/closed/wall/resin/membrane, /obj/structure/mineral_door/resin)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)


/turf/closed/wall/resin/New()
	..()
	if(!locate(/obj/effect/alien/weeds) in loc)
		new /obj/effect/alien/weeds(loc)

/turf/closed/wall/resin/ChangeTurf(path, new_baseturf, flags)
	. = ..()
	new /obj/effect/alien/weeds(.)

/turf/closed/wall/resin/flamer_fire_act()
	take_damage(50, BURN, "fire")

/turf/closed/wall/resin/proc/thicken()
	ChangeTurf(/turf/closed/wall/resin/thick)
	return TRUE

/turf/closed/wall/resin/thick
	name = "thick resin wall"
	desc = "Weird slime solidified into a thick wall."
	max_integrity = 300
	icon_state = "thickresin0"
	walltype = "thickresin"

/turf/closed/wall/resin/thick/thicken()
	return FALSE

/turf/closed/wall/resin/membrane
	name = "resin membrane"
	desc = "Weird slime translucent enough to let light pass through."
	icon_state = "membrane0"
	walltype = "membrane"
	max_integrity = 120
	opacity = FALSE
	alpha = 180

/turf/closed/wall/resin/membrane/thicken()
	ChangeTurf(/turf/closed/wall/resin/membrane/thick)


/turf/closed/wall/resin/membrane/thick
	name = "thick resin membrane"
	desc = "Weird thick slime just translucent enough to let light pass through."
	max_integrity = 240
	icon_state = "thickmembrane0"
	walltype = "thickmembrane"
	alpha = 210


/turf/closed/wall/resin/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(500)
		if(2)
			take_damage(rand(140, 300))
		if(3)
			take_damage(rand(50, 100))


/turf/closed/wall/resin/attack_alien(mob/living/carbon/xenomorph/M)
	M.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	M.visible_message("<span class='xenonotice'>\The [M] claws \the [src]!</span>", \
	"<span class='xenonotice'>We claw \the [src].</span>")
	playsound(src, "alien_resin_break", 25)
	take_damage(M.melee_damage + 50) //Beef up the damage a bit


/turf/closed/wall/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE


/turf/closed/wall/resin/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == "fire") //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage)
	playsound(src, "alien_resin_break", 25)


/turf/closed/wall/resin/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return !opacity
	return !density

/turf/closed/wall/resin/dismantle_wall(devastated = 0, explode = 0)
	ScrapeAway()


/turf/closed/wall/resin/ChangeTurf(newtype)
	. = ..()
	if(.)
		var/turf/T
		for(var/i in GLOB.cardinals)
			T = get_step(src, i)
			if(!istype(T))
				continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()




/turf/closed/wall/resin/can_be_dissolved()
	return FALSE





//-----USS Almayer Walls ---//

/turf/closed/wall/almayer
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "testwall0"
	walltype = "testwall"

	damage = 0
	damage_cap = 10000 //Wall will break down to girders if damage reaches this point

	max_temperature = 18000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = 1
	density = 1

/turf/closed/wall/almayer/handle_icon_junction(junction)
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
				icon_state = "almayer_deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"
	junctiontype = junction

/turf/closed/wall/almayer/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	//icon_state = "testwall0_debug" //Uncomment to check hull in the map editor.
	walltype = "testwall"
	hull = 1 //Impossible to destroy or even damage. Used for outer walls that would breach into space, potentially some special walls

/turf/closed/wall/almayer/white
	walltype = "wwall"
	icon_state = "wwall0"

/turf/closed/wall/almayer/white/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"
	junctiontype = junction



/turf/closed/wall/almayer/research/can_be_dissolved()
	return 0

/turf/closed/wall/almayer/research/containment/wall
	name = "cell wall"
	tiles_with = null
	walltype = null

/turf/closed/wall/almayer/research/containment/wall/corner
	icon_state = "containment_wall_corner"

/turf/closed/wall/almayer/research/containment/wall/divide
	icon_state = "containment_wall_divide"

/turf/closed/wall/almayer/research/containment/wall/south
	icon_state = "containment_wall_south"

/turf/closed/wall/almayer/research/containment/wall/west
	icon_state = "containment_wall_w"

/turf/closed/wall/almayer/research/containment/wall/connect_e
	icon_state = "containment_wall_connect_e"

/turf/closed/wall/almayer/research/containment/wall/connect3
	icon_state = "containment_wall_connect3"

/turf/closed/wall/almayer/research/containment/wall/connect_w
	icon_state = "containment_wall_connect_w"

/turf/closed/wall/almayer/research/containment/wall/connect_w2
	icon_state = "containment_wall_connect_w2"

/turf/closed/wall/almayer/research/containment/wall/east
	icon_state = "containment_wall_e"

/turf/closed/wall/almayer/research/containment/wall/north
	icon_state = "containment_wall_n"

/turf/closed/wall/almayer/research/containment/wall/connect_e2
	name = "\improper cell wall."
	icon_state = "containment_wall_connect_e2"

/turf/closed/wall/almayer/research/containment/wall/connect_s1
	icon_state = "containment_wall_connect_s1"

/turf/closed/wall/almayer/research/containment/wall/connect_s2
	icon_state = "containment_wall_connect_s2"

/turf/closed/wall/almayer/research/containment/wall/purple
	name = "cell window"
	icon_state = "containment_window"
	opacity = 0




//Sulaco walls.
/turf/closed/wall/sulaco
	name = "spaceship hull"
	desc = "A huge chunk of metal used to separate rooms on spaceships from the cold void of space."
	icon = 'icons/turf/walls.dmi'
	icon_state = "sulaco0"
	hull = 0 //Can't be deconstructed

	damage_cap = 8000 //As tough as R_walls.
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

/turf/closed/wall/sulaco/unmeltable/attackby() //This should fix everything else. No cables, etc
	return

/turf/closed/wall/sulaco/unmeltable/can_be_dissolved()
	return 0








/turf/closed/wall/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	hull = 1

/turf/closed/wall/indestructible/ex_act(severity) //Should make it indestructable
	return

/turf/closed/wall/indestructible/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/indestructible/attackby() //This should fix everything else. No cables, etc
	return

/turf/closed/wall/indestructible/can_be_dissolved()
	return 0



/turf/closed/wall/indestructible/bulkhead
	name = "bulkhead"
	desc = "It is a large metal bulkhead."
	icon_state = "hull"

/turf/closed/wall/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/closed/wall/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/title.dmi'
	icon_state = "title_painting1"
//	icon_state = "title_holiday"
	layer = FLY_LAYER

/turf/closed/wall/indestructible/splashscreen/New()
	..()
	if(icon_state == "title_painting1") // default
		icon_state = "title_painting[rand(1,4)]"

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
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/closed/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/closed/wall/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/turf/closed/wall/mineral/uranium/attackby(obj/item/W as obj, mob/user as mob)
	radiate()
	..()

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
	damage_cap = 200
	layer = RESIN_STRUCTURE_LAYER
	tiles_with = list(/turf/closed/wall/resin, /turf/closed/wall/resin/membrane, /obj/structure/mineral_door/resin)

/turf/closed/wall/resin/New()
	..()
	if(!locate(/obj/effect/alien/weeds) in loc)
		new /obj/effect/alien/weeds(loc)

/turf/closed/wall/resin/flamer_fire_act()
	take_damage(50)

//this one is only for map use
/turf/closed/wall/resin/ondirt
	oldTurf = "/turf/open/gm/dirt"

/turf/closed/wall/resin/thick
	name = "thick resin wall"
	desc = "Weird slime solidified into a thick wall."
	damage_cap = 400
	icon_state = "thickresin0"
	walltype = "thickresin"

/turf/closed/wall/resin/membrane
	name = "resin membrane"
	desc = "Weird slime translucent enough to let light pass through."
	icon_state = "membrane0"
	walltype = "membrane"
	damage_cap = 120
	opacity = 0
	alpha = 180

//this one is only for map use
/turf/closed/wall/resin/membrane/ondirt
	oldTurf = "/turf/open/gm/dirt"

/turf/closed/wall/resin/membrane/thick
	name = "thick resin membrane"
	desc = "Weird thick slime just translucent enough to let light pass through."
	damage_cap = 240
	icon_state = "thickmembrane0"
	walltype = "thickmembrane"
	alpha = 210

/turf/closed/wall/resin/bullet_act(var/obj/item/projectile/Proj)
	take_damage(Proj.damage/2)
	..()

	return 1

/turf/closed/wall/resin/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(500)
		if(2)
			take_damage(rand(140, 300))
		if(3)
			take_damage(rand(50, 100))


/turf/closed/wall/resin/hitby(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/Xenomorph))
		return
	visible_message("<span class='danger'>\The [src] was hit by \the [AM].</span>", \
	"<span class='danger'>You hit \the [src].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src, "alien_resin_break", 25)
	take_damage(max(0, damage_cap - tforce))


/turf/closed/wall/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return 0
	M.animation_attack_on(src)
	M.visible_message("<span class='xenonotice'>\The [M] claws \the [src]!</span>", \
	"<span class='xenonotice'>You claw \the [src].</span>")
	playsound(src, "alien_resin_break", 25)
	take_damage((M.melee_damage_upper + 50)) //Beef up the damage a bit


/turf/closed/wall/resin/attack_animal(mob/living/M)
	M.visible_message("<span class='danger'>[M] tears \the [src]!</span>", \
	"<span class='danger'>You tear \the [name].</span>")
	playsound(src, "alien_resin_break", 25)
	M.animation_attack_on(src)
	take_damage(40)


/turf/closed/wall/resin/attack_hand(mob/user)
	user << "<span class='warning'>You scrape ineffectively at \the [src].</span>"


/turf/closed/wall/resin/attack_paw(mob/user)
	return attack_hand(user)


/turf/closed/wall/resin/attackby(obj/item/W, mob/living/user)
	if(!(W.flags_item & NOBLUDGEON))
		user.animation_attack_on(src)
		take_damage(W.force)
		playsound(src, "alien_resin_break", 25)
	else
		return attack_hand(user)

/turf/closed/wall/resin/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/turf/closed/wall/resin/dismantle_wall(devastated = 0, explode = 0)
	cdel(src) //ChangeTurf is called by Dispose()



/turf/closed/wall/resin/ChangeTurf(newtype)
	. = ..()
	if(.)
		var/turf/T
		for(var/i in cardinal)
			T = get_step(src, i)
			if(!istype(T)) continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()




/turf/closed/wall/resin/can_be_dissolved()
	return FALSE

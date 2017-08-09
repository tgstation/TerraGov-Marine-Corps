/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = "0"
	var/mineral = "metal"
	var/rotting = 0
	var/hull = 0 //1 = Can't be deconstructed by tools or thermite. Used for Sulaco walls

	tiles_with = list(/turf/simulated/wall)

	var/damage = 0
	var/damage_cap = 1000 //Wall will break down to girders if damage reaches this point

	var/damage_overlay
	var/global/damage_overlays[8]

	var/current_bulletholes = 0
	var/bullethole_increment = 1
	var/bullethole_state = 0
	var/image/reusable/bullethole_overlay

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	var/d_state = 0 //Normal walls are now as difficult to remove as reinforced walls
	var/d_sleep = 60 //The time in deciseconds it takes for each step of wall deconstruction

	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"

/turf/simulated/wall/New()
	..()
	for(var/obj/item/device/mine/M in src)
		if(M)
			visible_message("<span class='warning'>\The [M] is sealed inside the wall as it is built</span>")
			cdel(M)

/turf/simulated/wall/Dispose()
	for(var/obj/effect/E in src) if(E.name == "Wallrot") cdel(E)
	. = ..()

/turf/simulated/wall/ChangeTurf(var/newtype)
	for(var/obj/effect/E in src) if(E.name == "Wallrot") cdel(E)
	..(newtype)

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..()

	if(!damage)
		user << "<span class='notice'>It looks fully intact.</span>"
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			user << "<span class='warning'>It looks slightly damaged.</span>"
		else if(dam <= 0.6)
			user << "<span class='warning'>It looks moderately damaged.</span>"
		else
			user << "<span class='danger'>It looks heavily damaged.</span>"

	if(rotting)
		user << "<span class='warning'>There is fungus growing on [src].</span>"

	switch(d_state)
		if(1)
			user << "<span class='info'>The outer plating has been sliced open. A screwdriver should remove the support lines.</span>"
		if(2)
			user << "<span class='info'>The support lines have been removed. A blowtorch should slice through the metal cover.</span>"
		if(3)
			user << "<span class='info'>The metal cover has been sliced through. A crowbar should pry it off.</span>"
		if(4)
			user << "<span class='info'>The metal cover has been removed. A wrench will remove the anchor bolts.</span>"
		if(5)
			user << "<span class='info'>The anchor bolts have been removed. Wirecutters will take care of the hydraulic lines.</span>"
		if(6)
			user << "<span class='info'>Hydraulic lines are gone. A crowbar will pry off the inner sheath.</span>"
		if(7)
			user << "<span class='info'>The inner sheath is gone. A blowtorch should finish off this wall.</span>"

#define BULLETHOLE_STATES 10 //How many variations of bullethole patterns there are
#define BULLETHOLE_MAX 8 * 3 //Maximum possible bullet holes.
//Formulas. These don't need to be defines, but helpful green. Should likely reuse these for a base 8 icon system.
#define cur_increment(v) round((v-1)/8)+1
#define base_dir(v,i) v-(i-1)*8
#define cur_dir(v) round(v+round(v)/3)

/turf/simulated/wall/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	if(!damage) //If the thing was healed for damage; otherwise update_icon() won't run at all, unless it was strictly damaged.
		overlays.Cut()
		damage_overlay = initial(damage_overlay)
		current_bulletholes = initial(current_bulletholes)
		bullethole_increment = initial(current_bulletholes)
		bullethole_state = initial(current_bulletholes)
		cdel(bullethole_overlay)
		bullethole_overlay = null
		return

	var/overlay = round(damage / damage_cap * damage_overlays.len) + 1
	if(overlay > damage_overlays.len) overlay = damage_overlays.len

	if(!damage_overlay || overlay != damage_overlay)
		overlays -= damage_overlays[damage_overlay]
		damage_overlay = overlay
		overlays += damage_overlays[damage_overlay]

		if(current_bulletholes > BULLETHOLE_MAX) //Could probably get away with a unique layer, but let's keep it standardized.
			overlays -= bullethole_overlay //We need this to be the top layer, no matter what, but only if the layer is at max bulletholes.
			overlays += bullethole_overlay

	if(current_bulletholes && current_bulletholes <= BULLETHOLE_MAX)
		overlays -= bullethole_overlay
		if(!bullethole_overlay)
			bullethole_state = rand(1, BULLETHOLE_STATES)
			bullethole_overlay = rnew(/image/reusable, list('icons/effects/bulletholes.dmi', src, "bhole_[bullethole_state]_[bullethole_increment]"))
			//for(var/mob/M in view(7)) M << bullethole_overlay
		if(cur_increment(current_bulletholes) > bullethole_increment) bullethole_overlay.icon_state = "bhole_[bullethole_state]_[++bullethole_increment]"

		var/base_direction = base_dir(current_bulletholes,bullethole_increment)
		var/current_direction = cur_dir(base_direction)
		dir = current_direction
		/*Hack. Image overlays behave as the parent object, so that means they are also attached to it and follow its directional.
		Luckily, it doesn't matter what direction the walls are set to, they link together via icon_state it seems.
		But I haven't thoroughly tested it.*/
		overlays += bullethole_overlay
		//world << "<span class='debuginfo'>Increment: <b>[bullethole_increment]</b>, Direction: <b>[current_direction]</b></span>"

#undef BULLETHOLE_STATES
#undef BULLETHOLE_MAX
#undef cur_increment
#undef base_dir
#undef cur_dir

/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

//Damage
/turf/simulated/wall/proc/take_damage(dam)
	if(hull) //Hull is literally invincible
		return
	if(dam) damage = max(0, damage + dam)
	var/cap = damage_cap
	if(rotting) cap = cap / 10
	if(damage >= cap) dismantle_wall()
	else if(dam) update_icon()

	return

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	if(adj_temp > max_temperature && !hull)
		take_damage(rand(10, 20) * (adj_temp / max_temperature))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(devastated = 0, explode = 0)
	if(hull) //Hull is literally invincible
		return
	if(istype(src, /turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel(src)
		else
			new /obj/item/stack/sheet/metal(src)
			new /obj/item/stack/sheet/metal(src)
			new /obj/item/stack/sheet/plasteel(src)
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			new /obj/structure/girder(src)
			if(mineral == "metal")
				new /obj/item/stack/sheet/metal(src)
				new /obj/item/stack/sheet/metal(src)
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M(src)
				new M(src)
		else
			if(mineral == "metal")
				new /obj/item/stack/sheet/metal(src)
				new /obj/item/stack/sheet/metal(src)
				new /obj/item/stack/sheet/metal(src)
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M(src)
				new M(src)
				new /obj/item/stack/sheet/metal(src)

	for(var/obj/O in contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	if(oldTurf != "") ChangeTurf(text2path(oldTurf))
	else ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	if(hull)
		return
	switch(severity)
		if(1)
			ChangeTurf(/turf/simulated/floor/plating)
		if(2)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1, 1)
		if(3)
			take_damage(rand(0, 250))
		else
	return

//Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting && !hull)
		rotting = 1

		var/number_rots = rand(2, 3)
		for(var/i = 0, i < number_rots, i++)
			var/obj/effect/overlay/O = new/obj/effect/overlay(src)
			O.name = "Wallrot"
			O.desc = "Yuck"
			O.icon = 'icons/effects/wallrot.dmi'
			O.pixel_x += rand(-10, 10)
			O.pixel_y += rand(-10, 10)
			O.anchored = 1
			O.density = 1
			O.layer = 5
			O.mouse_opacity = 0

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(mineral == "diamond" || hull)
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite starts melting through [src].</span>"

	spawn(100)
		if(O) cdel(O)
	return

//Interactions
/turf/simulated/wall/attack_paw(mob/user as mob)
	if((HULK in user.mutations))
		if(prob(40))
			user.visible_message("<span class='danger'>[user] smashes through [src].</span>",
			"<span class='danger'>You smash through the wall.</span>")
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			dismantle_wall(1)
			return
		else
			user.visible_message("<span class='warning'>[user] punches [src].</span>",
			"<span class='warning'>You punch the wall.</span>")
			take_damage(rand(25, 75))
			return

	return attack_hand(user)


/turf/simulated/wall/attack_animal(mob/living/M as mob)
	if(M.wall_smash)
		if((istype(src, /turf/simulated/wall/r_wall) && !rotting) || hull)
			M << "<span class='warning'>This [name] is far too strong for you to destroy.</span>"
			return
		else
			if((prob(40) || rotting) && !hull)
				M.visible_message("<span class='danger'>[M] smashes through [src].</span>",
				"<span class='danger'>You smash through the wall.</span>")
				dismantle_wall(1)
				return
			else
				M.visible_message("<span class='warning'>[M] smashes against [src].</span>",
				"<span class='warning'>You smash against the wall.</span>")
				take_damage(rand(25, 75))
				return

	M.visible_message("<span class='notice'>[M] pushes against [src].</span>",
	"<span class='notice'>You push against [src] but nothing happens.</span>")
	return

/turf/simulated/wall/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		if((prob(40) || rotting) && !hull)
			user.visible_message("<span class='danger'>[user] smashes through [src].</span>",
			"<span class='danger'>You smash through [src].</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			dismantle_wall(1)
			return
		else
			user.visible_message("<span class='warning'>[user] punches [src].</span>",
			"<span class='warning'>You punch [src].</span>")
			take_damage(rand(25, 75))
			return

	if(rotting && !hull)
		user << "<span class='warning'>[src] crumbles under your touch.</span>"
		dismantle_wall()
		return

	user << "<span class='notice'>You push [src] but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!(ishuman(user) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//Get the user's location
	if(!istype(user.loc, /turf)) return	//Can't do this stuff whilst inside objects and such

	if(rotting)
		if(W.heat_source >= 3000)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				WT.remove_fuel(0,user)
			user << "<span class='notice'>You burn away the fungi with \the [W].</span>"
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			for(var/obj/effect/E in src) if(E.name == "Wallrot")
				cdel(E)
			rotting = 0
			return
		else if((!is_sharp(W) && W.force >= 10 || W.force >= 20) && !hull)
			user << "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>"
			dismantle_wall(1)
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(W.heat_source >= 1000)
			if(hull)
				user << "<span class='warning'>[src] is much too tough for you to do anything to it with [W]</span>."
			else
				if(istype(W, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					WT.remove_fuel(0,user)
				thermitemelt(user)
			return

	if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/rust_fuel_compressor_frame))
		var/obj/item/rust_fuel_compressor_frame/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/rust_fuel_assembly_port_frame))
		var/obj/item/rust_fuel_assembly_port_frame/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	if(hull)
		user << "<span class='warning'>[src] is much too tough for you to do anything to it with [W]</span>."
		return

	if(damage && istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			user.visible_message("<span class='notice'>[user] starts repairing the damage to [src].</span>",
			"<span class='notice'>You start repairing the damage to [src].</span>")
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			if(do_after(user, max(5, damage / 5, TRUE, 5, BUSY_ICON_CLOCK)) && WT && WT.isOn())
				user.visible_message("<span class='notice'>[user] finishes repairing the damage to [src].</span>",
				"<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			return

	var/turf/T = user.loc //Get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if(istype(W, /obj/item/weapon/weldingtool))

				var/obj/item/weapon/weldingtool/WT = W
				playsound(src, 'sound/items/Welder.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] begins slicing through the outer plating.</span>",
				"<span class='notice'>You begin slicing through the outer plating.</span>")

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T)	return

					if(!d_state && user.loc == T && user.get_active_hand() == WT)
						d_state++
						user.visible_message("<span class='notice'>[user] slices through the outer plating.</span>",
						"<span class='notice'>You slice through the outer plating.</span>")
				return

		if(1)
			if(istype(W, /obj/item/weapon/screwdriver))

				user.visible_message("<span class='notice'>[user] begins removing the support lines.</span>",
				"<span class='notice'>You begin removing the support lines.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !W || !T) return

					if(d_state == 1 && user.loc == T && user.get_active_hand() == W)
						d_state++
						user.visible_message("<span class='notice'>[user] removes the support lines.</span>",
						"<span class='notice'>You remove the support lines.</span>")
				return

		if(2)
			if(istype(W, /obj/item/weapon/weldingtool))

				var/obj/item/weapon/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins slicing through the metal cover.</span>",
				"<span class='notice'>You begin slicing through the metal cover.</span>")
				playsound(src, 'sound/items/Welder.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T)	return

					if(d_state == 2 && user.loc == T && user.get_active_hand() == WT)
						d_state++
						user.visible_message("<span class='notice'>[user] presses firmly on the cover, dislodging it.</span>",
						"<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

		if(3)
			if(istype(W, /obj/item/weapon/crowbar))

				user.visible_message("<span class='notice'>[user] struggles to pry off the cover.</span>",
				"<span class='notice'>You struggle to pry off the cover.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !W || !T) return

					if(d_state == 3 && user.loc == T && user.get_active_hand() == W)
						d_state++
						user.visible_message("<span class='notice'>[user] pries off the cover.</span>",
						"<span class='notice'>You pry off the cover.</span>")
				return

		if(4)
			if(istype(W, /obj/item/weapon/wrench))

				user.visible_message("<span class='notice'>[user] starts loosening the anchoring bolts securing the support rods.</span>",
				"<span class='notice'>You start loosening the anchoring bolts securing the support rods.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !W || !T) return

					if(d_state == 4 && user.loc == T && user.get_active_hand() == W)
						d_state++
						user.visible_message("<span class='notice'>[user] removes the bolts anchoring the support rods.</span>",
						"<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

		if(5)
			if(istype(W, /obj/item/weapon/wirecutters))

				user.visible_message("<span class='notice'>[user] begins uncrimping the hydraulic lines.</span>",
				"<span class='notice'>You begin uncrimping the hydraulic lines.</span>")
				playsound(src, 'sound/items/Wirecutter.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !W || !T) return

					if(d_state == 5 && user.loc == T && user.get_active_hand() == W)
						d_state++
						user.visible_message("<span class='notice'>[user] finishes uncrimping the hydraulic lines.</span>",
						"<span class='notice'>You finish uncrimping the hydraulic lines.</span>")
				return

		if(6)
			if(istype(W, /obj/item/weapon/crowbar))

				user.visible_message("<span class='notice'>[user] struggles to pry off the inner sheath.</span>",
				"<span class='notice'>You struggle to pry off the inner sheath.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !W || !T) return

					if(d_state == 6 && user.loc == T && user.get_active_hand() == W)
						d_state++
						user.visible_message("<span class='notice'>[user] pries off the inner sheath.</span>",
						"<span class='notice'>You pry off the inner sheath.</span>")
				return

		if(7)
			if(istype(W, /obj/item/weapon/weldingtool))

				var/obj/item/weapon/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins slicing through the final layer.</span>",
				"<span class='notice'>You begin slicing through the final layer.</span>")
				playsound(src, 'sound/items/Welder.ogg', 25, 1)

				if(do_after(user, d_sleep, TRUE, 5, BUSY_ICON_CLOCK))
					if(!istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T)	return

					if(d_state == 7 && user.loc == T && user.get_active_hand() == WT)
						new /obj/item/stack/rods(src)
						user.visible_message("<span class='notice'>The support rods drop out as [user] slices through the final layer.</span>",
						"<span class='notice'>The support rods drop out as you slice through the final layer.</span>")
						dismantle_wall()
				return

	return attack_hand(user)

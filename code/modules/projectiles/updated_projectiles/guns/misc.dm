//-------------------------------------------------------
//ENERGY GUNS/ETC
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=1;materials=1"
	matter = list("metal" = 40000)
	ammo = /datum/ammo/energy/taser
	var/obj/item/weapon/cell/high/cell //10000 power.
	var/charge_cost = 100 //100 shots.
	flags_gun_features = GUN_UNUSUAL_DESIGN

	New()
		..()
		fire_delay = config.high_fire_delay * 2
		cell = new /obj/item/weapon/cell/high(src)

	update_icon()
		icon_state = (!cell || cell.charge - charge_cost < 0) ? icon_state + "_e" : initial(icon_state)

	emp_act(severity)
		cell.use(round(cell.maxcharge / severity))
		update_icon()
		..()

	able_to_fire(mob/living/carbon/human/user as mob)
		if(..()) //Let's check all that other stuff first.
			if(istype(user))
				var/obj/item/weapon/card/id/card = user.wear_id
				if(istype(card) && (card.assignment == "Military Police" || card.assignment == "Chief MP")) return 1//We can check for access, but only MPs have access to it.
				else user << "<span class='warning'>[src] is ID locked!</span>"

	load_into_chamber()
		if(!cell || cell.charge - charge_cost < 0) return

		cell.charge -= charge_cost
		in_chamber = create_bullet(ammo)
		return in_chamber

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) cell.charge += charge_cost
		return 1

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "\improper CHIMP70 magazine (.70M)"
	default_ammo = /datum/ammo/bullet/pistol/mankey
	caliber = ".70M"
	icon_state = "c70" //PLACEHOLDER
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	matter = list("metal" = 100000)
	max_rounds = 300
	gun_type = /obj/item/weapon/gun/pistol/chimp

/obj/item/weapon/gun/pistol/chimp
	name = "\improper CHIMP70 pistol"
	desc = "A powerful sidearm issued mainly to highly trained elite assassin necro-cyber-agents."
	icon_state = "c70"
	item_state = "c70"
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	current_mag = /obj/item/ammo_magazine/pistol/chimp
	fire_sound = 'sound/weapons/gun_chimp70.ogg'
	w_class = 3
	force = 8
	type_of_casings = null
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WY_RESTRICTED

	New()
		..()
		fire_delay = config.low_fire_delay
		burst_delay = config.mlow_fire_delay
		burst_amount = config.low_burst_value

//-------------------------------------------------------

/obj/item/weapon/gun/flare
	name = "flare gun"
	desc = "A gun that fires flares. Replace with flares. Simple!"
	icon_state = "flaregun" //REPLACE THIS
	item_state = "gun" //YUCK
	fire_sound = 'sound/weapons/gun_flare.ogg'
	origin_tech = "combat=1;materials=2"
	ammo = /datum/ammo/flare
	var/num_flares = 1
	var/max_flares = 1
	flags_gun_features = GUN_UNUSUAL_DESIGN

	examine(mob/user)
		..()
		fire_delay = config.low_fire_delay*3
		if(num_flares)
			user << "<span class='warning'>It has a flare loaded!</span>"

	update_icon()
		icon_state = num_flares ? initial(icon_state) : icon_state + "_e"

	load_into_chamber()
		if(num_flares)
			in_chamber = create_bullet(ammo)
			in_chamber.SetLuminosity(4)
			num_flares--
			return in_chamber

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) num_flares++
		return 1

	attackby(obj/item/I, mob/user)
		if(istype(I,/obj/item/device/flashlight/flare))
			var/obj/item/device/flashlight/flare/flare = I
			if(num_flares >= max_flares)
				user << "It's already full."
				return

			if(flare.on)
				user << "<span class='warning'>[flare] is already active. Can't load it now!</span>"
				return

			num_flares++
			user.temp_drop_inv_item(flare)
			sleep(-1)
			cdel(flare)
			user << "<span class='notice'>You insert the flare.</span>"
			update_icon()
			return

		return ..()

	unload(mob/user)
		if(num_flares)
			var/obj/item/device/flashlight/flare/new_flare = new()
			if(user) user.put_in_hands(new_flare)
			else new_flare.loc = get_turf(src)
			num_flares--
			if(user) user << "<span class='notice'>You unload a flare from [src].</span>"
			update_icon()
		else user << "<span class='warning'>It's empty!</span>"

//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/ammo_magazine/minigun
	name = "rotating ammo drum (7.62x51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62x51mm"
	icon_state = "painless" //PLACEHOLDER
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 100000)
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	reload_delay = 24 //Hard to reload.
	gun_type = /obj/item/weapon/gun/minigun

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. This thing will no doubt pack a punch."
	icon_state = "painless"
	item_state = "painless"
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/gun_minigun.ogg'
	cocked_sound = 'sound/weapons/gun_minigun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	type_of_casings = "cartridge"
	w_class = 5
	force = 20
	flags_atom = FPRINT|CONDUCT|TWOHANDED
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_BURST_ON

	New(loc, spawn_empty)
		..()
		recoil = config.med_recoil_value
		accuracy -= config.med_hit_accuracy_mult
		burst_amount = config.max_burst_value
		fire_delay = config.low_fire_delay
		burst_delay = config.min_fire_delay
		if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

	toggle_burst()
		usr << "<span class='warning'>This weapon can only fire in bursts!</span>"

//-------------------------------------------------------
//Toy rocket launcher.

/obj/item/weapon/gun/launcher/rocket/nobugs //Fires dummy rockets, like a toy gun
	name = "\improper BUG ROCKER rocket launcher"
	desc = "Where did this come from? <b>NO BUGS</b>"
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket/nobugs

/obj/item/ammo_magazine/rocket/nobugs
	name = "\improper BUG ROCKER rocket tube"
	desc = "Where did this come from? <b>NO BUGS</b>"
	default_ammo = /datum/ammo/rocket/nobugs
	caliber = "toy rocket"

/obj/item/ammo_magazine/internal/launcher/rocket/nobugs
	default_ammo = /datum/ammo/rocket/nobugs
	gun_type = /obj/item/weapon/gun/launcher/rocket/nobugs

/datum/ammo/rocket/nobugs
	name = "\improper NO BUGS rocket"
	damage = 1

	on_hit_mob(mob/M,obj/item/projectile/P)
		M << "<font size=6 color=red>NO BUGS</font>"

	on_hit_obj(obj/O,obj/item/projectile/P)
		return

	on_hit_turf(turf/T,obj/item/projectile/P)
		return

	do_at_max_range(obj/item/projectile/P)
		return

//TODO Convert to config values. Make sure ammo takes care of all the effects. Make sure that attached flamers work on the same principle.
//-------------------------------------------------------
//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually Ultra Thick Napthal Fuel,a sticky combustable liquid chemical, for use in the M240 incinerator unit. Handle with care."
	icon_state = "flametank"
	default_ammo = /datum/ammo/flamethrower //doesn't actually need bullets. But we'll get null ammo error messages if we don't
	max_rounds = 60 //Per turf.
	current_rounds = 60
	w_class = 3.0 //making sure you can't sneak this onto your belt.
	gun_type = /obj/item/weapon/gun/flamer
	caliber = "UT-Napthal Fuel" //Ultra Thick Napthal Fuel, from the lore book.
	flags_magazine = NOFLAGS

	//TODO Change this.
	afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.
		if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
			var/obj/structure/reagent_dispensers/fueltank/FT = target
			if(current_rounds)
				user << "<span class='warning'>You can't mix fuel mixtures!</span>"
				return
			var/fuel_available = FT.reagents.get_reagent_amount("fuel") < max_rounds ? FT.reagents.get_reagent_amount("fuel") : max_rounds
			if(!fuel_available)
				user << "<span class='warning'>[FT] is empty!</span>"
				return

			FT.reagents.remove_reagent("fuel", fuel_available)
			current_rounds = fuel_available
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			caliber = "Fuel"
			user << "<span class='notice'>You refill [src] with [lowertext(caliber)].</span>"
			update_icon()

		else
			..()

	update_icon() //keep this simple.
		icon_state = "flametank"

/*
Just a minor area to layout my plan for this. It'll be more deadly with the ability to catch mobs on fire. It'll also have a function with two
levels of heat generated by the fuel.
*/

/obj/item/weapon/gun/flamer
	name = "\improper M240A1 incinerator unit"
	desc = "M240A1 incinerator unit has proven to be one of the most effective weapons at clearing out soft-targets. This is a weapon to be feared and respected as it is quite deadly."
	origin_tech = "combat=4;materials=3"
	icon_state = "m240"
	item_state = "flamer"
	flags_equip_slot = SLOT_BACK
	w_class = 4
	force = 15
	flags_atom = FPRINT|CONDUCT|TWOHANDED
	fire_sound = 'sound/weapons/gun_flamethrower2.ogg'
	aim_slowdown = SLOWDOWN_ADS_INCINERATOR
	var/lit = 0 //Turn the flamer on/off
	current_mag = /obj/item/ammo_magazine/flamer_tank
	var/max_range = 5

	attachable_allowed = list( //give it some flexibility.
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)
	flags_gun_features = GUN_UNUSUAL_DESIGN

	New()
		..()
		fire_delay = config.max_fire_delay * 5
		attachable_offset = list("rail_x" = 12, "rail_y" = 23)

	unique_action(mob/user)
		toggle_flame(user)

	examine(mob/user)
		..()
		user << "It's turned [lit? "on" : "off"]."

/obj/item/weapon/gun/flamer/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds) return

/obj/item/weapon/gun/flamer/proc/toggle_flame(mob/user)
	playsound(user,'sound/weapons/flipblade.ogg', 25, 1)
	lit = !lit
	//REDO
	var/image/reusable/I = rnew(/image/reusable, list('icons/obj/gun.dmi',src,"+lit"))
	I.pixel_x += 3
	if(lit)	overlays += I
	else
		overlays -= I
		cdel(I)

/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, reflex)
	set waitfor = 0
	if(!able_to_fire(user)) return
	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if (!targloc || !curloc) return //Something has gone wrong...

	if(!lit)
		user << "<span class='alert'>The weapon isn't lit</span>"
		return

	if(!current_mag) return
	unleash_flame(target, user)

/obj/item/weapon/gun/flamer/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		user << "That's not a magazine!"
		return

	if(magazine.current_rounds <= 0)
		user << "That [magazine.name] is empty!"
		return

	if(!istype(src, magazine.gun_type))
		user << "That magazine doesn't fit in there!"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		user << "It's still got something loaded."
		return

	else
		if(user)
			if(magazine.reload_delay > 1)
				user << "<span class='notice'>You begin reloading [src]. Hold still...</span>"
				if(do_after(user,magazine.reload_delay, TRUE, 5, BUSY_ICON_CLOCK)) replace_magazine(user, magazine)
				else
					user << "<span class='warning'>Your reload was interrupted!</span>"
					return
			else replace_magazine(user, magazine)
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)

	update_icon()
	return 1

/obj/item/weapon/gun/flamer/unload(mob/user, reload_override = 0, drop_override = 0)
	if(!current_mag) return //no magazine to unload
	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.forceMove(get_turf(src)) //Drop it on the ground.
	else user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>")
	current_mag.update_icon()
	current_mag = null

	update_icon()

/obj/item/weapon/gun/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0
	var/list/turf/turfs = getline2(user,target)
	var/distance = 0
	var/obj/structure/window/W
	var/turf/T
	var/burnlevel
	var/burntime
	switch(current_mag.caliber)
		if("UT-Napthal Fuel") //This isn't actually Napalm actually.
			burnlevel = 24
			burntime = 17
			max_range = 5
		if("Napalm B") //Also a nice middle ground between Napalm C (our future Napalm) and standard fuel for flamers.
			burnlevel = 35 //This was set before weakening and changing regular fuel name to UT-Napathal Fuel
			burntime = 50 //This was just always long.
			max_range = 5
		if("Napalm C") //Probably can end up as a spec fuel or DS flamer fuel. Also this was the original fueltype, the madman i am.
			burnlevel = 50
			burntime = 40
			max_range = 6
		if("Fuel") //This is welding fuel and thus pretty weak. Not ment to be exactly used for flamers either.
			burnlevel = 10
			burntime = 10
			max_range = 4
		else return

	playsound(user, fire_sound, 50, 1)
	for(T in turfs)
		if(T == user.loc) 			continue
		if(T.density)				break
		if(!current_mag.current_rounds) 		break
		if(distance >= max_range) 	break
		if(DirBlocked(T,user.dir))  break
		else if(DirBlocked(T,turn(user.dir,180))) break
		if(locate(/obj/effect/alien/resin/wall,T) || locate(/obj/structure/mineral_door/resin,T) || locate(/obj/effect/alien/resin/membrane,T)) break
		W = locate() in T
		if(W)
			if(W.is_full_window()) 	break
			if(W.dir == user.dir) 	break
		current_mag.current_rounds--
		flame_turf(T,user, burntime, burnlevel)
		distance++
		sleep(1)

/obj/item/weapon/gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn)
	if(!istype(T)) return

	if(!locate(/obj/flamer_fire) in T) // No stacking flames!
		new /obj/flamer_fire(T, heat, burn)
	else return

	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)		continue

		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	continue
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				if(user.mind && !user.mind.special_role && H.mind && !H.mind.special_role)
					H.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with a <b>[name]</b>"
					user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with a <b>[name]</b>"
					msg_admin_ff("[user] ([user.ckey]) shot [H] ([H.ckey]) with a [name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>) (<a href='?priv_msg=\ref[user.client]'>PM</a>)")
				else
					H.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with a <b>[name]</b>"
					user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with a <b>[name]</b>"
					msg_admin_attack("[user] ([user.ckey]) shot [H] ([H.ckey]) with a [name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire)) continue

		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()
		M.adjustFireLoss(rand(burn,(burn*2))) // Make it so its the amount of heat or twice it for the initial blast.
		M << "[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!"

//////////////////////////////////////////////////////////////////////////////////////////////////
//Time to redo part of abby's code.
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = 1
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "2"
	layer = TURF_LAYER
	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.

/obj/flamer_fire/New(loc, fire_lvl, burn_lvl)
	..()
	if(fire_lvl) firelevel = fire_lvl
	if(burn_lvl) burnlevel = burn_lvl
	processing_objects.Add(src)

/obj/flamer_fire/Crossed(mob/living/M) //Only way to get it to reliable do it when you walk into it.
	if(istype(M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire))
				H.show_message(text("Your suit protects you from the flames."),1)
				H.adjustFireLoss(burnlevel*0.25) //Does small burn damage to a person wearing one of the suits.
				return
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	return
		M.adjust_fire_stacks(rand(burnlevel*0.5,burnlevel)) //Make it possible to light them on fire later.
		M.adjustFireLoss(rand(10,burnlevel)) //This makes fire stronk.
		M.show_message(text("<span class='danger'>You are burned!</span>"),1)
		if(isXeno(M)) M.updatehealth()

/obj/flamer_fire/process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf? Has to be on a floor
		processing_objects -= src
		cdel(src)
		return
	if(burnlevel < 15)
		color = "#c1c1c1" //make it darker to make show its weaker.
	switch(firelevel)
		if(1 to 9)
			icon_state = "1"
			SetLuminosity(2)
		if(10 to 25)
			icon_state = "2"
			SetLuminosity(4)
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			icon_state = "3"
			SetLuminosity(6)
		else
			SetLuminosity(0)
			processing_objects.Remove(src)
			cdel(src)
			return
	var/j = 0
	for(var/i in loc)
		if(++j >= 11) break
		if(isliving(i))
			var/mob/living/I = i
			if(istype(I,/mob/living/carbon/human))
				var/mob/living/carbon/human/M = I
				if(istype(M.wear_suit, /obj/item/clothing/suit/fire) || istype(M.wear_suit,/obj/item/clothing/suit/space/rig/atmos))
					M.show_message(text("Your suit protects you from the flames."),1)
					M.adjustFireLoss(rand(0 ,burnlevel*0.25)) //Does small burn damage to a person wearing one of the suits.
					continue
			if(istype(I,/mob/living/carbon/Xenomorph/Queen))
				var/mob/living/carbon/Xenomorph/Queen/X = I
				X.show_message(text("Your extra-thick exoskeleton protects you from the flames."),1)
				continue
			if(istype(I,/mob/living/carbon/Xenomorph/Ravager))
				if(!I.stat)
					var/mob/living/carbon/Xenomorph/Ravager/X = I
					X.storedplasma = X.maxplasma
					X.usedcharge = 0 //Reset charge cooldown
					X.show_message(text("<span class='danger'>The heat of the fire roars in your veins! KILL! CHARGE! DESTROY!</span>"),1)
					if(rand(1,100) < 70) X.emote("roar")
				continue
			I.adjust_fire_stacks(rand(burnlevel, burnlevel*2)) //If i stand in the fire i deserve all of this. Also Napalm stacks quickly.
			if(prob(firelevel)) I.IgniteMob()
			I.adjustFireLoss(rand(10 ,burnlevel)) //Including the fire should be way stronger.
			I.show_message(text("<span class='warning'>You are burned!</span>"),1)
			if(isXeno(I)) //Have no fucken idea why the Xeno thing was there twice.
				var/mob/living/carbon/Xenomorph/X = I
				X.updatehealth()
		if(istype(i, /obj/))
			var/obj/O = i
			O.flamer_fire_act()

	//This has been made a simple loop, for the most part flamer_fire_act() just does return, but for specific items it'll cause other effects.
	firelevel -= 2 //reduce the intensity by 2 per tick
	return



//Syringe Gun

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	matter = list("metal" = 2000)

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	if(user != loc) return
	user << "\blue [syringes.len] / [max_syringes] syringes."

/obj/item/weapon/gun/syringe/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				user.drop_inv_item_to_loc(I, src)
				syringes += I
				user << "\blue You put the syringe in [src]."
				user << "\blue [syringes.len] / [max_syringes] syringes."
			else
				usr << "\red [src] cannot hold more syringes."
		else
			usr << "\red This syringe is broken!"


/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/syringe/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(syringes.len)
		spawn(0) fire_syringe(target,user)
	else
		usr << "\red [src] is empty."

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
		if((!S) || (!S.reagents))	//ho boy! wot runtimes!
			return
		S.reagents.trans_to(D, S.reagents.total_volume)
		syringes -= S
		cdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!istype(M,/mob/living/carbon)) continue
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("[user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					var/mob/living/T
					if(istype(M,/mob/living))
						T = M

					M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")

					if(T && istype(T) && T.can_inject())
						if(D.reagents)
							D.reagents.trans_to(M, 15)
					else
						M.visible_message("<span class='danger'>The syringe bounces off [M]!</span>")

					cdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) cdel(D)

			sleep(1)

		if (D) spawn(10) cdel(D)

		return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src



/obj/item/big_ammo_box
	name = "big ammo box (10x24mm)"
	desc = "A large ammo box capable of containing hundreds of rounds."
	w_class = 5
	icon = 'icons/obj/ammo.dmi'
	icon_state = "big_ammo_box"
	var/base_icon_state = "big_ammo_box"
	var/default_ammo = /datum/ammo/bullet/rifle
	var/bullet_amount = 800
	var/max_bullet_amount = 800
	var/caliber = "10x24mm"

	update_icon()
		if(bullet_amount) icon_state = base_icon_state
		else icon_state = "[base_icon_state]_e"

	examine(mob/user)
		..()
		if(bullet_amount)
			user << "It contains [bullet_amount] round\s."
		else
			user << "It's empty."

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/ammo_magazine))
			var/obj/item/ammo_magazine/AM = I
			if(AM.flags_magazine & AMMUNITION_REFILLABLE)
				if(default_ammo != AM.default_ammo)
					user << "<span class='warning'>Those aren't the same rounds. Better not mix them up.</span>"
					return
				if(caliber != AM.caliber)
					user << "<span class='warning'>The rounds don't match up. Better not mix them up.</span>"
					return
				if(AM.current_rounds == AM.max_rounds)
					user << "<span class='warning'>[AM] is already full.</span>"
					return
				playsound(loc, 'sound/weapons/gun_revolver_load3.ogg', 25, 1)
				var/S = min(bullet_amount, AM.max_rounds - AM.current_rounds)
				AM.current_rounds += S
				bullet_amount -= S
				AM.update_icon(S)
				update_icon()
				if(AM.current_rounds == AM.max_rounds)
					user << "<span class='notice'>You refill [AM].</span>"
				else
					user << "<span class='notice'>You put [S] rounds in [AM].</span>"
			else if(AM.flags_magazine & AMMUNITION_HANDFUL)
				if(caliber != AM.caliber)
					user << "<span class='warning'>The rounds don't match up. Better not mix them up.</span>"
					return
				if(bullet_amount == max_bullet_amount)
					user << "<span class='warning'>[src] is full!</span>"
					return
				playsound(loc, 'sound/weapons/gun_revolver_load3.ogg', 25, 1)
				var/S = min(AM.current_rounds, max_bullet_amount - bullet_amount)
				AM.current_rounds -= S
				bullet_amount += S
				AM.update_icon()
				user << "<span class='notice'>You put [S] rounds in [src].</span>"
				if(AM.current_rounds <= 0)
					user.temp_drop_inv_item(AM)
					cdel(AM)


/obj/item/big_ammo_box/ap
	name = "big ammo box (10x24mm AP)"
	icon_state = "big_ammo_box_ap"
	base_icon_state = "big_ammo_box_ap"

/obj/item/big_ammo_box/smg
	name = "big ammo box (10x20mm)"
	caliber = "10x20mm"
	icon_state = "big_ammo_box_m39"
	base_icon_state = "big_ammo_box_m39"
	default_ammo = /datum/ammo/bullet/smg

//Items specific to yautja. Other people can use em, they're not restricted or anything.
//They can't, however, activate any of the special functions.

/obj/item/weapon/twohanded/glaive
	icon = 'icons/Predator/items.dmi'
	icon_state = "glaive"
	item_state = "glaive"
	name = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 34
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 34
	force_wielded = 60
	throwforce = 28
	throw_speed = 2
	edge = 1
	sharp = 0
	flags = NOSHIELD
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	unacidable = 1

/obj/item/weapon/twohanded/glaive/update_icon()
	if(wielded)
		item_state = "glaive-wield"
	else
		item_state = "glaive"
	return

/obj/item/clothing/head/helmet/space/yautja
	icon = 'icons/Predator/items.dmi'
	icon_state = "pred_mask1"
	item_state = "helmet"
	icon_override = 'icons/Predator/items.dmi'
	name = "clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	armor = list(melee = 60, bullet = 45, laser = 80,energy = 60, bomb = 75, bio = 100, rad = 100)
	anti_hug = 7
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH
	species_restricted = null
	body_parts_covered = HEAD|FACE
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	var/current_goggles = 0 //0: OFF. 1: NVG. 2: Thermals. 3: Mesons
	unacidable = 1

	New()
		spawn(0)
			var/mask = rand(1,4)
			icon_state = "pred_mask[mask]"

	verb/togglesight()
		set name = "Toggle Mask Visors"
		set desc = "Toggle your mask visor sights. You must only be wearing a type of Yautja visor for this to work."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(M.species && M.species.name != "Yautja")
			M << "You have no idea how to work these things."
			return
		var/obj/item/clothing/gloves/yautja/Y = M.gloves //Doesn't actually reduce power, but needs the bracers anyway.
		if(!Y || !istype(Y))
			M << "You must be wearing your bracers, as they have the power source."
			return
		var/obj/item/G = M.glasses
		if(G)
			if(!istype(G,/obj/item/clothing/glasses/night/yautja) && !istype(G,/obj/item/clothing/glasses/meson/yautja) && !istype(G,/obj/item/clothing/glasses/thermal/yautja))
				M << "You need to remove your glasses first. Why are you even wearing these?"
				return
			M.drop_from_inventory(G) //Get rid of ye existinge gogglors
			del(G)
		switch(current_goggles)
			if(0)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/yautja(M), slot_glasses)
				M << "Low-light vision module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(1)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/yautja(M), slot_glasses)
				M << "Thermal sight module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(2)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/yautja(M), slot_glasses)
				M << "Material vision module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(3)
				M << "You deactivate your visor."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
		M.update_inv_glasses()
		current_goggles++
		if(current_goggles > 3) current_goggles = 0

	dropped(var/mob/living/carbon/human/mob) //Clear the gogglors if the helmet is removed. This should work even though they're !canremove.
		..()
		if(!istype(mob)) return //Somehow
		var/obj/item/G = mob.glasses
		if(G)
			if(istype(G,/obj/item/clothing/glasses/night/yautja) || istype(G,/obj/item/clothing/glasses/meson/yautja) || istype(G,/obj/item/clothing/glasses/thermal/yautja))
				mob.drop_from_inventory(G)
				del(G)
				mob.update_inv_glasses()

/obj/item/clothing/suit/armor/yautja
	name = "clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predarmor"
	item_state = "armor"
	icon_override = 'icons/Predator/items.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 58, bullet = 75, laser = 20, energy = 20, bomb = 40, bio = 50, rad = 50)
	siemens_coefficient = 0.1
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/harpoon, /obj/item/weapon/twohanded/glaive)
	unacidable = 1

	New()
		..()
		if(prob(50))
			icon_state = "predarmor2"

/obj/item/weapon/harpoon/yautja
	name = "alien harpoon"
	desc = "A huge metal spike, with a hook at the end. It's carved with mysterious alien writing."
	force = 25
	throwforce = 85
	attack_verb = list("jabbed","stabbed","ripped", "skewered")
	unacidable = 1

/obj/item/weapon/wristblades
	name = "wrist blades"
	desc = "A pair of huge, serrated blades extending from a metal gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "wrist"
	item_state = "wristblades"
	force = 52
	w_class = 5.0
	edge = 1
	sharp = 0
	flags = NOSHIELD
	hitsound = 'sound/weapons/wristblades_hit.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	canremove = 0

	dropped(var/mob/living/carbon/human/mob)
		playsound(mob,'sound/weapons/wristblades_off.ogg', 40, 1)
		mob << "The wrist blades retract back into your armband."
		del(src)

	afterattack(obj/O as obj, mob/user as mob, proximity)
		if(!proximity || !user) return
		if (istype(O, /obj/machinery/door/airlock) && get_dist(src,O) <= 1)
			var/obj/machinery/door/airlock/D = O
			if(!D.density)
				return

			if(D.locked)
				user << "There's some kind of lock keeping it shut."
				return

			if(D.welded)
				user << "It's welded shut. You won't be able to rip it open."
				return

			user << "\blue You jam a wristblade into [O] and strain to rip it open."
			if(do_after(user,70))
				D.open(1)



/obj/item/clothing/shoes/yautja
	name = "armored boots"
	icon = 'icons/Predator/items.dmi'
	icon_state = "y-boots"
	icon_override = 'icons/Predator/items.dmi'
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."
//	item_state = "yautja"

	permeability_coefficient = 0.01
	flags = NOSLIP
	body_parts_covered = FEET|LEGS
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

	New()
		..()
		if(prob(50))
			icon_state = "y-boots2"

/obj/item/clothing/under/chainshirt
	name = "chain-mesh shirt"
	icon = 'icons/Predator/items.dmi'
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."
	icon_state = "mesh_shirt"
	icon_override = 'icons/Predator/items.dmi'
	has_sensor = 0
	armor = list(melee = 5, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_restricted = null

/obj/item/clothing/gloves/yautja
	name = "alien bracers"
//	icon = 'icons/Predator/items.dmi'
//	icon_state = "bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."
	icon_state = "s-ninja"//placeholder
	item_state = "s-ninja"
	species_restricted = null
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	canremove = 0
	body_parts_covered = HANDS|ARMS
	armor = list(melee = 70, bullet = 50, laser = 30,energy = 15, bomb = 50, bio = 30, rad = 30)
	var/charge = 2000
	var/charge_max = 2000
	var/cloaked = 0
	var/selfdestruct = 0
	var/blades_active = 0
	var/caster_active = 0
	var/exploding = 0
	var/inject_timer = 0

	//This is the main proc for checking AND draining the bracer energy. It must have M passed as an argument.
	//It can take a negative value in amount to restore energy.
	//Also instantly updates the yautja power HUD display.
	proc/drain_power(var/mob/living/carbon/human/M, var/amount)
		if(!M) return 0
		if(charge < amount)
			M << "Your bracers lack the energy. They have only <b>[charge]/[charge_max]</b> remaining and need <B>[amount]</b>."
			return 0
		charge -= amount
		var/perc = (charge / charge_max * 100)
		M.update_power_display(perc)
		return 1

	//Should put a cool menu here, like ninjas.
	verb/wristblades()
		set name = "Use Wrist Blades"
		set desc = "Extend your wrist blades. They cannot be dropped, but can be retracted."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return
		var/obj/item/weapon/wristblades/R = usr.r_hand
		var/obj/item/weapon/wristblades/L = usr.l_hand
		if(!istype(R) && !istype(L))
			blades_active = 0

		if(blades_active) //Turn it off.
			var/found = 0
			if(R && istype(R))
				found = 1
				usr.r_hand = null
				if(R) del(R)
				usr.update_inv_r_hand()
			if(L && istype(L))
				found = 1
				usr.l_hand = null
				if(L) del(L)
				usr.update_inv_l_hand()
			if(found)
				usr << "You retract your wrist blades."
				playsound(src.loc,'sound/weapons/wristblades_off.ogg', 40, 1)
				blades_active = 0
			return
		else //Turn it on!
			if(usr.get_active_hand())
				usr << "Your hand must be free to activate your wrist blades."
				return
			if(!drain_power(usr,50)) return
			var/obj/item/weapon/wristblades/W = new(usr)
			usr.put_in_active_hand(W)
			blades_active = 1
			usr << "You activate your wrist blades."
			playsound(src,'sound/weapons/wristblades_on.ogg', 40, 1)
			usr.update_icons()
		return 1

	verb/cloaker()
		set name = "Toggle Cloaking Device"
		set desc = "Activate your suit's cloaking device. It will malfunction if the suit takes damage or gets excessively wet."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return
		if(cloaked) //Turn it off.
			decloak(usr)
		else //Turn it on!
			if(!drain_power(usr,50)) return
			cloaked = 1
			usr << "\blue You are now invisible to normal detection."
			for(var/mob/O in oviewers(usr))
				O.show_message("[usr.name] vanishes into thin air!",1)
			playsound(usr.loc,'sound/effects/cloakon.ogg', 50, 1)
			usr.update_icons()
			spawn(1)
				anim(usr.loc,usr,'icons/mob/mob.dmi',,"cloak",,usr.dir)

		return 1

	proc/decloak(var/mob/user)
		if(!user) return
		user << "Your cloaking device deactivates."
		cloaked = 0
		for(var/mob/O in oviewers(user))
			O.show_message("[user.name] wavers into existence!",1)
		playsound(user.loc,'sound/effects/cloakoff.ogg', 50, 1)
		user.update_icons()
		spawn(1)
			if(user)
				anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)
		return

	verb/caster()
		set name = "Use Plasma Caster"
		set desc = "Activate your plasma caster. If it is dropped it will retract back into your armor."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return
		var/obj/item/weapon/gun/plasma_caster/R = usr.r_hand
		var/obj/item/weapon/gun/plasma_caster/L = usr.l_hand
		if(!istype(R) && !istype(L))
			caster_active = 0
		if(caster_active) //Turn it off.
			var/found = 0
			if(R && istype(R))
				found = 1
				usr.r_hand = null
				if(R) del(R)
				usr.update_inv_r_hand()
			if(L && istype(L))
				found = 1
				usr.l_hand = null
				if(L) del(L)
				usr.update_inv_l_hand()
			if(found)
				usr << "You deactivate your plasma caster."
				playsound(src,'sound/weapons/plasmacaster_off.ogg', 40, 1)
				caster_active = 0
			return
		else //Turn it on!
			if(usr.get_active_hand())
				usr << "Your hand must be free to activate your wrist blades."
				return
			if(!drain_power(usr,50)) return

			var/obj/item/weapon/gun/plasma_caster/W = new(usr)
			usr.put_in_active_hand(W)
			W.source = src
			caster_active = 1
			usr << "You activate your plasma caster."
			playsound(src,'sound/weapons/plasmacaster_on.ogg', 40, 1)
			usr.update_icons()
		return 1

	proc/explodey()
		for(var/mob/O in viewers())
			O.show_message("\red <B>The [src] begin beeping.</b>",2) // 2 stands for hearable message
		playsound(src.loc,'sound/effects/pred_countdown.ogg', 100, 0)
		spawn(85)
			var/turf/T = get_turf(src.loc)
			if(T && istype(T))
				explosion(T, 1, 3, 7, 1) //KABOOM! This should be enough to gib the corpse and injure/kill anyone nearby.
				if(src)
					del(src)

	verb/activate_suicide()
		set name = "Final Countdown (!)"
		set desc = "Activate the explosive device implanted into your bracers. You have failed! Show some honor!"
		set category = "Yautja"

		if(!usr) return
		var/mob/living/carbon/human/M = usr
		if(M.stat == DEAD)
			usr << "Little too late for that now!"
			return
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return
		if(!M.stat) //We're conscious, first look for another dead yautja to blow up.
			for(var/mob/living/carbon/human/victim in oview(1))
				if(victim && isYautja(victim) && victim.stat == DEAD)
					if(victim.gloves && istype(victim.gloves,/obj/item/clothing/gloves/yautja))
						if(alert("Are you sure you want to send this Yautja into the great hunting grounds?","Explosive Bracers", "Yes", "No") == "Yes")
							var/obj/item/clothing/gloves/yautja/G = victim.gloves
							G.explodey()
							M.visible_message("\red [M] presses a few buttons on [victim]'s wrist bracer.","\red You activate the timer. May [victim]'s final hunt be swift.")
							return

		if(!M.stat)
			M << "You can only do this when unconscious, you coward. Go hunting and die gloriously."
			return
		if(exploding)
			if(alert("Are you sure you want to stop the countdown? You coward.","Bracers", "Yes", "No") == "Yes")
				exploding = 0
				M << "Your bracers stop beeping. Wuss."
				return
		if((M.wear_mask && istype(M.wear_mask,/obj/item/clothing/mask/facehugger)) || M.status_flags & XENO_HOST)
			M << "Strange.. something seems to be interfering with your bracer functions.."
			return
		if(alert("Detonate the bracers? Are you sure?","Explosive Bracers", "Yes", "No") == "Yes")
			M << "\red You set the timer. May your journey to the great hunting grounds be swift."
			src.explodey()

	verb/injectors()
		set name = "Create Self-Heal Crystal"
		set category = "Yautja"
		set desc = "Create a focus crystal to energize your natural healing processes."

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return

		if(usr.get_active_hand())
			usr << "Your active hand must be empty."
			return 0

		if(inject_timer)
			usr << "You recently activated the healing crystal. Be patient."
			return

		if(!drain_power(usr,1000)) return

		inject_timer = 1
		spawn(1200)
			if(usr && src.loc == usr)
				usr << "\blue Your bracers beep faintly and inform you that a new healing crystal is ready to be created."
				inject_timer = 0

		usr << "\blue You feel a faint hiss and a crystalline injector drops into your hand."
		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja/O = new(usr)
		usr.put_in_active_hand(O)
		playsound(src,'sound/machines/click.ogg', 20, 1)
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja
	name = "alien injector"
	desc = "A strange, thin alien needle."
	amount_per_transfer_from_this = 13
	volume = 13

	New()
		..()
		spawn(1)
			reagents.add_reagent("quickclot", 5)
			reagents.add_reagent("tricordrazine", 5)
			reagents.add_reagent("peridaxon", 3)
		return

/obj/item/weapon/gun/plasma_caster
	icon = 'icons/Predator/items.dmi'
	icon_state = "plasma"
	item_state = "plasma_wear"
	name = "plasma caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	fire_sound = 'sound/weapons/plasmacaster_fire.ogg'
	canremove = 0
	w_class = 5
	fire_delay = 6
	var/obj/item/clothing/gloves/yautja/source = null
	var/charge_cost = 100 //How much energy is needed to fire.
	var/projectile_type = "/obj/item/projectile/beam/yautja1"
	var/mode = 0
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 50
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				user << "\red \The [src.name] is now set to fire light plasma bolts."
				projectile_type = "/obj/item/projectile/beam/yautja1"
			if(0)
				mode = 1
				charge_cost = 75
				fire_sound = 'sound/weapons/emitter2.ogg'
				user << "\red \The [src.name] is now set to fire medium plasma bolts."
				projectile_type = "/obj/item/projectile/beam/yautja2"
			if(1)
				mode = 2
				charge_cost = 150
				fire_sound = 'sound/weapons/pulse.ogg'
				user << "\red \The [src.name] is now set to fire heavy plasma bolts."
				projectile_type = "/obj/item/projectile/beam/yautja3"
		return

	dropped(var/mob/living/carbon/human/mob)
		..()
		mob << "The plasma caster deactivates."
		playsound(mob,'sound/weapons/plasmacaster_off.ogg', 40, 1)
		del(src)
		return


	load_into_chamber()
		if(in_chamber)	return 1
		if(!source)	return 0
		if(!projectile_type)	return 0
		if(!usr) return 0 //somehow
		if(!source.drain_power(usr,charge_cost)) return 0
		in_chamber = new projectile_type(src)
		return 1

	afterattack(atom/target, mob/user , flag)
		if(ishuman(user))
			var/mob/living/carbon/human/M = user
			if(M.species && M.species == "Yautja")
				if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves/yautja))
					var/obj/item/clothing/gloves/yautja/Y = M.gloves
					var/perc_charge = (Y.charge / Y.charge_max * 100)
					M.update_power_display(perc_charge)
		..()

/obj/item/projectile/beam/yautja1
	name = "plasma bolt"
	icon_state = "bluelaser"
	damage = 25
	stun = 5
	weaken = 1

/obj/item/projectile/beam/yautja2
	name = "plasma"
	icon_state = "pulse1"
	damage = 45

/obj/item/projectile/beam/yautja3
	name = "heavy plasma"
	icon_state = "pulse1_bl"
	damage = 60

//Yes, it's a backpack that goes on the belt. I want the backpack noises. Deal with it (tm)
/obj/item/weapon/storage/backpack/yautja
	name = "leather bag"
	desc = "A huge leather pouch worn around the waist, made from the hide of some unknown beast."
	icon = 'icons/Predator/items.dmi'
	icon_state = "beltbag"
	item_state = "beltbag"
	slot_flags = SLOT_BELT

	New() //Spawn some items inside
		..()
		spawn(2)
			new /obj/item/weapon/harpoon/yautja(src)
			new /obj/item/weapon/harpoon/yautja(src)
			new /obj/item/weapon/harpoon/yautja(src)
			new /obj/item/weapon/legcuffs/yautja(src)
			new /obj/item/weapon/legcuffs/yautja(src)
			new /obj/item/weapon/legcuffs/yautja(src)


/obj/item/clothing/glasses/night/yautja
	name = "alien nightvision visor"
	desc = "Strange alien technology"
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_nvg"
	item_state = "securityhud"
	darkness_view = 5 //Not quite as good as regular NVG.
	canremove = 0

	New()
		..()
		overlay = null  //Stops the green overlay.

/obj/item/clothing/glasses/thermal/yautja
	name = "alien thermal visor"
	desc = "Strange alien technology"
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_thermal"
	item_state = "securityhud"
	vision_flags = SEE_MOBS
	invisa_view = 2
	canremove = 0

/obj/item/clothing/glasses/meson/yautja
	name = "alien X-ray visor"
	desc = "Strange alien technology"
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_meson"
	item_state = "securityhud"
	vision_flags = SEE_TURFS
	canremove = 0

/obj/item/weapon/legcuffs/yautja
	name = "alien trap"
	throw_speed = 2
	throw_range = 2
	icon = 'icons/Predator/items.dmi'
	icon_state = "yauttrap0"
	desc = "A trap used to catch prey."
	var/armed = 0
	breakouttime = 600 // 1 minute
	layer = 2.8 //Goes under weeds.

	dropped(var/mob/living/carbon/human/mob) //Changes to "camouflaged" icons based on where it was dropped.
		..()
		if(armed)
			if(isturf(mob.loc))
				if(istype(mob.loc,/turf/simulated/floor/gm/dirt))
					icon_state = "yauttrapdirt"
				else if (istype(mob.loc,/turf/simulated/floor/gm/grass))
					icon_state = "yauttrapgrass"
				else
					icon_state = "yauttrap1"

/obj/item/weapon/legcuffs/yautja/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "yauttrap[armed]"
		user << "<span class='notice'>\The [src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/legcuffs/yautja/Crossed(AM as mob|obj)
	if(armed)
		if(iscarbon(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(isYautja(H))
					H << "You carefully avoid stepping on the trap."
					return
				if(H.m_intent == "run")
					armed = 0
					icon_state = "yauttrap0"
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed()
					playsound(H,'sound/weapons/tablehit1.ogg', 50, 1)
					H << "\icon[src] \red <B>You step on \the [src]!</B>"
					H.Weaken(3)
					if(ishuman(H))
						H.emote("scream")
					feedback_add_details("handcuffs","B")
					for(var/mob/O in viewers(H, null))
						if(O == H)
							continue
						O.show_message("\icon[src] \red <B>[H] steps on \the [src].</B>", 1)
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20
	..()

//Yautja channel. Has to delete stock encryption key so we don't receive sulaco channel.
/obj/item/device/radio/headset/yautja
	name = "alien earpiece"
	desc = "A strange headset that fits in a bizarrely-shaped ear."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = 1214

	New()
		..()
		del(keyslot1)
		keyslot1 = new /obj/item/device/encryptionkey/yautja
		recalculateChannels()

	talk_into(mob/living/M as mob, message, channel, var/verb = "says", var/datum/language/speaking = null)
		if(!isYautja(M)) //Nope.
			M << "You try to talk into the headset, but just get a horrible shrieking in your ears."
			return
		..()
		return

/obj/item/device/encryptionkey/yautja
	name = "Yautja Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cypherkey"
	channels = list("Yautja" = 1)
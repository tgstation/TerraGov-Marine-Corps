//Items specific to yautja. Other people can use em, they're not restricted or anything.
//They can't, however, activate any of the special functions.

/obj/item/weapon/twohanded/glaive
	icon = 'icons/Predator/items.dmi'
	icon_state = "glaive"
	item_state = "glaive"
	name = "Yautja War Glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 38
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 28
	force_wielded = 60
	throwforce = 50
	throw_speed = 3
	edge = 1
	sharp = 0
	flags = NOSHIELD
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	unacidable = 1
	attack_speed = 12 //Default is 7.

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
	name = "Yautja Clan Mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	armor = list(melee = 80, bullet = 95, laser = 70,energy = 60, bomb = 65, bio = 100, rad = 100)
	anti_hug = 100
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
	name = "Yautja Clan Armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "halfarmor"
	item_state = "armor"
	icon_override = 'icons/Predator/items.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 65, bullet = 80, laser = 40, energy = 50, bomb = 40, bio = 50, rad = 50)
	siemens_coefficient = 0.1
	slowdown = 0
	allowed = list(/obj/item/weapon/harpoon, /obj/item/weapon/twohanded)
	unacidable = 1

/obj/item/clothing/suit/armor/yautja/full
	name = "Yautja Heavy Clan Armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "fullarmor"
	armor = list(melee = 69, bullet = 90, laser = 65, energy = 50, bomb = 40, bio = 70, rad = 50)
	slowdown = 1

/obj/item/weapon/harpoon/yautja
	name = "Yautja Harpoon"
	desc = "A huge metal spike, with a hook at the end. It's carved with mysterious alien writing."
	icon = 'icons/Predator/items.dmi'
	icon_state = "spike"
	item_state = "spike1"
	icon_override = 'icons/Predator/items.dmi'
	force = 15
	throwforce = 38
	attack_verb = list("jabbed","stabbed","ripped", "skewered")
	unacidable = 1
	sharp = 1

/obj/item/weapon/wristblades
	name = "Yautja Wrist Blades"
	desc = "A pair of huge, serrated blades extending from a metal gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "wrist"
	item_state = "wristblade"
	force = 30
	w_class = 5.0
	edge = 1
	sharp = 0
	flags = NOSHIELD
	slot_flags = 0
	hitsound = 'sound/weapons/wristblades_hit.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	canremove = 0
	attack_speed = 6

	New()
		..()
		if(usr)
			var/obj/item/weapon/wristblades/get_other_hand = usr.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				attack_speed = 4

	dropped(var/mob/living/carbon/human/mob)
		playsound(mob,'sound/weapons/wristblades_off.ogg', 30, 1)
		mob << "The wrist blades retract back into your armband."
		if(mob)
			var/obj/item/weapon/wristblades/get_other_hand = mob.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				get_other_hand.attack_speed = 6

		del(src)

	afterattack(obj/O as obj, mob/user as mob, proximity)
		if(!proximity || !user) return
		if(user)
			var/obj/item/weapon/wristblades/get_other_hand = user.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				attack_speed = 4
			else
				attack_speed = initial(attack_speed)

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

			user << "\blue You jam \the [src] into [O] and strain to rip it open."
			playsound(user,'sound/weapons/wristblades_hit.ogg', 60, 1)
			if(do_after(user,30))
				D.open(1)

/obj/item/weapon/wristblades/scimitar
	name = "Yautja Wrist Scimitar"
	desc = "An enormous serrated blade that extends from the gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "scim"
	item_state = "scim"
	force = 62
	attack_speed = 18 //slow!
	hitsound = 'sound/weapons/pierce.ogg'


/obj/item/clothing/shoes/yautja
	name = "Yautja Armored Boots"
	icon = 'icons/Predator/items.dmi'
	icon_state = "y-boots"
	icon_override = 'icons/Predator/items.dmi'
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."
//	item_state = "yautja"
	unacidable = 1
	permeability_coefficient = 0.01
	flags = NOSLIP
	body_parts_covered = FEET|LEGS
	armor = list(melee = 80, bullet = 90, laser = 30,energy = 15, bomb = 50, bio = 30, rad = 30)
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
	name = "Yautja Mesh"
	icon = 'icons/Predator/items.dmi'
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."
	icon_state = "mesh_shirt"
	icon_override = 'icons/Predator/items.dmi'
	item_color = "mesh_shirt"
	item_state = "mesh_shirt"
	has_sensor = 0
	armor = list(melee = 5, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_restricted = null

/obj/item/clothing/gloves/yautja
	name = "Yautja Bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."
	icon = 'icons/Predator/items.dmi'
	icon_state = "bracer"
	icon_override = 'icons/Predator/items.dmi'
	item_color = "bracer"
	item_state = "bracera"
	//icon_state = "bracer"//placeholder
	//item_state = "bracer"
	species_restricted = null
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	canremove = 0
	body_parts_covered = HANDS|ARMS
	armor = list(melee = 80, bullet = 80, laser = 30,energy = 15, bomb = 50, bio = 30, rad = 30)
	unacidable = 1
	var/charge = 2000
	var/charge_max = 2000
	var/cloaked = 0
	var/selfdestruct = 0
	var/blades_active = 0
	var/caster_active = 0
	var/exploding = 0
	var/inject_timer = 0
	var/cloak_timer = 0
	var/upgrades = 0

	emp_act(severity)
		charge -= (severity * 500)
		if(charge < 0) charge = 0
		if(usr)
			usr.visible_message("\red You hear a hiss and crackle!","\red Your bracers hiss and spark!")
			if(cloaked)
				decloak(usr)

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

	examine()
		..()
		usr << "They currently have [charge] out of [charge_max] charge."

	//Should put a cool menu here, like ninjas.
	verb/wristblades()
		set name = "Use Wrist Blades"
		set desc = "Extend your wrist blades. They cannot be dropped, but can be retracted."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(M))
			usr << "You have no idea how to work these things."
			return
		var/obj/item/weapon/wristblades/R = M.get_active_hand()
		if(R && istype(R)) //Turn it off.
			M << "You retract your wrist blade."
			playsound(M.loc,'sound/weapons/wristblades_off.ogg', 40, 1)
			blades_active = 0
			M.drop_item(R)
			if(R) del(R) //Just to make sure. The drop should take care of it though.
			return
		else
			if(R)
				M << "Your hand must be free to activate your wrist blade."
				return
			if(!drain_power(usr,50)) return

			var/obj/item/weapon/wristblades/W
			if(upgrades > 1)
				W = new /obj/item/weapon/wristblades/scimitar(M)
			else
				W = new /obj/item/weapon/wristblades(M)

			M.put_in_active_hand(W)
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
			return 0
		if(cloaked) //Turn it off.
			decloak(usr)
		else //Turn it on!
			if(cloak_timer)
				if(prob(50))
					usr << "\blue Your cloaking device is still recharging! Time left: <B>[cloak_timer]</b> ticks."
				return 0
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
			O.show_message("[user.name] shimmers into existence!",1)
		playsound(user.loc,'sound/effects/cloakoff.ogg', 50, 1)
		user.update_icons()
		cloak_timer = 10
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

	proc/explodey(var/mob/living/carbon/victim)
		playsound(src.loc,'sound/effects/pred_countdown.ogg', 80, 0)
		spawn(rand(65,85))
			var/turf/T = get_turf(victim)
			if(istype(T))
				victim.apply_damage(50,BRUTE,"chest")
				explosion(T, 1, 4, 7, -1) //KABOOM! This should be enough to gib the corpse and injure/kill anyone nearby.
				if(src) del(src)

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
			src.explodey(M)

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

	verb/call_disk()
		set name = "Call Smart-Disc"
		set category = "Yautja"
		set desc = "Call back your smart-disc, if it's in range. If not you'll have to go retrieve it."

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return

		if(usr.get_active_hand())
			usr << "Your active hand must be empty."
			return 0

		if(inject_timer)
			usr << "Your bracers need some time to recuperate first."
			return 0

		if(!drain_power(usr,70)) return
		inject_timer = 1
		spawn(100)
			inject_timer = 0

		for(var/mob/living/simple_animal/hostile/smartdisc/S in range(7))
			usr << "\blue The [S] skips back towards you!"
			new /obj/item/weapon/grenade/spawnergrenade/smartdisc(S.loc)
			del(S)

		for(var/obj/item/weapon/grenade/spawnergrenade/smartdisc/D in range(10))
			D.throw_at(usr,10,1,usr)

/obj/item/clothing/gloves/yautja/proc/translate()
	set name = "Translator"
	set desc = "Emit a message from your bracer to those nearby."
	set category = "Yautja"

	if(!usr || usr.stat) return

	if(!isYautja(usr))
		usr << "You have no idea how to work these things."
		return

	var/msg = input(usr,"Your bracer beeps and waits patiently for you to input your message.","Translator","") as text
	if(!msg || msg == "" || isnull(msg)) return

	msg = sanitize(msg)
	msg = replacetext(msg, "o", "¤")
	msg = replacetext(msg, "p", "þ")
	msg = replacetext(msg, "l", "£")
	msg = replacetext(msg, "s", "§")
	msg = replacetext(msg, "u", "µ")
	msg = replacetext(msg, "b", "ß") //We're ninjas now? .. fine

	spawn(10)
		if(!drain_power(usr,50)) return //At this point they've upgraded.
		var/mob/Q
		for(Q in hearers(usr))
			if(Q.stat == 1) continue //Unconscious
			if(isXeno(Q) && upgrades != 2) continue
			Q << "A strange voice says, '[msg]'."


/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja
	name = "Yautja Crystal"
	desc = "A strange glowing crystal with a spike at one end."
	icon = 'icons/Predator/items.dmi'
	icon_state = "crystal"
	item_state = "crystal"
	icon_override = 'icons/Predator/items.dmi'
	amount_per_transfer_from_this = 35
	volume = 35

	New()
		..()
		spawn(1)
			reagents.add_reagent("quickclot", 5)
			reagents.add_reagent("thwei", 30)
		return

/obj/item/weapon/gun/plasma_caster
	icon = 'icons/Predator/items.dmi'
	icon_state = "plasma"
	item_state = "plasma_wear"
	name = "Yautja Plasma Caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	fire_sound = 'sound/weapons/plasmacaster_fire.ogg'
	canremove = 0
	w_class = 5
	fire_delay = 3
	var/obj/item/clothing/gloves/yautja/source = null
	var/charge_cost = 100 //How much energy is needed to fire.
	var/mode = 0
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	accuracy = 10

	New()
		ammo = new /datum/ammo/energy/yautja()
		..()

	Del()
		del(ammo)
		ammo = null
		source = null
		return ..()

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 30
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				user << "\red \The [src.name] is now set to fire light plasma bolts."
				ammo.name = "plasma bolt"
				ammo.icon_state = "ion"
				ammo.damage = 5
				ammo.stun = 2
				ammo.weaken = 2
				fire_delay = 5
				ammo.shell_speed = 1
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/emitter2.ogg'
				user << "\red \The [src.name] is now set to fire medium plasma blasts."
				fire_delay = 16
				ammo.name = "plasma blast"
				ammo.icon_state = "pulse1"
				ammo.damage = 25
				ammo.stun = 0
				ammo.weaken = 0
				ammo.shell_speed = 2 //Lil faster
			if(1)
				mode = 2
				charge_cost = 300
				fire_delay = 100
				fire_sound = 'sound/weapons/pulse.ogg'
				user << "\red \The [src.name] is now set to fire heavy plasma spheres."
				ammo.name = "plasma eradication sphere"
				ammo.icon_state = "bluespace"
				ammo.damage = 30
				ammo.stun = 0
				ammo.weaken = 0
				ammo.shell_speed = 1
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
		if(!ammo)	return 0
		if(!usr) return 0 //somehow
		if(!source.drain_power(usr,charge_cost)) return 0
		in_chamber = new /obj/item/projectile(src)
		in_chamber.ammo = ammo
		in_chamber.damage = ammo.damage
		in_chamber.damage_type = ammo.damage_type
		in_chamber.icon_state = ammo.icon_state
		in_chamber.dir = usr.dir
		return 1

	afterattack(atom/target, mob/user , flag)
		if(ishuman(user))
			var/mob/living/carbon/human/M = user
			if(M.species && M.species == "Yautja")
				if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves/yautja))
					var/obj/item/clothing/gloves/yautja/Y = M.gloves
					var/perc_charge = (Y.charge / Y.charge_max * 100)
					M.update_power_display(perc_charge)
		return ..()

//Yes, it's a backpack that goes on the belt. I want the backpack noises. Deal with it (tm)
/obj/item/weapon/storage/backpack/yautja
	name = "Yautja Hunting Pouch"
	desc = "A Yautja hunting pouch worn around the waist, made from a thick tanned hide. Capable of holding various devices and tools and used for the transport of trophies."
	icon = 'icons/Predator/items.dmi'
	icon_state = "beltbag"
	item_state = "beltbag"
	slot_flags = SLOT_BELT
	max_w_class = 3
	storage_slots = 10
	max_combined_w_class = 30

/obj/item/clothing/glasses/night/yautja
	name = "Bio-mask Nightvision"
	desc = "A vision overlay generated by the Bio-Mask. Used for low-light conditions."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_nvg"
	item_state = "securityhud"
	darkness_view = 5 //Not quite as good as regular NVG.
	canremove = 0

	New()
		..()
		overlay = null  //Stops the green overlay.

/obj/item/clothing/glasses/thermal/yautja
	name = "Bio-mask Thermal"
	desc = "A vision overlay generated by the Bio-Mask. Used to sense the heat of prey."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_thermal"
	item_state = "securityhud"
	vision_flags = SEE_MOBS
	invisa_view = 2
	canremove = 0

/obj/item/clothing/glasses/meson/yautja
	name = "Bio-mask X-ray"
	desc = "A vision overlay generated by the Bio-Mask. Used to see through objects."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_meson"
	item_state = "securityhud"
	vision_flags = SEE_TURFS
	canremove = 0

/obj/item/weapon/legcuffs/yautja
	name = "Yautja Mine"
	throw_speed = 2
	throw_range = 2
	icon = 'icons/Predator/items.dmi'
	icon_state = "yauttrap0"
	desc = "A bizarre Yautja device used for trapping and killing prey."
	var/armed = 0
	breakouttime = 600 // 1 minute
	layer = 2.8 //Goes under weeds.

	dropped(var/mob/living/carbon/human/mob) //Changes to "camouflaged" icons based on where it was dropped.
		..()
		if(armed)
			if(isturf(mob.loc))
				if(istype(mob.loc,/turf/unsimulated/floor/gm/dirt))
					icon_state = "yauttrapdirt"
				else if (istype(mob.loc,/turf/unsimulated/floor/gm/grass))
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
					H.Weaken(4)
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
	name = "Yautja vox caster"
	desc = "A strange Yautja device used for projecting the Yautja's voice to the others in its pack. Similar in function to a standard human radio."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = 1214
	unacidable = 1

	New()
		..()
		del(keyslot1)
		keyslot1 = new /obj/item/device/encryptionkey/yautja
		syndie = 1
		recalculateChannels()

	talk_into(mob/living/M as mob, message, channel, var/verb = "says", var/datum/language/speaking = null)
		if(!isYautja(M)) //Nope.
			M << "You try to talk into the headset, but just get a horrible shrieking in your ears."
			return

		for(var/mob/living/carbon/hellhound/H in player_list)
			if(istype(H) && !H.stat)
				H << "\[Radio\]: [M.real_name] [verb], '<B>[message]</b>'."

		..()
		return

/obj/item/device/encryptionkey/yautja
	name = "Yautja Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cypherkey"
	channels = list("Yautja" = 1)

/obj/item/weapon/gun/launcher/speargun
	name = "Yautja Speargun"
	desc = "A compact Yautja device in the shape of a crescent. It can rapidly fire damaging spikes and automatically recharges."
	icon = 'icons/Predator/items.dmi'
	icon_state = "speargun-3"
	icon_empty = "speargun-0"
	item_state = "predspeargun"
	fire_sound = 'sound/effects/woodhit.ogg' // TODO: Decent THWOK noise.
	ejectshell = 0                          // No spent shells.
	mouthshoot = 1                         // No suiciding with this weapon, causes runtimes.
	w_class = 3 //Fits in yautja bags.
	fire_delay = 5
	var/fired = 0
	slot_flags = SLOT_BELT|SLOT_BACK
	var/spikes = 12
	var/max_spikes = 12
	var/last_regen

	Del()
		processing_objects.Remove(src)
		..()

	process()
		if(spikes < max_spikes && world.time > last_regen + 100 && prob(70))
			spikes++
			last_regen = world.time
			update_icon()

	New()
		..()
		ammo = new /datum/ammo/yautja_spike()
		processing_objects.Add(src)
		last_regen = world.time

	examine()
		..()
		usr << "It currently has [spikes] / [max_spikes] spikes."

	load_into_chamber()
		if(spikes <= 0)	return 0
		if(!isYautja(usr)) return 0

		var/obj/item/projectile/P = new(src) //New bullet!

		in_chamber = null
		spikes--

		P.ammo = src.ammo //Share the ammo type. This does all the heavy lifting.
		P.name = P.ammo.name
		P.icon_state = P.ammo.icon_state //Make it look fancy.
		P.damage = P.ammo.damage //For reverse lookups.
		P.damage_type = P.ammo.damage_type
		in_chamber = P
		return 1

	update_icon()
		if(spikes <= 0)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		return


/obj/item/weapon/melee/yautja_chain
	name = "Yautja Chainwhip"
	desc = "A segmented, lightweight whip made of durable, acid-resistant metal. Not very common among Yautja Hunters, but still a dangerous weapon capable of shredding prey."
	icon_state = "whip"
	item_state = "chain"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 28
	throwforce = 12
	w_class = 3
	unacidable = 1
	sharp = 0
	edge = 0
	attack_verb = list("whipped", "slashed","sliced","diced","shredded")

	attack(mob/target as mob, mob/living/user as mob)
		if(user.zone_sel.selecting == "r_leg" || user.zone_sel.selecting == "l_leg" || user.zone_sel.selecting == "l_foot" || user.zone_sel.selecting == "r_foot")
			if(prob(30) && !target.lying)
				if(isXeno(target))
					if(target:big_xeno) //Can't trip the big ones.
						return ..()
				playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
				user.visible_message("<span class = 'warning'>\The [src] lashes out and [target] goes down!</span>","<span class='warning'><b>You trip [target]!</span></b>")
				target.Weaken(4)
		return ..()

/obj/item/weapon/melee/yautja_knife
	name = "Yautja Ceremonial Dagger"
	desc = "A viciously sharp dagger enscribed with ancient Yautja markings. Smells thickly of blood. Carried by some hunters."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predknife"
	item_state = "knife"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_POCKET
	sharp = 1
	force = 24
	w_class = 1.0
	throwforce = 28
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

	attack_self(mob/living/carbon/human/user as mob)
		if(!isYautja(user)) return
		if(!hasorgans(user)) return

		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja/H = user.get_inactive_hand()
		var/pain_factor = 1 //Preds don't normally feel pain. This is an exception.

		if(!istype(H) || !H.reagents.total_volume)
			H = null

		user << "\red You begin using your knife to rip shrapnel out. Hold still. This will probably hurt."

		if(do_after(user,50))
			if(isnull(H)) //No crystal, just get the shrapnel out of us.
				for(var/datum/organ/external/organ in user.organs)
					for(var/obj/S in organ.implants)
						if(istype(S)) user << "\red You dig shrapnel out of your [organ.name]."
						S.loc = user.loc
						organ.implants -= S
						pain_factor++
						organ.take_damage(rand(2,5), 0, 0)
						organ.status |= ORGAN_BLEEDING

					for(var/datum/organ/internal/I in organ.internal_organs) //Now go in and clean out the internal ones.
						for(var/obj/Q in I)
							Q.loc = user.loc
							I.take_damage(rand(1,2), 0, 0)
							pain_factor += 3 //OWWW! No internal bleeding though.

				if(pain_factor < 1)
					user << "There was nothing to dig out."
				else if(pain_factor >= 1 && pain_factor < 5)
					user << "\red That hurt like hell!!"
				else if(pain_factor >= 5)
					user.emote("roar")

			else //Yay crystal as well. Heals all internal damage.
				user << "\red You crush the <b>healing crystal</b> into a fine powder and sprinkle it on your injuries. Hold still to heal the rest!"
				if(do_after(user,10))
					for(var/datum/organ/external/organ in user.organs)
						for(var/datum/organ/internal/current_organ in organ.internal_organs)
							current_organ.rejuvenate()
							for(var/obj/B in current_organ)
								B.loc = user.loc

					user.drop_from_inventory(H)
					del(H)
					src.attack_self(user) //Do it again! No crystal this time though.
		else
			user << "You were interrupted!"
		return

/obj/item/weapon/melee/yautja_sword
	name = "Yautja Hunting Blade"
	desc = "An expertly crafted Yautja blade carried by hunters who wish to fight up close. Razor sharp, and capable of cutting flesh into ribbons. Commonly carried by aggresive and lethal hunters."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predsword"
	item_state = "clansword"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK
	sharp = 1
	force = 38
	w_class = 4.0
	throwforce = 18
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(!isYautja(user))
			user << "\blue You aren't strong enough to swing the sword properly!"
			force = initial(force) - 24
			if(prob(50))
				user.make_dizzy(80)
		else
			force = initial(force)

		if(isYautja(user) && prob(15) && !target.lying)
			user.visible_message("[user] slashes \the [target] so hard they go flying!")
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			target.Weaken(3)
			step_away(target,user,1)
		return ..()

	pickup(mob/living/user as mob)
		if(!isYautja(user))
			user << "You struggle to pick up the huge, unwieldy sword. It makes you dizzy just trying to hold it."
			user.make_dizzy(50)

/obj/item/weapon/melee/yautja_scythe
	name = "Yautja Double War Scythe"
	desc = "A huge, incredibly sharp double blade used for hunting dangerous prey. This weapon is commonly carried by Yautja who wish to disable and slice apart their foes.."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predscythe"
	item_state = "scythe0"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK
	sharp = 1
	force = 32
	w_class = 4.0
	throwforce = 24
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unacidable = 1

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(!isYautja(user))
			if(prob(20))
				user.visible_message("\red <B>The [src] slips out of your hands!</b>")
				user.drop_from_inventory(src)
				return
		..()
		if(ishuman(target)) //Slicey dicey!
			if(prob(14))
				var/datum/organ/external/affecting
				affecting = target:get_organ(ran_zone(user.zone_sel.selecting,60))
				if(!affecting)
					affecting = target:get_organ(ran_zone(user.zone_sel.selecting,90)) //No luck? Try again.
				if(affecting)
					if(affecting.body_part != UPPER_TORSO && affecting.body_part != LOWER_TORSO) //as hilarious as it is
						user.visible_message("\red <B>The limb is sliced clean off!</b>","\red You slice off a limb!")
						affecting.droplimb(1,0,1) //the 0,1 is explode, and amputation. This amputates.
		else //Probably an alien
			if(prob(14))
				..() //Do it again! CRIT!

		return

/obj/item/weapon/gun/launcher/plasmarifle
	name = "Yautja Plasma Rifle"
	desc = "A long-barreled heavy plasma weapon capable of taking down large game. It has a mounted scope for distant shots and an integrated battery."
	icon = 'icons/Predator/items.dmi'
	icon_state = "spike-0"
	item_state = "spikelauncher"
	fire_sound = 'sound/weapons/plasma_shot.ogg'
	zoomdevicename = "scope"
	w_class = 5
	fire_delay = 10
	var/fired = 0
	slot_flags = SLOT_BACK
	var/last_regen
	var/charge_time = 0
	accuracy = 50
	unacidable = 1

	verb/scope()
		set category = "Yautja"
		set name = "Use Scope"
		set popup_menu = 1

		zoom()

	Del()
		processing_objects.Remove(src)
		..()

	process()
		if(charge_time < 100)
			charge_time++
			if(charge_time == 99)
				if(usr) usr << "\blue [src] hums as it achieves maximum charge."

	New()
		..()
		ammo = new /datum/ammo/energy/yautja/rifle()
		processing_objects.Add(src)
		last_regen = world.time

	examine()
		..()
		usr << "It currently has [charge_time] / 100 charge."

	load_into_chamber()
		if(!isYautja(usr)) return 0

		var/obj/item/projectile/P = new(src) //New bullet!
		in_chamber = null

		P.ammo = src.ammo //Share the ammo type. This does all the heavy lifting.
		P.name = P.ammo.name

		if(charge_time < 15)
			P.icon_state = "ion"
			P.ammo.shell_speed = 2
			P.ammo.weaken = 2
		else
			P.icon_state = "bluespace"
			P.ammo.shell_speed = 1
			P.ammo.weaken = 0

		P.damage = P.ammo.damage + charge_time
		P.ammo.accuracy = accuracy + charge_time
		P.damage_type = P.ammo.damage_type
		in_chamber = P
		charge_time = round(charge_time / 2)
		P.SetLuminosity(1)
		return 1

	attack_self(mob/user as mob)
		if(!isYautja(user))
			return ..()

		if(charge_time > 10)
			user.visible_message("\blue You feel a strange surge of energy in the area.","\blue You release the rifle battery's energy.")
			var/obj/item/clothing/gloves/yautja/Y = user:gloves
			if(Y && Y.charge < Y.charge_max)
				Y.charge += charge_time * 2
				if(Y.charge > Y.charge_max) Y.charge = Y.charge_max
				charge_time = 0
				user << "Your bracers absorb some of the released energy."
		else
			user << "The weapon's not charged enough with ambient energy."
		return


/obj/item/weapon/grenade/spawnergrenade/hellhound
	name = "hellhound caller"
	spawner_type = /mob/living/carbon/hellhound
	deliveryamt = 1
	desc = "A strange piece of alien technology. It seems to call forth a hellhound."
	icon = 'icons/Predator/items.dmi'
	icon_state = "hellnade"
	force = 25
	throwforce = 55
	w_class = 1.0
	det_time = 30
	var/obj/machinery/camera/current = null
	var/turf/activated_turf = null

	dropped()
		check_eye()
		return ..()

	attack_self(mob/user as mob)
		if(!active)
			if(!isYautja(user))
				user << "What's this thing?"
				return
			user << "<span class='warning'>You activate the hellhound beacon!</span>"
			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
		else
			if(!isYautja(user)) return
			activated_turf = get_turf(user)
			display_camera(user)
		return

	activate(mob/user as mob)
		if(active)
			return

		if(user)
			msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		icon_state = initial(icon_state) + "_active"
		active = 1
		if(dangerous)
			updateicon()
		spawn(det_time)
			prime()
			return

	prime()
		if(spawner_type && deliveryamt)
			// Make a quick flash
			var/turf/T = get_turf(src)
			if(ispath(spawner_type))
				new spawner_type(T)
//		del(src)
		return

	check_eye(var/mob/user as mob)
		if (user.stat || user.blinded )
			current = null
		if ( !current || get_turf(user) != activated_turf || src.loc != user ) //camera doesn't work, or we moved.
			current = null
		user.reset_view(current)
		return 1

	proc/display_camera(var/mob/user as mob)
		var/list/L = list()
		for(var/mob/living/carbon/hellhound/H in mob_list)
			L += H.real_name
		L["Cancel"] = "Cancel"

		var/choice = input(user,"Which hellhound would you like to observe? (moving will drop the feed)","Camera View") as null|anything in L
		if(!choice || choice == "Cancel" || isnull(choice))
			current = null
			user.reset_view(null)
			user.unset_machine()
			user << "Stopping camera feed."
			return

		for(var/mob/living/carbon/hellhound/Q in mob_list)
			if(Q.real_name == choice)
				current = Q.camera
				break

		if(istype(current))
			user << "Switching feed.."
			user.set_machine(current)
			user.reset_view(current)
		else
			user << "Something went wrong with the camera feed."
		return


//Telescopic baton
/obj/item/weapon/melee/combistick
	name = "Yautja Combi-Stick"
	desc = "A compact yet deadly personal weapon. Can be concealed when folded. Functions well as a throwing weapon or defensive tool. A common sight in Yautja packs due to its versatility."
	icon = 'icons/Predator/items.dmi'
	icon_state = "combi"
	item_state = "combilong"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BACK
	w_class = 4
	force = 32
	throwforce = 70
	unacidable = 1
	sharp = 1
	attack_verb = list("speared", "stabbed", "impaled")
	var/on = 1
	var/timer = 0

	IsShield()
		return on

/obj/item/weapon/melee/combistick/attack_self(mob/user as mob)
	if(timer) return
	on = !on
	if(on)
		user.visible_message("\red With a flick of their wrist, [user] extends their [src].",\
		"\red You extend the combi-stick.",\
		"You hear an ominous click.")
		icon_state = "combi"
		item_state = "combilong"
		w_class = 4
		force = 28
		throwforce = initial(throwforce)
		attack_verb = list("speared", "stabbed", "impaled")
		timer = 1
		spawn(10)
			timer = 0
	else
		user << "\blue You collapse the combi-stick for storage."
		icon_state = "combi_sheathed"
		item_state = "combishort"
		w_class = 1
		force = 0
		throwforce = initial(throwforce) - 50
		attack_verb = list("thwacked", "smacked")
		timer = 1
		spawn(10)
			timer = 0

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/device/yautja_teleporter
	name = "Yautja relay"
	desc = "A device covered in Yautja writing. It whirrs and beeps every couple of seconds."
	icon = 'icons/Predator/items.dmi'
	icon_state = "teleporter"
	flags = FPRINT | TABLEPASS
	w_class = 2
	force = 1
	throwforce = 1
	unacidable = 1
	var/timer = 0

	attack_self(mob/user as mob)
		if(istype(get_area(user),/area/yautja))
			user << "Nothing happens."
			return

		var/sure = alert("Really trigger it?","Sure?","Yes","No")
		if(sure == "No" || !sure) return
		playsound(src,'sound/ambience/signal.ogg', 100, 1)
		timer = 1
		user.visible_message("[user] starts becoming shimmery and indistinct..")
		if(do_after(user,100))
			var/mob/living/holding = user.pulling
			user.visible_message("\icon[user] [user] disappears!")
			user.loc = pick(pred_spawn)
			timer = 0
			if(holding)
				holding.visible_message("\icon[holding] \The [holding] disappears!")
				holding.loc = pick(pred_spawn)
		else
			spawn(10)
				timer = 0

//Doesn't give heat or anything yet, it's just a light source.
/obj/structure/campfire
	name = "fire"
	desc = "A crackling fire. What is it even burning?"
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "campfire"
	density = 0
	layer = 2
	anchored = 1
	unacidable = 1

	New()
		..()
		l_color = "#FFFF0C" //Yeller
		SetLuminosity(7)
		spawn(3000)
			if(ticker && istype(ticker.mode,/datum/game_mode/huntergames)) loop_firetick()


	proc/loop_firetick() //Crackly!
		while(src && ticker)
			SetLuminosity(0)
			SetLuminosity(rand(5,6))
			sleep(rand(15,30))


/*
/obj/item/weapon/gun/launcher/netgun
	name = "Yautja Net Gun"
	desc = "A short, wide-barreled weapon that fires weighted, difficult-to-remove nets or a grappling rope to snap back unwary enemies."
	var/max_nets = 1
	var/nets = 1
	var/fire_mode = 1 //1 is net. 0 is retrieve.
	release_force = 5
	icon = 'icons/Predator/items.dmi'
	icon_state = "netgun-empty"
	item_state = "predspeargun"
	fire_sound_text = "a strange noise"
	fire_sound = 'sound/weapons/Laser2.ogg' //Vyoooo!


/obj/item/weapon/gun/launcher/netgun/examine()
	..()
	usr << "It has [nets] [nets == 1 ? "net" : "nets"] remaining."

/obj/item/weapon/gun/launcher/netgun/update_icon()
	if(!nets)
		icon_state = "netgun-empty"
	else
		if(fire_mode)
			icon_state = "netgun-ready"
		else
			icon_state = "netgun-retrieve"

/obj/item/weapon/gun/launcher/netgun/emp_act(severity)
	return

/obj/item/weapon/gun/launcher/spikethrower/special_check(user)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(!isYautja(H))
			user << "\red \The [src] does not respond to you!"
			return 0
	return 1

/obj/item/weapon/gun/launcher/netgun/update_release_force()
	return

/obj/item/weapon/gun/launcher/netgun/load_into_chamber()
	if(in_chamber) return 1
	if(nets < 1) return 0

	in_chamber = new /obj/item/weapon/net(src)
	nets--
	return 1

/obj/item/weapon/gun/launcher/netgun/afterattack(atom/target, mob/user , flag)
	if(isYautja(user))
		if(istype(user.hands,/obj/item/clothing/gloves/yautja))
			var/obj/item/clothing/gloves/yautja/G = user.hands
			if(G.cloaked)
				G.decloak(user)
	return ..()

//The "projectile".
/obj/item/weapon/net
	name = "flying net"
	anchored = 0
	density = 0
	unacidable = 1
	w_class = 1
	layer = MOB_LAYER + 1.1
	desc = "A strange, self-winding net. It constricts automatically around its prey, immobilizing them."
	icon = 'icons/Predator/items.dmi'
	icon_state = "net1"
	flags = TABLEPASS
	pass_flags = PASSTABLE
	var/state = 1 //"bunched up" state
	var/fire_mode = 1//1: net. 0: grab

	attack_hand(user as mob)
		return

	update_icon()
		icon_state = "net[state]"

	proc/wrap_person(var/mob/living/carbon/victim)
		if(isnull(victim) || !istype(victim)) return 0

	throw_at(atom/target, range, speed)
		..()
		spawn(3)
			icon_state = "net2"
			state = 2
			spawn(3)
				icon_state = "net3"
				state = 3

	throw_impact(atom/hit_atom)
		..()
		if(!istype(hit_atom,/mob/living/carbon)) return 0
*/
//Items specific to yautja. Other people can use em, they're not restricted or anything.
//They can't, however, activate any of the special functions.

//=================//\\=================\\
//======================================\\

/*
				 EQUIPMENT
*/

//======================================\\
//=================\\//=================\\

/obj/item/clothing/mask/gas/yautja
	name = "clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "pred_mask1"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 95, laser = 70, energy = 70, bomb = 65, bio = 100, rad = 100)
	min_cold_protection_temperature = SPACE_HELMET_min_cold_protection_temperature
	flags_armor_protection = HEAD|FACE|EYES
	flags_cold_protection = HEAD
	flags_inventory = COVEREYES|COVERMOUTH|NOPRESSUREDMAGE|ALLOWINTERNALS|ALLOWREBREATH|BLOCKGASEFFECT|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDELOWHAIR
	filtered_gases = list("phoron", "sleeping_agent", "carbon_dioxide")
	gas_filter_strength = 3
	eye_protection = 2
	var/current_goggles = 0 //0: OFF. 1: NVG. 2: Thermals. 3: Mesons
	vision_impair = 0
	unacidable = 1
	anti_hug = 100

/obj/item/clothing/mask/gas/yautja/New(location, mask_number = rand(1,7), elder_restricted = 0)
	..()
	loc = location

	var/mask_input[] = list(1,2,3,4,5,6,7,231,334,732,928)
	if(mask_number in mask_input) icon_state = "pred_mask[mask_number]"
	if(elder_restricted) //Not possible for non-elders.
		switch(mask_number)
			if(1341)
				name = "\improper 'Mask of the Dragon'"
				icon_state = "pred_mask_elder_tr"
			if(7128)
				name = "\improper 'Mask of the Swamp Horror'"
				icon_state = "pred_mask_elder_joshuu"
			if(9867)
				name = "\improper 'Mask of the Enforcer'"
				icon_state = "pred_mask_elder_feweh"
			if(4879)
				name = "\improper 'Mask of the Ambivalent Collector'"
				icon_state = "pred_mask_elder_n"

/obj/item/clothing/mask/gas/yautja/verb/togglesight()
	set name = "Toggle Mask Visors"
	set desc = "Toggle your mask visor sights. You must only be wearing a type of Yautja visor for this to work."
	set category = "Yautja"

	if(!usr || usr.stat) return
	var/mob/living/carbon/human/M = usr
	if(!istype(M)) return
	if(M.species && M.species.name != "Yautja")
		M << "<span class='warning'>You have no idea how to work these things!</span>"
		return
	var/obj/item/clothing/gloves/yautja/Y = M.gloves //Doesn't actually reduce power, but needs the bracers anyway.
	if(!Y || !istype(Y))
		M << "<span class='warning'>You must be wearing your bracers, as they have the power source.</span>"
		return
	var/obj/item/G = M.glasses
	if(G)
		if(!istype(G,/obj/item/clothing/glasses/night/yautja) && !istype(G,/obj/item/clothing/glasses/meson/yautja) && !istype(G,/obj/item/clothing/glasses/thermal/yautja))
			M << "<span class='warning'>You need to remove your glasses first. Why are you even wearing these?</span>"
			return
		M.temp_drop_inv_item(G) //Get rid of ye existinge gogglors
		cdel(G)
	switch(current_goggles)
		if(0)
			M.equip_to_slot_or_del(rnew(/obj/item/clothing/glasses/night/yautja,M), WEAR_EYES)
			M << "<span class='notice'>Low-light vision module: activated.</span>"
			if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 15, 1)
		if(1)
			M.equip_to_slot_or_del(rnew(/obj/item/clothing/glasses/thermal/yautja,M), WEAR_EYES)
			M << "<span class='notice'>Thermal sight module: activated.</span>"
			if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 15, 1)
		if(2)
			M.equip_to_slot_or_del(rnew(/obj/item/clothing/glasses/meson/yautja,M), WEAR_EYES)
			M << "<span class='notice'>Material vision module: activated.</span>"
			if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 15, 1)
		if(3)
			M << "<span class='notice'>You deactivate your visor.</span>"
			if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 15, 1)
	M.update_inv_glasses()
	current_goggles++
	if(current_goggles > 3) current_goggles = 0


/obj/item/clothing/mask/gas/yautja/equipped(mob/living/carbon/human/user, slot)
	if(slot == WEAR_FACE)
		var/datum/mob_hud/H = huds[MOB_HUD_MEDICAL_ADVANCED]
		H.add_hud_to(user)
	..()

/obj/item/clothing/mask/gas/yautja/dropped(mob/living/carbon/human/mob) //Clear the gogglors if the helmet is removed.
	if(istype(mob) && mob.wear_mask == src) //inventory reference is only cleared after dropped().
		var/obj/item/G = mob.glasses
		if(G)
			if(istype(G,/obj/item/clothing/glasses/night/yautja) || istype(G,/obj/item/clothing/glasses/meson/yautja) || istype(G,/obj/item/clothing/glasses/thermal/yautja))
				mob.temp_drop_inv_item(G)
				cdel(G)
				mob.update_inv_glasses()
		var/datum/mob_hud/H = huds[MOB_HUD_MEDICAL_ADVANCED]
		H.remove_hud_from(mob)
	..()

/obj/item/clothing/suit/armor/yautja
	name = "clan armor"
	desc = "A suit of armor with light padding. It looks old, yet functional."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "halfarmor1"
	item_state = "armor"
	sprite_sheet_id = 1
	flags_armor_protection = UPPER_TORSO|ARM_LEFT
	armor = list(melee = 75, bullet = 75, laser = 60, energy = 65, bomb = 65, bio = 20, rad = 20)
	min_cold_protection_temperature = ARMOR_min_cold_protection_temperature
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature
	siemens_coefficient = 0.1
	allowed = list(/obj/item/weapon/harpoon,
			/obj/item/weapon/gun/launcher/spike,
			/obj/item/weapon/gun/energy/plasmarifle,
			/obj/item/weapon/gun/energy/plasmapistol,
			/obj/item/weapon/yautja_chain,
			/obj/item/weapon/yautja_knife,
			/obj/item/weapon/yautja_sword,
			/obj/item/weapon/yautja_scythe,
			/obj/item/weapon/combistick,
			/obj/item/weapon/twohanded/glaive)
	unacidable = 1

/obj/item/clothing/suit/armor/yautja/New(location, armor_number = rand(1,5), elder_restricted = 0)
	..()
	loc = location

	if(elder_restricted)
		switch(armor_number)
			if(1341)
				name = "\improper 'Armor of the Dragon'"
				icon_state = "halfarmor_elder_tr"
				armor = list(melee = 75, bullet = 85, laser = 60, energy = 70, bomb = 70, bio = 25, rad = 25)
			if(7128)
				name = "\improper 'Armor of the Swamp Horror'"
				icon_state = "halfarmor_elder_joshuu"
				flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
				armor = list(melee = 70, bullet = 80, laser = 60, energy = 70, bomb = 65, bio = 25, rad = 25)
			if(9867)
				name = "\improper 'Armor of the Enforcer'"
				icon_state = "halfarmor_elder_feweh"
				flags_armor_protection = UPPER_TORSO|ARMS
				armor = list(melee = 75, bullet = 85, laser = 60, energy = 70, bomb = 65, bio = 25, rad = 25)
			if(4879)
				name = "\improper 'Armor of the Ambivalent Collector'"
				icon_state = "halfarmor_elder_n"
				flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
				armor = list(melee = 75, bullet = 85, laser = 60, energy = 70, bomb = 65, bio = 25, rad = 25)
			else
				name = "clan elder's armor"
				icon_state = "halfarmor_elder"
				flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
				armor = list(melee = 70, bullet = 80, laser = 60, energy = 70, bomb = 65, bio = 25, rad = 25)
	else
		switch(armor_number)
			if(2)
				icon_state = "halfarmor[armor_number]"
				flags_armor_protection = UPPER_TORSO|ARMS
				armor = list(melee = 75, bullet = 75, laser = 60, energy = 65, bomb = 65, bio = 20, rad = 20)
			if(3)
				icon_state = "halfarmor[armor_number]"
				flags_armor_protection = UPPER_TORSO|LOWER_TORSO
				armor = list(melee = 75, bullet = 75, laser = 60, energy = 65, bomb = 65, bio = 20, rad = 20)
			if(4)
				icon_state = "halfarmor[armor_number]"
				flags_armor_protection = UPPER_TORSO
				armor = list(melee = 75, bullet = 80, laser = 60, energy = 70, bomb = 70, bio = 20, rad = 20)
			if(5,441)
				icon_state = "halfarmor[armor_number]"
				flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
				armor = list(melee = 70, bullet = 70, laser = 55, energy = 65, bomb = 65, bio = 20, rad = 20)
	flags_cold_protection = flags_armor_protection
	flags_heat_protection = flags_armor_protection

/obj/item/clothing/suit/armor/yautja/full
	name = "heavy clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon_state = "fullarmor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 90, bullet = 95, laser = 75, energy = 75, bomb = 75, bio = 25, rad = 25)
	slowdown = 1

/obj/item/clothing/suit/armor/yautja/full/New(location)
	. = ..(location, 0)



/obj/item/clothing/cape

/obj/item/clothing/cape/eldercape
	name = "clan elder cape"
	desc = "A dusty, yet powerful cape worn and passed down by elder Yautja."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "cape_elder"
	flags_equip_slot = SLOT_BACK
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 10, bullet = 0, laser = 5, energy = 15, bomb = 0, bio = 0, rad = 0)
	unacidable = 1

/obj/item/clothing/cape/eldercape/New(location, cape_number)
	..()
	switch(cape_number)
		if(1341)
			name = "\improper 'Mantle of the Dragon'"
			icon_state = "cape_elder_tr"
		if(7128)
			name = "\improper 'Mantle of the Swamp Horror'"
			icon_state = "cape_elder_joshuu"
		if(9867)
			name = "\improper 'Mantle of the Enforcer'"
			icon_state = "cape_elder_feweh"
		if(4879)
			name = "\improper 'Mantle of the Ambivalent Collector'"
			icon_state = "cape_elder_n"

/obj/item/clothing/shoes/yautja
	name = "clan greaves"
	icon_state = "y-boots1"
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."
	unacidable = 1
	permeability_coefficient = 0.01
	flags_inventory = NOSLIPPING
	flags_armor_protection = FEET|LEGS
	armor = list(melee = 75, bullet = 85, laser = 60, energy = 50, bomb = 50, bio = 20, rad = 20)
	siemens_coefficient = 0.2
	min_cold_protection_temperature = SHOE_min_cold_protection_temperature
	max_heat_protection_temperature = SHOE_max_heat_protection_temperature
	species_restricted = null

/obj/item/clothing/shoes/yautja/New(location, boot_number = rand(1,3))
	..()
	icon_state = "y-boots[boot_number]"
	if(boot_number != 1) //More overall protection, less defensive value.
		flags_armor_protection = FEET|LEGS|LOWER_TORSO
		armor = list(melee = 65, bullet = 75, laser = 55, energy = 45, bomb = 45, bio = 20, rad = 20)
	flags_cold_protection = flags_armor_protection
	flags_heat_protection = flags_armor_protection

/obj/item/clothing/under/chainshirt
	name = "body mesh"
	icon = 'icons/obj/clothing/uniforms.dmi'
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."
	icon_state = "mesh_shirt"
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|FEET|HANDS //Does not cover the head though.
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|FEET|HANDS
	has_sensor = 0
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 10, bio = 10, rad = 10)
	siemens_coefficient = 0.9
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	species_restricted = null

/obj/item/clothing/gloves/yautja
	name = "clan bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "bracer"
	origin_tech = "combat=8;materials=8;magnets=8;programming=8"
	species_restricted = null
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	flags_item = NODROP
	flags_armor_protection = HANDS
	armor = list(melee = 80, bullet = 80, laser = 55, energy = 50, bomb = 50, bio = 10, rad = 10)
	flags_cold_protection = HANDS
	flags_heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_min_cold_protection_temperature
	max_heat_protection_temperature = GLOVES_max_heat_protection_temperature
	unacidable = 1
	var/charge = 2000
	var/charge_max = 2000
	var/cloaked = 0
	var/blades_active = 0
	var/caster_active = 0
	var/exploding = 0
	var/inject_timer = 0
	var/cloak_timer = 0
	var/upgrades = 0

/obj/item/clothing/gloves/yautja/emp_act(severity)
	charge -= (severity * 500)
	if(charge < 0) charge = 0
	if(usr)
		usr.visible_message("<span class='danger'>You hear a hiss and crackle!</span>","<span class='danger'>Your bracers hiss and spark!</span>")
		if(cloaked)
			decloak(usr)

/obj/item/clothing/gloves/yautja/equipped(mob/user, slot)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(slot == WEAR_HANDS && H.species && H.species.name == "Yautja")
			processing_objects.Add(src)

/obj/item/clothing/gloves/yautja/dropped(mob/user)
	processing_objects.Remove(src)
	..()

/obj/item/clothing/gloves/yautja/process()
	if(!ishuman(loc))
		processing_objects.Remove(src)
		return
	var/mob/living/carbon/human/H = loc
	if(cloak_timer)
		cloak_timer--
	if(cloaked)
		H.alpha = 10
		charge = max(charge - 10, 0)
		if(charge <= 0)
			decloak(loc)
	else
		charge = min(charge + 30, charge_max)
	var/perc_charge = (charge / charge_max * 100)
	H.update_power_display(perc_charge)


//This is the main proc for checking AND draining the bracer energy. It must have M passed as an argument.
//It can take a negative value in amount to restore energy.
//Also instantly updates the yautja power HUD display.
/obj/item/clothing/gloves/yautja/proc/drain_power(var/mob/living/carbon/human/M, var/amount)
	if(!M) return 0
	if(charge < amount)
		M << "<span class='warning'>Your bracers lack the energy. They have only <b>[charge]/[charge_max]</b> remaining and need <B>[amount]</b>.</span>"
		return 0
	charge -= amount
	var/perc = (charge / charge_max * 100)
	M.update_power_display(perc)
	return 1

/obj/item/clothing/gloves/yautja/examine(mob/user)
	..()
	user << "They currently have [charge] out of [charge_max] charge."

//Should put a cool menu here, like ninjas.
/obj/item/clothing/gloves/yautja/verb/wristblades()
	set name = "Use Wrist Blades"
	set desc = "Extend your wrist blades. They cannot be dropped, but can be retracted."
	set category = "Yautja"

	if(!usr.loc || !usr.canmove || usr.stat) return
	var/mob/living/carbon/human/user = usr
	if(!istype(user)) return
	if(!isYautja(user))
		user << "<span class='warning'>You have no idea how to work these things!</span>"
		return
	var/obj/item/weapon/wristblades/R = user.get_active_hand()
	if(R && istype(R)) //Turn it off.
		user << "<span class='notice'>You retract your wrist blades.</span>"
		playsound(user.loc,'sound/weapons/wristblades_off.ogg', 15, 1)
		blades_active = 0
		user.drop_inv_item_to_loc(R, R.loc)
		return
	else
		if(!drain_power(user,50)) return

		if(R)
			user << "<span class='warning'>Your hand must be free to activate your wrist blade!</span>"
			return

		var/datum/limb/hand = user.get_limb(user.hand ? "l_hand" : "r_hand")
		if(!istype(hand) || !hand.is_usable())
			user << "<span class='warning'>You can't hold that!</span>"
			return

		var/obj/item/weapon/wristblades/W
		W =  rnew(upgrades > 2 ? /obj/item/weapon/wristblades/scimitar : /obj/item/weapon/wristblades, user)

		user.put_in_active_hand(W)
		blades_active = 1
		user << "<span class='notice'>You activate your wrist blades.</span>"
		playsound(user,'sound/weapons/wristblades_on.ogg', 15, 1)


	return 1


/obj/item/clothing/gloves/yautja/verb/cloaker()
	set name = "Toggle Cloaking Device"
	set desc = "Activate your suit's cloaking device. It will malfunction if the suit takes damage or gets excessively wet."
	set category = "Yautja"


	if(!usr || usr.stat) return
	var/mob/living/carbon/human/M = usr
	if(!istype(M)) return
	if(!isYautja(usr))
		usr << "<span class='warning'>You have no idea how to work these things!</span>"
		return 0
	if(cloaked) //Turn it off.
		decloak(usr)
	else //Turn it on!
		if(cloak_timer)
			if(prob(50))
				M << "<span class='warning'>Your cloaking device is still recharging! Time left: <B>[cloak_timer]</b> ticks.</span>"
			return 0
		if(!drain_power(M,50)) return
		cloaked = 1
		M << "<span class='notice'>You are now invisible to normal detection.</span>"
		for(var/mob/O in oviewers(M))
			O.show_message("[M] vanishes into thin air!",1)
		playsound(M.loc,'sound/effects/pred_cloakon.ogg', 15, 1)
		M.alpha = 10

		var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
		SA.remove_from_hud(M)
		var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
		XI.remove_from_hud(M)
		spawn(1)
			anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

	return 1

/obj/item/clothing/gloves/yautja/proc/decloak(var/mob/user)
	if(!user) return
	user << "Your cloaking device deactivates."
	cloaked = 0
	for(var/mob/O in oviewers(user))
		O.show_message("[user.name] shimmers into existence!",1)
	playsound(user.loc,'sound/effects/pred_cloakoff.ogg', 15, 1)
	user.alpha = initial(user.alpha)
	cloak_timer = 10

	var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
	SA.add_to_hud(user)
	var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
	XI.add_to_hud(user)

	spawn(1)
		if(user)
			anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)


/obj/item/clothing/gloves/yautja/verb/caster()
	set name = "Use Plasma Caster"
	set desc = "Activate your plasma caster. If it is dropped it will retract back into your armor."
	set category = "Yautja"

	if(!usr.loc || !usr.canmove || usr.stat) return
	var/mob/living/carbon/human/M = usr
	if(!istype(M)) return
	if(!isYautja(usr))
		usr << "<span class='warning'>You have no idea how to work these things!</span>"
		return
	var/obj/item/weapon/gun/energy/plasma_caster/R = usr.r_hand
	var/obj/item/weapon/gun/energy/plasma_caster/L = usr.l_hand
	if(!istype(R) && !istype(L))
		caster_active = 0
	if(caster_active) //Turn it off.
		var/found = 0
		if(R && istype(R))
			found = 1
			usr.r_hand = null
			if(R)
				M.temp_drop_inv_item(R)
				cdel(R)
			M.update_inv_r_hand()
		if(L && istype(L))
			found = 1
			usr.l_hand = null
			if(L)
				M.temp_drop_inv_item(L)
				cdel(L)
			M.update_inv_l_hand()
		if(found)
			usr << "<span class='notice'>You deactivate your plasma caster.</span>"
			playsound(src,'sound/weapons/pred_plasmacaster_off.ogg', 15, 1)
			caster_active = 0
		return
	else //Turn it on!
		if(usr.get_active_hand())
			usr << "<span class='warning'>Your hand must be free to activate your caster!</span>"
			return
		if(!drain_power(usr,50)) return

		var/obj/item/weapon/gun/energy/plasma_caster/W = new(usr)
		usr.put_in_active_hand(W)
		W.source = src
		caster_active = 1
		usr << "<span class='notice'>You activate your plasma caster.</span>"
		playsound(src,'sound/weapons/pred_plasmacaster_on.ogg', 15, 1)


/obj/item/clothing/gloves/yautja/proc/explodey(var/mob/living/carbon/victim)
	set waitfor = 0
	exploding = 1
	playsound(src.loc,'sound/effects/pred_countdown.ogg', 100, 0, 15, 10)
	sleep(rand(65,85))
	var/turf/T = get_turf(victim)
	if(istype(T) && exploding)
		victim.apply_damage(50,BRUTE,"chest")
		explosion(T, 2, 10, 15, 20) //Dramatically BIG explosion.
		if(victim) victim.gib() //Adding one more safety.

/obj/item/clothing/gloves/yautja/verb/activate_suicide()
	set name = "Final Countdown (!)"
	set desc = "Activate the explosive device implanted into your bracers. You have failed! Show some honor!"
	set category = "Yautja"
	if(!usr) return
	var/mob/living/carbon/human/M = usr
	if(!istype(M)) return
	if(!M.stat == CONSCIOUS)
		M << "<span class='warning'>Not while you're unconcious...</span>"
		return
	if(M.stat == DEAD)
		M << "<span class='warning'>Little too late for that now!</span>"
		return
	if(!isYautja(M))
		M << "<span class='warning'>You have no idea how to work these things!</span>"
		return

	var/obj/item/grab/G = M.get_active_hand()
	if(istype(G))
		var/mob/living/carbon/human/comrade = G.grabbed_thing
		if(isYautja(comrade) && comrade.stat == DEAD)
			var/obj/item/clothing/gloves/yautja/bracer = comrade.gloves
			if(istype(bracer))
				if(alert("Are you sure you want to send this Yautja into the great hunting grounds?","Explosive Bracers", "Yes", "No") == "Yes")
					if(M.get_active_hand() == G && comrade && comrade.gloves == bracer && !bracer.exploding)
						bracer.explodey(comrade)
						M.visible_message("<span class='warning'>[M] presses a few buttons on [comrade]'s wrist bracer.</span>","<span class='danger'>You activate the timer. May [comrade]'s final hunt be swift.</span>")
			else
				M << "<span class='warning'>Your fallen comrade does not have a bracer. <b>Report this to your elder so that it's fixed.</b></span>"
			return

	if(M.gloves != src)
		return

	if(exploding)
		if(alert("Are you sure you want to stop the countdown?","Bracers", "Yes", "No") == "Yes")
			if(M.gloves != src)
				return
			if(M.stat == DEAD)
				M << "<span class='warning'>Little too late for that now!</span>"
				return
			if(!M.stat == CONSCIOUS)
				M << "<span class='warning'>Not while you're unconcious...</span>"
				return
			exploding = 0
			M << "<span class='notice'>Your bracers stop beeping.</span>"
		return
	if((M.wear_mask && istype(M.wear_mask,/obj/item/clothing/mask/facehugger)) || M.status_flags & XENO_HOST)
		M << "<span class='warning'>Strange...something seems to be interfering with your bracer functions...</span>"
		return
	if(alert("Detonate the bracers? Are you sure?","Explosive Bracers", "Yes", "No") == "Yes")
		if(M.gloves != src)
			return
		if(M.stat == DEAD)
			M << "<span class='warning'>Little too late for that now!</span>"
			return
		if(!M.stat == CONSCIOUS)
			M << "<span class='warning'>Not while you're unconcious...</span>"
			return
		M << "<span class='userdanger'>You set the timer. May your journey to the great hunting grounds be swift.</span>"
		explodey(M)

/obj/item/clothing/gloves/yautja/verb/injectors()
	set name = "Create Self-Heal Crystal"
	set category = "Yautja"
	set desc = "Create a focus crystal to energize your natural healing processes."

	if(!usr.canmove || usr.stat || usr.is_mob_restrained())
		return 0

	if(!isYautja(usr))
		usr << "<span class='warning'>You have no idea how to work these things!/span>"
		return

	if(usr.get_active_hand())
		usr << "<span class='warning'>Your active hand must be empty!</span>"
		return 0

	if(inject_timer)
		usr << "<span class='warning'>You recently activated the healing crystal. Be patient.</span>"
		return

	if(!drain_power(usr,1000)) return

	inject_timer = 1
	spawn(1200)
		if(usr && src.loc == usr)
			usr << "\blue Your bracers beep faintly and inform you that a new healing crystal is ready to be created."
			inject_timer = 0

	usr << "\blue You feel a faint hiss and a crystalline injector drops into your hand."
	var/obj/item/reagent_container/hypospray/autoinjector/yautja/O = new(usr)
	usr.put_in_active_hand(O)
	playsound(src,'sound/machines/click.ogg', 15, 1)
	return

/obj/item/clothing/gloves/yautja/verb/call_disk()
	set name = "Call Smart-Disc"
	set category = "Yautja"
	set desc = "Call back your smart-disc, if it's in range. If not you'll have to go retrieve it."

	if(usr.is_mob_incapacitated())
		return 0

	if(!isYautja(usr))
		usr << "<span class='warning'>You have no idea how to work these things!</span>"
		return

	if(inject_timer)
		usr << "<span class='warning'>Your bracers need some time to recuperate first.</span>"
		return 0

	if(!drain_power(usr,70)) return
	inject_timer = 1
	spawn(100)
		inject_timer = 0

	for(var/mob/living/simple_animal/hostile/smartdisc/S in range(7))
		usr << "<span class='warning'>The [S] skips back towards you!</span>"
		new /obj/item/explosive/grenade/spawnergrenade/smartdisc(S.loc)
		cdel(S)

	for(var/obj/item/explosive/grenade/spawnergrenade/smartdisc/D in range(10))
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
	if(!msg || !usr.client) return

	msg = sanitize(msg)
	msg = oldreplacetext(msg, "a", "@")
	msg = oldreplacetext(msg, "e", "3")
	msg = oldreplacetext(msg, "i", "1")
	msg = oldreplacetext(msg, "o", "0")
	msg = oldreplacetext(msg, "u", "^")
	msg = oldreplacetext(msg, "y", "7")
	msg = oldreplacetext(msg, "r", "9")
	msg = oldreplacetext(msg, "s", "5")
	msg = oldreplacetext(msg, "t", "7")
	msg = oldreplacetext(msg, "l", "1")
	msg = oldreplacetext(msg, "n", "*")
	   //Preds now speak in bastardized 1337speak BECAUSE.

	spawn(10)
		if(!drain_power(usr,50)) return //At this point they've upgraded.
		var/mob/Q
		for(Q in hearers(usr))
			if(Q.stat == 1) continue //Unconscious
			if(isXeno(Q) && upgrades != 2) continue
			Q << "<span class='info'>A strange voice says,</span> <span class='rough'>'[msg]'.</span>"

//=================//\\=================\\
//======================================\\

/*
				   GEAR
*/

//======================================\\
//=================\\//=================\\

//Yautja channel. Has to delete stock encryption key so we don't receive sulaco channel.
/obj/item/device/radio/headset/yautja
	name = "vox caster"
	desc = "A strange Yautja device used for projecting the Yautja's voice to the others in its pack. Similar in function to a standard human radio."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = CIV_GEN_FREQ
	unacidable = 1

	New()
		..()
		cdel(keyslot1)
		keyslot1 = new /obj/item/device/encryptionkey/yautja
		recalculateChannels()

	talk_into(mob/living/M as mob, message, channel, var/verb = "commands", var/datum/language/speaking = "Sainja")
		if(!isYautja(M)) //Nope.
			M << "<span class='warning'>You try to talk into the headset, but just get a horrible shrieking in your ears!</span>"
			return

		for(var/mob/living/carbon/hellhound/H in player_list)
			if(istype(H) && !H.stat)
				H << "\[Radio\]: [M.real_name] [verb], '<B>[message]</b>'."
		..()

	attackby()
		return

/obj/item/device/encryptionkey/yautja
	name = "\improper Yautja encryption key"
	desc = "A complicated encryption device."
	icon_state = "cypherkey"
	channels = list("Yautja" = 1)

//Yes, it's a backpack that goes on the belt. I want the backpack noises. Deal with it (tm)
/obj/item/storage/backpack/yautja
	name = "hunting pouch"
	desc = "A Yautja hunting pouch worn around the waist, made from a thick tanned hide. Capable of holding various devices and tools and used for the transport of trophies."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "beltbag"
	flags_equip_slot = SLOT_WAIST
	max_w_class = 3
	storage_slots = 10
	max_storage_space = 30


/obj/item/reagent_container/hypospray/autoinjector/yautja
	name = "unusual crysal"
	desc = "A strange glowing crystal with a spike at one end."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "crystal"
	amount_per_transfer_from_this = 35
	volume = 35

	New()
		..()
		spawn(1)
			reagents.add_reagent("thwei", 30)


/obj/item/device/yautja_teleporter
	name = "relay beacon"
	desc = "A device covered in sacred text. It whirrs and beeps every couple of seconds."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "teleporter"
	origin_tech = "materials=7;bluespace=7;engineering=7"
	flags_atom = FPRINT|CONDUCT
	w_class = 1
	force = 1
	throwforce = 1
	unacidable = 1
	var/timer = 0

	attack_self(mob/user)
		set waitfor = 0
		if(istype(get_area(user),/area/yautja))
			user << "Nothing happens."
			return
		var/mob/living/carbon/human/H = user
		var/sure = alert("Really trigger it?","Sure?","Yes","No")
		if(!isYautja(H))
			user << "<span class='warning'>The screen angrily flashes three times!</span>"
			playsound(user, 'sound/effects/EMPulse.ogg', 25, 1)
			sleep(30)
			explosion(loc,-1,-1,2)
			if(loc)
				if(ismob(loc))
					user = loc
					user.temp_drop_inv_item(src)
				cdel(src)
			return

		if(sure == "No" || !sure) return
		playsound(src,'sound/ambience/signal.ogg', 25, 1)
		timer = 1
		user.visible_message("<span class='info'>[user] starts becoming shimmery and indistinct...</span>")
		if(do_after(user,100, TRUE, 5, BUSY_ICON_GENERIC))
			// Teleport self.
			user.visible_message("<span class='warning'>\icon[user][user] disappears!</span>")
			var/tele_time = animation_teleport_quick_out(user)
			// Also teleport whoever you're pulling.
			var/mob/living/M = user.pulling
			if(istype(M))
				M.visible_message("<span class='warning'>\icon[M][M] disappears!</span>")
				animation_teleport_quick_out(M)
			sleep(tele_time)

			var/turf/end_turf = pick(pred_spawn)
			user.forceMove(end_turf)
			animation_teleport_quick_in(user)
			if(M && M.loc)
				M.forceMove(end_turf)
				animation_teleport_quick_in(M)
			timer = 0
		else
			sleep(10)
			if(loc) timer = 0

//Doesn't give heat or anything yet, it's just a light source.
/obj/structure/campfire
	name = "fire"
	desc = "A crackling fire. What is it even burning?"
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "campfire"
	density = 0
	layer = TURF_LAYER
	anchored = 1
	unacidable = 1

	New()
		..()
		l_color = "#FFFF0C" //Yeller
		SetLuminosity(4)
		spawn(3000)
			if(ticker && istype(ticker.mode,/datum/game_mode/huntergames)) loop_firetick()


	proc/loop_firetick() //Crackly!
		while(src && ticker)
			SetLuminosity(0)
			SetLuminosity(rand(3,4))
			sleep(rand(15,30))

//=================//\\=================\\
//======================================\\

/*
			  MELEE WEAPONS
*/

//======================================\\
//=================\\//=================\\

/obj/item/weapon/harpoon/yautja
	name = "large harpoon"
	desc = "A huge metal spike, with a hook at the end. It's carved with mysterious alien writing."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "spike"
	item_state = "harpoon"
	force = 15
	throwforce = 38
	attack_verb = list("jabbed","stabbed","ripped", "skewered")
	unacidable = 1
	sharp = IS_SHARP_ITEM_BIG


/obj/item/weapon/wristblades
	name = "wrist blades"
	desc = "A pair of huge, serrated blades extending from a metal gauntlet."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "wrist"
	item_state = "wristblade"
	force = 30
	w_class = 5
	edge = 1
	sharp = 0
	flags_item = NOSHIELD|DELONDROP
	flags_equip_slot = NOFLAGS
	hitsound = 'sound/weapons/wristblades_hit.ogg'
	attack_speed = 6
	pry_capable = IS_PRY_CAPABLE_FORCE

/obj/item/weapon/wristblades/New()
	..()
	if(usr)
		var/obj/item/weapon/wristblades/W = usr.get_inactive_hand()
		if(istype(W)) //wristblade in usr's other hand.
			attack_speed = attack_speed - attack_speed/3
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")


/obj/item/weapon/wristblades/Dispose()
	. = ..()
	return TA_REVIVE_ME

/obj/item/weapon/wristblades/Recycle()
	var/blacklist[] = list("attack_verb")
	. = ..() + blacklist

/obj/item/weapon/wristblades/dropped(mob/living/carbon/human/M)
	playsound(M,'sound/weapons/wristblades_off.ogg', 15, 1)
	if(M)
		var/obj/item/weapon/wristblades/W = M.get_inactive_hand()
		if(istype(W))
			W.attack_speed = initial(attack_speed)
	..()

/obj/item/weapon/wristblades/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !user) return
	if(user)
		var/obj/item/weapon/wristblades/W = user.get_inactive_hand()
		attack_speed = (istype(W)) ? 4 : initial(attack_speed)

	if (istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/D = A
		if(D.operating || !D.density) return
		user << "<span class='notice'>You jam [src] into [D] and strain to rip it open.</span>"
		playsound(user,'sound/weapons/wristblades_hit.ogg', 15, 1)
		if(do_after(user,30, TRUE, 5, BUSY_ICON_HOSTILE) && D.density)
			D.open(1)

/obj/item/weapon/wristblades/scimitar
	name = "wrist scimitar"
	desc = "An enormous serrated blade that extends from the gauntlet."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "scim"
	item_state = "scim"
	force = 50
	attack_speed = 18 //Will have the same speed as the glaive if there are two.
	hitsound = 'sound/weapons/pierce.ogg'

//I need to go over these weapons and balance them out later. Right now they're pretty all over the place.
/obj/item/weapon/yautja_chain
	name = "chainwhip"
	desc = "A segmented, lightweight whip made of durable, acid-resistant metal. Not very common among Yautja Hunters, but still a dangerous weapon capable of shredding prey."
	icon_state = "whip"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 35
	throwforce = 12
	w_class = 3
	unacidable = 1
	sharp = 0
	edge = 0
	attack_verb = list("whipped", "slashed","sliced","diced","shredded")

	attack(mob/target as mob, mob/living/user as mob)
		if(user.zone_selected == "r_leg" || user.zone_selected == "l_leg" || user.zone_selected == "l_foot" || user.zone_selected == "r_foot")
			if(prob(35) && !target.lying)
				if(isXeno(target))
					if(target.mob_size == MOB_SIZE_BIG) //Can't trip the big ones.
						return ..()
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
				user.visible_message("<span class = 'danger'>[src] lashes out and [target] goes down!</span>","<span class='danger'><b>You trip [target]!</b></span>")
				target.KnockDown(5)
		return ..()

/obj/item/weapon/yautja_knife
	name = "ceremonial dagger"
	desc = "A viciously sharp dagger enscribed with ancient Yautja markings. Smells thickly of blood. Carried by some hunters."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "predknife"
	item_state = "knife"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_STORE
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 24
	w_class = 1
	throwforce = 28
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	actions_types = list(/datum/action/item_action)
	unacidable = 1

	attack_self(mob/living/carbon/human/user as mob)
		if(!isYautja(user)) return
		if(!hasorgans(user)) return

		var/pain_factor = 0 //Preds don't normally feel pain. This is an exception.

		user << "<span class='notice'>You begin using your knife to rip shrapnel out. Hold still. This will probably hurt...</span>"

		if(do_after(user,50, TRUE, 5, BUSY_ICON_FRIENDLY))
			var/obj/item/shard/shrapnel/S
			for(var/datum/limb/O in user.limbs)
				for(S in O.implants)
					user << "<span class='notice'>You dig shrapnel out of your [O.name].</span>"
					S.loc = user.loc
					O.implants -= S
					pain_factor++
					O.take_damage(rand(2,5), 0, 0)
					O.status |= LIMB_BLEEDING

			for(var/datum/internal_organ/I in user.internal_organs) //Now go in and clean out the internal ones.
				for(var/obj/Q in I)
					Q.loc = user.loc
					I.take_damage(rand(1,2), 0, 0)
					pain_factor += 3 //OWWW! No internal bleeding though.

			switch(pain_factor)
				if(0) user << "<span class='warning'>There was nothing to dig out!</span>"
				if(1 to 4) user << "<span class='warning'>That hurt like hell!!</span>"
				if(5 to INFINITY) user.emote("roar")

		else user << "<span class='warning'>You were interrupted!</span>"

/obj/item/weapon/yautja_sword
	name = "clan sword"
	desc = "An expertly crafted Yautja blade carried by hunters who wish to fight up close. Razor sharp, and capable of cutting flesh into ribbons. Commonly carried by aggresive and lethal hunters."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "clansword"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BACK
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	force = 45 //More damage than other weapons like it. Considering how "strong" this sword is supposed to be, 38 damage was laughable.
	w_class = 4.0
	throwforce = 18
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	attack_speed = 9
	unacidable = 1

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(isYautja(user))
			force = initial(force)
			if(prob(22) && !target.lying)
				user.visible_message("<span class='danger'>[user] slashes [target] so hard, they go flying!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
				target.KnockDown(3)
				step_away(target,user,1)
		else
			user << "<span class='warning'>You aren't strong enough to swing the sword properly!</span>"
			force = round(initial(force)/2)
			if(prob(50)) user.make_dizzy(80)

		return ..()

	pickup(mob/living/user as mob)
		if(!isYautja(user))
			user << "<span class='warning'>You struggle to pick up the huge, unwieldy sword. It makes you dizzy just trying to hold it!</span>"
			user.make_dizzy(50)

/obj/item/weapon/yautja_scythe
	name = "double war scythe"
	desc = "A huge, incredibly sharp double blade used for hunting dangerous prey. This weapon is commonly carried by Yautja who wish to disable and slice apart their foes.."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "predscythe"
	item_state = "scythe"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	sharp = IS_SHARP_ITEM_BIG
	force = 32
	w_class = 4.0
	throwforce = 24
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unacidable = 1

	New()
	 icon_state = pick("predscythe","predscythe_alt")

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(!isYautja(user))
			if(prob(20))
				user.visible_message("<span class='warning'>[src] slips out of your hands!</span>")
				user.drop_inv_item_on_ground(src)
				return
		..()
		if(ishuman(target)) //Slicey dicey!
			if(prob(14))
				var/datum/limb/affecting
				affecting = target:get_limb(ran_zone(user.zone_selected,60))
				if(!affecting)
					affecting = target:get_limb(ran_zone(user.zone_selected,90)) //No luck? Try again.
				if(affecting)
					if(affecting.body_part != UPPER_TORSO && affecting.body_part != LOWER_TORSO) //as hilarious as it is
						user.visible_message("<span class='danger'>The limb is sliced clean off!</span>","<span class='danger'>You slice off a limb!</span>")
						affecting.droplimb(1) //the second 1 is  amputation. This amputates.
		else //Probably an alien
			if(prob(14))
				..() //Do it again! CRIT!

		return

//Telescopic baton
/obj/item/weapon/combistick
	name = "combi-stick"
	desc = "A compact yet deadly personal weapon. Can be concealed when folded. Functions well as a throwing weapon or defensive tool. A common sight in Yautja packs due to its versatility."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "combistick"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BACK
	w_class = 4
	force = 32
	throwforce = 70
	unacidable = 1
	sharp = IS_SHARP_ITEM_ACCURATE
	attack_verb = list("speared", "stabbed", "impaled")
	var/on = 1
	var/timer = 0

	IsShield()
		return on

/obj/item/weapon/combistick/attack_self(mob/user as mob)
	if(timer) return
	on = !on
	if(on)
		user.visible_message("<span class='info'>With a flick of their wrist, [user] extends [src].</span>",\
		"<span class='notice'>You extend [src].</span>",\
		"You hear an ominous click.")
		icon_state = initial(icon_state)
		flags_equip_slot = initial(flags_equip_slot)
		w_class = 4
		force = 28
		throwforce = initial(throwforce)
		attack_verb = list("speared", "stabbed", "impaled")
		timer = 1
		spawn(10)
			timer = 0

		if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
			overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

			var/icon/I = new /icon(src.icon, src.icon_state)
			I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
			I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
			blood_overlay = I

			overlays += blood_overlay
	else
		user << "<span class='notice'>You collapse [src] for storage.</span>"
		icon_state = initial(icon_state) + "_f"
		flags_equip_slot = SLOT_STORE
		w_class = 1
		force = 0
		throwforce = initial(throwforce) - 50
		attack_verb = list("thwacked", "smacked")
		timer = 1
		spawn(10)
			timer = 0
		overlays.Cut()

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/gun_empty.ogg', 25, 1)
	add_fingerprint(user)

	return



//=================//\\=================\\
//======================================\\

/*
			   OTHER THINGS
*/

//======================================\\
//=================\\//=================\\

/obj/item/explosive/grenade/spawnergrenade/hellhound
	name = "hellhound caller"
	spawner_type = /mob/living/carbon/hellhound
	deliveryamt = 1
	desc = "A strange piece of alien technology. It seems to call forth a hellhound."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "hellnade"
	force = 25
	throwforce = 55
	w_class = 1.0
	det_time = 30
	var/obj/machinery/camera/current = null
	var/turf/activated_turf = null

	dropped(mob/user)
		check_eye(user)
		return ..()

	attack_self(mob/user)
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

	activate(mob/user)
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
//		cdel(src)
		return

	check_eye(mob/user)
		if (user.is_mob_incapacitated() || user.blinded )
			user.unset_interaction()
		else if ( !current || get_turf(user) != activated_turf || src.loc != user ) //camera doesn't work, or we moved.
			user.unset_interaction()


	proc/display_camera(var/mob/user as mob)
		var/list/L = list()
		for(var/mob/living/carbon/hellhound/H in mob_list)
			L += H.real_name
		L["Cancel"] = "Cancel"

		var/choice = input(user,"Which hellhound would you like to observe? (moving will drop the feed)","Camera View") as null|anything in L
		if(!choice || choice == "Cancel" || isnull(choice))
			user.unset_interaction()
			user << "Stopping camera feed."
			return

		for(var/mob/living/carbon/hellhound/Q in mob_list)
			if(Q.real_name == choice)
				current = Q.camera
				break

		if(istype(current))
			user << "Switching feed.."
			user.set_interaction(current)

		else
			user << "Something went wrong with the camera feed."
		return


/obj/item/explosive/grenade/spawnergrenade/hellhound/on_set_interaction(mob/user)
	..()
	user.reset_view(current)

/obj/item/explosive/grenade/spawnergrenade/hellhound/on_unset_interaction(mob/user)
	..()
	current = null
	user.reset_view(null)


//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()



/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=1;materials=1"
	matter = list("metal" = 2000)
	ammo = /datum/ammo/energy/taser
	movement_acc_penalty_mult = 1
	var/obj/item/cell/high/cell //10000 power.
	var/charge_cost = 100 //100 shots.
	flags_gun_features = GUN_UNUSUAL_DESIGN
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0

/obj/item/weapon/gun/energy/taser/New()
	..()
	cell = new /obj/item/cell/high(src)

/obj/item/weapon/gun/energy/taser/set_gun_config_values()
	fire_delay = config.high_fire_delay * 2
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


/obj/item/weapon/gun/energy/taser/update_icon()
	if(!cell || cell.charge - charge_cost < 0)
		icon_state = base_gun_icon + "_e"
	else
		icon_state = base_gun_icon

/obj/item/weapon/gun/energy/taser/emp_act(severity)
	cell.use(round(cell.maxcharge / severity))
	update_icon()
	..()

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
			to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
			return 0

/obj/item/weapon/gun/energy/taser/load_into_chamber()
	if(!cell || cell.charge - charge_cost < 0) return

	cell.charge -= charge_cost
	in_chamber = create_bullet(ammo)
	return in_chamber

/obj/item/weapon/gun/energy/taser/reload_into_chamber()
	update_icon()
	return 1

/obj/item/weapon/gun/energy/taser/delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) cell.charge += charge_cost
	return 1



/obj/item/weapon/gun/energy/plasmarifle
	name = "plasma rifle"
	desc = "A long-barreled heavy plasma weapon capable of taking down large game. It has a mounted scope for distant shots and an integrated battery."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasmarifle"
	item_state = "plasmarifle"
	origin_tech = "combat=8;materials=7;bluespace=6"
	unacidable = 1
	fire_sound = 'sound/weapons/pred_plasma_shot.ogg'
	ammo = /datum/ammo/energy/yautja/rifle/bolt
	muzzle_flash = null // TO DO, add a decent one.
	zoomdevicename = "scope"
	flags_equip_slot = SLOT_BACK
	w_class = 5
	var/charge_time = 0
	var/last_regen = 0
	flags_gun_features = GUN_UNUSUAL_DESIGN


/obj/item/weapon/gun/energy/plasmarifle/New()
	..()
	processing_objects.Add(src)
	last_regen = world.time
	update_icon()
	verbs -= /obj/item/weapon/gun/verb/field_strip
	verbs -= /obj/item/weapon/gun/verb/toggle_burst
	verbs -= /obj/item/weapon/gun/verb/empty_mag



/obj/item/weapon/gun/energy/plasmarifle/Dispose()
	. = ..()
	processing_objects.Remove(src)


/obj/item/weapon/gun/energy/plasmarifle/process()
	if(charge_time < 100)
		charge_time++
		if(charge_time == 99)
			if(ismob(loc)) to_chat(loc, "<span class='notice'>[src] hums as it achieves maximum charge.</span>")
		update_icon()


/obj/item/weapon/gun/energy/plasmarifle/set_gun_config_values()
	fire_delay = config.high_fire_delay*2
	accuracy_mult = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


/obj/item/weapon/gun/energy/plasmarifle/examine(mob/user)
	if(isYautja(user))
		..()
		to_chat(user, "It currently has [charge_time] / 100 charge.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/plasmarifle/update_icon()
	if(last_regen < charge_time + 20 || last_regen > charge_time || charge_time > 95)
		var/new_icon_state = charge_time <=15 ? null : icon_state + "[round(charge_time/33, 1)]"
		update_special_overlay(new_icon_state)
		last_regen = charge_time

/obj/item/weapon/gun/energy/plasmarifle/unique_action(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	..()
	zoom(user)

/obj/item/weapon/gun/energy/plasmarifle/able_to_fire(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return

	return ..()

/obj/item/weapon/gun/energy/plasmarifle/load_into_chamber()
	ammo = ammo_list[charge_time < 15? /datum/ammo/energy/yautja/rifle/bolt : /datum/ammo/energy/yautja/rifle/blast]
	var/obj/item/projectile/P = create_bullet(ammo)
	P.SetLuminosity(1)
	in_chamber = P
	charge_time = round(charge_time / 2)
	return in_chamber

/obj/item/weapon/gun/energy/plasmarifle/reload_into_chamber()
	update_icon()
	return 1

/obj/item/weapon/gun/energy/plasmarifle/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) charge_time *= 2
	return 1

/obj/item/weapon/gun/energy/plasmarifle/attack_self(mob/living/user)
	if(!isYautja(user))
		return ..()

	if(charge_time > 10)
		user.visible_message("<span class='notice'>You feel a strange surge of energy in the area.</span>","<span class='notice'>You release the rifle battery's energy.</span>")
		var/obj/item/clothing/gloves/yautja/Y = user:gloves
		if(Y && Y.charge < Y.charge_max)
			Y.charge += charge_time * 2
			if(Y.charge > Y.charge_max) Y.charge = Y.charge_max
			charge_time = 0
			to_chat(user, "<span class='notice'>Your bracers absorb some of the released energy.</span>")
			update_icon()
	else
		to_chat(user, "<span class='warning'>The weapon's not charged enough with ambient energy!</span>")





/obj/item/weapon/gun/energy/plasmapistol
	name = "plasma pistol"
	desc = "A plasma pistol capable of rapid fire. It has an integrated battery."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasmapistol"
	item_state = "plasmapistol"
	origin_tech = "combat=8;materials=7;bluespace=6"
	unacidable = 1
	fire_sound = 'sound/weapons/pulse3.ogg'
	flags_equip_slot = SLOT_WAIST
	ammo = /datum/ammo/energy/yautja/pistol
	muzzle_flash = null // TO DO, add a decent one.
	w_class = 3
	var/charge_time = 40
	flags_gun_features = GUN_UNUSUAL_DESIGN


/obj/item/weapon/gun/energy/plasmapistol/New()
	..()
	processing_objects.Add(src)
	verbs -= /obj/item/weapon/gun/verb/field_strip
	verbs -= /obj/item/weapon/gun/verb/toggle_burst
	verbs -= /obj/item/weapon/gun/verb/empty_mag



/obj/item/weapon/gun/energy/plasmapistol/Dispose()
	. = ..()
	processing_objects.Remove(src)


/obj/item/weapon/gun/energy/plasmapistol/process()
	if(charge_time < 40)
		charge_time++
		if(charge_time == 39)
			if(ismob(loc)) to_chat(loc, "<span class='notice'>[src] hums as it achieves maximum charge.</span>")



/obj/item/weapon/gun/energy/plasmapistol/set_gun_config_values()
	fire_delay = config.med_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.med_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.high_hit_accuracy_mult
	scatter = config.low_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult



/obj/item/weapon/gun/energy/plasmapistol/examine(mob/user)
	if(isYautja(user))
		..()
		to_chat(user, "It currently has [charge_time] / 40 charge.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")


/obj/item/weapon/gun/energy/plasmapistol/able_to_fire(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	else
		return ..()

/obj/item/weapon/gun/energy/plasmapistol/load_into_chamber()
	if(charge_time < 1) return
	var/obj/item/projectile/P = create_bullet(ammo)
	P.SetLuminosity(1)
	in_chamber = P
	charge_time -= 1
	return in_chamber

/obj/item/weapon/gun/energy/plasmapistol/reload_into_chamber()
	return 1

/obj/item/weapon/gun/energy/plasmapistol/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) charge_time *= 2
	return 1











/obj/item/weapon/gun/energy/plasma_caster
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasma"
	item_state = "plasma_wear"
	name = "plasma caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	fire_sound = 'sound/weapons/pred_plasmacaster_fire.ogg'
	ammo = /datum/ammo/energy/yautja/caster/bolt
	muzzle_flash = null // TO DO, add a decent one.
	w_class = 5
	force = 0
	fire_delay = 3
	var/obj/item/clothing/gloves/yautja/source = null
	var/charge_cost = 100 //How much energy is needed to fire.
	var/mode = 0
	actions_types = list(/datum/action/item_action/toggle)
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON|DELONDROP //Can't bludgeon with this.
	flags_gun_features = GUN_UNUSUAL_DESIGN

/obj/item/weapon/gun/energy/plasma_caster/New()
	..()
	verbs -= /obj/item/weapon/gun/verb/field_strip
	verbs -= /obj/item/weapon/gun/verb/toggle_burst
	verbs -= /obj/item/weapon/gun/verb/empty_mag
	verbs -= /obj/item/weapon/gun/verb/use_unique_action

/obj/item/weapon/gun/energy/plasma_caster/Dispose()
	. = ..()
	source = null


/obj/item/weapon/gun/energy/plasma_caster/set_gun_config_values()
	fire_delay = config.high_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.high_fire_delay
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult

/obj/item/weapon/gun/energy/plasma_caster/attack_self(mob/living/user)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 100
			fire_delay = config.med_fire_delay * 4
			fire_sound = 'sound/weapons/emitter2.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire medium plasma blasts.</span>")
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/blast]
		if(1)
			mode = 2
			charge_cost = 300
			fire_delay = config.high_fire_delay * 20
			fire_sound = 'sound/weapons/pulse.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire heavy plasma spheres.</span>")
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/sphere]
		if(2)
			mode = 0
			charge_cost = 30
			fire_delay = config.high_fire_delay
			fire_sound = 'sound/weapons/pred_lasercannon.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire light plasma bolts.</span>")
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/bolt]

/obj/item/weapon/gun/energy/plasma_caster/dropped(mob/living/carbon/human/M)
	playsound(M,'sound/weapons/pred_plasmacaster_off.ogg', 15, 1)
	..()

/obj/item/weapon/gun/energy/plasma_caster/able_to_fire(mob/user)
	if(!source)	return
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return

	return ..()

/obj/item/weapon/gun/energy/plasma_caster/load_into_chamber()
	if(source.drain_power(usr,charge_cost))
		in_chamber = create_bullet(ammo)
		return in_chamber

/obj/item/weapon/gun/energy/plasma_caster/reload_into_chamber()
	return 1

/obj/item/weapon/gun/energy/plasma_caster/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund)
		source.charge += charge_cost
		var/perc = source.charge / source.charge_max * 100
		var/mob/living/carbon/human/user = usr //Hacky...
		user.update_power_display(perc)
	return 1

//-------------------------------------------------------
//Lasguns

/obj/item/weapon/gun/energy/lasgun
	name = "\improper Lasgun"
	desc = "A laser based firearm. Uses power cells."
	origin_tech = "combat=5;materials=4"
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg'
	fire_sound = 'sound/weapons/Laser.ogg'
	matter = list("metal" = 2000)
	flags_equip_slot = SLOT_BACK
	w_class = 4
	force = 15
	overcharge = 0
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ENERGY
	aim_slowdown = SLOWDOWN_ADS_RIFLE
	wield_delay = WIELD_DELAY_SLOW
	gun_skill_category = GUN_SKILL_RIFLES


/obj/item/weapon/gun/energy/lasgun/set_gun_config_values()
	fire_delay = config.low_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.high_hit_accuracy_mult
	damage_mult = config.base_hit_damage_mult
	scatter_unwielded = config.max_scatter_value * 2 //Heavy and unwieldy
	damage_falloff_mult = config.med_damage_falloff_mult


//-------------------------------------------------------
//M43 Sunfury Lasgun MK1

/obj/item/weapon/gun/energy/lasgun/M43
	name = "\improper M43 Sunfury Lasgun MK1"
	desc = "An accurate, recoilless laser based battle rifle with an integrated charge selector. Ideal for longer range engagements. Uses power cells."
	force = 15 //Large and hefty!
	icon_state = "m43"
	item_state = "m43"
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/scope,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade)

/obj/item/weapon/gun/energy/lasgun/M43/New()
	..()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 24, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)
	var/obj/item/attachable/stock/lasgun/S = new(src)
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachables()
	update_icon()
	S.icon_state = initial(S.icon_state)


/obj/item/weapon/gun/energy/lasgun/M43/set_gun_config_values()
	fire_delay = config.low_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.max_hit_accuracy_mult //Heavy and unwieldy; you don't one hand this.
	damage_mult = config.base_hit_damage_mult
	scatter_unwielded = config.max_scatter_value * 2.5 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = config.med_damage_falloff_mult

//variant without ugl attachment
/obj/item/weapon/gun/energy/lasgun/M43/stripped
	starting_attachment_types = list()

/obj/item/weapon/gun/energy/lasgun/M43/unique_action(mob/user)
	toggle_chargemode(user)


//Toggles Overcharge mode. Overcharge mode significantly increases damage and AP in exchange for doubled ammo usage and increased fire delay.
/obj/item/weapon/gun/energy/lasgun/proc/toggle_chargemode(mob/user)
	if(overcharge == 0)
		if(current_mag.current_rounds < 1)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 1)
			to_chat(user, "<span class='warning'>You attempt to toggle on [src]'s overcharge mode but your battery pack lacks adequate charge to do so.</span>")
			return
		//While overcharge is active, double ammo consumption, and
		playsound(user, 'sound/weapons/emitter.ogg', 15, 1)
		ammo_per_shot = 2
		fire_delay = config.med_fire_delay * 2 // 1 shot per second fire rate
		damage_falloff_mult = config.low_damage_falloff_mult
		fire_sound = 'sound/weapons/Laser3.ogg'
		to_chat(user, "\icon[src] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = 1
	else
		playsound(user, 'sound/weapons/emitter2.ogg', 15, 1)
		ammo_per_shot = 1
		fire_delay = config.low_fire_delay
		damage_falloff_mult = config.med_damage_falloff_mult
		fire_sound = 'sound/weapons/Laser.ogg'
		to_chat(user, "\icon[src] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = 0
	replace_ammo(user,current_mag)
	load_into_chamber(user, TRUE)
	//to_chat(user, "DEBUG: Toggle End: Magazine: [current_mag] Regular: [current_mag.default_ammo] Overcharge: [current_mag.overcharge_ammo] Ammo per Shot: [ammo_per_shot] Ammo: [ammo] Chamber: [in_chamber] Rounds Left: [current_mag.current_rounds]")
	/*	if(in_chamber) //Update chamber if we have something loaded.
			update_chamber(user,refund)*/

//Ammo/Charge functions
/obj/item/weapon/gun/energy/lasgun/update_icon(mob/user)
	if(!current_mag || current_mag.current_rounds <= 0)
		icon_state = base_gun_icon + "_0"
		if(flags_item & WIELDED)
			item_state = "m43_0_w"
		else
			item_state = "m43_0"
	else if(current_mag.current_rounds > round(current_mag.max_rounds*0.75))
		icon_state = base_gun_icon + "_100"
		if(flags_item & WIELDED)
			item_state = "m43_100_w"
		else
			item_state = "m43_100"
	else if(current_mag.current_rounds > round(current_mag.max_rounds*0.5))
		icon_state = base_gun_icon + "_75"
		if(flags_item & WIELDED)
			item_state = "m43_75_w"
		else
			item_state = "m43_75"
	else if(current_mag.current_rounds > round(current_mag.max_rounds*0.25))
		icon_state = base_gun_icon + "_50"
		if(flags_item & WIELDED)
			item_state = "m43_50_w"
		else
			item_state = "m43_50"
	else
		icon_state = base_gun_icon + "_25"
		if(flags_item & WIELDED)
			item_state = "m43_25_w"
		else
			item_state = "m43_25"
	if(current_mag)
		update_mag_overlay()
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(src == M.l_hand)
			M.update_inv_l_hand()
		else if (src == user.r_hand)
			M.update_inv_r_hand()


//EMPs will fuck with remaining charge
/obj/item/weapon/gun/energy/lasgun/emp_act(severity)
	var/amount = round(current_mag.max_rounds * rand(2,severity) * 0.1)
	if(current_mag.current_rounds < amount)	return 0
	current_mag.current_rounds = max(0,current_mag.current_rounds - amount)
	update_icon()
	current_mag.update_icon()
	..()

// use power from a cell
/obj/item/ammo_magazine/lasgun/proc/use(var/amount)

	return 1
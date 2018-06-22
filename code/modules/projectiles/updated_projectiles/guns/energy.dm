
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
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
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
			if(ismob(loc)) loc << "<span class='notice'>[src] hums as it achieves maximum charge.</span>"
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
		user << "It currently has [charge_time] / 100 charge."
	else user << "This thing looks like an alien rifle of some kind. Strange."

/obj/item/weapon/gun/energy/plasmarifle/update_icon()
	if(last_regen < charge_time + 20 || last_regen > charge_time || charge_time > 95)
		var/new_icon_state = charge_time <=15 ? null : icon_state + "[round(charge_time/33, 1)]"
		update_special_overlay(new_icon_state)
		last_regen = charge_time

/obj/item/weapon/gun/energy/plasmarifle/unique_action(mob/user)
	if(!isYautja(user))
		user << "<span class='warning'>You have no idea how this thing works!</span>"
		return
	..()
	zoom(user)

/obj/item/weapon/gun/energy/plasmarifle/able_to_fire(mob/user)
	if(!isYautja(user))
		user << "<span class='warning'>You have no idea how this thing works!</span>"
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
			user << "<span class='notice'>Your bracers absorb some of the released energy.</span>"
			update_icon()
	else user << "<span class='warning'>The weapon's not charged enough with ambient energy!</span>"





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
			if(ismob(loc)) loc << "<span class='notice'>[src] hums as it achieves maximum charge.</span>"



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
		user << "It currently has [charge_time] / 40 charge."
	else
		user << "This thing looks like an alien rifle of some kind. Strange."


/obj/item/weapon/gun/energy/plasmapistol/able_to_fire(mob/user)
	if(!isYautja(user))
		user << "<span class='warning'>You have no idea how this thing works!</span>"
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
	flags_atom = FPRINT|CONDUCT
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
			user << "<span class='notice'>[src] is now set to fire medium plasma blasts.</span>"
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/blast]
		if(1)
			mode = 2
			charge_cost = 300
			fire_delay = config.high_fire_delay * 20
			fire_sound = 'sound/weapons/pulse.ogg'
			user << "<span class='notice'>[src] is now set to fire heavy plasma spheres.</span>"
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/sphere]
		if(2)
			mode = 0
			charge_cost = 30
			fire_delay = config.high_fire_delay
			fire_sound = 'sound/weapons/pred_lasercannon.ogg'
			user << "<span class='notice'>[src] is now set to fire light plasma bolts.</span>"
			ammo = ammo_list[/datum/ammo/energy/yautja/caster/bolt]

/obj/item/weapon/gun/energy/plasma_caster/dropped(mob/living/carbon/human/M)
	playsound(M,'sound/weapons/pred_plasmacaster_off.ogg', 15, 1)
	..()

/obj/item/weapon/gun/energy/plasma_caster/able_to_fire(mob/user)
	if(!source)	return
	if(!isYautja(user))
		user << "<span class='warning'>You have no idea how this thing works!</span>"
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

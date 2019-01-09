
//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()
	var/obj/item/cell/cell //1000 power.
	var/charge_cost = 10 //100 shots.
	var/cell_type = /obj/item/cell

/obj/item/weapon/gun/energy/New()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)

/obj/item/weapon/gun/energy/able_to_fire(mob/living/user)
	. = ..()
	if(!cell || cell.charge - charge_cost < 0)
		return

/obj/item/weapon/gun/energy/load_into_chamber()
	if(!cell || cell.charge - charge_cost < 0)
		return

	cell.charge -= charge_cost
	in_chamber = create_bullet(ammo)
	return in_chamber

/obj/item/weapon/gun/energy/update_icon()
	return

/obj/item/weapon/gun/energy/reload_into_chamber()
	update_icon()
	return TRUE

/obj/item/weapon/gun/energy/delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		cell.charge += charge_cost
	return TRUE

/obj/item/weapon/gun/energy/emp_act(severity)
	cell.use(round(cell.maxcharge / severity))
	update_icon()
	return ..()

/obj/item/weapon/gun/energy/has_ammo_counter()
	return TRUE

/obj/item/weapon/gun/energy/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/energy/get_ammo_count()
	if(!cell)
		return 0
	else
		return (cell.charge / max(charge_cost, 1))


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
	charge_cost = 1250
	flags_gun_features = GUN_UNUSUAL_DESIGN
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0
	cell_type = /obj/item/cell/high

/obj/item/weapon/gun/energy/taser/set_gun_config_values()
	fire_delay = config.max_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.mlow_scatter_value
	scatter_unwielded = config.low_scatter_value
	damage_mult = config.base_hit_damage_mult

/obj/item/weapon/gun/energy/taser/update_icon()
	if(!cell || cell.charge - charge_cost < 0)
		icon_state = base_gun_icon + "_e"
	else
		icon_state = base_gun_icon

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
			to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")


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
	charge_cost = 100
	flags_gun_features = GUN_UNUSUAL_DESIGN
	cell_type = /obj/item/cell/high

/obj/item/weapon/gun/energy/plasmarifle/set_gun_config_values()
	fire_delay = config.high_fire_delay*2
	accuracy_mult = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult

/obj/item/weapon/gun/energy/plasmarifle/examine(mob/user)
	. = ..()
	if(isYautja(user))
		to_chat(user, "It currently has [cell.charge / charge_cost] shots remaining.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/plasmarifle/unique_action(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	zoom(user)
	return ..()

/obj/item/weapon/gun/energy/plasmarifle/able_to_fire(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()


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
	flags_gun_features = GUN_UNUSUAL_DESIGN

/obj/item/weapon/gun/energy/plasmapistol/set_gun_config_values()
	fire_delay = config.med_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.med_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.high_hit_accuracy_mult
	scatter = config.low_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult

/obj/item/weapon/gun/energy/plasmapistol/examine(mob/user)
	. = ..()
	if(isYautja(user))
		to_chat(user, "It currently has [cell.charge / charge_cost] shots remaining.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/plasmapistol/able_to_fire(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()


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
	charge_cost = 100
	var/mode = 0
	actions_types = list(/datum/action/item_action/toggle)
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON|DELONDROP //Can't bludgeon with this.
	flags_gun_features = GUN_UNUSUAL_DESIGN

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
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()



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
	gun_skill_category = GUN_SKILL_PISTOLS

/obj/item/weapon/gun/flare/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay) * 3

/obj/item/weapon/gun/flare/examine_ammo_count(mob/user)
	if(num_flares)
		to_chat(user, "<span class='warning'>It has [num2text(num_flares)] flare[num_flares > 1 ? "s" : ""] loaded!</span>")

/obj/item/weapon/gun/flare/update_icon()
	if(num_flares)
		icon_state = base_gun_icon
	else
		icon_state = base_gun_icon + "_e"

/obj/item/weapon/gun/flare/load_into_chamber()
	if(num_flares)
		in_chamber = create_bullet(ammo)
		in_chamber.set_light(4)
		num_flares--
		return in_chamber

/obj/item/weapon/gun/flare/reload_into_chamber()
	update_icon()
	return TRUE

/obj/item/weapon/gun/flare/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		num_flares++
	return TRUE

/obj/item/weapon/gun/flare/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/explosive/grenade/flare))
		var/obj/item/explosive/grenade/flare = I
		if(num_flares >= max_flares)
			to_chat(user, "It's already full.")
			return
		num_flares++
		user.temporarilyRemoveItemFromInventory(flare)
		qdel(flare)
		to_chat(user, "<span class='notice'>You insert the flare.</span>")
		update_icon()
	else
		return ..()

/obj/item/weapon/gun/flare/unload(mob/user)
	if(num_flares)
		var/obj/item/explosive/grenade/flare/new_flare = new()
		if(user)
			user.put_in_hands(new_flare)
		else
			new_flare.loc = get_turf(src)
		num_flares--
		to_chat(user, "<span class='notice'>You unload a flare from [src].</span>")
		update_icon()
	else
		to_chat(user, "<span class='warning'>It's empty!</span>")
	return TRUE


//-------------------------------------------------------
//Toy rocket launcher.

/obj/item/weapon/gun/launcher/rocket/toy //Fires dummy rockets, like a toy gun
	name = "\improper toy rocket launcher"
	desc = "Where did this come from?"
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket/toy
	gun_skill_category = GUN_SKILL_FIREARMS


//Syringe Gun

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	matter = list("metal" = 2000)

/obj/item/weapon/gun/syringe/examine_ammo_count(mob/user)
	if(user == loc)
		to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")

/obj/item/weapon/gun/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_container/syringe))
		var/obj/item/reagent_container/syringe/S = I
		if(S.mode == 2)
			to_chat(user, "<span class='warning'>This syringe is broken!</span>")
			return

		if(length(syringes) >= max_syringes)
			to_chat(user, "<span class='warning'>[src] cannot hold more syringes.</span>")
			return

		user.transferItemToLoc(I, src)
		syringes += I
		update_icon()
		to_chat(user, "<span class='notice'>You put the syringe in [src].</span>")
		to_chat(user, "<span class='notice'>[length(syringes)] / [max_syringes] syringes.</span>")


/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/syringe/update_icon()
	if(syringes.len)
		icon_state = base_gun_icon
	else
		icon_state = base_gun_icon + "_e"


/obj/item/weapon/gun/syringe/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(syringes.len)
		spawn(0) fire_syringe(target,user)
	else
		to_chat(usr, "<span class='warning'>[src] is empty.</span>")

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/reagent_container/syringe/S = syringes[1]
		if((!S) || (!S.reagents))	//ho boy! wot runtimes!
			return
		S.reagents.trans_to(D, S.reagents.total_volume)
		syringes -= S
		update_icon()
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						log_combat(user, M, "shot", src, "Reagents: ([R])")
						msg_admin_attack("[ADMIN_TPMONTY(usr)] shot [ADMIN_TPMONTY(M)] with a syringegun ([R]).")

					else
						M.log_message("<b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[key_name(M)]</b> with a <b>[src]</b> Reagents: ([R])", LOG_ATTACK)
						msg_admin_attack("UNKNOWN shot [ADMIN_TPMONTY(M)] with a syringegun ([R]).")

					M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")

					if(M.can_inject())
						if(D.reagents)
							D.reagents.reaction(M, INJECT)
							D.reagents.trans_to(M, 15)
					else
						M.visible_message("<span class='danger'>The syringe bounces off [M]!</span>")

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D) spawn(10) qdel(D)

		return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "null"
	anchored = TRUE
	density = 0

/obj/effect/syringe_gun_dummy/Initialize()
	create_reagents(15)
	return ..()
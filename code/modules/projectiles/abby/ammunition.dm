//Ammo datums, magazine items, and casings.

/datum/ammo
	var/name = "generic bullet"

	var/obj/item/current_gun = null //Where's our home base?

	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/skips_marines = 0
	var/skips_xenos = 0
	var/accuracy = 0

	var/damage = 0
	var/damage_type = BRUTE

	var/armor_pen = 0
	var/incendiary = 0
	var/silenced = 0
	var/shrapnel_chance = 0
	var/icon = 'icons/obj/projectiles.dmi'
	var/icon_state = "bullet"
	var/tracer = 0 //TODO
	var/caseless = 1 //TODO
	var/ignores_armor = 0 //Use this on tasers, not on bullets. Use armor pen for that.

	var/max_range = 30 //This will de-increment a counter on the bullet.
	var/accurate_range = 7 //After this distance, accuracy suffers badly unless zoomed.
	var/damage_bleed = 1 //How much damage the bullet loses per turf traveled, very high for shotguns
	var/casing_type = "/obj/item/ammo_casing"
	var/shell_speed = 1 //This is the default projectile speed: x turfs per 1 second.
	var/bonus_projectiles = 0
	var/never_scatters = 0 //Never wanders

	proc/do_at_half_range(var/obj/item/projectile/P)
		return

	proc/do_at_max_range(var/obj/item/projectile/P)
		return

	proc/on_shield_block(var/mob/M, var/obj/item/projectile/P) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
		return

	proc/on_hit_turf(var/turf/T, var/obj/item/projectile/P) //Special effects when hitting dense turfs.
		return

	proc/on_hit_mob(var/mob/M, var/obj/item/projectile/P) //Special effects when hitting mobs.
		return

	proc/on_hit_obj(var/obj/O, var/obj/item/projectile/P) //Special effects when hitting objects.
		return

	proc/burst(var/atom/target,var/obj/item/projectile/P,var/message = "buckshot")
		if(!target) return

		for(var/mob/living/carbon/M in range(1,target))
			M.visible_message("\red [M] is hit by [message]!","\red You are hit by </b>[message]</b>!")
			M.apply_damage(rand(5,25),BRUTE)

//Boxes of ammo
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo"
	icon = 'icons/obj/ammo.dmi'
	icon_state = ""
	var/icon_empty = ""
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	item_state = ""
	matter = list("metal" = 50000)
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/default_ammo = "/datum/ammo"
	var/max_rounds = 7 //How many rounds can it hold?
	var/current_rounds = -1 //Set this to something else for it not to start with different initial counts.
	var/gun_type = "/obj/item/weapon/gun" //What type of gun does it fit in? Must be currently a gun. (see : gun reload proc)
	var/fits_in_subtypes = 1 //TODO
	var/null_ammo = 0 //Set this to 0 to have a non-ammo-datum-using magazine without generating errors.
	var/reload_delay = 1 //Set a timer for reloading mags (shotguns mostly). Higher is slower.
	var/sound_empty = 'sound/weapons/smg_empty_alarm.ogg'
	var/bonus_overlay = null //Sprite pointer in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on

	New()
		..()
		//Fill the ammo up.
		if(isnull(default_ammo) || null_ammo) //None!
			icon_state = icon_empty
			current_rounds = 0
			desc = desc && "\nThis one is empty."
			return

		 if(current_rounds == -1)
		 	current_rounds = max_rounds

	update_icon()
		if(current_rounds <= 0 && icon_empty)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)

	examine()
		..()
		if(current_rounds < 0)
			usr << "The [src] has <b>[max_rounds]</b> rounds out of <b>[max_rounds]</b>."
		else
			usr << "The [src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."

//Doesn't do anything or hold anything anymore.
/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 1
	w_class = 1.0

	New()
		..()
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(NORTH,EAST,SOUTH,WEST)
		return

/obj/item/ammo_casing/shotgun
	name = "shotgun casing"
	desc = "A shotgun casing. It is empty and useless."
	icon_state = "gshell"

/obj/item/ammo_casing/shotgun/red
	icon_state = "incendiaryshell"

/obj/item/ammo_casing/shotgun/green
	icon_state = "bshell"
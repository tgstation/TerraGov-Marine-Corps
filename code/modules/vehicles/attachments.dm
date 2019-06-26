
///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	flags_magazine = 0 //No refilling
	var/point_cost = 0

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "LTB Cannon Magazine"
	desc = "A primary armament cannon magazine"
	caliber = "86mm" //Making this unique on purpose
	icon_state = "ltbcannon_4"
	w_class = 15 //Heavy fucker
	default_ammo = /datum/ammo/rocket/ltb
	max_rounds = 4
	point_cost = 50

/obj/item/ammo_magazine/tank/ltb_cannon/update_icon()
	icon_state = "ltbcannon_[current_rounds]"


/obj/item/ammo_magazine/tank/ltaaap_minigun
	name = "LTAA-AP Minigun Magazine"
	desc = "A primary armament minigun magazine"
	caliber = "7.62x51mm" //Correlates to miniguns
	icon_state = "painless"
	w_class = 10
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 500
	point_cost = 25


/obj/item/ammo_magazine/tank/flamer
	name = "Flamer Magazine"
	desc = "A secondary armament flamethrower magazine"
	caliber = "UT-Napthal Fuel" //correlates to flamer mags
	icon_state = "flametank_large"
	w_class = 12
	default_ammo = /datum/ammo/flamethrower/tank_flamer
	max_rounds = 120
	point_cost = 50


/obj/item/ammo_magazine/tank/towlauncher
	name = "TOW Launcher Magazine"
	desc = "A secondary armament rocket magazine"
	caliber = "rocket" //correlates to any rocket mags
	icon_state = "quad_rocket"
	w_class = 10
	default_ammo = /datum/ammo/rocket/ap //Fun fact, AP rockets seem to be a straight downgrade from normal rockets. Maybe I'm missing something...
	max_rounds = 5
	point_cost = 100

/obj/item/ammo_magazine/tank/m56_cupola
	name = "M56 Cupola Magazine"
	desc = "A secondary armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box"
	w_class = 12
	default_ammo = /datum/ammo/bullet/smartgun
	max_rounds = 1000
	point_cost = 10

/obj/item/ammo_magazine/tank/tank_glauncher
	name = "Grenade Launcher Magazine"
	desc = "A secondary armament grenade magazine"
	caliber = "grenade"
	icon_state = "glauncher_2"
	w_class = 9
	default_ammo = /datum/ammo/grenade_container
	max_rounds = 10
	point_cost = 25

/obj/item/ammo_magazine/tank/tank_glauncher/update_icon()
	if(current_rounds >= max_rounds)
		icon_state = "glauncher_2"
	else if(current_rounds <= 0)
		icon_state = "glauncher_0"
	else
		icon_state = "glauncher_1"


/obj/item/ammo_magazine/tank/tank_slauncher
	name = "Smoke Launcher Magazine"
	desc = "A support armament grenade magazine"
	caliber = "grenade"
	icon_state = "slauncher_1"
	w_class = 12
	default_ammo = /datum/ammo/grenade_container/smoke
	max_rounds = 6
	point_cost = 5

/obj/item/ammo_magazine/tank/tank_slauncher/update_icon()
	icon_state = "slauncher_[current_rounds <= 0 ? "0" : "1"]"

///////////////
// AMMO MAGS // END
///////////////

/obj/vehicle/tank/attackby(obj/item/I, mob/user) //This handles reloading weapons, or changing what kind of mags they'll accept. You can have a passenger do this
	if(user.loc == src) //Stops safe healing
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while youre seated in it.</span>")
		return
	if(iswelder(I)) //Weld to repair the tank
		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='warning'>You can't see any visible dents on [src].</span>")
			return
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.isOn())
			to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
			return
		if(!do_after(user, 20 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = iswelder(I) ? CALLBACK(I, /obj/item/tool/weldingtool/proc/isOn) : null))
			user.visible_message("<span class='notice'>[user] stops repairing [src].</span>",
				"<span class='notice'>You stop repairing [src].</span>")
			return
		WT.remove_fuel(3, user) //3 Welding fuel to repair the tank. To repair a small tank, it'd take 4 goes AKA 12 welder fuel and 1 minute
		obj_integrity += 100
		if(obj_integrity > max_integrity)
			obj_integrity = max_integrity //Prevent overheal
		to_chat(user, "<span class='warning'>You weld out a few of the dents on [src].</span>")
		update_icon() //Check damage overlays
		return
	if(is_type_in_list(I, primary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.mind.cm_skills.large_vehicle)
		to_chat(user, "You start to swap out [primary_weapon]'s magazine...")
		if(do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			playsound(get_turf(src), 'sound/weapons/working_the_bolt.ogg', 100, 1)
			primary_weapon.ammo.forceMove(get_turf(user))
			primary_weapon.ammo = I
			to_chat(user, "You load [I] into [primary_weapon] with a satisfying click.")
			user.transferItemToLoc(I,src)
		return
	if(is_type_in_list(I, secondary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.mind.cm_skills.large_vehicle)
		to_chat(user, "You start to swap out [secondary_weapon]'s magazine...")
		if(do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			playsound(get_turf(src), 'sound/weapons/working_the_bolt.ogg', 100, 1)
			secondary_weapon.ammo.forceMove(get_turf(user))
			secondary_weapon.ammo = I
			to_chat(user, "You load [I] into [secondary_weapon] with a satisfying click.")
			user.transferItemToLoc(I,src)
		return
	. = ..()
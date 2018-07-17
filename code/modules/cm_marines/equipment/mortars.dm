//The Marine mortar, the M402 Mortar
//Works like a contemporary crew weapon mortar

/obj/structure/mortar
	name = "\improper M402 mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses manual targetting dials. Insert round to fire."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar_m402"
	anchored = 1
	unacidable = 1
	density = 1
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	flags_atom = RELAY_CLICK
	var/targ_x = 0 //Initial target coordinates
	var/targ_y = 0
	var/offset_x = 0 //Automatic offset from target
	var/offset_y = 0
	var/offset_per_turfs = 10 //Number of turfs to offset from target by 1
	var/dial_x = 0 //Dial adjustment from target
	var/dial_y = 0
	var/travel_time = 45 //Constant, assuming perfect parabolic trajectory. ONLY THE DELAY BEFORE INCOMING WARNING WHICH ADDS 45 TICKS
	var/busy = 0
	var/firing = 0 //Used for deconstruction and aiming sanity
	var/fixed = 0 //If set to 1, can't unanchor and move the mortar, used for map spawns and WO

/obj/structure/mortar/attack_hand(mob/user as mob)
	if(isYautja(user))
		user << "<span class='warning'>You kick [src] but nothing happens.</span>"
		return
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		user << "<span class='warning'>You don't have the training to use [src].</span>"
		return
	if(busy)
		user << "<span class='warning'>Someone else is currently using [src].</span>"
		return
	if(firing)
		user << "<span class='warning'>[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it.</span>"
		return
	add_fingerprint(user)

	var/choice = alert(user, "Would you like to set the mortar's target coordinates, or dial the mortar? Setting coordinates will make you lose your fire adjustment.", "Mortar Dialing", "Target", "Dial", "Cancel")
	if(choice == "Cancel")
		return
	if(choice == "Target")
		var/temp_targ_x = input("Set longitude of strike from 0 to [world.maxx].") as num
		if(dial_x + temp_targ_x > world.maxx || dial_x + temp_targ_x < 0)
			user << "<span class='warning'>You cannot aim at this coordinate, it is outside of the area of operations.</span>"
			return
		var/temp_targ_y = input("Set latitude of strike from 0 to [world.maxy].") as num
		if(dial_y + temp_targ_y > world.maxy || dial_y + temp_targ_y < 0)
			user << "<span class='warning'>You cannot aim at this coordinate, it is outside of the area of operations.</span>"
			return
		var/turf/T = locate(temp_targ_x + dial_x, temp_targ_y + dial_y, z)
		if(get_dist(loc, T) < 10)
			user << "<span class='warning'>You cannot aim at this coordinate, it is too close to your mortar.</span>"
			return
		if(busy)
			user << "<span class='warning'>Someone else is currently using this mortar.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts adjusting [src]'s firing angle and distance.</span>",
		"<span class='notice'>You start adjusting [src]'s firing angle and distance to match the new coordinates.</span>")
		busy = 1
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		if(do_after(user, 30, TRUE, 5, BUSY_ICON_FRIENDLY))
			user.visible_message("<span class='notice'>[user] finishes adjusting [src]'s firing angle and distance.</span>",
			"<span class='notice'>You finish adjusting [src]'s firing angle and distance to match the new coordinates.</span>")
			busy = 0
			targ_x = temp_targ_x
			targ_y = temp_targ_y
			var/offset_x_max = round(abs((targ_x + dial_x) - x)/offset_per_turfs) //Offset of mortar shot, grows by 1 every 10 tiles travelled
			var/offset_y_max = round(abs((targ_y + dial_y) - y)/offset_per_turfs)
			offset_x = rand(-offset_x_max, offset_x_max)
			offset_y = rand(-offset_y_max, offset_y_max)
		else busy = 0
	if(choice == "Dial")
		var/temp_dial_x = input("Set longitude adjustement from -10 to 10.") as num
		if(temp_dial_x + targ_x > world.maxx || temp_dial_x + targ_x < 0)
			user << "<span class='warning'>You cannot dial to this coordinate, it is outside of the area of operations.</span>"
			return
		if(temp_dial_x < -10 || temp_dial_x > 10)
			user << "<span class='warning'>You cannot dial to this coordinate, it is too far away. You need to set [src] up instead.</span>"
			return
		var/temp_dial_y = input("Set latitude adjustement from -10 to 10.") as num
		if(temp_dial_y + targ_y > world.maxy || temp_dial_y + targ_y < 0)
			user << "<span class='warning'>You cannot dial to this coordinate, it is outside of the area of operations.</span>"
			return
		var/turf/T = locate(targ_x + temp_dial_x, targ_y + temp_dial_y, z)
		if(get_dist(loc, T) < 10)
			user << "<span class='warning'>You cannot dial to this coordinate, it is too close to your mortar.</span>"
			return
		if(temp_dial_y < -10 || temp_dial_y > 10)
			user << "<span class='warning'>You cannot dial to this coordinate, it is too far away. You need to set [src] up instead.</span>"
			return
		if(busy)
			user << "<span class='warning'>Someone else is currently using this mortar.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts dialing [src]'s firing angle and distance.</span>",
		"<span class='notice'>You start dialing [src]'s firing angle and distance to match the new coordinates.</span>")
		busy = 1
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		if(do_after(user, 15, TRUE, 5, BUSY_ICON_FRIENDLY))
			user.visible_message("<span class='notice'>[user] finishes dialing [src]'s firing angle and distance.</span>",
			"<span class='notice'>You finish dialing [src]'s firing angle and distance to match the new coordinates.</span>")
			busy = 0
			dial_x = temp_dial_x
			dial_y = temp_dial_y
		else busy = 0

/obj/structure/mortar/attackby(var/obj/item/O as obj, mob/user as mob)

	if(istype(O, /obj/item/mortal_shell))

		var/obj/item/mortal_shell/mortar_shell = O
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user << "<span class='warning'>You don't have the training to fire [src].</span>"
			return
		if(busy)
			user << "<span class='warning'>Someone else is currently using [src].</span>"
			return
		if(z != 1)
			user << "<span class='warning'>You cannot fire [src] here.</span>"
			return
		if(targ_x == 0 && targ_y == 0) //Mortar wasn't set
			user << "<span class='warning'>[src] needs to be aimed first.</span>"
			return
		var/turf/T = locate(targ_x + dial_x + offset_x, targ_y + dial_y + offset_y, z)
		if(!isturf(T))
			user << "<span class='warning'>You cannot fire [src] to this target.</span>"
			return
		var/area/A = get_area(T)
		if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
			user << "<span class='warning'>You cannot hit the target. It is probably underground.</span>"
			return

		user.visible_message("<span class='notice'>[user] starts loading \a [mortar_shell.name] into [src].</span>",
		"<span class='notice'>You start loading \a [mortar_shell.name] into [src].</span>")
		playsound(loc, 'sound/weapons/gun_mortar_reload.ogg', 50, 1)
		busy = 1
		if(do_after(user, 15, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='notice'>[user] loads \a [mortar_shell.name] into [src].</span>",
			"<span class='notice'>You load \a [mortar_shell.name] into [src].</span>")
			visible_message("\icon[src] <span class='danger'>The [name] fires!</span>")
			user.drop_inv_item_to_loc(mortar_shell, src)
			playsound(loc, 'sound/weapons/gun_mortar_fire.ogg', 50, 1)
			busy = 0
			firing = 1
			flick(icon_state + "_fire", src)
			mortar_shell.forceMove(src)

			var/turf/G = get_turf(src)
			G.ceiling_debris_check(2)

			for(var/mob/M in range(7))
				shake_camera(M, 3, 1)
			spawn(travel_time) //What goes up
				playsound(T, 'sound/weapons/gun_mortar_travel.ogg', 50, 1)
				spawn(45) //Must go down //This should always be 45 ticks!
					T.ceiling_debris_check(2)
					mortar_shell.detonate(T)
					cdel(mortar_shell)
					firing = 0
		else
			busy = 0

	if(istype(O, /obj/item/tool/wrench))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user << "<span class='warning'>You don't have the training to undeploy [src].</span>"
			return
		if(fixed)
			user << "<span class='warning'>[src]'s supports are bolted and welded into the floor. It looks like it's going to be staying there.</span>"
			return
		if(busy)
			user << "<span class='warning'>Someone else is currently using [src].</span>"
			return
		if(firing)
			user << "<span class='warning'>[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it.</span>"
			return
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts undeploying [src].",
		"<span class='notice'>You start undeploying [src].")
		if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] undeploys [src].",
			"<span class='notice'>You undeploy [src].")
			playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
			new /obj/item/mortar_kit(loc)
			cdel(src)

//Don't allow blowing those up, so Marine nades don't fuck them
/obj/structure/mortar/ex_act(severity)
	return

/obj/structure/mortar/fixed
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses manual targetting dials. Insert round to fire. This one is bolted and welded into the ground."
	fixed = 1

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper M402 mortar portable kit"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first"
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar_m402_carry"
	unacidable = 1
	w_class = 5 //No dumping this in a backpack. Carry it, fatso

//Don't allow blowing those up, so Marine nades don't fuck them
/obj/item/mortar_kit/ex_act(severity)
	return

/obj/item/mortar_kit/attack_self(mob/user)

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		user << "<span class='warning'>You don't have the training to deploy [src].</span>"
		return
	if(user.z != 1)
		user << "<span class='warning'>You cannot deploy [src] here.</span>"
		return
	var/area/A = get_area(src)
	if(A.ceiling >= CEILING_METAL)
		user << "<span class='warning'>You probably shouldn't deploy [src] indoors.</span>"
		return
	user.visible_message("<span class='notice'>[user] starts deploying [src].",
	"<span class='notice'>You start deploying [src].")
	playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
	if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
		user.visible_message("<span class='notice'>[user] deploys [src].",
		"<span class='notice'>You deploy [src].")
		playsound(loc, 'sound/weapons/gun_mortar_unpack.ogg', 25, 1)
		var/obj/structure/mortar/M = new /obj/structure/mortar(get_turf(user))
		M.dir = user.dir
		cdel(src)

/obj/item/mortal_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar_ammo_cas"
	w_class = 5
	flags_atom = FPRINT|CONDUCT

/obj/item/mortal_shell/proc/detonate(var/turf/T)

	forceMove(T)

/obj/item/mortal_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"

/obj/item/mortal_shell/he/detonate(var/turf/T)

	explosion(T, 0, 3, 5, 7)

/obj/item/mortal_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a napalm charge."
	icon_state = "mortar_ammo_inc"

/obj/item/mortal_shell/incendiary/detonate(var/turf/T)

	explosion(T, 0, 2, 4, 7)
	flame_radius(3, T)
	playsound(T, 'sound/weapons/gun_flamethrower2.ogg', 35, 1, 4)

/obj/item/mortal_shell/smoke
	name = "\improper 80mm smoke mortar shell"
	desc = "An 80mm mortar shell, loaded with smoke dispersal agents."
	icon_state = "mortar_ammo_smk"
	var/datum/effect_system/smoke_spread/bad/smoke

	New()
		..()
		smoke = new /datum/effect_system/smoke_spread/bad
		smoke.attach(src)

/obj/item/mortal_shell/smoke/detonate(var/turf/T)

	explosion(T, 0, 1, 2, 7)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	forceMove(T) //AAAAAAAA
	smoke.set_up(6, 0, T, null, 6)
	smoke.start()
	smoke = null
	cdel(src)

/obj/item/mortal_shell/flash
	name = "\improper 80mm flash mortar shell"
	desc = "An 80mm mortar shell, loaded with a flash powder charge."
	icon_state = "mortar_ammo_fsh"

/obj/item/mortal_shell/flash/detonate(var/turf/T)

	explosion(T, 0, 1, 2, 7)
	var/obj/item/explosive/grenade/flashbang/flash = new(T)
	flash.icon_state = ""
	flash.prime()

/obj/item/mortal_shell/flare
	name = "\improper 80mm flare mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare."
	icon_state = "mortar_ammo_flr"

/obj/item/mortal_shell/flare/detonate(var/turf/T)

	//TODO: Add flare sound
	new /obj/item/device/flashlight/flare/on/illumination(T)
	playsound(T, 'sound/weapons/gun_flare.ogg', 50, 1, 4)

//Special flare subtype for the illumination flare shell
//Acts like a flare, just even stronger, and set length
/obj/item/device/flashlight/flare/on/illumination

	name = "illumination flare"
	desc = "It's really bright, and unreachable."
	icon_state = "" //No sprite
	invisibility = 101 //Can't be seen or found, it's "up in the sky"
	mouse_opacity = 0
	brightness_on = 7 //Way brighter than most lights

	New()

		..()
		fuel = rand(400, 500) // Half the duration of a flare, but justified since it's invincible

/obj/item/device/flashlight/flare/on/illumination/turn_off()

	..()
	cdel(src)

/obj/item/device/flashlight/flare/on/illumination/ex_act(severity)

	return //Nope

/obj/structure/closet/crate/mortar_ammo

	name = "\improper M402 mortar ammo crate"
	desc = "A crate containing live mortar shells with various payloads. DO NOT DROP. KEEP AWAY FROM FIRE SOURCES."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "closed_mortar_crate"
	icon_opened = "open_mortar_crate"
	icon_closed = "closed_mortar_crate"

/obj/structure/closet/crate/mortar_ammo/full/New()
	..()
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/flash(src)
	new /obj/item/mortal_shell/flash(src)

/obj/structure/closet/crate/mortar_ammo/mortar_kit
	name = "\improper M402 mortar kit"
	desc = "A crate containing a basic set of a mortar and some shells, to get an engineer started."

/obj/structure/closet/crate/mortar_ammo/mortar_kit/New()
	..()
	new /obj/item/mortar_kit(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/device/encryptionkey/engi(src)
	new /obj/item/device/encryptionkey/engi(src)
	new /obj/item/device/binoculars/tactical/range(src)
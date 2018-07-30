//////////////////////////////////////////////////////////////
//Mounted MG, Replacment for the current jury rig code.

//Adds a coin for engi vendors
/obj/item/coin/marine/engineer
	name = "marine engineer support token"
	desc = "Insert this into a engineer vendor in order to access a support weapon."
	icon_state = "coin_adamantine"

// First thing we need is the ammo drum for this thing.
/obj/item/ammo_magazine/m56d
	name = "M56D drum magazine (10x28mm Caseless)"
	desc = "A box of 700, 10x28mm caseless tungsten rounds for the M56D mounted smartgun system. Just click the M56D with this to reload it."
	w_class = 4
	icon_state = "ammo_drum"
	flags_magazine = NOFLAGS //can't be refilled or emptied by hand
	caliber = "10x28mm"
	max_rounds = 700
	default_ammo = /datum/ammo/bullet/smartgun
	gun_type = null


// Now we need a box for this.
/obj/item/storage/box/m56d_hmg
	name = "\improper M56D crate"
	desc = "A large metal case with Japanese writing on the top. However it also comes with English text to the side. This is a M56D smartgun, it clearly has various labeled warnings. The most major one is that this does not have IFF features due to specialized ammo."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_case" // I guess a placeholder? Not actually going to show up ingame for now.
	w_class = 5
	storage_slots = 6
	can_hold = list()

	New()
		..()
		spawn(1)
			new /obj/item/device/m56d_gun(src) //gun itself
			new /obj/item/ammo_magazine/m56d(src) //ammo for the gun
			new /obj/item/device/m56d_post(src) //post for the gun
			new /obj/item/tool/wrench(src) //wrench to hold it down into the ground
			new /obj/item/tool/screwdriver(src) //screw the gun onto the post.
			new /obj/item/ammo_magazine/m56d(src)

// The actual gun itself.
/obj/item/device/m56d_gun
	name = "\improper M56D Mounted Smartgun"
	desc = "The top half of a M56D Machinegun post. However it ain't much use without the tripod."
	unacidable = 1
	w_class = 5
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_gun_e"
	var/rounds = 0 // How many rounds are in the weapon. This is useful if we break down our guns.

	New()
		update_icon()

/obj/item/device/m56d_gun/examine(mob/user as mob) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		usr << "It has [rounds] out of 700 rounds."
	else
		usr << "It seems to be lacking a ammo drum."

/obj/item/device/m56d_gun/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "M56D_gun_e"
	else
		icon_state = "M56D_gun"
	return

/obj/item/device/m56d_gun/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return

	if(isnull(O))
		return

	if(istype(O,/obj/item/ammo_magazine/m56d)) //lets equip it with ammo
		if(!rounds)
			rounds = 700
			cdel(O)
			update_icon()
			return
		else
			usr << "The M56D already has a ammo drum mounted on it!"
		return

/obj/item/device/m56d_post //Adding this because I was fucken stupid and put a obj/machinery in a box. Realized I couldn't take it out
	name = "\improper M56D folded mount"
	desc = "The folded, foldable tripod mount for the M56D.  (Place on ground and drag to you to unfold)."
	unacidable = 1
	w_class = 5
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "folded_mount"

/obj/item/device/m56d_post/attack_self(mob/user) //click the tripod to unfold it.
	if(!ishuman(usr)) return
	user << "<span class='notice'>You deploy [src].</span>"
	new /obj/machinery/m56d_post(user.loc)
	cdel(src)



//The mount for the weapon.
/obj/machinery/m56d_post
	name = "\improper M56D mount"
	desc = "A foldable tripod mount for the M56D, provides stability to the M56D."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_mount"
	anchored = 0
	density = 1
	layer = ABOVE_MOB_LAYER
	var/gun_mounted = 0 //Has the gun been mounted?
	var/gun_rounds = 0 //Did the gun come with any ammo?
	var/health = 100


/obj/machinery/m56d_post/proc/update_health(damage)
	health -= damage
	if(health <= 0)
		if(prob(30))
			new /obj/item/device/m56d_post (src)
		cdel(src)



/obj/machinery/m56d_post/examine(mob/user)
	..()
	if(!anchored)
		user << "It must be <B>screwed</b> to the floor."
	else if(!gun_mounted)
		user << "The <b>M56D Mounted Smartgun</b> is not yet mounted."
	else
		user << "The M56D isn't screwed into the mount. Use a <b>screwdriver</b> to finish the job."

/obj/machinery/m56d_post/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) return //Larvae can't do shit
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>",
	"<span class='danger'>You slash [src]!</span>")
	M.animation_attack_on(src)
	M.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	update_health(rand(M.melee_damage_lower,M.melee_damage_upper))


/obj/machinery/m56d_post/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		if(anchored)
			user << "<span class='warning'>[src] can't be folded while screwed to the floor. Unscrew it first.</span>"
			return
		user << "<span class='notice'>You fold [src].</span>"
		var/obj/item/device/m56d_post/P = new(loc)
		user.put_in_hands(P)
		cdel(src)



/obj/machinery/m56d_post/attackby(obj/item/O, mob/user)
	if(!ishuman(user)) //first make sure theres no funkiness
		return

	if(istype(O,/obj/item/tool/wrench)) //rotate the mount
		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] rotates [src].</span>","<span class='notice'>You rotate [src].</span>")
		switch(dir)
			if(NORTH)
				dir = EAST
			if(EAST)
				dir = SOUTH
			if(SOUTH)
				dir = WEST
			if(WEST)
				dir = NORTH
		return

	if(istype(O,/obj/item/device/m56d_gun)) //lets mount the MG onto the mount.
		var/obj/item/device/m56d_gun/MG = O
		if(!anchored)
			user << "<span class='warning'>[src] must be anchored! Use a screwdriver!</span>"
			return
		user << "You begin mounting [MG].."
		if(do_after(user,30, TRUE, 5, BUSY_ICON_BUILD) && !gun_mounted && anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("\blue [user] installs [MG] into place.","\blue You install [MG] into place.")
			gun_mounted = 1
			gun_rounds = MG.rounds
			if(!gun_rounds)
				icon_state = "M56D_e"
			else
				icon_state = "M56D" // otherwise we're a empty gun on a mount.
			user.temp_drop_inv_item(MG)
			cdel(MG)
		return

	if(istype(O,/obj/item/tool/crowbar))
		if(!gun_mounted)
			user << "<span class='warning'>There is no gun mounted.</span>"
			return
		user << "You begin dismounting [src]'s gun.."
		if(do_after(user,30, TRUE, 5, BUSY_ICON_BUILD) && gun_mounted)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			user.visible_message("\blue [user] removes [src]'s gun.","\blue You remove [src]'s gun.")
			new /obj/item/device/m56d_gun(loc)
			gun_mounted = 0
			gun_rounds = 0
			icon_state = "M56D_mount"
		return

	if(istype(O,/obj/item/tool/screwdriver))
		if(gun_mounted)
			user << "You're securing the M56D into place"
			if(do_after(user,30, TRUE, 5, BUSY_ICON_BUILD))
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("\blue [user] screws the M56D into the mount.","\blue You finalize the M56D mounted smartgun system.")
				var/obj/machinery/m56d_hmg/G = new(src.loc) //Here comes our new turret.
				G.visible_message("\icon[G] <B>[G] is now complete!</B>") //finished it for everyone to
				G.dir = src.dir //make sure we face the right direction
				G.rounds = src.gun_rounds //Inherent the amount of ammo we had.
				cdel(src)
		else

			if(!anchored)
				var/turf/T = get_turf(src)
				var/fail = 0
				if(T.density)
					fail = 1
				else
					for(var/obj/X in T)
						if(X.density  && X != src && !(X.flags_atom & ON_BORDER))
							fail = 1
							break
				if(fail)
					user << "<span class='warning'>Can't install [src] here, something is in the way.</span>"
					return
			if(anchored)
				user << "You begin unscrewing [src] from the ground.."
			else
				user << "You begin screwing [src] into place.."
			var/old_anchored = anchored
			if(do_after(user,20, TRUE, 5, BUSY_ICON_BUILD) && anchored == old_anchored)
				anchored = !anchored
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				if(anchored)
					user.visible_message("\blue [user] anchors [src] into place.","\blue You anchor [src] into place.")
				else
					user.visible_message("\blue [user] unanchors [src].","\blue You unanchor [src].")
		return

	return ..()

// The actual Machinegun itself, going to borrow some stuff from current sentry code to make sure it functions. Also because they're similiar.
/obj/machinery/m56d_hmg
	name = "\improper M56D mounted smartgun"
	desc = "A deployable, mounted smartgun. While it is capable of taking the same rounds as the M56, it fires specialized tungsten rounds for increased armor penetration.<span class='notice'> !!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D"
	anchored = 1
	unacidable = 1 //stop the xeno me(l)ta.
	density = 1
	layer = ABOVE_MOB_LAYER //no hiding the hmg beind corpse
	use_power = 0
	var/rounds = 0 //Have it be empty upon spawn.
	var/rounds_max = 700
	var/fire_delay = 4 //Gotta have rounds down quick.
	var/last_fired = 0
	var/burst_fire = 0 //0 is non-burst mode, 1 is burst.
	var/safety = 0 //Weapon safety, 0 is weapons hot, 1 is safe.
	var/health = 200
	var/health_max = 200 //Why not just give it sentry-tier health for now.
	var/atom/target = null // required for shooting at things.
	var/datum/ammo/bullet/machinegun/ammo = /datum/ammo/bullet/machinegun
	var/obj/item/projectile/in_chamber = null
	var/locked = 0 //1 means its locked inplace (this will be for sandbag MGs)
	var/is_bursting = 0.
	var/icon_full = "M56D" // Put this system in for other MGs or just other mounted weapons in general, future proofing.
	var/icon_empty = "M56D_e" //Empty
	var/zoom = 0 // 0 is it doesn't zoom, 1 is that it zooms.

	New()
		ammo = ammo_list[ammo] //dunno how this works but just sliding this in from sentry-code.
		update_icon()

	Dispose() //Make sure we pick up our trash.
		if(operator)
			operator.unset_interaction()
		SetLuminosity(0)
		processing_objects.Remove(src)
		. = ..()

/obj/machinery/m56d_hmg/examine(mob/user) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		user << "It has [rounds] round\s out of [rounds_max]."
	else
		user << "It seems to be lacking ammo"

/obj/machinery/m56d_hmg/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "[icon_empty]"
	else
		icon_state = "[icon_full]"
	return

/obj/machinery/m56d_hmg/attackby(var/obj/item/O as obj, mob/user as mob) //This will be how we take it apart.
	if(!ishuman(user))
		return ..()

	if(isnull(O))
		return

	if(istype(O,/obj/item/tool/wrench)) // Let us rotate this stuff.
		if(locked)
			user << "This one is anchored in place and cannot be rotated."
			return
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("[user] rotates the [src].","You rotate the [src].")
			switch(dir)
				if(NORTH)
					dir = EAST
				if(EAST)
					dir = SOUTH
				if(SOUTH)
					dir = WEST
				if(WEST)
					dir = NORTH
		return

	if(istype(O, /obj/item/tool/screwdriver)) // Lets take it apart.
		if(locked)
			user << "This one cannot be disassembled."
		else
			user << "You begin disassembling the M56D mounted smartgun"
			if(do_after(user,15, TRUE, 5, BUSY_ICON_BUILD))
				user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				var/obj/item/device/m56d_gun/HMG = new(src.loc) //Here we generate our disassembled mg.
				new /obj/item/device/m56d_post(src.loc)
				HMG.rounds = src.rounds //Inherent the amount of ammo we had.
				cdel(src) //Now we clean up the constructed gun.
				return

	if(istype(O, /obj/item/ammo_magazine/m56d)) // RELOADING DOCTOR FREEMAN.
		var/obj/item/ammo_magazine/m56d/M = O
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.heavy_weapons < SKILL_HEAVY_WEAPONS_TRAINED)
			if(rounds)
				user << "<span class='warning'>You only know how to swap the ammo drum when it's empty.</span>"
				return
			if(user.action_busy) return
			if(!do_after(user, 25, TRUE, 5, BUSY_ICON_FRIENDLY))
				return
		user.visible_message("<span class='notice'> [user] loads [src]! </span>","<span class='notice'> You load [src]!</span>")
		playsound(loc, 'sound/weapons/gun_minigun_cocked.ogg', 25, 1)
		if(rounds)
			var/obj/item/ammo_magazine/m56d/D = new(user.loc)
			D.current_rounds = rounds
		rounds = min(rounds + M.current_rounds, rounds_max)
		update_icon()
		user.temp_drop_inv_item(O)
		cdel(O)
		return
	return ..()

/obj/machinery/m56d_hmg/proc/update_health(damage) //Negative damage restores health.
	health -= damage
	if(health <= 0)
		var/destroyed = rand(0,1) //Ammo cooks off or something. Who knows.
		playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		if(!destroyed) new /obj/machinery/m56d_post(loc)
		else
			var/obj/item/device/m56d_gun/HMG = new(loc)
			HMG.rounds = src.rounds //Inherent the amount of ammo we had.
		cdel(src)
		return

	if(health > health_max)
		health = health_max
	update_icon()

/obj/machinery/m56d_hmg/bullet_act(var/obj/item/projectile/Proj) //Nope.
	if(prob(30)) // What the fuck is this from sentry gun code. Sorta keeping it because it does make sense that this is just a gun, unlike the sentry.
		return 0

	visible_message("\The [src] is hit by the [Proj.name]!")
	update_health(round(Proj.damage / 10)) //Universal low damage to what amounts to a post with a gun.
	return 1

/obj/machinery/m56d_hmg/attack_alien(mob/living/carbon/Xenomorph/M) // Those Ayy lmaos.
	if(isXenoLarva(M)) return //Larvae can't do shit
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>",
	"<span class='danger'>You slash [src]!</span>")
	M.animation_attack_on(src)
	M.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	update_health(rand(M.melee_damage_lower,M.melee_damage_upper))

/obj/machinery/m56d_hmg/proc/load_into_chamber()
	if(in_chamber) return 1 //Already set!
	if(rounds == 0)
		update_icon() //make sure the user can see the lack of ammo.
		return 0 //Out of ammo.

	in_chamber = rnew(/obj/item/projectile, loc) //New bullet!
	in_chamber.generate_bullet(ammo)
	return 1

/obj/machinery/m56d_hmg/proc/process_shot()
	set waitfor = 0

	if(isnull(target)) return //Acqure our victim.

	if(!ammo)
		update_icon() //safeguard.
		return

	if(burst_fire && target && !last_fired)
		if(rounds > 3)
			for(var/i = 1 to 3)
				is_bursting = 1
				fire_shot()
				sleep(2)
			spawn(0)
				last_fired = 1
			spawn(fire_delay)
				last_fired = 0
		else burst_fire = 0
		is_bursting = 0

	if(!burst_fire && target && !last_fired)
		fire_shot()

	target = null

/obj/machinery/m56d_hmg/proc/fire_shot() //Bang Bang
	if(!ammo) return //No ammo.
	if(last_fired) return //still shooting.

	if(!is_bursting)
		last_fired = 1
		spawn(fire_delay)
			last_fired = 0

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)

	if (!istype(T) || !istype(U))
		return

	var/scatter_chance = 5
	if(burst_fire) scatter_chance = 10 //Make this sucker more accurate than the actual Sentry, gives it a better role.

	if(prob(scatter_chance) && get_dist(T,U) > 2) //scatter at point blank could make us fire sideways.
		U = locate(U.x + rand(-1,1),U.y + rand(-1,1),U.z)


	if(load_into_chamber() == 1)
		if(istype(in_chamber,/obj/item/projectile))
			in_chamber.original = target
			in_chamber.dir = src.dir
			in_chamber.def_zone = pick("chest","chest","chest","head")
			playsound(src.loc, 'sound/weapons/gun_rifle.ogg', 75, 1)
			in_chamber.fire_at(U,src,null,ammo.max_range,ammo.shell_speed)
			if(target)
				var/angle = round(Get_Angle(src,target))
				muzzle_flash(angle)
			in_chamber = null
			rounds--
			if(!rounds)
				visible_message("<span class='notice'> \icon[src] \The M56D beeps steadily and its ammo light blinks red.</span>")
				playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 25, 1)
				update_icon() //final safeguard.
	return

// New proc for MGs and stuff replaced handle_manual_fire(). Same arguements though, so alls good.
/obj/machinery/m56d_hmg/handle_click(mob/living/carbon/human/user, atom/A, var/list/mods)
	if(!operator) return 0
	if(operator != user) return 0
	if(istype(A,/obj/screen)) return 0
	if(is_bursting) return
	if(user.lying || get_dist(user,src) > 1 || user.is_mob_incapacitated())
		user.unset_interaction()
		return 0
	if(user.get_active_hand())
		usr << "<span class='warning'>You need a free hand to shoot the [src].</span>"
		return 0

	target = A
	if(!istype(target))
		return 0

	if(target.z != src.z || target.z == 0 || src.z == 0 || isnull(operator.loc) || isnull(src.loc))
		return 0

	if(get_dist(target,src.loc) > 15)
		return 0

	if(mods["middle"] || mods["shift"] || mods["alt"] || mods["ctrl"])	return 0

	var/angle = get_dir(src,target)
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != src.loc && target.loc != operator.loc)

		if(!rounds)
			user << "<span class='warning'><b>*click*</b></span>"
			playsound(src, 'sound/weapons/gun_empty.ogg', 25, 1, 5)
		else
			process_shot()
		return 1

	return 0

/obj/machinery/m56d_hmg/proc/muzzle_flash(var/angle) // Might as well keep this too.
	if(isnull(angle)) return

	if(prob(65))
		var/img_layer = layer + 0.1

		var/image/reusable/I = rnew(/image/reusable, list('icons/obj/items/projectiles.dmi', src, "muzzle_flash",img_layer))
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		I.transform = rotate

		I.flick_overlay(src, 3)

/obj/machinery/m56d_hmg/MouseDrop(over_object, src_location, over_location) //Drag the MG to us to man it.
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/user = usr //this is us
	src.add_fingerprint(usr)
	if((over_object == user && (in_range(src, user) || locate(src) in user))) //Make sure its on ourselves
		if(user.interactee == src)
			user.unset_interaction()
			visible_message("\icon[src] <span class='notice'>[user] decided to let someone else have a go </span>")
			usr << "<span class='notice'>You decided to let someone else have a go on the MG </span>"
			return
		if(operator) //If there is already a operator then they're manning it.
			if(operator.interactee == null)
				operator = null //this shouldn't happen, but just in case
			else
				user << "Someone's already controlling it."
				return
		else
			if(user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
				user << "You're already manning something!"
				return
			if(user.get_active_hand() != null)
				user << "<span class='warning'>You need a free hand to man the [src].</span>"
			else
				visible_message("\icon[src] <span class='notice'>[user] mans the M56D!</span>")
				user << "<span class='notice'>You man the gun!</span>"
				user.set_interaction(src)


/obj/machinery/m56d_hmg/on_set_interaction(mob/user)
	flags_atom |= RELAY_CLICK
	if(zoom)
		user.client.change_view(12)
	operator = user

/obj/machinery/m56d_hmg/on_unset_interaction(mob/user)
	flags_atom &= ~RELAY_CLICK
	if(zoom && user.client)
		user.client.change_view(world.view)
	if(operator == user)
		operator = null

/obj/machinery/m56d_hmg/check_eye(mob/user)
	if(user.lying || get_dist(user,src) > 1 || user.is_mob_incapacitated() || !user.client)
		user.unset_interaction()

/obj/machinery/m56d_hmg/clicked(var/mob/user, var/list/mods) //Making it possible to toggle burst fire. Perhaps have altclick be the safety on the gun?
	if (isobserver(user)) return

	if (mods["ctrl"])
		if(operator != user) return //only the operatore can toggle fire mode
		burst_fire = !burst_fire
		user << "<span class='notice'>You set [src] to [burst_fire ? "burst fire" : "single fire"] mode.</span>"
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
		return 1
	return ..()

/obj/machinery/m56d_hmg/mg_turret //Our mapbound version with stupid amounts of ammo.
	name = "M56D Smartgun Nest"
	desc = "A M56D smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.<span class='notice'>!!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	burst_fire = 1
	fire_delay = 2
	rounds = 1500
	rounds_max = 1500
	locked = 1
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_full = "towergun"
	icon_empty = "towergun"
	zoom = 1

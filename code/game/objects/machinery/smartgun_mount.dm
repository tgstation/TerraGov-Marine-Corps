//////////////////////////////////////////////////////////////
//Mounted MG, Replacment for the current jury rig code.

//Adds a coin for engi vendors
/obj/item/coin/marine/engineer
	name = "marine engineer support token"
	desc = "Insert this into a engineer vendor in order to access a support artillery weapon."
	flags_token = TOKEN_ENGI

// First thing we need is the ammo drum for this thing.
/obj/item/ammo_magazine/m56d
	name = "M56D drum magazine (10x28mm Caseless)"
	desc = "A box of 700, 10x28mm caseless tungsten rounds for the M56D mounted smartgun system. Just click the M56D with this to reload it."
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "ammo_drum"
	flags_magazine = NONE //can't be refilled or emptied by hand
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
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	bypass_w_limit = list(
		/obj/item/m56d_gun,
		/obj/item/ammo_magazine/m56d,
		/obj/item/m56d_post)

/obj/item/storage/box/m56d_hmg/Initialize()
	. = ..()
	new /obj/item/m56d_gun(src) //gun itself
	new /obj/item/ammo_magazine/m56d(src) //ammo for the gun
	new /obj/item/m56d_post(src) //post for the gun
	new /obj/item/tool/wrench(src) //wrench to hold it down into the ground
	new /obj/item/tool/screwdriver(src) //screw the gun onto the post.
	new /obj/item/ammo_magazine/m56d(src)

// The actual gun itself.
/obj/item/m56d_gun
	name = "\improper M56D Mounted Smartgun"
	desc = "The top half of a M56D Machinegun post. However it ain't much use without the tripod."
	resistance_flags = UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_gun_e"
	var/rounds = 0 // How many rounds are in the weapon. This is useful if we break down our guns.


/obj/item/m56d_gun/Initialize()
	. = ..()
	update_icon()


/obj/item/m56d_gun/examine(mob/user as mob) //Let us see how much ammo we got in this thing.
	. = ..()
	if(!ishuman(user))
		return
	if(rounds)
		to_chat(usr, "It has [rounds] out of 700 rounds.")
	else
		to_chat(usr, "It seems to be lacking a ammo drum.")

/obj/item/m56d_gun/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "M56D_gun_e"
	else
		icon_state = "M56D_gun"
	return

/obj/item/m56d_gun/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	else if(istype(I, /obj/item/ammo_magazine/m56d)) //lets equip it with ammo
		if(rounds)
			to_chat(user, "The M56D already has a ammo drum mounted on it!")
			return

		rounds = 700
		qdel(I)
		update_icon()

/obj/item/m56d_post //Adding this because I was fucken stupid and put a obj/machinery in a box. Realized I couldn't take it out
	name = "\improper M56D folded mount"
	desc = "The folded, foldable tripod mount for the M56D.  (Place on ground and drag to you to unfold)."
	resistance_flags = UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "folded_mount"

/obj/item/m56d_post/attack_self(mob/user) //click the tripod to unfold it.
	if(!ishuman(usr)) return
	to_chat(user, "<span class='notice'>You deploy [src].</span>")
	var/obj/machinery/m56d_post/P = new(user.loc)
	P.setDir(user.dir)
	P.update_icon()
	qdel(src)



//The mount for the weapon.
/obj/machinery/m56d_post
	name = "\improper M56D mount"
	desc = "A foldable tripod mount for the M56D, provides stability to the M56D."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_mount"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE
	var/gun_mounted = FALSE //Has the gun been mounted?
	var/gun_rounds = 0 //Did the gun come with any ammo?


/obj/machinery/m56d_post/deconstruct(disassembled = TRUE)
	if(disassembled || prob(30))
		new /obj/item/m56d_post(loc)
	return ..()



/obj/machinery/m56d_post/examine(mob/user)
	..()
	if(!gun_mounted)
		to_chat(user, "The <b>M56D Smartgun</b> is not yet mounted.")

/obj/machinery/m56d_post/attack_alien(mob/living/carbon/xenomorph/M)
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_M56_POST)
	return ..()

/obj/machinery/m56d_post/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		to_chat(user, "<span class='notice'>You fold [src].</span>")
		var/obj/item/m56d_post/P = new(loc)
		if(gun_mounted)
			var/obj/item/m56d_gun/HMG = new(loc)
			HMG.rounds = gun_rounds
		user.put_in_hands(P)
		qdel(src)

/obj/machinery/m56d_post/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user)) //first make sure theres no funkiness
		return

	if(iswrench(I)) //rotate the mount
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] rotates [src].</span>","<span class='notice'>You rotate [src].</span>")
		setDir(turn(dir, -90))

	else if(istype(I, /obj/item/m56d_gun)) //lets mount the MG onto the mount.
		var/obj/item/m56d_gun/MG = I
		to_chat(user, "You begin mounting [MG]..")

		if(!do_after(user,30, TRUE, src, BUSY_ICON_BUILD) || gun_mounted || !anchored)
			return

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'> [user] installs [MG] into place.</span>","<span class='notice'> You install [MG] into place.</span>")
		gun_mounted = TRUE
		gun_rounds = MG.rounds
		if(!gun_rounds)
			icon_state = "M56D_e"
		else
			icon_state = "M56D" // otherwise we're a empty gun on a mount.
		user.temporarilyRemoveItemFromInventory(MG)
		qdel(MG)

	else if(iscrowbar(I))
		if(!gun_mounted)
			to_chat(user, "<span class='warning'>There is no gun mounted.</span>")
			return

		to_chat(user, "You begin dismounting [src]'s gun..")

		if(!do_after(user,30, TRUE, src, BUSY_ICON_BUILD) || !gun_mounted)
			return

		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.visible_message("<span class='notice'> [user] removes [src]'s gun.</span>","<span class='notice'> You remove [src]'s gun.</span>")
		new /obj/item/m56d_gun(loc)
		gun_mounted = FALSE
		gun_rounds = 0
		icon_state = "M56D_mount"

	else if(isscrewdriver(I))
		if(!gun_mounted)
			return

		to_chat(user, "You're securing the M56D into place")

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
		user.visible_message("<span class='notice'> [user] screws the M56D into the mount.</span>","<span class='notice'> You finalize the M56D mounted smartgun system.</span>")
		var/obj/machinery/m56d_hmg/G = new(loc) //Here comes our new turret.
		G.visible_message("[icon2html(G, viewers(G))] <B>[G] is now complete!</B>") //finished it for everyone to
		G.setDir(dir) //make sure we face the right direction
		G.rounds = gun_rounds //Inherent the amount of ammo we had.
		G.update_icon()
		qdel(src)

// The actual Machinegun itself, going to borrow some stuff from current sentry code to make sure it functions. Also because they're similiar.
/obj/machinery/m56d_hmg
	name = "\improper M56D mounted smartgun"
	desc = "A deployable, mounted smartgun. While it is capable of taking the same rounds as the M56, it fires specialized tungsten rounds for increased armor penetration.\n<span class='notice'>Use (ctrl-click) to shoot in bursts.</span>\n<span class='notice'>!!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D"
	anchored = TRUE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER //no hiding the hmg beind corpse
	use_power = 0
	max_integrity = 200
	var/rounds = 0 //Have it be empty upon spawn.
	var/rounds_max = 700
	var/fire_delay = 4 //Gotta have rounds down quick.
	var/last_fired = 0
	var/burst_fire = FALSE
	var/burst_fire_toggled = FALSE
	var/safety = FALSE
	var/atom/target = null // required for shooting at things.
	var/datum/ammo/bullet/machinegun/ammo = /datum/ammo/bullet/machinegun
	var/obj/item/projectile/in_chamber = null
	var/locked = 0 //1 means its locked inplace (this will be for sandbag MGs)
	var/is_bursting = 0.
	var/icon_full = "M56D" // Put this system in for other MGs or just other mounted weapons in general, future proofing.
	var/icon_empty = "M56D_e" //Empty
	var/view_tile_offset = 3	//this is amount of tiles we shift our vision towards MG direction
	var/view_tiles = 7		//this is amount of tiles we want person to see in each direction (7 by default)

/obj/machinery/m56d_hmg/New()
	. = ..()
	ammo = GLOB.ammo_list[ammo] //dunno how this works but just sliding this in from sentry-code.
	update_icon()

/obj/machinery/m56d_hmg/Destroy() //Make sure we pick up our trash.
	operator?.unset_interaction()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/m56d_hmg/deconstruct(disassembled = TRUE)
	var/obj/item/m56d_gun/HMG = new(loc)
	HMG.rounds = rounds //Inherent the amount of ammo we had.
	return ..()

/obj/machinery/m56d_hmg/examine(mob/user) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		to_chat(user, "It has [rounds] round\s out of [rounds_max].")
	else
		to_chat(user, "It seems to be lacking ammo")

/obj/machinery/m56d_hmg/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "[icon_empty]"
	else
		icon_state = "[icon_full]"
	return

/obj/machinery/m56d_hmg/attackby(obj/item/I, mob/user, params) //This will be how we take it apart.
	. = ..()

	if(!ishuman(user))
		return

	else if(iswrench(I)) // Let us rotate this stuff.
		if(locked)
			to_chat(user, "This one is anchored in place and cannot be rotated.")
			return

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message("[user] rotates the [src].","You rotate the [src].")
		setDir(turn(dir, -90))

	else if(isscrewdriver(I)) // Lets take it apart.
		if(locked)
			to_chat(user, "This one cannot be disassembled.")
			return

		to_chat(user, "You begin disassembling the M56D mounted smartgun")
		if(!do_after(user, 15, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		var/obj/item/m56d_gun/HMG = new(loc) //Here we generate our disassembled mg.
		new /obj/item/m56d_post(loc)
		HMG.rounds = rounds //Inherent the amount of ammo we had.
		qdel(src) //Now we clean up the constructed gun.

	else if(istype(I, /obj/item/ammo_magazine/m56d)) // RELOADING DOCTOR FREEMAN.
		var/obj/item/ammo_magazine/m56d/M = I
		if(user.mind?.cm_skills && user.mind.cm_skills.heavy_weapons < SKILL_HEAVY_WEAPONS_TRAINED)
			if(rounds)
				to_chat(user, "<span class='warning'>You only know how to swap the ammo drum when it's empty.</span>")
				return

			if(user.action_busy)
				return

			if(!do_after(user, 25, TRUE, src, BUSY_ICON_FRIENDLY))
				return

		user.visible_message("<span class='notice'> [user] loads [src]! </span>","<span class='notice'> You load [src]!</span>")
		playsound(loc, 'sound/weapons/guns/interact/minigun_cocked.ogg', 25, 1)
		if(rounds)
			var/obj/item/ammo_magazine/m56d/D = new(user.loc)
			D.current_rounds = rounds
		rounds = min(rounds + M.current_rounds, rounds_max)
		update_icon()
		user.temporarilyRemoveItemFromInventory(I)
		qdel(I)


/obj/machinery/m56d_hmg/attack_alien(mob/living/carbon/xenomorph/M) // Those Ayy lmaos.
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_M56)
	return ..()

/obj/machinery/m56d_hmg/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(rounds == 0)
		update_icon() //make sure the user can see the lack of ammo.
		return FALSE //Out of ammo.

	in_chamber = new /obj/item/projectile(loc) //New bullet!
	in_chamber.generate_bullet(ammo)
	return 1

/obj/machinery/m56d_hmg/proc/process_shot()
	set waitfor = 0

	if(isnull(target))
		return //Acqure our victim.

	if(!ammo)
		update_icon() //safeguard.
		return

	if(burst_fire && target && !last_fired)
		if(rounds > 3)
			for(var/i = 1 to 3)
				is_bursting = 1
				fire_shot()
				sleep(2)
			last_fired = TRUE
			addtimer(VARSET_CALLBACK(src, last_fired, FALSE), fire_delay)
		else burst_fire = 0
		is_bursting = 0

	if(!burst_fire && target && !last_fired)
		fire_shot()
	if(burst_fire_toggled)
		burst_fire = !burst_fire
		burst_fire_toggled = FALSE
	target = null

/obj/machinery/m56d_hmg/proc/fire_shot() //Bang Bang
	if(!ammo)
		return //No ammo.
	if(last_fired)
		return //still shooting.

	if(!is_bursting)
		last_fired = TRUE
		addtimer(VARSET_CALLBACK(src, last_fired, FALSE), fire_delay)

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)

	if (!istype(T) || !istype(U))
		return

	var/scatter_chance = 5
	if(burst_fire)
		scatter_chance = 10 //Make this sucker more accurate than the actual Sentry, gives it a better role.

	if(prob(scatter_chance) && get_dist(T,U) > 2) //scatter at point blank could make us fire sideways.
		U = locate(U.x + rand(-1,1),U.y + rand(-1,1),U.z)


	if(load_into_chamber() == 1)
		if(istype(in_chamber,/obj/item/projectile))
			in_chamber.original = target
			in_chamber.setDir(dir)
			in_chamber.def_zone = pick("chest","chest","chest","head")
			playsound(src.loc, 'sound/weapons/guns/fire/hmg.ogg', 75, 1)
			in_chamber.fire_at(U,src,null,ammo.max_range,ammo.shell_speed)
			if(target)
				var/angle = round(Get_Angle(src,target))
				muzzle_flash(angle)
			in_chamber = null
			rounds--
			if(!rounds)
				visible_message("<span class='notice'> [icon2html(src, viewers(src))] \The M56D beeps steadily and its ammo light blinks red.</span>")
				playsound(src.loc, 'sound/weapons/guns/misc/smg_empty_alarm.ogg', 25, 1)
				update_icon() //final safeguard.
	return

/obj/machinery/m56d_hmg/proc/muzzle_flash(angle) // Might as well keep this too.
	if(isnull(angle))
		return

	if(prob(65))
		var/img_layer = layer + 0.1

		var/image/I = image('icons/obj/items/projectiles.dmi', src, "muzzle_flash",img_layer)
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		I.transform = rotate
		flick_overlay_view(I, src, 3)

/obj/machinery/m56d_hmg/MouseDrop(over_object, src_location, over_location) //Drag the MG to us to man it.
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(user.incapacitated())
		return
	if((over_object == user && (in_range(src, user) || locate(src) in user))) //Make sure its on ourselves
		if(user.interactee == src)
			user.unset_interaction()
			visible_message("[icon2html(src, viewers(src))] <span class='notice'>[user] decided to let someone else have a go </span>")
			to_chat(usr, "<span class='notice'>You decided to let someone else have a go on the MG </span>")
			return
		if(!Adjacent(user))
			to_chat(usr, "<span class='warning'>Something is between you and [src].</span>")
			return
		if(get_step(src,reverse_direction(dir)) != user.loc)
			to_chat(user, "<span class='warning'>You should be behind [src] to man it!</span>")
			return
		if(operator) //If there is already a operator then they're manning it.
			if(operator.interactee == null)
				operator = null //this shouldn't happen, but just in case
			else
				to_chat(user, "Someone's already controlling it.")
				return
		else
			if(user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
				to_chat(user, "You're already manning something!")
				return
			if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
				to_chat(user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
				return
			if(user.get_active_held_item() != null)
				to_chat(user, "<span class='warning'>You need a free hand to man the [src].</span>")
			else
				visible_message("[icon2html(src, viewers(src))] <span class='notice'>[user] mans the M56D!</span>")
				to_chat(user, "<span class='notice'>You man the gun!</span>")
				user.set_interaction(src)


/obj/machinery/m56d_hmg/InterceptClickOn(mob/user, params, atom/object)
	if(is_bursting)
		return TRUE
	if(user.lying || !Adjacent(user) || user.incapacitated())
		user.unset_interaction()
		return FALSE
	if(user.get_active_held_item())
		to_chat(usr, "<span class='warning'>You need a free hand to shoot the [src].</span>")
		return TRUE
	target = object
	if(!istype(target))
		return FALSE
	if(isnull(operator.loc) || isnull(loc) || !z || !target?.z == z)
		return FALSE
	if(get_dist(target, loc) > 15)
		return TRUE

	var/list/pa = params2list(params)
	if(pa.Find("ctrl"))
		burst_fire = !burst_fire
		burst_fire_toggled = TRUE

	var/angle = get_dir(src,target)
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != loc && target.loc != operator.loc)
		if(!rounds)
			to_chat(user, "<span class='warning'><b>*click*</b></span>")
			playsound(src, 'sound/weapons/guns/fire/empty.ogg', 25, 1, 5)
		else
			process_shot()
		return TRUE

	if(burst_fire_toggled)
		burst_fire = !burst_fire
	return FALSE


/obj/machinery/m56d_hmg/on_set_interaction(mob/user)
	user.client.change_view(view_tiles)
	switch(dir)
		if(NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = view_tile_offset * 32
		if(SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -1 * view_tile_offset * 32
		if(EAST)
			user.client.pixel_x = view_tile_offset * 32
			user.client.pixel_y = 0
		if(WEST)
			user.client.pixel_x = -1 * view_tile_offset * 32
			user.client.pixel_y = 0
	operator = user
	user.verbs += /mob/living/proc/toogle_mg_burst_fire
	user.client.click_intercept = src

/obj/machinery/m56d_hmg/on_unset_interaction(mob/user)
	if(user.client)
		user.client.change_view(world.view)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
		user.client.click_intercept = null
	if(operator == user)
		operator = null
	user.verbs -= /mob/living/proc/toogle_mg_burst_fire

/obj/machinery/m56d_hmg/check_eye(mob/user)
	if(user.lying || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()

/mob/living/proc/toogle_mg_burst_fire(obj/machinery/m56d_hmg/MG in list(interactee))
	set name = "Toggle MG Burst Fire"
	set category = "Weapons"

	if(!incapacitated() && MG.operator == src)
		MG.burst_fire = !MG.burst_fire
		to_chat(src, "<span class='notice'>You set [MG] to [MG.burst_fire ? "burst fire" : "single fire"] mode.</span>")
		playsound(loc, 'sound/items/deconstruct.ogg',25,1)

/obj/machinery/m56d_hmg/mg_turret //Our mapbound version with stupid amounts of ammo.
	name = "\improper M56D Smartgun Nest"
	desc = "A M56D smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.\n<span class='notice'>Use (ctrl-click) to shoot in bursts.</span>\n<span class='notice'>!!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	burst_fire = FALSE
	burst_fire_toggled = FALSE
	fire_delay = 2
	rounds = 1500
	rounds_max = 1500
	locked = TRUE
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_full = "towergun"
	icon_empty = "towergun"
	view_tile_offset = 6
	view_tiles = 7


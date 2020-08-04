//////////////////////////////////////////////////////////////
//Mounted MG, Replacment for the current jury rig code.

//Adds a coin for engi vendors
/obj/item/coin/marine/engineer
	name = "marine engineer support token"
	desc = "Insert this into a engineer vendor in order to access a support artillery weapon."
	flags_token = TOKEN_ENGI

// First thing we need is the ammo drum for this thing.
/obj/item/ammo_magazine/standard_hmg
	name = "TL-102 drum magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the TL-102 mounted heavy smartgun. Just click the TL-102 with this to reload it."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mag"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = "10x30mm"
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/smartgun
	gun_type = null


// Now we need a box for this.
/obj/item/storage/box/standard_hmg
	name = "\improper TL-102 crate"
	desc = "A large metal case with Japanese writing on the top. However it also comes with English text to the side. This is a TL-102 heavy smartgun, it clearly has various labeled warnings."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "crate" // I guess a placeholder? Not actually going to show up ingame for now.
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 7
	bypass_w_limit = list(
		/obj/item/standard_hmg,
		/obj/item/ammo_magazine/standard_hmg,
		)

/obj/item/storage/box/standard_hmg/Initialize()
	. = ..()
	new /obj/item/standard_hmg(src) //gun itself
	new /obj/item/ammo_magazine/standard_hmg(src) //ammo for the gun
	new /obj/item/ammo_magazine/standard_hmg(src)


// The actual gun itself.
/obj/item/standard_hmg
	name = "\improper TL-102 Mounted Heavy Smartgun"
	desc = "The TL-102 Heavy Machinegun. IFF capable. No extra work required, just deploy it."
	max_integrity = 300
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "turret_icon_e"
	var/rounds = 0 // How many rounds are in the weapon. This is useful if we break down our guns.
	var/burst_fire = FALSE

/obj/item/standard_hmg/Initialize()
	. = ..()
	update_icon()


/obj/item/standard_hmg/examine(mob/user as mob) //Let us see how much ammo we got in this thing.
	. = ..()
	if(!ishuman(user))
		return
	if(rounds)
		to_chat(usr, "It has [rounds] out of 300 rounds.")
	else
		to_chat(usr, "It seems to be lacking a ammo drum.")

/obj/item/standard_hmg/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "turret_icon_e"
	else
		icon_state = "turret_icon"
	return

/obj/item/standard_hmg/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	else if(istype(I, /obj/item/ammo_magazine/standard_hmg)) //lets equip it with ammo
		if(rounds)
			to_chat(user, "The TL-102 already has a ammo drum mounted on it!")
			return

		rounds = 300
		qdel(I)
		update_icon()
/obj/item/standard_hmg/attack_self(mob/user) //click the gun to unfold it.
	if(!ishuman(usr)) return

	var/step = get_step(user, user.dir)
	if(check_blocked_turf(step))
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [src]!</span>")
		return
	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return
	to_chat(user, "<span class='notice'>You deploy [src].</span>")
	var/obj/machinery/standard_hmg/P = new(step)
	P.obj_integrity = obj_integrity
	P.setDir(user.dir)
	P.rounds = rounds
	P.burst_fire = burst_fire
	P.update_icon()
	qdel(src)

/obj/item/standard_hmg/welder_act(mob/living/user, obj/item/I)
	if(user.action_busy)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	repair_damage(120)
	update_icon()
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	return TRUE

// The actual Machinegun itself, going to borrow some stuff from current sentry code to make sure it functions. Also because they're similiar.
/obj/machinery/standard_hmg
	name = "\improper TL-102 Mounted Heavy Smartgun"
	desc = "A deployed and mounted Heavy Smartgun. While it is capable of taking the same rounds as a smartgun, it fires specialized tungsten rounds for increased armor penetration.\n<span class='notice'>Use (ctrl-click) to toggle burstfire."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "turret"
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER //no hiding the hmg beind corpse
	use_power = 0
	max_integrity = 300
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)
	var/rounds = 0 //Have it be empty upon spawn.
	var/rounds_max = 300
	var/fire_delay = 2 //Gotta have rounds down quick. // Ren's changes
	var/burst_delay = 1 // Ren's changes
	var/last_fired = 0
	var/burst_fire = FALSE
	var/safety = FALSE
	var/atom/target = null // required for shooting at things.
	var/datum/ammo/bullet/machinegun/ammo = /datum/ammo/bullet/machinegun
	var/obj/projectile/in_chamber = null
	var/locked = 0 //1 means its locked inplace (this will be for sandbag MGs)
	var/is_bursting = 0.
	var/icon_full = "turret" // Put this system in for other MGs or just other mounted weapons in general, future proofing.
	var/icon_empty = "turret_e" //Empty
	var/view_tile_offset = 3	//this is amount of tiles we shift our vision towards MG direction
	var/view_tiles = WORLD_VIEW

/obj/machinery/standard_hmg/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[ammo] //dunno how this works but just sliding this in from sentry-code.
	update_icon()

/obj/machinery/standard_hmg/Destroy() //Make sure we pick up our trash.
	operator?.unset_interaction()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/standard_hmg/deconstruct(disassembled = TRUE)
	return ..()

/obj/machinery/standard_hmg/examine(mob/user) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		to_chat(user, "It has [rounds] round\s out of [rounds_max].")
	else
		to_chat(user, "It seems to be lacking ammo")

/obj/machinery/standard_hmg/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "[icon_empty]"
	else
		icon_state = "[icon_full]"
	return

/obj/machinery/standard_hmg/attackby(obj/item/I, mob/user, params) //This will be how we take it apart.
	. = ..()

	if(!ishuman(user))
		return

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/ammo_magazine/standard_hmg)) // RELOADING DOCTOR FREEMAN.
		var/obj/item/ammo_magazine/standard_hmg/M = I
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			if(rounds)
				to_chat(user, "<span class='warning'>You only know how to swap the ammo drum when it's empty.</span>")
				return

		if(rounds == rounds_max)
			to_chat(user, "<span class='warning'>You cannot reload the Smartgun, it has a full drum of ammo!</span>")
			return
		if(user.action_busy)
			return
		if(!do_after(user, 25, TRUE, src, BUSY_ICON_FRIENDLY))
			return
		user.visible_message("<span class='notice'> [user] loads [src]! </span>","<span class='notice'> You load [src]!</span>")
		playsound(loc, 'sound/weapons/guns/interact/minigun_cocked.ogg', 25, 1)
		user.temporarilyRemoveItemFromInventory(I)
		var/obj/item/ammo_magazine/standard_hmg/D = new()
		if(rounds)
			user.put_in_active_hand(D)
			D.current_rounds = rounds - (rounds_max - M.current_rounds)
		rounds = min(rounds + M.current_rounds, rounds_max)
		update_icon()
		qdel(I)

/obj/machinery/standard_hmg/welder_act(mob/living/user, obj/item/I)
	if(user.action_busy)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	repair_damage(120)
	update_icon()
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	return TRUE


/obj/machinery/standard_hmg/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		if(locked)
			to_chat(user, "This one is anchored in place and cannot be disassembled.")
			return
		to_chat(user, "You begin disassembling [src].")
		if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
			return
		user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")
		var/obj/item/standard_hmg/HMG
		if(user.get_active_held_item())
			HMG = new(loc)
		else
			HMG = new()
			user.put_in_active_hand(HMG)
		HMG.obj_integrity = obj_integrity
		HMG.rounds = rounds
		HMG.burst_fire = burst_fire
		HMG.update_icon()
		qdel(src)


/obj/machinery/standard_hmg/attack_alien(mob/living/carbon/xenomorph/M) // Those Ayy lmaos.
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_M56)
	return ..()


/obj/machinery/standard_hmg/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(rounds == 0)
		update_icon() //make sure the user can see the lack of ammo.
		return FALSE //Out of ammo.

	create_bullet()
	return TRUE


/obj/machinery/standard_hmg/proc/create_bullet()
	in_chamber = new /obj/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)


/obj/machinery/standard_hmg/proc/process_shot(mob/user)
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
				fire_shot(user)
				sleep(2)
			last_fired = TRUE
			addtimer(VARSET_CALLBACK(src, last_fired, FALSE), burst_delay)
		else burst_fire = 0
		is_bursting = 0

	if(!burst_fire && target && !last_fired)
		fire_shot(user)

	target = null

/obj/machinery/standard_hmg/proc/fire_shot(mob/user) //Bang Bang
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


	if(!load_into_chamber())
		return

	var/obj/projectile/proj_to_fire = in_chamber
	in_chamber = null //Projectiles live and die fast. It's better to null the reference early so the GC can handle it immediately.
	var/mob/living/L = locate() in U
	var/atom/A
	if(L !=null)
		proj_to_fire.original_target = L
		A = L
	else
		proj_to_fire.original_target = target
		A = target
	proj_to_fire.setDir(dir)
	proj_to_fire.def_zone = pick("chest","chest","chest","head")
	playsound(loc, 'sound/weapons/guns/fire/hmg2.ogg', 65, TRUE)
	if(!QDELETED(target))
		var/angle = round(Get_Angle(src,target))
		muzzle_flash(angle)
	proj_to_fire.fire_at(A, user, src, ammo.max_range, ammo.shell_speed)
	rounds--
	if(!rounds)
		visible_message("<span class='notice'> [icon2html(src, viewers(src))] \The TL-102 beeps steadily and its ammo light blinks red.</span>")
		playsound(loc, 'sound/weapons/guns/misc/smg_empty_alarm.ogg', 25, TRUE)
		update_icon() //final safeguard.


/obj/machinery/standard_hmg/proc/muzzle_flash(angle) // Might as well keep this too.
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


/obj/machinery/standard_hmg/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(user.interactee == src)
		user.unset_interaction()
		visible_message("[icon2html(src, viewers(src))] <span class='notice'>[user] decided to let someone else have a go </span>",
			"<span class='notice'>You decided to let someone else have a go on the MG </span>")
		return TRUE
	if(get_step(src, REVERSE_DIR(dir)) != user.loc)
		to_chat(user, "<span class='warning'>You should be behind [src] to man it!</span>")
		return TRUE
	if(operator) //If there is already a operator then they're manning it.
		if(!operator.interactee)
			stack_trace("/obj/machinery/standard_hmg/interact called by user [user] with an operator with a null interactee: [operator].")
			operator = null //this shouldn't happen, but just in case
		else
			to_chat(user, "<span class='warning'>Someone's already controlling it.</span>")
			return TRUE
	if(user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
		to_chat(user, "<span class='warning'>You're already busy!</span>")
		return TRUE
	if(issynth(human_user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
		return TRUE

	visible_message("[icon2html(src, viewers(src))] <span class='notice'>[user] mans the TL-102!</span>",
		"<span class='notice'>You man the gun!</span>")

	return ..()

/obj/machinery/standard_hmg/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && user.ShiftClickOn(object))
		return FALSE
	if(modifiers["shift"] && modifiers["middle"])
		user.ShiftMiddleClickOn(object)
		return FALSE
	if(is_bursting)
		return TRUE
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || get_step(src, REVERSE_DIR(dir)) != user.loc)
		user.unset_interaction()
		return FALSE
	if(user.get_active_held_item())
		to_chat(usr, "<span class='warning'>You need a free hand to shoot the [src].</span>")
		return TRUE
	target = object
	if(!istype(target))
		return FALSE
	if(user != operator)
		CRASH("InterceptClickOn called by user ([user]) different from operator ([operator]).")
	if(isnull(operator.loc) || isnull(loc) || !z || !target?.z == z)
		return FALSE
	if(get_dist(target, loc) > 15)
		return TRUE


	if(modifiers.Find("ctrl"))
		burst_fire = !burst_fire
		var/text = ""
		if(burst_fire)
			text = "ON"
		else
			text = "OFF"
		to_chat(user, "You toggle [src]'s burstfire to: [text]")
	var/angle = get_dir(src,target)
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != loc && target.loc != operator.loc)
		if(!rounds)
			to_chat(user, "<span class='warning'><b>*click*</b></span>")
			playsound(src, 'sound/weapons/guns/fire/empty.ogg', 25, 1, 5)
		else
			process_shot(user)
		user.setDir(dir)
		return TRUE
	else if (!(dir & angle) && target.loc != loc && target.loc != operator.loc) // Let us rotate this stuff.
		if(locked)
			to_chat(user, "This one is anchored in place and cannot be rotated.")
			return

		var/list/leftright = LeftAndRightOfDir(dir)
		var/left = leftright[1] - 1
		var/right = leftright[2] + 1
		if(left == (angle-1) || right == (angle+1))
			var/turf/w = get_step(src, REVERSE_DIR(angle))
			if(user.Move(w))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				user.visible_message("[user] rotates the [src].","You rotate the [src].")
				setDir(angle)
				user.set_interaction(src)
			else
				to_chat(user, "You cannot rotate [src] that way.")
				return
		else
			to_chat(user, "<span class='warning'> [src] cannot be rotated so violently.</span>")
	return FALSE


/obj/machinery/standard_hmg/on_set_interaction(mob/user)
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

/obj/machinery/standard_hmg/on_unset_interaction(mob/user)
	if(user.client)
		user.client.change_view(WORLD_VIEW)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
		user.client.click_intercept = null
	if(operator == user)
		operator = null
	user.verbs -= /mob/living/proc/toogle_mg_burst_fire

/obj/machinery/standard_hmg/check_eye(mob/user)
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()

/mob/living/proc/toogle_mg_burst_fire(obj/machinery/standard_hmg/MG in list(interactee))
	set name = "Toggle MG Burst Fire"
	set category = "Weapons"

	if(!incapacitated() && MG.operator == src)
		MG.burst_fire = !MG.burst_fire
		to_chat(src, "<span class='notice'>You set [MG] to [MG.burst_fire ? "burst fire" : "single fire"] mode.</span>")
		playsound(loc, 'sound/items/deconstruct.ogg',25,1)

/obj/machinery/standard_hmg/mg_turret //Our mapbound version with stupid amounts of ammo.
	name = "\improper TL-102 Heavy Smartgun Nest"
	desc = "A TL-102 Heavy Smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.\n<span class='notice'>Use (ctrl-click) to shoot in bursts."
	burst_fire = FALSE
	fire_delay = 2
	rounds = 1500
	rounds_max = 1500
	locked = TRUE
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_full = "entrenched"
	icon_empty = "entrenched_e"
	view_tile_offset = 6

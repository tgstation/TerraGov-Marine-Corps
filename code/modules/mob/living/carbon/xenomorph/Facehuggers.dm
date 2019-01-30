#define FACEHUGGER_LIFECYCLE 8 SECONDS
#define FACEHUGGER_KNOCKOUT 10

#define MIN_IMPREGNATION_TIME 10 SECONDS //Time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 15 SECONDS

#define MIN_ACTIVE_TIME 4 SECONDS //Time between being dropped and going idle
#define MAX_ACTIVE_TIME 8 SECONDS

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //Note: can be picked up by aliens unlike most other items of w_class below 4
	flags_inventory = COVEREYES|ALLOWINTERNALS|COVERMOUTH|ALLOWREBREATH
	flags_armor_protection = FACE|EYES
	flags_atom = NOFLAGS
	flags_item = NOBLUDGEON
	throw_range = 1
	layer = MOB_LAYER

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/hugger_tick = 0
	var/sterile = FALSE
	var/attached = FALSE
	var/lifecycle = FACEHUGGER_LIFECYCLE //How long the hugger will survive outside of the egg, or carrier.
	var/leaping = FALSE //Is actually attacking someone?
	var/hivenumber = XENO_HIVE_NORMAL

/obj/item/clothing/mask/facehugger/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/facehugger/ex_act(severity)
	Die()

/obj/item/clothing/mask/facehugger/proc/update_stat(new_stat)
	if(stat != new_stat)
		stat = new_stat
		update_icon()
		if(stat == CONSCIOUS)
			START_PROCESSING(SSobj, src)
		else
			hugger_tick = 0
			STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/facehugger/process()
	if(hugger_tick && hugger_tick % 2 == 0)
		monitor_surrounding()
	hugger_tick++

/obj/item/clothing/mask/facehugger/update_icon()
	if(stat == DEAD)
		var/fertility = sterile ? "impregnated" : "dead"
		icon_state = "[initial(icon_state)]_[fertility]"
	else if(throwing)
		icon_state = "[initial(icon_state)]_throwing"
	else if(stat == UNCONSCIOUS && !attached)
		icon_state = "[initial(icon_state)]_inactive"
	else
		icon_state = "[initial(icon_state)]"

//Can be picked up by aliens
/obj/item/clothing/mask/facehugger/attack_paw(user as mob)
	if(isxeno(user))
		attack_alien(user)
	else
		attack_hand(user)

//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/Xenomorph/user)
	if(user.hivenumber != hivenumber && stat != DEAD)
		user.animation_attack_on(src)
		user.visible_message("<span class='xenowarning'>[user] crushes \the [src]","<span class='xenowarning'>You crush \the [src]")
		Die()
		return
	else
		attack_hand(user)

/obj/item/clothing/mask/facehugger/attack_hand(mob/user)
	if(isxeno(user))
		var/mob/living/carbon/Xenomorph/X = user
		if(X.xeno_caste.caste_flags & CASTE_CAN_HOLD_FACEHUGGERS)
			return ..() // These can pick up huggers.
		else
			return FALSE // The rest can't.
	if(stat == DEAD || sterile)
		return ..() // Dead or sterile (lamarr) can be picked.
	else if(stat == CONSCIOUS && CanHug(user, provoked = TRUE)) // If you try to take a healthy one it will try to hug you.
		Attach(user)
	return FALSE // Else you can't pick.

/obj/item/clothing/mask/facehugger/attack(mob/M, mob/user)
	if(!CanHug(M, provoked = TRUE))
		to_chat(user, "<span class='warning'>The facehugger refuses to attach.</span>")
		return ..()
	user.visible_message("<span class='warning'>\ [user] attempts to plant [src] on [M]'s face!</span>", \
	"<span class='warning'>You attempt to plant [src] on [M]'s face!</span>")
	if(M.client && !M.stat) //Delay for conscious cliented mobs, who should be resisting.
		if(!do_after(user, 10, TRUE, 5, BUSY_ICON_HOSTILE))
			return
	Attach(M)
	user.update_icons()

/obj/item/clothing/mask/facehugger/attack_self(mob/user)
	if(isxenocarrier(user))
		var/mob/living/carbon/Xenomorph/Carrier/C = user
		C.store_hugger(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	. = ..()
	if(stat != CONSCIOUS)
		to_chat(user, "<span class='warning'>[src] is not moving.</span>")
	else
		to_chat(user, "<span class='danger'>[src] seems to be active.</span>")
	if(initial(sterile))
		to_chat(user, "<span class='warning'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/attackby(obj/item/W, mob/user)
	if(W.flags_item & NOBLUDGEON || attached)
		return
	Die()

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P)
	..()
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX))
		return FALSE //Xeno spits ignore huggers.
	if(P.damage && !(P.ammo.damage_type in list(OXY, HALLOSS)))
		Die()
	P.ammo.on_hit_obj(src,P)
	return TRUE

/obj/item/clothing/mask/facehugger/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()

/obj/item/clothing/mask/facehugger/flamer_fire_act()
	Die()

/obj/item/clothing/mask/facehugger/proc/monitor_surrounding()
	if(stat == CONSCIOUS && loc && !throwing) //Make sure we're conscious and not idle, dead or in action.
		if(check_lifecycle())
			leap_at_nearest_target()

/obj/item/clothing/mask/facehugger/proc/GoIdle(stasis = FALSE) //Idle state does not count toward the death timer.
	if(stat != CONSCIOUS)
		return
	update_stat(UNCONSCIOUS)
	if(stasis)
		lifecycle = initial(lifecycle)
	else if(!attached)
		addtimer(CALLBACK(src, .proc/GoActive), rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == UNCONSCIOUS)
		update_stat(CONSCIOUS)
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/check_lifecycle()
	if(sterile)
		return TRUE
	if(isturf(loc))
		if(check_neighbours())
			return FALSE
	if(lifecycle - 2 SECONDS <= 0)
		if(isturf(loc))
			var/obj/effect/alien/egg/E = locate() in loc
			if(E?.status == EGG_BURST)
				visible_message("<span class='xenowarning'>[src] crawls back into [E]!</span>")
				forceMove(E)
				E.hugger = src
				E.update_status(EGG_GROWN)
				E.deploy_egg_triggers()
				GoIdle(TRUE)
				return FALSE
			var/obj/effect/alien/resin/trap/T = locate() in loc
			if(T && !T.hugger)
				visible_message("<span class='xenowarning'>[src] crawls into [T]!</span>")
				forceMove(T)
				T.hugger = src
				T.icon_state = "trap1"
				GoIdle(TRUE)
				return FALSE
		Die()
		return FALSE

	lifecycle -= 2 SECONDS
	return TRUE

/obj/item/clothing/mask/facehugger/proc/check_neighbours()
	var/obj/item/clothing/mask/facehugger/F
	var/count = 0
	for(F in get_turf(src))
		if(F.stat == CONSCIOUS && !F.sterile)
			count++
		if(count > 2) //Was 5, our rules got much tighter
			visible_message("<span class='xenowarning'>The facehugger is furiously cannibalized by the nearby horde of other ones!</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	return HasProximity(finder)

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM)
	if(CanHug(AM))
		if(stat == CONSCIOUS)
			Attach(AM)
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/leap_at_nearest_target()
	if(isturf(loc))
		var/mob/living/M
		var/i = 10//So if we have a pile of dead bodies around, it doesn't scan everything, just ten iterations.
		for(M in view(4,src))
			if(!i)
				break
			if(CanHug(M))
				M.visible_message("<span class='warning'>\The scuttling [src] leaps at [M]!</span>", \
				"<span class='warning'>The scuttling [src] leaps at [M]!</span>")
				leaping = TRUE
				throw_at(M, 4, 1)
				break
			i--
		if(!attached) //Didn't hit anything?
			i = 5
			for(M in loc)
				if(!i)
					break
				if(CanHug(M))
					Attach(M)
					break
				i--

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	. = ..()
	if(stat == CONSCIOUS)
		update_stat(UNCONSCIOUS) //stopping their process for the flight duration.

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, speed)
	if(stat == DEAD)
		return ..()
	if(ismob(hit_atom))
		if(leaping && CanHug(hit_atom)) //Standard leaping behaviour, not attributable to being _thrown_ such as by a Carrier.
			stat = CONSCIOUS
			Attach(hit_atom)
		else if(hit_atom.density) //We hit something, cool.
			step(src, turn(dir, 180)) //We want the hugger to bounce off if it hits a mob.
			throwing = FALSE
			leaping = FALSE
			addtimer(CALLBACK(src, .proc/fast_activate), 1.5 SECONDS)

	else
		addtimer(CALLBACK(src, .proc/fast_activate), rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		return ..()

/obj/item/clothing/mask/facehugger/proc/fast_activate()
	if(GoActive())
		monitor_surrounding()

/obj/item/clothing/mask/facehugger/proc/CanHug(mob/living/carbon/M, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(!istype(M) || stat == DEAD)
		return FALSE

	if(!(ishuman(M) || ismonkey(M)) || M.status_flags & (XENO_HOST|GODMODE))
		return FALSE

	if(check_death && M.stat == DEAD)
		return FALSE

	if(!provoked)
		if(iszombie(M))
			return FALSE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species?.flags & IS_SYNTHETIC)
				return FALSE

	//Already have a hugger? NOPE
	//This is to prevent eggs from bursting all over if you walk around with one on your face,
	//or an unremovable mask.
	if(check_mask && M.wear_mask)
		var/obj/item/W = M.wear_mask
		if(W.flags_item & NODROP)
			return FALSE
		if(istype(W, /obj/item/clothing/mask/facehugger))
			var/obj/item/clothing/mask/facehugger/hugger = W
			if(hugger.stat != DEAD)
				return FALSE
	else if (M.wear_mask != src)
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/carbon/M, self_done = FALSE)

	if(!istype(M) || stat != CONSCIOUS)
		return FALSE

	if(attached || M.status_flags & XENO_HOST || isxeno(M))
		return FALSE
	if(!self_done)
		M.visible_message("<span class='danger'>[src] leaps at [M]'s face!</span>")

	throwing = FALSE
	leaping = FALSE
	update_icon()

	if(isxeno(loc)) //Being carried? Drop it
		var/mob/living/carbon/Xenomorph/X = loc
		X.dropItemToGround(src)
		X.update_icons()

	var/blocked = null //To determine if the hugger just rips off the protection or can infect.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!H.has_limb(HEAD))
			visible_message("<span class='warning'>[src] looks for a face to hug on [H], but finds none!</span>")
			GoIdle()
			return

		if(isyautja(H) && !self_done)
			var/catch_chance = 50
			if(H.dir == reverse_dir[dir])
				catch_chance += 20
			if(H.lying)
				catch_chance -= 50
			catch_chance -= ((H.maxHealth - H.health) / 3)
			if(H.get_active_held_item())
				catch_chance  -= 25
			if(H.get_inactive_held_item())
				catch_chance  -= 25

			if(!H.stat && H.dir != dir && prob(catch_chance)) //Not facing away
				H.visible_message("<span class='notice'>[H] snatches [src] out of the air and squashes it!")
				Die()
				loc = H.loc
				return

		if(H.head)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 0 || D.flags_item & NODROP)
					blocked = D
					D.anti_hug = max(0, --D.anti_hug)
					if(prob(60 + 10 * D.anti_hug)) //60% chance + 10% per anti_hug point that it will idle now. Still a warranty against hugging.
						H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name], damaging it!")
						GoIdle()
						return FALSE
				else
					if(istype(D, /obj/item/clothing/head/helmet/marine)) //Marine helmets now get a fancy overlay.
						var/obj/item/clothing/head/helmet/marine/m_helmet = D
						m_helmet.add_hugger_damage()
					H.update_inv_head()

	if(M.wear_mask)
		var/obj/item/clothing/mask/W = M.wear_mask
		if(istype(W))
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return

			if(W.anti_hug > 0 || W.flags_item & NODROP)
				if(!blocked)
					blocked = W
				W.anti_hug = max(0, --W.anti_hug)
				if(prob(60 + 10 * W.anti_hug))
					M.visible_message("<span class='danger'>[src] smashes against [M]'s [blocked]!</span>")
					GoIdle()
					return FALSE

			if(!blocked)
				M.visible_message("<span class='danger'>[src] smashes against [M]'s [W.name] and rips it off!</span>")
				M.dropItemToGround(W)
			if(ishuman(M)) //Check for camera; if we have one, turn it off.
				var/mob/living/carbon/human/H = M
				if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine))
					var/obj/item/device/radio/headset/almayer/marine/R = H.wear_ear
					if(R.camera.status)
						R.camera.status = FALSE //Turn camera off.
						to_chat(H, "<span class='danger'>Your headset camera flickers off; you'll need to reactivate it by rebooting your headset HUD!<span>")

	if(blocked)
		M.visible_message("<span class='danger'>[src] smashes against [M]'s [blocked]!</span>")
		return FALSE

	M.equip_to_slot(src, SLOT_WEAR_MASK)
	return TRUE

/obj/item/clothing/mask/facehugger/equipped(mob/living/user, slot)
	. = ..()
	if(slot != SLOT_WEAR_MASK || stat != CONSCIOUS)
		reset_attach_status(FALSE)
		return
	if(ishuman(user))
		playsound(loc, (user.gender == MALE ?'sound/misc/facehugged_male.ogg' : 'sound/misc/facehugged_female.ogg') , 25, 0)
	if(!sterile)
		if(!issynth(user) || !isIPC(user)) //synthetics aren't paralyzed
			if(user.disable_lights(sparks = TRUE, silent = TRUE)) //Knock out the lights so the victim can't be cam tracked/spotted as easily
				user.visible_message("<span class='danger'>[user]'s lights flicker and short out in a struggle!</span>", "<span class='danger'>Your equipment's lights flicker and short out in a struggle!</span>")
			user.KnockOut(FACEHUGGER_KNOCKOUT) //THIS MIGHT NEED TWEAKS
	flags_item |= NODROP
	attached = TRUE
	GoIdle()
	addtimer(CALLBACK(src, .proc/Impregnate, user), rand(MIN_IMPREGNATION_TIME, MAX_IMPREGNATION_TIME))

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/carbon/target)
	var/as_planned = target?.wear_mask == src ? TRUE : FALSE
	if(CanHug(target, FALSE, FALSE) && !sterile) //double check for changes
		var/embryos = 0
		for(var/obj/item/alien_embryo/embryo in target) // already got one, stops doubling up
			embryos++
		if(!embryos)
			var/obj/item/alien_embryo/embryo = new(target)
			embryo.hivenumber = hivenumber
			round_statistics.now_pregnant++
			sterile = TRUE
		Die()
	else
		reset_attach_status(as_planned)
		playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)
		addtimer(CALLBACK(src, .proc/GoActive), rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))

	if(as_planned)
		if(sterile || target.status_flags & XENO_HOST)
			target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>")
		else //Huggered but not impregnated, deal damage.
			target.visible_message("<span class='danger'>[src] frantically claws at [target]'s face before falling down!</span>","<span class='danger'>[src] frantically claws at your face before falling down! Auugh!</span>")
			target.apply_damage(15, BRUTE, "head")

/obj/item/clothing/mask/facehugger/proc/Die(update_icon = TRUE)
	reset_attach_status()

	if(stat == DEAD)
		return

	update_stat(DEAD)

	visible_message("\icon[src] <span class='danger'>\The [src] curls up into a ball!</span>")
	playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

	layer = BELOW_MOB_LAYER //so dead hugger appears below live hugger if stacked on same tile.

	addtimer(CALLBACK(src, .proc/melt_away), 3 MINUTES)

/obj/item/clothing/mask/facehugger/proc/reset_attach_status(forcedrop = TRUE)
	flags_item &= ~NODROP
	attached = FALSE
	if(ismob(loc) && forcedrop) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
		var/mob/M = loc
		M.dropItemToGround(src)
	update_icon()

/obj/item/clothing/mask/facehugger/proc/melt_away()
	visible_message("\icon[src] <span class='danger'>\The [src] decays into a mass of acid and chitin.</span>")
	qdel(src)

#undef FACEHUGGER_LIFECYCLE
#undef FACEHUGGER_KNOCKOUT
#undef MIN_IMPREGNATION_TIME
#undef MAX_IMPREGNATION_TIME
#undef MIN_ACTIVE_TIME
#undef MAX_ACTIVE_TIME

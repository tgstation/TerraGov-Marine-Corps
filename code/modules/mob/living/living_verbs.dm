/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	if(usr.incapacitated(TRUE))
		to_chat(src, "<span class='warning'>You can't resist in your current state.</span>")
		return
	var/mob/living/L = usr
	usr.next_move = world.time + 20

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/holder))
		var/obj/item/holder/H = src.loc //Get our item holder.
		var/mob/M = H.loc                      //Get our mob holder (if any).

		if(istype(M))
			M.dropItemToGround(H)
			to_chat(M, "[H] wriggles out of your grip!")
			to_chat(src, "You wriggle out of [M]'s grip!")
		else if(istype(H.loc,/obj/item))
			to_chat(src, "You struggle free of [H.loc].")
			H.loc = get_turf(H)

		if(istype(M))
			for(var/atom/A in M.contents)
				if(istype(A,/obj/item/holder))
					return

		M.status_flags &= ~PASSEMOTES
		return

	//resisting grabs (as if it helps anyone...)
	if(!restrained(0) && pulledby)
		visible_message("<span class='danger'>[src] resists against [pulledby]'s grip!</span>")
		resist_grab()
		return

	//untangling
	if(entangled_by)
		if(world.time < entangle_delay)
			visible_message("<span class='danger'>[src] attempts to disentangle itself from [entangled_by] but was unsuccessful!</span>")
			to_chat(src, "<span class='warning'>You will be able to disentangle yourself after [(entangle_delay - world.time) * 0.1] more seconds!</span>")
			return
		if(istype(entangled_by, /obj/structure/razorwire) )
			var/obj/structure/razorwire/R = entangled_by
			R.razorwire_untangle(src)
		return

	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if(iscarbon(L))
			if(istype(L.buckled,/obj/structure/bed/nest))
				L.buckled.manual_unbuckle(L)
				return

			var/mob/living/carbon/C = L
			if( C.handcuffed )
				C.next_move = world.time + 100
				C.last_special = world.time + 100
				C.visible_message("<span class='danger'>[C] attempts to unbuckle themself!</span>",\
				"<span class='warning'> You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)</span>")
				if(do_after(C, 1200, FALSE, 5, BUSY_ICON_HOSTILE))
					if(!C.buckled)
						return
					C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>",\
								"<span class='notice'> You successfully unbuckle yourself.</span>")
					C.buckled.manual_unbuckle(C)
			else
				C.buckled.manual_unbuckle(C)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	else if( src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		usr.next_move = world.time + 100
		L.last_special = world.time + 100
		to_chat(L, "<span class='warning'>You lean on the back of \the [C] and start pushing the door open. (this will take about [breakout_time] minutes)</span>")
		for(var/mob/O in viewers(usr.loc))
			O.show_message("<span class='danger'>The [L.loc] begins to shake violently!</span>", 1)


		spawn(0)
			if(do_after(usr,(breakout_time*60*10), FALSE)) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
				if(istype(L.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					if(!SC.locked && !SC.welded)
						return
				else
					if(!C.welded)
						return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = 1
					SC.locked = 0
					SC.update_icon()
					to_chat(usr, "<span class='warning'>You successfully break out!</span>")
					for(var/mob/O in viewers(L.loc))
						O.show_message("<span class='danger'>\the [usr] successfully broke out of \the [SC]!</span>", 1)
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					C.update_icon()
					to_chat(usr, "<span class='warning'>You successfully break out!</span>")
					for(var/mob/O in viewers(L.loc))
						O.show_message("<span class='danger'>\the [usr] successfully broke out of \the [C]!</span>", 1)
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//breaking out of handcuffs & putting out fires
	else if(iscarbon(L))
		if (isxeno(L))
			var/mob/living/carbon/Xenomorph/X = L
			if (X.on_fire && X.canmove && !knocked_down)
				X.fire_stacks = max(X.fire_stacks - rand(3, 6), 0)
				X.KnockDown(4, TRUE)
				X.visible_message("<span class='danger'>[X] rolls on the floor, trying to put themselves out!</span>", \
					"<span class='notice'>You stop, drop, and roll!</span>", null, 5)
				if (fire_stacks <= 0)
					X.visible_message("<span class='danger'>[X] has successfully extinguished themselves!</span>", \
					"<span class='notice'>You extinguish yourself.</span>", null, 5)
					ExtinguishMob()
				return

		var/mob/living/carbon/human/CM = L
		if(CM.on_fire && CM.canmove && !knocked_down)
			CM.fire_stacks = max(CM.fire_stacks - rand(3,6), 0)
			CM.KnockDown(4, TRUE)
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>", \
				"<span class='notice'>You stop, drop, and roll!</span>", null, 5)
			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>", \
					"<span class='notice'>You extinguish yourself.</span>", null, 5)
				ExtinguishMob()
			return
		if(CM.handcuffed && CM.canmove && (CM.last_special <= world.time))
			var/obj/item/handcuffs/HC = CM.handcuffed

			CM.next_move = world.time + 100
			CM.last_special = world.time + 100

			var/can_break_cuffs
			if(HULK in usr.mutations)
				can_break_cuffs = 1
			else if(istype(CM,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = CM
				if(H.species.can_shred(H))
					can_break_cuffs = 1


			if(can_break_cuffs) //Don't want to do a lot of logic gating here.
				to_chat(usr, "<span class='warning'>You attempt to break [HC]. (This will take around 5 seconds and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break [HC]!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, FALSE, 5, BUSY_ICON_HOSTILE))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break [HC]!</span>", CM), 1)
						to_chat(CM, "<span class='warning'>You successfully break [HC].</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						qdel(CM.handcuffed)
						CM.handcuffed = null
						CM.handcuff_update()
			else
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				/*if(istype(HC, /obj/item/handcuffs/xeno))
					breakouttime = 300
					displaytime = "Half a"
					to_chat(CM, "<span class='warning'>You attempt to remove \the [HC]. (This will take around half a minute and you need to stand still)</span>")
					spawn (breakouttime)
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("<span class='danger'>[CM] manages to remove the handcuffs!</span>", 1)
						to_chat(CM, "<span class='notice'>You successfully remove \the [CM.handcuffed].</span>")
						CM.dropItemToGround(CM.handcuffed)
						return*/ //Commented by Apop


				if(istype(HC))
					displaytime = max(1, round(HC.breakouttime / 600)) //Minutes
				to_chat(CM, "<span class='warning'>You attempt to remove [HC]. (This will take around [displaytime] minute(s) and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message( "<span class='danger'>[usr] attempts to remove [HC]!</span>", 1)
				spawn(0)
					if(do_after(CM, HC.breakouttime, FALSE, 5, BUSY_ICON_HOSTILE))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("<span class='danger'>[CM] manages to remove [HC]!</span>", 1)
						to_chat(CM, "<span class='notice'>You successfully remove [HC].</span>")
						CM.dropItemToGround(CM.handcuffed)
		else if(CM.legcuffed && CM.canmove && (CM.last_special <= world.time))
			var/obj/item/legcuffs/LC = CM.legcuffed

			CM.next_move = world.time + 100
			CM.last_special = world.time + 100

			var/can_break_cuffs
			if(HULK in usr.mutations)
				can_break_cuffs = 1
			else if(istype(CM,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = CM
				if(H.species.can_shred(H))
					can_break_cuffs = 1

			if(can_break_cuffs) //Don't want to do a lot of logic gating here.
				to_chat(usr, "<span class='warning'>You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break [LC]!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, FALSE, 5, BUSY_ICON_HOSTILE))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break [LC]!</span>", CM), 1)
						to_chat(CM, "<span class='warning'>You successfully break your legcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						CM.temporarilyRemoveItemFromInventory(CM.legcuffed)
						qdel(CM.legcuffed)
						CM.legcuffed = null
			else
				var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/legcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(LC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
					breakouttime = LC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				to_chat(CM, "<span class='warning'>You attempt to remove [LC]. (This will take around [displaytime] minutes and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message( "<span class='danger'>[usr] attempts to remove [LC]!</span>", 1)
				spawn(0)
					if(do_after(CM, breakouttime, FALSE, 5, BUSY_ICON_HOSTILE))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("<span class='danger'>[CM] manages to remove the legcuffs!</span>", 1)
						to_chat(CM, "<span class='notice'>You successfully remove \the [CM.legcuffed].</span>")
						CM.dropItemToGround(CM.legcuffed)


/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	if(incapacitated(TRUE))
		return

	if(!resting)
		resting = TRUE
		to_chat(src, "<span class='notice'>You are now resting.</span>")
		update_canmove()
	else if(action_busy)
		to_chat(src, "<span class='warning'>You are still in the process of standing up.</span>")
		return
	else
		action_busy = TRUE
		overlays += get_busy_icon(BUSY_ICON_GENERIC)
		addtimer(CALLBACK(src, .proc/get_up), 2 SECONDS)


/mob/living/proc/get_up()
	action_busy = FALSE
	overlays -= get_busy_icon(BUSY_ICON_GENERIC)
	if(!incapacitated(TRUE))
		to_chat(src, "<span class='notice'>You get up.</span>")
		resting = FALSE
		update_canmove()
	else
		to_chat(src, "<span class='notice'>You fail to get up.</span>")


/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", "Ghost", "Stay in body") != "Ghost")
		return

	resting = TRUE
	log_game("[key_name(usr)] has ghosted.")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	var/mob/dead/observer/ghost = ghostize(FALSE)
	if(ghost)
		ghost.timeofdeath = world.time
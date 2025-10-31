/obj/structure/bed/nest/advanced
	name = "tentacle breeding nest"
	desc = "It's a gruesome pile of thick, sticky resin-covered tentacles shaped like a nest."
	var/hivenumber = XENO_HIVE_NORMAL
	var/targethole = 1
	var/settings_locked = FALSE
	var/list/mob/living/carbon/human/grabbing = null
	COOLDOWN_DECLARE(tentacle_cooldown)
	resist_time = 30 SECONDS

/obj/structure/bed/nest/advanced/Initialize(mapload, _hivenumber)
	. = ..()
	if(_hivenumber) ///because admins can spawn them
		hivenumber = _hivenumber
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	name = "[hive.prefix][name]"
	color = hive.color
	START_PROCESSING(SSslowprocess, src)
	var/static/list/listen_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, listen_connections)

/obj/structure/bed/nest/advanced/examine(mob/user)
	. = ..()
	var/targetholename = "!!ERROR!!"
	switch(targethole)
		if(1)
			targetholename = "mouth"
		if(2)
			targetholename = "ass"
		if(3)
			targetholename = "pussy"
	. += span_notice("It is currently set to use its victim's [targetholename].")
	if(settings_locked)
		if(user.buckled == src)
			. += span_notice("Set to: <a href=byond://?src=[REF(src)];sethole=1>\[mouth\]</a> <a href=byond://?src=[REF(src)];sethole=2>\[ass\]</a> <a href=byond://?src=[REF(src)];sethole=3>\[pussy\]</a> <a href=byond://?src=[REF(src)];lock=2>\[unlock settings\]</a>")
		else
			. += span_notice("The settings are locked. Only the person buckled to it can unlock them.")
	else
		. += span_notice("Set to: <a href=byond://?src=[REF(src)];sethole=1>\[mouth\]</a> <a href=byond://?src=[REF(src)];sethole=2>\[ass\]</a> <a href=byond://?src=[REF(src)];sethole=3>\[pussy\]</a> <a href=byond://?src=[REF(src)];lock=1>\[lock settings\]</a>")

/obj/structure/bed/nest/advanced/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	settings_locked = FALSE
	COOLDOWN_START(src, tentacle_cooldown, 29.9 SECONDS)

/obj/structure/bed/nest/advanced/proc/on_cross(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	try_to_grab(A)

/obj/structure/bed/nest/advanced/proc/try_to_grab(mob/living/carbon/human/target)
	if(!COOLDOWN_FINISHED(src, tentacle_cooldown))
		return
	if(LAZYLEN(buckled_mobs))
		return
	if(CHECK_MULTIPLE_BITFIELDS(target.allow_pass_flags, HOVERING))
		return
	if(!ishuman(target))
		return
	if(issamexenohive(target))
		return
	if(target.stat == DEAD)
		return
	if(target.buckled)
		return
	if(target in grabbing)
		return
	if(ismonkey(target))
		if(!buckle_mob(target))
			return
		target.visible_message(span_danger("Tentacles suddenly grab [target]'s legs and secure [target.p_them()] into [src]!"),
		span_userdanger("Tentacles suddenly grab your legs and secure you into [src]!"),
		span_notice("You hear squelching."))
		return
	COOLDOWN_START(src, tentacle_cooldown, 29.9 SECONDS)
	target.visible_message(span_danger("Tentacles start grabbing at [target]'s legs to try to secure [target.p_them()] into [src]!"),
		span_userdanger("Tentacles suddenly grab your legs to try to secure you into [src]!"),
		span_notice("You hear squelching."))
	LAZYADD(grabbing, target)
	ASYNC
		if(!do_mob(target, src, 10 SECONDS, null, BUSY_ICON_DANGER, PROGRESS_GENERIC, IGNORE_HAND | IGNORE_HELD_ITEM | IGNORE_DO_AFTER_COEFFICIENT | IGNORE_INCAPACITATION))
			LAZYREMOVE(grabbing, target)
			return
		if(!buckle_mob(target))
			return
		target.visible_message(span_danger("Tentacles secure [target] into [src]!"),
			span_userdanger("Tentacles secure you into [src]!"),
			span_notice("You hear squelching."))

/obj/structure/bed/nest/advanced/can_interact(mob/user)
	if(isliving(user))
		return (src in view(user))

	return IsAdminGhost(user)

/obj/structure/bed/nest/advanced/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["sethole"])
		if(!(src in view(3, usr)))
			to_chat(usr, span_warning("You aren't close enough to [src] to change the setting!"))
			return
		if(settings_locked && (usr.buckled != src))
			to_chat(usr, span_warning("The settings of [src] are locked! Only the person buckled to it can change them currently."))
			return
		switch(href_list["sethole"])
			if("1")
				targethole = 1
				to_chat(usr, span_notice("You set [src] to use its victim's mouth."))
			if("2")
				targethole = 2
				to_chat(usr, span_notice("You set [src] to use its victim's ass."))
			if("3")
				targethole = 3
				to_chat(usr, span_notice("You set [src] to use its victim's pussy."))
			else
				to_chat(usr, span_warning("Attempted to set [src]'s target hole to an invalid value."))
	if(href_list["lock"])
		if(usr.buckled != src)
			to_chat(usr, span_warning("Only the person buckled to [src] can lock or unlock its settings."))
			return
		switch(href_list["lock"])
			if("1")
				settings_locked = TRUE
				to_chat(usr, span_notice("You lock the settings of [src]."))
			if("2")
				settings_locked = FALSE
				to_chat(usr, span_notice("You unlock the settings of [src]."))
			else
				to_chat(usr, span_notice("Something went wrong with you attempting to lock or unlock the settings of [src]!"))

/obj/structure/bed/nest/advanced/user_buckle_mob(mob/living/buckling_mob, mob/living/user, check_loc = TRUE, silent, skip)
	if(skip)
		return ..()
	if(user.incapacitated() || !in_range(user, src) || buckling_mob.buckled)
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(ishuman(buckling_mob))
		var/mob/living/carbon/human/H = buckling_mob
		if(!TIMER_COOLDOWN_FINISHED(H, COOLDOWN_NEST))
			to_chat(user, span_warning("[H] was recently unbuckled. Wait a bit."))
			return FALSE

	user.visible_message(span_warning("[user] pins [buckling_mob] into [src], preparing the securing tentacles."),
	span_warning("[user] pins [buckling_mob] into [src], preparing the securing tentacles."))

	if(!do_mob(user, buckling_mob, 2 SECONDS, BUSY_ICON_HOSTILE))
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(!ishuman(buckling_mob))
		to_chat(user, span_warning("[buckling_mob] is not something we can capture."))
		return FALSE

	log_combat(user, buckling_mob, "nested", src)
	buckling_mob.visible_message(span_xenonotice("[user] coaxes the tentacles into securing [buckling_mob] into [src]!"),
		span_xenonotice("[user] coaxes [src]'s tentacles into trapping you in it and starting to breed you!"),
		span_notice("You hear squelching."))
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 50)

	silent = TRUE
	skip = TRUE
	return ..()

/obj/structure/bed/nest/advanced/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	. = ..()

/obj/structure/bed/nest/advanced/process()
	. = ..()
	if(!LAZYLEN(buckled_mobs))
		if(!COOLDOWN_FINISHED(src, tentacle_cooldown))
			return
		for(var/mob/living/carbon/human/target in loc)
			if(target.buckled)
				continue
			if(target.stat != DEAD)
				try_to_grab(target)
				continue
			if(HAS_TRAIT(target, TRAIT_PSY_DRAINED))
				continue
				//could maybe make it silo the corpse here instead
			else
				COOLDOWN_START(src, tentacle_cooldown, 29.9 SECONDS)
				src.visible_message(span_xenonotice("[src] starts using its tentacles to spin a cocoon around [target]!"))
				ASYNC

					/*
					//can't use do_after because we're not a mob and the corpse would fail due to being dead
					var/ok = TRUE
					var/datum/progressicon/busyicon = new(target, BUSY_ICON_DANGER)
					while(!COOLDOWN_FINISHED(src, tentacle_cooldown))
						stoplag(1)
						if(QDELETED(target))
							ok = FALSE
						if(target.loc != loc)
							ok = FALSE
						if(HAS_TRAIT(target, TRAIT_PSY_DRAINED))
							ok = FALSE
						if(target.stat != DEAD)
							ok = FALSE
						if(!ok)
							src.visible_message(span_xenonotice("[src] stops making a cocoon."))
							qdel(busyicon)
							return
					*/
					if(!do_mob(target, src, 30 SECONDS, null, BUSY_ICON_DANGER, PROGRESS_GENERIC, IGNORE_HAND | IGNORE_HELD_ITEM | IGNORE_DO_AFTER_COEFFICIENT | IGNORE_INCAPACITATION)  || HAS_TRAIT(target, TRAIT_PSY_DRAINED) || (target.stat != DEAD))
						src.visible_message(span_xenonotice("[src] stops making a cocoon."))
						return
					src.visible_message(span_xenonotice("[src] finishes using its tentacles to spin a cocoon around [target]!"))
					//qdel(busyicon)
					target.med_hud_set_status()
					ADD_TRAIT(target, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
					new /obj/structure/cocoon(get_turf(src), hivenumber, target)
			break
		return
	var/mob/living/carbon/human/victim = buckled_mobs[1]
	if(victim.stat == DEAD)
		unbuckle_mob(victim)
		return
	var/targetholename = "mouth"
	switch(targethole)
		if(2)
			targetholename = "ass"
		if(3)
			targetholename = "pussy"
	if(COOLDOWN_FINISHED(src, tentacle_cooldown))
		COOLDOWN_START(src, tentacle_cooldown, 29.9 SECONDS)
		if(!(victim.status_flags & XENO_HOST))
			victim.visible_message(span_xenonotice("[src] roughly thrusts a tentacle into [victim]'s [targetholename], a round bulge visibly sliding through it as it inserts an egg into [victim]!"),
			span_xenonotice("[src] roughly thrusts a tentacle into your [targetholename], a round bulge visibly sliding through it as it inserts an egg into you!"),
			span_notice("You hear squelching."))
			var/obj/item/alien_embryo/embryo = new(victim)
			embryo.hivenumber = hivenumber
			embryo.emerge_target = targethole
			embryo.emerge_target_flavor = targetholename
		else
			victim.visible_message(span_love("[src] roughly thrusts a tentacle into [victim]'s [targetholename]!"),
			span_love("[src] roughly thrusts a tentacle into your [targetholename]!"),
			span_love("You hear squelching."))
		//same medicines as larval growth sting, but no larva jelly
		if(victim.reagents.get_reagent_amount(/datum/reagent/medicine/tricordrazine) < 5)
			victim.reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 10)
		if(victim.reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline) < 5)
			victim.reagents.add_reagent(/datum/reagent/medicine/inaprovaline, 10)
		if(victim.reagents.get_reagent_amount(/datum/reagent/medicine/dexalin) < 5)
			victim.reagents.add_reagent(/datum/reagent/medicine/dexalin, 10)
		if(victim.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin) < 5)
			victim.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 1)
	else
		victim.visible_message(span_love("[src] roughly thrusts a tentacle into [victim]'s [targetholename]!"),
		span_love("[src] roughly thrusts a tentacle into your [targetholename]!"),
		span_love("You hear squelching."))

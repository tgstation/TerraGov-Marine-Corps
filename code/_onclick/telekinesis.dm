/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/

#define TK_MAXRANGE 15

/*
To add TK to a living mob, just make it register this proc on ranged attacks and enable the TK flag:
	RegisterSignal(src, COMSIG_MOB_ATTACK_RANGED, .proc/on_ranged_attack_tk)
	ENABLE_BITFIELD(living_flags, LIVING_TK_USER)
Redefine as needed.
*/
/mob/living/proc/on_ranged_attack_tk(mob/user, atom/target)
	target.attack_tk(user)


/atom/proc/attack_tk(mob/user)
	if(user.incapacitated() || !tkMaxRangeCheck(user, src))
		return FALSE
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	user.UnarmedAttack(src, FALSE) // attack_hand, attack_paw, etc
	add_fingerprint(user, "attack_tk")


/obj/attack_tk(mob/user)
	if(user.incapacitated())
		return FALSE
	if(anchored)
		return ..()
	attack_tk_grab(user)


/obj/item/attack_tk(mob/user)
	if(user.incapacitated())
		return FALSE
	attack_tk_grab(user)


/obj/proc/attack_tk_grab(mob/user)
	var/obj/item/tk_grab/O = new(src)
	O.tk_user = user
	if(O.focus_object(src))
		user.put_in_active_hand(O)
		add_fingerprint(user, "attack_tk_grab")


/mob/attack_tk(mob/user)
	return

/*
	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.

	It is used for manipulating things at range, for example, opening and closing closets.
	There are not a lot of defaults at this time, add more where appropriate.
*/

/atom/proc/attack_self_tk(mob/user)
	return


/obj/item/attack_self_tk(mob/user)
	attack_self(user)


/*
	TK Grab Item (the workhorse of old TK)

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby()
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic"
	icon = 'icons/obj/magic.dmi'
	icon_state = "2"
	flags_item = NOBLUDGEON | ITEM_ABSTRACT | DELONDROP
	w_class = WEIGHT_CLASS_GIGANTIC
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	var/atom/movable/focus = null
	var/mob/living/carbon/tk_user = null


/obj/item/tk_grab/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)


/obj/item/tk_grab/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()


/obj/item/tk_grab/process()
	if(check_if_focusable(focus)) //if somebody grabs your thing, no waiting for them to put it down and hitting them again.
		update_icon()


/obj/item/tk_grab/dropped(mob/user)
	if(focus && user && loc != user && loc != user.loc) // drop_item() gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.forceMove(loc)
	return ..()


//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(mob/user, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			return
		else
			qdel(src)


/obj/item/tk_grab/examine(user)
	if(focus)
		return focus.examine(user)
	return ..()


/obj/item/tk_grab/attack_self(mob/user)
	if(!focus)
		return
	if(QDELETED(focus))
		qdel(src)
		return
	focus.attack_self_tk(user)
	update_icon()


/obj/item/tk_grab/afterattack(atom/target, mob/living/carbon/user, proximity, params)//TODO: go over this
	. = ..()
	if(!target || !user)
		return

	if(!focus)
		focus_object(target)
		return
	else if(!check_if_focusable(focus))
		return

	if(target == focus)
		target.attack_self_tk(user)
		update_icon()
		return

	if(!isturf(target) && isitem(focus) && target.Adjacent(focus))
		apply_focus_overlay()
		var/obj/item/I = focus
		I.melee_attack_chain(tk_user, target, params) //isn't copying the attack chain fun. we should do it more often.
		if(check_if_focusable(focus))
			focus.do_attack_animation(target, null, focus)
	else
		apply_focus_overlay()
		focus.throw_at(target, 10, 1, user)
	user.changeNext_move(CLICK_CD_MELEE)
	update_icon()


/proc/tkMaxRangeCheck(mob/user, atom/target)
	var/d = get_dist(user, target)
	if(d > TK_MAXRANGE)
		to_chat(user, "<span class ='warning'>Your mind won't reach that far.</span>")
		return
	return TRUE


/obj/item/tk_grab/attack(mob/living/L, mob/living/user, def_zone)
	return


/obj/item/tk_grab/proc/focus_object(obj/target)
	if(!check_if_focusable(target))
		return FALSE
	focus = target
	update_icon()
	apply_focus_overlay()
	return TRUE


/obj/item/tk_grab/proc/check_if_focusable(obj/target)
	if(!istype(tk_user) || QDELETED(target) || !istype(target) || !CHECK_BITFIELD(tk_user.living_flags, LIVING_TK_USER))
		qdel(src)
		return FALSE
	if(!tkMaxRangeCheck(tk_user, target) || target.anchored || !isturf(target.loc))
		qdel(src)
		return FALSE
	return TRUE


/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	new /obj/effect/temp_visual/telekinesis(get_turf(focus))


/obj/item/tk_grab/update_icon()
	cut_overlays()
	if(!focus)
		return
	var/old_layer = focus.layer
	var/old_plane = focus.plane
	focus.layer = layer+0.01
	focus.plane = ABOVE_HUD_PLANE
	add_overlay(focus) //this is kind of ick, but it's better than using icon()
	focus.layer = old_layer
	focus.plane = old_plane
	

//===// Shrike TK Grab //===//


/obj/item/tk_grab/shrike
	var/grab_level = TKGRAB_NONLETHAL
	var/last_grab_change = 0 //Time
	var/last_life_tick = 0
	var/turf/starting_master_loc
	var/turf/starting_victim_loc
	var/datum/action/xeno_action/activable/psychic_choke/master_action


/obj/item/tk_grab/shrike/Initialize(mapload, mob/living/carbon/human/victim, xeno_action)
	var/mob/living/carbon/xenomorph/shrike/master = loc
	if(!istype(master) || QDELETED(victim) || !xeno_action || !master.put_in_hands(src))
		return INITIALIZE_HINT_QDEL

	master_action = xeno_action
	tk_user = master
	focus = victim
	starting_master_loc = get_turf(tk_user)
	starting_victim_loc = get_turf(victim)
	last_life_tick = victim.life_tick

	ENABLE_BITFIELD(victim.restrained_flags, RESTRAINED_PSYCHICGRAB)
	RegisterSignal(victim, list(COMSIG_LIVING_DO_RESIST, COMSIG_LIVING_DO_MOVE_RESIST), .proc/resisted_against)

	return ..() //Starts processing.


/obj/item/tk_grab/shrike/Destroy()
	if(focus)
		var/mob/living/carbon/human/victim = focus
		DISABLE_BITFIELD(victim.restrained_flags, RESTRAINED_PSYCHICGRAB)
		victim.SetStunned(0)
		victim.grab_resist_level = 0
		victim.update_canmove()
		focus = null
	
	if(master_action && master_action.psychic_hold == src)
		master_action.psychic_hold = null
		master_action = null

	starting_master_loc = null
	starting_victim_loc = null

	tk_user = null

	return ..() //Stops processing.


/obj/item/tk_grab/shrike/resisted_against(datum/source, mob/living/carbon/human/victim)
	if(victim.restrained(RESTRAINED_PSYCHICGRAB))
		return COMSIG_LIVING_RESIST_SUCCESSFUL
	if(victim.last_special >= world.time)
		return COMSIG_LIVING_RESIST_SUCCESSFUL
	victim.last_special = world.time + CLICK_CD_RESIST_PSYCHIC_GRAB

	var/mob/living/carbon/xenomorph/shrike/master = tk_user

	if(grab_level == TKGRAB_LETHAL && master.hive.living_xeno_ruler == master)
		to_chat(victim, "<span class='warning'>The grip is too strong, you are at its mercy!</span>")
		return COMSIG_LIVING_RESIST_SUCCESSFUL

	victim.visible_message("<span class='danger'>[victim] resists against the invisible force's grip!</span>")

	if(++victim.grab_resist_level < grab_level)
		return COMSIG_LIVING_RESIST_SUCCESSFUL

	playsound(victim.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
	victim.visible_message("<span class='danger'>[victim] has broken free of the invisible force's grip!</span>", null, null, 5)
	stop_psychic_grab()
	return COMSIG_LIVING_RESIST_SUCCESSFUL


/obj/item/tk_grab/shrike/proc/stop_psychic_grab()
	if(QDELETED(tk_user) || loc != tk_user)
		qdel(src)
		return
	tk_user.temporarilyRemoveItemFromInventory(src)


/obj/item/tk_grab/shrike/process()
	if(QDELETED(tk_user) || loc != tk_user)
		qdel(src)
		return FALSE
	
	if(QDELETED(focus))
		stop_psychic_grab()
		return FALSE

	var/mob/living/carbon/xenomorph/shrike/assailant = tk_user
	var/mob/living/carbon/human/victim = focus

	if(!assailant.check_state() || assailant.stagger || assailant.loc != starting_master_loc || victim.loc != starting_victim_loc || victim.stat == DEAD || isnestedhost(victim))
		stop_psychic_grab()
		return FALSE

	if(victim.life_tick <= last_life_tick) //One per life tick, no more.
		return FALSE

	switch(grab_level)
		if(TKGRAB_NONLETHAL)
			victim.SetStagger(4)
		if(TKGRAB_LETHAL)
			victim.SetStagger(2)
			victim.Losebreath(3)

	apply_focus_overlay()

	last_life_tick = victim.life_tick


/obj/item/tk_grab/shrike/proc/swap_psychic_grab()
	var/mob/living/carbon/xenomorph/shrike/assailant = tk_user
	var/mob/living/carbon/human/victim = focus //Typecasting merely for clarity, because it's free.

	if(last_grab_change + 3 SECONDS > world.time)
		return FALSE

	switch(grab_level)
		if(TKGRAB_NONLETHAL)
			if(assailant.action_busy)
				return FALSE
			if(!do_mob(assailant, victim, 2 SECONDS, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
				return FALSE
			grab_level = TKGRAB_LETHAL
			victim.SetKnockeddown(2)
			log_combat(assailant, victim, "psychically strangled", addition="(kill intent)")
			msg_admin_attack("[key_name(assailant)] psychically strangled (kill intent) [key_name(victim)]")
			to_chat(assailant, "<span class='danger'>We tighten our psychic grip on [victim]'s neck!</span>")
			victim.visible_message("<span class='danger'>The invisible force has tightened its grip on [victim]'s neck!</span>", null, null, 5)
			assailant.do_attack_animation(victim, "bite")
			playsound(victim,'sound/effects/blobattack.ogg', 75, 1)
		if(TKGRAB_LETHAL)
			grab_level = TKGRAB_NONLETHAL
			log_combat(assailant, victim, "neck grabbed")
			msg_admin_attack("[key_name(assailant)] grabbed the neck of [key_name(victim)]")
			to_chat(assailant, "<span class='warning'>We loosen our psychic grip on [victim]'s neck!</span>")
			victim.visible_message("<span class='warning'>The invisible force has loosened its grip on [victim]'s neck...</span>", null, null, 5)
			assailant.flick_attack_overlay(victim, "grab")
			playsound(victim,'sound/effects/magic.ogg', 75, 1)

	last_grab_change = world.time


/obj/item/tk_grab/shrike/afterattack(atom/target, mob/living/carbon/user, proximity, params)
	if(target != focus)
		return FALSE

	swap_psychic_grab()


/obj/item/tk_grab/shrike/attack_self(mob/user)
	swap_psychic_grab()


#undef TK_MAXRANGE
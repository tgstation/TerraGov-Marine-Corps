/// Chainsword & Chainsaw
/obj/item/weapon/twohanded/chainsaw
	name = "chainsaw"
	desc = "A chainsaw. Good for turning big things into little things."
	icon = 'icons/obj/items/weapons/misc.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	icon_state = "chainsaw_off"
	worn_icon_state = "chainsaw"
	attack_verb = list("gores", "tears", "rips", "shreds", "slashes", "cuts")
	force = 20
	force_activated = 75
	throwforce = 30
	attack_speed = 20
	w_class = WEIGHT_CLASS_NORMAL
	///icon when on
	var/icon_state_on = "chainsaw_on"
	///sprite on the mob when off but wielded
	var/worn_icon_state_w = "chainsaw_w"
	///sprite on the mob when on
	var/worn_icon_state_on = "chainsaw_on"
	///amount of fuel stored inside
	var/max_fuel = 50
	///amount of fuel used per hit
	var/fuel_used = 5
	///additional damage when weapon is active
	var/additional_damage = 75

/obj/item/weapon/twohanded/chainsaw/Initialize(mapload)
	. = ..()
	create_reagents(max_fuel, null, list(/datum/reagent/fuel = max_fuel))
	AddElement(/datum/element/strappable)

///handle icon change
/obj/item/weapon/twohanded/chainsaw/update_icon_state()
	. = ..()
	if(active)
		icon_state = icon_state_on
		return
	icon_state = initial(icon_state)

///handle worn_icon change
/obj/item/weapon/twohanded/chainsaw/update_item_state(mob/user)
	. = ..()
	if(active)
		worn_icon_state = worn_icon_state_on
		return
	if(CHECK_BITFIELD(item_flags, WIELDED)) //weapon is wielded but off
		worn_icon_state = worn_icon_state_w
		return
	worn_icon_state = initial(worn_icon_state)

///Proc to turn the chainsaw on or off
/obj/item/weapon/twohanded/chainsaw/proc/toggle_motor(mob/user)
	if(!active)
		force = initial(force)
		hitsound = initial(hitsound)
		balloon_alert(user, "the motor is dead!")
		update_icon()
		update_item_state()
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used)
		balloon_alert(user, "no fuel!")
		return
	force += additional_damage
	playsound(loc, 'sound/weapons/chainsawhit.ogg', 100, 1)
	hitsound = 'sound/weapons/chainsawhit.ogg'
	update_icon()
	update_item_state()

///Proc for the fuel cost and check and chainsaw noises
/obj/item/weapon/twohanded/chainsaw/proc/rip_apart(mob/user)
	if(!active)
		return
	reagents.remove_reagent(/datum/reagent/fuel, fuel_used)
	user.changeNext_move(attack_speed) //this is here because attacking object for some reason doesn't respect weapon attack speed
	if(reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used && active) //turn off the chainsaw after one last attack when fuel ran out
		playsound(loc, 'sound/items/weldingtool_off.ogg', 50)
		to_chat(user, span_warning("\The [src] shuts off, using last bits of fuel!"))
		active = FALSE
		toggle_motor(user)
		return
	if(prob(0.1)) // small chance for an easter egg of simpson chainsaw noises
		playsound(loc, 'sound/weapons/chainsaw_simpson.ogg', 60)
	else
		playsound(loc, 'sound/weapons/chainsawhit.ogg', 100, 1)

///Chainsaw give bump attack when picked up
/obj/item/weapon/twohanded/chainsaw/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

///Chainsaw turned off when dropped, and also lose bump attack
/obj/item/weapon/twohanded/chainsaw/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)
	if(!active)
		return
	active = FALSE
	toggle_motor(user)

///Chainsaw turn on when wielded
/obj/item/weapon/twohanded/chainsaw/wield(mob/user)
	. = ..()
	if(!.)
		return
	playsound(loc, 'sound/weapons/chainsawstart.ogg', 100, 1)
	toggle_active(FALSE)
	if(!do_after(user, SKILL_TASK_TRIVIAL, NONE, src, BUSY_ICON_DANGER, null,PROGRESS_BRASS))
		return
	toggle_active(TRUE)
	toggle_motor(user)

///Chainsaw turn off when unwielded
/obj/item/weapon/twohanded/chainsaw/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_motor(user)

/obj/item/weapon/twohanded/chainsaw/examine(mob/user)
	. = ..()
	. += "It contains [reagents.get_reagent_amount(/datum/reagent/fuel)]/[max_fuel] units of fuel!"

/obj/item/weapon/twohanded/chainsaw/attack(mob/living/carbon/M, mob/living/carbon/user)
	rip_apart(user)
	return ..()

///Handle chainsaw attack loop on object
/obj/item/weapon/twohanded/chainsaw/attack_obj(obj/target_object, mob/living/user)
	. = ..()
	if(!active)
		return

	if(user.do_actions)
		target_object.balloon_alert(user, "busy!")
		return TRUE

	if(user.incapacitated() || get_dist(user, target_object) > 1 || user.resting)  // loop attacking an adjacent object while user is not incapacitated nor resting, mostly here for the one handed chainsword
		return TRUE

	rip_apart(user)

	if(!do_after(user, src.attack_speed, NONE, target_object, BUSY_ICON_DANGER, null,PROGRESS_BRASS) || !active) //attack channel to loop attack, and second active check in case fuel ran out.
		return

	attack_obj(target_object, user)

/obj/item/weapon/twohanded/chainsaw/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is falling on the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return(BRUTELOSS)

/obj/item/weapon/twohanded/chainsaw/sword
	name = "chainsword"
	desc = "Cutting heretic and xenos never been easier"
	icon_state = "chainsword_off"
	icon_state_on = "chainsword_on"
	worn_icon_state = "chainsword"
	worn_icon_state_w = "chainsword_w"
	worn_icon_state_on = "chainsword_w"
	attack_speed = 12
	max_fuel = 150
	force = 60
	force_activated = 90
	additional_damage = 60

/// Allow the chainsword variant to be activated without being wielded
/obj/item/weapon/twohanded/chainsaw/sword/unique_action(mob/user)
	. = ..()
	if(CHECK_BITFIELD(item_flags, WIELDED))
		return
	playsound(loc, 'sound/machines/switch.ogg', 25)
	toggle_active()
	toggle_motor(user)

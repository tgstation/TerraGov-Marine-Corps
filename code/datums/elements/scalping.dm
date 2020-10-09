/datum/element/scalping/Attach(datum/target, _result)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/element/scalping/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/scalping/proc/on_attack(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER_DOES_SLEEP
	if(!isxeno(M) || (M.stat != DEAD))
		return NONE
	if(M.a_intent == INTENT_HARM)
		return NONE
	M.visible_message("<span class='notice'>[user] starts to tear into [M] with \the [source]</span>" ,"<span class='notice'>You start hacking away at [M] with \the [source]</span>")
	if(!do_after(user, 2 SECONDS, TRUE, M))
		return NONE
	M.visible_message("<span class='danger'>[user] brutally scalps [M]!</span>", "<span class='danger'> You brutally scalp [M] 	with \the [source]!</span>")
	var/obj/item/scalp/scalp = new(get_turf(M))
	scalp.name = M.name + "'s " + initial(scalp.name)
	return COMPONENT_ITEM_NO_ATTACK

/obj/item/scalp
	name = "scalp"
	desc = "The mutilated scalp of a slain xeno, proof of a great victory!"
	icon = 'icons/unused/Marine_research.dmi'
	icon_state = "chitin-chunk"
	w_class = WEIGHT_CLASS_TINY

/datum/element/scalping/Attach(datum/target, _result)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(_on_attack))

/datum/element/scalping/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/scalping/proc/_on_attack(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(on_attack), source, M, user)

/datum/element/scalping/proc/on_attack(datum/source, mob/living/M, mob/living/user)
	if(!isxeno(M) || (M.stat != DEAD))
		return NONE
	if(M.a_intent == INTENT_HARM)
		return NONE
	M.visible_message(span_notice("[user] starts to tear into [M] with \the [source]") ,span_notice("You start hacking away at [M] with \the [source]"))
	if(!do_after(user, 2 SECONDS, NONE, M))
		return NONE
	M.visible_message(span_danger("[user] brutally scalps [M]!"), span_danger(" You brutally scalp [M] 	with \the [source]!"))
	var/obj/item/scalp/scalp = new(get_turf(M))
	scalp.name = M.name + "'s " + initial(scalp.name)
	return COMPONENT_ITEM_NO_ATTACK

/obj/item/scalp
	name = "scalp"
	desc = "The mutilated scalp of a slain xeno, proof of a great victory!"
	icon = 'icons/unused/Marine_research.dmi'
	icon_state = "chitin-chunk"
	w_class = WEIGHT_CLASS_TINY

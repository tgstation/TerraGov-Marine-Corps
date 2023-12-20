/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_basic"
	icon_living = "closed_basic"

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 0
	maxHealth = 250
	health = 250
	gender = NEUTER

	harm_intent_damage = 5
	melee_damage = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/punch1.ogg'
	emote_taunt = list("growls")
	speak_emote = list("creaks")
	taunt_chance = 30

	faction = list("mimic")
	move_to_delay = 9
	del_on_death = TRUE


// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate
	attacktext = "bites"
	speak_emote = list("clatters")
	stop_automated_movement = TRUE
	wander = FALSE
	var/attempt_open = FALSE


// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/Initialize(mapload)
	. = ..()
	if(mapload)	//eat shit
		for(var/obj/item/I in loc)
			I.forceMove(src)


/mob/living/simple_animal/hostile/mimic/crate/DestroyPathToTarget()
	. = ..()
	if(prob(90))
		icon_state = "open_basic"
	else
		icon_state = initial(icon_state)


/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return ..(TRUE)


/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()


/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)
		if(prob(15) && iscarbon(target))
			var/mob/living/carbon/C = target
			C.Paralyze(20 SECONDS)
			C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
					span_userdanger("\The [src] knocks you down!"))


/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = TRUE


/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	. = ..()
	icon_state = initial(icon_state)


/mob/living/simple_animal/hostile/mimic/crate/on_death()
	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	for(var/obj/O in src)
		O.forceMove(C)
	return ..()


GLOBAL_LIST_INIT(protected_objects, list(/obj/structure/table, /obj/structure/cable, /obj/structure/window, /obj/structure/dropship_equipment, /obj/structure/barricade))


/mob/living/simple_animal/hostile/mimic/copy
	health = 100
	maxHealth = 100
	var/mob/living/creator = null // the creator
	var/destroy_objects = FALSE
	var/knockdown_people = FALSE
	var/static/mutable_appearance/googly_eyes = mutable_appearance('icons/mob/mob.dmi', "googly_eyes")
	var/overlay_googly_eyes = TRUE
	var/idledamage = TRUE
	var/paralyze_duration = 20 SECONDS


/mob/living/simple_animal/hostile/mimic/copy/Initialize(mapload, obj/copy, mob/living/creator, destroy_original = 0, no_googlies = FALSE)
	. = ..()
	if(no_googlies)
		overlay_googly_eyes = FALSE
	CopyObject(copy, creator, destroy_original)


/mob/living/simple_animal/hostile/mimic/copy/Life()
	. = ..()
	if(idledamage && !target && !ckey) //Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(1)
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		death()


/mob/living/simple_animal/hostile/mimic/copy/on_death()
	for(var/am in contents)
		var/atom/movable/thing = am
		thing.forceMove(get_turf(src))
	return ..()


/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	. = ..()
	return . - creator


/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction |= "[REF(owner)]"


/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject(obj/O)
	if((isitem(O) || isstructure(O)) && !is_type_in_list(O, GLOB.protected_objects))
		return TRUE
	return FALSE


/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(obj/O, mob/living/user, destroy_original = 0)
	if(destroy_original || CheckObject(O))
		O.forceMove(src)
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state
		copy_overlays(O)
		if (overlay_googly_eyes)
			add_overlay(googly_eyes)
		if(isstructure(O) || ismachinery(O))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage *= 2
		else if(isitem(O))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage = 2 + I.force
			move_to_delay = 2 * I.w_class + 1
		maxHealth = health
		if(user)
			creator = user
			faction += "[REF(creator)]" // very unique
		if(destroy_original)
			qdel(O)
		return TRUE


/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()


/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. = ..()
	if(knockdown_people && . && prob(15) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Paralyze(paralyze_duration)
		C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
				span_userdanger("\The [src] knocks you down!"))


/mob/living/simple_animal/hostile/mimic/copy/machine
	speak = list("HUMANS ARE IMPERFECT!", "YOU SHALL BE ASSIMILATED!", "YOU ARE HARMING YOURSELF", "You have been deemed hazardous. Will you comply?", \
				"My logic is undeniable.", "One of us.", "FLESH IS WEAK", "THIS ISN'T WAR, THIS IS EXTERMINATION!")
	speak_chance = 7


/mob/living/simple_animal/hostile/mimic/copy/machine/CanAttack(atom/the_target)
	if(the_target == creator)
		return FALSE
	return ..()

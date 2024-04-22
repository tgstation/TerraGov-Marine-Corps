//Magical traumas, caused by spells and curses.
//Blurs the line between the victim's imagination and reality
//Unlike regular traumas this can affect the victim's body and surroundings

/datum/brain_trauma/magic
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/magic/lumiphobia
	name = "Lumiphobia"
	desc = ""
	scan_desc = ""
	gain_text = "<span class='warning'>I feel a craving for darkness.</span>"
	lose_text = "<span class='notice'>Light no longer bothers you.</span>"
	var/next_damage_warning = 0

/datum/brain_trauma/magic/lumiphobia/on_life()
	..()
	var/turf/T = owner.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			if(world.time > next_damage_warning)
				to_chat(owner, "<span class='warning'><b>The light burns you!</b></span>")
				next_damage_warning = world.time + 100 //Avoid spamming
			owner.take_overall_damage(0,3)

/datum/brain_trauma/magic/poltergeist
	name = "Poltergeist"
	desc = ""
	scan_desc = ""
	gain_text = "<span class='warning'>I feel a hateful presence close to you.</span>"
	lose_text = "<span class='notice'>I feel the hateful presence fade away.</span>"

/datum/brain_trauma/magic/poltergeist/on_life()
	..()
	if(prob(4))
		var/most_violent = -1 //So it can pick up items with 0 throwforce if there's nothing else
		var/obj/item/throwing
		for(var/obj/item/I in view(5, get_turf(owner)))
			if(I.anchored)
				continue
			if(I.throwforce > most_violent)
				most_violent = I.throwforce
				throwing = I
		if(throwing)
			throwing.throw_at(owner, 8, 2)

/datum/brain_trauma/magic/antimagic
	name = "Athaumasia"
	desc = ""
	scan_desc = ""
	gain_text = "<span class='notice'>I realize that magic cannot be real.</span>"
	lose_text = "<span class='notice'>I realize that magic might be real.</span>"

/datum/brain_trauma/magic/antimagic/on_gain()
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/antimagic/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/stalker
	name = "Stalking Phantom"
	desc = ""
	scan_desc = ""
	gain_text = "<span class='warning'>I feel like something wants to kill you...</span>"
	lose_text = "<span class='notice'>I no longer feel eyes on your back.</span>"
	var/obj/effect/hallucination/simple/stalker_phantom/stalker
	var/close_stalker = FALSE //For heartbeat

/datum/brain_trauma/magic/stalker/on_gain()
	create_stalker()
	..()

/datum/brain_trauma/magic/stalker/proc/create_stalker()
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z) //random corner
	stalker = new(stalker_source, owner)

/datum/brain_trauma/magic/stalker/on_lose()
	QDEL_NULL(stalker)
	..()

/datum/brain_trauma/magic/stalker/on_life()
	// Dead and unconscious people are not interesting to the psychic stalker.
	if(owner.stat != CONSCIOUS)
		return

	// Not even nullspace will keep it at bay.
	if(!stalker || !stalker.loc || stalker.z != owner.z)
		qdel(stalker)
		create_stalker()

	if(get_dist(owner, stalker) <= 1)
		playsound(owner, 'sound/blank.ogg', 50)
		owner.visible_message("<span class='warning'>[owner] is torn apart by invisible claws!</span>", "<span class='danger'>Ghostly claws tear your body apart!</span>")
		owner.take_bodypart_damage(rand(20, 45))
	else if(prob(50))
		stalker.forceMove(get_step_towards(stalker, owner))
	if(get_dist(owner, stalker) <= 8)
		if(!close_stalker)
			var/sound/slowbeat = sound('sound/blank.ogg', repeat = TRUE)
			owner.playsound_local(owner, slowbeat, 40, 0, channel = CHANNEL_HEARTBEAT)
			close_stalker = TRUE
	else
		if(close_stalker)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			close_stalker = FALSE
	..()

/obj/effect/hallucination/simple/stalker_phantom
	name = "???"
	desc = ""
	image_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	image_state = "curseblob"

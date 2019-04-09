// These should all be procs, you can add them to humans/subspecies by
// species.dm's inherent_verbs ~ Z

/mob/living/carbon/human/proc/tackle()
	set category = "Abilities"
	set name = "Tackle"
	set desc = "Tackle someone down."

	if(last_special > world.time)
		return

	if(incapacitated() || lying || buckled)
		to_chat(src, "You cannot tackle someone in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/M in view(1,src))
		if(!istype(M,/mob/living/silicon) && Adjacent(M))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to tackle?") as null|anything in choices

	if(!T || !src || src.stat) return

	if(!Adjacent(T)) return

	if(last_special > world.time)
		return

	if(incapacitated() || lying || buckled)
		to_chat(src, "You cannot tackle in your current state.")
		return

	last_special = world.time + 50

	var/failed
	if(prob(75))
		T.KnockDown(rand(0.5,3))
	else
		src.KnockDown(rand(2,4))
		failed = 1

	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1)
	if(failed)
		src.KnockDown(rand(2,4))

	for(var/mob/O in viewers(src, null))
		if ((O.client && !( is_blind(O) )))
			O.show_message(text("<span class='danger'>[] [failed ? "tried to tackle" : "has tackled"] down []!</span>", src, T), 1)

/mob/living/carbon/human/proc/leap()
	set category = "Abilities"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	if(last_special > world.time)
		return

	if(incapacitated() || lying || buckled)
		to_chat(src, "You cannot leap in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/M in view(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") as null|anything in choices

	if(!T || !src || src.stat) return

	if(get_dist(get_turf(T), get_turf(src)) > 6) return

	if(last_special > world.time)
		return

	if(incapacitated() || lying || buckled)
		to_chat(src, "You cannot leap in your current state.")
		return

	last_special = world.time + 75
	status_flags |= LEAPING

	src.visible_message("<span class='warning'><b>\The [src]</b> leaps at [T]!</span>")
	src.throw_at(get_step(get_turf(T),get_turf(src)), 5, 1, src)
	playsound(src.loc, 'sound/voice/shriek1.ogg', 25, 1)

	sleep(5)

	if(status_flags & LEAPING) status_flags &= ~LEAPING

	if(!src.Adjacent(T))
		to_chat(src, "<span class='warning'>You miss!</span>")
		return

	T.KnockDown(5)

	if(T == src || T.anchored)
		return 0

	start_pulling(T)

/mob/living/carbon/human/proc/gut()
	set category = "Abilities"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(incapacitated(TRUE) || lying)
		to_chat(src, "<span class='warning'>You cannot do that in your current state.</span>")
		return

	var/obj/item/grab/G = locate() in src
	if(!G || !istype(G))
		to_chat(src, "<span class='warning'>You are not grabbing anyone.</span>")
		return

	if(usr.grab_level < GRAB_AGGRESSIVE)
		to_chat(src, "<span class='warning'>You must have an aggressive grab to gut your prey!</span>")
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> rips viciously at \the [G.grabbed_thing]'s body with its claws!</span>")

	if(istype(G.grabbed_thing,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = G.grabbed_thing
		H.apply_damage(50,BRUTE)
		if(H.stat == 2)
			H.gib()
	else
		var/mob/living/M = G.grabbed_thing
		if(!istype(M)) return //wut
		M.apply_damage(50,BRUTE)
		if(M.stat == 2)
			M.gib()

/mob/living/carbon/human/proc/commune()
	set category = "Abilities"
	set name = "Commune with creature"
	set desc = "Send a telepathic message to an unlucky recipient."

	var/target = null
	var/text = null

	target = input("Select a creature!", "Speak to creature", null, null) as null|anything in GLOB.mob_list

	if(!target) return

	text = input("What would you like to say?", "Speak to creature", null, null)

	text = trim(copytext(sanitize(text), 1, MAX_MESSAGE_LEN))

	if(!text) return

	var/mob/M = target

	if(isobserver(M) || M.stat == DEAD)
		to_chat(src, "Not even a [src.species.name] can speak to the dead.")
		return

	log_directed_talk(src, M, text, LOG_SAY, "telepathic commune")

	to_chat(M, "<span class='notice'>Like lead slabs crashing into the ocean, alien thoughts drop into your mind: [text]</span>")
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(is_species(H, species))
			return
		to_chat(H, "<span class='warning'>Your nose begins to bleed...</span>")
		H.drip(1)

/mob/living/carbon/human/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Abilities"

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_directed_talk(src, M, msg, LOG_SAY, "psychic whisper")
		to_chat(M, "<span class='green'> You hear a strange, alien voice in your head... \italic [msg]</span>")
		to_chat(src, "<span class='green'> You said: \"[msg]\" to [M]</span>")
	return

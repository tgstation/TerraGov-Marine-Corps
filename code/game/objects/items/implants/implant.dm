#define MALFUNCTION_TEMPORARY 1
#define MALFUNCTION_PERMANENT 2


/obj/item/implant
	name = "implant"
	icon_state = "implant"
	var/implanted = null
	var/mob/imp_in = null
	var/datum/limb/part = null
	var/implant_color= "b"
	var/allow_reagents = 0
	var/malfunction = 0
	embedding = list("embedded_flags" = EMBEDDEED_DEL_ON_HOLDER_DEL, "embed_process_chance" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)

	proc/trigger(emote, source as mob)
		return

	proc/activate()
		return

	// What does the implant do upon injection?
	// return 0 if the implant fails (ex. Revhead and loyalty implant.)
	// return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
	proc/implanted(mob/source, mob/user)
		return 1

	proc/get_data()
		return "No information available"

	proc/hear(message, mob/source)
		return

	proc/islegal()
		return 0

	proc/meltdown()	//breaks it down, making implant unrecongizible
		to_chat(imp_in, "<span class='warning'>You feel something melting inside [part ? "your [part.display_name]" : "you"]!</span>")
		if(part)
			part.take_damage_limb(0, 15)
		else
			var/mob/living/M = imp_in
			M.apply_damage(15,BURN)
		name = "melted implant"
		desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
		icon_state = "implant_melted"
		malfunction = MALFUNCTION_PERMANENT

	Destroy()
		if(part)
			part.implants.Remove(src)
		GLOB.implant_list -= src
		. = ..()

/obj/item/implant/Initialize()
	. = ..()
	GLOB.implant_list += src


/obj/item/implant/codex
	name = "codex implant"
	desc = "It has 'DON'T PANIC' embossed on the casing in friendly letters."

/obj/item/implant/codex/implanted(mob/source)
	. = ..()
	to_chat(usr, "<span class='notice'>You feel the brief sensation of having an entire encyclopedia at the tip of your tongue as the codex implant meshes with your nervous system.</span>")

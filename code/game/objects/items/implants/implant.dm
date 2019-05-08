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
		. = ..()

/obj/item/implant/loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such."

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Management Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected are marked as NT property and are subject to NT overwatch.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Marks the host as NT property and allow special monitoring functions.<BR>
<b>Special Features:</b> Will make the host more resistent to brainwashing techniques.<BR>
<b>Integrity:</b> Implant will last approximately ten years."}
		return dat

	implanted(mob/M)
		if(!ishuman(M))	return
		var/mob/living/carbon/human/H = M
		to_chat(H, "<span class='notice'>You are now tagged as a NT loyalist and will be monitored by their central headquarters. You retain your free will and mental faculties.</span>")
		return 1
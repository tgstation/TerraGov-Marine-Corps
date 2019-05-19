//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/circuitboard/computer/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || issilicon(usr))
			return

		opened = !opened
		if(opened)
			to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
		else
			to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
		return


	attackby(obj/item/O as obj, mob/user as mob)
		if (user.z > 6)
			to_chat(user, "<span class='danger'>Unable to establish a connection: You're too far away from the station!</span>")
			return
		if(istype(O, /obj/item/circuitboard/ai_module))
			var/obj/item/circuitboard/ai_module/M = O
			M.install(src)
		else
			..()


	attack_hand(var/mob/user as mob)
		if(src.machine_stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.machine_stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = select_active_ai(user)

		if (!src.current)
			to_chat(usr, "No active AIs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return
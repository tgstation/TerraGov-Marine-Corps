//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/prisoner
	name = "Prisoner Management"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "explosive"
	req_access = list(ACCESS_MARINE_BRIG)
	circuit = "/obj/item/circuitboard/computer/prisoner"
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed


/obj/machinery/computer/prisoner/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/prisoner/attack_paw(var/mob/user as mob)
	return


/obj/machinery/computer/prisoner/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_interaction(src)
	var/dat
	dat += "<BR>"
	if(screen == 0)
		dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		dat += "<HR>Chemical Implants<BR>"
		dat += "<b> ERROR SERVER OFFLINE <b>"
		dat += "<HR>Tracking Implants<BR>"
		dat += "<b> ERROR SERVER OFFLINE <b>"
		dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Prisoner Implant Manager System</div>", 400, 500)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "computer")


/obj/machinery/computer/prisoner/process()
	if(!..())
		src.updateDialog()
	return


/obj/machinery/computer/prisoner/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		usr.set_interaction(src)
		if(href_list["lock"])
			if(src.allowed(usr))
				screen = !screen
			else
				to_chat(usr, "Unauthorized Access.")

		else if(href_list["warn"])
			var/warning = copytext(sanitize(input(usr,"Message:","Enter your message here!","")),1,MAX_MESSAGE_LEN)
			if(!warning) return
			var/obj/item/implant/I = locate(href_list["warn"])
			if((I)&&(I.imp_in))
				var/mob/living/carbon/R = I.imp_in
				to_chat(R, "<span class='green'> You hear a voice in your head saying: '[warning]'</span>")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/robot/stun
	name = "electrified arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

	attack(mob/living/M as mob, mob/living/silicon/robot/user as mob)
		log_combat(user, M, "attacked", src)
		msg_admin_attack("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) used the [src.name] to attack [key_name(M)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[M]'>FLW</a>)")

		user.cell.charge -= 30

		playsound(M.loc, 'sound/weapons/Egloves.ogg', 25, 1, 4)
		M.KnockDown(5)
		if (M.stuttering < 5)
			M.stuttering = 5
		M.Stun(5)

		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message("<span class='danger'>[user] has prodded [M] with an electrically-charged arm!</span>", 1, "\red You hear someone fall", 2)

/obj/item/robot/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/robot/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/robot/sight/xray
	name = "\proper x-ray Vision"
	sight_mode = BORGXRAY


/obj/item/robot/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"
	icon = 'icons/obj/clothing/glasses.dmi'


/obj/item/robot/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/robot/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/robot/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"
	icon = 'icons/obj/clothing/glasses.dmi'

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health(src)
		return


/obj/item/robot/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"
	icon = 'icons/obj/clothing/glasses.dmi'

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/security(src)
		return

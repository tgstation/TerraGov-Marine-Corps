//antag spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/regular/spy
	desc = "Made by Nerd. Co's infiltration and surveillance department. Upon closer inspection, there's a small screen in each lens."
	var/obj/item/spy_bug/linked_bug

/obj/item/clothing/glasses/regular/spy/proc/show_to_user(mob/user)//this is the meat of it. most of the map_popup usage is in this.
	if(!user)
		return
	if(!user.client)
		return
	if(!linked_bug)
		user.audible_message(span_warning("[src] lets off a shrill beep!"))
	if("spypopup_map" in user.client.screen_maps) //alright, the popup this object uses is already IN use, so the window is open. no point in doing any other work here, so we're good.
		return
	user.client.setup_popup("spypopup", 3, 3, 2)
	linked_bug.cam_screen.display_to(user) // todo does not get removed
	linked_bug.update_view()

/obj/item/clothing/glasses/regular/spy/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_EYES)
		user.client.close_popup("spypopup")

/obj/item/clothing/glasses/regular/spy/dropped(mob/user)
	. = ..()
	user.client.close_popup("spypopup")

/obj/item/clothing/glasses/regular/spy/verb/activate_remote_view()
	//yada yada check to see if the glasses are in their eye slot
	if(ishuman(usr))
		var/mob/living/carbon/human/user = usr
		if(user.glasses == src)
			show_to_user(user)

/obj/item/clothing/glasses/regular/spy/Destroy()
	if(linked_bug)
		linked_bug.linked_glasses = null
		linked_bug = null
	return ..()


/obj/item/spy_bug
	name = "pocket protector"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	desc = "an advanced peice of espionage equipment in the shape of a pocket protector. it has a built in 360 degree camera for all your nefarious needs. Microphone not included."

	var/obj/item/clothing/glasses/regular/spy/linked_glasses
	var/atom/movable/screen/map_view/camera/cam_screen
	// Ranges higher than one can be used to see through walls.
	var/cam_range = 1
	var/datum/movement_detector/tracker

/obj/item/spy_bug/Initialize(mapload)
	. = ..()
	tracker = new /datum/movement_detector(src, CALLBACK(src, PROC_REF(update_view)))

	cam_screen = new
	cam_screen.generate_view("spypopup_map_[REF(src)]")

/obj/item/spy_bug/Destroy()
	if(linked_glasses)
		linked_glasses.linked_bug = null
	QDEL_NULL(cam_screen)
	QDEL_NULL(tracker)
	return ..()

/obj/item/spy_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_screen.vis_contents.Cut()
	for(var/turf/visible_turf in view(1,get_turf(src)))//fuck you usr
		cam_screen.vis_contents += visible_turf

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <i>cool</i> nerd glasses; with built-in displays to view a linked camera."

/obj/item/paper/fluff/nerddocs
	name = "Espionage For Dummies"
	color = "#FFFF00"
	desc = "An eye gougingly yellow pamphlet with a badly designed image of a detective on it. the subtext says \" The Latest way to violate privacy guidelines!\" "
	info = @{"

Thank you for your purchase of the Nerd Co SpySpeks <small>tm</small>, this paper will be your quick-start guide to violating the privacy of your crewmates in three easy steps!<br><br>Step One: Nerd Co SpySpeks <small>tm</small> upon your face. <br>
Step Two: Place the included "ProfitProtektor <small>tm</small>" camera assembly in a place of your choosing - make sure to make heavy use of it's inconspicous design!

Step Three: Press the "Activate Remote View" Button on the side of your SpySpeks <small>tm</small> to open a movable camera display in the corner of your vision, it's just that easy!<br><br><br><center><b>TROUBLESHOOTING</b><br></center>
My SpySpeks <small>tm</small> Make a shrill beep while attempting to use!

A shrill beep coming from your SpySpeks means that they can't connect to the included ProfitProtektor <small>tm</small>, please make sure your ProfitProtektor is still active, and functional!
	"}

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/regular/spy/newglasses = new(src)
	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug
	new /obj/item/paper/fluff/nerddocs(src)

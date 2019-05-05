/obj/item/pinpointer
    name = "pinpointer"
    icon_state = "pinoff"
    flags_atom = CONDUCT
    flags_equip_slot = ITEM_SLOT_BELT
    w_class = 1
    item_state = "electronic"
    throw_speed = 4
    throw_range = 20
    matter = list("metal" = 500)
    var/active = FALSE
    var/target = null

/obj/item/pinpointer/proc/set_target()
    if (issurvivorgamemode(SSticker.mode))
        target = input("Select the item you wish to track.", "Pinpointer") as null|anything in GLOB.gamemode_survivor_key_items
        if(!target)
            return
    
    var/obj/item/disk/nuclear/the_disk = locate()
    if(the_disk)
        target = the_disk

/obj/item/pinpointer/attack_self()
    if(!active)
        active = TRUE
        set_target()
        START_PROCESSING(SSobj, src)
        to_chat(usr, "<span class='notice'>You activate the pinpointer</span>")
    else
        active = FALSE
        STOP_PROCESSING(SSobj, src)
        icon_state = "pinoff"
        to_chat(usr, "<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/pinpointer/process()
    if(!active)
        STOP_PROCESSING(SSobj, src)
        return
    if(!target)
        icon_state = "pinonnull"
        active = FALSE
        return

    setDir(get_dir(src, target))
    switch(get_dist(src, target))
        if(0)
            icon_state = "pinondirect"
        if(1 to 8)
            icon_state = "pinonclose"
        if(9 to 16)
            icon_state = "pinonmedium"
        if(16 to INFINITY)
            icon_state = "pinonfar"

/obj/item/pinpointer/examine(mob/user)
    ..()
    for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
        if(bomb.timing)
            to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")


/obj/item/pinpointer/advpinpointer
    name = "Advanced Pinpointer"
    desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
    var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates, 2 to find an item

/obj/item/pinpointer/advpinpointer/set_target()
    if(mode == 0)
        var/obj/item/disk/nuclear/the_disk = locate()
        if(the_disk)
            target = the_disk
    if(mode == 1)
        if (!target)
            to_chat(usr, "<span class='notice'>\The [src] beeps, and turns off</span>")
            active = FALSE
            return
    if(mode == 2)
        // This never worked,
        to_chat(usr, "<span class='notice'>\The [src] beeps twice, and turns off</span>")
        active = FALSE
        return

/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
    set category = "Object"
    set name = "Toggle Pinpointer Mode"
    set src in view(1)

    active = 0
    icon_state = "pinoff"
    target = null

    switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
        if("Disk Recovery")
            mode = 0
            return attack_self()
        if("Location")
            mode = 1
            var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
            if(!locationx || !(usr in view(1,src)))
                return
            var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
            if(!locationy || !(usr in view(1,src)))
                return

            var/turf/Z = get_turf(src)
            target = locate(locationx,locationy,Z.z)

            to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")

            return attack_self()
        if("Other Signature")
            mode = 2
            return attack_self()

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "secure_closed_basic"
	icon_opened = "secure_open_basic"
	icon_locked = "secure_locked_basic"
	icon_unlocked = "secure_unlocked_basic"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	..()
	code = rand(min,max)
	var/loot = rand(1,30)
	switch(loot)
		if(1)
			new/obj/item/reagent_container/food/drinks/bottle/rum(src)
			new/obj/item/reagent_container/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/reagent_container/food/drinks/bottle/whiskey(src)
			new/obj/item/tool/lighter/zippo(src)
		if(2)
			new/obj/item/tool/pickaxe/drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space(src)
			new/obj/item/clothing/head/helmet/space(src)
		if(3)
			return
		if(4)
			new/obj/item/reagent_container/glass/beaker/bluespace(src)
		if(5 to 6)
			for(var/i = 0, i < 10, i++)
				new/obj/item/ore/diamond(src)
		if(7)
			return
		if(8)
			return
		if(9)
			for(var/i = 0, i < 3, i++)
				new/obj/machinery/portable_atmospherics/hydroponics(src)
		if(10)
			for(var/i = 0, i < 3, i++)
				new/obj/item/reagent_container/glass/beaker/noreact(src)
		if(11 to 13)
			new/obj/item/weapon/classic_baton(src)
		if(14)
			return
		if(15)
			for(var/i = 0, i < 7, i++)
				new/obj/item/clothing/tie/horrible(src)
		if(16)
			new/obj/item/clothing/under/shorts(src)
			new/obj/item/clothing/under/shorts/red(src)
			new/obj/item/clothing/under/shorts/blue(src)
		//Dummy crates start here.
		if(17 to 29)
			return
		//Dummy crates end here.
		if(30)
			new/obj/item/weapon/baton(src)

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	if(locked && ishuman(user))
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		var/input = input(usr, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as num
		if(in_range(src, user))
			input = CLAMP(input, 0, 10)
			if (input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = 0
				icon_state = icon_unlocked
			else if (input == null || input > max || input < min)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if (attempts == 0)
					to_chat(user, "<span class='danger'>The crate's anti-tamper system activates!</span>")
					var/turf/T = get_turf(src.loc)
					explosion(T, 0, 0, 0, 1)
					cdel(src)
					return
		else
			to_chat(user, "<span class='notice'>You attempt to interact with the device using a hand gesture, but it appears this crate is from before the DECANECT came out.</span>")
			return
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/card/emag))
			to_chat(user, "<span class='notice'>The crate unlocks!</span>")
			locked = 0
		if (istype(W, /obj/item/device/multitool))
			to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
			if (attempts == 1)
				to_chat(user, "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>")
			else
				to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts.</span>")
			if (lastattempt == null)
				to_chat(user, "<span class='notice'> has been made to open the crate thus far.</span>")
				return
			// hot and cold
			if (code > lastattempt)
				to_chat(user, "<span class='notice'>* Last access attempt lower than expected code.</span>")
			else
				to_chat(user, "<span class='notice'>* Last access attempt higher than expected code.</span>")
		else ..()
	else ..()

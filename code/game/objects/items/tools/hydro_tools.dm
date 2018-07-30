
// *************************************
// Hydroponics Tools
// *************************************

/obj/item/tool/plantspray
	icon = 'icons/obj/items/spray.dmi'
	item_state = "spray"
	flags_item = NOBLUDGEON
	flags_equip_slot = SLOT_WAIST
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/pest_kill_str = 0
	var/weed_kill_str = 0

/obj/item/tool/plantspray/weeds // -- Skie

	name = "weed-spray"
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon_state = "weedspray"
	weed_kill_str = 6

/obj/item/tool/plantspray/pests
	name = "pest-spray"
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon_state = "pestspray"
	pest_kill_str = 6

/obj/item/tool/plantspray/pests/old
	name = "bottle of pestkiller"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle16"

/obj/item/tool/plantspray/pests/old/carbaryl
	name = "bottle of carbaryl"
	icon_state = "bottle16"
	toxicity = 4
	pest_kill_str = 2

/obj/item/tool/plantspray/pests/old/lindane
	name = "bottle of lindane"
	icon_state = "bottle18"
	toxicity = 6
	pest_kill_str = 4

/obj/item/tool/plantspray/pests/old/phosmet
	name = "bottle of phosmet"
	icon_state = "bottle15"
	toxicity = 8
	pest_kill_str = 7



/obj/item/tool/weedkiller
	name = "bottle of weedkiller"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/weed_kill_str = 0

/obj/item/tool/weedkiller/triclopyr
	name = "bottle of glyphosate"
	icon_state = "bottle16"
	toxicity = 4
	weed_kill_str = 2

/obj/item/tool/weedkiller/lindane
	name = "bottle of triclopyr"
	icon_state = "bottle18"
	toxicity = 6
	weed_kill_str = 4

/obj/item/tool/weedkiller/D24
	name = "bottle of 2,4-D"
	icon_state = "bottle15"
	toxicity = 8
	weed_kill_str = 7




/obj/item/tool/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags_atom = FPRINT|CONDUCT
	flags_item = NOBLUDGEON
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	matter = list("metal" = 50)
	attack_verb = list("slashed", "sliced", "cut", "clawed")




//Hatchets and things to kill kudzu
/obj/item/tool/hatchet
	name = "hatchet"
	desc = "A sharp hand hatchet, commonly used to cut things apart, be it timber or other objects. Often found in the hands of woodsmen, scouts, and looters."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "hatchet"
	flags_atom = FPRINT|CONDUCT
	force = 25.0
	w_class = 2.0
	throwforce = 20.0
	throw_speed = 4
	throw_range = 4
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	matter = list("metal" = 15000)
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")

/obj/item/tool/hatchet/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()


/obj/item/tool/scythe
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "scythe"
	force = 13.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 3
	w_class = 4.0
	flags_atom = FPRINT|CONDUCT
	flags_item = NOSHIELD
	flags_equip_slot = SLOT_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/tool/scythe/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A, /obj/effect/plantsegment))
		for(var/obj/effect/plantsegment/B in orange(A,1))
			if(prob(80))
				cdel(B)
		cdel(A)







/obj/item/tool/bee_net
	name = "bee net"
	desc = "For catching rogue bees."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_net"
	item_state = "bedsheet"
	w_class = 3
	var/caught_bees = 0

/obj/item/tool/bee_net/attack_self(mob/user as mob)
	var/turf/T = get_step(get_turf(user), user.dir)
	for(var/mob/living/simple_animal/bee/B in T)
		if(B.feral < 0)
			caught_bees += B.strength
			cdel(B)
			user.visible_message("\blue [user] nets some bees.","\blue You net up some of the becalmed bees.")
		else
			user.visible_message("\red [user] swings at some bees, they don't seem to like it.","\red You swing at some bees, they don't seem to like it.")
			B.feral = 5
			B.target_mob = user

/obj/item/tool/bee_net/verb/empty_bees()
	set src in usr
	set name = "Empty bee net"
	set category = "Object"
	var/mob/living/carbon/M
	if(iscarbon(usr))
		M = usr

	while(caught_bees > 0)
		//release a few super massive swarms
		while(caught_bees > 5)
			var/mob/living/simple_animal/bee/B = new(src.loc)
			B.feral = 5
			B.target_mob = M
			B.strength = 6
			B.icon_state = "bees_swarm"
			caught_bees -= 6

		//what's left over
		var/mob/living/simple_animal/bee/B = new(src.loc)
		B.strength = caught_bees
		B.icon_state = "bees[B.strength]"
		B.feral = 5
		B.target_mob = M

		caught_bees = 0

/obj/item/queen_bee
	name = "queen bee packet"
	desc = "Place her into an apiary so she can get busy."
	icon = 'icons/obj/items/seeds.dmi'
	icon_state = "seed-kudzu"
	w_class = 1



/obj/item/beezeez
	name = "bottle of BeezEez"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

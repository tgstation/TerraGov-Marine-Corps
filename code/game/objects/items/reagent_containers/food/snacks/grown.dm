

// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/reagent_container/food/snacks/grown/
	var/plantname
	var/potency = -1
	icon = 'icons/obj/items/harvest.dmi'
	New(newloc,newpotency)
		if (!isnull(newpotency))
			potency = newpotency
		..()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/reagent_container/food/snacks/grown/New()
	..()

	//Handle some post-spawn var stuff.
	spawn(1)
		// Fill the object up with the appropriate reagents.
		if(!isnull(plantname))
			var/datum/seed/S = seed_types[plantname]
			if(!S || !S.chems)
				return

			potency = S.potency

			for(var/rid in S.chems)
				var/list/reagent_data = S.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				if(reagents)
					reagents.add_reagent(rid, max(1, rtotal))

		if(reagents.total_volume > 0)
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/reagent_container/food/snacks/grown/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	plantname = "corn"
	icon_state = "corn"
	potency = 40
	filling_color = "#FFEE00"
	trash = /obj/item/corncob

/obj/item/reagent_container/food/snacks/grown/cherries
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	filling_color = "#FF0000"
	gender = PLURAL
	plantname = "cherry"

/obj/item/reagent_container/food/snacks/grown/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	potency = 30
	filling_color = "#CC6464"
	plantname = "poppies"

/obj/item/reagent_container/food/snacks/grown/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten’d not thy breath.\""
	icon_state = "harebell"
	potency = 1
	filling_color = "#D4B2C9"
	plantname = "harebells"

/obj/item/reagent_container/food/snacks/grown/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	potency = 25
	filling_color = "#E6E8DA"
	plantname = "potato"

/obj/item/reagent_container/food/snacks/grown/potato/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(C.use(5))
			to_chat(user, "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>")
			var/obj/item/cell/potato/pocell = new /obj/item/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			cdel(src)
			return

/obj/item/reagent_container/food/snacks/grown/grapes
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	filling_color = "#A332AD"
	plantname = "grapes"

/obj/item/reagent_container/food/snacks/grown/greengrapes
	name = "bunch of green grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	potency = 25
	filling_color = "#A6FFA3"
	plantname = "greengrapes"

/obj/item/reagent_container/food/snacks/grown/peanut
	name = "peanut"
	desc = "Nuts!"
	icon_state = "peanut"
	filling_color = "857e27"
	potency = 25
	plantname = "peanut"

/obj/item/reagent_container/food/snacks/grown/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	potency = 25
	filling_color = "#A2B5A1"
	plantname = "cabbage"

/obj/item/reagent_container/food/snacks/grown/berries
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	filling_color = "#C2C9FF"
	plantname = "berries"

/obj/item/reagent_container/food/snacks/grown/plastellium
	name = "clump of plastellium"
	desc = "Hmm, needs some processing"
	icon_state = "plastellium"
	filling_color = "#C4C4C4"
	plantname = "plastic"

/obj/item/reagent_container/food/snacks/grown/shand
	name = "S'rendarr's Hand leaf"
	desc = "A leaf sample from a lowland thicket shrub. Smells strongly like wax."
	icon_state = "shand"
	filling_color = "#70C470"
	plantname = "shand"

/obj/item/reagent_container/food/snacks/grown/mtear
	name = "sprig of Messa's Tear"
	desc = "A mountain climate herb with a soft, cold blue flower, known to contain an abundance of healing chemicals."
	icon_state = "mtear"
	filling_color = "#70C470"
	plantname = "mtear"

/obj/item/reagent_container/food/snacks/grown/mtear/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/open/space))
		return
	var/obj/item/stack/medical/ointment/tajaran/poultice = new /obj/item/stack/medical/ointment/tajaran(user.loc)

	poultice.heal_burn = potency
	cdel(src)

	to_chat(user, "<span class='notice'>You mash the petals into a poultice.</span>")

/obj/item/reagent_container/food/snacks/grown/shand/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/open/space))
		return
	var/obj/item/stack/medical/bruise_pack/tajaran/poultice = new /obj/item/stack/medical/bruise_pack/tajaran(user.loc)

	poultice.heal_brute = potency
	cdel(src)

	to_chat(user, "<span class='notice'>You mash the leaves into a poultice.</span>")

/obj/item/reagent_container/food/snacks/grown/glowberries
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	var/light_on = 1
	var/brightness_on = 2 //luminosity when on
	filling_color = "#D3FF9E"
	icon_state = "glowberrypile"
	plantname = "glowberries"

/obj/item/reagent_container/food/snacks/grown/glowberries/Dispose()
	if(istype(loc,/mob))
		loc.SetLuminosity(round(-potency/5,1))
	. = ..()

/obj/item/reagent_container/food/snacks/grown/glowberries/pickup(mob/user)
	src.SetLuminosity(0)
	user.SetLuminosity(round((potency/5),1))

/obj/item/reagent_container/food/snacks/grown/glowberries/dropped(mob/user)
	user.SetLuminosity(-(round((potency/5),1)))
	src.SetLuminosity(round(potency/5,1))

/obj/item/reagent_container/food/snacks/grown/cocoapod
	name = "cocoa pod"
	desc = "Can be ground into cocoa powder."
	icon_state = "cocoapod"
	potency = 50
	filling_color = "#9C8E54"
	plantname = "cocoa"

/obj/item/reagent_container/food/snacks/grown/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	potency = 50
	filling_color = "#C0C9AD"
	plantname = "sugarcane"

/obj/item/reagent_container/food/snacks/grown/poisonberries
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	icon_state = "poisonberrypile"
	gender = PLURAL
	potency = 15
	filling_color = "#B422C7"
	plantname = "poisonberries"

/obj/item/reagent_container/food/snacks/grown/deathberries
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	icon_state = "deathberrypile"
	gender = PLURAL
	potency = 50
	filling_color = "#4E0957"
	plantname = "deathberries"

/obj/item/reagent_container/food/snacks/grown/ambrosiavulgaris
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	filling_color = "#125709"
	plantname = "ambrosia"

/obj/item/reagent_container/food/snacks/grown/ambrosiadeus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	potency = 10
	filling_color = "#229E11"
	plantname = "ambrosiadeus"

/obj/item/reagent_container/food/snacks/grown/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	potency = 15
	filling_color = "#DFE88B"
	plantname = "apple"

/obj/item/reagent_container/food/snacks/grown/apple/poisoned
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	potency = 15
	filling_color = "#B3BD5E"
	plantname = "poisonapple"

/obj/item/reagent_container/food/snacks/grown/goldapple
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	potency = 15
	filling_color = "#F5CB42"
	plantname = "goldapple"

/obj/item/reagent_container/food/snacks/grown/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	potency = 10
	filling_color = "#FA2863"
	slice_path = /obj/item/reagent_container/food/snacks/watermelonslice
	slices_num = 5
	plantname = "watermelon"

/obj/item/reagent_container/food/snacks/grown/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	potency = 10
	filling_color = "#FAB728"
	plantname = "pumpkin"

/obj/item/reagent_container/food/snacks/grown/pumpkin/attackby(obj/item/W as obj, mob/user as mob)
	if(W.sharp == IS_SHARP_ITEM_ACCURATE || W.sharp == IS_SHARP_ITEM_BIG)
		to_chat(user, "<span class='notice'>You carve a face into [src]!</span>")
		new /obj/item/clothing/head/pumpkinhead (user.loc)
		cdel(src)
	else
		return ..()

/obj/item/reagent_container/food/snacks/grown/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	potency = 20
	filling_color = "#28FA59"
	plantname = "lime"

/obj/item/reagent_container/food/snacks/grown/lemon
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	potency = 20
	filling_color = "#FAF328"
	plantname = "lemon"

/obj/item/reagent_container/food/snacks/grown/orange
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	potency = 20
	filling_color = "#FAAD28"
	plantname = "orange"

/obj/item/reagent_container/food/snacks/grown/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	potency = 15
	filling_color = "#FFFCCC"
	plantname = "whitebeet"

/obj/item/reagent_container/food/snacks/grown/banana
	name = "banana"
	desc = "It's an excellent prop for a comedy."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	filling_color = "#FCF695"
	trash = /obj/item/bananapeel
	plantname = "banana"

/obj/item/reagent_container/food/snacks/grown/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	plantname = "chili"

/obj/item/reagent_container/food/snacks/grown/eggplant
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	filling_color = "#550F5C"
	plantname = "eggplant"

/obj/item/reagent_container/food/snacks/grown/soybeans
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	filling_color = "#E6E8B7"
	icon_state = "soybeans"
	plantname = "soybean"

/obj/item/reagent_container/food/snacks/grown/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	filling_color = "#FF0000"
	potency = 10
	plantname = "tomato"

/obj/item/reagent_container/food/snacks/grown/tomato/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/tomato_smudge(src.loc)
	src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
	cdel(src)
	return

/obj/item/reagent_container/food/snacks/grown/killertomato
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	potency = 10
	filling_color = "#FF0000"
	potency = 30
	plantname = "killertomato"

/obj/item/reagent_container/food/snacks/grown/killertomato/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/open/space))
		return
	new /mob/living/simple_animal/tomato(user.loc)
	cdel(src)

	to_chat(user, "<span class='notice'>You plant the killer-tomato.</span>")

/obj/item/reagent_container/food/snacks/grown/bloodtomato
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	potency = 10
	filling_color = "#FF0000"
	plantname = "bloodtomato"

/obj/item/reagent_container/food/snacks/grown/bloodtomato/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/blood/splatter(src.loc)
	src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
	src.reagents.reaction(get_turf(hit_atom))
	for(var/atom/A in get_turf(hit_atom))
		src.reagents.reaction(A)
	cdel(src)
	return

/obj/item/reagent_container/food/snacks/grown/bluetomato
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	potency = 10
	filling_color = "#586CFC"
	plantname = "bluetomato"

/obj/item/reagent_container/food/snacks/grown/bluetomato/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/blood/oil(src.loc)
	src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
	src.reagents.reaction(get_turf(hit_atom))
	for(var/atom/A in get_turf(hit_atom))
		src.reagents.reaction(A)
	cdel(src)
	return

/obj/item/reagent_container/food/snacks/grown/bluetomato/Crossed(AM as mob|obj)
	if (iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.slip(name, 8, 5)

/obj/item/reagent_container/food/snacks/grown/wheat
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	filling_color = "#F7E186"
	plantname = "wheat"

/obj/item/reagent_container/food/snacks/grown/ricestalk
	name = "rice stalk"
	desc = "Rice to see you."
	gender = PLURAL
	icon_state = "rice"
	filling_color = "#FFF8DB"
	plantname = "rice"

/obj/item/reagent_container/food/snacks/grown/kudzupod
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	filling_color = "#59691B"
	plantname = "kudzu"

/obj/item/reagent_container/food/snacks/grown/icepepper
	name = "ice-pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	potency = 20
	filling_color = "#66CEED"
	plantname = "icechili"

/obj/item/reagent_container/food/snacks/grown/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	potency = 10
	filling_color = "#FFC400"
	plantname = "carrot"

/obj/item/reagent_container/food/snacks/grown/mushroom/reishi
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus believed to help relieve stress."
	icon_state = "reishi"
	potency = 10
	filling_color = "#FF4800"
	plantname = "reishi"

/obj/item/reagent_container/food/snacks/grown/mushroom/amanita
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	potency = 10
	filling_color = "#FF0000"
	plantname = "amanita"

/obj/item/reagent_container/food/snacks/grown/mushroom/angel
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	potency = 35
	filling_color = "#FFDEDE"
	plantname = "destroyingangel"

/obj/item/reagent_container/food/snacks/grown/mushroom/libertycap
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	potency = 15
	filling_color = "#F714BE"
	plantname = "libertycap"

/obj/item/reagent_container/food/snacks/grown/mushroom/plumphelmet
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	filling_color = "#F714BE"
	plantname = "plumphelmet"

/obj/item/reagent_container/food/snacks/grown/mushroom/walkingmushroom
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	filling_color = "#FFBFEF"
	potency = 30
	plantname = "walkingmushroom"

/obj/item/reagent_container/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/open/space))
		return
	new /mob/living/simple_animal/mushroom(user.loc)
	cdel(src)

	to_chat(user, "<span class='notice'>You plant the walking mushroom.</span>")

/obj/item/reagent_container/food/snacks/grown/mushroom/chanterelle
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	filling_color = "#FFE991"
	plantname = "mushrooms"

/obj/item/reagent_container/food/snacks/grown/mushroom/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark. Or does it?"
	icon_state = "glowshroom"
	filling_color = "#DAFF91"
	potency = 30
	plantname = "glowshroom"

/obj/item/reagent_container/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/open/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)

	planted.delay = 50
	planted.endurance = 100
	planted.potency = potency
	cdel(src)

	to_chat(user, "<span class='notice'>You plant the glowshroom.</span>")

/obj/item/reagent_container/food/snacks/grown/mushroom/glowshroom/Dispose()
	if(istype(loc,/mob))
		loc.SetLuminosity(round(-potency/10,1))
	. = ..()

/obj/item/reagent_container/food/snacks/grown/mushroom/glowshroom/pickup(mob/user)
	SetLuminosity(0)
	user.SetLuminosity(round((potency/10),1))

/obj/item/reagent_container/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	user.SetLuminosity(round(-(potency/10),1))
	SetLuminosity(round(potency/10,1))


// *************************************
// Complex Grown Object Defines -
// Putting these at the bottom so they don't clutter the list up. -Cheridan
// *************************************

/obj/item/reagent_container/food/snacks/grown/bluespacetomato
	name = "blue-space tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	potency = 20
	origin_tech = "bluespace=3"
	filling_color = "#91F8FF"
	plantname = "bluespacetomato"

/obj/item/reagent_container/food/snacks/grown/bluespacetomato/throw_impact(atom/hit_atom)
	..()
	var/mob/M = usr
	var/outer_teleport_radius = potency/10 //Plant potency determines radius of teleport.
	var/inner_teleport_radius = potency/15
	var/list/turfs = new/list()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	if(inner_teleport_radius < 1) //Wasn't potent enough, it just splats.
		new/obj/effect/decal/cleanable/blood/oil(src.loc)
		src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		cdel(src)
		return
	for(var/turf/T in orange(M,outer_teleport_radius))
		if(T in orange(M,inner_teleport_radius)) continue
		if(istype(T,/turf/open/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-outer_teleport_radius || T.x<outer_teleport_radius)	continue
		if(T.y>world.maxy-outer_teleport_radius || T.y<outer_teleport_radius)	continue
		turfs += T
	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in orange(M,outer_teleport_radius))
			if(!(T in orange(M,inner_teleport_radius)))
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	switch(rand(1,2))//Decides randomly to teleport the thrower or the throwee.
		if(1) // Teleports the person who threw the tomato.
			s.set_up(3, 1, M)
			s.start()
			new/obj/effect/decal/cleanable/molten_item(M.loc) //Leaves a pile of goo behind for dramatic effect.
			M.loc = picked //
			sleep(1)
			s.set_up(3, 1, M)
			s.start() //Two set of sparks, one before the teleport and one after.
		if(2) //Teleports mob the tomato hit instead.
			for(var/mob/A in get_turf(hit_atom))//For the mobs in the tile that was hit...
				s.set_up(3, 1, A)
				s.start()
				new/obj/effect/decal/cleanable/molten_item(A.loc) //Leave a pile of goo behind for dramatic effect...
				A.loc = picked//And teleport them to the chosen location.
				sleep(1)
				s.set_up(3, 1, A)
				s.start()
	new/obj/effect/decal/cleanable/blood/oil(src.loc)
	src.visible_message("<span class='notice'>The [src.name] has been squashed, causing a distortion in space-time.</span>","<span class='moderate'>You hear a splat and a crackle.</span>")
	cdel(src)
	return
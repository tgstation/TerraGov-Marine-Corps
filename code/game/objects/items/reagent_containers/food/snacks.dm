//Food items that are eaten normally and don't leave anything behind.
/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/items/food/food.dmi'
	icon_state = null
	var/bitesize = 1
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/package = FALSE
	center_of_mass = list("x"=15, "y"=15)
	var/list/tastes // for example list("crisps" = 2, "salt" = 1)

/obj/item/reagent_containers/food/snacks/create_reagents(max_vol, new_flags, list/init_reagents, data)
	if(!length(tastes) || !length(init_reagents))
		return ..()
	if(reagents)
		qdel(reagents)
	reagents = new (max_vol, new_flags)
	reagents.my_atom = WEAKREF(src)
	for(var/rid in init_reagents)
		var/amount = list_reagents[rid]
		if(rid == /datum/reagent/consumable/nutriment)
			reagents.add_reagent(rid, amount, tastes.Copy())
		else
			reagents.add_reagent(rid, amount, data)

/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/M)
	if(!usr)
		return

	if(reagents.total_volume)
		return

	balloon_alert_to_viewers("eats \the [src]")

	usr.dropItemToGround(src)	//so icons update :[

	if(trash)
		var/obj/item/T = new trash
		usr.put_in_hands(T)

	qdel(src)

/obj/item/reagent_containers/food/snacks/attack_self(mob/user as mob)
	return

/obj/item/reagant_containers/food/snacks/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(X)

/obj/item/reagent_containers/food/snacks/attack(mob/M, mob/user, def_zone)
	if(!reagents.total_volume)						//Shouldn't be needed but it checks to see if it has anything left in it.
		balloon_alert(user, "None of [src] left")
		M.dropItemToGround(src)	//so icons update :[
		qdel(src)
		return FALSE

	if(package)
		balloon_alert(user, "Can't, package still on")
		return FALSE

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/fullness = C.nutrition + (C.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 25)
		if(M == user)								//If you're eating it yourself
			var/mob/living/carbon/H = M
			if(ishuman(H) && (H.species.species_flags & ROBOTIC_LIMBS))
				balloon_alert(user, "can't eat food")
				return
			if (fullness <= 50)
				balloon_alert(user, "hungrily chews [src]")
			if (fullness > 50 && fullness <= 150)
				balloon_alert(user, "hungrily eats [src]")
			if (fullness > 150 && fullness <= 350)
				balloon_alert(user, "takes bite of [src]")
			if (fullness > 350 && fullness <= 550)
				balloon_alert(user, "unwillingly chews [src]")
			if (fullness > 550)
				balloon_alert(user, "cannot eat more of [src]")
				return FALSE
		else
			var/mob/living/carbon/H = M
			if(ishuman(H) && (H.species.species_flags & ROBOTIC_LIMBS))
				balloon_alert(user, "can't eat food")
				return
			if (fullness <= 550)
				balloon_alert_to_viewers("tries to feed [M]")
			else
				balloon_alert_to_viewers("tries to feed [M] but can't")
				return FALSE

			if(!do_after(user, 3 SECONDS, NONE, M, BUSY_ICON_FRIENDLY))
				return

			var/rgt_list_text = get_reagent_list_text()

			log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")

			balloon_alert_to_viewers("forces [M] to eat")


		if(reagents)								//Handle ingestion of the reagent.
			playsound(M.loc,'sound/items/eatfood.ogg', 15, 1)
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				if(reagents.total_volume > bitesize)
					/*
					* I totally cannot understand what this code supposed to do.
					* Right now every snack consumes in 2 bites, my popcorn does not work right, so I simplify it. -- rastaf0
					var/temp_bitesize = max(reagents.total_volume /2, bitesize)
					reagents.trans_to(M, temp_bitesize)
					*/
					//Why is bitesize used instead of an actual portion???
					record_reagent_consumption(bitesize, reagents.reagent_list, user, M)
					reagents.trans_to(M, bitesize)
				else
					record_reagent_consumption(reagents.total_volume, reagents.reagent_list, user, M)
					reagents.trans_to(M, reagents.total_volume)
				bitecount++
				On_Consume(M)
			return TRUE

	return FALSE

/obj/item/reagent_containers/food/snacks/afterattack(obj/target, mob/user, proximity)
	return ..()

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	. = ..()
	if (!(user in range(0)) && user != loc)
		return
	if (bitecount==0)
		return
	else if (bitecount==1)
		. += span_notice("\The [src] was bitten by someone!")
	else if (bitecount<=3)
		. += span_notice("\The [src] was bitten [bitecount] times!")
	else
		. += span_notice("\The [src] was bitten multiple times!")

/obj/item/reagent_containers/food/snacks/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/kitchen/utensil)) //todo early return
		var/obj/item/tool/kitchen/utensil/U = I

		if(!U.reagents)
			U.create_reagents(5)

		if(U.reagents.total_volume > 0)
			balloon_alert(user, "already something on [U]")
			return

		user.visible_message("[user] scoops up some [src] with \the [U]!", \
			span_notice("You scoop up some [src] with \the [U]!"))

		bitecount++
		U.overlays.Cut()
		U.loaded = "[src]"
		var/image/IM = new(U.icon, "loadedfood")
		IM.color = filling_color
		U.overlays += IM

		reagents.trans_to(U, min(reagents.total_volume, 5))

		if(reagents.total_volume <= 0)
			qdel(src)


/obj/item/reagent_containers/food/snacks/sliceable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp == IS_NOT_SHARP_ITEM)
		if(I.w_class >= WEIGHT_CLASS_SMALL)
			return
		if(!user.transferItemToLoc(I, src))
			return
		if(length(contents) > max_items)
			balloon_alert(user, "already full")
			return
		balloon_alert(user, "slips [I] inside")
		return

	if(!isturf(loc) || !(locate(/obj/structure/table) in loc))
		balloon_alert(user, "need a table or tray to slice")
		return

	balloon_alert_to_viewers("slices [src]")

	var/reagents_per_slice = reagents.total_volume / slices_num

	for(var/i in 1 to slices_num)
		var/obj/slice = new slice_path(loc)
		reagents.trans_to(slice,reagents_per_slice)

	qdel(src)
	return TRUE


/obj/item/reagent_containers/food/snacks/Destroy()
	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(iscorgi(M))
			var/mob/living/L = M
			if(bitecount == 0 || prob(50))
				M.emote("nibbles away at the [src]")
			bitecount++
			L.taste(reagents) //why should carbons get all the fun?
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where the [src] was")
				if(sattisfaction_text)
					M.emote("[sattisfaction_text]")
				qdel(src)
		if(ismouse(M))
			var/mob/living/simple_animal/mouse/N = M
			balloon_alert(N, "nibbles")
			N.taste(reagents) // ratatouilles
			if(prob(50))
				balloon_alert_to_viewers("nibbles")
			//N.emote("nibbles away at the [src]")
			N.health = min(N.health + 1, N.maxHealth)

////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////











//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/reagent_containers/food/snacks/burger/xeno			//Identification path for the object.
//	 name = "Xenoburger"												//Name that displays in the UI.
//	 desc = "Smells caustic. Tastes like heresy."						//Duh
//	 icon_state = "xburger"												//Refers to an icon in food.dmi
//	 list_reagents = list(/datum/reagent/consumable/nutriment = 2)			//This is what is in the food item. you may copy/paste
//	 tastes = list("dough" = 2, "heresy" = 1)							//This is the flavour of the food
//	 bitesize = 3														//This is the amount each bite consumes.


///obj/item/reagent_containers/food/snacks/burger/xeno/Initialize(mapload)		//Absolute pathing for procs, please.
//	 . = ..()															//Calls the parent proc, don't forget to add this.


/obj/item/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	icon_state = "honeycomb"
	desc = "Dripping with sugary sweetness."
	list_reagents = list(/datum/reagent/consumable/honey = 10, /datum/reagent/consumable/nutriment = 0.5, /datum/reagent/consumable/sugar = 2)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	icon = 'icons/obj/items/food/packaged.dmi'
	filling_color = "#7D5F46"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	tastes = list("candy" = 1)

/obj/item/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 3, /datum/reagent/medicine/tricordrazine = 1, /datum/reagent/iron = 5) //Honk
	bitesize = 2


/obj/item/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon = 'icons/obj/items/food/candy.dmi'
	icon_state = "candy_corn"
	filling_color = "#FFFCB0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 2)
	bitesize = 2
	tastes = list("candy corn" = 1)

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sodiumchloride = 1)
	tastes = list("salt" = 1, "crisps" = 1)

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	icon = 'icons/obj/items/food/confectionary.dmi'
	filling_color = "#DBC94F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("cookie" = 1)

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon = 'icons/obj/items/food/candy.dmi'
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/coco = 2)
	bitesize = 2
	tastes = list("chocolate" = 1)

/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon = 'icons/obj/items/food/candy.dmi'
	icon_state = "chocolateegg"
	filling_color = "#7D5F46"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/coco = 2)
	bitesize = 2
	tastes = list("chocolate" = 4, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "egg"
	filling_color = "#FDFFD1"
	var/egg_color
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.reaction(hit_atom, TOUCH)
	src.visible_message(span_warning(" [src.name] has been squashed."),span_warning(" You hear a smack."))
	qdel(src)

/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	egg_color = "blue"

/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	egg_color = "green"

/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	egg_color = "mime"

/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	egg_color = "orange"

/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	egg_color = "purple"

/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	egg_color = "rainbow"

/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	egg_color = "red"

/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	egg_color = "yellow"

/obj/item/reagent_containers/food/snacks/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#FFDF78"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	tastes = list("egg" = 4, "salt" = 1, "pepper" = 1)

/obj/item/reagent_containers/food/snacks/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "egg"
	filling_color = "#FFFFFF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "A small bag filled with some flour."
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "flour"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("chalky wheat" = 1)


/obj/item/reagent_containers/food/snacks/organ

	name = "organ"
	desc = "It's good for you."
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3


/obj/item/reagent_containers/food/snacks/organ/Initialize(mapload)
	list_reagents = list(/datum/reagent/consumable/nutriment = rand(3,5), /datum/reagent/toxin = rand(1,3))
	return ..()


/obj/item/reagent_containers/food/snacks/worm
	name = "worm"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "worm"
	desc = "A small worm. It looks a bit lonely."
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bitesize = 2
	tastes = list("dirt" = 1)
	attack_verb = list("touched")

/obj/item/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bitesize = 3
	tastes = list("tofu" = 1)

/obj/item/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "tofurkey"
	filling_color = "#FFFEE0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/toxin/sleeptoxin = 3)
	bitesize = 3
	tastes = list("tofu" = 3, "breadcrumbs" = 1)

/obj/item/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "stuffing"
	filling_color = "#C9AC83"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("breadcrumbs" = 3, "pepper" = 1)

/obj/item/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin/carpotoxin = 3)
	bitesize = 6
	tastes = list("fish" = 1)

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/toxin/carpotoxin = 3)
	bitesize = 3
	tastes = list("fish" = 1, "breadcrumbs" = 1)

/obj/item/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/psilocybin = 3)
	bitesize = 6
	tastes = list("mushroom" = 1)

/obj/item/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("tomato" = 1)
	bitesize = 6

/obj/item/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/toxin/sleeptoxin = 3)
	tastes = list("meat" = 1, "salmon" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/raw_lizard_sausage
	name = "raw Lizard blood sausage"
	desc = "A raw lizard blood sausage, ready to be cured on a drying rack."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "raw_lizard_sausage"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/blood = 3)
	tastes = list("meat" = 1, "black pudding" = 1)

/obj/item/reagent_containers/food/snacks/lizard_sausage
	name = "\improper Lizard blood sausage"
	desc = "A coarse dry-cured blood sausage, traditionally made from 100% organically sourced lizard."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "lizard_sausage"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("meat" = 1, "black pudding" = 1)

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "meatball"
	filling_color = "#DB0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("meat" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "sausage"
	filling_color = "#DB0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("meat" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon = 'icons/obj/items/food/confectionary.dmi'
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	var/warm = 0
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)

/obj/item/reagent_containers/food/snacks/donkpocket/proc/cooltime()
	if(warm)
		spawn( 4200 )
			if(!gc_destroyed) //not cdel'd
				warm = 0
				reagents.del_reagent(/datum/reagent/medicine/tricordrazine)
				name = "donk-pocket"

/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#FFF9A8"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("egg" = 1, "cheese" = 1)


/obj/item/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon = 'icons/obj/items/food/confectionary.dmi'
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("muffin" = 1)

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	bitesize = 2
	tastes = list("waffles" = 1)

/obj/item/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4D2F5E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("eggplant" = 3, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#B8E6B5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	bitesize = 2
	tastes = list("waffles" = 7, "people" = 1)

/obj/item/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#E6FA61"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	bitesize = 2
	tastes = list("waffles" = 7, "the colour green" = 1)

/obj/item/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("tender meat" = 3, "metal" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("meat" = 3, "metal" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("tofu" = 3, "metal" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/carpotoxin = 3, /datum/reagent/consumable/capsaicin = 3)
	tastes = list("fish" = 4, "batter" = 1, "hot peppers" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	icon = 'icons/obj/items/food/packaged.dmi'
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#FFFAD4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 0.1  //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	tastes = list("popcorn" = 3, "butter" = 1)


/obj/item/reagent_containers/food/snacks/popcorn/Initialize(mapload)
	. = ..()
	unpopped = rand(1,10)

/obj/item/reagent_containers/food/snacks/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(usr, span_warning("You bite down on an un-popped kernel!"))
		unpopped = max(0, unpopped-1)
	return ..()


/obj/item/reagent_containers/food/snacks/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	icon = 'icons/obj/items/food/packaged.dmi'
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sodiumchloride = 2)
	bitesize = 2
	tastes = list("dried meat" = 1)

/obj/item/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	icon = 'icons/obj/items/food/packaged.dmi'
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 4)
	tastes = list("dried raisins" = 1)

/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	icon = 'icons/obj/items/food/confectionary.dmi'
	desc = "Guaranteed to survive longer than you will."
	filling_color = "#FFE591"
	list_reagents = list(/datum/reagent/consumable/sugar = 4)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	icon = 'icons/obj/items/food/packaged.dmi'
	desc = "Bite sized cheesie snacks that will honk all over your mouth"
	trash = /obj/item/trash/cheesie
	filling_color = "#FFA305"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	bitesize = 2
	tastes = list("cheese" = 5, "crisps" = 2)

/obj/item/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#FF5D05"

	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/doctor_delight = 5)
	trash = /obj/item/trash/syndi_cakes
	bitesize = 3
	tastes = list("sweetness" = 3, "cake" = 1)

/obj/item/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9C7A68"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("nutriment" = 1)

/obj/item/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	bitesize = 2
	tastes = list("fries" = 3, "salt" = 1)

/obj/item/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#C4BF76"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 2
	tastes = list("soy" = 1)

/obj/item/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("fries" = 3, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon = 'icons/obj/items/food/confectionary.dmi'
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	trash = /obj/item/trash/fortunecookie
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bitesize = 2
	tastes = list("cookie" = 1)

/obj/item/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211F02"
	list_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/carbon = 3)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "meatsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	bitesize = 3
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#ADAC7F"
	var/monkey_type = /mob/living/carbon/human/species/monkey
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("the jungle" = 1, "bananas" = 1)

/obj/item/reagent_containers/food/snacks/monkeycube/examine(mob/user)
	. = ..()
	if(package)
		. += "It is wrapped in waterproof cellophane. Maybe using it in your hand would tear it off?"

/obj/item/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O,/obj/structure/sink) && !package)
		to_chat(user, "You place \the [name] under a stream of water...")
		user.drop_held_item()
		return Expand()
	return ..()

/obj/item/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(!package)
		return
	icon_state = "monkeycube"
	balloon_alert_to_viewers("unwraps [src]")
	package = FALSE

/obj/item/reagent_containers/food/snacks/monkeycube/On_Consume(mob/M)
	to_chat(M, span_warning("Something inside of you suddently expands!</span>"))
	balloon_alert_to_viewers("eats [src]", ignored_mobs = M)
	usr.dropItemToGround(src)
	if(!ishuman(M))
		return ..()
	//Do not try to understand.
	var/obj/item/surprise = new(M)
	var/mob/ook = monkey_type
	surprise.icon = initial(ook.icon)
	surprise.icon_state = initial(ook.icon_state)
	surprise.name = "malformed [initial(ook.name)]"
	surprise.desc = "Looks like \a very deformed [initial(ook.name)], a little small for its kind. It shows no signs of life."
	surprise.transform *= 0.6
	surprise.add_mob_blood(M)
	var/mob/living/carbon/human/H = M
	var/datum/limb/E = H.get_limb("chest")
	E.fracture()
	for (var/datum/internal_organ/I in E.internal_organs)
		I.take_damage(rand(I.min_bruised_damage, I.min_broken_damage+1))
	if (!E.hidden && prob(60)) //set it snuggly
		E.hidden = surprise
		E.cavity = 0
	else 		//someone is having a bad day
		E.createwound(CUT, 30)
		surprise.embed_into(M, E)
	qdel(src)

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	balloon_alert_to_viewers("expands")
	var/turf/T = get_turf(src)
	if(T)
		new monkey_type(T)
	qdel(src)


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	package = TRUE


/obj/item/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/species/monkey/farwa

/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/species/monkey/farwa


/obj/item/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/species/monkey/stok

/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/species/monkey/stok


/obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/species/monkey/naera
/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/species/monkey/naera

/obj/item/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5C3C11"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/drink/banana = 5, /datum/reagent/consumable/blackpepper = 1, /datum/reagent/consumable/sodiumchloride = 1)
	bitesize = 6
	tastes = list("the jungle" = 1, "banana" = 1)

/obj/item/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "baguette"
	filling_color = "#E3D796"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/blackpepper = 1, /datum/reagent/consumable/sodiumchloride = 1)
	bitesize = 3
	tastes = list("bread" = 1)

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "fishandchips"
	filling_color = "#E3D796"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/carpotoxin = 3)
	bitesize = 3
	tastes = list("fish" = 1, "chips" = 1)

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "Rohffle Waffles"
	desc = "Waffles from Rohffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/psilocybin = 8)
	bitesize = 4
	tastes = list("waffle" = 1, "mushrooms" = 1)

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("soy" = 1, "vegetables" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 2
	tastes = list("pasta" = 1)

/obj/item/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	bitesize = 3
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	desc = "A large soft pretzel full of POP!"
	icon = 'icons/obj/items/food/confectionary.dmi'
	icon_state = "poppypretzel"
	filling_color = "#AB7D2E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bitesize = 2
	tastes = list("pretzel" = 1)

/obj/item/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#FAA005"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/drink/carrotjuice = 3)
	bitesize = 2
	tastes = list("carrots" = 3, "salt" = 1)

/obj/item/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon = 'icons/obj/items/food/candy.dmi'
	icon_state = "candiedapple"
	filling_color = "#F21873"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 2)
	bitesize = 3
	tastes = list("carrots" = 3, "salt" = 1)

/obj/item/reagent_containers/food/snacks/twobreadold
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "twobread"
	filling_color = "#DBCC9A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 3
	tastes = list("bread" = 2)

/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon = 'icons/obj/items/food/food.dmi'
	icon_state = "mint"
	filling_color = "#F2F2F2"
	list_reagents = list(/datum/reagent/toxin/minttoxin = 1)

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bitesize = 2
	tastes = list("mushroom" = 1, "biscuit" = 1)

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize(mapload)
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/medicine/tricordrazine = 5)
	return ..()

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("custard" = 1)

/obj/item/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon = 'icons/obj/items/food/soupsalad.dmi'
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	bitesize = 3
	tastes = list("leaves" = 1, "vegetables" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon = 'icons/obj/items/food/soupsalad.dmi'
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	bitesize = 3
	tastes = list("leaves" = 1, "nutriment" = 1, "meat" = 1, "valids" = 1)

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.
/obj/item/reagent_containers/food/snacks/sliceable
	name = "sliceable food"
	bitesize = 1
	slices_num = 5
	var/max_items = 4

/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "cheesewheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#FFF700"
	tastes = list("cheese" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "cheesewedge"
	filling_color = "#FFF700"
	bitesize = 2
	tastes = list("cheese" = 1)

/obj/item/reagent_containers/food/snacks/baked_cheese
	name = "baked cheese wheel"
	desc = "A baked cheese wheel, melty and delicious."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "baked_cheese"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/nutriment = 5)
	tastes = list("cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/baked_cheese_platter
	name = "backed cheese platter"
	desc = "A baked cheese wheel: a favourite for sharing. Usually served with crispy bread slices for dipping, because the only thing better than good cheese is good cheese on bread."
	icon = 'icons/obj/items/food/cheeseandfries.dmi'
	icon_state = "baked_cheese_platter"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 12, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/nutriment = 8)
	tastes = list("cheese" = 1, "bread" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#FF3867"
	bitesize = 2
	tastes = list("watermelon" = 1)

/obj/item/reagent_containers/food/snacks/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	icon = 'icons/obj/items/food/mre.dmi'
	filling_color = "#F5DEB8"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("cracker" = 1)

// Flour + egg = dough
/obj/item/reagent_containers/food/snacks/flour/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/food/snacks/egg))
		new /obj/item/reagent_containers/food/snacks/dough(src)
		balloon_alert(user, "makes dough")
		qdel(I)
		qdel(src)

// Egg + flour = dough
/obj/item/reagent_containers/food/snacks/egg/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/food/snacks/flour))
		new /obj/item/reagent_containers/food/snacks/dough(src)
		balloon_alert(user, "makes dough")
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(user, span_notice("The egg refuses to take on this color!"))
			return

		to_chat(user, span_notice("You color \the [src] [clr]"))
		icon_state = "egg-[clr]"
		egg_color = clr

/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "dough"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 2
	tastes = list("dough" = 1)

// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/snacks/sliceable/flatdough(src)
		balloon_alert(user, "flattens dough")
		qdel(src)

// slicable into 3xdoughslices
/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	slices_num = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("dough" = 1)

/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("dough" = 1)

/obj/item/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	icon = 'icons/obj/items/food/meat.dmi'
	max_integrity = 180
	filling_color = "#FF1C1C"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/meat/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/kitchen/knife))
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		balloon_alert(user, "cuts meat into strips")
		qdel(src)

/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/reagent_containers/food/snacks/meat/human
	desc = "A slab of meat. Looks kinda like pork..."

/obj/item/reagent_containers/food/snacks/meat/xeno
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	tastes = list("meat" = 1, "acid" = 1)
	bitesize = 6

/obj/item/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/obj/item/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/kitchen/knife))
		new /obj/item/reagent_containers/food/snacks/rawmeatball(src)
		new /obj/item/reagent_containers/food/snacks/rawmeatball(src)
		new /obj/item/reagent_containers/food/snacks/rawmeatball(src)
		balloon_alert(user, "cuts and rolls strips into balls")
		qdel(src)


/obj/item/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("meat" = 1)


/obj/item/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/items/food/meat.dmi'
	icon_state = "raw_meatball"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)

/obj/item/reagent_containers/food/snacks/rawmeatball/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meatball, rand(40 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon = 'icons/obj/items/food/food.dmi'
	icon_state = "hotdog"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("bun" = 3, "meat" = 2)

/obj/item/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "flatbread"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)


/obj/item/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("potatoes" = 3, "salt" = 1)

/obj/item/reagent_containers/food/snacks/packaged_burrito
	name = "Packaged Burrito"
	desc = "A hard microwavable burrito. There's no time given for how long to cook it. Packaged by the Nanotrasen Corporation."
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "burrito"
	bitesize = 2
	package = TRUE
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("tortilla" = 2, "beans" = 2)

/obj/item/reagent_containers/food/snacks/packaged_burrito/attack_self(mob/user as mob)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		balloon_alert(user, "unwraps burrito")
		package = FALSE
		icon = 'icons/obj/items/food/mexican.dmi'
		icon_state = "openburrito"

/obj/item/reagent_containers/food/snacks/packaged_hdogs
	name = "Packaged Hotdog"
	desc = "A singular squishy, room temperature, hot dog. There's no time given for how long to cook it, so you assume its probably good to go. Packaged by the Nanotrasen Corporation."
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "hot_dogs"
	bitesize = 2
	package = TRUE
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sodiumchloride = 2)
	tastes = list("dough" = 1, "chicken" = 1)

/obj/item/reagent_containers/food/snacks/packaged_hdogs/attack_self(mob/user as mob)
	if (package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		balloon_alert(user, "unwraps hotdog")
		package = FALSE
		icon = 'icons/obj/items/food/food.dmi'
		icon_state = "hotdog"

/obj/item/reagent_containers/food/snacks/upp
	name = "\improper USL ration"
	desc = "A sealed, freeze-dried, compressed package containing a single item of food. Commonplace in the USL pirate band and even those who live on Mars, especially those stationed on far-flung colonies. This one is was packaged in 2415."
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "upp_ration"
	bitesize = 2
	package = TRUE
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sodiumchloride = 0.5)
	var/variation = null


/obj/item/reagent_containers/food/snacks/upp/Initialize(mapload)
	if(!variation)
		variation = pick("fish","rice")

	switch(variation)
		if("fish")
			tastes = list("dried [pick("carp", "shark", "tuna", "fish")]" = 1, "[pick("potatoes", "borsch", "borshch", "bortsch", "hardtack")]" = 1)
		if("rice")
			tastes = list("[pick("rice", "rye", "starch")]" = 1, "[pick("sawdust", "beans", "chicken")]" = 1)

	return ..()

/obj/item/reagent_containers/food/snacks/upp/attack_self(mob/user as mob)
	if (package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		balloon_alert(user, "pops the packaged seal")
		package = FALSE
		desc = "An extremely dried item of food, with little flavoring or coloration. Looks to be prepped for long term storage, but will expire without the packaging. Best to eat it now to avoid waste. At least things are equal."
		switch(variation)
			if("fish")
				name = "rationed fish"
				icon_state = "upp_1"
			if("rice")
				name = "rationed rice"
				icon_state = "upp_2"

/obj/item/reagent_containers/food/snacks/upp/fish
	name = "\improper UPP ration (fish)"
	variation = "fish"

/obj/item/reagent_containers/food/snacks/upp/rice
	name = "\improper UPP ration (cereal)"
	variation = "rice"

/obj/item/reagent_containers/food/snacks/enrg_bar
	name = "EnrG Bar"
	desc = "A calorie-dense bar made with ingredients with unpronounceable names. Somehow, even the packaging is edible."
	icon = 'icons/obj/items/food/packaged.dmi'
	icon_state = "energybar"
	bitesize = 2
	w_class = WEIGHT_CLASS_TINY
	trash = /obj/item/trash/eat
	//no taste, default to "something indescribable"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)


/obj/item/reagent_containers/food/snacks/kepler_crisps
	name = "Kepler Crisps"
	desc = "'They're disturbingly good!' Now with 0% trans fat."
	icon_state = "kepler"
	bitesize = 2
	trash = /obj/item/trash/kepler
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sodiumchloride = 1)
	tastes = list("chips" = 2)

//Wrapped candy bars

/obj/item/reagent_containers/food/snacks/wrapped
	package = TRUE
	bitesize = 3
	icon = 'icons/obj/items/food/packaged.dmi'
	var/obj/item/trash/wrapper = null //Why this and not trash? Because it pulls the wrapper off when you unwrap it as a trash item.

/obj/item/reagent_containers/food/snacks/wrapped/attack_self(mob/user as mob)
	if (package)
		balloon_alert(user, "opens the package")
		playsound(loc,'sound/effects/pageturn2.ogg', 15, 1)

		new wrapper (user.loc)
		icon_state = "[initial(icon_state)]-o"
		package = FALSE


/obj/item/reagent_containers/food/snacks/wrapped/booniebars
	name = "Boonie Bars"
	desc = "Two delicious bars of minty chocolate. <i>\"Sometimes things are just... out of reach.\"</i>"
	icon_state = "boonie"
	bitesize = 2 //Two bars
	wrapper = /obj/item/trash/boonie
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/coco = 4)
	tastes = list("peppermint" = 3, "falling into the sun" = 1)

/obj/item/reagent_containers/food/snacks/wrapped/chunk
	name = "CHUNK box"
	desc = "A bar of \"The <b>CHUNK</b>\" brand chocolate. <i>\"The densest chocolate permitted to exist according to federal law. We are legally required to ask you not to use this blunt object for anything other than nutrition.\"</i>"
	icon_state = "chunk"
	force = 35 //LEGAL LIMIT OF CHOCOLATE
	bitesize = 3
	wrapper = /obj/item/trash/chunk
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/coco = 10)
	tastes = list("compressed matter" = 1)

/obj/item/reagent_containers/food/snacks/wrapped/barcardine
	name = "Barcardine Bars"
	desc = "A bar of chocolate, it smells like the medical bay. <i>\"Chocolate always helps the pain go away.\"</i>"
	icon_state = "barcardine"
	wrapper = /obj/item/trash/barcardine
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/coco = 2, /datum/reagent/medicine/tramadol = 1, /datum/reagent/medicine/tramadol = 1)
	tastes = list ("cough syrup" = 1)

/obj/item/reagent_containers/food/snacks/wrapped/berrybar
	name = "Berry Bars"
	desc = "Berry-licious bars! These are a new invention from the world health association for outer-rim colonies. <i>\"Bit of berry to keep the bars away!\"</i>"
	icon_state = "berrybar"
	wrapper = /obj/item/trash/berrybar
	list_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/drink/berryjuice = 1,
		/datum/reagent/medicine/tramadol = 10,
		/datum/reagent/medicine/bicaridine = 10,
		/datum/reagent/medicine/kelotane = 10,
		/datum/reagent/medicine/tricordrazine = 10,
	)
	tastes = list("delicious processed berries" = 1)
	bitesize = 9

/obj/item/reagent_containers/food/snacks/wrapped/proteinbar
	name = "Protein Bar"
	desc = "A chocolate protein bar, made of dense unused food materials that couldn't find a home in another recipe."
	icon_state = "proteinbar"
	force = 10 //dense enough to hurt but less than chunk
	wrapper = /obj/item/trash/candy
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/coco = 2)
	tastes = list("compressed matter" = 3, "discarded rubber" = 1)

//MREs

/obj/item/reagent_containers/food/snacks/packaged_meal
	name = "\improper MRE component"
	package = TRUE
	bitesize = 4
	icon_state = "entree"
	icon = 'icons/obj/items/food/mre.dmi'
	var/flavor = "boneless pork ribs"//default value


/obj/item/reagent_containers/food/snacks/packaged_meal/Initialize(mapload, newflavor)
	tastes = list("[pick(SSstrings.get_list_from_file("names/food_adjectives"))]" = 1) //idea, list, gimmick
	determinetype(newflavor)
	desc = "A packaged [icon_state] from a Meal Ready-to-Eat, there is a lengthy list of [pick("obscure", "arcane", "unintelligible", "revolutionary", "sophisticated", "unspellable")] ingredients and addictives printed on the back.</i>"
	return ..()

/obj/item/reagent_containers/food/snacks/packaged_meal/attack_self(mob/user as mob)
	if (package)
		balloon_alert(user, "opens package")
		playsound(loc,'sound/effects/pageturn2.ogg', 15, 1)
		name = "\improper" + flavor
		desc = "The contents of a standard issue MRE. This one is " + flavor + "."
		icon_state = flavor
		package = FALSE

/obj/item/reagent_containers/food/snacks/packaged_meal/proc/determinetype(newflavor)
	name = "\improper MRE component" + " (" + newflavor + ")"
	flavor = newflavor

	switch(newflavor)
		if("boneless pork ribs", "grilled chicken", "pizza square", "spaghetti", "chicken tenders")
			icon_state = "entree"
			list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/sodiumchloride = 1)
		if("meatballs", "cheese spread", "beef turnover", "mashed potatoes")
			icon_state = "side"
			list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/sodiumchloride = 1)
		if("biscuit", "pretzels", "peanuts", "cracker")
			icon_state = "snack"
			list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/sodiumchloride = 1)
		if("spiced apples", "chocolate brownie", "sugar cookie", "choco bar", "crayon")
			icon_state = "dessert"
			list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/sugar = 1)


/obj/item/reagent_containers/food/snacks/lollipop
	name = "lollipop"
	desc = "A delicious lollipop."
	icon = 'icons/obj/items/lollipop.dmi'
	icon_state = "lollipop_stick"
	item_state = "lollipop_stick"
	flags_equip_slot = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 4)
	tastes = list("candy" = 1)
	var/mutable_appearance/head
	var/headcolor = rgb(0, 0, 0)
	var/succ_int = 100
	var/next_succ = 0
	var/mob/living/carbon/owner

/obj/item/reagent_containers/food/snacks/lollipop/Initialize(mapload)
	. = ..()
	head = mutable_appearance('icons/obj/items/lollipop.dmi', "lollipop_head")
	change_head_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))

//makes lollipops actually wearable as masks and still edible the old fashioned way.
/obj/item/reagent_containers/food/snacks/lollipop/proc/handle_reagents()
	var/fraction = min(FOOD_METABOLISM/reagents.total_volume, 1)
	reagents.reaction(owner, INGEST, fraction)
	if(!reagents.trans_to(owner, FOOD_METABOLISM))
		reagents.remove_any(FOOD_METABOLISM)

/obj/item/reagent_containers/food/snacks/lollipop/process()
	if(!owner)
		stack_trace("lollipop processing without an owner")
		return PROCESS_KILL
	if(!reagents)
		stack_trace("lollipop processing without a reagents datum")
		return PROCESS_KILL
	if(owner.stat == DEAD)
		return PROCESS_KILL
	if(!reagents.total_volume)
		qdel(src)
		return
	if(next_succ <= world.time)
		handle_reagents()
		next_succ = world.time + succ_int

/obj/item/reagent_containers/food/snacks/lollipop/equipped(mob/user, slot)
	. = ..()
	if(!iscarbon(user))
		return
	if(slot != SLOT_WEAR_MASK)
		owner = null
		STOP_PROCESSING(SSobj, src) //equipped is triggered when moving from hands to mouth and vice versa
		return
	owner = user
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/lollipop/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/food/snacks/lollipop/proc/change_head_color(C)
	headcolor = C
	cut_overlay(head)
	head.color = C
	add_overlay(head)

//med pop
/obj/item/reagent_containers/food/snacks/lollipop/tramadol
	name = "Tram-pop"
	desc = "Your reward for behaving so well in the medbay. Can be eaten or put in the mask slot."
	list_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/medicine/tramadol = 4)
	tastes = list("cough syrup" = 1, "artificial sweetness" = 1)

/obj/item/reagent_containers/food/snacks/lollipop/tramadol/combat
	desc = "A lolipop devised after realizations that a massive amount of marines end up with a crippling opiod addiction, meant to fight against that. Whether it works or not is up to you, really. Can be eaten or put in the mask slot"
	list_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/medicine/tramadol = 10)
	tastes = list("cough syrup" = 1, "artificial sweetness" = 1)

/obj/item/reagent_containers/food/snacks/lollipop/combat
	name = "Commed-pop"
	desc = "A lolipop devised to heal wounds overtime by mixing sugar with bicard and kelotane, with a slower amount of reagent use. Can be eaten or put in the mask slot"
	list_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/medicine/bicaridine = 5, /datum/reagent/medicine/kelotane = 5)

/obj/item/reagent_containers/food/snacks/lollipop/tricord
	name = "Tricord-pop"
	desc = "A lolipop laced with tricordrazine, a slow healing reagent. Can be eaten or put in the mask slot."
	list_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/medicine/tricordrazine = 10)
	tastes = list("cough syrup" = 1, "artificial sweetness" = 1)

////////////////////////////////////////////DONK POCKETS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	w_class = WEIGHT_CLASS_SMALL
/obj/item/reagent_containers/food/snacks/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/tricordrazine = 6)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)

//donkpockets

/obj/item/reagent_containers/food/snacks/donkpocket/dankpocket
	name = "\improper Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	list_reagents = list(/datum/reagent/space_drugs = 3, /datum/reagent/consumable/nutriment = 4)
	tastes = list("meat" = 2, "dough" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/spicy
	name = "\improper Spicy-pocket"
	desc = "The classic snack food, now with a heat-activated spicy flair."
	icon_state = "donkpocketspicy"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/capsaicin = 2)
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/spicy
	name = "warm Spicy-pocket"
	desc = "The classic snack food, now maybe a bit too spicy."
	icon_state = "donkpocketspicy"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/tricordrazine = 2, /datum/reagent/consumable/capsaicin = 5)
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/teriyaki
	name = "\improper Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack."
	icon_state = "donkpocketteriyaki"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/soysauce = 2)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/teriyaki
	name = "warm Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack, now steamy and warm."
	icon_state = "donkpocketteriyaki"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/medicine/tricordrazine = 2, /datum/reagent/consumable/soysauce = 2)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/pizza
	name = "\improper Pizza-pocket"
	desc = "Delicious, cheesy and surprisingly filling."
	icon_state = "donkpocketpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/drink/tomatojuice = 2)
	tastes = list("meat" = 2, "dough" = 2, "cheese"= 2)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/pizza
	name = "warm Pizza-pocket"
	desc = "Delicious, cheesy, and even better when hot."
	icon_state = "donkpocketpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/tricordrazine = 2, /datum/reagent/consumable/drink/tomatojuice = 2)
	tastes = list("meat" = 2, "dough" = 2, "melty cheese"= 2)

/obj/item/reagent_containers/food/snacks/donkpocket/honk
	name = "\improper Honk-pocket"
	desc = "The award-winning donk-pocket that won the hearts of clowns and humans alike."
	icon_state = "donkpocketbanana"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/banana = 4)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/honk
	name = "warm Honk-pocket"
	desc = "The award-winning donk-pocket, now warm and toasty."
	icon_state = "donkpocketbanana"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/tricordrazine = 2, /datum/reagent/consumable/drink/banana = 4, /datum/reagent/consumable/laughter = 6)
	tastes = list("dough" = 2, "children's antibiotics" = 1)

/obj/item/reagent_containers/food/snacks/donkpocket/berry
	name = "\improper Berry-pocket"
	desc = "A relentlessly sweet donk-pocket first created for use in Operation Dessert Storm."
	icon_state = "donkpocketberry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/berryjuice = 3)
	tastes = list("dough" = 2, "jam" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/berry
	name = "warm Berry-pocket"
	desc = "A relentlessly sweet donk-pocket, now warm and delicious."
	icon_state = "donkpocketberry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/tricordrazine = 2, /datum/reagent/consumable/drink/berryjuice = 3)
	tastes = list("dough" = 2, "warm jam" = 2)

/obj/item/reagent_containers/food/snacks/donkpocket/gondola
	name = "\improper Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least." //Only a monster would craft this.
	icon_state = "donkpocketgondola"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)

/obj/item/reagent_containers/food/snacks/donkpocket/warm/gondola
	name = "warm Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least."
	icon_state = "donkpocketgondola"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/tricordrazine = 2)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)

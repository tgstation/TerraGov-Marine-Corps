

// Surgery Tools
/obj/item/tool/surgery
	icon = 'icons/obj/items/surgery_tools.dmi'
	attack_speed = 11 //Used to be 4 which made them attack insanely fast.

/*
* Retractor
*/
/obj/item/tool/surgery/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon_state = "retractor"
	matter = list("metal" = 10000, "glass" = 5000)
	flags_atom = CONDUCT
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"

/*
* Hemostat
*/
/obj/item/tool/surgery/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon_state = "hemostat"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = CONDUCT
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")

/*
* Cautery
*/
/obj/item/tool/surgery/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon_state = "cautery"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = CONDUCT
	w_class = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")

/*
* Surgical Drill
*/
/obj/item/tool/surgery/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	matter = list("metal" = 15000, "glass" = 10000)
	flags_atom = CONDUCT
	force = 15.0
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

/obj/item/tool/surgery/surgicaldrill/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is pressing the [name] to [user.p_their()] [pick("temple","chest")] and activating it! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS)

/*
* Scalpel
*/
/obj/item/tool/surgery/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon_state = "scalpel"
	flags_atom = CONDUCT
	force = 10.0
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	w_class = 1
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 10000, "glass" = 5000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/tool/surgery/scalpel/suicide_act(mob/user)
	user.visible_message(pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/*
* Researchable Scalpels
*/
/obj/item/tool/surgery/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"

/obj/item/tool/surgery/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0

/obj/item/tool/surgery/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0

/obj/item/tool/surgery/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5

/*
* Circular Saw
*/
/obj/item/tool/surgery/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags_atom = CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 20000,"glass" = 10000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

//misc, formerly from code/defines/weapons.dm
/obj/item/tool/surgery/bonegel
	name = "bone gel"
	icon_state = "bone-gel"
	force = 0
	w_class = 2.0
	throwforce = 1.0

/obj/item/tool/surgery/FixOVein
	name = "FixOVein"
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=3"
	w_class = 2.0
	var/usage_amount = 10

/obj/item/tool/surgery/bonesetter
	name = "bone setter"
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = 2.0
	attack_verb = list("attacked", "hit", "bludgeoned")
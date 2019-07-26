//FOB in a BOX

/obj/machinery/vending/fobbox
	name = "FOB IN A BOX"
	desc = "Every thing you need to build the FOB of your dreams. And plenty of it!"
	products = list(
					/obj/item/storage/box/sentry = 50,
					/obj/item/ammo_magazine/sentry = 50,
					/obj/item/storage/box/minisentry = 50,
					/obj/item/ammo_magazine/minisentry = 50,
					/obj/item/storage/box/m56d_hmg = 50,
					/obj/item/ammo_magazine/m56d = 50,
					/obj/item/cell/infinite = 50,
					/obj/item/storage/box/m94 = 50,
					/obj/item/storage/box/explosive_mines = 50,
					/obj/item/stack/sheet/metal/large_stack = 50,
					/obj/item/stack/sheet/plasteel/large_stack = 50,
					/obj/item/stack/barbed_wire/full = 50,
					/obj/item/stack/razorwire/full = 50,
					/obj/item/storage/belt/utility/full = 50,
					/obj/item/book/skillbook = 50
					)

/obj/item/book/skillbook
	name = "Skill Book (max construction)"
	dat = ""
	unique = TRUE   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	title = "A book of Skill"		 // The real name of the book.

/obj/item/book/skillbook/attack_self(mob/user as mob)
	to_chat(user, "This book is full of magic knowledge that makes you good at building things!")
	user.mind.cm_skills.engineer = SKILL_ENGINEER_MT
	user.mind.cm_skills.construction = SKILL_CONSTRUCTION_MASTER
	to_chat(user, "It's so good that you've already learned everything!")

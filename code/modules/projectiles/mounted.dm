//Machine to hold a deployed gun. It aquired nearly all of its variables from the gun itself.
/obj/machinery/mounted

	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = FALSE
	max_integrity = 100
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)
	hud_possible = list(MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)

	///Gun that does almost all the work when deployed. This type should not exist with a null 'gun'
	var/obj/item/weapon/gun/gun

	///Flags inhereted from the deployed gun to determin if it can be picked up, or rotated.
	var/deploy_flags

	///Icon that is default to this gun, used to replace usage of initial(icon_state) since that does not default back to what the icon_state this gun is deployed with
	var/default_icon
	///Icon state for when the gun has no ammo.
	var/icon_empty
	//this is amount of tiles we shift our vision towards guns direction when operated, currently its max is 7
	var/view_tile_offset = 3

/obj/machinery/mounted/Initialize()
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)

///generates the icon based on how much ammo it has.
/obj/machinery/mounted/update_icon_state() 

	if(!gun.current_mag)
		icon_state = icon_empty
	else
		icon_state = default_icon
	hud_set_machine_health()
	hud_set_gun_ammo()

///Handles variable transfer from the gun, to the machine.
/obj/machinery/mounted/proc/deploy(obj/item/weapon/gun/new_gun, direction)
	if(istype(new_gun.current_mag, /obj/item/ammo_magazine/internal) || istype(new_gun, /obj/item/weapon/gun/launcher))
		stack_trace("[new_gun] has been deployed, however it is incompatible because of either an internal magazine, or it is a launcher.")
		return
	gun = new_gun
	gun.forceMove(src)

	deploy_flags = gun.deploy_flags
	obj_integrity = gun.deploy_integrity
	max_integrity = gun.deploy_max_integrity
	view_tile_offset = gun.deploy_view_offset

	name = gun.deploy_name ? gun.deploy_name : gun.name

	desc = gun.deploy_desc ? gun.deploy_desc : gun.desc

	icon = gun.deploy_icon ? gun.deploy_icon : gun.icon

	default_icon = gun.deploy_icon_state ? gun.deploy_icon_state : gun.icon_state

	icon_empty = gun.deploy_icon_empty ? gun.deploy_icon_empty : icon_state

	gun.deployed = TRUE

	setDir(direction)
	update_icon_state()

///Handles dissasembly
/obj/machinery/mounted/proc/disassemble(mob/user)
	if(deploy_flags & DEPLOYED_NO_PICKUP)
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	to_chat(user, "<span class='notice'>You begin disassembling [src].</span>")
	if(!do_after(user, gun.deploy_time, TRUE, src, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")

	user.unset_interaction()
	gun.deployed = FALSE
	gun.deploy_integrity = obj_integrity

	user.put_in_active_hand(gun)
	gun = null

	qdel(src)

///Makes sure we clean our trash
/obj/machinery/mounted/Destroy()
	if(gun)
		qdel(gun)
		gun = null
	if(operator)
		operator.unset_interaction()
	. = ..()

///Left in from old TL-102 code
/obj/machinery/mounted/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE) // Those Ayy lmaos.
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_M56)
	return ..()

///Update health hud when damage is taken
/obj/machinery/mounted/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	hud_set_machine_health()

///This is called when a user tries to operate the gun
/obj/machinery/mounted/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(human_user.interactee == src) //If your already using the gun, and click on it again to exit
		human_user.unset_interaction()
		visible_message("[icon2html(src, viewers(src))] <span class='notice'>[human_user] decided to let someone else have a go. </span>",
			"<span class='notice'>You decided to let someone else have a go on the [src] </span>")
		return TRUE
	if(get_step(src, REVERSE_DIR(dir)) != human_user.loc) //cant man the gun from the barrels side
		to_chat(human_user, "<span class='warning'>You should be behind [src] to man it!</span>")
		return TRUE
	if(operator) //If there is already a operator then they're manning it.
		if(!operator.interactee)
			stack_trace("/obj/machinery/mounted/interact called by user [human_user] with an operator with a null interactee: [operator].")
			operator = null //this shouldn't happen, but just in case
		to_chat(human_user, "<span class='warning'>Someone's already controlling it.</span>")
		return TRUE
	if(human_user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
		to_chat(human_user, "<span class='warning'>You're already busy!</span>")
		return TRUE
	if(issynth(human_user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(human_user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
		return TRUE

	visible_message("[icon2html(src, viewers(src))] <span class='notice'>[human_user] mans the [src]!</span>",
		"<span class='notice'>You man the gun!</span>")

	operator = human_user

	return ..()

/obj/machinery/mounted/examine(mob/user) //Let us see how much ammo we got in this thing.
	. = ..()
	gun.examine(user)

/obj/machinery/mounted/attackby(obj/item/I, mob/user, params) //This handles reloading the gun, if its in acid cant touch it.
	. = ..()

	if(!ishuman(user))
		return

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	reload(user, I)

///Repairs gun
/obj/machinery/mounted/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	repair_damage(120)
	update_icon_state()
	return TRUE

///Reloads gun
/obj/machinery/mounted/proc/reload(mob/user, ammo_magazine)
	if(!istype(ammo_magazine, /obj/item/ammo_magazine))
		return

	var/obj/item/ammo_magazine/ammo = ammo_magazine
	
	if(istype(gun, ammo.gun_type))

		if(ammo.current_rounds <= 0)
			to_chat(user, "<span class='warning'>[ammo] is empty!</span>")
			return

		if(gun.current_mag)
			gun.unload(user,0,1)
			update_icon_state()

		var/tac_reload_time = max(0.5 SECONDS, 1.5 SECONDS - user.skills.getRating("firearms") * 5)
		if(!do_after(user, tac_reload_time, TRUE, ammo_magazine))
			return
	
		gun.reload(user, ammo_magazine)
		update_icon_state()

///Sets the user as manning the internal gun
/obj/machinery/mounted/on_set_interaction(mob/user)
	. = ..()
	operator = user
	update_view(operator)
	gun.manned(operator)

///Unsets the user from manning the internal gun
/obj/machinery/mounted/on_unset_interaction(mob/user)
	if(user.client)
		user.client.change_view(WORLD_VIEW)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
	operator = null
	if(gun)
		gun.un_man()

///makes sure you can see and or use the gun
/obj/machinery/mounted/check_eye(mob/user)
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()

///Drag the gun onto you to fold it.
/obj/machinery/mounted/MouseDrop(over_object, src_location, over_location) 
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		disassemble(user)

///Updates view, sets max zoom distance to 7
/obj/machinery/mounted/proc/update_view(mob/user)
	if(view_tile_offset > 7)
		stack_trace("[src] has its view_tile offset set higher than 7, please don't.")

	user.client.change_view(WORLD_VIEW)
	var/view_offset = view_tile_offset * 32
	switch(dir)
		if(NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = view_offset
		if(SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -1 * view_offset
		if(EAST)
			user.client.pixel_x = view_offset
			user.client.pixel_y = 0
		if(WEST)
			user.client.pixel_x = -1 * view_offset
			user.client.pixel_y = 0

//Mapbound version, it is initialized directly so it requires a gun to be set with it.
/obj/machinery/mounted/hsg_nest
	gun = /obj/item/weapon/gun/mounted/hsg_nest

/obj/machinery/mounted/hsg_nest/Initialize()
	. = ..()
	deploy(new gun(), SOUTH)

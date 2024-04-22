/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = ""

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/mob/living/simple_animal/bot/ed209")

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = FALSE //if set to TRUE, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = TRUE //if set to TRUE, each new object is summoned on a new spawn point

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

	var/cast_sound = 'sound/blank.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets,mob/user = usr)
	playsound(get_turf(user), cast_sound, 50,TRUE)
	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T

	for(var/i=0,i<summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type = pick(summon_type)
		var/spawn_place = pick(targets)
		if(summon_ignore_prev_spawn_points)
			targets -= spawn_place
		if(ispath(summoned_object_type, /turf))
			var/turf/O = spawn_place
			var/N = summoned_object_type
			O.ChangeTurf(N, flags = CHANGETURF_INHERIT_AIR)
		else
			var/atom/summoned_object = new summoned_object_type(spawn_place)

			for(var/varName in newVars)
				if(varName in newVars)
					summoned_object.vv_edit_var(varName, newVars[varName])
			summoned_object.flags_1 |= ADMIN_SPAWNED_1
			if(summon_lifespan)
				QDEL_IN(summoned_object, summon_lifespan)

			post_summon(summoned_object, user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/proc/post_summon(atom/summoned_object, mob/user)
	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm //test purposes - Also a lot of fun
	name = "Dispense Wizard Justice"
	desc = ""
	summon_type = list(/mob/living/simple_animal/bot/secbot/ed209)
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 2, "remote_disabled" = 1,"shoot_sound" = 'sound/blank.ogg',"projectile" = /obj/projectile/beam/laser, "declare_arrests" = 0,"name" = "Wizard's Justicebot")

/obj/effect/proc_holder/spell/aoe_turf/conjure/linkWorlds
	name = "Link Worlds"
	desc = ""
	invocation = "WTF"
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/spawner/nether)
	summon_amt = 1
	range = 1
	cast_sound = 'sound/blank.ogg'

/obj/effect/proc_holder/spell/targeted/conjure_item
	name = "Summon weapon"
	desc = ""
	invocation_type = "none"
	include_user = TRUE
	range = -1
	clothes_req = FALSE
	var/obj/item/item
	var/item_type = /obj/item/banhammer
	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	var/delete_old = TRUE //TRUE to delete the last summoned object if it's still there, FALSE for infinite item stream weeeee

/obj/effect/proc_holder/spell/targeted/conjure_item/cast(list/targets, mob/user = usr)
	if (delete_old && item && !QDELETED(item))
		QDEL_NULL(item)
	else
		for(var/mob/living/carbon/C in targets)
			if(C.dropItemToGround(C.get_active_held_item()))
				C.put_in_hands(make_item(), TRUE)

/obj/effect/proc_holder/spell/targeted/conjure_item/Destroy()
	if(item)
		qdel(item)
	return ..()

/obj/effect/proc_holder/spell/targeted/conjure_item/proc/make_item()
	item = new item_type
	return item

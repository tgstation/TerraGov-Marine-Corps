/*

Usage:
Override /Run() to run your test code

Call TEST_FAIL() to fail the test (You should specify a reason)

You may use /New() and /Destroy() for setup/teardown respectively

You can use the run_loc_floor_bottom_left and run_loc_floor_top_right to get turfs for testing

*/

GLOBAL_DATUM(current_test, /datum/unit_test)
GLOBAL_VAR_INIT(failed_any_test, FALSE)
/// When unit testing, all logs sent to log_mapping are stored here and retrieved in log_mapping unit test.
GLOBAL_LIST_EMPTY(unit_test_mapping_logs)
/// Global assoc list of required mapping items, [item typepath] to [required item datum].
GLOBAL_LIST_EMPTY(required_map_items)

/// A list of every test that is currently focused.
/// Use the PERFORM_ALL_TESTS macro instead.
GLOBAL_VAR_INIT(focused_tests, focused_tests())

/proc/focused_tests()
	var/list/focused_tests = list()
	for (var/datum/unit_test/unit_test as anything in subtypesof(/datum/unit_test))
		if (initial(unit_test.focus))
			focused_tests += unit_test

	return focused_tests.len > 0 ? focused_tests : null

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left floor turf of the testing zone
	var/turf/run_loc_floor_bottom_left

	/// The top right floor turf of the testing zone
	var/turf/run_loc_floor_top_right
	///The priority of the test, the larger it is the later it fires
	var/priority = TEST_DEFAULT
	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

	/// Do not instantiate if type matches this
	var/abstract_type = /datum/unit_test

	/// List of atoms that we don't want to ever initialize in an agnostic context, like for Create and Destroy. Stored on the base datum for usability in other relevant tests that need this data.
	var/static/list/uncreatables = null

	var/static/datum/space_level/reservation

/proc/cmp_unit_test_priority(datum/unit_test/a, datum/unit_test/b)
	return initial(a.priority) - initial(b.priority)

/datum/unit_test/New()
	if (isnull(reservation))
		var/datum/map_template/unit_tests/template = new
		reservation = template.load_new_z()

	if (isnull(uncreatables))
		uncreatables = build_list_of_uncreatables()

	allocated = new
	run_loc_floor_bottom_left = get_turf(locate(/obj/effect/landmark/unit_test_bottom_left) in GLOB.landmarks_list)
	run_loc_floor_top_right = get_turf(locate(/obj/effect/landmark/unit_test_top_right) in GLOB.landmarks_list)

	TEST_ASSERT(isfloorturf(run_loc_floor_bottom_left), "run_loc_floor_bottom_left was not a floor ([run_loc_floor_bottom_left])")
	TEST_ASSERT(isfloorturf(run_loc_floor_top_right), "run_loc_floor_top_right was not a floor ([run_loc_floor_top_right])")

/datum/unit_test/Destroy()
	QDEL_LIST(allocated)
	// clear the test area
	for (var/turf/turf in Z_TURFS(run_loc_floor_bottom_left.z))
		for (var/content in turf.contents)
			if (istype(content, /obj/effect/landmark))
				continue
			qdel(content)
	return ..()

/datum/unit_test/proc/Run()
	TEST_FAIL("[type]/Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason", file = "OUTDATED_TEST", line = 1)
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, list(list(reason, file, line)))

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if(ispath(type, /atom))
		if (!arguments.len)
			arguments = list(run_loc_floor_bottom_left)
		else if (arguments[1] == null)
			arguments[1] = run_loc_floor_bottom_left
	var/instance
	// Byond will throw an index out of bounds if arguments is empty in that arglist call. Sigh
	if(length(arguments))
		instance = new type(arglist(arguments))
	else
		instance = new type()
	allocated += instance
	return instance

/datum/unit_test/proc/test_screenshot(name, icon/icon)
	if (!istype(icon))
		TEST_FAIL("[icon] is not an icon.")
		return

	var/path_prefix = replacetext(replacetext("[type]", "/datum/unit_test/", ""), "/", "_")
	name = replacetext(name, "/", "_")

	var/filename = "code/modules/unit_tests/screenshots/[path_prefix]_[name].png"

	if (fexists(filename))
		var/data_filename = "data/screenshots/[path_prefix]_[name].png"
		fcopy(icon, data_filename)
		log_test("\t[path_prefix]_[name] was found, putting in data/screenshots")
	else if (fexists("code"))
		// We are probably running in a local build
		fcopy(icon, filename)
		TEST_FAIL("Screenshot for [name] did not exist. One has been created.")
	else
		// We are probably running in real CI, so just pretend it worked and move on
		fcopy(icon, "data/screenshots_new/[path_prefix]_[name].png")

		log_test("\t[path_prefix]_[name] was put in data/screenshots_new")

/// Helper for screenshot tests to take an image of an atom from all directions and insert it into one icon
/datum/unit_test/proc/get_flat_icon_for_all_directions(atom/thing, no_anim = TRUE)
	var/icon/output = icon('icons/effects/effects.dmi', "nothing")

	for (var/direction in GLOB.cardinals)
		var/icon/partial = getFlatIcon(thing, defdir = direction, no_anim = no_anim)
		output.Insert(partial, dir = direction)

	return output

/// Logs a test message. Will use GitHub action syntax found at https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions
/datum/unit_test/proc/log_for_test(text, priority, file, line)
	var/map_name = SSmapping.config.map_name

	// Need to escape the text to properly support newlines.
	var/annotation_text = replacetext(text, "%", "%25")
	annotation_text = replacetext(annotation_text, "\n", "%0A")

	log_world("::[priority] file=[file],line=[line],title=[map_name]: [type]::[annotation_text]")

/proc/RunUnitTest(datum/unit_test/test_path, list/test_results)
	if(ispath(test_path, /datum/unit_test/focus_only))
		return

	if(initial(test_path.abstract_type) == test_path)
		return

	var/datum/unit_test/test = new test_path

	GLOB.current_test = test
	var/duration = REALTIMEOFDAY
//	var/skip_test = (test_path in SSmapping.config.skipped_tests)
	var/test_output_desc = "[test_path]"
	var/message = ""

	log_world("::group::[test_path]")

//	if(skip_test)
//		log_world("[TEST_OUTPUT_YELLOW("SKIPPED")] Skipped run on map [SSmapping.config.map_name].")

//	else

	test.Run()

	duration = REALTIMEOFDAY - duration
	GLOB.current_test = null
	GLOB.failed_any_test |= !test.succeeded

	var/list/log_entry = list()
	var/list/fail_reasons = test.fail_reasons

	for(var/reasonID in 1 to LAZYLEN(fail_reasons))
		var/text = fail_reasons[reasonID][1]
		var/file = fail_reasons[reasonID][2]
		var/line = fail_reasons[reasonID][3]

		test.log_for_test(text, "error", file, line)

		// Normal log message
		log_entry += "\tFAILURE #[reasonID]: [text] at [file]:[line]"

	if(length(log_entry))
		message = log_entry.Join("\n")
		log_test(message)

	test_output_desc += " [duration / 10]s"
	if (test.succeeded)
		log_world("[TEST_OUTPUT_GREEN("PASS")] [test_output_desc]")

	log_world("::endgroup::")

	//if (!test.succeeded && !skip_test)
	if (!test.succeeded)
		log_world("::error::[TEST_OUTPUT_RED("FAIL")] [test_output_desc]")

	//var/final_status = skip_test ? UNIT_TEST_SKIPPED : (test.succeeded ? UNIT_TEST_PASSED : UNIT_TEST_FAILED)
	var/final_status = test.succeeded ? UNIT_TEST_PASSED : UNIT_TEST_FAILED
	test_results[test_path] = list("status" = final_status, "message" = message, "name" = test_path)

	qdel(test)

/// Builds (and returns) a list of atoms that we shouldn't initialize in generic testing, like Create and Destroy.
/// It is appreciated to add the reason why the atom shouldn't be initialized if you add it to this list.
/datum/unit_test/proc/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	var/list/returnable_list = list()
	// The following are just generic, singular types.
	returnable_list = list(
		//Never meant to be created, errors out the ass for mobcode reasons
		/mob/living/carbon,
		//And another
		/obj/item/slimecross/recurring,
		//This should be obvious
		/obj/machinery/doomsday_device,
		//Template type
		/obj/effect/mob_spawn,
		//Singleton
		/mob/dview,
		//Template type
		/obj/item/bodypart,
		//briefcase launchpads erroring
		/obj/machinery/launchpad/briefcase,
	)

	// Everything that follows is a typesof() check.

	//Say it with me now, type template
	returnable_list += typesof(/obj/effect/mapping_helpers)
	//This turf existing is an error in and of itself
	returnable_list += typesof(/turf/baseturf_skipover)
	returnable_list += typesof(/turf/baseturf_bottom)
	//This one demands a computer, ditto
	returnable_list += typesof(/obj/item/modular_computer/processor)
	//Very finiky, blacklisting to make things easier
	returnable_list += typesof(/obj/item/poster/wanted)
	//Same to above. Needs a client / mob / hallucination to observe it to exist.
	returnable_list += typesof(/obj/projectile/hallucination)
	//We have a baseturf limit of 10, adding more than 10 baseturf helpers will kill CI, so here's a future edge case to fix.
	returnable_list += typesof(/obj/effect/baseturf_helper)
	//No tauma to pass in
	returnable_list += typesof(/mob/camera/imaginary_friend)
	//No pod to gondola
	returnable_list += typesof(/mob/living/simple_animal/pet/gondola/gondolapod)
	//Hangs a ref post invoke async, which we don't support. Could put a qdeleted check but it feels hacky
	returnable_list += typesof(/obj/effect/anomaly/grav/high)
	//See above
	returnable_list += typesof(/obj/effect/timestop)
	//This lad also sleeps
	returnable_list += typesof(/obj/item/hilbertshotel)
	//this boi spawns turf changing stuff, and it stacks and causes pain. Let's just not
	returnable_list += typesof(/obj/effect/sliding_puzzle)
	//these can explode and cause the turf to be destroyed at unexpected moments
	returnable_list += typesof(/obj/effect/mine)
	//Stacks baseturfs, can't be tested here
	returnable_list += typesof(/obj/effect/temp_visual/lava_warning)
	//Our system doesn't support it without warning spam from unregister calls on things that never registered
	returnable_list += typesof(/obj/docking_port)
	//Asks for a shuttle that may not exist, let's leave it alone
	returnable_list += typesof(/obj/item/pinpointer/shuttle)
	//Expects a mob to holderize, we have nothing to give
	returnable_list += typesof(/obj/item/clothing/head/mob_holder)
	//Needs cards passed into the initilazation args
	returnable_list += typesof(/obj/item/toy/cards/cardhand)
	//Needs a holodeck area linked to it which is not guarenteed to exist and technically is supposed to have a 1:1 relationship with computer anyway.
	returnable_list += typesof(/obj/machinery/computer/holodeck)

	return returnable_list

/proc/RunUnitTests()
	CHECK_TICK

	var/list/tests_to_run = subtypesof(/datum/unit_test)
	var/list/focused_tests = list()
	for (var/_test_to_run in tests_to_run)
		var/datum/unit_test/test_to_run = _test_to_run
		if (initial(test_to_run.focus))
			focused_tests += test_to_run
	if(length(focused_tests))
		tests_to_run = focused_tests

	tests_to_run = sortTim(tests_to_run, /proc/cmp_unit_test_priority)

	var/list/test_results = list()

	//Hell code, we're bound to end the round somehow so let's stop if from ending while we work
	SSticker.delay_end = TRUE
	for(var/unit_path in tests_to_run)
		CHECK_TICK //We check tick first because the unit test we run last may be so expensive that checking tick will lock up this loop forever
		RunUnitTest(unit_path, test_results)
	SSticker.delay_end = FALSE

	var/file_name = "data/unit_tests.json"
	fdel(file_name)
	file(file_name) << json_encode(test_results)

	SSticker.force_ending = 1
	//We have to call this manually because del_text can preceed us, and SSticker doesn't fire in the post game
	SSticker.declare_completion()

/datum/map_template/unit_tests
	name = "Unit Tests Zone"
	mappath = "_maps/templates/unit_tests.dmm"

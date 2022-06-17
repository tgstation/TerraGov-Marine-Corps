# CONTRIBUTING

1. [Reporting Issues](#reporting-issues)
2. [Introduction](#introduction)
3. [Getting Started](#getting-started)
4. [Meet the Team](#meet-the-team)
	1. [Design Lead](#design-lead)
	2. [Headcoder](#headcoder)
	3. [Art Director](#art-director)
	4. [Maintainers](#maintainers)
5. [Specifications](#specifications)
	1. [Code specifications](#code-specifications)
	2. [Map specifications](#map-specifications)
6. [Pull Request Process](#pull-request-process)
7. [Porting features/sprites/sounds/tools from other codebases](#porting-featuresspritessoundstools-from-other-codebases)
8. [Banned content](#banned-content)
9. [Content that requires prior approval](#content-that-requires-prior-approval)
10. [A word on Git](#a-word-on-git)

## Reporting Issues

See [this page](https://github.com/tgstation/TerraGov-Marine-Corps/issues/new?template=bug_report.md) for a guide and format to issue reports.

## Introduction

Hello and welcome to the TGMC contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below. We strive to maintain long-term code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as what the structure of the team and the processes are, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

We don't have a strict list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you'd still like some guidance to see which features are appreciated, check the thread [here](https://tgstation13.org/phpBB/viewtopic.php?f=65&t=20487).

If you want to contribute the first thing you'll need to do is set up Git and clone the repository. Check out [this](https://tgstation13.org/wiki/TGMC:Guide_to_contributing) helpful guide.

We have a [list of guides on the wiki](http://www.tgstation13.org/wiki/index.php/Guides#Development_and_Contribution_Guides) that will help you get started contributing to this codebase with Git and Dream Maker. For beginners, it is recommended you work on small projects like bugfixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

You can of course, as always, ask for help at #coding channel on our [Discord](https://discord.gg/2dFpfNE). We're just here to have fun and help out, so please don't expect professional support. If you're eager to learn we'll gladly hold your hand during the first steps.

## Meet the Team

### Headcoder

The Headcoder is responsible for overall quality of the code and has the veto power here. In addition they are also able to appoint maintainers.

### Art Director

The Art Director controls sprites and aesthetic that get into the game. While sprites for brand-new additions are generally accepted without harsh standards, modified current art assets fall to the Art Director, who can decide whether or not a sprite tweak is both merited and a suitable replacement.

They also control the general "perspective" of the game - how sprites should generally look, especially the angle from which they're viewed. An example of this is the [3/4 perspective](http://static.tvtropes.org/pmwiki/pub/images/kakarikovillage.gif), which is a bird's eye view from above the object being viewed.

### Maintainers

Maintainers are the quality control. If a proposed pull request doesn't meet the following specifications, they can request a change, and if a proper reason is not provided or the request becomes stale, they may close it. Maintainers are required to give a reason for closing the pull request.

Maintainers can revert changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

## Specifications

### Code specifications

As mentioned before, you are expected to follow these specifications in order to make everyone's lives easier. It'll save both your time and ours, by making sure you don't have to make any changes and we don't have to ask you to. Thank you for reading this section!

#### Object Oriented Code
As BYOND's Dream Maker (henceforth "DM") is an object-oriented language, code must be object-oriented when possible in order to be more flexible when adding content to it. If you don't know what "object-oriented" means, we highly recommend you do some light research to grasp the basics.

#### All BYOND paths must contain the full path
(i.e. absolute pathing)

DM will allow you nest almost any type keyword into a block, such as:

```DM
datum
	datum1
		var
			varname1 = 1
			varname2
			static
				varname3
				varname4
		proc
			proc1()
				code
			proc2()
				code

		datum2
			varname1 = 0
			proc
				proc3()
					code
			proc2()
				..()
				code
```

The use of this is not allowed in this project as it makes finding definitions via full text searching next to impossible. The only exception is the variables of an object may be nested to the object, but must not nest further.

The previous code made compliant:

```DM
/datum/datum1
	var/varname1
	var/varname2
	var/static/varname3
	var/static/varname4

/datum/datum1/proc/proc1()
	code
/datum/datum1/proc/proc2()
	code
/datum/datum1/datum2
	varname1 = 0
/datum/datum1/datum2/proc/proc3()
	code
/datum/datum1/datum2/proc2()
	. = ..()
	code
```

#### Preserve return values
```
/datum/proc/proc1()
	code
	return something

/datum/datum1/proc1()
	..()
```
This wouldn't preserve the return value of the parent proc, instead, you should do this.
```
/datum/proc/proc1()
	code
	return something

/datum/datum1/proc1()
	. = ..()
```
`.` is the current return value of the current proc.
If you have the parent call at the end of the proc, use `return ..()` instead, it's slightly faster and more readable.

#### No overriding type safety checks
The use of the : operator to override type safety checks is not allowed. You must cast the variable to the proper type.

#### Type paths must begin with a /
eg: `/datum/thing`, not `datum/thing`

#### Type paths must be snake case
eg: `/datum/blue_bird`, not `/datum/BLUEBIRD` or `/datum/BlueBird` or `/datum/Bluebird` or `/datum/blueBird`

#### Datum type paths must began with "datum"
In DM, this is optional, but omitting it makes finding definitions harder.

#### Do not use text/string based type paths
It is rarely allowed to put type paths in a text format, as there are no compile errors if the type path no longer exists. Here is an example:

```DM
//Good
var/path_type = /obj/item/baseball_bat

//Bad
var/path_type = "/obj/item/baseball_bat"
```

#### Use var/name format when declaring variables
While DM allows other ways of declaring variables, this one should be used for consistency.

#### Tabs, not spaces
You must use tabs to indent your code, NOT SPACES.

(You may use spaces to align something, but you should tab to the block level first, then add the remaining spaces)

#### Argument naming
Do not use the `var/` prefix in arguments, it is already implied. Also if the argument will always be of a certain type, make the path reflect it. `mob/user` or `list/L` for example.

#### The use of src
`src.` is implied and the only place where using it makes sense is if you have an argument of the same name as one of the variables, for example:
```
/datum/datum1
	var/something

/datum/datum1/New(something)
	src.something = something
```

#### No hacky code
Hacky code, such as adding specific checks, is highly discouraged and only allowed when there is ***no*** other option. "I couldn't immediately think of a proper way so thus there must be no other option" is likely not gonna cut it. If you can't think of anything else, say that outright and admit that you need help with it. Maintainers and helpful contributors exist for exactly that reason.

You can avoid hacky code by using object-oriented methodologies, such as overriding a function (called "procs" in DM) or sectioning code into functions and then overriding them as required.

#### No duplicated code
Copying code from one place to another may be suitable for small, short-time projects, but this is a long-term project and highly discourages this.

Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

#### Startup/Runtime tradeoffs with lists and the "hidden" init proc
First, read the comments in [this BYOND thread](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), starting where the link takes you.

There are two key points here:

1) Defining a list in the variable's definition calls a hidden proc - init. If you have to define a list at startup, do so in New() (or preferably Initialize()) and avoid the overhead of a second call (Init() and then New())

2) It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: Although this tradeoff makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

#### Prefer `Initialize()` over `New()` for atoms
Our game controller is pretty good at handling long operations and lag, but it can't control what happens when the map is loaded, which calls `New` for all atoms on the map. If you're creating a new atom, use the `Initialize` proc to do what you would normally do in `New`. This cuts down on the number of proc calls needed when the world is loaded. See here for details on `Initialize`: https://github.com/tgstation/tgstation/blob/master/code/game/atoms.dm#L49
While we normally encourage (and in some cases, even require) bringing out of date code up to date when you make unrelated changes near the out of date code, that is not the case for `New` -> `Initialize` conversions. These systems are generally more dependant on parent and children procs so unrelated random conversions of existing things can cause bugs that take months to figure out.

##### `Initialize()` must be used properly
`Initialize()` must always call the parent proc `..()` to ensure the atom initializes and must return a valid value either by using `. = ..()` or `return ..()` or `return INITIALIZE_HINT_*`
This ensures atoms initialize correctly and there are not false positives of failures.
You also must not use `qdel(src)` inside `Initialize()`, use `return INITIALIZE_HINT_QDEL` instead.

#### Type checks vs Overrides
It is preferable to override a proc instead of using `istype()` checks for special behaviour for subtypes.
eg;
````DM
/mob/proc/do_a_thing()
	if(istype(src, /mob/subtype))
		do something different
	else
		do something
````
Instead of this you should;
````DM
/mob/proc/do_a_thing()
	do something

/mob/subtype/do_a_thing()
	do something different
````

#### Proc arguments
Keep typed arguments consistent across redefinitions, based on what minimal type the proc is called with rather than the actual type of the passed argument.
````DM
/atom/proc/do_a_thing(mob/user)
	do something

/atom/movable/do_a_thing(mob/living/carbon/human/user)
	do something
````
Instead of this you should do it like this:
````DM
/atom/proc/do_a_thing(mob/user)
	do something

/atom/movable/do_a_thing(mob/user)
	if !(istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	do something
````

#### No magic numbers or strings
This means stuff like having a "mode" variable for an object set to "1" or "2" with no clear indicator of what that means. Make these #defines with a name that more clearly states what it's for. For instance:
````DM
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(1)
			(...)
		if(2)
			(...)
````
There's no indication of what "1" and "2" mean! Instead, you'd do something like this:
````DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(DO_THE_THING_REALLY_HARD)
			(...)
		if(DO_THE_THING_EFFICIENTLY)
			(...)
````
This is clearer and enhances readability of your code! Get used to doing it!

#### Control statements
(if, while, for, etc)

* All control statements must not contain code on the same line as the statement (`if (blah) return`)
* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse (eg: `if (count <= 10)` not `if (10 >= count)`)

#### Use early return
Do not enclose a proc in an if-block when returning on a condition is more feasible
This is bad:
````DM
/datum/datum1/proc/proc1()
	if (thing1)
		if (!thing2)
			if (thing3 == 30)
				do stuff
````
This is good:
````DM
/datum/datum1/proc/proc1()
	if (!thing1)
		return
	if (thing2)
		return
	if (thing3 != 30)
		return
	do stuff
````
This prevents nesting levels from getting deeper then they need to be.

#### Use our time defines

The codebase contains some defines which will automatically multiply a number by the correct amount to get a number in deciseconds. Using these is preffered over using a literal amount in deciseconds.

The defines are as follows:
* SECONDS
* MINUTES
* HOURS

This is bad:
````DM
/datum/datum1/proc/proc1()
	if(do_after(mob, 15))
		mob.dothing()
````

This is good:
````DM
/datum/datum1/proc/proc1()
	if(do_after(mob, 1.5 SECONDS))
		mob.dothing()
````

#### Getters and setters

* Avoid getter procs. They are useful tools in languages with that properly enforce variable privacy and encapsulation, but DM is not one of them. The upfront cost in proc overhead is met with no benefits, and it may tempt to develop worse code.

This is bad:
```DM
/datum/datum1/proc/simple_getter()
	return gotten_variable
```
Prefer to either access the variable directly or use a macro/define.


* Make usage of variables or traits, set up through condition setters, for a more maintainable alternative to compex and redefined getters.

These are bad:
```DM
/datum/datum1/proc/complex_getter()
	return condition ? VALUE_A : VALUE_B

/datum/datum1/child_datum/complex_getter()
	return condition ? VALUE_C : VALUE_D
```

This is good:
```DM
/datum/datum1
	var/getter_turned_into_variable

/datum/datum1/proc/set_condition(new_value)
	if(condition == new_value)
		return
	condition = new_value
	on_condition_change()

/datum/datum1/proc/on_condition_change()
	getter_turned_into_variable = condition ? VALUE_A : VALUE_B

/datum/datum1/child_datum/on_condition_change()
	getter_turned_into_variable = condition ? VALUE_C : VALUE_D
```

#### Avoid unnecessary type checks and obscuring nulls in lists
Typecasting in `for` loops carries an implied `istype()` check that filters non-matching types, nulls included. The `AS` macro can be used to skip the check, it uses `as()` on byond versions that the proper `as anything` was broken.

If we know the list is supposed to only contain the desired type then we want to skip the check not only for the small optimization it offers, but also to catch any null entries that may creep into the list.

Nulls in lists tend to point to improperly-handled references, making hard deletes hard to debug. Generating a runtime in those cases is more often than not positive.

This is bad:
```DM
var/list/bag_of_atoms = list(new /obj, new /mob, new /atom, new /atom/movable, new /atom/movable)
var/highest_alpha = 0
for(var/atom/thing in bag_of_atoms)
	if(thing.alpha <= highest_alpha)
		continue
	highest_alpha = thing.alpha
```

This is good:
```DM
var/list/bag_of_atoms = list(new /obj, new /mob, new /atom, new /atom/movable, new /atom/movable)
var/highest_alpha = 0
for(var/atom/thing as anything in bag_of_atoms)
	if(thing.alpha <= highest_alpha)
		continue
	highest_alpha = thing.alpha
```

For more information on istypeless `for` loops check [this other section.](#istypeless-for-loops)


#### Develop Secure Code

* Player input must always be escaped safely, we recommend you use stripped_input in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind

* Calls to the database must be escaped properly - use sanitizeSQL to escape text based database entries from players or admins, and isnum() for number based database entries from players or admins.

* All calls to topics must be checked for correctness. Topic href calls can be easily faked by clients, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls, because it won't.

* Information that players could use to metagame (that is, to identify round information and/or antagonist type via information that would not be available to them in character) should be kept as administrator only.

* It is recommended as well you do not expose information about the players - even something as simple as the number of people who have readied up at the start of the round can and has been used to try to identify the round type.

* Where you have code that can cause large-scale modification and *FUN*, make sure you start it out locked behind one of the proper admin permissions - ask if you're not sure.

#### Files
* Because runtime errors do not give the full path, try to avoid having files with the same name across folders.

* File names and directory names should not contain upper case letters, spaces or any character that would require escaping in a URI.

* Files and path accessed and referenced by code above simply being #included should be strictly lowercase to avoid issues on filesystems where case matters.

#### SQL
* Do not use the shorthand SQL insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

* All changes to the database's layout(schema) must be specified in the database changelog in SQL, as well as reflected in the schema files

* Any time the schema is changed the `schema_revision` table and `DB_MAJOR_VERSION` or `DB_MINOR_VERSION` defines must be incremented.

* Queries must never specify the database, be it in code, or in text files in the repo.

* Primary keys are inherently immutable and you must never do anything to change the primary key of a row or entity. This includes preserving auto increment numbers of rows when copying data to a table in a conversion script. No amount of bitching about gaps in ids or out of order ids will save you from this policy.

* The ttl for data from the database is 10 seconds. You must have a compelling reason to store and reuse data for longer then this.

* Do not write stored and transformed data to the database, instead, apply the transformation to the data in the database directly.
	* ie: SELECTing a number from the database, doubling it, then updating the database with the doubled number. If the data in the database changed between step 1 and 3, you'll get an incorrect result. Instead, directly double it in the update query. `UPDATE table SET num = num*2` instead of `UPDATE table SET num = [num]`.
	* if the transformation is user provided (such as allowing a user to edit a string), you should confirm the value being updated did not change in the database in the intervening time before writing the new user provided data by checking the old value with the current value in the database, and if it has changed, allow the user to decide what to do next.

#### User Interfaces
* All new player-facing user interfaces must use TGUI.
* Raw HTML is permitted for admin and debug UIs.
* Documentation for TGUI can be found at:
	* [tgui/README.md](../tgui/README.md)
	* [tgui/tutorial-and-examples.md](../tgui/docs/tutorial-and-examples.md)

#### Signal Handlers
All procs that are registered to listen for signals using `RegisterSignal()` must contain at the start of the proc `SIGNAL_HANDLER` eg;
```
/type/path/proc/signal_callback()
	SIGNAL_HANDLER
	// rest of the code
```
This is to ensure that it is clear the proc handles signals and turns on a lint to ensure it does not sleep.

Any sleeping behaviour that you need to perform inside a `SIGNAL_HANDLER` proc must be called asynchronously (e.g. with `INVOKE_ASYNC()`) or be redone to work asynchronously.

#### Enforcing parent calling
When adding new signals to root level procs, eg;
```
/atom/proc/setDir(newdir)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir
```
The `SHOULD_CALL_PARENT(TRUE)` lint should be added to ensure that overrides/child procs call the parent chain and ensure the signal is sent.

#### Use descriptive and obvious names
Optimize for readability, not writability. While it is certainly easier to write `M` than `victim`, it will cause issues down the line for other developers to figure out what exactly your code is doing, even if you think the variable's purpose is obvious.

##### Don't use abbreviations
Avoid variables like C, M, and H. Prefer names like "user", "victim", "weapon", etc.

```dm
// What is M? The user? The target?
// What is A? The target? The item?
/proc/use_item(mob/M, atom/A)

// Much better!
/proc/use_item(mob/user, atom/target)
```

Unless it is otherwise obvious, try to avoid just extending variables like "C" to "carbon"--this is slightly more helpful, but does not describe the *context* of the use of the variable.

##### Naming things when typecasting
When typecasting, keep your names descriptive:
```dm
var/mob/living/living_target = target
var/mob/living/carbon/carbon_target = living_target
```

Of course, if you have a variable name that better describes the situation when typecasting, feel free to use it.

Note that it's okay, semantically, to use the same variable name as the type, e.g.:
```dm
var/atom/atom
var/client/client
var/mob/mob
```

Your editor may highlight the variable names, but BYOND, and we, accept these as variable names:

```dm
// This functions properly!
var/client/client = CLIENT_FROM_VAR(usr)
// vvv this may be highlighted, but it's fine!
client << browse(...)
```
##### Name things as directly as possible
`was_called` is better than `has_been_called`. `notify` is better than `do_notification`.

##### Avoid negative variable names
`is_flying` is better than `is_not_flying`. `late` is better than `not_on_time`.
This prevents double-negatives (such as `if (!is_not_flying)` which can make complex checks more difficult to parse.

##### Exceptions to variable names

Exceptions can be made in the case of inheriting existing procs, as it makes it so you can use named parameters, but *new* variable names must follow these standards. It is also welcome, and encouraged, to refactor existing procs to use clearer variable names.

Naming numeral iterator variables `i` is also allowed, but do remember to [Avoid unnecessary type checks and obscuring nulls in lists](#avoid-unnecessary-type-checks-and-obscuring-nulls-in-lists), and making more descriptive variables is always encouraged.

```dm
// Bad
for (var/datum/reagent/R as anything in reagents)

// Good
for (var/datum/reagent/deadly_reagent as anything in reagents)

// Allowed, but still has the potential to not be clear. What does `i` refer to?
for (var/i in 1 to 12)

// Better
for (var/month in 1 to 12)

// Bad, only use `i` for numeral loops
for (var/i in reagents)
```

#### Icons are for image manipulation and defining an obj's `.icon` var, appearances are for everything else.
BYOND will allow you to use a raw icon file or even an icon datum for underlays, overlays, and what not (you can even use strings to refer to an icon state on the current icon). The issue is these get converted by BYOND to appearances on every overlay insert or removal involving them, and this process requires inserting the new appearance into the global list of appearances, and informing clients about them.

Converting them yourself to appearances and storing this converted value will ensure this process only has to happen once for the lifetime of the round. Helper functions exist to do most of the work for you.


Bad:
```dm
/obj/machine/update_overlays(blah)
	if (stat & broken)
		add_overlay(icon(broken_icon))  //this icon gets created, passed to byond, converted to an appearance, then deleted.
		return
	if (is_on)
		add_overlay("on") //also bad, the converstion to an appearance still has to happen
	else
		add_overlay(iconstate2appearance(icon, "off")) //this might seem alright, but not storing the value just moves the repeated appearance generation to this proc rather then the core overlay management. It would only be acceptable (and to some degree perferred) if this overlay is only ever added once (like in init code)
```

Good:
```dm
/obj/machine/update_overlays(var/blah)
	var/static/on_overlay
	var/static/off_overlay
	var/static/broken_overlay
	if(isnull(on_overlay)) //static vars initialize with global variables, meaning src is null and this won't pass integration tests unless you check.
		on_overlay = iconstate2appearance(icon, "on")
		off_overlay = iconstate2appearance(icon, "off")
		broken_overlay = icon2appearance(broken_icon)
	if (stat & broken)
		add_overlay(broken_overlay)
		return
	if (is_on)
		add_overlay(on_overlay)
	else
		add_overlay(off_overlay)
	...
```

Note: images are appearances with extra steps, and don't incur the overhead in conversion.


#### Do not abuse associated lists.
Associated lists that could instead be variables or statically defined number indexed lists will use more memory, as associated lists have a 24 bytes per item overhead (vs 8 for lists and most vars), and are slower to search compared to static/global variables and lists with known indexes.


Bad:
```dm
/obj/machine/update_overlays(var/blah)
	var/static/our_overlays
	if(isnull(our_overlays)
		our_overlays = list("on" = iconstate2appearance(overlay_icon, "on"), "off" = iconstate2appearance(overlay_icon, "off"), "broken" = iconstate2appearance(overlay_icon, "broken"))
	if (stat & broken)
		add_overlay(our_overlays["broken"])
		return
	...
```

Good:
```dm
#define OUR_ON_OVERLAY 1
#define OUR_OFF_OVERLAY 2
#define OUR_BROKEN_OVERLAY 3
/obj/machine/update_overlays(var/blah
	var/static/our_overlays
	if(isnull(our_overlays)
		our_overlays = list(iconstate2appearance(overlay_icon, "on"), iconstate2appearance(overlay_icon, "off"), iconstate2appearance(overlay_icon, "broken"))
	if (stat & broken)
		add_overlay(our_overlays[OUR_BROKEN_OVERLAY])
		return
	...

#undef OUR_ON_OVERLAY
#undef OUR_OFF_OVERLAY
#undef OUR_BROKEN_OVERLAY
```
Storing these in a flat (non-associated) list saves on memory, and using defines to reference locations in the list saves CPU time searching the list.

Also good:
```dm
/obj/machine/update_overlays(var/blah)
	var/static/on_overlay
	var/static/off_overlay
	var/static/broken_overlay
	if(isnull(on_overlay))
		on_overlay = iconstate2appearance(overlay_icon, "on")
		off_overlay = iconstate2appearance(overlay_icon, "off")
		broken_overlay = iconstate2appearance(overlay_icon, "broken")
	if (stat & broken)
		add_overlay(broken_overlay)
		return
	...
```
Proc variables, static variables, and global variables are resolved at compile time, so the above is equivalent to the second example, but is easier to read, and avoids the need to store a list.

Note: While there has historically been a strong impulse to use associated lists for caching of computed values, this is the easy way out and leaves a lot of hidden overhead. Please keep this in mind when designing core/root systems that are intended for use by other code/coders. It's normally better for consumers of such systems to handle their own caching using vars and number indexed lists, than for you to do it using associated lists.

#### Don't create code that hangs references

This is part of the larger issue of hard deletes, read this file for more info: [Guide to Harddels](HARDDEL_GUIDE.md))

#### Other Notes
* Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the "tools.dm" file)

* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

* Do not divide when you can easily convert it to multiplication. (ie `4 / 2` should be done as `4 * 0.5`)

* If you used regex to replace code during development of your code, post the regex in your PR for the benefit of future developers and downstream users.

* Changes to the `/config` tree must be made in a way that allows for updating server deployments while preserving previous behaviour. This is due to the fact that the config tree is to be considered owned by the user and not necessarily updated alongside the remainder of the code. The code to preserve previous behaviour may be removed at some point in the future given the OK by maintainers.

##### Enforced not enforced
The following coding styles are not only not enforced at all, but are generally frowned upon to change for little to no reason:

* English/British spelling on var/proc names
	* Color/Colour - both are fine, but keep in mind that BYOND uses `color` as a base variable
* Spaces after control statements
	* `if()` and `if ()` - nobody cares!

#### Operators
##### Spacing
(this is not strictly enforced, but more a guideline for readability's sake)

* Operators that should be separated by spaces
	* Boolean and logic operators like &&, || <, >, ==, etc (but not !)
	* Bitwise AND &
	* Argument separator operators like , (and ; when used in a forloop)
	* Assignment operators like = or += or the like
* Operators that should not be separated by spaces
	* Bitwise OR |
	* Access operators like . and :
	* Parentheses ()
	* logical not !

Math operators like +, -, /, *, etc are up in the air, just choose which version looks more readable.

##### Use
* Bitwise AND - '&'
	* Should be written as ```bitfield & bitflag``` NEVER ```bitflag & bitfield```, both are valid, but the latter is confusing and nonstandard.
	* Feel free to use one of the helpful bitflag operation macros instead (CHECK_BITFIELD and similar).
* Associated lists declarations must have their key value quoted if it's a string
	* WRONG: list(a = "b")
	* RIGHT: list("a" = "b")

#### Dream Maker Quirks/Tricks
Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

##### In-To for-loops
```for(var/i = 1, i <= some_value, i++)``` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but DM's ```for(var/i in 1 to some_value)``` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (Note, the ```to``` keyword is inclusive, so it automatically defaults to replacing ```<=```; if you want ```<``` then you should write it as ```1 to some_value-1```).

HOWEVER, if either ```some_value``` or ```i``` changes within the body of the for (underneath the ```for(...)``` header) or if you are looping over a list AND changing the length of the list then you can NOT use this type of for-loop!

##### for(var/A in list) VS for(var/i in 1 to list.len)
The former is faster than the latter, as shown by the following profile results:
https://file.house/zy7H.png
Code used for the test in a readable format:
https://pastebin.com/w50uERkG

##### Istypeless for loops
A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:
```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using ```istype()``` (or some internal-magic similar to ```istype()``` - this is BYOND, after all). This is fine in its current state for ```bag_of_items```, but if ```bag_of_items``` contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
specifies a type for DM to filter by.

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic ```istype()``` checks by writing the loop as such:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
	var/obj/item/sword/S = s
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the specified type, even if it isn't really that type, causing runtime errors.

##### Dot variable
Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:
```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```
However, DM also has a dot variable, accessed just as ```.``` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the ```return``` statement) at the end of a proc, provided the proc does not already manually return (```return count``` for example.) Why is this special?

With ```.``` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the ```.``` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the ```.``` operator is compatible with a few operators that look weird but work perfectly fine, such as: ```.++``` for incrementing ```.'s``` value, or ```.[1]``` for accessing the first element of ```.```, provided that it's a list.

##### Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
/mob
	var/global/thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.


#### Documentation

TGMC has self-documenting code, and as such all new procs and variables should be documented using the following format:

Single line comments
```DM
///This proc, variable or define does something
var/myvariable
```
Multi line comments
```DM
/**
 * This is a proc with arguments
 *
 * it does things
 * Arguments:
 * * bar: this argument does things
 */
/proc/foo(bar)
```
File comments
```DM
/*!
 * This file has things in it
 */
```

### Map specifications

Any new map or map change must comply to these specifications.

#### TGM Format & Map Merge

New maps should be converted into the .tgm format before making a pull request. All edits to existing maps should be correctly map merged. This is done using the [Map Merge](https://tgstation13.org/wiki/Map_Merger) utility included in the repo to convert the file to TGM format.
It is HIGHLY recommend to use third party mapping programs such as StrongDMM to make map changes easier.

#### Variable Editing (Var-edits)

While var-editing an item within the editor is perfectly fine, it is preferred that when you are changing the base behavior of an item (how it functions) that you make a new subtype of that item within the code, especially if you plan to use the item in multiple locations on the same map, or across multiple maps. This makes it easier to make corrections as needed to all instances of the item at one time as opposed to having to find each instance of it and change them all individually.

Please attempt to clean out any dirty variables that may be contained within items you alter through var-editing. For example, due to how DM functions, changing the `pixel_x` variable from 23 to 0 will leave a dirty record in the map's code of `pixel_x = 0`. Likewise this can happen when changing an item's icon to something else and then back. This can lead to some issues where an item's icon has changed within the code, but becomes broken on the map due to it still attempting to use the old entry.

Areas should not be var-edited on a map to change it's name or attributes. All areas of a single type and it's altered instances are considered the same area within the code, and editing their variables on a map can lead to issues with powernets and event subsystems which are difficult to debug.

#### Map size

All maps should be 255x255 at most because of known issues with how BYOND behaves with maps bigger than this.

#### Working ai nodes network for ship maps and ground maps

Ais should be able to go everywhere on the map and it should be a single network if possible (two levels maps get a pass). Nodes can be placed up to 15 tiles apart, including diagonally. Any walls or lava between two nodes will block the link between them. Remember that ais are stupid, and that some obstacles are impossible to cross for them, so make their paths simple.

#### Limited marine supplies in shipside maps

Marine players are given limited supplies for preparation and deployment to enhance their gameplay while not sacrificing xenomorph players' fun. This line of thought follows the philosophy that all shipside maps are not chosen over another in consideration of supplies. For example: if marines choose Pillar of Spring over all other maps due to Pillar of Spring having more round start sentries and mortars, then mappers or contributors are obligated to eliminate the bias. While not an exhausive list, all shipside maps follow the same number of supplies:

Chem lab:
3 bluespace beakers

CAS armament:
6 30mm ammo crates
2 banshees
2 keepers
2 widowmakers
4 mini rockets
2 GAU-21 30 mm cannons
2 rocket pods
2 minirocket pods

This doesn't mean that mappers can't put extra supplies in planetside maps, though the extra supplies should be far away from landing zones to prevent marine players from favoring one map over another when considering supplies.
#### Anti fob area system implemented

Xenos should not be able to build near the fob before shutters are down. As such, wide enough areas around FOB must be placed. An area is set as non-buildable if it contains a shutter.

#### Working electrical system

Every area must have an APC. A ground map must have roughly 10 generators, with working SMES nearby. A shipmap must be fully wired and its electrical system fully working at the start of the game

#### Connected pipenet

Every ship should have a believable and complete pipe system (ventilation, scrubbers). All pipes must belong to the same network. No pipes ending nowhere. Pipes groundside are not mandatory, but they add to the atmosphere and are usefull to xeno.

#### Xenos related items (walls, weeds, silos, etc.)

Everything related to xenos must be placed on map via a landmark, and not be directly added. This allows the map to be clean in HvH modes.
Silos must be placed around the map for crash and hunt gamemode. A reasonable amount of turrets must be placed around the map, preferrably in caves and near silos.
A reasonnable amount of weeds must be placed, near silos and turrets. You don't have to add resin walls or doors if you don't want to, but they add to the atmostphere.
Adding corpse spawner also add to the atmospher, but they are not mandatory.

#### Fog around silos

Any silo placed on map must be protected by enough fog. This fog only appears in crash gamemode and is here to prevent marines to go near xenos spawn locations

#### Intel and nuke disk computers

There should be a reasonnable amount of intel computers placed in areas with apc. 3 nuke disk computer (yellow, red, blue) must be placed around the map. A nuke landmark has to be present as well somewhere.

#### Miners

Miners must be placed around the map. Platinium miners must be in locations easily defendable by xenos, typically caves. Phoron miners must not be placed too close to LZ, it should be somewhat an effort to secure any miner.

#### LZ requirements

LZ must be marqued (lz1, lz2). The appropriate shuttle console landmark should be placed inside the fob. It must be surrounded by shutters. It has to have an apc to power the area, and a button to open the shutters.

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

Anyone can review pull requests, and while only maintainers have write permissions, any help is appreciated.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are expected to have tested your pull requests if it is anything that would warrant testing. Text only changes, single number balance changes, and similar generally don't need testing, but anything else does. This means by extension web edits are disallowed for larger changes.

* You are going to be expected to describe your changes in the pull request description. Failing to do so could mean delaying it as we may have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data. For performance changes, you are expected to do some profiling. Ask around if you don't know how.

* Use the changelog for large player-facing changes, it prevents our players from being caught unaware by changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable. This is called atomizing.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

* If your pull request is not finished, you may open it as a draft for potential review. If you open it as a full-fledged PR make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

* After leaving reviews on an open pull request, maintainers may convert it to a draft. Once you have addressed all their comments to the best of your ability, feel free to mark the pull as `Ready for Review` again.

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All of our assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated. However if you are porting assets from GoonStation or usually any assets under the [Creative Commons 3.0 BY-NC-SA license](https://creativecommons.org/licenses/by-nc-sa/3.0/) are to go into the 'goon' folder of the codebase.

## Banned content
Do not add any of the following in a pull request or it will get closed:
* National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
* Code which violates GitHub's [terms of service](https://github.com/site/terms).
* Anything that would be against our rules.

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## Content that requires prior approval

The following content requires prior approval from Maintainers, Head Coders before making a Pull Request:
* Changes to Rank names, rank times or job ranks

## A word on Git
Yes, we know that the files have a tonne of mixed Windows and Linux line endings. Attempts to fix this have been met with less than stellar success, and as such we have decided to give up caring until there comes a time when it matters.

Therefore, EOF settings of main repo are forbidden territory one must avoid wandering into, at risk of losing body and/or mind to the Git gods.

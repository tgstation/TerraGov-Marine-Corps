#define PAPER_DEFAULT_FONT "Verdana"
#define PAPER_SIGN_FONT "Times New Roman"
#define PAPER_CRAYON_FONT "Comic Sans MS"

GLOBAL_LIST_INIT(pencode_blocked_tags, list("*", "hr", "small", "/small", "list", "/list", "table", "/table", "row", "cell", "logo"))

/proc/parse_pencode(t, obj/item/tool/pen/P, mob/user, is_crayon = FALSE)
	var/font = is_crayon ? PAPER_CRAYON_FONT : PAPER_DEFAULT_FONT

	// First if crayon
	if(is_crayon)
		// Remove all the blocked tags.
		for(var/i in GLOB.pencode_blocked_tags)
			t = replacetext_char(t, "\[[i]\]", "")

	t = replacetext_char(t, "\n", "<br />") // Lets just always do this one

	t = replacetext_char(t, "\[br\]", "<br />")
	t = replacetext_char(t, "\[hr\]", "<hr />")
	t = replacetext_char(t, "\[center\]", "<center>")
	t = replacetext_char(t, "\[/center\]", "</center>")
	t = replacetext_char(t, "\[b\]", "<b>")
	t = replacetext_char(t, "\[/b\]", "</b>")
	t = replacetext_char(t, "\[i\]", "<i>")
	t = replacetext_char(t, "\[/i\]", "</i>")
	t = replacetext_char(t, "\[u\]", "<u>")
	t = replacetext_char(t, "\[/u\]", "</u>")

	t = replacetext_char(t, "\[large\]", "<font size='4'>")
	t = replacetext_char(t, "\[/large\]", "</font>")
	t = replacetext_char(t, "\[small\]", "<font size='1'>")
	t = replacetext_char(t, "\[/small\]", "</font>")
	t = replacetext_char(t, "\[h1\]", "<h1>")
	t = replacetext_char(t, "\[/h1\]", "</h1>")
	t = replacetext_char(t, "\[h2\]", "<h2>")
	t = replacetext_char(t, "\[/h2\]", "</h2>")
	t = replacetext_char(t, "\[h3\]", "<h3>")
	t = replacetext_char(t, "\[/h3\]", "</h3>")

	t = replacetext_char(t, "\[list\]", "<ul>")
	t = replacetext_char(t, "\[/list\]", "</ul>")
	t = replacetext_char(t, "\[*\]", "<li>")
	t = replacetext_char(t, "\[table\]", "<table border='1' cellspacing='0' cellpadding='3 style='border: 1px solid black;'>")
	t = replacetext_char(t, "\[/table\]", "</td></tr></table>")
	t = replacetext_char(t, "\[grid\]", "<table>")
	t = replacetext_char(t, "\[/grid\]", "</td></tr></table>")
	t = replacetext_char(t, "\[row\]", "</td><tr>")
	t = replacetext_char(t, "\[cell\]", "<td>")

	t = replacetext_char(t, "\[sign\]", "<font face=\"[PAPER_SIGN_FONT]\"><i>[user ? user.real_name : "Anonymous"]</i></font>")
	t = replacetext_char(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext_char(t, "\[logo\]", "<img src='tgmclogo.png' />")
	t = replacetext_char(t, "\[ntlogo\]", "<img src='ntlogo.png' />")

	t = replacetext_char(t, "\[mapname\]", "[SSmapping.configs[GROUND_MAP].map_name]")
	t = replacetext_char(t, "\[shipname\]", "[SSmapping.configs[SHIP_MAP].map_name]")
	t = replacetext_char(t, "\[date\]", "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")]")
	t = replacetext_char(t, "\[time\]", "[worldtime2text()]")

	t = "<font face='[font]' color='[P ? P.colour : "black"]'>[t]</font>"

	return t

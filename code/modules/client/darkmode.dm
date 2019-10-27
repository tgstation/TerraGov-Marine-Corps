//Darkmode preference by Kmc2000//

/*
This lets you switch chat themes by using winset and CSS loading, you must relog to see this change (or rebuild your browseroutput datum)

How this works:
I've added a function to browseroutput.js which registers a cookie for darkmode and swaps the chat accordingly. You can find the button to do this under the "cog" icon next to the ping button (top right of chat)
This then swaps the window theme automatically

Thanks to spacemaniac and mcdonald for help with the JS side of this.

*/


//#define COLOR_DARKMODE_BACKGROUND "#202020"
//#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
//#define COLOR_DARKMODE_TEXT "#a4bad6"
#define COLOR_DARKMODE_BACKGROUND "#333333"
#define COLOR_DARKMODE_DARKBACKGROUND "#1E1E1E"
#define COLOR_DARKMODE_TEXT "#acacac"


/client/proc/force_white_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	//Main windows
	winset(src, "menu", "background-color = none ; text-color = #000000")
	winset(src, "split", "background-color = none")
	winset(src, "infowindow", "background-color = none ; text-color = #000000")
	winset(src, "info", "background-color = none ; text-color = #000000")
	winset(src, "browseroutput", "background-color = none ; text-color = #000000")
	winset(src, "outputwindow", "background-color = none ; text-color = #000000")
	winset(src, "mainwindow", "background-color = none")
	winset(src, "split", "background-color = none")
	//Buttons
	winset(src, "changelog", "background-color = none ; text-color=#000000")
	winset(src, "discord", "background-color = none ; text-color=#000000")
	winset(src, "rules", "background-color = none ; text-color = #000000")
	winset(src, "wiki", "background-color = none ; text-color = #000000")
	winset(src, "forum", "background-color = none ; text-color = #000000")
	winset(src, "github", "background-color = none ; text-color = #000000")
	winset(src, "webmap", "background-color = none ; text-color = #000000")
	//Status and verb tabs
	winset(src, "output", "background-color = none ; text-color = #000000")
	winset(src, "outputwindow", "background-color = none ; text-color = #000000")
	winset(src, "statwindow", "background-color = none ; text-color = #000000")
	winset(src, "stat", "background-color = #FFFFFF ; tab-background-color = none ; text-color = #000000 ; tab-text-color = #000000 ; prefix-color = #000000 ; suffix-color = #000000")
	//Say, OOC, me Buttons etc.
	winset(src, "input", "background-color = #d3b5b5 ; text-color = #000000")
	winset(src, "saybutton", "background-color = none ; text-color = #000000")
	winset(src, "oocbutton", "background-color = none ; text-color = #000000")
	winset(src, "mebutton", "background-color = none ; text-color = #000000")
	winset(src, "asset_cache_browser", "background-color = none ; text-color = #000000")
	winset(src, "tooltip", "background-color = none ; text-color = #000000")

/client/proc/force_dark_theme() //Inversely, if theyre using white theme and want to swap to the superior dark theme, let's get WINSET() ing
	//Main windows
	winset(src, "menu", "background-color = #252526 ; text-color = #acacac")
	winset(src, "split", "background-color = [COLOR_DARKMODE_BACKGROUND]")
	winset(src, "infowindow", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "info", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "browseroutput", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mainwindow", "background-color = [COLOR_DARKMODE_BACKGROUND]")
	winset(src, "split", "background-color = [COLOR_DARKMODE_BACKGROUND]")
	//Buttons
	winset(src, "changelog", "background-color = #494949 ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "discord", "background-color = #494949 ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rules", "background-color = #494949 ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "wiki", "background-color = #494949 ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "forum", "background-color = #494949 ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "github", "background-color = #3a3a3a ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "webmap", "background-color = #3a3a3a ; text-color = [COLOR_DARKMODE_TEXT]")
	//Status and verb tabs
	winset(src, "output", "background-color = [COLOR_DARKMODE_DARKBACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [COLOR_DARKMODE_DARKBACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "statwindow", "background-color = [COLOR_DARKMODE_DARKBACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "stat", "background-color = [COLOR_DARKMODE_DARKBACKGROUND] ; tab-background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT] ; tab-text-color = [COLOR_DARKMODE_TEXT] ; prefix-color = [COLOR_DARKMODE_TEXT] ; suffix-color = [COLOR_DARKMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "input", "background-color = #1e1e1e ; text-color = #acacac")
	winset(src, "saybutton", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "oocbutton", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mebutton", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "asset_cache_browser", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "tooltip", "background-color = [COLOR_DARKMODE_BACKGROUND] ; text-color = [COLOR_DARKMODE_TEXT]")

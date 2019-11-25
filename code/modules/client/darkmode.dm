//Darkmode preference by Kmc2000//

/*
This lets you switch chat themes by using winset and CSS loading, you must relog to see this change (or rebuild your browseroutput datum)

How this works:
I've added a function to browseroutput.js which registers a cookie for darkmode and swaps the chat accordingly. You can find the button to do this under the "cog" icon next to the ping button (top right of chat)
This then swaps the window theme automatically

Thanks to spacemaniac and mcdonald for help with the JS side of this.

*/

/client/proc/force_white_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	//Main windows
	winset(src, "infowindow", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "info", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "browseroutput", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "mainwindow", "background-color = [LIGHTMODE_BACKGROUND]")
	winset(src, "split", "background-color = [LIGHTMODE_BACKGROUND]")
	//Buttons
	winset(src, "changelog", "background-color = [LIGHTMODE_BACKGROUND] ; text-color=[LIGHTMODE_TEXT]")
	winset(src, "discord", "background-color = [LIGHTMODE_BACKGROUND] ; text-color=[LIGHTMODE_TEXT]")
	winset(src, "rules", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "wiki", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "forum", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "github", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "webmap", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	//Status and verb tabs
	winset(src, "output", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "statwindow", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "stat", "background-color = #FFFFFF ; tab-background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT] ; tab-text-color = [LIGHTMODE_TEXT] ; prefix-color = [LIGHTMODE_TEXT] ; suffix-color = [LIGHTMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "input", "background-color = [COLOR_INPUT_DISABLED] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "saybutton", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "oocbutton", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "mebutton", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "asset_cache_browser", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")
	winset(src, "tooltip", "background-color = [LIGHTMODE_BACKGROUND] ; text-color = [LIGHTMODE_TEXT]")

/client/proc/force_dark_theme() //Inversely, if theyre using white theme and want to swap to the superior dark theme, let's get WINSET() ing
	//Main windows
	winset(src, "infowindow", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "info", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "browseroutput", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "mainwindow", "background-color = [DARKMODE_BACKGROUND]")
	winset(src, "split", "background-color = [DARKMODE_BACKGROUND]")
	//Buttons
	winset(src, "changelog", "background-color = [DARKMODE_GRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "discord", "background-color = [DARKMODE_GRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "rules", "background-color = [DARKMODE_GRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "wiki", "background-color = [DARKMODE_GRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "forum", "background-color = [DARKMODE_GRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "github", "background-color = [DARKMODE_DARKGRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	winset(src, "webmap", "background-color = [DARKMODE_DARKGRAYBUTTON] ; text-color = [DARKMODE_TEXT]")
	//Status and verb tabs
	winset(src, "output", "background-color = [DARKMODE_DARKBACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "outputwindow", "background-color = [DARKMODE_DARKBACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "statwindow", "background-color = [DARKMODE_DARKBACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "stat", "background-color = [DARKMODE_DARKBACKGROUND] ; tab-background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT] ; tab-text-color = [DARKMODE_TEXT] ; prefix-color = [DARKMODE_TEXT] ; suffix-color = [DARKMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "input", "background-color = [DARKMODE_DARKBACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "saybutton", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "oocbutton", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "mebutton", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "asset_cache_browser", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")
	winset(src, "tooltip", "background-color = [DARKMODE_BACKGROUND] ; text-color = [DARKMODE_TEXT]")

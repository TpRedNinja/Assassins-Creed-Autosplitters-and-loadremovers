//Assassins Creed Unity Autosplitter v4 by AkiloGames

//Splits when the mission complete menu dissappears ***It is possible for the player to be too quick and have the mission menu not show up for long enough to register and therefore not split***
//Works for 1.4.0 & 1.5.0 Any%


state("ACU", "1.4.0") 
{
    //Only these four values are used to split and remove loads
    int currency : 0x0524E7E0, 0x58, 0x0, 0x964; //Current currency -1 on loads to new areas
    int isLoading: 0x0512A558, 0x20, 0xD8, 0x8, 0x20, 0x28, 0x18, 0xF40; //0 when normal, 1 when loading
    int missionComplete: 0x05210C30, 0x58, 0x8; //1 if the accept mission complete rewards. 0 everywhere else
    int paused : 0x04F486A8, 0xCC8; //Detects pause and menu 1/0
    int startMenu : 0x03C3F308, 0x0; //Also detects pause and menu 256/0
    
    //Below values are not used and were found when I was new so they may not actually work 100% of the time
    //string5 versionNumber : 0x7FF4FD5E9AB0;
    int sync : 0x05252500, 0x128, 0xD8, 0x0, 0x4C;
    int tabbedOut : 0x39B20C0; //1 is tabbed out, 0 is in game (May be related to game running or not. Unsure as of now)
    float gameTimer : 0x0520BA70, 0x70, 0x108, 0x4C0; //Game Timer, pauses while in menus, does not pause during loads
    float missionTimer : 0x0524E7B8, 0x150, 0x10, 0x8B8; //SOMETIMES resets to 0 on mission load. Not always and no noticable pattern
    float missionTimer2 : 0x0524E7B8, 0x120, 0x10, 0x8B8;
    int xp : 0x051A6860, 0xC8; //Total Creed points 
}

state("ACU", "1.5.0") 
{
    //Only these four values are used so split and remove loads
    int currency : 0x0525BD10, 0x2D8, 0x0, 0x10, 0x70, 0x78, 0x0, 0x144; //Current currency
    int isLoading: 0x0522BB28, 0x68, 0x8, 0x28, 0x80, 0x30, 0x38, 0xFD0; //1 when loading 0 when not. Also detects first cutscene
    int missionComplete: 0x05219860, 0x2C, 0x40, 0x18, 0x10, 0x0, 0x168, 0x8; //1 if the accept mission complete rewards. 0 everywhere else
    int paused : 0x04F55598, 0xCC8;  //Detects pause and menu 1/0
    int startMenu : 0x05217280, 0xBC;  //Also detects pause and menu and title screen 256/0

    //Below values are not used but should work for 1.5.0
    //string5 versionNumber : 0x7FF4FD5E9AB0;
    int sync : 0x05196070, 0x40, 0x0, 0x1CC;
    int tabbedOut : 0x0521AA98, 0x80, 0x38; //1 is tabbed out, 0 is in game (May be related to game running or not. Unsure as of now)
    float gameTimer : 0x0524CFD8, 0x10, 0x18, 0x70, 0x0, 0x840, 0x108, 0x30; //Game Timer, pauses while in menus, does not pause during loads   Acts super weird and im not sure when it resets but it does sometimes
    //float missionTimer : 0x0524E7B8, 0x150, 0x10, 0x8B8; //SOMETIMES resets to 0 on mission load. Not always and no noticable pattern
    //float missionTimer2 : 0x0524E7B8, 0x120, 0x10, 0x8B8;
    int xp : 0x051B3E50, 0xC8; //Total Creed points 
    int syncPoints: 0x051B1BF0, 0x380, 0x10, 0x0, 0x18, 0x528, 0x200, 0x144; //Ability points - seems to detect first load of -1 like currency does. Changes to -1 when loading from server bridge to paris 
    int creedPoints: 0x0525BD10, 0x2F8, 0x0, 0x10, 0x70, 0x78, 0x0, 0x144; //Also detects first load as -1. not sure if this is useful or not tbh.
    int missionMenu: 0x0522BDE0, 0x38, 0x9E0; //Detects if the mission start or end menues are on the screen. Includes the menu with just the name of the mission but you are too far to accept. 
}

startup 
{
	refreshRate = 165;	//Increased to 120 since at 60 (default) splits can be missed if the player is too fast to accept the mission rewards. 
    vars.playingIntro = 0;  //Flag to detect if the opening intro has been watched or not.
    vars.prologue = 0;  //Determining if the prologue has been started or not. Needed for first split accuracy
    vars.split = 0;     //Tracks which split we are on
    vars.tabbedFlag = 0;      //Flag to detect if the game has been tabbed out at least once
    // Store all possible currency increases in vars.Money
    vars.Money = new int[] {100, 150, 250, 300, 350, 400, 450, 500, 750, 1000, 1350, 1500, 2000, 2500, 3000, 4000, 4500, 5000, 6000, 6500, 10000};

    // Create a new list containing the values of vars.Money
    vars.MoneyIncreased = new List<int>(vars.Money);
    
    //settings for hundo
    settings.Add("100%", false, "100% Splits") // 100% setting
    settings.Add("Chests", false, "Chests Splits", "100%") // Chests setting under 100% parent
    settings.Add("SyncPoints", false, "Sync Points Splits", "100%") // Sync Points setting under 100% parent   
    //settings.Add("", false, "", "")
}
                                                              
init 
{
    switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
        version = "1.5.0";
        break;
        case (129081344):
        version = "1.4.0";
        break;
    }
}

update 
{    //Used to update flags at the right time
    if (current.tabbedOut == 0 && vars.tabbedFlag == 0) {   //Tabbed out byte only activates once the game has been tabbed out of at least once
        vars.tabbedFlag = 1;
    }
    if (current.paused == 0 && old.paused == 13) {  //Detects when the first mission select screen appears after the first cutscene to enable load removal
        vars.playingIntro = 1;
    }
    if(vars.playingIntro == 1 && current.isLoading == 0 && old.isLoading == 1){ //Needed because sometimes loading into the prologue mission sets currency to -1 which would cause an early split
        vars.prologue = 1;
    }
    
    //print("IsLoading: " + current.isLoading + " Playing intro: " + vars.playingIntro + " Tabbed Out: " + current.tabbedOut);
}

onStart
{
    vars.split ++;
    vars.prologue = 1;
    vars.playingIntro = 1;
}


start {
    if(current.startMenu == 0 && old.startMenu == 256) {    //Starts splits on first menu close ie. clicking start on first main manu
        vars.playingIntro = 0;  //Flag to detect if the opening intro has been watched or not.
        vars.prologue = 0;  //Determining if the prologue has been started or not. Needed for first split accuracy
        vars.split = 0;     //Tracks which split we are on
        vars.tabbedFlag = 0;      //Flag to detect if the game has been tabbed out at least once      
        return true;
    }
}

split 
{
    //Splits when end of mission is accepted, also for most side missions such as heist, and coop missions
    if(current.missionComplete == 0 && old.missionComplete == 1) 
    { 
        vars.split ++;
        return true;
    }

    //Splits after prologue due to currency (or ability points) jumping up to 4294967295 (-1) during the load of the first mission
    if(current.currency == 0 && old.currency == -1 && vars.prologue == 1 && vars.split == 0) 
    { 
        vars.split ++;
        return true;
    }

    // Chest-related splits, checks if MoneyIncreased the difference between current and old currency
    if (settings["Chest"] && vars.MoneyIncreased.Contains(current.currency - old.currency)) {
        vars.split ++;
        return true;
    }

    // Sync points-related splits, check if Sync Points setting is enabled
    if (settings["SyncPoints"]) 
    {
        if (current.syncPoints == old.syncPoints + 1) 
        {
            vars.split ++;
            return true;
        }
    }
}

isLoading {
    if(current.isLoading == 1 && current.startMenu != 256 && vars.playingIntro == 1) //Pauses timer when loading. Only starts working after intro cutscene finishes because it is detected as a load for some reason
    {   
        return true;
    }
    else {
        return false;
    }
}


//assassin's creed syndicate load remover an autosplitter by TpRedNinja w/ DeathHound,AkiloGames, people from the speedrun development tool discord
//Support for Ubisoft Connect
//Support for Steam

//[9188] 157683712
//SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version 
state("ACS", "Ubisoft Connect")
{
    int Loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; //Detects if loading, 0 is not loading 1 is for loading
    int Endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; //Detects end mission sceen, 1 for end screen 0 for literally everything else
    int Cutscene: 0x715EBC0; //Detects cutscene value 0 in loading screen 1 no cutscene 2 for cutscene game and dlc is not a pointer just "ACS.exe" +(inserst address here)
    int Eviemain: 0x070E0BE8, 0x3C8, 0x980, 0x18, 0x38, 0x84, 0x330, 0x230; //Detects if your playing evie in the main game. 0 if false 2 if true.
    int Jacob: 0x070E0BE8, 0xD50, 0x18, 0x480, 0x38, 0x84, 0x390, 0x20; //Detects if your jacob. 0 if false 2 if true.
    int Character: 0x07155D78, 0xB20, 0xA0, 0x560, 0x140; //6 for evie 7 when not in london 8 for jack 9 when not in london.
    int Percentage: 0x07160A98, 0x40, 0x5C; //total completion of jack the ripper note does not work with main game
}

//[10848] 163323904
//SHA256: a2e6ca1504d172ca87f500d1d6cb1de97a2f6687f7ce77f661dce95e90c54e0e hash id for steam version 
state("ACS", "Steam")
{
    int Loading:0x070D7470, 0x4A0, 0x10, 0x368; //same as og but just in case if first one doesnt work
    int Endscreen: 0x07325DB0, 0x78, 0x3D0, 0x68; //1 for endscreen showing 0 for not
    int Cutscene: 0x7154FE0;  //same as ubi connect
    int Eviemain: 0x070D9A38, 0xD50, 0x2D0, 0x7C0, 0x38, 0x84, 0x108, 0x20; //same as ubi connect
    //int Eviebackup: 0x070D9A38, 0xD50, 0x300, 0x4A0, 0x38, 0x84, 0x3E0, 0x20; //same as ubi connect
    int Jacob: 0x07154AA8, 0x58, 0x6C8, 0x898, 0x78, 0x68, 0x30, 0x230; //same as ubi connect
    int Character: 0x071546C8, 0x18, 0x0, 0x308, 0x158; //same as ubi connect
    int Percentage: 0x07159920, 0x40, 0x5C;//same as ubi connect
}

startup
{
    //to control when the timer starts for the main game
    settings.Add("base", true, "Main Game");
    settings.Add("new_game", false, "New Game", "base");
    settings.Add("loaded_save", false, "Loaded Game Save", "base");
    settings.Add("levels", false, "Level runs", "base");

    //Settings to differeniate between base game and the dlc along with if u want it to split
    settings.Add("ripper", true, "Jack the Ripper");
    //Settings for Any% and 100% for the dlc
    settings.Add("Any%_DLC", false, "Any%", "ripper");
    settings.Add("100%_DLC", false, "100%", "ripper");
    
    //percentage display
    settings.Add("percentage display", false);

    //Settings tooltips 
    //Settings tooltips for the base game
    settings.SetToolTip("base", "Click this if you are speedrunning the base game");
    settings.SetToolTip("new_game", "Enable this if you are starting a any% or 100% run from a new game with no save attached");
    settings.SetToolTip("loaded_save", "Enable this if you are starting a any% or 100% run from a save where the first cutscene has fully played through");
    settings.SetToolTip("levels", "Enable this if you are gonna speedrun individual levels");
    
    //Settings tooltips for the DLC
    settings.SetToolTip("ripper", "Click this if you are speedrunning the dlc");
    settings.SetToolTip("Any%_DLC", "Enable this if you are doing a any% speedrun & using my any% splits");
    settings.SetToolTip("100%_DLC", "Enable this if you are doing a 100% speedrun & using the 100% route made by ector");

    // set text taken from Poppy Platime C2
    // to display the text associated with this script aka current percentage along with IGT
    Action<string, string> SetTextComponent = (id, text) => {
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
            var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
            var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
            timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

            textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
            textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }

        if (textSetting != null)
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    };
    
//Initalize variables
vars.SetTextComponent = SetTextComponent;
vars.completedsplits = new List<string>();
vars.MainMissions = new List<string>();
vars.JackMissions = new List<string>();
vars.PlusOne = new List<string>();
vars.PlusTwo = new List<string>();
}

init
{  
        switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
        version = "Ubisoft Connect";
        break;
        case (163323904):
        version = "Steam";
        break;
    } 
    
    //print(modules.First().ModuleMemorySize.ToString());
    
    if(settings["Any%_DLC"])
    {
        vars.MainMissions = new List<string> {  
            "The Autumn of Terror", 
            "Unfortunates", 
            "The Lady Talks", 
            "Letters of Intent",
            "The Mother of All Crimes",  
        };
        vars.JackMissions = new List<string> {
            "Prologue",
            "Prisoners",
            "Loose Ends",
            "Family Reunion"
        };
        }
    if(settings["100%_DLC"])
    {
        vars.MainMissions = new List<string> {
            "Prologue",
            "The Autumn of Terror", 
            "Unfortunates", 
            "The Lady Talks", 
            "Letters of Intent", 
            "Prisoners",
            "Loose Ends", 
            "The Mother of All Crimes",
            "Family Reunion",
            "Live by the Creed, Die by the Creed"  
        };
        vars.PlusOne = new List<string> {
            "Chest 1",//during Unfortunates
            "Buck's Row Brothel",
            "Chest 2",//during wood shinnings
            "Woody Shinnings",
            "Helix Glitch 1",// after The Lady Talks
            "Robert Donston Stephenson",
            "Helix Glitch 2",//during letters of Intent
            "Dear Boss",
            "Chest 3",//during prisoners
            "Saucy Jack",
            "Chest 4",//during the mother of all crimes
            "From Hell",
            "Walk of shame",
            "Helix Glitch 3",//during egyptian spoils
            "Jack's Lieutenants 1", 
            "Ludgate Hill Brothel",
            "David Jack-Emmings",
            "Chest 5", //during opium spoils
            "Opium Spoils",
            "Indian Emerald"
        };
        vars.PlusTwo = new List<string> {
            "Sweryn Klosowski",
            "Mitre Square Fight Club",
            "Shameful Abuse",
            "Gracechurch Street Brothel",
            "Egyptian Spoils",
            "Lost Women",
            "Lost in the City",
            "Cock Lane Fight Club",
            "Jack's Lieutenants 2",
            "John Pizer"
        };
    }  
}

update
{
    if (settings["percentage display"])
    {
    vars.SetTextComponent("Percentage Completion", "N/A");
    if (current.Percentage != null)
    vars.SetTextComponent("Percentage Completion", current.Percentage + "%");
    }
    //to debug shit
    //print("Completed splits: " + String.Join(",", vars.completedsplits));
    //print("completedsplits: " + vars.completedsplits);
    //print("any%splits: " + vars.split);
    //if (current.Character != old.Character || current.Cutscene != old.Cutscene || current.Loading != old.Loading)
   // {
   //print("Jack;" + " CurrentCharacter:" + current.Character + " OldCharacter:" + old.Character  + " Cutscene:" + current.Cutscene + " Loading:" + current.Loading);    
//}
    //print("Current splits: " + String.Join(", ", vars.MainMissions));
}

start
{

    //starts when you gain control of jacob from a fresh save
    if(settings["new_game"])
    {
        if(current.Loading == 0 && old.Loading == 0 && current.Jacob == 2 && current.Eviemain == 2)
        return true;
    }

    //starts when you gain control of jacob from loading a save past the first cutscene
    if(settings["loaded_save"])
    {
        if(old.Loading == 1 && current.Loading == 0 && current.Jacob == 2 && current.Eviemain == 0 )
             return true;
    }

    //starts when starting a level
    if(settings["levels"])
    {
        return old.Cutscene == 0 && (current.Cutscene == 1 || current.Cutscene == 2);
    }
}

/*splits when end mission screen disappears 
note if you want it to split on after the jack missions please select the ripper_# as those will allow it to split after the mission ends as jack*/
split
{   


    if(settings["Any%_DLC"])
        {
    //splits when end screen appears so when you are able to press "A" button or equivlent on keyboard and mouse for any%
        if(current.Endscreen == 1 && old.Endscreen == 0)
            {
            vars.completedsplits.Add(vars.MainMissions[0]);
            vars.MainMissions.RemoveAt(0);    
            return true;
                }
        if (current.percentage = old.percentage + 6)
                {
            vars.completedsplits.Add(vars.JackMissions[0]);
            vars.JackMissions.RemoveAt(0); 
            return true;
            }
        }
    if (settings["100%_DLC"])
    {
        if (current.percentage = old.percentage + 6)
        {
            vars.completedsplits.Add(vars.MainMissions[0]);
            vars.MainMissions.RemoveAt(0); 
            return true;
        }

        if (current.percentage = old.percentage + 1)
        {
            vars.completedsplits.Add(vars.PlusOne[0]);
            vars.PlusOne.RemoveAt(0); 
            return true;
        }

        if (current.percentage = old.percentage + 2)
        {
            vars.completedsplits.Add(vars.PlusTwo[0]);
            vars.PlusTwo.RemoveAt(0); 
            return true; 
        }
    }


}

isLoading
{
    //pauses during loading screen and unpauses when out of loading screens note black screens do not count as loading
    return current.Loading == 1;
}

onReset
{
    //Clears all lists execpt completed splits
    if (vars.MainMissions.count > 0 && vars.JackMissions.count > 0 && vars.PlusOne.count > 0 && vars.PlusTwo.count > 0)
    {
        vars.MainMissions.Clear();
        vars.JackMissions.Clear();
        vars.PlusOne.Clear();
        vars.PlusTwo.Clear();
    }
    if (vars.completedsplits.count > 0)
    {
        vars.completedsplits.Clear();
    }
}


//£
/*
2:25.86
2:07.47
5:49.75
2:13.16
2:00.20
2:54.51
5:33.99
3:49.60
5:22.47
2:46.94
6:27.91
3:07.42
3:10.35
2:16.67
7:19.54
2:38.88
3:14.85
3:09.88
3:25.59
7:45.75
2:43.55
1:50.08
6:08.98
1:44.37
3:36.26
3:39.43
3:46.48
2:04.75
3:02.83
4:06.48
6:53.32
*/

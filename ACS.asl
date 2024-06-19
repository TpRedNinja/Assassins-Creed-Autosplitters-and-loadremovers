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
    //Settings to splits after missions where you play as jack
    settings.Add("Prologue", false, "Prologue", "ripper");
    settings.Add("Loose Ends", false, "Loose Ends", "ripper");
    settings.Add("Family Reunion", false, "Family Reunion", "ripper");
    
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
    settings.SetToolTip("Prologue", "Enable this if you want to split after the prologue ends");
    settings.SetToolTip("Loose Ends", "Enable this if you want to split after you complete Loose Ends");
    settings.SetToolTip("Family Reunion", "Enable this if you want to split after you complete Family Reunion");

    vars.completedsplits = new List<string>();
    vars.split = new List<string>();
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
    vars.SetTextComponent = SetTextComponent;
    settings.Add("percentage display", false);


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
    //print("Current splits: " + String.Join(", ", vars.split));
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

onStart
{
    // Initialize vars.split based on selected settings
    if (settings["Any%_DLC"])
    {
        vars.split = new List<string> {  
            "The Autumn of Terror", 
            "Unfortunates", 
            "The Lady Talks", 
            "Letters of Intent", 
            "Prisoners", 
            "The Mother of All Crimes",  
        };
    }
    else if(settings["100%_DLC"])
    {
        vars.split = new List<string> {
            "The Autumn of Terror",
            "Unfortunates",
            "Buck's Row Brothel",
            "Woody Shinnings",
            "Sweryn Klosowski",
            "The Lady Talks",
            "Robert Donston Stephenson",
            "Letters of Intent",
            "Dear Boss",
            "Prisoners",
            "Mitre Square Fight Club",
            "Saucy Jack",
            "The Mother of All Crimes",
            "From Hell",
            "Shameful Abuse",
            "Walk of shame",
            "Gracechurch Street Brothel",
            "Egyptian Spoils",
            "Jack's Lieutenants 1", 
            "Lost Women",
            "Lost in the City",
            "Ludgate Hill Brothel",
            "Cock Lane Fight Club",
            "Jack's Lieutenants 2",
            "John Pizer",
            "David Jack-Emmings",
            "Opium Spoils",
            "Live by the Creed, Die by the Creed"
        };
    }  
}

/*splits when end mission screen disappears 
note if you want it to split on after the jack missions please select the ripper_# as those will allow it to split after the mission ends as jack*/
split
{   
    //splits when end screen appears so when you are able to press "A" button or equivlent on keyboard and mouse for any%
    if(current.Endscreen == 1 && old.Endscreen == 0)
    {
    return true;
    }

    //Splits for 100% after you accept the final mission end screen and the percentage goes to 100 assuming u got 100%
    if (vars.completedsplits.Contains("Family Reunion") && current.Percentage == 100 && settings["100%_DLC"])
    {
        return true;
    }

    //Splits after you complete the first mission Prologue approxmitly during the black screen after you skip the cutscene with jacob collecting his things in his safehouse
    if(settings["Prologue"])
    {
        if(!vars.completedsplits.Contains("Prologue") && current.Percentage > old.Percentage)
        {
            vars.completedsplits.Add("Prologue");
            return true;
        }
    }

    //splits after completeing the mission Loose Ends approxmitly after jack says "im looking forward to the family reunion" or when the ding sound plays
    if(settings["Loose Ends"])
    {
        if(!vars.completedsplits.Contains("Loose Ends") && vars.completedsplits.Contains("Prisoners") && current.Percentage == old.percentage + 6 )
        {
            vars.completedsplits.Add("Loose Ends");
            return true;
            }
    }

    //splits after completeing the mission Family Reunion approxmitly when the ding sound plays or when the last bit of jacks dialogue is played
    if(settings["Family Reunion"])
    {
        if (settings["Any%_DLC"])
        {
          if(!vars.completedsplits.Contains("Family Reunion") && vars.completedsplits.Contains("The Mother of all Crimes") && current.Percentage > old.Percentage)
            {
                vars.completedsplits.Add("Family Reunion");
                return true;
                }  
        } else
        {
            if(settings["100%_DLC"] && !vars.completedsplits.Contains("Family Reunion") && vars.completedsplits.Contains("Opium Spoils") && current.Percentage > old.Percentage)
            {
                vars.completedsplits.Add("Family Reunion");
                return true;
            }   
        }
    }
}

onSplit
{
    if (settings["Any%_DLC"])
    {
    vars.completedsplits.Add(vars.split[0]);
    vars.split.RemoveAt(0);
    }
    
    if (settings["100%_DLC"] && !vars.completedsplits.Contains("Family Reunion"))
    {
        vars.completedsplits.Add(vars.split[0]);
        vars.split.RemoveAt(0);
    }else
    {
        if (vars.completedsplits.Contains("Family Reunion") && current.Percentage == 100 && settings["100%_DLC"])
        {
        vars.completedsplits.Add(vars.split[0]);
        vars.split.RemoveAt(0);
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
    //Clear vars.split
    vars.completedsplits.Clear();

    //Clear vars.split
    vars.split.Clear();

    //Re-add each split individually to vars.split if it's empty or less then the max & Any% setting is enabled
    if (vars.split.Count == 0 && settings["Any%_DLC"])
    {
        vars.split.Add("The Autumn of Terror");
        vars.split.Add("Unfortunates");
        vars.split.Add("The Lady Talks");
        vars.split.Add("Letters of Intent");
        vars.split.Add("Prisoners");
        vars.split.Add("The Mother of All Crimes");
        vars.split.Add("Live by the Creed, Die by the Creed");
    }
    // Re-add each split individually to vars.split if it's empty or less then the max & 100% ALT setting is enabled
    if (vars.split.Count == 0 && settings["100%_DLC"])
    {
        vars.split.Add("The Autumn of Terror");
        vars.split.Add("Unfortunates");
        vars.split.Add("Buck's Row Brothel");
        vars.split.Add("Woody Shinnings");
        vars.split.Add("Sweryn Klosowski");
        vars.split.Add("The Lady Talks");
        vars.split.Add("Robert Donston Stephenson");
        vars.split.Add("Letters of Intent");
        vars.split.Add("Dear Boss");
        vars.split.Add("Prisoners");
        vars.split.Add("Mitre Square Fight Club");
        vars.split.Add("Saucy Jack");
        vars.split.Add("The Mother of All Crimes");
        vars.split.Add("From Hell");
        vars.split.Add("Shameful Abuse");
        vars.split.Add("Walk of shame");
        vars.split.Add("Gracechurch Street Brothel");
        vars.split.Add("Egyptian Spoils");
        vars.split.Add("Jack's Lieutenants 1");
        vars.split.Add("Lost Women");
        vars.split.Add("Lost in the City");
        vars.split.Add("Ludgate Hill Brothel");
        vars.split.Add("Cock Lane Fight Club");
        vars.split.Add("Jack's Lieutenants 2");
        vars.split.Add("John Pizer");
        vars.split.Add("David Jack-Emmings");
        vars.split.Add("Opium Spoils");
        vars.split.Add("Live by the Creed, Die by the Creed");
    }
}

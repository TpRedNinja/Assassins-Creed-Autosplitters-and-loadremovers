// Assassins Creed III & Liberation Remastered autosplitter & load remover made by TpRedNinja
// People who helped me: Akilogames, DeathHound, Mysterion and his tutorial, a lot of people from the speedrun tool development discord server

//[133480] 59396096 
state("ACIII", "AC3 Steam")
{
    int IsLoading: 0x03269D90, 0x468, 0xB0, 0xC8, 0x370; // 0 for not loading and 1 for loading note the cutscene with connor cutting his hair counts as loading
    int percentage: 0x03269D88, 0xC60, 0xB18, 0x690, 0x4; // displays current percentage complete note does not work with tyranny of king washington as it displays 24 for some reason
    int IGT: 0x03203510, 0x850, 0x8, 0x3D8, 0x80; // Uses the built in timer for each save file note its in seconds for display but can be used for the timer.
    int MissionComplete: 0x32C2270;
}
//[133480] 53477376 
state("ACLiberation", "ACL Steam")
{
    int percentage: 0x02C0EC88, 0x280, 0x10, 0x2CC; // detects overall completion % value
    int menu: 0x02BCB4C0, 0x80, 0xC0, 0x4DC; // detects if you're in a menu or in-game/cutscene. 32756 when in pause menu or loading & main, any other number below when not, note when selecting save it's below 32756.
    int pausemenu: 0x2C0EDD0; // detects if you're in the pause menu. 1 for if you are 0 if you aren't
    int IGT: 0x2C0D0B0; // somehow game time is 4 bytes idk why.
    // Note IGT // it will pause if the pause menu is open or if you go back to the main menu
    // int mainmenu: 0x02BC5D48, 0x818, 0x678, 0xF9C; // tells whether you're in the main menu or not, currently useless as it only shows 1 number all the time
    int IsLoading: 0x02BDAC70, 0xBB0, 0xA28, 0x10, 0xF58; // detects if you're in the loading screen or not, 1 for is 0 for not, IGT goes on during unskippable cutscene and cutscene isn't considered loading
    int currency: 0x02C26C80, 0x478, 0xB0, 0x98; // detects currency, becomes 4294967295 when loading into the game but changes back, but when leaving the game it becomes ??
    int cutscene: 0x02BC8010, 0x748, 0x2E0, 0xC8, 0x78; // detects skippable and nonskippable cutscenes
    /*
    Notes for cutscene: 3 is in-game as a child and after the second mission with assassin persona,- 
    6 is skippable as a child. 8 is nonskippable as all personas or just assassin. Got 123 when starting 2nd mission before the unskippable. -
    When swapped to slave persona was 1 in the game and 23 as skippable. -
    When as a lady persona 1 in the game, 138 for skippable cutscene, 1 back in the game after the mission of getting the clothes-
    (and 160 and 132 in the game and) during skippable cutscene of getting clothes for the slave that you rescued and at the end of the mission-
    101 during skippable cutscene first mission after being able to free roam 5 in tailing mission it's now 5 in free roam
    */
}
//[133480] 59396096 
state("ACIII", "AC3 UbisoftConnect")
{
    int IsLoading: 0x03206FC8, 0x48, 0x2F8, 0x38, 0x30;
    int percentage: 0x03269CC8, 0xC20, 0xB40, 0x6B8, 0x4;
    int IGT: 0x03203450, 0x738, 0x2B0, 0x398, 0x80; //stops when in pausemenu during loading it doesnt for some reason.
    int MissionComplete: 0x32C21B0; //detects the mission end screen but does not detect sequence complete. 0 for false 1 for true
    int Cutscene: 0x03269CD0, 0x1A8, 0x88, 0x0, 0x928; //0 when first in the main menu but 4 for when no cutscene adn 65540 or something like that during a cutscene
}

state("ACLiberation", "ACL UbisoftConnect")
{
    int percentage: 0x02BC5F00, 0x2D0, 0xEC;
    int menu: 0x02BC7F50, 0x74C; // same condition as steam 
    int pausemenu: 0x02C0ED10; // just an address does changing persona's screen as paused
    int IGT: 0x02C0CF00, 0xE8; // steam was just an address Ubisoft is a full-on pointer
    // int mainmenu:; currently, I can't find, maybe I can find but seems kinda useless currently
    int IsLoading: 0x02C26F98, 0x0, 0x200;
    int currency: 0x02C26BC0, 0xB0, 0x98;
    // int cutscene:;
}

startup
{
    // credit to deathhound246 on discord for allowing me to copy some of the code from the RE2R autosplitter. was very helpful in making this.
    // ubisoft connect hash id(ACL): SHA256: 7a4b62b1ebe7ce7b5a54d7265ba8a0e1a3151c6c3ab87342506d359429c075c9
    vars.aclubisoftconnect = new byte[32]{ 0x7a, 0x4b, 0x62, 0xb1, 0xeb, 0xe7, 0xce, 0x7b, 0x5a, 0x54, 0xd7, 0x26, 0x5b, 0xa8, 0xa0, 0xe1, 0xa3, 0x15, 0x1c, 0x6c, 0x3a, 0xb8, 0x73, 0x42, 0x50, 0x6d, 0x35, 0x94, 0x29, 0xc0, 0x75, 0xc9 };
    // ubisoft connect hash id(ACIII): SHA256: 8e414119ee22d300b4acdaa5a15fd2d02482b7a51ba803370618920a94a1dc0d
    vars.ac3ubisoftconnect = new byte[32]{ 0x8e, 0x41, 0x41, 0x19, 0xee, 0x22, 0xd3, 0x00, 0xb4, 0xac, 0xda, 0xa5, 0xa1, 0x5f, 0xd2, 0xd0, 0x24, 0x82, 0xb7, 0xa5, 0x1b, 0xa8, 0x03, 0x37, 0x06, 0x18, 0x92, 0x0a, 0x94, 0xa1, 0xdc, 0x0d };
    // steam hash id: SHA256(ACL): 87836d1759dd4dae57eff66aa170c07c4c5e6b817632379e493d2929adebe947
    vars.aclsteam = new byte[32]{ 0x87, 0x83, 0x6d, 0x17, 0x59, 0xdd, 0x4d, 0xae, 0x57, 0xef, 0xf6, 0x6a, 0xa1, 0x70, 0xc0, 0x7c, 0x4c, 0x5e, 0x6b, 0x81, 0x76, 0x32, 0x37, 0x9e, 0x49, 0x3d, 0x29, 0x29, 0xad, 0xeb, 0xe9, 0x47 };
    // steam hash id(ACIII): SHA256: 450b76dea323089077a8bb8f0a9bafd3b7c02f48a46de48811f2f00b63aa13d1
    vars.ac3steam = new byte[32]{ 0x45, 0x0b, 0x76, 0xde, 0xa3, 0x23, 0x08, 0x90, 0x77, 0xa8, 0xbb, 0x8f, 0x0a, 0x9b, 0xaf,0xd3, 0xb7, 0xc0, 0x2f, 0x48, 0xa4, 0x6d, 0xe4, 0x88, 0x11, 0xf2, 0xf0, 0x0b, 0x63, 0xaa, 0x13, 0xd1 };

    // calculates the hash id for the current module credit to the re2r autosplitter & deathHound246 on discord for this code 
    Func<ProcessModuleWow64Safe, byte[]> CalcModuleHash = (module) => {
        print("Calculating hash of " + module.FileName);
        byte[] checksum = new byte[32];
        using (var hashFunc = System.Security.Cryptography.SHA256.Create())
            using (var fs = new FileStream(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                checksum = hashFunc.ComputeHash(fs);
        return checksum;
    };
    vars.CalcModuleHash = CalcModuleHash;

    // setting to choose which game your playing
    settings.Add("Game", true);
    settings.SetToolTip("Game", "Choose if you are playing Assassins Creed 3 Remastered or Liberation Remastered");
    
    // settings to choose how ac3 and acl autosplitter work
    settings.Add("Assassin's Creed III Remastered", false, "Assassin's Creed III Remastered", "Game");
    settings.SetToolTip("Assassin's Creed III Remastered", "Choose this if you are playing Assassin's Creed III Remastered");
    settings.Add("Assassin's Creed Liberation Remastered", false, "Assassin's Creed Liberation Remastered", "Game");
    settings.SetToolTip("Assassin's Creed Liberation Remastered", "Choose this if you are playing Assassin's Creed Liberation Remastered");
    
    //sequence settings for Assassin's Creed III Remastered
    settings.Add("Sequence 1_AC3", false, "Sequence 1_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 2_AC3", false, "Sequence 2_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 3_AC3", false, "Sequence 3_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 4_AC3", false, "Sequence 4_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 5_AC3", false, "Sequence 5_AC3","Assassin's Creed III Remastered");
    settings.Add("Modern day 1", false, "Modern day 1","Assassin's Creed III Remastered");
    settings.Add("Sequence 6_AC3", false, "Sequence 6_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 7_AC3", false, "Sequence 7_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 8_AC3", false, "Sequence 8_AC3","Assassin's Creed III Remastered");
    settings.Add("Modern day 2", false, "Modern day 2","Assassin's Creed III Remastered");
    settings.Add("Sequence 9_AC3", false, "Sequence 9_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 10_AC3", false, "Sequence 10_AC3","Assassin's Creed III Remastered");
    settings.Add("Sequence 11_AC3", false, "Sequence 11_AC3","Assassin's Creed III Remastered");
    settings.Add("Modern day 3", false, "Modern day 3","Assassin's Creed III Remastered");
    settings.Add("Sequence 12_AC3", false, "Sequence 12_AC3","Assassin's Creed III Remastered");
    settings.Add("Modern day 4", false, "Modern day 4","Assassin's Creed III Remastered");

    //sequence settings for Assassin's Creed Liberation Remastered
    settings.Add("Sequence 1_ACL", false, "Sequence 1_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 2_ACL", false, "Sequence 2_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 3_ACL", false, "Sequence 3_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 4_ACL", false, "Sequence 4_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 5_ACL", false, "Sequence 5_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 6_ACL", false, "Sequence 6_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 7_ACL", false, "Sequence 7_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 8_ACL", false, "Sequence 8_ACL","Assassin's Creed Liberation Remastered");
    settings.Add("Sequence 9_ACL", false, "Sequence 9_ACL","Assassin's Creed Liberation Remastered");

    //Literally a setting to split on every mission
    settings.Add("Mission", true, "Mission", "Game");
    settings.SetToolTip("Mission", "Choose this if you want to split after a mission is completed will not split for modern day sections only for ac3");
    settings.Add("Mission_acl", true, "Mission_acl", "Game");
    settings.SetToolTip("Mission", "Choose this if you want acl to split after a mission is completed");
    // Asks the user if they want to change to game time if the comparison is set to real time on startup.
    if(timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show(
            "This Autosplitter has a load removal Time without loads. "+
            "LiveSplit is currently set to display and compare against Real Time (including loads).\n\n"+
            "Would you like the timing method to be set to Game Time?",
            "Assassin's Creed III Remastered/Liberation Remastered | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    };

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
}

init
{
    // Detects the game version based on SHA-256 hash for Assassin's Creed III & Liberation Remastered
    byte[] checksum = vars.CalcModuleHash(modules.First());
    if (Enumerable.SequenceEqual(checksum, vars.aclsteam))
        version = "ACL Steam";
    else if(Enumerable.SequenceEqual(checksum, vars.aclubisoftconnect)) 
        version = "ACL UbisoftConnect";
    else if (Enumerable.SequenceEqual(checksum, vars.ac3steam))
        version = "AC3 Steam";
    else if(Enumerable.SequenceEqual(checksum, vars.ac3ubisoftconnect)) 
        version = "AC3 UbisoftConnect";
}

update
{
    print(modules.First().ModuleMemorySize.ToString());
    vars.SetTextComponent("Percentage Completion", "N/A");
    if (current.percentage != null)
        vars.SetTextComponent("Percentage Completion", current.percentage + "%");
}

start
{
    // starts when first skippable cutscene appears should be no delay
    // TODO: We shouldn't be doing a < comparison here. We should know the values it can be
    if (settings["Assassin's Creed Liberation Remastered"])
        return current.IsLoading == 0 && current.menu == 0 && current.IGT > 0 && current.percentage == 0;

    //starts when you have control of desmond hopefully
    if(settings["Assassin's Creed III Remastered"])
        return current.IsLoading == 0 && old.IsLoading == 1;
}

split
{
    // splits after every mission that gives you percentage note some missions dont have a end mission screen so make sure you have enough splits
    if(settings["Mission"])
    {
    if(current.MissionComplete == 1 && old.MissionComplete == 0){
        return true;
        };
    }
    if (settings["Mission_acl"])
    {
        if (current.percentage > old.percentage)
        {
            return true;
        }
    }
    //all splits down split base off what the ending percentage is, very expiermental as if you miss certain objectives it could not split. Note is only for ac3
    if(settings["Sequence 1_AC3"])
    {if(current.percentage == 2 && old.percentage == 1 ){
        return true;
        }
    }

   /* if(settings["Sequence 2_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 3_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 4_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 5_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Modern day 1"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 6_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 7_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 8_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Modern day 2"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 9_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 10_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 11_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Modern day 3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }

    if(settings["Sequence 12_AC3"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    }
    //final split should ideally split once you lose control of desmond
    if(settings["Modern day 4"])
    {if(current.percentage ==  && old.percentage ==  ){
        return true;
        }
    } */
    //All splits down will split upon ending of a sequence. Note it might not split for you as i used the wr run for any% as the base of what the percentage complete is. Sense each mission gives you 1% and every optional objective also gives you plus 1 i did it base off of wr run and what he got and didnt get. Please remember this is expiermental.
    if(settings["Sequence 1_ACL"])
    {if(current.percentage == 13 && old.percentage == 12 ){
        return true;
        }
    }

    if(settings["Sequence 2_ACL"])
    {if(current.percentage == 24 && old.percentage == 23 ){
        return true;
        }
    }

    if(settings["Sequence 3_ACL"])
    {if(current.percentage == 38 && old.percentage == 37 ){
        return true;
        }
    }

    if(settings["Sequence 4_ACL"])
    {if(current.percentage == 50 && old.percentage == 49 ){
        return true;
        }
    }

    if(settings["Sequence 5_ACL"])
    {if(current.percentage == 59 && old.percentage == 58 ){
        return true;
        }
    }   

    if(settings["Sequence 6_ACL"])
    {if(current.percentage == 61 && old.percentage == 60 ){
        return true;
        }
    }

    if(settings["Sequence 7_ACL"])
    {if(current.percentage == 67 && old.percentage == 66 ){
        return true;
        }
    }

    if(settings["Sequence 8_ACL"])
    {if(current.percentage == 69 && old.percentage == 68 ){
        return true;
        }
    }
    //splits when the mission end screen shows so way after you suppose to end the timer so manually split until i find a way to remedy this
    if(settings["Sequence 9_ACL"])
    {if(current.percentage == 75 && old.percentage == 74 ){
        return true;
        }
    }                
}

isLoading
{
    /*
    detects address if it equals 1 as well if the game time is pasued as well as the menu equaling 32756 
    as the timer should only pause during loading screens not any menu which is why we have pausemenu to be 0 as that equals false 
    and we dont want the pause menu or anything else that the game considers pausemenu to pause the timer
    pauses during loading screens,condition to pause during a unskippable is at the bottom just add a || and do (current.cutscene == 8)
    */
    if(settings["Assassin's Creed Liberation Remastered"])
        return current.IsLoading == 1 && current.IGT == old.IGT && current.menu == 32756 && current.pausemenu == 0;

    // detects when game is loading note for some reason death confessions count as loading as well as when connor is putting on his warrior tats at the end of sequence 11 during that cutscene
    if(settings["Assassin's Creed III Remastered"])
        return current.IsLoading == 1 && old.IsLoading == 0 && current.IGT == old.IGT;
}

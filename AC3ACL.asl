// Assassins Creed III & Liberation Remastered autosplitter & load remover made by TpRedNinja
// People who helped me: Akilogames, DeathHound, Mysterion and his tutorial, a lot of people from the speedrun tool development discord server

//[133480] 59396096 
state("ACIII", "AC3 Steam")
{
    bool IsLoading: 0x03269D90, 0x468, 0xB0, 0xC8, 0x370; // 0 for not loading and 1 for loading note the cutscene with connor cutting his hair counts as loading
    int percentage: 0x0324C588, 0x330, 0x10, 0x18, 0x15C; // displays current percentage complete note does not work with tyranny of king washington as it displays 24 for some reason
    int IGT: 0x03203510, 0x850, 0x8, 0x3D8, 0x80; // Uses the built in timer for each save file note its in seconds for display but can be used for the timer.
    int MissionComplete: 0x32C2270;
    bool menu: 0x324CA20; // 1 for in any menu 0 for not in a menu
}
//[133480] 53477376 
state("ACLiberation", "ACL Steam")
{
    int percentage: 0x02C0EC88, 0x280, 0x10, 0x2CC; // detects overall completion % value
    int menu: 0x02BCB4C0, 0x80, 0xC0, 0x4DC; // detects if you're in a menu or in-game/cutscene. 32756 when in pause menu or loading & main, any other number below when not, note when selecting save it's below 32756.
    int pausemenu: 0x2C0EDD0; // detects if you're in the pause menu. 1 for if you are 0 if you aren't
    int IGT: 0x2C0D0B0; // somehow game time is 4 bytes idk why.
    // Note IGT // it will pause if the pause menu is open or if you go back to the main menu
    bool IsLoading: 0x02BDAC70, 0xBB0, 0xA28, 0x10, 0xF58; // detects if you're in the loading screen or not, 1 for is 0 for not, IGT goes on during unskippable cutscene and cutscene isn't considered loading
    int currency: 0x02C26C80, 0x478, 0xB0, 0x98; // detects currency, becomes 4294967295 when loading into the game but changes back, but when leaving the game it becomes ??
}
//[133480] 59396096 
state("ACIII", "AC3 UbisoftConnect")
{
    bool IsLoading: 0x03206FC8, 0x48, 0x2F8, 0x38, 0x30; // same as steam
    int percentage: 0x0324C4C8, 0x330, 0x10, 0x18, 0x15C; // same as steam
    int IGT: 0x03203450, 0x738, 0x2B0, 0x398, 0x80; // same as steam
    int MissionComplete: 0x32C21B0; //same as steam
    bool menu: 0x324C960; // same as steam
}

state("ACLiberation", "ACL UbisoftConnect")
{
    int percentage: 0x02BC5F00, 0x2D0, 0xEC;
    int menu: 0x02BC7F50, 0x74C; // same as steam
    int pausemenu: 0x02C0ED10; // same as steam
    int IGT: 0x2C0CFF0; // same as steam
    bool IsLoading: 0x02C26F98, 0x0, 0x200; // same as steam
    int currency: 0x02C26BC0, 0xB0, 0x98; // same as steam
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
    vars.ac3steam = new byte[32]{ 0x45, 0x0b, 0x76, 0xde, 0xa3, 0x23, 0x08, 0x90, 0x77, 0xa8, 0xbb, 0x8f, 0x0a, 0x9b, 0xaf, 0xd3, 0xb7, 0xc0, 0x2f, 0x48, 0xa4, 0x6d, 0xe4, 0x88, 0x11, 0xf2, 0xf0, 0x0b, 0x63, 0xaa, 0x13, 0xd1 };

    // calculates the hash id for the current module credit to the re2r autosplitter & deathHound246 on discord for this code 
    Func<ProcessModuleWow64Safe, byte[]> CalcModuleHash = (module) => 
    {
        print("Calculating hash of " + module.FileName);
        byte[] checksum = new byte[32];
        using (var hashFunc = System.Security.Cryptography.SHA256.Create())
            using (var fs = new FileStream(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                checksum = hashFunc.ComputeHash(fs);
        return checksum;
    };
    vars.CalcModuleHash = CalcModuleHash;


    //Literally a setting to split on every mission
    settings.Add("Splitting", false, "Splitting");
        settings.Add("Mission", true, "Mission", "Splitting");
        settings.SetToolTip("Mission", "Choose this if you want to split after a mission is completed. \n" + "will not split for modern day sections");
        settings.Add("Some Missions", false, "Some Missions", "Splitting");
        settings.SetToolTip("Some Missions", "Choose this if you want to split after some missions are completed. \n" + "will not split for liberation\n" +
        "Missions it will split on: ");

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
    vars.game = "None";
}

init
{
    // Detects the game version based on SHA-256 hash for Assassin's Creed III & Liberation Remastered
    byte[] checksum = vars.CalcModuleHash(modules.First());
    if (Enumerable.SequenceEqual(checksum, vars.aclsteam))
    {
        version = "ACL Steam";
        vars.game = "ACL";
    } else if(Enumerable.SequenceEqual(checksum, vars.aclubisoftconnect))
    { 
        version = "ACL UbisoftConnect";
        vars.game = "ACL";
    } else if (Enumerable.SequenceEqual(checksum, vars.ac3steam))
    {
        version = "AC3 Steam";
        vars.game = "AC3";
    } else if(Enumerable.SequenceEqual(checksum, vars.ac3ubisoftconnect))
    { 
        version = "AC3 UbisoftConnect";
        vars.game = "AC3";
    } else
    {
        version = "Unknown";
        vars.game = "None";
    }
}

start
{
    // starts when first skippable cutscene appears should be no delay
    if (vars.game == "ACL" && !current.IsLoading && current.menu == 0 && current.IGT > 0 && old.IGT == 0 && current.percentage == 0)
    {
        return true;
    }

    //starts when you have control of desmond hopefully
    if(vars.game == "AC3" && !current.IsLoading && current.percentage == 0 && !current.menu)
    {
        return true;
    }
}

split
{
    // splits after every mission that gives you percentage note some missions dont have a end mission screen so make sure you have enough splits
    if(current.percentage > old.percentage && settings["Mission"])
    {
        return true;
    }

    if (vars.game == "AC3" && current.MissionComplete == 1 && old.MissionComplete == 0 && settings["Some Missions"])
    {
        return true;
    }

}

isLoading
{
   return current.IsLoading;
}


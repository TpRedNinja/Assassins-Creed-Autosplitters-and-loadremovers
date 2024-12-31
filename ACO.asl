state("ACOrigins", "Uplay")
{
    int xp: 0x04CBB3D8, 0x168, 0x0, 0x11C;
    int loading: 0x42B7668;
}

state("ACOrigins", "Steam")
{
    int xp: 0x04C5AAD8, 0x168, 0x0, 0x11C;
    int loading: 0x4299998;
}

startup
{
    //sets of the different xp values for the main game and the dlcs for splitting
    //vars.MainGameNGPlus = new HashSet<int>{1000, 1250, 1500, 2250, 2500, 3000, 3500, 6000, 7500, 9600};
    vars.MainGame = new HashSet<int>{500, 900, 1000, 1250, 1500, 2250, 2500, 3000, 3500, 6000, 7500, 9600};
    vars.HiddenOnes = new HashSet<int>{22500, 10000, 15000, 15050};
    vars.CurseOfThePharaohs = new HashSet<int>{4000, 5000, 7000, 8000, 10000, 20000, 30000};
    
    //hashes for the different versions of the game
    vars.Ubisoft = new byte[32]{0xc3, 0x1d, 0xc1, 0xb8, 0xc4, 0x51, 0x89, 0xb5, 0x2f, 0xa5, 0x77, 0x3a, 0x4f, 0x15, 0xcc, 0xcf, 0x65, 0xec, 0xc1, 0x1b, 0x83, 0xf5, 0x47, 0x14, 0xce, 0x5f, 0x0b, 0x57, 0xa9, 0x44, 0xf9, 0x76};
    vars.Steam = new byte[32]{0x56, 0xaf, 0x8a, 0x6f, 0x85, 0xe2, 0x3f, 0x84, 0xd7, 0x71, 0xdd, 0x60, 0xbf, 0xd5, 0xd7, 0xe6, 0x95, 0xf5, 0x57, 0x20, 0x9c, 0xa9, 0x2a, 0x13, 0xf8, 0xac, 0x61, 0xb5, 0x20, 0xdf, 0x0d, 0x9f};
    
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

    //Settings for splits
    settings.Add("MainStory", false);
    settings.SetToolTip("MainStory", "Enable this option if you are speedrunning the main game");
    settings.Add("DLC", false);
    settings.SetToolTip("DLC", "Enable this option if you are speedrunning the DLC");
    settings.Add("HiddenOnes", false, "Hidden Ones", "DLC");
    settings.SetToolTip("HiddenOnes", "Enable this option if you are speedrunning the Hidden Ones DLC");
    settings.Add("CurseOfThePharaohs", false, "Curse of the Pharaohs", "DLC");
    settings.SetToolTip("CurseOfThePharaohs", "Enable this option if you are speedrunning the Curse of the Pharaohs DLC");
}

init
{
    // Detects the game version based on SHA-256 hash for Assassin's Creed Origins for steam and uplay
    byte[] checksum = vars.CalcModuleHash(modules.First());
    if (Enumerable.SequenceEqual(checksum, vars.Ubisoft))
        version = "Ubisoft";
    else if(Enumerable.SequenceEqual(checksum, vars.Steam)) 
        version = "Steam";
    else
    {
        version = "Unknown";
    }
}

split
{
    //Splits for the main game when current xp - old xp value is in the set
    if (settings["MainStory"])
    {
        if (vars.MainGame.Contains(current.xp - old.xp))
        {
            return true;
        }
    }

    //Splits for the Hidden Ones DLC when current xp - old xp value is in the set
    if (settings["HiddenOnes"])
    {
        if (vars.HiddenOnes.Contains(current.xp - old.xp))
        {
            return true;
        }
    }

    //Splits for the Curse of the Pharaohs DLC when current xp - old xp value is in the set
    if (settings["CurseOfThePharaohs"])
    {
        if (vars.CurseOfThePharaohs.Contains(current.xp - old.xp))
        {
            return true;
        }
    }
}

isLoading
{
    return current.loading == 1;
}

/*

List Experience Thresholds

 Level    Threshold
   1            0
   2         1000
   3         2100
   4         3300
   5         4600
   6         6000
   7         7500
   8         9100
   9        10800
  10        12600
  11        14500
  12        16900
  13        19800
  14        23200
  15        27100
  16        31500
  17        36400
  18        41800
  19        47700
  20        54100
  21        61000
  22        68400
  23        76300
  24        84700
  25        93600
  26       103000
  27       113400
  28       124800
  29       137200
  30       150600
  31       165000
  32       180400
  33       196800
  34       214200
  35       232600
  36       252000
  37       272400
  38       293800
  39       316200
  40       339600
  41       364000
  42       389400
  43       415800
  44       443200
  45       471600
  46       501000
  47       531400
  48       562800
  49       595200
  50       628600
  51       663000
  52       698400
  53       734800
  54       772200
  55       810600

*/

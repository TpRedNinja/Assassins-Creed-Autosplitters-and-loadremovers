state("ACBlackFlag")
{
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.aslVersion = "1.0.9"; // version variable

    // settings
    settings.Add("Debug", false, "Debug");
    settings.Add("Any%", true, "Any%");
    settings.SetToolTip("Any%", "Splits for all the main missions in the game");
    settings.Add("extra splits", false, "extra splits");
        settings.Add("A Proper Shipwright", false, "A Proper Shipwright", "extra splits");
        settings.SetToolTip("A Proper Shipwright", "Splits when you complete A Proper Shipwright quest");
        settings.Add("The One With the Gun", false, "Lucy Baldwin Recruited", "extra splits");
        settings.SetToolTip("The One With the Gun", "Splits when Lucy Baldwin is recruited");
        settings.Add("The Siege of Charles-Town_35", false, "Siege of Charles-Town extra", "extra splits");
        settings.SetToolTip("The Siege of Charles-Town_35", "Splits after the cutscene with bonnet");
        settings.Add("Do Not Go Gently..._05", false, "Do Not Go Gently extra 1", "extra splits");
        settings.SetToolTip("Do Not Go Gently..._05", "Splits after starting the mission");
        settings.Add("Do Not Go Gently..._11", false, "Do Not Go Gently extra 2", "extra splits");
        settings.SetToolTip("Do Not Go Gently..._11", "Splits after the cutscene with the Black Beard treasure map");
        settings.Add("Imagine My Surprise_SQ9_M05", false, "Imagine My Surprise extra", "extra splits");
        settings.SetToolTip("Imagine My Surprise_SQ9_M05", "Splits after the cutscene with Jack Racham going back to retirement");
        settings.Add("Trust is Earned_15", false, "Trust is Earned extra", "extra splits");
        settings.SetToolTip("Trust is Earned_15", "Splits once you start the mission");
        settings.Add("Everything is Permitted_25", false, "Everything is Permitted extra", "extra splits");
        settings.SetToolTip("Everything is Permitted_25", "Splits after the cutscene with Adawale after u wake up from being drunk");
        settings.Add("Royal Misfortune_15", false, "Royal Misfortune extra", "extra splits");
        settings.SetToolTip("Royal Misfortune_15", "Splits when you start the mission");
        settings.Add("Tainted Blood_25", false, "Tainted Blood extra", "extra splits");
        settings.SetToolTip("Tainted Blood_25", "Splits when you start the mission");
    timer.Run.Metadata.SetCustomVariable("Version", vars.aslVersion);

    vars.completedsplits = new List<string>();
    vars.TotalTimeWatch = new Stopwatch();

    vars.MainMissions = new Dictionary<string, List<int>>
    {
        //the missions only have 2 offsets that are the same the first one and the last one. The missions aren't in order in the array so the offsets for the mission
        // order is fucked so thats why the first missions Edward Kenway is d88 and then the second is 98 and then the third is 16c8
        {"Edward Kenway", new List<int> {0x88, 0xD88, 0x20}},
        {"Lively Havana", new List<int> {0x88, 0x98, 0x20}},
        {"...And My Sugar?", new List<int> {0x88, 0x16C8, 0x20}},
        {"Mister Walpole, I Presume?", new List<int> {0x88, 0xD8, 0x20}},
        {"A Man They Call the Sage", new List<int> {0x88, 0x19C8, 0x20}},
        {"Claiming What's Due", new List<int> {0x88, 0xE78, 0x20}},
        {"The Treasure Fleet", new List<int> {0x88, 0x1928, 0x20}},
        {"This Tyro Captain", new List<int> {0x88, 0xC78, 0x20}},
        {"Now Hiring", new List<int> {0x88, 0x1138, 0x20}},
        {"Prizes and Plunder", new List<int> {0x88, 0x8F8, 0x20}},
        {"Raise the Black Flag", new List<int> {0x88, 0xDE8, 0x20}},
        {"Sugarcane and Its Yields", new List<int> {0x88, 0x18F8, 0x20}},
        {"Proper Defense", new List<int> {0x88, 0x1198, 0x20}},
        {"A Single Madman", new List<int> {0x88, 0x1BB8, 0x20}},
        {"This Old Cove", new List<int> {0x88, 0x1828, 0x20}},
        {"A Proper Shipwright", new List<int> {0x88, 0x18E8, 0x20}},
        {"The One With the Gun", new List<int> {0x88, 0x1178, 0x34, 0x40, 0x20}},
        {"Nothing is True...", new List<int> {0x88, 0x1898, 0x20}},
        {"The Sage's Buried Secret", new List<int> {0x88, 0x238, 0x20}},
        {"Overrun and Outnumbered", new List<int> {0x88, 0x11F8, 0x20}},
        {"The Forts", new List<int> {0x88, 0xDC8, 0x20}},
        {"Traveling Salesman", new List<int> {0x88, 0x1388, 0x20}},
        {"Unmanned", new List<int> {0x88, 0x638, 0x20}},
        {"Diving For Medicines", new List<int> {0x88, 0x15C8, 0x20}},
        {"Devil's Advocate", new List<int> {0x88, 0x1B38, 0x20}},
        {"The Siege of Charles-Town_35", new List<int> {0x88, 0x1C8, 0x20}}, // theirs 2 of these idk why so have to test which one is more ideal then the other
        {"The Siege of Charles-Town", new List<int> {0x88, 0x318, 0x20}}, // main split
        {"We Demand a Parley", new List<int> {0x88, 0x1968, 0x20}},
        {"The Gunpowder Plot", new List<int> {0x88, 0xC98, 0x20}},
        {"Commodore Eighty-Sixed", new List<int> {0x88, 0x718, 0x20}},
        {"The Fireship", new List<int> {0x88, 0x14F8, 0x20}},
        {"Do Not Go Gently..._05", new List<int> {0x88, 0xAE8, 0x20}}, // Theirs actually 3 of these but its kind of weird tbh the third might be for Vainglorious Bastards but idk for sure
        {"Do Not Go Gently...", new List<int> {0x88, 0x478, 0x20}}, // main split
        {"Do Not Go Gently..._11", new List<int> {0x88, 0x7E8, 0x20}}, // black beard cutscene
        {"Vainglorious Bastards", new List<int> {0x88, 0x1398, 0x20}},
        {"Marooned", new List<int> {0x88, 0x7F8, 0x20}}, 
        {"Imagine My Surprise_SQ9_M05", new List<int> {0x88, 0xCA8, 0x20}},// two of these missions -- back to retirement Jack Racham
        {"Imagine My Surprise", new List<int> {0x88, 0x488, 0x20}}, // main split
        {"Trust is Earned_15", new List<int> {0x88, 0x7A8, 0x20}}, // two of these missions
        {"Trust is Earned", new List<int> {0x88, 0x1C78, 0x20}}, // main split
        {"Black Bart's Gambit", new List<int> {0x88, 0x6C8, 0x20}},
        {"Murder and Mayhem", new List<int> {0x88, 0x7B8, 0x20}},
        {"The Observatory", new List<int> {0x88, 0x14E8, 0x20}},
        {"To Suffer Without Dying", new List<int> {0x88, 0x6D8, 0x20}},
        {"Delirium", new List<int> {0x88, 0x1E78, 0x20}},
        {"Everything is Permitted_25", new List<int> {0x88, 0x18A8, 0x20}}, // two of these missions
        {"Everything is Permitted", new List<int> {0x88, 0x1B28, 0x20}}, // main split
        {"A Governor No Longer", new List<int> {0x88, 0xD08, 0x20}},
        {"Royal Misfortune_15", new List<int> {0x88, 0xF08, 0x20}},// two of these missions
        {"Royal Misfortune", new List<int> {0x88, 0x258, 0x20}}, // main split
        {"Tainted Blood_25", new List<int> {0x88, 0x16B8, 0x20}},// two of these missions
        {"Tainted Blood", new List<int> {0x88, 0xAB8, 0x20}}, // main split
        {"Ever a Splinter", new List<int> {0x88, 0x1148, 0x34, 0x68, 0x20}} // objective of killing tores
    };

    Func<string, string> Logging = (string message) =>
    {
        string NewMessage = "Splitted for " + message + " at " + vars.formattedTime + " LRT";
        if (File.Exists("AC4BFR.log"))
        {
            File.AppendAllText("AC4BFR.log", NewMessage + Environment.NewLine);
        }
        else
        {
            File.WriteAllText("AC4BFR.log", NewMessage + Environment.NewLine);
        }

        return NewMessage;
    };
    vars.Logging = Logging;
}

init
{
    vars.MainMissionWatchers = new MemoryWatcherList();
    // finds a static address by scanning the code of the main module, so it survives game updates.
    // pattern = the AOB, dispOffset = where the 4 displacement bytes (the first ?? run of the RIP relative instruction) start inside the pattern,
    // tail = bytes of that same instruction after the displacement (0 for a plain mov reg,[rip+disp]).
    // Returns the static as an offset from the module base (what DeepPointer wants), or 0 when the pattern was not found.
    var mod = modules.First();
    Func<string, int, int, int> scanStatic = (pattern, dispOffset, tail) =>
    {
        var target = new SigScanTarget(dispOffset, pattern);
        long lo = (long)mod.BaseAddress;
        long hi = lo + mod.ModuleMemorySize;
        foreach (var page in game.MemoryPages(true))
        {
            long pb = (long)page.BaseAddress;
            if (pb < lo || pb >= hi) continue;                    // only the main module
            if ((int)page.State != 0x1000) continue;              // MEM_COMMIT
            if (((int)page.Protect & 0xF0) == 0) continue;        // executable pages only (the code)
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
            IntPtr hit = scanner.Scan(target);
            if (hit == IntPtr.Zero) continue;
            // RIP relative: the address is relative to the end of the instruction
            return (int)((long)hit + 4 + tail + game.ReadValue<int>(hit) - lo);
        }
        return 0;
    };

    // quest manager static: mov rdx,[rip+disp] (48 8B 15 disp32), the displacement starts at byte 3
    int QuestBase = scanStatic("48 8B 15 ?? ?? ?? ?? 48 85 D2 0F 84 ?? ?? ?? ?? 8B 82 ?? ?? ?? ?? A9 00 00 F0 7F 0F 85 ?? ?? ?? ?? B8 01 00 00 00 F0 0F C1 82 ?? ?? ?? ?? FF C0 A9 00 00 F0 7F 0F 85 ?? ?? ?? ?? 48 83 7A ?? 00 0F 84 ?? ?? ?? ?? 48 8B 09", 3, 0);
    if (QuestBase == 0) throw new Exception("AC4BFR: quest manager AOB not found yet");   // LiveSplit retries init until the game has it in memory
    print("AC4BFR: quest base found at exe+" + QuestBase.ToString("X"));

    // loading: [static] + 0x2F0 = 0 when not loading, 1 when loading (found with a pointer scan, the static is read by mov rbx,[rip+disp] = 48 8B 1D, the displacement starts at byte 20 of the pattern)
    int LoadBase = scanStatic("44 8B 3D ?? ?? ?? ?? 45 89 FE 41 81 E6 00 00 00 40 48 8B 1D ?? ?? ?? ?? 41 C1 E7 06 41 81 E7 C0 FF 0F 00 4E 8D 04 3B 48 89 C1 48 89 DA E8 ?? ?? ?? ??", 20, 0);
    if (LoadBase == 0) throw new Exception("AC4BFR: loading AOB not found yet");
    print("AC4BFR: loading base found at exe+" + LoadBase.ToString("X"));
    vars.Loading = new MemoryWatcher<int>(new DeepPointer(LoadBase, 0x2F0));

    foreach (var mission in vars.MainMissions)
    {
        if (mission.Key.Contains("_")) // add these splits only if activated
        {
            if (!settings[mission.Key]) {
                continue;
            }

            vars.MainMissionWatchers.Add(new MemoryWatcher<int>(new DeepPointer(QuestBase, mission.Value.ToArray())){Name = mission.Key}); // for the extra main mission splits
        } else if (mission.Key == "The One With the Gun" || mission.Key == "A Proper Shipwright") // add these splits only if activated
        {
            if (!settings[mission.Key]) {
                continue;
            }
            vars.MainMissionWatchers.Add(new MemoryWatcher<int>(new DeepPointer(QuestBase, mission.Value.ToArray())){Name = mission.Key}); // for the Lucy Baldwin quest line
        }

        vars.MainMissionWatchers.Add(new MemoryWatcher<int>(new DeepPointer(QuestBase, mission.Value.ToArray())){Name = mission.Key}); // for all the main missions
    }
}

update
{ 
    vars.formattedTime = string.Format("{0:00}:{1:00}:{2:00}.{3:000}",
    vars.TotalTimeWatch.Elapsed.Hours, vars.TotalTimeWatch.Elapsed.Minutes,
    vars.TotalTimeWatch.Elapsed.Seconds, vars.TotalTimeWatch.Elapsed.Milliseconds);
    vars.Helper.Update();
	vars.Helper.MapPointers();
    vars.Loading.Update(game);
    if (settings["Any%"]) { 
        vars.MainMissionWatchers.UpdateAll(game);
    }
    if(settings["Debug"]) {
        timer.Run.Metadata.SetCustomVariable("Loading", vars.Loading.Current.ToString() + "/1");
    }

    if (timer.CurrentPhase == TimerPhase.Paused || timer.IsGameTimePaused == true)
    {
        vars.TotalTimeWatch.Stop();
    } else if (vars.TotalTimeWatch.IsRunning == false && timer.CurrentPhase == TimerPhase.Running && timer.IsGameTimePaused == false)
    {
        vars.TotalTimeWatch.Start();
    }
}

start
{
    if (vars.Loading.Current == 0 && vars.Loading.Old == 1)
    {
        vars.TotalTimeWatch.Start();
        return true;
    }
}

split
{
    if (settings["Any%"])
    {
        foreach (var mission in vars.MainMissionWatchers)
        {
            string message = mission.Name;
            if (mission.Current == 2 && mission.Old == 1 && !vars.completedsplits.Contains(mission.Name))
            {
                if (settings["Debug"]) {
                    vars.Logging(message);
                }
                vars.completedsplits.Add(mission.Name);
                return true;
            }
        }
    }
}

onReset
{
    vars.completedsplits.Clear();
    vars.TotalTimeWatch.Reset();
}

isLoading
{
    if (vars.Loading.Current == 1)
    {
        vars.TotalTimeWatch.Stop();
        return true;
    } else {
        vars.TotalTimeWatch.Start();
        return false;
    }
}

//Assassins Creed IV Black Flag Version: 2.0.0 Autosplitter made by TpRedNinja
//Thanks for the help from tasz for testing all versions of my autosplitter and getting the percentage values for everything

state("AC4BFSP")
{
    //--stuff for loading & starting stuff--
        int MainMenu: 0x49D2204; //65540 Main Menu anything else is in save file
        int Character: 0x23485C0; //1 for modern day 0 for not
        //int location: 0x26C1F80; //for land lock Major locations the number is the same such as Cape & Principe everything else changes. 
        //For secondary locations as of now it stays the same number. To do: write down all numbers for all locations
        int loading: 0x04A1A6CC, 0x7D8; //0 when not loading 1 when u are loading
    //--stuff that affects Edward--
        int Money: 0x049E3788, 0xA0, 0x90; //Shows your current money when in the animus.
        int Health: 0x049E3788, 0x34, 0x84; //shows you current health works with upgrades.
        float oxygen: 0x25E080C; //current oxygen 1 for full and anything lower means the bar is going down. Except for exiting a shipwreck. 
    //--for knowing how far your are and for splitting--
        int Percentage: 0x049D9774, 0x284; //Shows the total current percentage
        float PercentageF: 0x049F1EE8, 0x74; //Shows the total current percentage but in a float
}

startup
{
    //asl help stuff
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.Settings.CreateFromXml("C:/Users/jjdom/OneDrive/Desktop/livesplit/LiveSplit_1.8.29/Components/AC4.Settings.xml");
    vars.Helper.StartFileLogger("SplitsVersions.log");

    //set text taken from Poppy Playtime C2
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

    //not splitting settings
    settings.Add("Percentage Display", false);
    settings.Add("Collectibles Display", false, "Collectibles Display");
    settings.Add("Debug", false, "Debug");
    settings.Add("Calculator", false, "Calculator","Debug");
    settings.SetToolTip("Debug", "This will show the current MainMenu value and loading.\n" + "Along with the calculator if u use it");
    for (int i = 1; i <= 13; i++)
    {
        var seqKey = "Sequence " + i;
        settings.Add(seqKey, false, seqKey, "Sequences");
        settings.Add(seqKey + " - All", false, "All", seqKey);
        settings.SetToolTip(seqKey + " - All", "Splits after every mission in " + seqKey);
        settings.Add(seqKey + " - Last", false, "Last", seqKey);
        settings.SetToolTip(seqKey + " - Last", "Splits after the last mission in " + seqKey);
    }
    /*for any future settings i want to add
    settings.Add("", false, "", "Splits");
    settings.SetToolTip("", "Splits when ");
    */
    vars.completedsplits = new List<string>();
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = null;
    vars.TotalTimeWatch = new Stopwatch();
    vars.TotalTime = null;
    vars.IsStopwatchStop = false;

    vars.Counters = new Dictionary<string, List<int>>
    {
        {"Viewpoints", new List<int>{0x2D0, 0x8BC, 0x2B98, 0x18}},
        {"Myan Stele", new List<int>{0x2D0, 0x8BC, -0x1B1C, 0x18}},
        {"Buried Treasure", new List<int>{0x2D0, 0x8BC, -0xBB8, 0x18}},
        {"Animus Fragments", new List<int>{0x2D0, 0x8BC, -0x1B58, 0x18}},
        {"Assassin Contracts", new List<int>{0x2D0, 0x8BC, -0x1E8C, 0x18}},
        {"Naval Contracts", new List<int>{0x2D0, 0x8BC, 0x1950, 0x18}},
        {"Letters", new List<int>{0x2D0, 0x8BC, -0x4EC, 0x18}},
        {"Manuscripts", new List<int>{0x2D0, 0x8BC, -0x334, 0x18}},
        {"Music Sheets", new List<int>{0x2D0, 0x8BC, 0x424, 0x18}},
        {"Taverns", new List<int>{0x2D0, 0x8BC, 0x3188, 0x18}}
    };

    vars.SpecialStuff = new Dictionary<string, int>
    {
        {"Forts", 0xA08},
        {"Legendary Ships", 0xB88},
        {"Modern Day", 0x1D88}
    };

    vars.TemplarHunts = new Dictionary<string, int> // templar hunts add 60 to the offset to get the next one. 16 hunt missions in total but 4 pointers.
    {
        {"Opia Hunt", 0x6A8},
        {"Rhona Hunt", 0x708},
        {"Anto Hunt", 0x768},
        {"Upton Hunt", 0x7C8}
    };

    vars.MainMissions = new Dictionary<string, int> // Add 60 to each offset to get the next sequence pointer. 13 sequences in total.
    {
        {"Sequence 1", 0x1C8}, // 1 mission
        {"Sequence 2", 0x228}, // 6 missions
        {"Sequence 3", 0x288}, // 7 missions
        {"Sequence 4", 0x2E8}, // 4 missions
        {"Sequence 5", 0x348}, // 3 missions
        {"Sequence 6", 0x3A8}, // 3 missions
        {"Sequence 7", 0x408}, // 4 missions
        {"Sequence 8", 0x468}, // 3 missions
        {"Sequence 9", 0x4C8}, // 2 missions
        {"Sequence 10", 0x528}, // 3 missions
        {"Sequence 11", 0x588}, // 3 missions
        {"Sequence 12", 0x5E8}, // 4 missions
        {"Sequence 13", 0x648}, // 2 missions
    };

    vars.SequenceEndValue = new Dictionary<string, int>
    {
        {"Sequence 1", 1},
        {"Sequence 2", 6},
        {"Sequence 3", 7},
        {"Sequence 4", 4},
        {"Sequence 5", 3},
        {"Sequence 6", 3},
        {"Sequence 7", 4},
        {"Sequence 8", 3},
        {"Sequence 9", 2},
        {"Sequence 10", 3},
        {"Sequence 11", 3},
        {"Sequence 12", 4},
        {"Sequence 13", 2},
    };
    vars.Chests = new Dictionary<string, List<int>>
    {
        {"Uncharted Chests", new List<int>{0x2D0, 0x8BC, 0x94C, 0x18}},
        {"Havana", new List<int>{0x2D0, 0x8BC, 0x744, 0x18}},
        {"Cape Batavistia", new List<int>{0x2D0, 0x8BC, 0xA78, 0x18}},
        {"Fort Dry Tortuga", new List<int>{0x2D0, 0x8BC, 0x9C4, 0x18}},
        {"Salt Key Bay", new List<int>{0x2D0, 0x8BC, 0x898, 0x18}},
        {"Matanzas", new List<int>{0x2D0, 0x8BC, 0x80C, 0x18}},
        {"Florida", new List<int>{0x2D0, 0x8BC, 0xA8C, 0x18}},
        {"Nassau", new List<int>{0x2D0, 0x8BC, 0x848, 0x18}},
        {"Fort Eleuthra", new List<int>{0x2D0, 0x8BC, 0x9D8, 0x18}},
        {"Andreas Island", new List<int>{0x2D0, 0x8BC, 0x7D0, 0x18}},
        {"Cat Island", new List<int>{0x2D0, 0x8BC, 0x6CC, 0x18}},
        {"Abaco Island", new List<int>{0x2D0, 0x8BC, 0x690, 0x18}},
        {"Hideout(Great Iguana)", new List<int>{0x2D0, 0x8BC, 0x870, 0x18}},
        {"Fort Gibra", new List<int>{0x2D0, 0x8BC, 0x9EC, 0x18}},
        {"Crooked Island", new List<int>{0x2D0, 0x8BC, 0x71C, 0x18}},
        {"Jiguey", new List<int>{0x2D0, 0x8BC, 0x794, 0x18}},
        {"Mariguana", new List<int>{0x2D0, 0x8BC, 0x7F8, 0x18}},
        {"Salt Lagoon", new List<int>{0x2D0, 0x8BC, 0x8AC, 0x18}},
        {"Principe", new List<int>{0x2D0, 0x8BC, 0x884, 0x18}},
        {"Punta Guarico", new List<int>{0x2D0, 0x8BC, 0xA14, 0x18}},
        {"Tortuga", new List<int>{0x2D0, 0x8BC, 0x938, 0x18}},
        {"Petite Cavern", new List<int>{0x2D0, 0x8BC, 0x834, 0x18}},
        {"Cumberland Bay", new List<int>{0x2D0, 0x8BC, 0x7E4, 0x18}},
        {"Tulum", new List<int>{0x2D0, 0x8BC, 0x708, 0x18}},
        {"Fort Conttoyor", new List<int>{0x2D0, 0x8BC, 0x99C, 0x18}},
        {"Fort Navassa", new List<int>{0x2D0, 0x8BC, 0xA00, 0x18}},
        {"Ille A Vache", new List<int>{0x2D0, 0x8BC, 0x76C, 0x18}},
        {"Kingston", new List<int>{0x2D0, 0x8BC, 0x7BC, 0x18}},
        {"Long Bay (Observatory)", new List<int>{0x2D0, 0x8BC, 0x758, 0x18}},
        {"Fort Charlotte", new List<int>{0x2D0, 0x8BC, 0x974, 0x18}},
        {"Annatto Bay", new List<int>{0x2D0, 0x8BC, 0x6B8, 0x18}},
        {"Isla Providencia", new List<int>{0x2D0, 0x8BC, 0x780, 0x18}},
        {"Fort Serranillia", new List<int>{0x2D0, 0x8BC, 0xA28, 0x18}},
        {"Misteriosa", new List<int>{0x2D0, 0x8BC, 0x820, 0x18}},
        {"New Bone", new List<int>{0x2D0, 0x8BC, 0x85C, 0x18}},
        {"Fort Chinchorro", new List<int>{0x2D0, 0x8BC, 0x988, 0x18}},
        {"Fort Santanillas", new List<int>{0x2D0, 0x8BC, 0x8C0, 0x18}},
        {"Corozal", new List<int>{0x2D0, 0x8BC, 0x6F4, 0x18}},
        {"Ambergis Bay", new List<int>{0x2D0, 0x8BC, 0x67C, 0x18}},
        {"Castillo", new List<int>{0x2D0, 0x8BC, 0x960, 0x18}},
        {"Pinos Isle", new List<int>{0x2D0, 0x8BC, 0x7A8, 0x18}},
        {"Arrayos", new List<int>{0x2D0, 0x8BC, 0x6A4, 0x18}},
        {"Cayman Sound", new List<int>{0x2D0, 0x8BC, 0x6E0, 0x18}},
        {"Fort Cruz", new List<int>{0x2D0, 0x8BC, 0x9B0, 0x18}},
        {"San Juan", new List<int>{0x2D0, 0x8BC, 0x924, 0x18}},
        {"Grand Cayman", new List<int>{0x2D0, 0x8BC, 0x730, 0x18}},
        {"San Ignacio", new List<int>{0x2D0, 0x8BC, 0xA3C, 0x18}},
        {"Antocha Wreck", new List<int>{0x2D0, 0x8BC, 0xA50, 0x18}},
        {"The Black Trench", new List<int>{0x2D0, 0x8BC, 0xA64, 0x18}},
        {"Kabah Ruins", new List<int>{0x2D0, 0x8BC, 0x8D4, 0x18}},
        {"Devils Eyes Cavern", new List<int>{0x2D0, 0x8BC, 0x8E8, 0x18}},
        {"La Concepcion", new List<int>{0x2D0, 0x8BC, 0x8FC, 0x18}},
        {"The Blue Hole", new List<int>{0x2D0, 0x8BC, 0x910, 0x18}},
        {"Water Chests", new List<int>{0x30C, 0x58C, 0x18}}
    };

    foreach (var item in vars.Counters)
    {
        if (item.Key == "Assassin Contracts" || item.Key == "Naval Contracts" || item.Key == "Taverns")
        {
            break;
        }
        settings.Add(item.Key, false, item.Key, "Collectibles");
    }
}

init
{
    vars.PercentDiff = 0.0f;
    vars.TotalChests = 0;
    vars.TotalTemplarHunts = 0;
    vars.TotalMainMissions = 0;
    vars.TotalModernDayMissionsDone = 0;
    int InventoryBase = 0x026BEAC0;
    int InventoryBase2 = 0x0137D9F8;
    int WaterBase = 0x026BEC04;
    vars.ChestWatchers = new MemoryWatcherList();
    vars.CountersWatchers = new MemoryWatcherList();
    vars.SpecialWatchers = new MemoryWatcherList();
    vars.TemplarHuntsWatchers = new MemoryWatcherList();
    vars.MainMissionsWatchers = new MemoryWatcherList();

    foreach (var Chest in vars.Chests)
    {
        if (Chest.Key == "Water Chests")
        {
            vars.ChestWatchers.Add(new MemoryWatcher<int>(new DeepPointer(WaterBase, Chest.Value.ToArray())){Name = Chest.Key});
        } else
        {
            vars.ChestWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase, Chest.Value.ToArray())){Name = Chest.Key});
        }
        
    }

    foreach (var Counter in vars.Counters)
    {
        vars.CountersWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase, Counter.Value.ToArray())){Name = Counter.Key});
    }

    foreach (var SpecialThing in vars.SpecialStuff)
    {
        vars.SpecialWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase2, SpecialThing.Value)){Name = SpecialThing.Key});
    }

    foreach (var Hunt in vars.TemplarHunts)
    {
        vars.TemplarHuntsWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase2, Hunt.Value)){Name = Hunt.Key});
    }

    foreach (var Sequence in vars.MainMissions)
    {
        vars.MainMissionsWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase2, Sequence.Value)){Name = Sequence.Key});
    }

    if (current.MainMenu == 65540 && current.loading == 0)
    {
        timer.IsGameTimePaused = true;
    }

    if (vars.IsStopwatchStop == true)
    {
        vars.stopwatch.Start();
        vars.IsStopwatchStop = false; 
    }
}

update
{
    vars.PercentDiff = current.PercentageF - old.PercentageF;

    if (current.Percentage < 100)
    {
        current.PercentageF = Math.Round(current.PercentageF, 5);
    } else if (settings["Everything"])
    {
        current.PercentageF = Math.Round(current.PercentageF, 2);
    }
    
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
    vars.TotalTime = (float)vars.TotalTimeWatch.Elapsed.TotalSeconds;

    if (timer.CurrentPhase == TimerPhase.Paused)
    {
        vars.TotalTimeWatch.Stop();
        vars.Stopwatch.Stop();
    } else if (timer.CurrentPhase == TimerPhase.Running)
    {
        vars.stopwatch.Start();
        vars.TotalTimeWatch.Start();
        
    }

    if (settings["Percentage Display"])
    {
        if (current.PercentageF != null){
            vars.SetTextComponent("Percentage Completion", current.PercentageF + "%");
        } else
        {
            vars.SetTextComponent("Percentage Completion", null + "%");
        }
    }

    if (settings["Debug"])
    {
        string formattedTime = string.Format("{0:00}:{1:00}:{2:00}.{3:000}",
        vars.TotalTimeWatch.Elapsed.Hours, vars.TotalTimeWatch.Elapsed.Minutes,
        vars.TotalTimeWatch.Elapsed.Seconds, vars.TotalTimeWatch.Elapsed.Milliseconds);

        //vars.SetTextComponent("", current. + "/"); for extras in the future
        if (current.MainMenu != null && current.loading != null)
        {
            vars.SetTextComponent("Current MainMenu Value", current.MainMenu + "/65540");
            vars.SetTextComponent("Current Loading", current.loading + "/1");
            vars.SetTextComponent("Time from Last Split", vars.SplitTime + "/2");
            vars.SetTextComponent("Total Run Time", formattedTime);
            if (settings["Calculator"])
            {
                if (current.PercentageF > old.PercentageF)
                {
                    vars.SetTextComponent("Percentage increased by ", current.PercentageF - old.PercentageF + "%");
                }
            }
        }

        // DEBUG: print sequence end values directly (no extra checks)
        foreach (var seq in vars.MainMissions)
        {
            vars.Log("DBG Sequence: " + seq.Key + " | endVal=" + vars.SequenceEndValue[seq.Key]);
        }

    }

    if (settings["Collectibles Display"])
    { 
        vars.CountersWatchers.UpdateAll(game);
        vars.SpecialWatchers.UpdateAll(game);
        vars.TemplarHuntsWatchers.UpdateAll(game);
        vars.ChestWatchers.UpdateAll(game);
        vars.MainMissionsWatchers.UpdateAll(game);
        if (current.MainMenu == 65540 && old.MainMenu != 65540)
        {
            vars.TotalChests = 0;
            vars.TotalTemplarHunts = 0;
            vars.TotalMainMissions = 0;
        }
        vars.TotalChests = 0;
        foreach (var Watcher in vars.ChestWatchers)
        {
            vars.TotalChests += Watcher.Current;
        }
        vars.TotalTemplarHunts = 0;
        foreach (var Watcher in vars.TemplarHuntsWatchers)
        {
            vars.TotalTemplarHunts += Watcher.Current;
        }
        vars.TotalMainMissions = 0;
        foreach (var Watcher in vars.MainMissionsWatchers)
        {
            vars.TotalMainMissions += Watcher.Current;
        }

        vars.SetTextComponent("Viewpoints Synchronized", vars.CountersWatchers["Viewpoints"].Current + "/58");
        vars.SetTextComponent("MyanStele Collected", vars.CountersWatchers["Myan Stele"].Current + "/16");
        vars.SetTextComponent("BuriedTreasure Found", vars.CountersWatchers["Buried Treasure"].Current + "/22");
        vars.SetTextComponent("Fragments Collected", vars.CountersWatchers["Animus Fragments"].Current + "/200");
        vars.SetTextComponent("Total Chests Collected", vars.TotalChests + "/340");
        vars.SetTextComponent("Assassins Contracts Completed", vars.CountersWatchers["Assassin Contracts"].Current + "/30");
        vars.SetTextComponent("Naval Contracts Completed", vars.CountersWatchers["Naval Contracts"].Current + "/15");
        vars.SetTextComponent("Letters Collected", vars.CountersWatchers["Letters"].Current + "/20");
        vars.SetTextComponent("Manuscripts Collected", vars.CountersWatchers["Manuscripts"].Current + "/20");
        vars.SetTextComponent("Shanties Collected", vars.CountersWatchers["Music Sheets"].Current + "/24");
        vars.SetTextComponent("Forts captured", vars.SpecialWatchers["Forts"].Current + "/10");
        vars.SetTextComponent("Taverns Unlocked", vars.CountersWatchers["Taverns"].Current + "/8");
        vars.SetTextComponent("Legendary Ships Defeated", vars.SpecialWatchers["Legendary Ships"].Current + "/4");
        vars.SetTextComponent("Templar Hunts Completed", vars.TotalTemplarHunts + "/16");
        vars.SetTextComponent("Main Missions Completed", vars.TotalMainMissions + "/45");
        if (vars.MainMissionsWatchers["Sequence 1"].Current == 1)
        {
            vars.SetTextComponent("Modern Day Missions Completed", vars.SpecialWatchers["Modern Day"].Current + 1 + "/5");
        } else
        {
            vars.SetTextComponent("Modern Day Missions Completed", vars.SpecialWatchers["Modern Day"].Current + "/5");
        }
        
        
    }
    //print(modules.First().ModuleMemorySize.ToString());

    if (settings["LegendaryShips"])
    {
        vars.SpecialWatchers["Legendary Ships"].Update(game);
    }
    if(settings["TemplarHunts"])
    {
        vars.TemplarHuntsWatchers.UpdateAll(game);
    }
    if (settings["Collectibles"])
    {
        vars.CountersWatchers.UpdateAll(game);
    }
    if (settings["Any%"] || settings["Sequences"])
    {
        vars.MainMissionsWatchers.UpdateAll(game);
    }
    if (settings["ModernDay"])
    {
        vars.SpecialWatchers["Modern Day"].Update(game);
    }
    if (settings["Shipwrecks"])
    {
        vars.ChestWatchers["Water Chests"].Update(game);
    }
}

start
{
    //should start after accepting the save file
    if (current.MainMenu == 131076 && old.MainMenu == 65540 && current.PercentageF < 1)
    {
        return true;
    }
}

onStart
{
    vars.stopwatch.Restart();
    vars.TotalTimeWatch.Restart();
}

split
{
    //should work for most splits
    if (settings["Any%"])
    {
        // split on any main mission completion (Any% = split on every main mission)
        foreach (var seq in vars.MainMissions)
        {
            var watcher = vars.MainMissionsWatchers[seq.Key];
            if (watcher.Current == watcher.Old + 1 && current.loading == 0 && vars.SplitTime > 2)
            {
                vars.Log("Any% Split - Main mission in " + seq.Key + " at: " + vars.TotalTime.ToString("F2"));
                vars.stopwatch.Restart();
                return true;
            }
        }
    }

    // sequence-specific splitting (per-sequence "All" or "Last")
    foreach (var seq in vars.MainMissions)
    {
        var allSetting = seq.Key + " - All";
        var lastSetting = seq.Key + " - Last";
        var watcher = vars.MainMissionsWatchers[seq.Key];

        if (settings[allSetting])
        {
            // split on every mission in this sequence
            if (watcher.Current == watcher.Old + 1 && current.loading == 0 && vars.SplitTime > 2)
            {
                vars.Log(seq.Key + " - All Split at: " + vars.TotalTime.ToString("F2"));
                vars.stopwatch.Restart();
                return true;
            }
        }

        if (settings[lastSetting])
        {
            // split when the sequence reaches its final mission
            var endVal = vars.SequenceEndValue[seq.Key];
            if (watcher.Current == endVal && watcher.Old != endVal && current.loading == 0 && vars.SplitTime > 2)
            {
                vars.Log(seq.Key + " - Last Split at: " + vars.TotalTime.ToString("F2"));
                vars.stopwatch.Restart();
                return true;
            }
        }
    }

    if(settings["ModernDay"])
    {
        //splits when entering the animus
        if (current.Character == 0 && old.Character == 1 && current.loading == 0 && vars.SplitTime > 2 && vars.TotalModernDayMissionsDone < 1)
        {
            print("Modern day Split");
            vars.TotalModernDayMissionsDone += 1;
            vars.stopwatch.Restart();
            return true;
        } else if (vars.SpecialWatchers["Modern Day"].Current == vars.SpecialWatchers["Modern Day"].Old + 1 && vars.SplitTime > 2 && vars.TotalModernDayMissionsDone > 1)
        {
            print("Modern day Split");
            vars.TotalModernDayMissionsDone += 1;
            vars.stopwatch.Restart();
            return true;
        }
    }
    
    if (settings["Everything"])
    {
        if (current.PercentageF > old.PercentageF && current.loading == 0 && vars.SplitTime > 2)
        {
            print("Splited");
            vars.stopwatch.Restart();
            return true;
        }
    }

    if (settings["Shipwrecks"])
    {
        Dictionary<string, int> ShipwreckSplits = new Dictionary<string, int>()
        {
            {"San Ignacio", 6},
            {"The Blue Hole", 13},
            {"Antocha Wreck", 20},
            {"Devils Eyes Cavern", 28},
            {"La Concepcion", 35},
            {"The Black Trench", 42},
            {"Kabah Ruins", 50}
        };
        foreach (var Shipwreck in ShipwreckSplits)
        {
            if (vars.ChestWatchers["Water Chests"].Current == Shipwreck.Value && vars.ChestWatchers["Water Chests"].Old != Shipwreck.Value && !vars.completedsplits.Contains(Shipwreck.Key))
            {
                vars.completedsplits.Add(Shipwreck.Key);
                vars.Log("Shipwreck Split: " + Shipwreck.Key + " at: " + vars.TotalTime.ToString("F2"));
                return true;
            }
        }
    }

    if(settings["Viewpoints"])
    {
        List<float> ValidValues = new List<float> { 0.03750f, 0.03333f, 0.11250f, 0.03214f, 0.05625f };
        //splits when syncing a viewpoint
        if (vars.CountersWatchers["Viewpoints"].Current == vars.CountersWatchers["Viewpoints"].Old + 1 && vars.SplitTime > 2 
        && current.loading == 0)
        {
            vars.Log("Viewpoints Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (ValidValues.Contains(current.PercentageF - old.PercentageF) && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Viewpoints Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
        
    }

    if(settings["Myan Stele"])
    {
        //splits when getting one myan stone
        if (vars.CountersWatchers["Myan Stele"].Current == vars.CountersWatchers["Myan Stele"].Old + 1 && vars.SplitTime > 2 
        && current.loading == 0)
        {
            vars.Log("MyanStele Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (((vars.PercentDiff >= 0.09288 && vars.PercentDiff <= 0.09291) || 
        (vars.PercentDiff >= 0.18577 && vars.PercentDiff <= 0.18579) || (vars.PercentDiff >= 0.20641 && vars.PercentDiff <= 0.20643)) 
        && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("MyanStele Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
    }

    if(settings["Buried Treasure"])
    {
        //splits when opening a buried treasure
        if (vars.CountersWatchers["Buried Treasure"].Current == vars.CountersWatchers["Buried Treasure"].Old + 1 && vars.SplitTime > 2 
        && current.loading == 0)
        {
            vars.Log("BuriedTreasure Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (current.PercentageF == old.PercentageF + 0.20455 && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("BuriedTreasure Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
    }

    if (settings["Contracts"])
    {
        //splits for assassin contracts
        if (vars.CountersWatchers["Assassin Contracts"].Current == vars.CountersWatchers["Assassin Contracts"].Old + 1 
        && vars.SplitTime > 2 && current.loading == 0)
        {
            vars.Log("Assassin Contracts Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (vars.PercentDiff >= 0.61727 && vars.PercentDiff <= 0.61730 && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Assassin Contracts Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }

        //splits for naval contracts
        if (vars.CountersWatchers["Naval Contracts"].Current == vars.CountersWatchers["Naval Contracts"].Old + 1 && current.loading == 0 
        && vars.SplitTime > 4)
        {
            vars.Log("Naval Contracts Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (vars.PercentDiff >= 0.02056 && vars.PercentDiff <= 0.02060 && current.loading == 0 && vars.SplitTime > 4)
        {
            vars.Log("Naval Contracts Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }

    }

    if (settings["Forts"])
    {
        //splits when capturing a fort
        if (vars.SpecialWatchers["Forts"].Current == vars.SpecialWatchers["Forts"].Old + 1 && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Forts Split version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }else if (current.PercentageF == old.PercentageF + 0.22500 && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Forts Split version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }  
    }

    if (settings["Taverns"])
    {
        //splits when completing a tavern
        if (vars.CountersWatchers["Taverns"].Current == vars.CountersWatchers["Taverns"].Old + 1 && current.loading == 0 
        && vars.SplitTime > 2)
        {
            vars.Log("Taverns Split = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (((vars.PercentDiff >= 0.20223 && vars.PercentDiff <= 0.20226) || (vars.PercentDiff >= 0.18538 && vars.PercentDiff <= 0.18541)) 
        && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Taverns Split version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
    }

    if (settings["TemplarHunts"])
    {
        foreach (var hunt in vars.TemplarHunts)
        {
            if (vars.TemplarHuntsWatchers[hunt.Key].Current == vars.TemplarHuntsWatchers[hunt.Key].Old + 1 && 
            current.loading == 0 && vars.SplitTime > 2)
            {
                vars.Log("Templar Hunts Split Version = " + hunt.Key + ", at: "+ vars.TotalTime.ToString("F2"));
                vars.stopwatch.Restart();
                return true;
            }
        }

        if ((vars.PercentDiff >= old.PercentageF + 0.38579 && vars.PercentDiff <= old.PercentageF + 0.38582) 
        && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Templar Hunts Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
    }

    if (settings["LegendaryShips"])
    {
        //splits when defeating one of the legendary ships
        if (vars.SpecialWatchers["Legendary Ships"].Current == vars.SpecialWatchers["Legendary Ships"].Old + 1 && current.loading == 0 
        && vars.SplitTime > 2)
        {
            vars.Log("Legendary Ships Split Version = Counter, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        } else if (current.PercentageF == old.PercentageF + 0.18750 && current.loading == 0 && vars.SplitTime > 2)
        {
            vars.Log("Legendary Ships Split Version = %, at: "+ vars.TotalTime.ToString("F2"));
            vars.stopwatch.Restart();
            return true;
        }
    }

}

onReset
{
    vars.completedsplits.Clear();
    vars.stopwatch.Reset();
    vars.TotalTimeWatch.Reset();
}

isLoading
{
    if (current.loading == 1 || current.MainMenu == 65540)
    {
        vars.TotalTimeWatch.Stop();
        vars.stopwatch.Stop();
        vars.IsStopwatchStop = true;
        return true;
    } else if (vars.IsStopwatchStop == true)
    {
        vars.stopwatch.Start();
        vars.TotalTimeWatch.Start();
        vars.IsStopwatchStop = false;
    } else
    {
        return false;
    }
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
    vars.stopwatch.Stop();
    vars.IsStopwatchStop = true;
}

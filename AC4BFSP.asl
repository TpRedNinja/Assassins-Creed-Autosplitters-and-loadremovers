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
        int Sequence: 0x049F1EE8, 0x20, 0x0, 0x0, 0x30; //Shows how many sequences you have completed.
}

startup
{
    //asl help stuff
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.Settings.CreateFromXml("Components/AC4.Settings.xml");

	// variables
    vars.completedsplits = new List<string>();
    vars.Stopwatch = new Stopwatch();
    vars.SplitTime = null;
    vars.TotalTimeWatch = new Stopwatch();
    vars.TotalTime = null;
    vars.IsStopwatchStop = false;
    vars.Splits = 0;
    vars.ModernDaySplitTargets = new List<int>{2, 16, 27, 40, 48};

    vars.MainMissions = new Dictionary<string, List<int>>
    {
        {"Sequence 1", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1170}}, // 1 mission
        {"Sequence 2", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x11D0}}, // 6 missions
        {"Sequence 3", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1230}}, // 7 missions
        {"Sequence 4", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1290}}, // 4 missions
        {"Sequence 5", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x12F0}}, // 3 missions
        {"Sequence 6", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1350}}, // 3 missions
        {"Sequence 7", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x13B0}}, // 4 missions
        {"Sequence 8", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1410}}, // 3 missions
        {"Sequence 9", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1470}}, // 2 missions
        {"Sequence 10", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x14D0}}, // 3 missions
        {"Sequence 11", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1530}}, // 3 missions
        {"Sequence 12", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x1590}}, // 4 missions
        {"Sequence 13", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x15F0}}, // 2 missions
    };
    vars.Test = new Dictionary<string, List<int>>
    {
        {"Modern Day", new List<int>{0x1C, 0x550, 0x74, 0x0, 0x10, 0x2D30}} // 4 missions
    }; 
}

init
{
    vars.SequencesLimits = new Dictionary<string, int>
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
    vars.SequenceCompletionTokens = new Dictionary<string, string>
    {
        {"Sequence 1", "Abstergo"},
        {"Sequence 2", "Sequence 2 Memory 6"},
        {"Sequence 3", "Sequence 3 Memory 7"},
        {"Sequence 4", "Sequence 4 Memory 4"},
        {"Sequence 5", "Sequence 5 Memory 3"},
        {"Sequence 6", "Sequence 6 Memory 3"},
        {"Sequence 7", "Sequence 7 Memory 4"},
        {"Sequence 8", "Sequence 8 Memory 3"},
        {"Sequence 9", "Sequence 9 Memory 2"},
        {"Sequence 10", "Sequence 10 Memory 3"},
        {"Sequence 11", "Sequence 11 Memory 3"},
        {"Sequence 12", "Sequence 12 Memory 4"},
        {"Sequence 13", "Sequence 13 Memory 2"},
    };
    vars.completedsplits = new List<string>();
    vars.Splits = 0;
    vars.MainMissionWatchers = new MemoryWatcherList();
    vars.TestWatchers = new MemoryWatcherList();
    int InventoryBase = 0x00634960;
    vars.PercentDiff = 0.0f;

    foreach (var Sequence in vars.MainMissions)
    {
        vars.MainMissionWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase, Sequence.Value.ToArray())){Name = Sequence.Key});
    }

    foreach (var modern in vars.Test)
    {
        vars.TestWatchers.Add(new MemoryWatcher<int>(new DeepPointer(InventoryBase, modern.Value.ToArray())){Name = modern.Key});
    }

    if (current.MainMenu == 65540 && current.loading == 0)
    {
        timer.IsGameTimePaused = true;
    }

    if (vars.IsStopwatchStop == true)
    {
        vars.Stopwatch.Start();
        vars.IsStopwatchStop = false; 
    }
}

update
{
    vars.Helper.Update();
	vars.Helper.MapPointers();
    vars.MainMissionWatchers.UpdateAll(game);

    vars.SplitTime = (int)vars.Stopwatch.Elapsed.TotalSeconds;
    vars.TotalTime = (float)vars.TotalTimeWatch.Elapsed.TotalSeconds;

    if (timer.CurrentPhase == TimerPhase.Paused || timer.IsGameTimePaused == true)
    {
        vars.TotalTimeWatch.Stop();
        vars.Stopwatch.Stop();
    } else if (vars.TotalTimeWatch.IsRunning == false && vars.Stopwatch.IsRunning == false && timer.CurrentPhase == TimerPhase.Running && timer.IsGameTimePaused == false)
    {
        vars.TotalTimeWatch.Start();
        vars.Stopwatch.Start();
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
    vars.Stopwatch.Restart();
    vars.TotalTimeWatch.Restart();
}

split
{
    //should work for most splits
    if (settings["Any%"])
    {
        foreach (var Sequence in vars.MainMissions)
        {
            var watcher = vars.MainMissionWatchers[Sequence.Key];
            var completionToken = vars.SequenceCompletionTokens[Sequence.Key];
            string splitName = Sequence.Key + " Memory " + watcher.Current;
            
            if (vars.ModernDaySplitTargets.Contains(vars.Splits+1))
                splitName = "Modern Day " + (vars.Splits+1);

            if (vars.completedsplits.Contains(completionToken))
                continue; // Skip if this split has already been completed
            
            if (watcher.Current > watcher.Old && vars.SplitTime > 2  && (current.loading == 0 || vars.ModernDaySplitTargets.Contains(vars.Splits + 1)) && !vars.completedsplits.Contains(splitName)) // split on all missions assuming no load and isnt already completed
            {
                vars.completedsplits.Add(splitName);
                return true;
            }
        }
    }

}

onSplit
{
    vars.Splits++;
    vars.Stopwatch.Restart();
}

onReset
{
    vars.completedsplits.Clear();
    vars.Stopwatch.Stop();
    vars.Stopwatch.Reset();
    vars.TotalTimeWatch.Stop();
    vars.TotalTimeWatch.Reset();
    vars.splits = 0;
}

isLoading
{
    if (current.loading == 1 || current.MainMenu == 65540 || current.MainMenu == 0)
    {
        vars.TotalTimeWatch.Stop();
        vars.Stopwatch.Stop();
        vars.IsStopwatchStop = true;
        return true;
    } else if (vars.IsStopwatchStop == true && current.loading == 0 && current.MainMenu != 65540)
    {
        vars.Stopwatch.Start();
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
    vars.IsStopwatchStop = true;
}

/* Auto Splitter for Assassin's Creed II
* Made by: @TpRedNinja
* Auto Splitter Version: 2.0.3 
*/
state("AssassinsCreedIIGame", "Legit")
{
    int percentage : 0x01E3DBE4, 0x2D0; // stats menu current percentage
    int money : 0x1E134B4, 0x24, 0x34; // current money u have
    uint lastCompletedMission : 0x01E110E4, 0x0, 0x28; // hexid for the last completed mission
    int CodexPages : 0x01E134BC, 0xF0, 0x0; // how many codex pages u have collected in total
    int Feathers : 0x01E134BC, 0xF0, 0x4; // how many feathers u have collected in total
    int loading : 0x01E16320, 0x38C, 0x694; // 6 and 7 for loading 5 for not loadimng 4 in mainmenu
    uint currentMission : 0x01E3DBE4, 0x158, 0x0, 0x2C, 0xC; // hexid for the current mission u are on
    int currentMissionStatus : 0x01E3DBE4, 0x158, 0x0, 0x2C, 0x0, 0x18; // current mission status
    int AbstergoStatus : 0x005E77BC, 0xC, 0x14, 0x318; // current mission status for Escaping Abstergo
    int AnimusStatus : 0x01E12004, 0x8, 0x1C8, 0x10, 0x18; // current mission status for animus 2.0
    int WarehouseStatus : 0x01E110DC, 0x1C, 0x164, 0x21C, 0x18; // current mission status for warehouse
    int AltairStatus : 0x01E110DC, 0x1C, 0x164, 0x220, 0x18; // current mission status for altair
    uint mostRecentMission : 0x1E13314; // hexid for the most recent mission u are on
}

state("AssassinsCreedIIGame", "Pirate")
{
    int percentage : 0x01E14D1C, 0x2D0;
    int money : 0x1E3C588, 0x24, 0x34;
    uint lastCompletedMission : 0x01E1297C, 0x0, 0x28;
    int CodexPages : 0x1E3C590, 0xF0, 0x0;
    int Feathers : 0x1E3C590, 0xF0, 0x4;
    int loading : 0x01E3F3F0, 0x38C, 0x694; // 6 and 7 for loading 5 for not loadimng 4 in mainmenu
    uint currentMission : 0x01E14D1C, 0x94, 0xC0, 0x0, 0x2C, 0xC;
    int currentMissionStatus : 0x01E14D1C, 0x94, 0xC0, 0x0, 0x2C, 0x0, 0x18;
    uint mostRecentMission : 0x1E14B64;
}

startup
{
    vars.AutoSplitterVersion = "2.0.3"; // version variable
    timer.Run.Metadata.SetCustomVariable("Auto Splitter Version", vars.AutoSplitterVersion);
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = null;
    vars.IsStopwatchStop = false;
    vars.Sequence = new Dictionary<float, string>
    {
        {0.5f, "Present Day 1"}, {1f, "Sequence 1: Ignorance Is Bliss"}, {2f, "Sequence 2: Escape Plans"},
        {3f, "Sequence 3: Requiescat in Pace"}, {4f, "Sequence 4: The Pazzi Conspiracy"}, {5f, "Sequence 5: Loose Ends"},
        {6f, "Sequence 6: Rocky Road"}, {6.5f, "Present Day 2"}, {7f, "Sequence 7: The Merchant of Venice"},
        {8f, "Sequence 8: Necessity, Mother of Invention"}, {9f, "Sequence 9: Carnevale"}, {10f, "Sequence 10: Force Majeure"},
        {11f, "Sequence 11: Alter Egos"}, {12f, "Sequence 12: Battle of Florli"}, {13f, "Sequence 13: Bonfire of the Vanities"},
        {14f, "Sequence 14: Veni, Vidi, Vici"}, {14.5f, "Present Day 3"}
    };
    vars.Missions = new Dictionary<uint, Tuple<string, float>>
    {
        //present day 1
        {0x6697F883, Tuple.Create("Escaping Abstergo", 0.5f)}, {0x9C1E07D6, Tuple.Create("Animus 2.0", 0.5f)},
        // Sequence 1 Ignorance Is Bliss
        {0x385B98EB, Tuple.Create("Boys Will Be Boys", 1f)}, {0x3904C2E5, Tuple.Create("You Should See the Other Guy", 1f)}, 
        {0x3904EBE9, Tuple.Create("Sibling Rivalary", 1f)}, {0x3904EBEC, Tuple.Create("Nightcap", 1f)}, 
        {0x3904EBEF, Tuple.Create("Paperboy", 1f)}, {0x3904EBF2, Tuple.Create("Beat a Cheat", 1f)}, 
        {0x3904EBF5, Tuple.Create("Petruccio's Secret", 1f)}, {0x3904EC40, Tuple.Create("Friend of the Family", 1f)}, 
        {0x3904EC44, Tuple.Create("Special Delivery", 1f)}, {0x3904EC47, Tuple.Create("JailBird", 1f)}, 
        {0x3904EC4A, Tuple.Create("Family Heirloom", 1f)}, {0x3904EC4D, Tuple.Create("Last Man Standing", 1f)},
        // Sequence 2 Escape Plans
        {0x397E179F, Tuple.Create("Fitting In", 2f)}, {0x39E0A28D, Tuple.Create("Ace Up My Sleeve", 2f)}, 
        {0x39E0A28A, Tuple.Create("Judge, Jury, Executioner", 2f)}, {0x39E0A287, Tuple.Create("Laying Low", 2f)}, 
        {0x39E0A284, Tuple.Create("Arrivederci", 2f)},
        // Sequence 3 Requiescat in Pace
        {0x53E662CA, Tuple.Create("RoadSide Assistance", 3f)}, {0x53E662E4, Tuple.Create("Casa Dolce Casa", 3f)}, 
        {0x53E662E7, Tuple.Create("Practice Makes Perfect", 3f)}, {0x53E662EA, Tuple.Create("What Goes Around", 3f)}, 
        {0x53E662ED, Tuple.Create("A Change of Plans", 3f)},
        // Sequence 4 The Pazzi Conspiracy
        {0x38EA7247, Tuple.Create("Practice What You Preach", 4f)}, {0x38EA724A, Tuple.Create("Fox Hunt", 4f)}, 
        {0x38EA724D, Tuple.Create("See You There", 4f)}, {0x4549D89D, Tuple.Create("Novella's Secret", 4f)}, 
        {0x38EA7253, Tuple.Create("Wolves in Sheep's Clothing", 4f)}, {0x38EA7256, Tuple.Create("Farewell Francesco", 4f)},
        // Sequence 5 Loose Ends
        {0x44F3E3CF, Tuple.Create("Lorenzo's Reward", 5f)}, {0x900AFDA9, Tuple.Create("A Blade with Bite", 5f)}, 
        {0x44F3E3D2, Tuple.Create("Evasive Maneuvers", 5f)}, {0x44F3E3D5, Tuple.Create("Town Crier", 5f)}, 
        {0x44F3E3D8, Tuple.Create("Come Out and Play", 5f)}, {0x044F3E3DB, Tuple.Create("The Cowl Does Not Make the Monk", 5f)},
        {0x44F3E3DE, Tuple.Create("Behind Closed Doors", 5f)}, {0x44F3E3E1, Tuple.Create("With Friends Like These", 5f)},
        // Sequence 6 Rocky Road
        {0x45112AA2, Tuple.Create("Road Trip", 6f)}, {0x53AC7948, Tuple.Create("Romagna Holiday", 6f)}, 
        {0x45112AA8, Tuple.Create("Tutti a Bordo", 6f)}, {0x8A3E691C, Tuple.Create("Alt end", 6f)},
        // Present Day 2
        {0xB5E0167E, Tuple.Create("Interlude?", 6.5f)}, {0x56FC8626, Tuple.Create("Warehouse", 6.5f)}, 
        {0x6799E8DE, Tuple.Create("Altair", 6.5f)},
        // Sequence 7 The Merchant of Venice
        {0x0E553CCF, Tuple.Create("Benvenuto", 7f)}, {0x1594A6F1, Tuple.Create("That's Gonna Leave a Mark", 7f)}, 
        {0x1CA10BB1, Tuple.Create("Building Blocks", 7f)}, {0xFBED01F, Tuple.Create("Breakout", 7f)},
        {0x16C116C9, Tuple.Create("Clothes Make the Man", 7f)}, {0x15DF90C1, Tuple.Create("Cleaning House", 7f)},
        {0x15B3D7A0, Tuple.Create("Monkey See, Monkey Do", 7f)}, {0x161B79EE, Tuple.Create("By Leaps and Bounds", 7f)}, 
        {0xDB13BF3, Tuple.Create("Everything Must Go", 7f)},
        // Sequence 8 Necessity, Mother of Invention
        {0x44C119BD, Tuple.Create("Birds of a Feather", 8f)}, {0x44C119C6, Tuple.Create("If at first you don't succeed", 8f)}, 
        {0x44C119C3, Tuple.Create("Nothing ventured, nothing gained", 8f)}, {0x44C119C0, Tuple.Create("Well begun is half done", 8f)}, 
        {0x44C119C9, Tuple.Create("Infrequent flier", 8f)},
        // Sequence 9 Carnevale
        {0x635BC901, Tuple.Create("Knowledge is power", 9f)}, {0x635BC904, Tuple.Create("Damsels in distress", 9f)}, 
        {0x635BC907, Tuple.Create("Nun the wiser", 9f)}, {0x635BC90A, Tuple.Create("And they're off", 9f)},
        {0x635BC913, Tuple.Create("CTF-Capture the Flag", 9f)},  {0x635BC910, Tuple.Create("Ribbon round-up", 9f)}, 
        {0x635BC90D, Tuple.Create("Cheaters never prosper", 9f)}, {0x635BC916, Tuple.Create("Having a blast", 9f)},
        // Sequence 10 Force Majeure
        {0x635BC9A6, Tuple.Create("An unpleasant turn of events", 10f)}, {0x635BC9A9, Tuple.Create("Caged fighter", 10f)}, 
        {0x635BC9AC, Tuple.Create("Leave no man behind", 10f)}, {0x635BC9AF, Tuple.Create("Assume the position", 10f)},
        {0x635BC9B2, Tuple.Create("Two birds, one blade", 10f)},  
        // Sequence 11 Alter Egos
        {0x63904392, Tuple.Create("All things come to he who waits", 11f)}, {0x63904398, Tuple.Create("Play along", 11f)},
        // Sequence 12 Battle of Florli
        {0x9AF3C2C1, Tuple.Create("A warm welcome", 12f)}, {0x9AF3C2C4, Tuple.Create("Bodyguard", 12f)},
        {0x9AF3C2C7, Tuple.Create("Holding the fort", 12f)}, {0x9AF3C2CA, Tuple.Create("Godfather", 12f)},
        {0x9AF3C2CD, Tuple.Create("Checcomate", 12f)}, {0xABB3E6A6, Tuple.Create("Far from the tree", 12f)},
        // Sequence 13 Bonfire of the Vanities
        {0x0D4A26D0, Tuple.Create("Florentine fiasco", 13f)}, {0x0D4A2712, Tuple.Create("Still life", 13f)}, // missions 1 & 2
        {0x0D4A274F, Tuple.Create("Climbing the ranks", 13f)}, {0x0D4A2785, Tuple.Create("Upward mobility", 13f)}, // missions 3 & 4
        {0x0D4A27BE, Tuple.Create("Last rites", 13f)}, {0x0D4A27E8, Tuple.Create("Port authority", 13f)}, //missions 5 & 6
        {0x0D4A280F, Tuple.Create("Surgical strike", 13f)}, {0x0D4A2851, Tuple.Create("Hitting the hay", 13f)}, // Missions 7 & 8
        {0x0D4A2889, Tuple.Create("Arch nemesis", 13f)}, {0x0D4A28CF, Tuple.Create("Doomsday", 13f)}, // missions 9 & 10
        {0x0D4A291C, Tuple.Create("Power to the people", 13f)}, {0x0D4A2942, Tuple.Create("Mob Justice", 13f)}, // missions 11 & 12
        // Sequence 14 Veni, Vidi, Vici
        {0x2532C038, Tuple.Create("X marks the spot", 14f)}, {0xD2365A19, Tuple.Create("In bocca al lupo", 14f)}, 
        {0x54D6A2BE, Tuple.Create("Minerva Cutscene", 14f)},
        // Present Day 3
        {0x40F4541F, Tuple.Create("Leaving the Assassin hideout", 14.5f)}, 
        // extras: Tuple.Create(0x0, "", 0f),
    };
    settings.Add("Splits", false, "Any% Splits");
    settings.SetToolTip("Splits", "Contains all missions you can split on for Any%.");
    settings.Add("Alt", false, "Alternate Splits");
    settings.SetToolTip("Alt", "Contains alternate splits.\nSuch as Money, Codex Pages, Feathers, and percentage increase.");
    settings.Add("Money", false, "Money Splits", "Alt");
    settings.SetToolTip("Money", "This will split after getting money from chests");
    settings.Add("CodexPages", false, "Codex Pages Splits", "Alt");
    settings.SetToolTip("CodexPages", "This will split after collecting codex pages");
    settings.Add("Feathers", false, "Feather Splits", "Alt");
    settings.SetToolTip("Feathers", "This will split after collecting a feather");
    settings.Add("Percentage", false, "Percentage Splits", "Alt");
    settings.SetToolTip("Percentage", "This will split after the in game percentage increases\n" +
    "Note: will not split on all missions use with money splits if u want to split on all missions");
    /*for(float i = 0.5f; i <= 14.5f; i += 0.5f)
    {
        if(!vars.Sequence.ContainsKey(i))
        {
            continue;
        }
        string sequenceName = vars.Sequence[i];
        settings.Add(sequenceName, false, sequenceName, "Splits");
        settings.SetToolTip(sequenceName, "Contains all splits for " + sequenceName + ".");
        foreach (var mission in vars.Missions)
        {
            var sequence = mission.Value.Item2;
            string missionName = mission.Value.Item1;
            if (sequence == i)
            {
                if (missionName == "Interlude?"){continue;}
                settings.Add(missionName, false, missionName, sequenceName);
                switch (missionName)
                {
                    case "Escaping Abstergo":
                        settings.SetToolTip(missionName, "This will split after " + missionName + ".");
                        break;
                    case "Animus 2.0":
                        settings.SetToolTip(missionName, "This will split after interacting with " + missionName + ".");
                        break;
                    case "Alt end":
                        settings.SetToolTip(missionName, "This will split after once you board the ship and the cutscene ends.");
                        break;
                    case "Warehouse":
                    case "Altair":
                        settings.SetToolTip(missionName, "This will split after completing " + missionName + "segment of the modern day.");
                        break;
                    case "Minerva Cutscene":
                        settings.SetToolTip(missionName, "This will split after sitting through the " + missionName + ".");
                        break;
                    default:
                        settings.SetToolTip(missionName, "This will split after completing '" + missionName + "'.");
                        break;
                }
            }
        }
    }*/
}

init
{
    // a list for the amount of money you could get from a pickpocketing
    vars.PickPocketMoney = new List<int>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
    41,42,43,44,45,46,47,48,49,50,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,
    141,142,143,144,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,
    191,192,193,194,195,196,197,198,199};
    print("Module Size: " + modules.First().ModuleMemorySize.ToString());
    switch (modules.First().ModuleMemorySize)
    {
        case (35053568):
            print("Game Version: Pirate");
            version = "Pirate";
            break;
        case (35192832):
            print("Game Version: Legit");
            version = "Legit";
            break;
    }
    vars.GameTime = 0;
    vars.waitTime = 5;
    if (vars.IsStopwatchStop == true && timer.CurrentPhase == TimerPhase.Running)
    {
        vars.stopwatch.Start();
        vars.IsStopwatchStop = false; 
    }
    vars.CompletedMissions = new List<uint>();
    vars.missionValueIsValid = false;
    vars.enoughTimeHasPassed = false;
    vars.missionIsNew = false;
    vars.missionIsConfigured = false;
    vars.missionSplitIsEnabled = false;
    vars.gameIsReady = false;
    vars.SplitTime = null;
}

update
{
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
    current.timerPhase = timer.CurrentPhase;
    if (current.timerPhase.ToString() == "Paused")
    {
        vars.stopwatch.Stop();
    } else if (current.timerPhase.ToString() == "Running")
    {
        vars.stopwatch.Start();
    }

    if (vars.Missions.ContainsKey(current.currentMission))
    {
        timer.Run.Metadata.SetCustomVariable("CurrentMission", vars.Missions[current.currentMission].Item1);
    }
    if (vars.Missions.ContainsKey(current.lastCompletedMission))
    {
        timer.Run.Metadata.SetCustomVariable("Mission", vars.Missions[current.lastCompletedMission].Item1);
    }

    // main logic for mission splits
    vars.missionStatusIsValid = current.currentMissionStatus == 6 && (old.currentMissionStatus == 0 || old.currentMissionStatus == 5);
    //vars.missionValueIsValid = (current.lastCompletedMission == old.lastCompletedMission && vars.missionStatusIsValid) || 
    //(current.lastCompletedMission != old.lastCompletedMission && vars.missionStatusIsValid);
    vars.enoughTimeHasPassed = vars.splitTime >= vars.waitTime;
    vars.missionIsNew = !vars.CompletedMissions.Contains(current.lastCompletedMission);
    vars.missionIsConfigured = vars.Missions.ContainsKey(current.lastCompletedMission);
    vars.missionSplitIsEnabled = vars.missionIsConfigured && settings[vars.Missions[current.lastCompletedMission].Item1];
    vars.gameIsReady = current.loading != 6 && current.loading != 7 && current.loading != 4;
    //vars.ModernDayIsCompleted = current.AbstergoStatus == 6 || current.AnimusStatus == 6 || current.WarehouseStatus == 6 || current.AltairStatus == 6;
    vars.isModernDay = vars.ModernDayMissions.Contains(current.lastCompletedMission);
    
    // money splits
    vars.moneyIncreasedIsValid = current.money > old.money && current.percentage == old.percentage && !vars.PickPocketMoney.Contains(current.money-old.money);
    vars.moneyIsGameReady = (old.money != 0 || current.money != null);
}

onStart
{
    vars.stopwatch.Start();
}

split
{
    // for normal splits
    // only split if the mission is completed and the mission is in the list of missions to split on
    /*if (vars.missionValueIsValid && vars.enoughTimeHasPassed && vars.missionIsNew && vars.missionSplitIsEnabled && vars.gameIsReady)
    {
        print("splits on mission: " + vars.Missions[current.lastCompletedMission].Item1);
        vars.CompletedMissions.Add(current.lastCompletedMission); // prevents double splits
        vars.stopwatch.Restart(); //prevents double splits
        return true;
    }*/
    
    // Alternate splits
    // for splits such as chests and side missions and mission that dont increase the percentage
    for (int i = 0; i < vars.PickPocketMoney.Count; i++)
    {
        if(settings["Money"] && vars.moneyIncreasedIsValid && vars.enoughTimeHasPassed && vars.moneyIsGameReady && vars.gameIsReady)
        {
            print("split on money");
            vars.stopwatch.Restart(); //prevents double splits
            return true;
        }
    }
    if (settings["CodexPages"] && current.CodePages > old.CodePages && vars.enoughTimeHasPassed && vars.gameIsReady)
    {
        print("split on codex pages");
        vars.stopwatch.Restart(); //prevents double splits
        return true;
    }
    if (settings["Feathers"] && current.Feathers > old.Feathers && vars.enoughTimeHasPassed && vars.gameIsReady)
    {
        print("split on feathers");
        vars.stopwatch.Restart(); //prevents double splits
        return true;
    }
    if (settings["Percentage"] && current.percentage > old.percentage && vars.enoughTimeHasPassed && vars.gameIsReady)
    {
        print("split on percentage");
        vars.stopwatch.Restart();
        return true;
    }

    // no longer needed but keeping just in case
    /*
    
    // old in case the new doesnt work
    if ((current.lastCompletedMission != old.lastCompletedMission || current.lastCompletedMission == old.lastCompletedMission) && vars.splitTime >= vars.waitTime && !vars.CompletedMissions.Contains(current.lastCompletedMission)
    && vars.Missions.ContainsKey(current.lastCompletedMission) && settings[vars.Missions[current.lastCompletedMission].Item1] && current.currentMission == 0x0 && current.loading == 1)
    {
        print("splits on mission: " + vars.Missions[current.lastCompletedMission].Item1);
        vars.CompletedMissions.Add(current.lastCompletedMission); // prevents double splits
        vars.stopwatch.Restart(); //prevents double splits
        return true;
    }
    
    */
    
}

isLoading 
{
    return current.loading == 6 || current.loading == 7 || current.loading == 4;
}

onReset
{
    vars.CompletedMissions.Clear();
    vars.stopwatch.Reset();
}

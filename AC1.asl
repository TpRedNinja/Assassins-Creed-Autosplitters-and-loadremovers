// Assassins Creed 1 Autosplitter
state("AssassinsCreed_Dx10")
{
    int Health: 0x025C1470, 0x14; // current health
    int MaxHealth: 0x025C1470, 0x18; // What the current max health you can heal to
    int MainMenu: 0x1491F60; // 0 = in game, -1 = main menu
    float XCoord: 0x025C1554, 0x0, 0x90, 0x10, 0x1C, 0x70, 0x40; // Player X Coordinates
    float YCoord: 0x025C1554, 0x0, 0x90, 0x10, 0x1C, 0x70, 0x44; // Player Y Coordinates
    float ZCoord: 0x025C1554, 0x0, 0x90, 0x10, 0x1C, 0x70, 0x48; // Player Z Coordinates
    byte PlayerID: 0x025C1554, 0x0, 0x90, 0x10, 0x1C, 0x70, 0xA8; // Player ID 9 for Desmond, 1 for Altair
    int thing: 0x25A2E6C;
}

startup
{
    // set text taken from Poppy Playtime C2
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
    settings.Add("Splits", false, "Splits");
        settings.Add("MemoryBlockSplits", false, "Memory Block Splits", "Splits");
        settings.SetToolTip("MemoryBlockSplits", "This contains all the splits for memory blocks in order for the most part unless specified it can split for multiple parts");
            //Memory Block 1 Splits
            settings.Add("Tutorial", false, "Tutorial", "MemoryBlockSplits");
            settings.SetToolTip("Tutorial", "splits when you have loaded into Solomon's temple after the tutorial\nThis is the start of Memory Block 1 so if you want to split their choose this one");
            settings.Add("SolomonTemple1", false, "Solomon Temple Split1", "MemoryBlockSplits");
            settings.SetToolTip("SolomonTemple1", "Splits when you are about to load at the end of Solomon's temple.");
            settings.Add("SolomonTemple2", false, "Solomon Temple Split2", "MemoryBlockSplits");
            settings.SetToolTip("SolomonTemple2", "Splits when you load into Masyaf after Solomon's temple");
            settings.Add("MasyafDone", false, "Masyaf Done", "MemoryBlockSplits");
            settings.SetToolTip("MasyafDone", "Splits when you enter the load after Altair gets 'killed' by Al Mualim");
            //Memory Block 2 Splits
            settings.Add("MemoryBlock 2 Start", false, "Memory Block 2 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 2 Start", "Splits at the start of memory block 2");
            settings.Add("TraitorEavesdrop", false, "Traitor Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("TraitorEavesdrop", "Splits when you sit down on the bench for the eavesdrop in Masyaf");
            settings.Add("TurnTraitorIn", false, "Turn Traitor In", "MemoryBlockSplits");
            settings.SetToolTip("TurnTraitorIn", "Splits when you have captured the traitor beat-up dude");
            settings.Add("Haystack", false, "Mandatory Viewpoint", "MemoryBlockSplits");
            settings.SetToolTip("Haystack", "Splits when you are in the haystack after doing the leap of faith");
            // Memory Block 3-6 Splits
            settings.Add("MemoryBlock 3-6 Start", false, "Memory Block 3-6 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 3-6 Start", "Splits at the start of memory blocks 3-6. Also splits whenever you return to Masyaf after killing a target thats not the last one in the memory block.");
            settings.Add("Garnier Eavesdrop", false, "Garnier Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("Garnier Eavesdrop", "Splits when you sit down on the bench for the eavesdrop thats tied to the Garnier investigation in Acre");
            settings.Add("Abu'l Nuqoud Eavesdrop", false, "Abu'l Nuqoud Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("Abu'l Nuqoud Eavesdrop", "Splits when you sit down on the bench for the eavesdrop thats tied to the Abu'l Nuqoud investigation in Damascus");
            settings.Add("Majd Addin Eavesdrop", false, "Majd Addin Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("Majd Addin Eavesdrop", "Splits when you sit down on the bench for the eavesdrop thats tied to the Majd Addin investigation in Jerusalem");
            settings.Add("Jubair Eavesdrop", false, "Jubair Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("Jubair Eavesdrop", "Splits when you sit down on the bench for the eavesdrop thats tied to the Jubair investigation in Acre");
            settings.Add("Maria Eavesdrop", false, "Maria Eavesdrop", "MemoryBlockSplits");
            settings.SetToolTip("Maria Eavesdrop", "Splits when you sit down on the bench for the eavesdrop thats tied to the Maria investigation in Jerusalem");
            // Memory Block 7 Split
            settings.Add("MemoryBlock 7 Start", false, "Memory Block 7 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 7 Start", "Splits at the start of memory block 7.");
        // Bureau Splits
        settings.Add("BureauSplits", false, "Bureau Splits", "Splits");
        settings.SetToolTip("BureauSplits", "This contains splits for the assassin's bureaus in each city whenever you quit warp to them or after you inform the bureau leader or kill your target.");
            settings.Add("DamascusBureauQuit", false, "Damascus Bureau(Quit)", "BureauSplits");
            settings.SetToolTip("DamascusBureauQuit", "Splits for the Assassin's Bureau in Damascus whenever you quit warp to it");
            settings.Add("DamascusBureau", false, "Damascus Bureau", "BureauSplits");
            settings.SetToolTip("DamascusBureau", "Splits for the Assassin's Bureau in Damascus after you inform the bureau leader or kill your target.");
            settings.Add("AcreBureauQuit", false, "Acre Bureau(Quit)", "BureauSplits");
            settings.SetToolTip("AcreBureauQuit", "Splits for the Assassin's Bureau in Acre whenever you quit warp to it");
            settings.Add("AcreBureau", false, "Acre Bureau", "BureauSplits");
            settings.SetToolTip("AcreBureau", "Splits for the Assassin's Bureau in Acre after you inform the bureau leader or kill your target.");
            settings.Add("JerusalemBureauQuit", false, "Jerusalem Bureau(Quit)", "BureauSplits");
            settings.SetToolTip("JerusalemBureauQuit", "Splits for the Assassin's Bureau in Jerusalem whenever you quit warp to it");
            settings.Add("JerusalemBureau", false, "Jerusalem Bureau", "BureauSplits");
            settings.SetToolTip("JerusalemBureau", "Splits for the Assassin's Bureau in Jerusalem after you inform the bureau leader or kill your target.");
        // Misc splits
        settings.Add("MiscSplits", false, "Misc Splits", "Splits");
        settings.SetToolTip("MiscSplits", "This contains splits that aren't necessarily tied to a specific memory block but are still important splits for the run");
            settings.Add("DeathConfessionSplits", false, "Death Confession Splits", "MiscSplits");
            settings.SetToolTip("DeathConfessionSplits", "Splits for all targets when you are in the death confession room.");
            settings.Add("ExitAnimus", false, "Exiting Animus", "MiscSplits");
            settings.SetToolTip("ExitAnimus", "Splits when Desmond is physically leaving the animus");
            settings.Add("QuitWarpExit", false, "Quit to animus - Exiting", "MiscSplits");
            settings.SetToolTip("QuitWarpExit", "Splits when you quit to the animus");
            settings.Add("QuitWarpEnter", false, "Quit to animus - Entering", "MiscSplits");
            settings.SetToolTip("QuitWarpEnter", "Splits when you enter the animus after quitting to the animus");
            settings.Add("HealthIncreaseSplits", false, "HealthIncreaseSplits", "MiscSplits");
            settings.SetToolTip("HealthIncreaseSplits", "Splits when you gain a health increase/rank up.");
    settings.Add("Memory Block Runs", false, "Memory Block Start Timer");
    settings.SetToolTip("Memory Block Runs", "Starts the timer at the start of memory blocks so you can time them separately. Note Memory Blocks 3-6 share the same start position.");
        for (int i = 1; i <= 7; i++)
        {
            settings.Add("MemoryBlock" + i, false, "Memory Block " + i, "Memory Block Runs");
            settings.SetToolTip("MemoryBlock" + i, "Starts the timer for the start of memory block " + i);
        }
    settings.Add("DebugPrint", false, "For dev only do not turn on");
    settings.SetToolTip("DebugPrint", "Do not turn this on otherwise livesplit will add stuff to your layout so just keep it turned off");
    settings.Add("NoToleranceTest", false, "No Tolerance Test");
    settings.Add("WithToleranceTest", false, "With Tolerance Test");
    settings.Add("XYZ", false, "XYZ");
    settings.SetToolTip("XYZ", "Adds a text component to the layout that shows the players current XYZ coordinates");
    vars.X = 0.0f;
    vars.Y = 0.0f;
    vars.Z = 0.0f;
    vars.MemoryBlock = 0;
    vars.SplitPositions = new Dictionary<string, Tuple<float [], float[]>>
    {
        {"Tutorial", Tuple.Create(new float [] {-66.18973f, -58.75932f, -8.38886f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Solomon Temple 1", Tuple.Create(new float [] {1.13976f, 30.56754f, 13.25423f}, new float [] {0.02517f, 0.10636f, 0.00100f})},
        {"Solomon Temple 2", Tuple.Create(new float [] {-39.1783f, -33.99732f, 34.46896f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Masyaf Done", Tuple.Create(new float [] {202.62020f, -3.95567f, 99.26974f}, new float [] {0.00003f, 0.00000f, 0.04160f})},
        {"MemoryBlock 2 Start", Tuple.Create(new float [] {208.24425f, 11.22722f, 107.64150f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Traitor Eavesdrop", Tuple.Create(new float [] {7.16993f, -16.99199f, 34.64021f}, new float [] {0.00319f, 0.01306f, 0.00000f})},
        {"Turn Traitor In", Tuple.Create(new float [] {207.08463f, 11.84124f, 107.60572f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Haystack", Tuple.Create(new float [] {-222.54272f, 722.5073f, 89.77293f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Damascus Bureau Quit", Tuple.Create(new float [] {46.38885f, 6.1258f, 4.13938f}, new float [] {0.00000f, 0.00000f, 0.00020f})},
        {"Damascus Bureau", Tuple.Create(new float [] {42.75412f, 7.48691f, 4.12456f}, new float [] {0.00000f, 0.00000f, 0.00007f})},
        {"MemoryBlock 3-6 Start", Tuple.Create(new float [] {207.43881f, 12.49873f, 107.60572f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Garnier Eavesdrop", Tuple.Create(new float [] {-179.621f, 162.3696f, 17.00000f}, new float [] {0.00346f, 0.01912f, 0.00000f})},
        {"Acre Bureau Quit", Tuple.Create(new float [] {-2.54902f, 39.92605f, 5.14663f}, new float [] {0.00002f, 0.00002f, 0.00002f})},
        {"Acre Bureau", Tuple.Create(new float [] {-2.03045f, 42.15536f, 5.14195f}, new float [] {0.00190f, 0.00166f, 0.00002f})},
        {"Jerusalem Bureau Quit", Tuple.Create(new float [] {91.00118f, 84.52809f, 2.25257f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Jerusalem Bureau", Tuple.Create(new float [] {91.33311f, 88.22004f, 2.01741f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Abu'l Nuqoud Eavesdrop", Tuple.Create(new float [] {-68.91216f, 85.63019f, 8.18865f}, new float [] {0.00054f, 0.01068f, 0.00000f})},
        {"Majd Addin Eavesdrop", Tuple.Create(new float [] {28.08077f, -179.1255f, 6.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Jubair Eavesdrop", Tuple.Create(new float [] {277.2652f, -39.46133f, 4.14445f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Maria Eavesdrop", Tuple.Create(new float [] {-139.9565f, 110.8973f, 10.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"MemoryBlock 7 Start", Tuple.Create(new float [] {-38.28265f, -33.71172f, 34.46831f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Death Confession Room for Maria", Tuple.Create(new float [] {-11.29227f, -30.75496f, 0.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Death Confession Room", Tuple.Create(new float [] {-11.42463f, -30.58017f, 0.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Loading Position", Tuple.Create(new float [] {-0.07626f, -0.10379f, 0.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Start of game", Tuple.Create(new float [] {-0.07626f, -0.10379f, 0.00000f}, new float [] {0.00000f, 0.00000f, 0.00000f})},
        {"Modern Day Position", Tuple.Create(new float [] {-2.63071f, -4.52977f, 0.00262f}, new float [] {0.00000f, 0.00000f, 0.00000f})}
    };
    
    // checks if the players current xyz is the same as the xyz of one of the items in the array 
    Func<dynamic, float[], bool> IsAtPositionCurrent = 
    (dynamic s, float [] pos) => 
    {
        if (s.XCoord == pos[0] && s.YCoord == pos[1] && s.ZCoord == pos[2])
        {
            return true;
        } /*else if (vars.X == pos[0] && vars.Y == pos[1] && vars.Z == pos[2])
        {
            return true;
        }*/
        return false;
    };
    vars.IsAtPositionCurrent = IsAtPositionCurrent;
    // same as above but has tolerance
    Func<dynamic, float[], float[], bool> IsAtPositionCurrentWithTolerance = 
    (dynamic s, float [] pos, float [] tol) => 
    {
        if (Math.Abs(s.XCoord - pos[0]) <= tol[0] && Math.Abs(s.YCoord - pos[1]) <= tol[1] && Math.Abs(s.ZCoord - pos[2]) <= tol[2])
        {
            return true;
        } /*else if (vars.X == pos[0] && vars.Y == pos[1] && vars.Z == pos[2])
        {
            return true;
        }*/
        return false;
    };
    vars.IsAtPositionCurrentWithTolerance = IsAtPositionCurrentWithTolerance;
    // checks if the players old xyz is not the same as the xyz of one of the items in the array 
    Func<dynamic, float[], bool> IsAtPositionOld = 
    (dynamic s, float [] pos) => 
    {
        if (s.XCoord != pos[0] || s.YCoord != pos[1] || s.ZCoord != pos[2])
        {
            return true;
        }/* else if (vars.X != pos[0] && vars.Y != pos[1] && vars.Z != pos[2])
        {
            return true;
        }*/
        return false;
    };
    vars.IsAtPositionOld = IsAtPositionOld;
    Func<dynamic, float[], float[], bool> IsAtPositionOldWithTolerance = 
    (dynamic s, float [] pos, float [] tol) => 
    {
        if (Math.Abs(s.XCoord - pos[0]) > tol[0] || Math.Abs(s.YCoord - pos[1]) > tol[1] || Math.Abs(s.ZCoord - pos[2]) > tol[2])
        {
            return true;
        }/* else if (vars.X != pos[0] && vars.Y != pos[1] && vars.Z != pos[2])
        {
            return true;
        }*/
        return false;
    };
    vars.IsAtPositionOldWithTolerance = IsAtPositionOldWithTolerance;
    // difference between positions
    Func<dynamic, float [], bool> IsDiffNot0 =
    (dynamic s, float [] pos) =>
    {
        if ((s.XCoord - pos[0]) > 0 || (s.XCoord - pos[0]) < 0)
        {
            print("Difference in X: " + Math.Round(Math.Abs(s.XCoord - pos[0]), 5));
            return true;
        }
        if ((s.YCoord - pos[1]) > 0 || (s.YCoord - pos[1]) < 0)
        {
            print("Difference in Y: " + Math.Round(Math.Abs(s.YCoord - pos[1]), 5));
            return true;
        }
        if ((s.ZCoord - pos[2]) > 0 || (s.ZCoord - pos[2]) < 0)
        {
            print("Difference in Z: " + Math.Round(Math.Abs(s.ZCoord - pos[2]), 5));
            return true;
        }
        print("At position " + vars.TestingPos);
        return false;
    };
    vars.IsDiffNot0 = IsDiffNot0;
    // same as above but with tolerance
    Func<dynamic, float [], float [], bool> IsDiffNot0WithTolerance =
    (dynamic s, float [] pos, float [] tol) =>
    {
        if (Math.Abs(s.XCoord - pos[0]) > 0 && Math.Round(Math.Abs(s.XCoord - pos[0]), 5) > tol[0])
        {
            print("Difference in X: " + Math.Round(Math.Abs(s.XCoord - pos[0]), 5));
            return true;
        }
        if (Math.Abs(s.YCoord - pos[1]) > 0 && Math.Round(Math.Abs(s.YCoord - pos[1]), 5) > tol[1])
        {
            print("Difference in Y: " + Math.Round(Math.Abs(s.YCoord - pos[1]), 5));
            return true;
        }
        if (Math.Abs(s.ZCoord - pos[2]) > 0 && Math.Round(Math.Abs(s.ZCoord - pos[2]), 5) > tol[2])
        {
            print("Difference in Z: " + Math.Round(Math.Abs(s.ZCoord - pos[2]), 5));
            return true;
        }
        print("At position " + vars.TestingPos + " with tolerance.");
        return false;
    };
    vars.IsDiffNot0WithTolerance = IsDiffNot0WithTolerance;
    vars.TestingPos = "Jerusalem Bureau"; // change this to one of the dictionary keys to test different positions in the array
    vars.TestingPos2 = "MemoryBlock 3-6 Start"; // change this index to test different positions in the array
    vars.ToleranceTestingPos = 2; // change this index to test different tolerances in the array
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = 0;
    vars.IsTutorialDone = false;
}

update
{
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
    current.XCoord = (float)Math.Round(current.XCoord, 5);
    current.YCoord = (float)Math.Round(current.YCoord, 5);
    current.ZCoord = (float)Math.Round(current.ZCoord, 5);
    /*vars.X = (float)Math.Round(current.XCoord, 5);
    vars.Y = (float)Math.Round(current.YCoord, 5);
    vars.Z = (float)Math.Round(current.ZCoord, 5);*/

    if (settings["DebugPrint"])
    {
        vars.SetTextComponent("XYZ", "( " + current.XCoord + ", " + current.YCoord + ", " + current.ZCoord + " )");
        vars.SetTextComponent("IsAtPositionCurrentSplits: ", vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.TestingPos].Item1) + "");
        vars.SetTextComponent("IsAtPositionOldSplits: ", vars.IsAtPositionOld(old, vars.SplitPositions[vars.TestingPos].Item1) + "");
        vars.SetTextComponent("IsAtPositionCurrentStarts: ", vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.TestingPos2].Item1) + "");
        vars.SetTextComponent("IsAtPositionOldStarts: ", vars.IsAtPositionOld(old, vars.SplitPositions[vars.TestingPos2].Item1) + "");
        vars.SetTextComponent("SplitTime: ", vars.SplitTime + "/5");
        //print("IsAtPosition " + vars.TestingPos + ": " + vars.IsAtPosition(current, vars.StartPositions[vars.TestingPos]));
        //print("difference " + (vars.X - vars.StartPositions[vars.TestingPos][0]));
        //print("Current Z: " + current.ZCoord);
    }

    if (settings["NoToleranceTest"])
    {
        if (vars.IsDiffNot0(current, vars.SplitPositions[vars.TestingPos].Item1))
        {
            print("Difference for position " + vars.TestingPos + " is not 0");
        }
    }

    if (settings["WithToleranceTest"])
    {
        if (vars.IsDiffNot0WithTolerance(current, vars.SplitPositions[vars.TestingPos].Item1, vars.SplitPositions[vars.TestingPos].Item2))
        {
            print("Difference for position " + vars.TestingPos + " is not 0");
        }
    }

    if (settings["XYZ"])
    {
        vars.SetTextComponent("XYZ", "( " + current.XCoord + ", " + current.YCoord + ", " + current.ZCoord + " )");
    }
}

start
{
    if (settings["Memory Block Runs"])
    {
        if(settings["MemoryBlock1"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Tutorial"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Tutorial"].Item1))
        {
            print("Started for Memory Block 1");
            return true;
        } else if(settings["MemoryBlock2"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 2 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 2 Start"].Item1))
        {
            print("Started for Memory Block 2");
            return true;
        } else if(settings["MemoryBlock3-6"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 3-6 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 3-6 Start"].Item1))
        {
            print("Started for Memory Block 3-6");
            return true;
        } else if(settings["MemoryBlock7"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 7 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 7 Start"].Item1))
        {
            print("Started for Memory Block 7");
            return true;
        }
    }
}

onStart
{
    vars.stopwatch.Start();
}

split
{
    // splits when you have loaded into Solomon's temple after the tutorial
    if (settings["Tutorial"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Tutorial"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Tutorial"].Item1))
    {
        if (settings["DebugPrint"])
            print("Tutorial split triggered.");
        vars.IsTutorialDone = true;
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when right before you start to load at the end of Solomon's temple.
    if (settings["SolomonTemple1"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Solomon Temple 1"].Item1, vars.SplitPositions["Solomon Temple 1"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Solomon Temple 1"].Item1, vars.SplitPositions["Solomon Temple 1"].Item2))
    {
        if (settings["DebugPrint"])
            print("Solomon's temple split1 triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you load into Masyaf after Solomon's temple
    if (settings["SolomonTemple2"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Solomon Temple 2"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Solomon Temple 2"].Item1))
    {
        if (settings["DebugPrint"])
            print("Solomon's temple split2 triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits After getting 'killed' by Al Mualim at the end of Masyaf
    if (settings["MasyafDone"] && vars.IsAtPositionCurrentWithTolerance(old, vars.SplitPositions["Masyaf Done"].Item1, vars.SplitPositions["Masyaf Done"].Item2) && vars.IsAtPositionCurrent(current, vars.SplitPositions["LoadingPos"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["LoadingPos"].Item1))
    {
        if (settings["DebugPrint"])
            print("Masyaf done split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits at the start of memory blocks 2
    if (settings["MemoryBlock 2 Start"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 2 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 2 Start"].Item1))
    {
        if (settings["DebugPrint"])
            print("Memory block 2 start split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you sit down on the bench for the eavesdrop in Masyaf
    if (settings["TraitorEavesdrop"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Traitor Eavesdrop"].Item1, vars.SplitPositions["Traitor Eavesdrop"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Traitor Eavesdrop"].Item1, vars.SplitPositions["Traitor Eavesdrop"].Item2))
    {
            if (settings["DebugPrint"])
                print("Masyaf eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you have captured the traitor beat-up dude
    if (settings["TurnTraitorIn"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Turn Traitor In"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Turn Traitor In"].Item1))
    {
        if (settings["DebugPrint"])
            print("Turn traitor in split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you are in the haystack after doing the leap of faith
    if (settings["Haystack"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Haystack"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Haystack"].Item1))
    {
        if (settings["DebugPrint"])
            print("Haystack split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits at the start of memory blocks 3-6. Also splits whenever you return to Masyaf after killing a target thats not the last one in the memory block.
    if (settings["MemoryBlock 3-6 Start"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 3-6 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 3-6 Start"].Item1))
    {
        if (settings["DebugPrint"])
            print("Memory block 3-6 start split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Garnier Eavesdrop in Acre
    if (settings["Garnier Eavesdrop"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Garnier Eavesdrop"].Item1, vars.SplitPositions["Garnier Eavesdrop"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Garnier Eavesdrop"].Item1, vars.SplitPositions["Garnier Eavesdrop"].Item2))
    {
        if (settings["DebugPrint"])
            print("Garnier eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Abu'l Nuqoud Eavesdrop in Damascus
    if (settings["Abu'l Nuqoud Eavesdrop"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Abu'l Nuqoud Eavesdrop"].Item1, vars.SplitPositions["Abu'l Nuqoud Eavesdrop"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Abu'l Nuqoud Eavesdrop"].Item1, vars.SplitPositions["Abu'l Nuqoud Eavesdrop"].Item2))
    {
        if (settings["DebugPrint"])
            print("Abu'l Nuqoud eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Majd Addin Eavesdrop in Jerusalem
    if (settings["Majd Addin Eavesdrop"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Majd Addin Eavesdrop"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Majd Addin Eavesdrop"].Item1))
    {
        if (settings["DebugPrint"])
            print("Majd Addin eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Jubair Eavesdrop in Damascus
    if (settings["Jubair Eavesdrop"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Jubair Eavesdrop"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Jubair Eavesdrop"].Item1))
    {
        if (settings["DebugPrint"])
            print("Jubair eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Maria Eavesdrop in Jerusalem
    if (settings["Maria Eavesdrop"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Maria Eavesdrop"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Maria Eavesdrop"].Item1))
    {
        if (settings["DebugPrint"])
            print("Maria eavesdrop split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits at the start of memory block 7.
    if (settings["MemoryBlock 7 Start"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["MemoryBlock 7 Start"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["MemoryBlock 7 Start"].Item1))
    {
        if (settings["DebugPrint"])
            print("Memory block 7 start split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you gain a rank
    if (settings["HealthIncreaseSplits"] && current.MaxHealth == old.MaxHealth + 1)
    {
        if (settings["DebugPrint"])
            print("Health increase split triggered. Current health: " + current.MaxHealth);
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when Desmond is physically leaving the animus
    if (settings["ExitAnimus"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Modern Day Position"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Modern Day Position"].Item1))
    {
        if (settings["DebugPrint"])
            print("Exit animus split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you quit to the animus
    if (settings["QuitWarpExit"] && current.PlayerID == 9 && old.PlayerID == 1 && vars.IsTutorialDone)
    {        
        if (settings["DebugPrint"])
            print("Quit to animus split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you enter the animus after quitting to the animus
    if (settings["QuitWarpEnter"] && current.PlayerID == 1 && old.PlayerID == 9 && vars.IsTutorialDone)
    {
        if (settings["DebugPrint"])
            print("Enter animus split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for all targets when you are in the death confession room.
    if (settings["DeathConfessionSplits"] && (vars.IsAtPositionCurrent(current, vars.SplitPositions["Death Confession Room"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Death Confession Room"].Item1))
    || (vars.IsAtPositionCurrent(current, vars.SplitPositions["Death Confession Room for Maria"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Death Confession Room for Maria"].Item1)))
    {
        if (settings["DebugPrint"])
            print("Death confession split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you quit warp to the assassin's bureau in Damascus
    if (settings["DamascusBureauQuit"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Damascus Bureau Quit"].Item1, vars.SplitPositions["Damascus Bureau Quit"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Damascus Bureau Quit"].Item1, vars.SplitPositions["Damascus Bureau Quit"].Item2))
    {
        if (settings["DebugPrint"])
            print("Damascus bureau quit split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for the assassin's bureau in Damascus after you inform the bureau leader or kill your target.
    if (settings["DamascusBureau"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Damascus Bureau"].Item1, vars.SplitPositions["Damascus Bureau"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Damascus Bureau"].Item1, vars.SplitPositions["Damascus Bureau"].Item2))
    {
        if (settings["DebugPrint"])
            print("Damascus bureau split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you quit warp to the assassin's bureau in Acre
    if (settings["AcreBureauQuit"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Acre Bureau Quit"].Item1, vars.SplitPositions["Acre Bureau Quit"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Acre Bureau Quit"].Item1, vars.SplitPositions["Acre Bureau Quit"].Item2))
    {
        if (settings["DebugPrint"])
            print("Acre bureau quit split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for the assassin's bureau in Acre after you inform the bureau leader or kill your target.
    if (settings["AcreBureau"] && vars.IsAtPositionCurrentWithTolerance(current, vars.SplitPositions["Acre Bureau"].Item1, vars.SplitPositions["Acre Bureau"].Item2) && vars.IsAtPositionOldWithTolerance(old, vars.SplitPositions["Acre Bureau"].Item1, vars.SplitPositions["Acre Bureau"].Item2))
    {
        if (settings["DebugPrint"])
            print("Acre bureau split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you quit warp to the assassin's bureau in Jerusalem
    if(settings["JerusalemBureauQuit"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Jerusalem Bureau Quit"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Jerusalem Bureau Quit"].Item1))
    {
        if (settings["DebugPrint"])
            print("Jerusalem bureau quit split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for the assassin's bureau in Jerusalem after you inform the bureau leader or kill your target.
    if(settings["JerusalemBureau"] && vars.IsAtPositionCurrent(current, vars.SplitPositions["Jerusalem Bureau"].Item1) && vars.IsAtPositionOld(old, vars.SplitPositions["Jerusalem Bureau"].Item1))
    {
        if (settings["DebugPrint"])
            print("Jerusalem bureau split triggered.");
        vars.stopwatch.Restart();
        return true;
    }
}

onReset
{
    vars.IsTutorialDone = false;
    vars.stopwatch.Reset();
}

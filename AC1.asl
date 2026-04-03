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
        settings.Add("MemoryBlock1Splits", false, "Memory Block 1 Splits", "Splits");
        settings.SetToolTip("MemoryBlock1Splits", "Contains splits for memory block 1");
            settings.Add("Tutorial", false, "Tutorial", "MemoryBlock1Splits");
            settings.SetToolTip("Tutorial", "splits when you have loaded into Solomon's temple after the tutorial\nThis is the start of Memory Block 1 so if you want to split their choose this one");
            settings.Add("SolomonTemple1", false, "Solomon Temple Split1", "MemoryBlock1Splits");
            settings.SetToolTip("SolomonTemple1", "Splits when you are about to load at the end of Solomon's temple.");
            settings.Add("SolomonTemple2", false, "Solomon Temple Split2", "MemoryBlock1Splits");
            settings.SetToolTip("SolomonTemple2", "Splits when you load into Masyaf after Solomon's temple");
        settings.Add("MemoryBlock2Splits", false, "Memory Block 2 Splits", "Splits");
        settings.SetToolTip("MemoryBlock2Splits", "Contains splits for memory block 2");
            settings.Add("MemoryBlock 2 Start", false, "Memory Block 2 Start", "MemoryBlock2Splits");
            settings.SetToolTip("MemoryBlock 2 Start", "Splits at the start of memory block 2");
            settings.Add("MasyafEavesdrop", false, "Masyaf Eavesdrop", "MemoryBlock2Splits");
            settings.SetToolTip("MasyafEavesdrop", "Splits when you sit down on the bench for the eavesdrop in Masyaf");
            settings.Add("TurnTraitorIn", false, "Turn Traitor In", "MemoryBlock2Splits");
            settings.SetToolTip("TurnTraitorIn", "Splits when you have captured the traitor beat-up dude");
            settings.Add("Haystack", false, "Mandatory Viewpoint", "MemoryBlock2Splits");
            settings.SetToolTip("Haystack", "Splits when you are in the haystack after doing the leap of faith");
        settings.Add("MemoryBlock3Splits", false, "Memory Block 3 Splits", "Splits");
        settings.SetToolTip("MemoryBlock3Splits", "Contains splits for memory block 3");
            settings.Add("MemoryBlock 3 Start", false, "Memory Block 3 Start", "MemoryBlock3Splits");
            settings.SetToolTip("MemoryBlock 3 Start", "Splits at the start of memory block 3");
        settings.Add("MemoryBlock4Splits", false, "Memory Block 4 Splits", "Splits");
        settings.SetToolTip("MemoryBlock4Splits", "Contains splits for memory block 4");
            settings.Add("MemoryBlock 4 Start", false, "Memory Block 4 Start", "MemoryBlock4Splits");
            settings.SetToolTip("MemoryBlock 4 Start", "Splits at the start of memory block 4.");
        settings.Add("MemoryBlock5Splits", false, "Memory Block 5 Splits", "Splits");
        settings.SetToolTip("MemoryBlock5Splits", "Contains splits for memory block 5");
            settings.Add("MemoryBlock 5 Start", false, "Memory Block 5 Start", "MemoryBlock5Splits");
            settings.SetToolTip("MemoryBlock 5 Start", "Splits at the start of memory block 5.");
        settings.Add("MemoryBlock6Splits", false, "Memory Block 6 Splits", "Splits");
        settings.SetToolTip("MemoryBlock6Splits", "Contains splits for memory block 6");
            settings.Add("MemoryBlock 6 Start", false, "Memory Block 6 Start", "MemoryBlock6Splits");
            settings.SetToolTip("MemoryBlock 6 Start", "Splits at the start of memory block 6.");
        settings.Add("MemoryBlock7Splits", false, "Memory Block 7 Splits", "Splits");
        settings.SetToolTip("MemoryBlock7Splits", "Contains splits for memory block 7");
            settings.Add("MemoryBlock 7 Start", false, "Memory Block 7 Start", "MemoryBlock7Splits");
            settings.SetToolTip("MemoryBlock 7 Start", "Splits at the start of memory block 7.");
        settings.Add("DeathConfessionSplits", false, "Death Confession Splits", "Splits");
        settings.SetToolTip("DeathConfessionSplits", "Splits for all targets when you are in the death confession room.");
        settings.Add("ExitAnimus", false, "Exiting Animus", "Splits");
        settings.SetToolTip("ExitAnimus", "Splits when Desmond is physically leaving the animus");
        settings.Add("QuitWarpExit", false, "Quit to animus - Exiting", "Splits");
        settings.SetToolTip("QuitWarpExit", "Splits when you quit to the animus");
        settings.Add("QuitWarpEnter", false, "Quit to animus - Entering", "Splits");
        settings.SetToolTip("QuitWarpEnter", "Splits when you enter the animus after quitting to the animus");
        settings.Add("HealthIncreaseSplits", false, "HealthIncreaseSplits", "Splits");
        settings.SetToolTip("HealthIncreaseSplits", "Splits when you gain a health increase/rank up.");
    settings.Add("Memory Block Runs", false, "Memory Block Start Timer");
    settings.SetToolTip("Memory Block Runs", "Note: Memory Blocks 4-7 are Work In Progress and will not work currently");
        for (int i = 1; i <= 7; i++)
        {
            settings.Add("MemoryBlock" + i, false, "Memory Block " + i, "Memory Block Runs");
            settings.SetToolTip("MemoryBlock" + i, "Starts the timer for the start of memory block " + i);
        }
    settings.Add("DebugPrint", false, "For dev only do not turn on");
    settings.SetToolTip("DebugPrint", "Do not turn this on otherwise livesplit will add stuff to your layout so just keep it turned off");
    settings.Add("XYZ", false, "XYZ");
    settings.SetToolTip("XYZ", "Adds a text component to the layout that shows the players current XYZ coordinates");
    vars.X = 0.0f;
    vars.Y = 0.0f;
    vars.Z = 0.0f;
    vars.MemoryBlock = 0;
    // if i need to add more positions here is the copy pasta
    // new float [] {},
    // array of positions to check if the player is at, can add more if needed just make sure to update the indices in the code
    float [][] splitPositions =
    {
        new float [] {1.13976f, 30.56754f, 13.25423f}, // At end of Solomon's Temple about to load into Masyaf (double check)
        new float [] {-39.1783f, -33.99732f, 34.46896f}, // Load after Solomon's Temple into Masyaf, In Masyaf right after loading in
        new float [] {7.16993f, -16.99199f, 34.64021f}, // Traitor in Masyaf Eavesdrop
        new float [] {207.08463f, 11.84124f, 107.60572f}, // Turn Traitor in, the position of Altair after you beat up the dude and bring him to the mentor in the castle
        new float [] {-222.54272f, 722.5073f, 89.77293f}, // In the haystack after the mandatory viewpoint
        new float [] {46.38885f, 6.1258f, 4.13928f}, // Assassin's Bureau in Damascus after quit warping (double check)
        new float [] {42.75412, 7.48691f, 4.12456f}, // Assassin's Bureau in Damascus after informing the Bureau leader or after a assassination mission is complete.
        new float [] {-179.621f, 162.3696f, 17.00000f}, // Garnier Eavesdrop in Acre (double check)
        new float [] {-2.54902f, 39.92605f, 5.14663f}, // Assassin's Bureau in Acre after quit warping (double check)
        new float [] {-2.02865f, 42.15371f, 5.14196f}, // Assassin's Bureau in Acre after informing the Bureau leader or after a assassination mission is complete.
        new float [] {-86.82042f, 173.3221f, 27.85501f}, // Made it into the window for Garnier skip (double check)
        new float [] {91.00118f, 84.52809f, 2.25257f}, // Assassin's Bureau in Jerusalem after quit warping
        new float [] {91.33311f, 88.22004f, 2.01741f}, // Assassin's Bureau in Jerusalem after informing the Bureau leader or after a assassination mission is complete.
        new float [] {-68.91216f, 85.63019f, 8.18865f}, // Abu'l Nuqoud Eavesdrop in Damascus
        new float [] {28.08077f, -179.1255f, 6.00000f}, // Majd Addin Eavesdrop in Jerusalem (double check)
        new float [] {277.2652f, -39.46133f, 4.14445f}, // Jubair Eavesdrop in Damascus (double check)
        new float [] {-139.9565f, 110.8973f, 10.00000f}, // Maria Eavesdrop in Jerusalem (double check)
        new float [] {-11.29227f, -30.75496f, 0.00000f}, // Maria Death confession room
        new float [] {-11.42463f, -30.58017f, 0.00000f}, // In the Death confession room for all targets but maria
        new float [] {-0.07626f, -0.10379f, 0.00000f},// start of the game
        new float [] {-2.63071f, -4.52977f, 0.00262f} // in the animus but modern day
    };
    vars.SplitPositions = splitPositions;
    // arrays of start positions
    float [][] MemoryBlockPositions =
    {
        new float [] {-66.18973f, -58.75932f, -8.38886f}, // start of memory block 1
        new float [] {208.24425f, 11.22722f, 107.64150f}, // start of memory block 2
        new float [] {207.43881f, 12.49873f, 107.60572f}, // start of memory block 3
        new float [] {207.43881f, 12.49873f, 107.60572f}, // start of memory block 4
        new float [] {207.43881f, 12.49873f, 107.60572f}, // start of memory block 5
        new float [] {207.43881f, 12.49873f, 107.60572f}, // start of memory block 6
        new float [] {-38.28265f, -33.71172f, 34.46831f} // start of memory block 7
        
    };
    vars.MemoryBlockPositions = MemoryBlockPositions;
    vars.ModernDayPos = (vars.SplitPositions.Length - 1);
    vars.AnyPercentPos = (vars.SplitPositions.Length - 2);
    vars.DeathConfessionPos = (vars.SplitPositions.Length - 3);
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
    // checks if the players old xyz is not the same as the xyz of one of the items in the array 
    Func<dynamic, float[], bool> IsAtPositionOld = 
    (dynamic s, float [] pos) => 
    {
        if (s.XCoord != pos[0] && s.YCoord != pos[1] && s.ZCoord != pos[2])
        {
            return true;
        }/* else if (vars.X != pos[0] && vars.Y != pos[1] && vars.Z != pos[2])
        {
            return true;
        }*/
        return false;
    };
    vars.IsAtPositionOld = IsAtPositionOld;
    // difference between positions
    Func<dynamic, float [], bool> IsDiffNot0 =
    (dynamic s, float [] pos) =>
    {
        if ((s.XCoord - pos[0]) > 0 || (s.XCoord - pos[0]) < 0)
        {
            print("Difference in X: " + Math.Abs(s.XCoord - pos[0]));
            return true;
        } else if ((s.YCoord - pos[1]) > 0 || (s.YCoord - pos[1]) < 0)
        {
            print("Difference in Y: " + Math.Abs(s.YCoord - pos[1]));
            return true;
        } else if ((s.ZCoord - pos[2]) > 0 || (s.ZCoord - pos[2]) < 0)
        {
            print("Difference in Z: " + Math.Abs(s.ZCoord - pos[2]));
            return true;
        }
        return false;
    };
    vars.IsDiffNot0 = IsDiffNot0;
    vars.TestingPos = vars.AnyPercentPos; // change this index to test different positions in the array
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
        vars.SetTextComponent("IsAtPositionCurrentSplits: ", vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.TestingPos]) + "");
        vars.SetTextComponent("IsAtPositionOldSplits: ", vars.IsAtPositionOld(old, vars.SplitPositions[vars.TestingPos]) + "");
        vars.SetTextComponent("IsAtPositionCurrentStarts: ", vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[0]) + "");
        vars.SetTextComponent("IsAtPositionOldStarts: ", vars.IsAtPositionOld(old, vars.MemoryBlockPositions[0]) + "");
        vars.SetTextComponent("SplitTime: ", vars.SplitTime + "/5");
        //print("IsAtPosition " + vars.TestingPos + ": " + vars.IsAtPosition(current, vars.StartPositions[vars.TestingPos]));
        //print("difference " + (vars.X - vars.StartPositions[vars.TestingPos][0]));
        //print("Current Z: " + current.ZCoord);

        if (vars.IsDiffNot0(current, vars.SplitPositions[vars.TestingPos]))
        {
            print("Difference for position " + vars.TestingPos + " is not 0");
        }

        if (vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.TestingPos]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.TestingPos]))
        {
            print("At position " + vars.TestingPos);
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
        if (settings["MemoryBlock1"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[0]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[0]))
        {
            return true;
        } else if (settings["MemoryBlock2"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[1]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[1]))
        {
            return true;
        } else if (settings["MemoryBlock3"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[2]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[2]))
        {
            return true;
        } else if (settings["MemoryBlock4"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[3]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[3]))
        {
            return true;
        } else if (settings["MemoryBlock5"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[4]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[4]))
        {
            return true;
        } else if (settings["MemoryBlock6"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[5]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[5]))
        {
            return true;
        } else if (settings["MemoryBlock7"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[6]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[6]))
        {
            return true;
        }
    } 
    // doesn't work.
    if (vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.AnyPercentPos]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.AnyPercentPos])) // start after leaving the main menu
    {
        return true;
    }
}

onStart
{
    vars.stopwatch.Start();
}

split
{
    // splits when you have loaded into Solomon's temple after the tutorial
    if (settings["Tutorial"] && vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[0]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[0]))
    {
        vars.IsTutorialDone = true;
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when right before you start to load at the end of Solomon's temple.
    if (settings["SolomonTemple1"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[0]) && vars.IsAtPositionOld(old, vars.SplitPositions[0]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you load into Masyaf after Solomon's temple
    if (settings["SolomonTemple2"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[1]) && vars.IsAtPositionOld(old, vars.SplitPositions[1]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you sit down on the bench for the eavesdrop in Masyaf
    if (settings["MasyafEavesdrop"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[2]) && vars.IsAtPositionOld(old, vars.SplitPositions[2]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you have captured the traitor beat-up dude
    if (settings["TurnTraitorIn"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[3]) && vars.IsAtPositionOld(old, vars.SplitPositions[3]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you are in the haystack after doing the leap of faith
    if (settings["Haystack"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[4]) && vars.IsAtPositionOld(old, vars.SplitPositions[4]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits at the start of memory blocks 2-7, if you want to split at the start of memory block 1 then use the tutorial split
    for (int i = 2; i <= 7; i++)
    {
        string settingName = "MemoryBlock " + i + " Start";
        //print("Checking split for " + vars.MemoryBlockPositions[i-1]);
        if (vars.IsAtPositionCurrent(old, vars.MemoryBlockPositions[i-1]) && vars.IsAtPositionOld(current, vars.MemoryBlockPositions[i-1]) && settings[settingName])
        {
            vars.stopwatch.Restart();
            return true;
        }
    }
    // Splits when you gain a rank
    if (settings["HealthIncreaseSplits"] && current.MaxHealth == old.MaxHealth + 1)
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when Desmond is physically leaving the animus
    if (settings["ExitAnimus"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.ModernDayPos]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.ModernDayPos]))
    {
        vars.stopwatch.Restart();
        return true;
    }

    // Splits when you quit to the animus
    if (settings["QuitWarpExit"] && current.PlayerID == 9 && old.PlayerID == 1 && vars.IsTutorialDone)
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits when you enter the animus after quitting to the animus
    if (settings["QuitWarpEnter"] && current.PlayerID == 1 && old.PlayerID == 9 && vars.IsTutorialDone)
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for all targets when you are in the death confession room.
    if (settings["DeathConfessionSplits"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.DeathConfessionPos]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.DeathConfessionPos]))
    {
        vars.stopwatch.Restart();
        return true;
    }
    // Splits for Maria Death confession
    if (settings["DeathConfessionSplits"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.DeathConfessionPos - 1]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.DeathConfessionPos - 1]))
    {
        vars.stopwatch.Restart();
        return true;
    }
}

onReset
{
    vars.IsTutorialDone = false;
    vars.stopwatch.Reset();
}

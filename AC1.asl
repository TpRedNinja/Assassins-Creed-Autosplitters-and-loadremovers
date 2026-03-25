// Assassins Creed 1 Autosplitter
state("AssassinsCreed_Dx10")
{
    int Health: 0x025C1470, 0x14; // current health
    int MaxHealth: 0x025C1470, 0x18; // What the current max health you can heal to
    int MainMenu: 0x1491F60; // 0 = in game, -1 = main menu
    float XCoord: 0x025C1554, 0x0, 0x8C, 0x10, 0x1C, 0x70, 0x40; // Player X Coordinates
    float YCoord: 0x025C1554, 0x0, 0x8C, 0x10, 0x1C, 0x70, 0x44; // Player Y Coordinates
    float ZCoord: 0x025C1554, 0x0, 0x8C, 0x10, 0x1C, 0x70, 0x48; // Player Z Coordinates
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
        settings.Add("Tutorial", false, "Tutorial", "Splits");
        settings.SetToolTip("Tutorial", "splits when you have loaded into Solomon's temple after the tutorial\nThis is the start of Memory Block 1 so if you want to split their choose this one");
        settings.Add("SolomonTemple", false, "Solomon Temple Split", "Splits");
        settings.SetToolTip("SolomonTemple", "Splits when you load into Masyaf after Solomon's temple");
        settings.Add("MemoryBlock 2", false, "Memory Block 2", "Splits");
        settings.SetToolTip("MemoryBlock 2", "Splits at the start of memory block 2");
        settings.Add("MemoryBlock 3", false, "Memory Block 3", "Splits");
        settings.SetToolTip("MemoryBlock 3", "Splits at the start of memory block 3");
        settings.Add("MemoryBlock 4", false, "Memory Block 4", "Splits");
        settings.SetToolTip("MemoryBlock 4", "Splits at the start of memory block 4");
        settings.Add("MemoryBlock 5", false, "Memory Block 5", "Splits");
        settings.SetToolTip("MemoryBlock 5", "Splits at the start of memory block 5");
        settings.Add("MemoryBlock 6", false, "Memory Block 6", "Splits");
        settings.SetToolTip("MemoryBlock 6", "Splits at the start of memory block 6");
        settings.Add("MemoryBlock 7", false, "Memory Block 7", "Splits");
        settings.SetToolTip("MemoryBlock 7", "Splits at the start of memory block 7");
        settings.Add("ModernDaySplits", false, "Modern Day Splits", "Splits");
        settings.SetToolTip("ModernDaySplits", "Splits when Desmond is physically leaving the animus");
        settings.Add("HealthIncreaseSplits", false, "HealthIncreaseSplits", "Splits");
        settings.SetToolTip("HealthIncreaseSplits", "Splits when you gain a health increase/rank up.");
    settings.Add("Memory Block Runs", false, "Memory Block Start Timer");
        for (int i = 1; i <= 7; i++)
        {
            settings.Add("MemoryBlock" + i, false, "Memory Block " + i, "Memory Block Runs");
            settings.SetToolTip("MemoryBlock" + i, "Starts the timer for the start of memory block " + i);
        }
    //settings.Add("Debug", false, "For dev only do not turn on");
    //settings.SetToolTip("Debug", "Do not turn this on otherwise livesplit will add stuff to your layout so just keep it turned off");
    vars.X = 0.0f;
    vars.Y = 0.0f;
    vars.Z = 0.0f;
    vars.MemoryBlock = 0;
    // array of positions to check if the player is at, can add more if needed just make sure to update the indices in the code
    float [][] splitPositions =
    {
        new float [] {-39.1783f, -33.99732f, 34.46896f}, //leaving Solomon's temple
        new float [] {-2.63071f, -4.52977f, 0.00262f} // in the animus but modern day
    };
    vars.SplitPositions = splitPositions;
    // arrays of start positions
    float [][] MemoryBlockPositions =
    {
        new float [] {-66.18973f, -58.75932f, -8.38886f}, // start of memory block 1
        new float [] {208.24425f, 11.22722f, 107.64150f}, // start of memory block 2
        new float [] {207.43881f, 12.49873f, 107.60572f}, // start of memory block 3
        new float [] {}, // start of memory block 4
        new float [] {}, // start of memory block 5
        new float [] {}, // start of memory block 6
        new float [] {} // start of memory block 7
        
    };
    vars.MemoryBlockPositions = MemoryBlockPositions;
    vars.ModernDayPos = (vars.SplitPositions.Length - 1);
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
    vars.TestingPos = 1;     
}

update
{
    current.XCoord = (float)Math.Round(current.XCoord, 5);
    current.YCoord = (float)Math.Round(current.YCoord, 5);
    current.ZCoord = (float)Math.Round(current.ZCoord, 5);
    /*vars.X = (float)Math.Round(current.XCoord, 5);
    vars.Y = (float)Math.Round(current.YCoord, 5);
    vars.Z = (float)Math.Round(current.ZCoord, 5);

    if (settings["Debug"])
    {
        vars.SetTextComponent("XYZ", "( " + current.XCoord + ", " + current.YCoord + ", " + current.ZCoord + " )");
        vars.SetTextComponent("IsAtPositionCurrent: ", vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.TestingPos]) + "");
        vars.SetTextComponent("IsAtPositionOld: ", vars.IsAtPositionOld(old, vars.SplitPositions[vars.TestingPos]) + "");
        vars.SetTextComponent("Current Health", current.Health + "");
        vars.SetTextComponent("Max Health", current.MaxHealth + "");
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
    } */

    for (int i = 1; i < 7; i++)
    {
        string settingName = "MemoryBlock" + i;
        if (settings[settingName])
        {
            vars.MemoryBlock = i;
        }
    }
}

start
{
    if (settings["Memory Block Runs"])
    {
        
        if (vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[vars.MemoryBlock-1]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[vars.MemoryBlock-1]))
        {
            print("Starting for Memory Block: " + vars.MemoryBlock);
            return true;
        }   
    } else if (current.MainMenu == 0 && old.MainMenu == -1) // start after leaving the main menu
    {
        return true;
    }
}

split
{
    // splits when you have loaded into Solomon's temple after the tutorial
    if (settings["Tutorial"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[0]) && vars.IsAtPositionOld(old, vars.SplitPositions[0]))
    {
        return true;
    }
    // Splits when you load into Masyaf after Solomon's temple
    if (settings["SolomonTemple"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[0]) && vars.IsAtPositionOld(old, vars.SplitPositions[0]))
    {
        return true;
    }
    // Splits at the start of memory blocks 2-7, if you want to split at the start of memory block 1 then use the tutorial split
    for (int i = 2; i <= 7; i++)
    {
        string settingName = "MemoryBlock " + i;
        if (vars.IsAtPositionCurrent(current, vars.MemoryBlockPositions[i-1]) && vars.IsAtPositionOld(old, vars.MemoryBlockPositions[i-1]) && settings[settingName])
        {
            return true;
        }
    }

    // Splits when you gain a rank
    if (settings["HealthIncreaseSplits"] && current.MaxHealth == old.MaxHealth + 1)
    {
        return true;
    }
    // Splits when Desmond is physically leaving the animus
    if (settings["ModernDaySplits"] && vars.IsAtPositionCurrent(current, vars.SplitPositions[vars.ModernDayPos]) && vars.IsAtPositionOld(old, vars.SplitPositions[vars.ModernDayPos]))
    {
        return true;
    }
    
    
}

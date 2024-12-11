state("AC4BFSP")
{
    //stuff for loading & starting stuff
    int MainMenu: 0x49D2204; //65540 Main Menu anything else is in save file
    int Cutscene: 0x49DAB04; //Gonna find something different
    int loading: 0x04A1A6CC, 0x7D8; //0 when not loading 1 when u are loading
    
    //stuff that affects edward
    int Money: 0x049E3788, 0xA0, 0x90; //Shows your current money when in the animus
    int Health: 0x049E3788, 0x34, 0x84; //shows you current health works with upgrades. Note not nessacearly needed for splitting only if its wanted.
    float oxygen: 0x25E080C; //current oxygen 1 for full and anything lower means the bar is going down. Except for exiting a shipwreck. 
    
    //for knowing how far your are and for splitting
    int Percentage: 0x049D9774, 0x284; //Shows the total current percentage
    float PercentageF: 0x049F1EE8, 0x74; //Shows the total current percentage but in a float
    
    //counters for collectibles
    int Viewpoints: 0x0002E8D0, 0x1A8, 0x28, 0x18; //Tracks total number of viewpoints completed
    int MyanStele: 0x0002E8D0, 0x1A8, 0x3C, 0x18; //Tracks total number of MyanStele completed
    int BuriedTreasure: 0x0002E8D0, 0x1A8, 0xFA0, 0x18; //Tracks total number of BuriedTreasure collected
    int animusfragments: 0x0002E8D0, 0x1A8, 0x0, 0x18; //Tracks total number of animus fragments collected
    int WaterChests: 0x0002E8D0, 0x1A8, 0x64, 0x18; //Tracks total number of chests underwater collected
    int UnchartedChests: 0x0002E8D0, 0x450, 0xE38, 0x18; //Tracks total number of uncharted chests collected
    int UnchartedFragments: 0x0002E8D0, 0x400, 0x528, 0x18; //Tracks total number of uncharted animusfragments collected
    int UnchartedSecrets: 0x0002E8D0, 0x400, 0x370, 0x18; //Tracks total number of uncharted secrets collected 
    int AssassinContracts: 0x0002E8D0, 0x1A8, 0xD84, 0x18; //Tracks the total number of Assassin Contracts completed
    int NavalContracts: 0x01118F54, 0x488; //Tracks the total number of Naval Contracts completed
    int Letters: 0x0002E8D0, 0x450, 0x0, 0x18; //Tracks total number of letters in a bottle collected
    int Manuscripts: 0x0002E8D0, 0x7C0, 0x0, 0x18; //Tracks total number of Manuscripts collected
    int MusicSheets: 0x0002E8D0, 0xB08, 0x424, 0x18; //Tracks total number of MusicSheets collected
    int Forts: 0x002FE2CC, 0xED0;
}

startup
{
    // set text taken from Poppy Platime C2
    // to display the text associated with this script aka current percentage
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

    settings.Add("Splits", true, "Splitting Options");
    settings.Add("Modern day", false, "Modern day", "Splits");
    settings.Add("Health", false, "Health upgrades", "Splits");
    settings.Add("Viewpoints", false, "Viewpoints", "Splits");
    settings.Add("MyanStele", false, "MyanStele", "Splits");
    settings.Add("BuriedTreasure", false, "BuriedTreasure", "Splits");
    settings.Add("Shipwrecks", false, "Shipwrecks", "Splits");
    settings.Add("Contracts", false, "Contracts", "Splits");
    settings.Add("Forts", false, "Forts", "Splits");
    settings.Add("Legendary Ships", false, "Legendary Ships", "Splits");

    settings.SetToolTip("Splits", "Gives options of where to split");
    settings.SetToolTip("Modern day", "Splits when leaving the animus and entering the animus for the modern day missions");
    settings.SetToolTip("Health", "Splits when crafting health upgrades");
    settings.SetToolTip("Viewpoints", "Splits after syncing a viewpoint");
    settings.SetToolTip("MyanStele", "Splits wafter lotting the myan stele stone ");
    settings.SetToolTip("BuriedTreasure", "Splits after edwards opens the treasure chest");
    settings.SetToolTip("Shipwrecks", "Splits when getting a x amount of chests from the shipwrecks");
    settings.SetToolTip("Contracts", "Splits when gainning money from completeling a contract");
    settings.SetToolTip("Forts", "Splits when gainning money from unlocking a fort");
    settings.SetToolTip("Legendary Ships", "Splits when looting the 10000 gold from the legendary ships");

    //Percentage display
    settings.Add("Percentage Display", false, "Percentage Display");
    settings.Add("Calculator", false, "Calculator" ,"Percentage Display");
    settings.Add("Uncharted Display", false);
    settings.Add("Debug", false);
    settings.SetToolTip("Debug", "This will display the current value of all counters\n"+ 
    "use this only to check to see if something is broken.\n" +
    "Remove most stuff from your layout as this will add a lot of components");
    /*for any future settings i want to add
    settings.Add("", false, "", "Splits");
    settings.SetToolTip("", "Splits when ");
    */
}

init
{
    vars.ViewpointsDone = false;
    vars.MayanDone = false;
    vars.TreasureDone = false;
    vars.FragmentsDone = false;
    vars.MusicSheetsDone = false;
    vars.ManuscriptsDone = false;
    vars.Letters = false;
    vars.SecretsDone = false;
    vars.CountersDone = false;
    vars.completedsplits = new List<string>();
    
    if (current.MainMenu == 65540 && current.loading == 0)
    {
        timer.IsGameTimePaused = false;
    }
    
}

update
{
    current.PercentageF = Math.Round(current.PercentageF, 5);
    if (current.oxygen == old.oxygen)
    {
        current.oxygen = Math.Round(current.oxygen, 1);
    } else
    {
        current.oxygen = Math.Round(current.oxygen, 8);
    }

    if (settings["Percentage Display"])
    {
        if (current.PercentageF != null){
            vars.SetTextComponent("Percentage Completion", current.PercentageF + "%");
            if (settings["Calculator"])
            {
                if (current.PercentageF > old.PercentageF)
                {
                    vars.SetTextComponent("Percentage increased by ", current.PercentageF - old.PercentageF + "%");
                }
            }
        } else
        {
            vars.SetTextComponent("Percentage Completion", "N/A");
        }
    }

    if (settings["Uncharted Display"])
    {
        if (current.UnchartedChests != null && current.UnchartedFragments != null && current.UnchartedSecrets != null){
        vars.SetTextComponent("UnchartedChests Collected", current.UnchartedChests + "/46");
        vars.SetTextComponent("UnchartedFragments Collected", current.UnchartedFragments + "/30");
        vars.SetTextComponent("UnchartedSecrets Collected", current.UnchartedSecrets + "/3");   
        } else
        {
            vars.SetTextComponent("UnchartedChests Collected", "N/A");
            vars.SetTextComponent("UnchartedFragments Collected", "N/A");
            vars.SetTextComponent("UnchartedSecrtes Collected", "N/A");
        }
    }

    if (settings["Debug"])
    {
        //vars.SetTextComponent("", current. + "/"); for extras in the future
        if (current.MainMenu != null && current.loading != null && current.Viewpoints != null && current.MyanStele != null && current.BuriedTreasure != null 
        && current.animusfragments != null && current.WaterChests != null && current.AssassinContracts != null && current.NavalContracts != null 
        && current.letters != null && current.Manuscripts != null && current.Shanties != null && current.Forts != null)
        {
            vars.SetTextComponent("Current MainMenu Value", current.MainMenu);
            vars.SetTextComponent("Current Loading", current.loading + "/1");
            vars.SetTextComponent("Viewpoints Synchornized", current.Viewpoints + "/58");
            vars.SetTextComponent("MyanStele Collected", current.MyanStele + "/16");
            vars.SetTextComponent("BuriedTreasure Found", current.BuriedTreasure + "/22");
            vars.SetTextComponent("Fragments Collected", current.animusfragments + "/200");
            vars.SetTextComponent("Water Chests looted", current.WaterChests + "/50");
            vars.SetTextComponent("Assassins Contracts Completed", current.AssassinContracts + "/30");
            vars.SetTextComponent("Naval Contracts Completed", current.NavalContracts + "/15");
            vars.SetTextComponent("Letters Collected", current.Letters + "/20");
            vars.SetTextComponent("Manuscripts Collected", current.Manuscripts + "/20");
            vars.SetTextComponent("Shanties Collected", current.MusicSheets + "/24");
            vars.SetTextComponent("Forts captures", current.Forts + "/10");
        } else
        {
            vars.SetTextComponent("Current MainMenu Value", "N/A");
            vars.SetTextComponent("Current Loading", "N/A");
            vars.SetTextComponent("Viewpoints Synchornized", "N/A");
            vars.SetTextComponent("MyanStele Collected", "N/A");
            vars.SetTextComponent("BuriedTreasure Found", "N/A");
            vars.SetTextComponent("Fragments Collected", "N/A");
            vars.SetTextComponent("Water Chests looted", "N/A");
            vars.SetTextComponent("Assassins Contracts Completed", "N/A");
            vars.SetTextComponent("Naval Contracts Completed", "N/A");
            vars.SetTextComponent("Letters Collected", "N/A");
            vars.SetTextComponent("Manuscripts Collected", "N/A");
            vars.SetTextComponent("Shanties Collected", "N/A");
            vars.SetTextComponent("Forts captures", "N/A");
        }

    }

    if (current.Viewpoints == 58 && old.Viewpoints == 57)
    {
        vars.ViewpointsDone = true;
    }

    if (current.MyanStele == 16 && old.MyanStele == 15)
    {
        vars.MayanDone = true;
    }

    if (current.BuriedTreasure == 22 && old.BuriedTreasure == 21)
    {
        vars.TreasureDone = true;
    }

    if (current.animusfragments == 200 && old.animusfragments == 199)
    {
        vars.FragmentsDone = true;
    }

    if (current.MusicSheets == 24 && old.MusicSheets == 23)
    {
        vars.MusicSheetsDone = true;
    }

    if (vars.ManuscriptsDone == true && vars.Letters == true)
    {
        vars.SecretsDone = true;
    } else if (current.Manuscripts == 20 && old.Manuscripts == 19)
    {
        vars.ManuscriptsDone = true;
    } else if (current.Letters == 20 && old.Letters == 19)
    {
        vars.Letters = true;
    }

    if (vars.ViewpointsDone == true && vars.MayanDone == true && vars.TreasureDone == true && vars.FragmentsDone == true 
    && vars.MusicSheetsDone == true && vars.SecretsDone == true)
    {
        vars.CountersDone = true;
    }


    /*print(modules.First().ModuleMemorySize.ToString());
    if (current.PercentageF != old.PercentageF)
    {
        print("current cutscene:" + current.PercentageF);
        print("current cutscene:" + current.Percentage);
    }
    */
    
    //print("current cutscene:" + vars.MainMenu);
    //print("current cutscene:" + current.Cutscene);
}

start
{
    //should start after accepting the save file
    if (current.MainMenu == 131076 && old.MainMenu == 65540)
    {
        return true;
    }
}

split
{
    //should work for most splits
    if (current.Percentage > old.Percentage && current.loading == 0 && current.MainMenu == 1311076)
    {
        return true;
    } else if (current.PercentageF >= old.PercentageF + 0.66667 && current.PercentageF <= old.PercentageF + 1.66667 && current.loading == 0 && current.MainMenu == 1311076)
    {
        return true;
    } else
    {
        return false;
    }

    if(settings["Modern day"])
    {
        //splits when entering the animus
        if (current.Money != null && current.Health != null && current.MainMenu == 1311076)
        {
            return true;
        }
    }

    if(settings["Viewpoints"])
    {
        //splits when syncing a viewpoint
        if (current.Viewpoints == old.Viewpoints + 1 || current.PercentageF == old.PercentageF + 0.03750 || 
        current.PercentageF == old.PercentageF + 0.03333 || current.PercentageF == old.PercentageF + 0.11250 || 
        current.PercentageF == old.PercentageF + 0.03214 || current.PercentageF == old.PercentageF + 0.05625)
        {
            return true;
        }
    }

    if(settings["MyanStele"])
    {
        //splits when getting one myan stone
        if (current.MyanStele == old.MyanStele + 1 || current.PercentageF == old.PercentageF + 0.18578 || 
        current.PercentageF == old.PercentageF + 0.09289 || current.PercentageF == old.PercentageF + 0.20642)
        {
            return true;
        }
    }

    if(settings["BuriedTreasure"])
    {
        //splits when openning a buried treasure
        if (current.BuriedTreasure == old.BuriedTreasure + 1 || || current.PercentageF == old.PercentageF + 0.20455)
        {
            return true;
        }
    }

    if (settings["Shipwrecks"])
    {
        //splitting for shipwrecks
        if (current.WaterChests == 6 && !vars.completedsplits.Contains("san ignacio"))
        {
            vars.completedsplits.Add("san ignacio");
            return true;
        }

        if (current.WaterChests == 13 && !vars.completedsplits.Contains("blue hole"))
        {
            vars.completedsplits.Add("blue hole");
            return true;
        }

        if (current.WaterChests == 20 && !vars.completedsplits.Contains("antocha wreck"))
        {
            vars.completedsplits.Add("antocha wreck");
            return true;
        }

        if (current.WaterChests == 28 && !vars.completedsplits.Contains("Devils eye caverns"))
        {
            vars.completedsplits.Add("Devils eye caverns");
            return true;
        }

        if (current.WaterChests == 35 && !vars.completedsplits.Contains("La concepcion"))
        {
            vars.completedsplits.Add("La concepcion");
            return true;
        }

        if (current.WaterChests == 42 && !vars.completedsplits.Contains("Black trench"))
        {
            vars.completedsplits.Add("Black trench");
            return true;
        }

        if (current.WaterChests == 50 && !vars.completedsplits.Contains("Kabah ruins"))
        {
            vars.completedsplits.Add("Kabah ruins");
            return true;
        }
    }

    if (settings["Contracts"])
    {
        //splits for assassination contracts, alt need to fix naval contracts 
        if (current.AssassinContracts == old.AssassinContracts + 1 || current.NavalContracts == old.NavalContracts + 1 || 
        current.PercentageF == old.PercentageF + 0.61728 || current.PercentageF == old.PercentageF + 0.02058)
        {
            return true;
        }

    }

    if (settings["Forts"])
    {
        //splits when capturing a fort
        if (current.PercentageF == old.PercentageF + 0.22500 || current.Forts == old.Forts + 1)
        {
            return true;
        }
    }

    if (settings["Legendary Ships"])
    {

        //splits when defeating one of the legendary ships
        if ((current.Money == old.Money + 20000 || current.Money == old.Money + 10000) || current.PercentageF == old.PercentageF + 0.18750)
        {
            return true;
        }
    }

}

onReset
{
    vars.completedsplits.Clear();
}

isLoading
{
    if (current.loading == 1 && old.loading == 0)
    {
        return true;
    } else if (current.MainMenu == 1 && (old.MainMenu == 0 || old.MainMenu == null))
    {
        return true;
    } else
    {
        return false;
    }
    
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}

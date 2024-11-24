
state("AC4BFSP")
{
    //stuff for loading & starting stuff
    int MainMenu: 0x23485D0; // 1 when in mainmenu and first cutscene and 0 when not in main menu.
    int Cutscene: 0x49DAB04; //33 when in main menu, 80 during cutscenes with edward thats not a flash back, 81 when able to play as edward, 94 when in a flash back with edward
    int loading: 0x04A1A6CC, 0x7DB8; //0 when not loading 1 when u are loading
    
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
    int BuriedTreasure: 0x01817920, 0x3AC, 0xBF8; //Tracks total number of BuriedTreasure completed
    int animusfragments: 0x0002E8D0, 0x1A8, 0x0, 0x18; //Tracks total number of animus fragments
    int Chests: 0x0002E8D0, 0x1A8, 0x64, 0x18; //Tracks total number of chests underwater. Note this does include chests at smuggler dens that have you go underwater at first
    int AssassinContracts: 0x018FF260, 0x38C, 0x778; //Tracks the total number of Assassin Contracts completed
    int NavalContracts: 0x0154DAA8, 0x28C, 0xFB8; //Tracks the total number of Naval Contracts completed
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
    //settings.Add("Forts", false, "Forts", "Splits");
    settings.Add("Legendary Ships", false, "Legendary Ships", "Splits");

    settings.SetToolTip("Splits", "Gives options of where to split");
    settings.SetToolTip("Modern day", "Splits when leaving the animus and entering the animus for the modern day missions");
    settings.SetToolTip("Health", "Splits when crafting health upgrades");
    settings.SetToolTip("Viewpoints", "Splits after syncing a viewpoint");
    settings.SetToolTip("MyanStele", "Splits wafter lotting the myan stele stone ");
    settings.SetToolTip("BuriedTreasure", "Splits after edwards opens the treasure chest");
    settings.SetToolTip("Shipwrecks", "Splits when getting a x amount of chests from the shipwrecks");
    settings.SetToolTip("Contracts", "Splits when gainning money from completeling a contract");
    //settings.SetToolTip("Forts", "Splits when gainning money from unlocking a fort");
    settings.SetToolTip("Legendary Ships", "Splits when looting the 10000 gold from the legendary ships");

    //Percentage display
    settings.Add("Percentage display", false);
    /*for any future settings i want to add
    settings.Add("", false, "", "Splits");
    settings.SetToolTip("", "Splits when ");
    */
}

init
{
    vars.MainMenu = true;
    vars.Modernday = false;
    vars.ViewpointsDone = false;
    vars.MayanDone = false;
    vars.TreasureDone = false;
    vars.FragmentsDone = false;
    vars.CountersDone = false;
    vars.completedsplits = new List<string>();
}

update
{
    //) && current.MainMenu == true
    //(current.Cutscene >= 10 || current.Cutscene < 40 )
    if (current.Cutscene >= 10 || current.Cutscene < 40 && current.MainMenu == 1)
    {
        vars.MainMenu = true;
    } else
    {
        vars.MainMenu = false;
    }

    if (current.Cutscene < 50 && current.Cutscene > 39 && current.MainMenu == 0)
    {
        vars.Modernday = true;
    }else
    {
        vars.Modernday = false;
    }

    current.PercentageF = Math.Round(current.PercentageF, 5);
    if (current.oxygen == old.oxygen)
    {
        current.oxygen = Math.Round(current.oxygen, 1);
    }

    if (settings["Percentage display"])
    {
        vars.SetTextComponent("Percentage Completion", "N/A");
        if (current.PercentageF != null){
        vars.SetTextComponent("Percentage Completion", current.PercentageF + "%");
            if (current.PercentageF > old.PercentageF)
            {
                vars.SetTextComponent("Percentage increased by ", current.PercentageF - old.PercentageF + "%");
            }
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

    if (vars.ViewpointsDone == true && vars.MayanDone == true && vars.TreasureDone == true && vars.FragmentsDone == true)
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
    if ((current.Cutscene != 10 || current.Cutscene != 33) && current.MainMenu == 0 && current.Percentage == 0)
    {
        return true;
    }
}

split
{
    //should work for most splits
    if (current.Percentage > old.Percentage && current.Percentage <= 98 && current.loading == 0)
    {
        return true;
    } else if (current.Percentage == 100 && old.Percentage != 100  && current.Percentage <= 100 && current.loading == 0)
    {
        return true;
    }

    if(settings["Modern day"])
    {
        //splits when leaving the animus
        if (vars.Modernday == true && old.Modernday == false)
        {
            return true;
        }

        //splits when entering the animus
        if (vars.Modernday == false && old.Modernday == true )
        {
            return true;
        }
    }

    if(settings["Viewpoints"])
    {
        //splits when syncing a viewpoint
        if (current.Viewpoints == old.Viewpoints + 1)
        {
            return true;
        }
    }

    if(settings["MyanStele"])
    {
        //splits when getting one myan stone
        if (current.MyanStele == old.MyanStele + 1)
        {
            return true;
        }
    }

    if(settings["BuriedTreasure"])
    {
        //splits when openning a buried treasure
        if (current.BuriedTreasure == old.BuriedTreasure + 1 && (current.Money == old.Money + 1500 || current.Money == old.Money + 3000 || 
        current.Money == old.Money + 4000))
        {
            return false;
        }
    }

    if (settings["Shipwrecks"])
    {
        //splitting for shipwrecks
        if (current.Chests == 6 && !vars.completedsplits.Contains("san ignacio"))
        {
            vars.completedsplits.Add("san ignacio");
            return true;
        }

        if (current.Chests == 13 && !vars.completedsplits.Contains("blue hole"))
        {
            vars.completedsplits.Add("blue hole");
            return true;
        }

        if (current.Chests == 20 && !vars.completedsplits.Contains("antocha wreck"))
        {
            vars.completedsplits.Add("antocha wreck");
            return true;
        }

        if (current.Chests == 28 && !vars.completedsplits.Contains("Devils eye caverns"))
        {
            vars.completedsplits.Add("Devils eye caverns");
            return true;
        }

        if (current.Chests == 35 && !vars.completedsplits.Contains("La concepcion"))
        {
            vars.completedsplits.Add("La concepcion");
            return true;
        }

        if (current.Chests == 42 && !vars.completedsplits.Contains("Black trench"))
        {
            vars.completedsplits.Add("Black trench");
            return true;
        }

        if (current.Chests == 50 && !vars.completedsplits.Contains("Kabah ruins"))
        {
            vars.completedsplits.Add("Kabah ruins");
            return true;
        }
    }

    if (settings["Contract"])
    {
        //splits for assassination contracts
        if (current.AssassinContracts == old.AssassinContracts + 1 && (current.Money == old.Money + 1000 || current.Money == old.Money + 1500) && 
        current.PercentageF == old.PercentageF + 0.61728)
        {
            return true;
        }

        if (current.NavalContracts == old.NavalContracts + 1 && (current.Money == old.Money + 1200 || current.Money == old.Money + 1800 || current.Money == old.Money + 2400) && 
        current.PercentageF == old.PercentageF + 0.02058)
        {
            return true;
        }

    }

    if (settings["Legendary Ships"])
    {
        //splits when defeating one of the legendary ships
        if (current.Money == old.Money + 10000 && current.PercentageF == old.PercentageF + 0.1875)
        {
            return true;
        }

        //splits when defeating one of the legendary ships
        if (current.Money == old.Money + 20000 && current.PercentageF > old.PercentageF)
        {
            return true;
        }
    }

}

onReset
{
    vars.completedsplits.Clear();
}

/*
total chests:340?
total underwater chest: 50
total chest collected in save 2: 71
total chest major locations: 116
total chest secondary locations: 152
total chest side activities:72

/*stuff that splits on gainning money
1- percentages wont be enough so money
2- for doesnt matter percentages will be fine
4- can use percentages and money for the split conditions
5- wont use
300-"Proper Defenses", 2
350-Templar hunts, 2
500-Templar hunts, "Mister Walpole, I Presume", 2
700-Templar hunts, 2
1000-Assassin contracts(4),Forts(4),chests shipwreck(5), "Unmanned"(2)
1200-Naval contracts(4)
1500-Assassin contracts(4),Buried treasure(4),Templar hunt(2)
1800-Naval contracts (4)
2400-Naval contracts (4)
3000-Forts,Buried treasure(3)
4000-Buried treasure(4)
5000-Forts(4)
10000-Legendary ships,buried treasure(3) (4)
20000-Legendary ships(4)

if (settings["Forts"])
{
    //splits when capturing a fort
    if (current.Money == old.Money + 1000)
    {
        return true;
    }

    //splits when capturing a fort
    if (current.Money == old.Money + 3000)
    {
        return true;
    }
}
*/

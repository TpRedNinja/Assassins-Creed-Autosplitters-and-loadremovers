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
    vars.Helper.Settings.CreateFromXml("Components/AC4.Settings.xml");

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
}

init
{
    vars.PercentDiff = 0.0f;

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

    }
    //print(modules.First().ModuleMemorySize.ToString());
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
        if ((current.Percentage == old.Percentage + 1 || (current.PercentageF > old.PercentageF && current.Percentage == old.Percentage)) 
        && current.loading == 0 && vars.SplitTime > 2)
        {
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

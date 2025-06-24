state("ACC")
{
    int percentage: 0x032E09F8, 0x47C; // percentage of completion in int format
    float percentageFloat: 0x3308838, 0xC0; // percentage of completion in float/decimal format
    int IGT: 0x329DDC8, 0x20, 0x0, 0x10, 0x3E0; // the in game timer
    bool loading: 0x032973E0, 0xF70; // loading bool 1 for loading, 0 for not loading
    bool InModernDay: 0x32C8100; // InModernDay 0 for not in modern day 1 for in modern day
    bool InMenu: 0x32CB190; // Menu bool 1 for in menu, 0 for not in menu
}

startup
{
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

    settings.Add("Splits", false, "Splitting options");
    settings.Add("Any%", false, "Any%", "Splits");
    settings.SetToolTip("Any%", "Split when completing any mission that gives a percentage increase.");
    settings.Add("Modern Day", false, "Modern Day", "Splits");
    settings.SetToolTip("Modern Day", "Split when exiting the modern day.");
    settings.Add("100%", false, "100%", "Splits");
    settings.SetToolTip("100%", "Splits on everything");

    settings.Add("Timing", false, "Timing Options");
    settings.Add("IGT", false, "In-Game Timer", "Timing");
    settings.SetToolTip("IGT", "Use the in-game timer");
    settings.Add("Load Remover", false, "Load Remover", "Timing");
    settings.SetToolTip("Load Remover", "Use the Load Remover");
    settings.Add("IGT Display", false, "IGT Display", "Timing");
    settings.SetToolTip("IGT Display", "Display the In-Game Timer as a text component on live split.");

    
    vars.AddSecondWatch = new Stopwatch();
    vars.AddSecond = null;
    vars.TotalIGT = 0f;
    vars.TimeBeforeLoad = null;

    vars.TimeBeforeStarting = new Stopwatch();
    vars.Starting = 0;
}

update
{
    if (old.loading && !current.loading && !current.InMenu && !old.InMenu && timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.TimeBeforeStarting.Start();
    }

    if (settings["IGT Display"])
    {
        var igtTimeSpan = TimeSpan.FromSeconds(current.IGT);
        var igtString = igtTimeSpan.ToString(@"hh\:mm\:ss");
        vars.SetTextComponent("IGT: ", igtString);
    }

    vars.Starting = (int)vars.TimeBeforeStarting.Elapsed.TotalSeconds;

    vars.SetTextComponent("Starting: ", vars.Starting.ToString());
}

start
{
    if (vars.Starting >= 11 && !current.loading)
    {
        vars.TimeBeforeStarting.Reset();
        return true;
    }
}

split
{
    if (current.percentage > old.percentage && settings["Any%"])
    {
        return true;
    }

    if (!current.InModernDay && old.InModernDay && settings["Modern Day"])
    {
        return true;
    }

    if (current.percentageFloat > old.percentageFloat && settings["100%"] && !current.loading)
    {
        return true;
    }
}

isLoading
{
    if (settings["Load Remover"])
    {
        if (current.loading && current.IGT == old.IGT)
        {
            return true;
        }
    }
    return true;
}

gameTime
{
    if (settings["IGT"])
    {
        // 1. In menu, IGT not changing, not loading
        if (current.IGT == old.IGT && !current.loading && current.InMenu)
        {
            vars.AddSecondWatch.Start();
            vars.AddSecond = (int)vars.AddSecondWatch.Elapsed.TotalSeconds;
            if (vars.AddSecond >= 1)
            {
                vars.TotalIGT += 1;
                vars.AddSecondWatch.Restart();
            }
        }
        // 2. loading
        else if (current.loading)
        {
            vars.TotalIGT += 0;
        }
        else if (current.IGT - old.IGT < 0)
        {
            vars.TotalIGT += Math.Abs(current.IGT - old.IGT);
        }
        // 4. normal case: IGT is increasing
        else
        {
            vars.TotalIGT += current.IGT - old.IGT;
        }
        return TimeSpan.FromMilliseconds(vars.TotalIGT * 1000);
    }
}

onReset
{
    vars.AddSecondWatch.Reset();
    vars.AddSecond = null;
    vars.TotalIGT = 0;
    vars.TimeBeforeLoad = null;
}

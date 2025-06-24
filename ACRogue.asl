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
    settings.Add("Any%", false, "Any%", "Splitting options");
    settings.SetToolTip("Any%", "Split when completing any mission that gives a percentage increase.");
    settings.Add("Modern Day", false, "Modern Day", "Splitting options");
    settings.SetToolTip("Modern Day", "Split when exiting the modern day.");
    settings.Add("100%", true, "100%", "Splitting options");
    settings.SetToolTip("100%", "Splits on everything");

    settings.Add("Timing", false, "Timing Options");
    settings.Add("IGT", false, "In-Game Timer", "Timing Options");
    settings.SetToolTip("IGT", "Use the in-game timer");
    settings.Add("Load Remover", false, "Load Remover", "Timing Options");
    settings.SetToolTip("Load Remover", "Use the Load Remover");
    settings.Add("IGT Display", false, "IGT Display", "Timing Options");
    settings.SetToolTip("IGT Display", "Display the In-Game Timer as a text component on live split. \n Can only be displayed if In-Game Timer is disabled.");

    
    vars.AddSecondWatch = new Stopwatch();
    vars.AddSecond = null;
    vars.IGT = 0;
    vars.TimeBeforeLoad = null;
}

update
{
    if (settings["IGT Display"] && !settings["IGT"])
    {
        var igtTimeSpan = TimeSpan.FromSeconds(current.IGT);
        var igtString = igtTimeSpan.ToString(@"hh\:mm\:ss");
        vars.SetTextComponent("IGT: ", igtString);
    }
    

    if (current.loading && !old.loading && current.IGT == old.IGT)
    {
        vars.TimeBeforeLoad = current.IGT;
    }
}

split
{
    if (current.percentage > old.percentage && settings.["Any%"])
    {
        return true;
    }

    if (!current.InModernDay && old.InModernDay && settings.["Modern Day"])
    {
        return true;
    }

    if (current.percentageFloat > old.percentageFloat && settings.["100%"] && !current.loading)
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
}

gameTime
{
    if(settings["IGT"])
    {
        if (current.IGT == old.IGT && !current.loading && current.InMenu) //prevent timer from pause on menus
        {
            vars.AddSecondWatch.Start();
            vars.AddSecond = (int)vars.AddSecondWatch.Elapsed.TotalSeconds;
            if (vars.AddSecond > = 1)
            {
                vars.IGT ++;
                vars.AddSecondWatch.Restart();
            }
        } else if (current.IGT < vars.TimeBeforeLoad && vars.TimeBeforeLoad - current.IGT >= 1) // when reloading a checkpoint igt goes back to what the number was at the checkpoint
        {
            if(vars.AddSecondWatch.IsRunning)
            {
                vars.AddSecondWatch.Reset();
            }
            vars.IGT = vars.TimeBeforeLoad - current.IGT;
        } else if (vars.TimeBeforeLoad - current.IGT <= 0) // when reloading a checkpoint igt goes back to what the number was at the checkpoint but it is now greater than the current igt
        {
            if(vars.AddSecondWatch.IsRunning)
            {
                vars.AddSecondWatch.Reset();
            }
            
            vars.IGT = current.IGT - old.IGT;
        } else // normal timing
        {
            if(vars.AddSecondWatch.IsRunning)
            {
                vars.AddSecondWatch.Reset();
            }
            
            vars.IGT = current.IGT - old.IGT; // normal timing
        }

        return TimeSpan.FromSeconds(vars.IGT); // returns the game time in seconds
    
    }
    
}

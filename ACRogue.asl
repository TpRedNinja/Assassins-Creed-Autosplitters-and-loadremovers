state("ACC")
{
    int percentage: 0x032E09F8, 0x47C; // percentage of completion in int format
    float percentageFloat: 0x3308838, 0xC0; // percentage of completion in float/decimal format
    int IGT: 0x329DDC8, 0x20, 0x0, 0x10, 0x3E0; // the in game timer
    bool loading: 0x329A010; // loading bool 1 for loading, 0 for not loading
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

    settings.Add("IGT Display", false, "IGT Display");
    settings.SetToolTip("IGT Display", "Display the In-Game Timer as a text component on live split.");

    vars.StartingTime = 0;
    vars.TimerGreaterThanZero = false;
}

update
{
    if (settings["IGT Display"])
    {
        var igtTimeSpan = TimeSpan.FromSeconds(current.IGT);
        var igtString = igtTimeSpan.ToString(@"hh\:mm\:ss");
        vars.SetTextComponent("IGT: ", igtString);
    }

    if (timer.CurrentPhase == TimerPhase.NotRunning && current.loading && current.IGT > 0)
    {
        vars.TimerGreaterThanZero = true;
        vars.StartingTime = current.IGT;
    }
}

start
{
    if (current.IGT >= vars.StartingTime + 60 && vars.TimerGreaterThanZero)
    {
        print("starting");
        vars.TimerGreaterThanZero = false;
        return true;
    } else if(current.IGT == 60 && !current.InMenu && !current.loading && !vars.TimerGreaterThanZero)
    {
        print("starting2");
        vars.TimerGreaterThanZero = false;
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
    return current.loading;
}

state("ACCGame-Win32-Shipping")
{
    int EndScreen: 0x19680E8; // 0 = not in end screen, 1 = in end screen
    int IGT: 0x0184AF84, 0x28, 0x3C, 0xEAC, 0x1E0; // IGT in seconds
}

startup
{
    //made by ero
    // TextComponent stuff.
    var lcCache = new Dictionary<string, LiveSplit.UI.Components.ILayoutComponent>();
    vars.SetTextComponent = (Action<string, string, object>)((key, text1, text2) =>
    {
        LiveSplit.UI.Components.ILayoutComponent lc;
        if (!lcCache.TryGetValue(key, out lc))
        {
            lc = timer.Layout.LayoutComponents.Cast<dynamic>()
                .FirstOrDefault(llc => Path.GetFileName(llc.Path) == "LiveSplit.Text.dll" && llc.Component.Settings.Text1 == text1)
                ?? LiveSplit.UI.Components.ComponentManager.LoadLayoutComponent("LiveSplit.Text.dll", timer);

            lcCache.Add(key, lc);
        }

        if (!timer.Layout.LayoutComponents.Contains(lc))
            timer.Layout.LayoutComponents.Add(lc);

        dynamic tc = lc.Component;
        tc.Settings.Text1 = text1;
        tc.Settings.Text2 = text2.ToString();
    });

    vars.RemoveTextComponent = (Action<string>)(key =>
    {
        LiveSplit.UI.Components.ILayoutComponent lc;
        if (lcCache.TryGetValue(key, out lc))
        {
            timer.Layout.LayoutComponents.Remove(lc);
            lcCache.Remove(key);
        }
    });

    vars.RemoveAllTextComponents = (Action)(() =>
    {
        foreach (var lc in lcCache.Values)
            timer.Layout.LayoutComponents.Remove(lc);

        lcCache.Clear();
    });

    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Main");

    settings.Add("texts", false, "Text Displays");
    settings.SetToolTip("texts", "Shows stuff on livesplit");
        settings.Add("IGT", false, "In Game Time Display", "texts");
        settings.SetToolTip("IGT", "Shows the In Game Time in the top left corner of the screen.");
        settings.Add("texts-remove", false, "Remove all texts on exit", "texts");

    // Helper functions.
    vars.LogChange = (Action<string>)(key =>
    {
        if (vars.Helper[key].Changed)
        {
            vars.Log(key + ": " + vars.Helper[key].Old + " -> " + vars.Helper[key].Current);
        }
    });
}

init
{
    vars.totalIGT = 0;

    vars.ShowTextIfEnabled = (Action<string, string, object>)((key, text1, text2) =>
    {
        if (settings[key])
        {
            vars.SetTextComponent(key, text1, text2);
        }
        else if (settings["texts-remove"])
        {
            vars.RemoveTextComponent(key);
        }
    });
}

update
{
    vars.totalIGT += current.IGT - old.IGT;
    vars.ShowTextIfEnabled("IGT", "In Game Time", vars.totalIGT);
}

split
{
    if (current.EndScreen == 1 && old.EndScreen == 0)
    {
        return true;
    }
}

onReset
{
    vars.totalIGT = 0;
}

exit
{
    if (settings["texts-remove"])
    {
        vars.RemoveAllTextComponents();
    }
}

shutdown
{
    if (settings["texts-remove"])
    {
        vars.RemoveAllTextComponents();
    }
}

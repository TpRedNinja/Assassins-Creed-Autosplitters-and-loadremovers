state("ACBlackFlag")
{
    int loading: 0x0AF005B8, 0x2F0; // 0 for when not loading, 1 for when loading
}

startup
{
    vars.aslVersion = "1.0.2"; // version variable
    
    //set text by SetTextComponent("Left / Only Text", "Right Text", 0/1 for normal/centered);
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

    //Clears the text components where Text1 matches the id.
    vars.RemoveTextComponent = (Action<string>)(key =>
    {
        LiveSplit.UI.Components.ILayoutComponent lc;
        if (lcCache.TryGetValue(key, out lc))
        {
            timer.Layout.LayoutComponents.Remove(lc);
            lcCache.Remove(key);
        }
    });

    //Clears all text components added by this script.
    vars.RemoveAllTextComponents = (Action)(() =>
    {
        foreach (var lc in lcCache.Values)
            timer.Layout.LayoutComponents.Remove(lc);

        lcCache.Clear();
    });

    settings.Add("Debug", false, "Debug");
    vars.SetTextComponent("Version", "Autosplitter Version " + vars.aslVersion,  "");
}

update
{
    if(settings["Debug"]) {
        vars.SetTextComponent("Loading", "Loading:", current.loading + "/1");
    }
    else{
        vars.RemoveTextComponent("Loading");
    };
        

}

isLoading
{
    return current.loading == 1;
}

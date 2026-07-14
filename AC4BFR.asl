state("ACBlackFlag")
{
    int loading: 0x0AEBD878, 0x2F0; // 0 for when not loading, 1 for when loading
}

startup
{
    vars.version = "1.0.0";
    if (vars.version == "1.0.0")
    {
        var timingMessage = MessageBox.Show(
            "Load remover version 1.0.0 if this is not the right version then contact TpRedNinja on discord to ask if its the right version. \n\n" +
            "If you are using the wrong version then the load remover may not work properly and may cause issues with your run. \n\n" +
            "Note if this is your first time seeing this message then you are on the right version.",
            "Assassin's Creed Black Flag Resync | LiveSplit",
            MessageBoxButtons.OK, MessageBoxIcon.Information
        );
    }

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

    settings.Add("Debug", false, "Debug");
}

update
{
    if(settings["Debug"])
        vars.SetTextComponent("Loading: ", current.loading.ToString() + "/1");
}

isLoading
{
    return current.loading == 1;
}
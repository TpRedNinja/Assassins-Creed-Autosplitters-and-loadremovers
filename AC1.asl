// Assassins Creed 1 Autosplitter
state("AssassinsCreed_Dx10")
{
    int Health: 0x025C1470, 0x14; // current health
    int MaxHealth: 0x025C1470, 0x18; // What the current max health you can heal to
    int MainMenu: 0x1491F60; // 0 = in game, -1 = main menu
    float XCoord: 0x025C8884, 0x94, 0x14, 0x4, 0x48, 0x40; // Player X Coordinates
    float YCoord: 0x025C8884, 0x94, 0x14, 0x4, 0x48, 0x44; // Player Y Coordinates
    float ZCoord: 0x025C8884, 0x94, 0x14, 0x4, 0x48, 0x48; // Player Z Coordinates
    /* 
    need to find these
    bool Completed: 0x, 0x; // 0 for the a thing not being completed, 1 for it being completed hud ui thing showing
    int CompletedType: 0x, 0x; 
    17 for saving civilians, 18 for templars, 21 investigations, 23 for assassinations, 26 for viewpoints, 28 Jerusalem flags, 29 Damascus & Templar flags,
    30 Teutonic flags, 31 kingdom flags, 32 Masyaf flags, 34 Hospitalier flags
    */
}

startup
{
    settings.Add("Health Increase Splits", "HealthIncreaseSplits", false);
    settings.SetToolTip("Health Increase Splits", "Splits when you gain a health increase/rank up.\nAlso splits after you enter the Animus and health it set to 4 segments.");
    settings.Add("Tutorial", "Tutorial", false);
    settings.SetToolTip("Tutorial", "Splits after you gain your last health segment back in the tutorial.");
    vars.TutorialDone = false;
}

start
{
    // start after leaving the main menu
    if (current.MainMenu == 0 && old.MainMenu == -1)
    {
        return true;
    }
}

split
{
    // should split when you gain a rank
    if (current.MaxHealth == old.MaxHealth + 1 && settings["Health Increase Splits"])
    {
        return true;
    } else if (current.MaxHealth == 4 && old.MaxHealth != 4 && settings["Health Increase Splits"]) // splits after you go into the animus 
    {
        return true;
    }
    // splits after you gain your last health segment back.
    if (current.Health == 14 && old.Health != 14 && settings["Tutorial"] && !vars.TutorialDone)
    {
        vars.TutorialDone = true;
        return true;
    }
}
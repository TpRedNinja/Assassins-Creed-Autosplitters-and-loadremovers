state("ACCGame-Win32-Shipping")
{
    int EndScreen: 0x18BAA0C; // 0 = not in end screen, 1 = in end screen/pausemenu
    int MainMenu: 0x17E70C4; // 445 = main/pause menu, 486 end screen
}

split
{
    if (current.EndScreen == 1 && old.EndScreen == 0 && current.MainMenu == 486 && old.MainMenu != 486)
    {
        return true;
    }
}

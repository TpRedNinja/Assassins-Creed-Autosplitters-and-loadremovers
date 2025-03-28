state("ACCGame-Win32-Shipping")
{
    int EndScreen: 0x18CF10C; // 0 = not in end screen, 1 = in end screen
    int MainMenu: 0x17FB7B4; // 444 = main menu, 492 = end screen
}

split
{
    if (current.EndScreen == 1 && old.EndScreen == 0 && current.MainMenu == 492 && old.MainMenu != 492)
    {
        return true;
    }
}

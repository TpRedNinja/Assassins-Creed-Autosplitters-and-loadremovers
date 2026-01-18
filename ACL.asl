state("ac3lhd_32")
{
    int Percentage: 0x01D92190, 0xBA4, 0x4, 0x10, 0xC, 0x4, 0x8, 0x14C; // detects overall completion % value
    int Pausemenu: 0x01D4F138, 0x14; // 1 for when in a menu 0 for not
    int Money: 0x01D76508, 0x14, 0x28, 0x80, 0x48, 0x8C, 0xC, 0x50; // detects current amount of money you have, -1 when loading
}

split
{
    if (current.Percentage > old.Percentage)
    {
        return true;
    }
}

isLoading
{
    if (current.Money == -1)
    {
       return true; 
    }
}



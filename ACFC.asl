state("ACFC")
{
    int Percentage: 0x04A064E4, 0x194, 0x60, 0x4; // save file percentage
}

split
{
    if (current.Percentage > old.Percentage)
    {
        return true;
    }
}
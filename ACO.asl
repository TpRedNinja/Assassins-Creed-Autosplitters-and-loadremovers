state("ACOrgins_plus")
{
    int xp: 0x04CBB3D8, 0x168, 0x0, 0x11C;
}

state("ACOrgins")
{
    int xp: 0x04CBB3D8, 0x168, 0x0, 0x11C;
}

init
{
    vars.validIncrements = new HashSet<int>{500, 900, 1000, 1250, 1500, 2250, 2500, 3000, 3500, 6000, 7500, 9600};
}

update
{
    if (current.xp - 1000 >= 0)
    {
        vars.level ++;
    }
}

split
{
    //splits if the set contains the difference of current.xp - old.xp. This works sense xp has the total xp gained throughout a playthrough.
    if (vars.validIncrements.contains(current.xp - old.xp))
    {
        return true;
    }
    
    
    //alternate spliting ways
    /*if (current.xp >= old.xp + 500)
    {
        return true;
    }
    
    if (current.xp == old.xp + 500)
    {
        return true;
    }

    if (current.xp == old.xp + 900)
    {
        return true;
    }

    if (current.xp == old.xp + 1000)
    {
        return true;
    }

    if (current.xp == old.xp + 1250)
    {
        return true;
    }

    if (current.xp == old.xp + 1500)
    {
        return true;
    }

    if (current.xp == old.xp + 2250)
    {
        return true;
    }

    if (current.xp == old.xp + 2500)
    {
        return true;
    }

    if (current.xp == old.xp + 3000)
    {
        return true;
    }

    if (current.xp == old.xp + 3500)
    {
        return true;
    }

    if (current.xp == old.xp + 6000)
    {
        return true;
    }

    if (current.xp == old.xp + 7500)
    {
        return true;
    }

    if (current.xp == old.xp + 9600)
    {
        return true;
    }

    
    */
}
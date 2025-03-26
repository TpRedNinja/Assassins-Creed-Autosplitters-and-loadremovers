state("ACBSP")
{
    int Percentage: 0x025B08A4, 0x278, 0x4, 0xC, 0x7C; //Percentage
    int Money: 0x025C63AC, 0x24, 0x40; //Money
    bool Main_Loading: 0x25B0B60; // 1 = non gameplay, 0 = gameplay
}

init
{
    vars.AllMainMissions = new HashSet<int>{100, 150, 250, 400, 600, 700, 800, 1000, 1200, 1300, 1400, 1500, 2100, 2200, 2400, 2500, 3000, 5200, 6000, 6300, 6800}; //Money gained from main missions
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = 0;
}

update
{
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
}

start
{
    if (!current.Main_Loading && old.Main_Loading && current.Money == null)
    {
        return true;
    }
}

onStart
{
    if (vars.SplitTime > 0)
    {
        vars.stopwatch.Restart();
    } else
    {
        vars.stopwatch.Start();
    } 
}

split
{
    if (current.Percentage > old.Percentage && vars.AllMainMissions.Contains(Math.Abs(current.Money - old.Money)) && vars.SplitTime > 2) //splits when the percentage increases and money increases
    {
        vars.stopwatch.Restart();
        return true;
    } else if(vars.AllMainMissions.Contains(Math.Abs(current.Money - old.Money)) && vars.SplitTime > 2) // if first condition fails it checks if only the money has increased
    {
        vars.stopwatch.Restart();
        return true;
    } else if(current.Percentage > old.Percentage && vars.SplitTime > 2) // if the stuff before this fails it checks if only the percentage has increased
    {
        vars.stopwatch.Restart();
        return true;
    }

    if (!current.Main_Loading && currnet.Money == null && old.Main_Loading && vars.SplitTime > 2) //splits when leaving the animus
    {
        vars.stopwatch.Restart();
        return true;
    } else if(current.Main_Loading && currnet.Money != null && !old.Main_Loading && vars.SplitTime > 2) //splits when entering the animus
    {
        vars.stopwatch.Restart();
        return true;
    }
}

isLoading
{
    if (current.Menu_Loading && current.Money == 0)
    {
        return true;
    } else
    {
        return false;
    }
}

onReset
{
    vars.stopwatch.Stop();
}
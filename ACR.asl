state("ACRSP")
{
    int Percentage : 0x025DF1D0, 0x204, 0x4, 0xC, 0x158; //Percentage
    int Money: 0x0258DED0, 0x24, 0x40; //Money
    bool Loading : 0x02589EA0, 0xB8; // 1 = loading, 0 = not loading
}

init
{
    vars.AllMainMissions = new HashSet<int>{100, 150, 200, 250, 343, 500, 550, 600, 700, 750, 900, 950, 1000, 1150, 1200, 1350, 1500, 1550, 1600, 1800, 1950, 2000, 2350, 4500}; //Money gained from main missions
    vars.NegativeMoney = 343; //Money your lose
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = 0;
}

update
{
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
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
    if (current.Percentage > old.Percentage && (vars.AllMainMissions.Contains(current.Money - old.Money) 
    || vars.NegativeMoney == current.Money - old.Money) && vars.SplitTime > 2) //splits when the percentage increases and money increases
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
}

isLoading
{
    return current.Loading;
}

onReset
{
    vars.stopwatch.Stop();
}

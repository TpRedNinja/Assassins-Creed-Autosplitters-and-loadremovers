state("AssassinsCreedIIGame", "Legit")
{
    int percentage : 0x01E3DBE4, 0x2D0;
    int money : 0x1E134B4, 0x24, 0x34;
}

state("AssassinsCreedIIGame", "Pirate")
{
    int percentage : 0x01E14D1C, 0x2D0;
    int money : 0x1E3C588, 0x24, 0x34;
    float IGT : 0x1E4A2E4, 0x30;
}

startup
{
    vars.stopwatch = new Stopwatch();
    vars.SplitTime = null;
    vars.IsStopwatchStop = false;
    vars.version = "";
}

init
{
    // a list for the amount of money you could get from a pickpocketing
    vars.PickPocketMoney = new List<int>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
    41,42,43,44,45,46,47,48,49,50,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,
    141,142,143,144,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,
    191,192,193,194,195,196,197,198,199};
    print("Module Size: " + modules.First().ModuleMemorySize.ToString());
    switch (modules.First().ModuleMemorySize)
    {
        case (35053568):
            print("Game Version: Pirate");
            version = "Pirate";
            vars.version = version;
            break;
        case (35192832):
            print("Game Version: Legit");
            version = "Legit";
            vars.version = version;
            break;
    }
    vars.GameTime = 0;
    vars.waitTune = 5;
    if (vars.IsStopwatchStop == true)
    {
        vars.stopwatch.Start();
        vars.IsStopwatchStop = false; 
    }
}

update
{
    /*vars.GameTime += (int)(Math.Abs(old.IGT - current.IGT));
    string formattedGameTime = TimeSpan.FromSeconds(vars.GameTime).ToString(@"hh\:mm\:ss\.fff");*/
    //timer.Run.Metadata.SetCustomVariable("game time", current.IGT);
    vars.SplitTime = (int)vars.stopwatch.Elapsed.TotalSeconds;
    if (timer.CurrentPhase == TimerPhase.Paused)
    {
        vars.stopwatch.Stop();
    } else if (timer.CurrentPhase == TimerPhase.Running)
    {
        vars.stopwatch.Start();
    }
}

onStart
{
    vars.stopwatch.Start();
}

split
{
    // for normal splits
    if (current.percentage > old.percentage && vars.SplitTime >= vars.waitTune)
    {
        print("Split Time: " + vars.SplitTime.ToString() + "Split 1");
        vars.stopwatch.Restart();
        return true;
    }

    // for splits such as chests and side missions and mission that dont increase the percentage by 1 in general
    for (int i = 0; i < vars.PickPocketMoney.Count; i++)
    {
        if(current.money > old.money && current.percentage == old.percentage && !vars.PickPocketMoney.Contains(current.money-old.money) && vars.SplitTime >= vars.waitTune)
        {
            print("Split Time: " + vars.SplitTime.ToString() + "Split 2");
            vars.stopwatch.Restart();
            return true;
        }
    }
    
}

isLoading 
{
    return true;
}

gameTime
{
    if(vars.version == "Pirate")
    {
        /*vars.GameTime += (int)(Math.Abs(old.IGT - current.IGT));
        return TimeSpan.FromSeconds(vars.GameTime);*/
        return TimeSpan.FromSeconds(current.IGT);
    }
}

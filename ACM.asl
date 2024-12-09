//Load remover orginally by TheDementedSalad
//Update for latest Release by TpRedNinja

state("ACMirage","Current")
{
    int loading: 0x061028B8, 0x68;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
}

init
{
	string md5 = "";
    md5 = (string)vars.Helper.GetMD5Hash();

    switch (md5)
    {
        case "E1EC754BE4BBDA435AF11BB329FFBB3B":
            version = "Current";
            break;
        default:
            version = "N/A";
            break;
    }
}

isLoading
{
    return current.loading == 1;
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}

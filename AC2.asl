state("AssassinsCreedIIGame")
{
// byte chk : 0x01E14D1C, 0x2d0;
byte percentage : 0x01E3DBE4, 0x2D0;
}

split
{
    if (current.percentage > old.percentage){
        return true;
    }
}
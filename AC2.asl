﻿state("AssassinsCreedIIGame")
{
byte percentage : 0x01E3DBE4, 0x2D0;
}

split
{
    if (current.percentage > old.percentage)
    {
        return true;
    }
}

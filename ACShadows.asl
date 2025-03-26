state("ACShadows")
{
    int totalXP: 0x09959640, 0x490, 0x0, 0x28, 0x34; // total xp
    bool Loading: 0x0B48A048, 0x3A0, 0x4B8, 0xE98, 0x20; // bool loading whenever in a regular loading screen or when doing the flash back memorys loading screen
}

isLoading
{
    return current.Loading;
}

/*
Notes:

Quest xp gains:
2000

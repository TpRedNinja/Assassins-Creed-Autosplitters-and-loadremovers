//Assassins Creed Mirage Load remover by TpRedNinja
state("ACMirage")
{
    int loading: 0x061028B8, 0x68;
}

isLoading
{
    if (current.loading == 1 && old.loading == 0)
    {
        return true;
    }
}
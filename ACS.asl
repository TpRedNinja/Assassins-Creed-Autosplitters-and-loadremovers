//assassin's creed syndicate load remover an autosplitter by TpRedNinja w/ DeathHound,AkiloGames, people from the speedrun development tool discord
//Support for Ubisoft Connect
//Support for Steam

//[9188] 157683712
//SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version 
state("ACS", "Ubisoft Connect")
{
    int Loading: 0x073443F8, 0x120, 0x638, 0x118; //Detects if loading, 0 is not loading 1 is for loading
    int Endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; //Detects end mission sceen, 1 for end screen 0 for literally everything else
    int Cutscene: 0x715EBC0; //Detects cutscene value 0 in loading screen 1 no cutscene 2 for cutscene game and dlc is not a pointer just "ACS.exe" +(inserst address here)
    int MainMenu: 0x073446E8, 0x358, 0x458, 0xAD8, 0xA0, 0xE8, 0x8, 0x1A8; //Detects if ur on the main menu note its when you able to see your character. 1 for when ur are an 0 whenever u are not.
    int Character: 0x07155D78, 0xB20, 0xA0, 0x560, 0x140; //6 for evie 7 when not in london 8 for jack 9 when not in london.
    int Percentage: 0x07160A98, 0x40, 0x5C; //total completion of jack the ripper note does not work with main game
}

//[10848] 163323904
//SHA256: a2e6ca1504d172ca87f500d1d6cb1de97a2f6687f7ce77f661dce95e90c54e0e hash id for steam version 
state("ACS", "Steam")
{
    int Loading:0x070D7470, 0x4A0, 0x10, 0x368; //same as og but just in case if first one doesnt work
    int Endscreen: 0x07325DB0, 0x78, 0x3D0, 0x68; //1 for endscreen showing 0 for not
    int Cutscene: 0x7154FE0;  //same as ubi connect
    int MainMenu: 0x0733D320, 0x208, 0x50, 0x20, 0x6D8; //same as ubi connect
    int Character: 0x071546C8, 0x18, 0x0, 0x308, 0x158; //same as ubi connect
    int Percentage: 0x07159920, 0x40, 0x5C;//same as ubi connect
}

startup
{
    //to control when the timer starts for the main game
    settings.Add("base", true, "Main Game");
    settings.Add("new_game", false, "New Game", "base");
    settings.Add("loaded_save", false, "Loaded Game Save", "base");
    settings.Add("Any%", false, "Any%", "base");
    settings.Add("100%", false, "100%", "base");
    settings.Add("levels", false, "Level runs", "base");
    

    //Settings to differeniate between base game and the dlc along with if u want it to split
    settings.Add("ripper", true, "Jack the Ripper");
    //Settings for Any% and 100% for the dlc
    settings.Add("Any%_DLC", false, "Any%", "ripper");
    settings.Add("100%_DLC", false, "100%", "ripper");
    settings.Add("start", false, "Start Fresh", "ripper");
    settings.Add("15sec_start", false, "15 Second Start", "ripper");
    
    //Percentage display
    settings.Add("Percentage display", false);

    //Settings tooltips 
    //Settings tooltips for the base game
    settings.SetToolTip("base", "Click this if you are speedrunning the base game");
    settings.SetToolTip("new_game", "Enable this if you are starting a any% or 100% run from a new game with no save attached. This is for autostart");
    settings.SetToolTip("loaded_save", "Enable this if you are starting a any% or 100% run from a save where the first cutscene has fully played through. This is for autostart");
    settings.SetToolTip("Any%", "Enable this if you are doing a any% speedrun. This is for splitting");
    settings.SetToolTip("100%", "Enable this if you are doing a 100% speedrun. This is for splitting");
    settings.SetToolTip("levels", "Enable this if you are gonna speedrun individual levels. This is for autostart");
    
    //Settings tooltips for the DLC
    settings.SetToolTip("ripper", "Click this if you are speedrunning the dlc");
    settings.SetToolTip("Any%_DLC", "Enable this if you are doing a any% speedrun & using my any% splits");
    settings.SetToolTip("100%_DLC", "Enable this if you are doing a 100% speedrun");
    settings.SetToolTip("start", "Enable this if you are starting from a fresh save" );
    settings.SetToolTip("15sec_start", "Enable this if you are starting from a save where you have control of jack");

    // set text taken from Poppy Platime C2
    // to display the text associated with this script aka current Percentage along with IGT
    Action<string, string> SetTextComponent = (id, text) => {
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
            var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
            var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
            timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

            textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
            textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }

        if (textSetting != null)
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    };
    
    //Initalize variables
    vars.SetTextComponent = SetTextComponent;
    vars.completedsplits = new List<string>();
    vars.Any = new List<string>();
    vars.Hundo = new List<string>();
    vars.MainMissions = new List<string>();
    vars.JackMissions = new List<string>();
    vars.PlusOne = new List<string>();
    vars.PlusTwo = new List<string>();

}

init
{  
        switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
        version = "Ubisoft Connect";
        break;
        case (163323904):
        version = "Steam";
        break;
    } 
}

update
{
    if (settings["Percentage display"])
    {
    vars.SetTextComponent("Percentage Completion", "N/A");
    if (current.Percentage != null)
    vars.SetTextComponent("Percentage Completion", current.Percentage + "%");
    }
}

start
{

    //starts when you gain control of jacob from a fresh save
    if(settings["new_game"])
    {
        if(current.Cutscene == 0 && old.Cutscene == 1 || 2){
            return true;
        }
            
    }

    //starts when you gain control of jacob from loading a save past the first cutscene
    if(settings["loaded_save"])
    {
        if(old.Loading == 1 && current.Loading == 0 && current.Cutscene == 1){
            return true;
        }
             
    }

    //starts when starting a level
    if(settings["levels"])
    {
        return old.Cutscene == 0 && (current.Cutscene == 1 || current.Cutscene == 2);
    }
    
    if (settings["start"])
    {
        if (current.Cutscene == 2 && current.Character == 8){
            timer.Run.Offset = TimeSpan.FromSeconds(0);
            Thread.Sleep(1550);
            return true;
        }
    }

    if (settings["15sec_start"])
    {
        if (current.Cutscene == 1 && current.Character == 8){
            timer.Run.Offset = TimeSpan.FromSeconds(15);
            Thread.Sleep(500);
            return true;
        }
    }
}

onStart
{
    //any% list    
    if (settings["Any%"])
    {
        vars.Any = new List<string> {
            "A Spanner In The Works",
            "A Simple Plan",
            "Somewhere That's Green",
            "Homer Dalton",
            "Harold Drake",
            "Spitalfields",
            "Radclyffe Mill",
            "Simon Chase",
            "Martin Church",
            "The Jekyll Brothers",
            "Freedom Of The Press",
            "Captain Hargrave II",
            "George Scrivens",
            "The Crate Escape",
            "Playing It By Ear",
            "Leopold Bacchus",
            "Mildred Graves",
            "Cable News",
            "A Spoonful Of Syrup",
            "Unnatural Selection",
            "Echostreet Alley",
            "The Lambeth Bullies",
            "Strain & Boil",
            "On The Orgin Of Syrup",
            "The Fletchers",
            "Overdose",
            "The Lady With The Lamp",
            "Jesse Butler",
            "Battersea Bellows",
            "Tom Eccleston",
            "Breaking News",
            "Emmet Sedgwick",
            "A Room With A View",
            "Friendly Competition",
            "Research And Development",
            "Survival Of The Fittest",
            "End Of The Line",
            "One Good Deed",
            "A Thorne In The Side",
            "A Case Of Identity",
            "A Spot Of Tea",
            "A Bad Penny",
            "Unbreaking The Bank",
            "Change Of Plans",
            "Strange Bedfellows",
            "Triple Theft",
            "Fun And Games",
            "Final Act",
            "Playing Politics",
            "The Bodyguard",
            "Driving Mrs. Disraeli",
            "Motion To Impeach",
            "Double Trouble",
            "Dress to Impress",
            "Family Politics",
            "A Night To Remember"
        };
    }
    
    //100% list
    if (settings["100%"])
    {
        vars.Hundo = new List<string> {
            "A Spanner In The Works",
            "A Simple Plan",
            "Somewhere That's Green",
            "Homer Dalton",
            "Harold Drake",
            "Spitalfields",
            "Radclyffe Mill",
            "Simon Chase",
            "Martin Church",
            "The Jekyll Brothers",
            "Red Growler Distillery",
            "Freedom Of The Press",
            "Captain Hargrave II",
            "George Scrivens",
            "The Crate Escape",
            "Playing It By Ear",
            "Leopold Bacchus",
            "Mildred Graves",
            "Cable News",
            "A Spoonful Of Syrup",
            "Phillip Beckinridge",
            "Unnatural Selection",
            "Echostreet Alley",
            "The Lambeth Bullies",
            "Strain & Boil",
            "On The Orgin Of Syrup",
            "The Fletchers",
            "Overdose",
            "The Lady With The Lamp",
            "Jesse Butler",
            "Spring-Heeled Jack",
            "Cat And Mouse",
            "Dead Letters",
            "Wade Lynton",
            "Tom Eccleston",
            "Myrtle Platt",
            "Emmet Sedgwick",
            "The Mint",
            "Battersea Bellows",
            "Breaking News",
            "Black Swan Yard",
            "A Room With A View",
            "Harcey Hughes",
            "Friendly Competition",
            "Thomas Blackroot",
            "Outterridge Manufacturing",
            "Anarchist Intervention",
            "An Explosive End",
            "Albie Vassell",
            "Where There Is A Smoke",
            "Anna Abramson",
            "Research And Development",
            "Survival Of The Fittest",
            "Southwark Spinning Mill",
            "End Of The Line",
            "A Thorne In The Side",
            "Peter Needham",
            "Clare Market",
            "Hell's Bells",
            "Recollection",
            "Vox Populi",
            "One Good Deed",
            "Hightower Coal",
            "Maude Foster",
            "Eveline Dipper",
            "A Case Of Identity",
            "A Spot Of Tea",
            "Spindles and Looms",
            "The Darkest Hour",
            "The Apothecary Twins",
            "Hopton's",
            "17 Walpol Lane",
            "Clearence Stock House",
            "The Magpie",
            "The Master Spy",
            "A Bad Penny",
            "Stalk The Stalker",
            "Nigel In For The Chop",
            "Wolfshead Brewing Co.",
            "Strange Bedfellows",
            "Lynch's Fine Ornamentation",
            "50 Berkeley Square",
            "Milton King",
            "Triple Theft",
            "The Berlin Specimen",
            "Change Of Plans",
            "Fun And Games",
            "Argus and Rose Bartlett",
            "Final Act",
            "The Terror Of London",
            "The Slaughterhouse Siblings",
            "Defamation",
            "Beatrice Gribble",
            "An Abominable Mystery",
            "Gilbert Fowler",
            "Sylvia Duke",
            "Louis Blake",
            "Cruel Caricature",
            "A Struggle For Existence",
            "Field Lane",
            "Unbreaking The Bank",
            "David O'Donnell",
            "Rosemary Lane",
            "Hullo Mr. Gartling",
            "Harrison Harley",
            "Deil's Arce",
            "Playing Politics",
            "The Bodyguard",
            "Driving Mrs. Disraeli",
            "Motion To Impeach",
            "Double Trouble",
            "Dress to Impress",
            "Wallace Bone",
            "Good Fellow's Brewery",
            "Family Politics",
            "A Night To Remember",
            "Ivan Bunbury",
            "Blue Anchor Alley",
            "Operation Dynamite Boat",
            "Operation Locomotive",
            "Operation Drive For Lives",
            "Operation Westminster"
        };
    }
    
    //list's for any% for jack the ripper
    if(settings["Any%_DLC"])
    {
        vars.MainMissions = new List<string> {  
            "The Autumn of Terror", 
            "Unfortunates", 
            "The Lady Talks", 
            "Letters of Intent", 
            "The Mother of All Crimes",  
        };
        vars.JackMissions = new List<string> {
            "Prologue",
            "Prisoners", 
            "Loose Ends",
            "Family Reunion"
        };
        }
    
    //list's for 100% for jack the ripper
    if(settings["100%_DLC"])
    {
        vars.MainMissions = new List<string> {
            "Prologue",
            "The Autumn of Terror", 
            "Unfortunates", 
            "The Lady Talks", 
            "Letters of Intent", 
            "Prisoners",
            "Loose Ends", 
            "The Mother of All Crimes",
            "Family Reunion",
            "Live by the Creed, Die by the Creed"  
        };
        vars.PlusOne = new List<string> {
            "Chest 1",//during Unfortunates. Chest in the very back behind kennways manor
            "Buck's Row Brothel",
            "Chest 2",//during wood shinning. while ur driving Woody to the destinated marker on left side of rode
            "Woody Shinnings",
            "Helix Glitch 1",// after The Lady Talks. On your way to the carriage mission
            "Robert Donston Stephenson",
            "Helix Glitch 2",//during letters of Intent. is on roof pipes above where mr.weaverbrooks is
            "Dear Boss",
            "Chest 3",//during prisoners. first chest on the first boat
            "Saucy Jack",
            "Chest 4",//during the mother of all crimes. Closest chest to when you start the mission
            "From Hell",
            "Walk of shame",
            "Helix Glitch 3",//during egyptian spoils. u get all the chest at beginning area take carriage then as your driving their is a chest to your left and helix glitch to the right get in any order tbh
            "Jack's Lieutenants 1", 
            "Ludgate Hill Brothel",
            "David Jack-Emmings",
            "Chest 5", //during opium spoils. while driving to end point
            "Opium Spoils",
            "Indian Emerald"
        };
        vars.PlusTwo = new List<string> {
            "Sweryn Klosowski",
            "Mitre Square Fight Club",
            "Shameful Abuse",
            "Gracechurch Street Brothel",
            "Egyptian Spoils",
            "Lost Women",
            "Lost in the City",
            "Cock Lane Fight Club",
            "Jack's Lieutenants 2",
            "John Pizer"
        };
    }  
}


/*splits when end mission screen appears or when percentage changes.*/
split
{   


    if (settings["Any%"])
        {
    //For all splits except last split
        if(current.Endscreen == 1 && old.Endscreen == 0 && !vars.completedsplits.Contains(vars.Any[0]) && vars.Any[0] != "A Night To Remember")
            {      
            vars.completedsplits.Add(vars.Any[0]);
            vars.Any.RemoveAt(0);
            return true;
            }
    //For final split as the rules say after you press accept on mission end screen 
        if (current.Endscreen == 0 && old.Endscreen == 1 && !vars.completedsplits.Contains(vars.Any[0]))
            {
            vars.completedsplits.Add(vars.Any[0]);
            vars.Any.RemoveAt(0);
            return true;
            }
        }

    if (settings["100%"])
        {
    //For all splits excepet last split
        if(current.Endscreen == 1 && old.Endscreen == 0 && !vars.completedsplits.Contains("Operation Drive For Lives"))
            {      
            vars.completedsplits.Add(vars.Hundo[0]);
            vars.Hundo.RemoveAt(0);
            return true;
            }
    //For final split will only split if the percentage equals 100% completed 
        if (current.Endscreen == 0 && old.Endscreen == 1 && vars.completedsplits.Contains("Operation Drive For Lives") && current.Percentage == 100)
            {
            vars.completedsplits.Add(vars.Hundo[0]);
            vars.Hundo.RemoveAt(0);
            return true; 
            }
        }

    if(settings["Any%_DLC"])
        {
    //splits when end screen appears so when you are able to press "A" button or equivlent on keyboard and mouse for any%
        if(current.Endscreen == 1 && old.Endscreen == 0)
            {
            vars.completedsplits.Add(vars.MainMissions[0]);
            vars.MainMissions.RemoveAt(0);    
            return true;
            }
    //splits for jack missions and the mission for jack 2 sense their is either no end screen or their is a end screen but the percentage changes            
        if (current.Percentage == old.Percentage + 6 && current.Character != 6)
            {
            vars.completedsplits.Add(vars.JackMissions[0]);
            vars.JackMissions.RemoveAt(0); 
            return true;
            }
        }
    if (settings["100%_DLC"])
        {
    //Splits for all main missions as they all give plus 6 to the overall percentage    
        if (current.Percentage == old.Percentage + 6)
            {
            vars.completedsplits.Add(vars.MainMissions[0]);
            vars.MainMissions.RemoveAt(0);
            return true;
            }
    //Splits for Side missions and collectibles that give + 1 to the overal percentage
        if (current.Percentage == old.Percentage + 1)
            {
            vars.completedsplits.Add(vars.PlusOne[0]);
            vars.PlusOne.RemoveAt(0);
            return true;
            }
    //Splits for Side missions and collectibles that give + 2 to the overal percentage
        if (current.Percentage == old.Percentage + 2)
            {
            vars.completedsplits.Add(vars.PlusTwo[0]);
            vars.PlusTwo.RemoveAt(0);
            return true;
            }
        }
}

isLoading
{
    //pauses during loading screen and unpauses when out of loading screens note black screens do not Count as loading
    return current.Loading == 1 && current.Cutscene == 0;
}
reset
{
    //resets if you go to the main menu so try not to do that by accident an isnull equals false. So if u just had a crash note it will take 2 mins before it switches to false for just in case
    if (current.MainMenu == 1 && old.Percentage > 0 && current.Percentage <= 0)
    {
        return true;
    }
}

onReset
{
    //Clears all lists execpt completed splits
    if (vars.MainMissions.Count > 0 || vars.JackMissions.Count > 0 || vars.PlusOne.Count > 0 || vars.PlusTwo.Count > 0 || vars.Any.Count > 0 || vars.Hundo.Count > 0)
    {
        vars.Any.Clear();
        vars.Hundo.Clear();
        vars.MainMissions.Clear();
        vars.JackMissions.Clear();
        vars.PlusOne.Clear();
        vars.PlusTwo.Clear();
    }
    //Clears completedsplits list
    if (vars.completedsplits.Count > 0)
    {
        vars.completedsplits.Clear();
    }
}


//£

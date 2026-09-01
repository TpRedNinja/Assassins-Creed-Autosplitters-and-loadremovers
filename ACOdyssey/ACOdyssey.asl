// Autosplitter and load remover for Assassin's Creed Odyssey v. 1.5.6 (Steam & Ubisoft Connect)
// Made by: VegasKaiser & TpRedNinja
//
// Version: 0.0.1
//
// Contact info:
// - Assassin's Creed Speedrunning Discord server: invite link at https://www.speedrun.com/acodyssey
// - GitHub: https://github.com/TpRedNinja/Assassins-Creed-Autosplitters-and-loadremovers
//
// Many thanks to:
// - Forgemaster for his invaluable AC Viewer tool without which this autosplitter couldn't have been made: https://github.com/forge-master/ACViewer/wiki
// - linuslin0 for creating ACSaveTool: https://github.com/linuslin0/ACST 
// - Speedrun Tool Development Discord server, in particular ero and apple1417 for helping with the ASL language (invite link at: https://github.com/LiveSplit/LiveSplit.AutoSplitters#additional-resources)

state("ACOdyssey")
{
    int isLoading : 0x059EBA28, 0x32C; // -1 when loading and in the first two prologue cutscenes, 0 otherwise
    ulong lastCompletedQuest : 0x05B04AE8, 0x120, 0x48, 0x10; // 6-byte internal quest ID (see Components/ACOdysseyQuests.json)
    // ulong lastCompletedQuest : 0x059E7D08, 0x8, 0x110, 0x48, 0x10; // alternative pointer chain
    uint inCharCreationMenu : 0x056C1600, 0xA4; // 1 while in the character creation menu, 0 otherwise
    ulong world : 0x056C4348; // 6-byte internal world value (see vars.WorldRepository)
    byte inPrologueCutscene : 0x056C4365; // 1 while in the prologue's pre-rendered cutscenes, 0 otherwise
    byte inIntroCutscene : 0x0571E218; // 1 while in any cutscene (pre-rendered and in-game rendered), 0 otherwise
    uint screenFade : 0x05B00328, 0x8, 0x0, 0x94, 0x84; // 2 at the start of a fade in/out screen, 1 while it's active, 0 otherwise
}

startup
{
    vars.worldRepository = new Dictionary<ulong, string>
    {
        {0xC0262B40BB, "ACD_Greece"},
        {0x12EC1B5E842, "ACD_WhiteRoom"},
        {0x156D9C42F56, "ACD_TitleScreen"},
        {0x16111D6694F, "ACD_PresentDay"},
        {0x190A7543F8B, "ACD_Elysium"},
        {0x1A6C1E737CD, "ACD_Underworld"},
        {0x1AC524C8511, "ACD_Atlantis"},
        {0x1AEB5A93A86, "ACD_ThroneRoom"},
        {0x1E2E82B9D63, "ACD_Connection"},
    };

    Func<ulong, string> getWorld = world =>
    {
        string w = "";
        vars.worldRepository.TryGetValue(world, out w);
        return w;
    };

    vars.getWorld = getWorld;

    Func<ulong, bool> canStartNewGamePlus = world =>
    {
        string w = "";
        if (vars.worldRepository.TryGetValue(world, out w))
        {
            return (w != "ACD_TitleScreen" &&
                    w != "ACD_WhiteRoom" &&
                    w != "ACD_PresentDay");
        }
        return false;
    };

    settings.Add("NeedHelp", true, "Need help? Join the AC Speedrunning Discord!");
    settings.SetToolTip("NeedHelp", "Invite link can be found at: www.speedrun.com/acodyssey");

    vars.canStartNewGamePlus = canStartNewGamePlus;

    settings.Add("NewGamePlus", false, "New Game+ AutoStart");
    settings.SetToolTip("NewGamePlus", "Let the timer start automatically for NG+.");

    vars.questRepository = new Dictionary<ulong, List<string>>();
    vars.childQuests = new Dictionary<ulong, List<ulong>>();

    string questRepositoryJSON = File.ReadAllText("Components/ACOdysseyQuests.json");    
    IDictionary<string, object> jsonData = System.Text.Json.JsonSerializer.Deserialize<IDictionary<string, object>>(questRepositoryJSON);

    Action<string, string, string> addChildToolTip = (devName, longName, key) =>
    {
        string[] validChilds = { "Meta-Quest", "Chapters", "Clusters", "Main Quests", "Side Quests", "Achievements" };
        string kind = validChilds.Contains(key) ? key.ToLower().TrimEnd('s') : "quest";
        string description = String.Format("If enabled, splits on completion of the '{0}' {1}.", longName, kind);
        settings.SetToolTip(devName, description);
    };

    Action<IDictionary<string, object>> populateSettings = null;
    populateSettings = dict =>
    {
        string parent = settings.CurrentDefaultParent;
        foreach (string key in dict.Keys)
        {
            string settingName = String.Format("{0}{1}{2}", parent, (parent == null ? "" : "_"), key);
            settings.Add(settingName, false, key, parent);
            settings.CurrentDefaultParent = settingName;

            object nextLevel = dict[key];

            if (nextLevel == null)
                continue;

            if (nextLevel is System.Text.Json.JsonElement)
            {
                var element = (System.Text.Json.JsonElement) nextLevel;
                switch (element.ValueKind)
                {
                    case System.Text.Json.JsonValueKind.Object:
                        var nestedDict = element.EnumerateObject().ToDictionary(p => p.Name, p => (object) p.Value);
                        populateSettings(nestedDict);
                        break;

                    case System.Text.Json.JsonValueKind.Array:
                        foreach (var quest in element.EnumerateArray())
                        {
                            var questData = quest.EnumerateArray().ToArray();
                            var id = questData[0].GetUInt64();
                            var children = questData[1].EnumerateArray().Select(item => item.GetUInt64()).ToArray();
                            var devName = questData[2].ToString();
                            var longName = questData[3].ToString();
                            if (children != null && children.Length > 0)
                            {
                                List<ulong> cq = null;
                                if (vars.childQuests.TryGetValue(id, out cq))
                                {
                                    cq.AddRange(children);
                                }
                                else
                                {
                                    vars.childQuests[id] = new List<ulong>(children);
                                }
                            }
                            settings.Add(devName, false, longName);
                            addChildToolTip(devName, longName, key);
                            vars.questRepository[id] = new List<string>() { devName, longName };
                        }
                        break;
                        
                    default:
                        break;
                }
            }
        settings.CurrentDefaultParent = parent;
        }
    };

    populateSettings((IDictionary<string, object>) jsonData);
}

init 
{
    vars.completedQuests = new List<string>();
    vars.removingIntroLoadNG = false;
    vars.introDone = false;

    Func<ulong, bool> shouldSplit = null;
    shouldSplit = questID =>
    {
        List<string> quest = null;
        if (vars.questRepository.TryGetValue(questID, out quest))
        {
            var questName = quest[0];

            if (vars.completedQuests.Contains(questName))
                return false;

            if (settings[questName])
            {
                vars.completedQuests.Add(questName);
                return true;
            }

            // If a main or side quest that we need to split on was just completed
            // *and* it was the last remaining one in the chapter that it belongs
            // to, then sometimes the game writes the chapter quest to lastCompletedQuest
            // rather than that tracked main/side quest. The same can happen with
            // meta-quests if the chapter quest belongs to one.
            // Because of that, if we're tracking at least one main/side quest
            // that can trigger the end of a chapter quest and/or a chapter that
            // can trigger the end of a meta-quest, we need to split on the
            // chapter quest or the meta-quest respectively (if we don't, we'll
            // miss the split on the tracked quest and/or on the chapter).
            // For instance: Debt Collector triggers the end of the chapter quest
            // Another Day, Another Drachma, lastCompletedQuest will only update
            // to the latter so we need to make sure that we check if any of ADAD's
            // child quests that can trigger its end are completed (which here
            // is only Debt Collector) and make sure to split if the user has
            // chosen to split on Debt Collector.
            
            List<ulong> children = null;
            if (!vars.childQuests.TryGetValue(questID, out children))
                return false;
            
            foreach (var child in children)
            {
                List<string> childQuest = null;
                if (vars.questRepository.TryGetValue(child, out childQuest))
                {
                    var childQuestName = childQuest[0];
                    var splitOnChildQuest = settings[childQuestName];
                    if (vars.completedQuests.Contains(childQuestName))
                        continue;
                    if (!splitOnChildQuest)
                    {
                        // We still have to follow the chain of the current child quest's
                        // child quests or we could miss a quest that we need to split on.
                        if (!shouldSplit(child))
                            continue;
                        vars.completedQuests.Add(questName);
                        return true;
                    }
                    else
                    {
                        vars.completedQuests.Add(childQuestName);
                        vars.completedQuests.Add(questName);
                        return true;
                    }
                }
            }
        }
        return false;
    };
    vars.shouldSplit = shouldSplit;
}

start
{
    if (settings["NewGamePlus"])
    {
        if (vars.getWorld(current.world) == "ACD_Greece" &&
            old.inIntroCutscene == 1 && current.inIntroCutscene == 0 &&
            current.isLoading == 0)
        {
            vars.introDone = true;
            return true;
        }
    }
    else
    {
        if (vars.getWorld(current.world) == "ACD_Greece" &&
            current.inPrologueCutscene == 0 &&
            current.isLoading == 0)
                return true;
    }
}

isLoading
{
    if (!vars.introDone)
    {
        if (!settings["NewGamePlus"])
        {
            if (!vars.removingIntroLoadNG)
            {
                if (current.lastCompletedQuest == 0x14E2FF37534 && // Battle of 300
                    old.inCharCreationMenu == 1 && current.inCharCreationMenu == 0)
                {
                    // The loading screen after the character creation menu
                    // has started, we wait until this and the following white
                    // screen end. At this point isLoading is -1 and screenFade
                    // is either 2 or 1
                    vars.removingIntroLoadNG = true;
                    return true;
                };
                // We're either in control of Leonidas in the prologue or in
                // the character creation menu, so keep the timer running
                return false;
            }
            else
            {
                // Wait until the aforementioned white screen that fades into
                // the cutscene where Ikaros flies over to Kassandra/Alexios ends
                if (current.isLoading == 0 && current.screenFade == 0)
                {
                    vars.removingIntroLoadNG = false;
                    vars.introDone = true;
                    return false;
                }
                return true;
            }
        }
        // In NG+, the timer only starts when the intro cutscene is done so
        // we don't need to remove any load time here
        return false;
    }

    return (current.isLoading == -1);
}

split
{
    if (current.lastCompletedQuest == 0 ||
        current.lastCompletedQuest == old.lastCompletedQuest)
            return false;
    
    return vars.shouldSplit(current.lastCompletedQuest);
}

onReset
{
    vars.removingIntroLoadNG = false;
    vars.introDone = false;
    vars.completedQuests.Clear();
}
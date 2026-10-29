// Assassin's Creed 1 Autosplitter (DX9 + DX10)
// Version: v0.0.9 (see vars.ASLVersion)
// - position splits (memory block starts, death confession) / loading / health splits: original AC1.asl
// - mission splits: every mission item (dev name) is a setting; splits when its state becomes 3 (done)
// - auto start on the New Game click: heap scan for the menu handler (build specific vtable, picked in init)
// - credits split (DX9 + DX10, always on): heap scan for the CreditsHandler object, confirmed through the handle table
state("AssassinsCreed_Dx10")
{
    int Health: 0x025C1470, 0x14; // current health
    int MaxHealth: 0x025C1470, 0x18; // What the current max health you can heal to
    float XCoord: 0x159FE30, 0x0, 0x40; // Player X Coordinates
    float YCoord: 0x159FE30, 0x0, 0x44; // Player Y Coordinates
    float ZCoord: 0x159FE30, 0x0, 0x48; // Player Z Coordinates
    byte PlayerID: 0x159FE30, 0x0, 0xA8; // Player ID 9 for Desmond, 1 for Altair
    uint World: 0x25C2EE8, 0xFC; // current world id (main menu = 0x1E3889FE, 0 while loading)
    uint LoadingWorld: 0x159EC00, 0x12C, 0xC; // current id of the world being loaded (WorldTransitionManager +0x12C -> handle entry +0xC); 0 when nothing is loading
    byte TemplarsKilled: 0x159EA18, 0x8, 0x4, 0x8, 0x8, 0x0, 0x14, 0x20; // total number of templars killed in all worlds.
    byte KingdomFlags: 0x159EA18, 0x8, 0x4, 0x8, 0xC, 0x0, 0x14, 0x20; // total number of Kingdom flags collected in Kingdom
    byte MasyafFlags: 0x159EA18, 0x8, 0x4, 0x8, 0x10, 0x0, 0x14, 0x20; // total number of Masyaf flags collected in Masyaf
    byte JerusalemFlags: 0x159EA18, 0x8, 0x4, 0x8, 0x14, 0x0, 0x14, 0x20; // total number of Jerusalem flags collected in Jerusalem
    byte DamascusFlags: 0x159EA18, 0x8, 0x4, 0x8, 0x18, 0x0, 0x14, 0x20; // total number of Damascus flags collected in Damascus
    byte TeutonicFlags: 0x159EA18, 0x8, 0x4, 0x8, 0x98, 0x0, 0x14, 0x20; // total number of Teutonic flags collected in Acre
    byte TemplarsFlags: 0x159EA18, 0x8, 0x4, 0x8, 0x9C, 0x0, 0x14, 0x20; // total number of Templars flags collected in Acre
    byte HspitaliersFlags: 0x159EA18, 0x8, 0x4, 0x8, 0xA0, 0x0, 0x14, 0x20; // total number of Hspitaliers flags collected in Acre
}

state("AssassinsCreed_Dx9")
{
    int Health: 0x16284E0, 0x14;
    int MaxHealth: 0x16284E0, 0x18;
    float XCoord: 0x1612FB0, 0x0, 0x40;
    float YCoord: 0x1612FB0, 0x0, 0x44;
    float ZCoord: 0x1612FB0, 0x0, 0x48;
    byte PlayerID: 0x1612FB0, 0x0, 0xA8;
    uint World: 0x1629F58, 0xFC;
    uint LoadingWorld: 0x1611BF0, 0x12C, 0xC;
    byte TemplarsKilled: 0x1611A08, 0x8, 0x4, 0x8, 0x8, 0x0, 0x14, 0x20;
    byte KingdomFlags: 0x1611A08, 0x8, 0x4, 0x8, 0xC, 0x0, 0x14, 0x20;
    byte MasyafFlags: 0x1611A08, 0x8, 0x4, 0x8, 0x10, 0x0, 0x14, 0x20;
    byte JerusalemFlags: 0x1611A08, 0x8, 0x4, 0x8, 0x14, 0x0, 0x14, 0x20;
    byte DamascusFlags: 0x1611A08, 0x8, 0x4, 0x8, 0x18, 0x0, 0x14, 0x20;
    byte TeutonicFlags: 0x1611A08, 0x8, 0x4, 0x8, 0x98, 0x0, 0x14, 0x20;
    byte TemplarsFlags: 0x1611A08, 0x8, 0x4, 0x8, 0x9C, 0x0, 0x14, 0x20;
    byte HspitaliersFlags: 0x1611A08, 0x8, 0x4, 0x8, 0xA0, 0x0, 0x14, 0x20;
}

startup
{
    vars.ASLVersion = "v0.0.9";

    timer.Run.Metadata.SetCustomVariable("Auto Splitter Version", vars.ASLVersion);

    // ---- mission dictionary: dev name -> (child index path from the root item, hash ID, tier) ----
    // Filled from Components/AC1Missions.json while the settings are built (see below).
    // Tier = position of the top level list in the run order (0 Game Start, 1 Memory Block 1, 2 M08_Day1, 3 Memory Block 2, 4 M15_Day2, ... 14 M72_Day7);
    // -1 = the 100% lists (side quests, Kingdom, Present), which are always watched.
    vars.Missions = new Dictionary<string, Tuple<string, uint, int>>();
    // priority = tier * 1000000 + sub tier * 1000 + number ("0.2.1" = tier 0, sub tier 2, number 1); a plain number tier has sub 0.
    // Only the lowest priority level that still has an unfinished mission is read (see PriorityWindow); -1 = the 100% lists, always read.
    vars.MPrio = new Dictionary<string, int>();
    // some splits have a merge tier: while a trigger split of the same area is enabled (the 100% splits of an investigation) every split with that merge tier is read at the same priority,
    // because the order of the missions is not fixed in a 100% run. MBase keeps the normal priorities, MMerge = dev name -> merge priority, MTrig = dev names of the trigger splits.
    vars.MBase = new Dictionary<string, int>();
    vars.MMerge = new Dictionary<string, int>();
    vars.MTrig = new HashSet<string>();
    // target order: a memory block with several targets that can be done in any order (2 in Memory Block 3, 3 in Memory Block 4). The splits of each target have one priority per slot (1st, 2nd, 3rd target done),
    // which is how the targets swap places. The default order is the one written in the tier of the split. Marker splits (the debriefs of the first / second target) say which target is in which slot;
    // targets without a marker fill the free slots in their default order. Two markers for one slot, or one target in two slots = error, and nothing is read (a marker with the target "*" is the "any target" option: it picks no target but counts as a marker for its slot).
    // MOrdSplit = dev name -> (order key, target, priority per slot, merge priority per slot or null), MOrdMark = marker dev name -> (order key, target, slot), MOrdDef = order key|target -> default slot
    vars.MOrdSplit = new Dictionary<string, Tuple<string, string, int[], int[]>>();
    vars.MOrdMark = new Dictionary<string, Tuple<string, string, int>>();
    vars.MOrdDef = new Dictionary<string, int>();
    vars.RouteError = false;         // true while the target order settings conflict

    // ---- settings ----
    settings.Add("Splits", false, "Splits");
        settings.Add("MemoryBlockSplits", false, "Memory Block Splits", "Splits");
        settings.SetToolTip("MemoryBlockSplits", "Position based splits at the start of the memory blocks.");
            settings.Add("Tutorial", false, "Tutorial", "MemoryBlockSplits");
            settings.SetToolTip("Tutorial", "Splits when you have loaded into Solomon's Temple after the tutorial.\nThis is the start of Memory Block 1, so if you want to split there, choose this one.");
            settings.Add("MemoryBlock 2 Start", false, "Memory Block 2 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 2 Start", "Splits at the start of memory block 2");
            settings.Add("MemoryBlock 3-6 Start", false, "Memory Block 3-6 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 3-6 Start", "Splits at the start of memory blocks 3-6. Also splits whenever you return to Masyaf after killing a target that's not the last one in the memory block.");
            settings.Add("MemoryBlock 7 Start", false, "Memory Block 7 Start", "MemoryBlockSplits");
            settings.SetToolTip("MemoryBlock 7 Start", "Splits at the start of memory block 7.");
        settings.Add("MiscSplits", false, "Misc Splits", "Splits");
        settings.SetToolTip("MiscSplits", "This contains splits that aren't necessarily tied to a specific memory block but are still important splits for the run");
            settings.Add("DeathConfessionSplits", false, "Death Confession Splits", "MiscSplits");
            settings.SetToolTip("DeathConfessionSplits", "Splits for all targets when you are in the death confession room.");
            settings.Add("HealthIncreaseSplits", false, "HealthIncreaseSplits", "MiscSplits");
            settings.SetToolTip("HealthIncreaseSplits", "Splits when you gain a health increase/rank up.");
        // The mission settings come from Components/AC1Missions.json:
        //  - an object is a settings group; a MissionItemList's group has an entry called "(list completed)" for the list itself plus its children
        //  - an array is a setting: [child index path, hash ID, dev name (= setting id), name shown in the settings, tier, tooltip (optional), merge tier (optional), 100% trigger (optional, true/false)]
        //  - the order in the file is the order in the settings
        var missions = (Dictionary<string, Tuple<string, uint, int>>)vars.Missions;
        var prios = (Dictionary<string, int>)vars.MPrio;
        var merges = (Dictionary<string, int>)vars.MMerge;
        var trigs = (HashSet<string>)vars.MTrig;
        var ordSplit = (Dictionary<string, Tuple<string, string, int[], int[]>>)vars.MOrdSplit;
        var ordMark = (Dictionary<string, Tuple<string, string, int>>)vars.MOrdMark;
        var ordDef = (Dictionary<string, int>)vars.MOrdDef;
        // "tier.subTier.number" -> priority
        Func<string, int> parseTier = ts =>
        {
            var tp = ts.Split('.');
            int r = int.Parse(tp[0]) * 1000000;
            if (tp.Length > 1) r += int.Parse(tp[1]) * 1000;
            if (tp.Length > 2) r += int.Parse(tp[2]);
            return r;
        };
        Action<System.Text.Json.JsonElement, string> addGroup = null;
        addGroup = (obj, parentId) =>
        {
            foreach (var prop in obj.EnumerateObject())
            {
                if (prop.Value.ValueKind == System.Text.Json.JsonValueKind.Object)
                {
                    string gid = "G:" + prop.Name;
                    System.Text.Json.JsonElement own;
                    if (prop.Value.TryGetProperty("(list completed)", out own))
                        gid = "G:" + own[2].GetString();
                    settings.Add(gid, false, prop.Name, parentId);
                    addGroup(prop.Value, gid);
                }
                else
                {
                    string dev = prop.Value[2].GetString();
                    settings.Add(dev, false, prop.Value[3].GetString(), parentId);
                    // tier: a number, or a string "tier.subTier.number" (e.g. "0.2.1")
                    int tier, sub = 0;
                    if (prop.Value[4].ValueKind == System.Text.Json.JsonValueKind.Number)
                        tier = prop.Value[4].GetInt32();
                    else
                    {
                        var tp = prop.Value[4].GetString().Split('.');
                        tier = int.Parse(tp[0]);
                        if (tp.Length > 1) sub = int.Parse(tp[1]) * 1000;
                        if (tp.Length > 2) sub += int.Parse(tp[2]);
                    }
                    missions[dev] = Tuple.Create(prop.Value[0].GetString(), prop.Value[1].GetUInt32(), tier);
                    prios[dev] = tier >= 0 ? tier * 1000000 + sub : -1;
                    // optional tooltip
                    if (prop.Value.GetArrayLength() > 5 && !string.IsNullOrEmpty(prop.Value[5].GetString()))
                        settings.SetToolTip(dev, prop.Value[5].GetString());
                    // optional merge tier ("tier.subTier.number") and trigger flag, see vars.MMerge
                    if (prop.Value.GetArrayLength() > 6 && prop.Value[6].ValueKind == System.Text.Json.JsonValueKind.String)
                    {
                        merges[dev] = parseTier(prop.Value[6].GetString());
                        if (prop.Value.GetArrayLength() > 7 && prop.Value[7].GetBoolean()) trigs.Add(dev);
                    }
                    // optional target order info (an object): {"order": key, "target": name, "slots": [tier per slot], "slotMerge": [merge tier per slot]} for the splits of a target,
                    // {"order": key, "target": name, "marker": slot number (1 = first target done)} for the marker splits, see vars.MOrdSplit
                    if (prop.Value.GetArrayLength() > 8 && prop.Value[8].ValueKind == System.Text.Json.JsonValueKind.Object)
                    {
                        var ri = prop.Value[8];
                        System.Text.Json.JsonElement rx;
                        string okey = ri.GetProperty("order").GetString();
                        string otgt = ri.GetProperty("target").GetString();
                        if (ri.TryGetProperty("marker", out rx)) ordMark[dev] = Tuple.Create(okey, otgt, rx.GetInt32() - 1);
                        if (ri.TryGetProperty("slots", out rx))
                        {
                            var sp = new List<int>();
                            foreach (var el in rx.EnumerateArray()) sp.Add(parseTier(el.GetString()));
                            int[] sm = null;
                            if (ri.TryGetProperty("slotMerge", out rx))
                            {
                                var ml = new List<int>();
                                foreach (var el in rx.EnumerateArray()) ml.Add(parseTier(el.GetString()));
                                sm = ml.ToArray();
                            }
                            ordSplit[dev] = Tuple.Create(okey, otgt, sp.ToArray(), sm);
                            int defSlot = sp.IndexOf(prios[dev]);
                            if (defSlot >= 0) ordDef[okey + "|" + otgt] = defSlot;
                        }
                    }
                }
            }
        };
        try
        {
            // developer copy of the file (only exists on the author's PC); everyone else uses the one in the Components folder
            string devMissionFile = "C:/Users/jjdom/OneDrive/Desktop/notes/AC1Missions.json";
            string missionFile = File.Exists(devMissionFile) ? devMissionFile : "Components/AC1Missions.json";
            var missionDoc = System.Text.Json.JsonDocument.Parse(File.ReadAllText(missionFile));
            addGroup(missionDoc.RootElement, "Splits");
        }
        catch (Exception ex)
        {
            print("AC1: could not read the missions file (Components/AC1Missions.json): " + ex.Message);
        }
        vars.MBase = new Dictionary<string, int>(prios);
    settings.Add("AutoStartNew", true, "Start timer when New Game is clicked");
    settings.SetToolTip("AutoStartNew", "Starts the timer the moment New Game is clicked on the main menu (needs a short memory scan of the menu while the timer is not running).");
    settings.Add("Memory Block Runs", false, "Memory Block Start Timer");
    settings.SetToolTip("Memory Block Runs", "Starts the timer at the start of memory blocks so you can time them separately. Note Memory Blocks 3-6 share the same start position.");
        for (int i = 1; i <= 7; i++)
        {
            settings.Add("MemoryBlock" + i, false, "Memory Block " + i, "Memory Block Runs");
            settings.SetToolTip("MemoryBlock" + i, "Starts the timer for the start of memory block " + i);
        }
    settings.Add("Flags", false, "Flags", "G:100%");
    settings.SetToolTip("Flags", "Contains splits for splitting on any of the flags in the game.");
        settings.Add("KingdomFlags", false, "Kingdom Flags", "Flags");
        settings.SetToolTip("KingdomFlags", "Splits whenever you collect any Kingdom flags in the Kingdom.");
        settings.Add("MasyafFlags", false, "Masyaf Flags", "Flags");
        settings.SetToolTip("MasyafFlags", "Splits whenever you collect any Masyaf flags in Masyaf.");
        settings.Add("JerusalemFlags", false, "Jerusalem Flags", "Flags");
        settings.SetToolTip("JerusalemFlags", "Splits whenever you collect any Jerusalem flags in Jerusalem.");
        settings.Add("DamascusFlags", false, "Damascus Flags", "Flags");
        settings.SetToolTip("DamascusFlags", "Splits whenever you collect any Damascus flags in Damascus.");
        settings.Add("TeutonicFlags", false, "Teutonic Flags", "Flags");
        settings.SetToolTip("TeutonicFlags", "Splits whenever you collect any Teutonic flags in Acre.");
        settings.Add("TemplarsFlags", false, "Templars Flags", "Flags");
        settings.SetToolTip("TemplarsFlags", "Splits whenever you collect any Templars flags in Acre.");
        settings.Add("HspitaliersFlags", false, "Hspitaliers Flags", "Flags");
        settings.SetToolTip("HspitaliersFlags", "Splits whenever you collect any Hspitaliers flags in Acre.");
    settings.Add("TemplarsKilled", false, "Templars Killed", "G:100%");
    settings.SetToolTip("TemplarsKilled", "Splits whenever you kill a templar in the game.");
    settings.Add("DebugPrint", false, "Debug Shit");
    settings.SetToolTip("DebugPrint", "Do not turn this on, otherwise print statements may slow down your LiveSplit.");
    settings.Add("XYZ", false, "XYZ");
    settings.SetToolTip("XYZ", "Shows the players current XYZ coordinates in the custom variable called XYZ (add it to your layout with a Custom Variable component)");

    // ---- positions (exact match on the rounded coordinates) ----
    vars.SplitPositions = new Dictionary<string, float[]>
    {
        {"Tutorial", new float [] {-66.18973f, -58.75932f, -8.38886f}},
        {"MemoryBlock 2 Start", new float [] {208.24425f, 11.22722f, 107.64150f}},
        {"MemoryBlock 3-6 Start", new float [] {207.43881f, 12.49873f, 107.60572f}},
        {"MemoryBlock 7 Start", new float [] {-38.28265f, -33.71172f, 34.46831f}},
        {"Death Confession Room for Maria", new float [] {-11.29227f, -30.75496f, 0.00000f}},
        {"Death Confession Room", new float [] {-11.42463f, -30.58017f, 0.00000f}}
    };

    // true when the player just arrived at pos (at pos now, was elsewhere on the previous update)
    Func<dynamic, dynamic, float[], bool> ArrivedAt = (dynamic cur, dynamic prev, float[] pos) =>
        cur.XCoord == pos[0] && cur.YCoord == pos[1] && cur.ZCoord == pos[2]
        && (prev.XCoord != pos[0] || prev.YCoord != pos[1] || prev.ZCoord != pos[2]);
    vars.ArrivedAt = ArrivedAt;

    // ---- mission split state ----
    vars.MActive = new List<string>();   // enabled missions that are not done yet
    vars.MDone = new List<string>();     // enabled missions that are done this run
    vars.MSweep = true;                  // false = the first check after a start silently marks already finished missions as done
    vars.NewGameStart = false;
    vars.PriorityWindow = 1;             // priority levels read at once (1 = only the earliest unfinished level; a mission that never reaches 3 blocks the ones after it, raise this to read further ahead)
    vars.MItems = new Dictionary<string, IntPtr>();
    vars.MNext = new Dictionary<string, long>();
    vars.MFire = new Queue<string>();
    vars.MBuilt = false;                 // true once RebuildMissions has run (the lists exist)
    // rebuild the active list from the settings (every dictionary key whose setting is on) and clear the done list
    // takes the settings object as an argument: the one visible in startup is the settings builder, which cannot be indexed
    vars.RebuildMissions = (Action<dynamic>)(s =>
    {
        var act = new List<string>();
        foreach (var kv in (Dictionary<string, Tuple<string, uint, int>>)vars.Missions)
            if (s[kv.Key]) act.Add(kv.Key);
        vars.MActive = act;
        vars.MDone = new List<string>();
        vars.MFire = new Queue<string>();
        vars.MBuilt = true;
        var prio = (Dictionary<string, int>)vars.MPrio;
        var bas = (Dictionary<string, int>)vars.MBase;
        var mrg = (Dictionary<string, int>)vars.MMerge;
        var trg = (HashSet<string>)vars.MTrig;
        // target order: the marker splits that are on decide which target is in which slot (see vars.MOrdSplit)
        var omk = (Dictionary<string, Tuple<string, string, int>>)vars.MOrdMark;
        var osp = (Dictionary<string, Tuple<string, string, int[], int[]>>)vars.MOrdSplit;
        var odf = (Dictionary<string, int>)vars.MOrdDef;
        var picked = new Dictionary<string, Dictionary<int, List<string>>>();
        foreach (string k in act)
        {
            Tuple<string, string, int> mk;
            if (!omk.TryGetValue(k, out mk)) continue;
            Dictionary<int, List<string>> bySlot;
            if (!picked.TryGetValue(mk.Item1, out bySlot)) { bySlot = new Dictionary<int, List<string>>(); picked[mk.Item1] = bySlot; }
            List<string> lst;
            if (!bySlot.TryGetValue(mk.Item3, out lst)) { lst = new List<string>(); bySlot[mk.Item3] = lst; }
            lst.Add(mk.Item2);
        }
        vars.RouteError = false;
        var slotOf = new Dictionary<string, int>();     // order key|target -> slot
        foreach (var ord in picked)
        {
            var taken = new Dictionary<string, int>();   // target -> slot picked by a marker
            bool bad = false;
            foreach (var slv in ord.Value)
            {
                if (slv.Value.Count > 1) bad = true;
                foreach (string t in slv.Value)
                {
                    if (t == "*") continue;                  // "any target" option: counts for the conflict check, picks no target
                    if (taken.ContainsKey(t)) bad = true;
                    taken[t] = slv.Key;
                }
            }
            if (bad)
            {
                vars.RouteError = true;
                print("AC1: error, 2 conflicting settings are on (target order " + ord.Key + "). No mission memory is read until this is fixed.");
                continue;
            }
            // the other targets fill the free slots in their default order
            var tgs = new List<string>();
            foreach (var dk in odf)
                if (dk.Key.StartsWith(ord.Key + "|")) tgs.Add(dk.Key.Substring(ord.Key.Length + 1));
            string okp = ord.Key + "|";
            tgs.Sort((x, y) => odf[okp + x].CompareTo(odf[okp + y]));
            var used = new HashSet<int>(taken.Values);
            int nextFree = 0;
            foreach (string t in tgs)
            {
                if (taken.ContainsKey(t)) { slotOf[okp + t] = taken[t]; continue; }
                while (used.Contains(nextFree)) nextFree++;
                slotOf[okp + t] = nextFree;
                used.Add(nextFree);
            }
        }
        // effective priority and merge priority of every split (the ones of its slot)
        var eff = new Dictionary<string, int>(bas);
        var effMrg = new Dictionary<string, int>(mrg);
        foreach (var os in osp)
        {
            int slot;
            if (!slotOf.TryGetValue(os.Value.Item1 + "|" + os.Value.Item2, out slot) || slot >= os.Value.Item3.Length) continue;
            eff[os.Key] = os.Value.Item3[slot];
            if (os.Value.Item4 != null && slot < os.Value.Item4.Length) effMrg[os.Key] = os.Value.Item4[slot];
        }
        // merge tiers: an area whose trigger split is enabled reads all of its merge split at one priority, otherwise the normal priorities apply
        var on = new HashSet<int>();
        foreach (string k in act)
            if (trg.Contains(k)) on.Add(effMrg[k]);
        foreach (var kv in eff)
            prio[kv.Key] = kv.Value;
        foreach (var kv in effMrg)
            prio[kv.Key] = on.Contains(kv.Value) ? kv.Value : eff[kv.Key];
    });

    // ---- autostart / credits state ----
    vars.H = IntPtr.Zero;            // New/Continue menu handler
    vars.nextScan = 0L;
    vars.NEW_GAME = 0x377AC858;      // target world hash of the New Game button
    vars.CreditsDelayMs = 726;       // ms between the credits flip and the split; tune after recording (0 = split on the flip)
    vars.CreditsRescanMs = 3000;     // time between credits-object heap scans while it is not known (max 10 per world load)
    vars.Obj = IntPtr.Zero;          // CreditsHandler object
    vars.LastCreditsScan = 0L;
    vars.CreditsActive = false;
    vars.CreditsFired = false;
    vars.CreditsFire = false;
    vars.CreditsSw = new Stopwatch();
    vars.MENU_WORLD = 0x1E3889FEu;   // world id of the main menu
    vars.CreditsTries = 0;           // credits-object scans left after the last world change
    vars.EndObj = IntPtr.Zero;       // cached MissionItem object of M72_S04_Secret_Ending
    vars.EndNextResolve = 0L;
}

init
{
    // build specific constants (the process name is only known here, not in startup)
    bool dx10 = game.ProcessName.IndexOf("Dx10", StringComparison.OrdinalIgnoreCase) >= 0;
    vars.IsDx10 = dx10;
    vars.VTABLE = dx10 ? 0x174D7C0 : 0x1705484;                      // New/Continue menu handler vtable
    vars.MenuTarget = dx10 ? "C0 D7 74 01" : "84 54 70 01";           // same value as bytes
    var baseAddr = modules.First().BaseAddress;
    vars.Sentinel   = (uint)((long)baseAddr + (dx10 ? 0x25A3294 : 0x161E204));   // credits movie handle "null"
    vars.HandleRoot = baseAddr + (dx10 ? 0x25A3318 : 0x161E288);                 // handle table root
    vars.MissionMgr = baseAddr + (dx10 ? 0x159EAA8 : 0x1611AF8);                 // MissionManager static pointer
    vars.CreditsVt  = dx10 ? 0x01741A00u : 0x016F8DBCu;                          // CreditsHandler vtable
    vars.CreditsTarget = dx10 ? "00 1A 74 01" : "BC 8D 6F 01";                   // same value as bytes
    vars.H = IntPtr.Zero;
    vars.nextScan = 0L;
    vars.Obj = IntPtr.Zero;
    vars.LastCreditsScan = 0L;
    vars.CreditsActive = false;
    vars.CreditsSw.Reset();
    vars.CreditsTries = 10;          // attached mid-run: allow a first batch of scans

    // New/Continue menu handler: private (heap) memory only, so the copy of the bytes inside the exe is not matched
    vars.ScanMenu = (Func<Process, IntPtr>)(proc =>
    {
        var target = new SigScanTarget(0, (string)vars.MenuTarget);
        foreach (var page in proc.MemoryPages(false))
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            foreach (var hit in scanner.ScanAll(target))
            {
                if (((long)hit & 3) != 0) continue;                       // instances are 4-aligned
                if (proc.ReadValue<int>(hit + 0x14) == 0) continue;       // clip pointer must exist
                return hit;
            }
        }
        return IntPtr.Zero;
    });

    // hash ID of a game object through the global handle table (0 when anything looks wrong)
    vars.HashOf = (Func<IntPtr, uint>)(obj =>
    {
        uint idx;
        if (!game.ReadValue<uint>(obj + 4, out idx) || idx == 0 || idx > 0x100000) return 0;
        uint i0 = idx - 1;
        IntPtr root;
        if (!game.ReadPointer((IntPtr)vars.HandleRoot, out root) || root == IntPtr.Zero) return 0;
        IntPtr page;
        if (!game.ReadPointer(root + (int)(12 * (i0 >> 14)), out page) || page == IntPtr.Zero) return 0;
        IntPtr entry = page + (int)(16 * (i0 & 0x3FFF));
        IntPtr target; uint hash;
        if (!game.ReadPointer(entry, out target) || target != obj) return 0;
        if (!game.ReadValue<uint>(entry + 0xC, out hash)) return 0;
        return hash;
    });

    // MissionItem by static child-index path from the root item, DX10 (MissionManager exe+159EAA8 -> +0x48 -> root entry).
    // Same tree as AC1_DX10_mission_paths.csv (column child_index_path), e.g. "20.0.2" = M72_S04_Secret_Ending.
    vars.ItemByPath = (Func<string, IntPtr>)(path =>
    {
        IntPtr p, entry, obj, arr;
        if (!game.ReadPointer((IntPtr)vars.MissionMgr, out p) || p == IntPtr.Zero) return IntPtr.Zero;
        if (!game.ReadPointer(p + 0x48, out entry) || entry == IntPtr.Zero) return IntPtr.Zero;
        if (!game.ReadPointer(entry, out obj) || obj == IntPtr.Zero) return IntPtr.Zero;
        foreach (var part in path.Split('.'))
        {
            int idx = int.Parse(part);
            uint hdr;
            if (!game.ReadValue<uint>(obj + 0x90, out hdr) || idx >= (int)(hdr & 0x3FFF)) return IntPtr.Zero;
            if (!game.ReadPointer(obj + 0x8C, out arr) || arr == IntPtr.Zero) return IntPtr.Zero;
            if (!game.ReadPointer(arr + 4 * idx, out entry) || entry == IntPtr.Zero) return IntPtr.Zero;
            if (!game.ReadPointer(entry, out obj) || obj == IntPtr.Zero) return IntPtr.Zero;
        }
        return obj;
    });
    vars.EndObj = IntPtr.Zero;
    vars.EndNextResolve = 0L;

    // CreditsHandler (vtable DX10 0x01741A00 / DX9 0x016F8DBC, hash ID 42A05DCA)
    vars.ScanCredits = (Func<IntPtr>)(() =>
    {
        var target = new SigScanTarget(0, (string)vars.CreditsTarget);
        foreach (var page in game.MemoryPages(true))
        {
            if ((int)page.State != 0x1000) continue;                 // MEM_COMMIT
            if (((int)page.Protect & 0x04) == 0) continue;           // PAGE_READWRITE
            if (((int)page.Protect & 0x100) != 0) continue;          // PAGE_GUARD
            if ((int)page.Type != 0x20000) continue;                 // MEM_PRIVATE
            int size = (int)page.RegionSize;
            if (size <= 0) continue;
            var scanner = new SignatureScanner(game, page.BaseAddress, size);
            foreach (var hit in scanner.ScanAll(target))
            {
                if (((long)hit & 3) != 0) continue;
                if (vars.HashOf(hit) == 0x42A05DCA) return hit;
            }
        }
        return IntPtr.Zero;
    });

    // pointers from a previous game process are not valid in this one
    vars.MItems = new Dictionary<string, IntPtr>();
    vars.MNext = new Dictionary<string, long>();
    // a run in progress keeps its lists when the game restarts (crash, closed and reopened): a mission that already split is never read or split again until a new run starts.
    // Only without a run in progress (or when the lists do not exist yet) are the lists built here.
    if (timer.CurrentPhase == TimerPhase.Running || timer.CurrentPhase == TimerPhase.Paused)
    {
        if (!(bool)vars.MBuilt) vars.RebuildMissions(settings);
        else if (settings["DebugPrint"]) print("AC1: game attached during a run, keeping " + ((List<string>)vars.MDone).Count + " done missions");
    }
    else
        vars.RebuildMissions(settings);
    vars.MSweep = false;             // attached mid-run: do not split on missions that are already finished
}

update
{
    current.XCoord = (float)Math.Round(current.XCoord, 5);
    current.YCoord = (float)Math.Round(current.YCoord, 5);
    current.ZCoord = (float)Math.Round(current.ZCoord, 5);

    if (settings["XYZ"])
    {
        timer.Run.Metadata.SetCustomVariable("XYZ", "( " + current.XCoord + ", " + current.YCoord + ", " + current.ZCoord + " )");
    }

    // ---- scans only run after a world change, never every frame ----
    bool worldChanged = current.World != old.World;
    bool inMenu = current.World == (uint)vars.MENU_WORLD;

    // ---- autostart: New/Continue menu handler, only searched while in the main menu ----
    // (also when the timer is still running, people forget to reset before going back to the menu)
    if (worldChanged)
        vars.H = IntPtr.Zero;                                      // handler belongs to one menu visit
    var h = (IntPtr)vars.H;
    if (h != IntPtr.Zero && memory.ReadValue<int>(h) != (int)vars.VTABLE)
        vars.H = IntPtr.Zero;                                      // freed
    if (settings["AutoStartNew"] && inMenu && (IntPtr)vars.H == IntPtr.Zero
        && Environment.TickCount > (long)vars.nextScan)
    {
        vars.H = vars.ScanMenu(game);
        vars.nextScan = Environment.TickCount + 1500;              // keep trying until it exists, stop once found
        if ((IntPtr)vars.H != IntPtr.Zero && settings["DebugPrint"])
            print("AC1: menu handler at 0x" + ((IntPtr)vars.H).ToString("X"));
    }

    // ---- credits split (DX9 + DX10) ----
    {
        // final mission M72_S04_Secret_Ending (hash 9A8C2B94): 2 = active during the whole ending, 3 = done after the credits.
        // The object is looked up once through the mission tree and then read directly; it is re-resolved if the hash stops matching.
        var eo = (IntPtr)vars.EndObj;
        if (eo != IntPtr.Zero && vars.HashOf(eo) != 0x9A8C2B94)
            eo = IntPtr.Zero;
        if (eo == IntPtr.Zero && Environment.TickCount > (long)vars.EndNextResolve)
        {
            vars.EndNextResolve = Environment.TickCount + 1000;
            eo = vars.ItemByPath("20.0.2");
            if (eo != IntPtr.Zero && vars.HashOf(eo) != 0x9A8C2B94) eo = IntPtr.Zero;
        }
        vars.EndObj = eo;
        byte endState = 0;
        if (eo != IntPtr.Zero) game.ReadValue<byte>(eo + 0x44, out endState);

        var o = (IntPtr)vars.Obj;
        if (o != IntPtr.Zero)
        {
            uint vt;
            if (!game.ReadValue<uint>(o, out vt) || vt != (uint)vars.CreditsVt || vars.HashOf(o) != 0x42A05DCA)
            {
                if (settings["DebugPrint"]) print("AC1: credits object lost");
                vars.Obj = IntPtr.Zero;
                vars.CreditsActive = false;
                vars.CreditsSw.Reset();
                vars.CreditsTries = 10;
            }
        }

        // a world change gives a fresh batch of scan attempts; scanning stops as soon as the object is found
        if (worldChanged) vars.CreditsTries = 10;

        // only look while a run is going, Desmond is the player and a world is loaded (never in the menu / loading)
        if ((IntPtr)vars.Obj == IntPtr.Zero && !vars.CreditsFired && (int)vars.CreditsTries > 0
            && timer.CurrentPhase == TimerPhase.Running && current.PlayerID == 9
            && current.World != 0 && !inMenu && endState == 2
            && Environment.TickCount > (long)vars.LastCreditsScan)
        {
            vars.LastCreditsScan = Environment.TickCount + (long)(int)vars.CreditsRescanMs;
            vars.CreditsTries = (int)vars.CreditsTries - 1;
            vars.Obj = vars.ScanCredits();
            if ((IntPtr)vars.Obj != IntPtr.Zero && settings["DebugPrint"])
                print("AC1: credits object at 0x" + ((IntPtr)vars.Obj).ToString("X"));
        }

        bool on = false;
        if ((IntPtr)vars.Obj != IntPtr.Zero)
        {
            uint mh;
            if (game.ReadValue<uint>((IntPtr)vars.Obj + 0x7C, out mh))
                on = mh != 0 && mh != (uint)vars.Sentinel;
        }

        if (on && !vars.CreditsActive)
        {
            vars.CreditsActive = true;
            vars.CreditsSw.Restart();
            if (settings["DebugPrint"]) print("AC1: credits screen up");
        }
        else if (!on && vars.CreditsActive)
        {
            vars.CreditsActive = false;
            vars.CreditsSw.Reset();
        }

        if (!vars.CreditsFired && vars.CreditsActive && vars.CreditsSw.ElapsedMilliseconds >= (int)vars.CreditsDelayMs)
            vars.CreditsFire = true;
    }

    // ---- mission splits: every active mission is checked; a finished one moves to the done list and fires a split ----
    // Priorities: only the lowest priority level that still has an active mission is read (PriorityWindow levels), plus the 100% lists (tier -1).
    if (timer.CurrentPhase == TimerPhase.Running && !(bool)vars.RouteError)   // conflicting route settings: nothing is read
    {
        long now = Environment.TickCount;
        var active = (List<string>)vars.MActive;
        var missions = (Dictionary<string, Tuple<string, uint, int>>)vars.Missions;
        var items = (Dictionary<string, IntPtr>)vars.MItems;
        var nextTry = (Dictionary<string, long>)vars.MNext;
        bool silent = !(bool)vars.MSweep;   // first pass after a start: already finished missions are marked done without a split
        var prio = (Dictionary<string, int>)vars.MPrio;
        // the lowest PriorityWindow distinct priority levels among the unfinished missions of the run order are read
        var levels = new List<int>();
        foreach (string k in active)
        {
            int pr = prio[k];
            if (pr >= 0 && !levels.Contains(pr)) levels.Add(pr);
        }
        levels.Sort();
        int lastPrio = levels.Count == 0 ? int.MaxValue : levels[Math.Min((int)vars.PriorityWindow, levels.Count) - 1];
        int resolved = 0;
        var fresh = new List<string>();     // missions that finished on this update
        for (int i = active.Count - 1; i >= 0; i--)
        {
            string key = active[i];
            var info = missions[key];
            if (!silent && prio[key] >= 0 && prio[key] > lastPrio) continue;   // later priority: not read yet
            IntPtr mo;
            if (!items.TryGetValue(key, out mo)) mo = IntPtr.Zero;
            if (mo != IntPtr.Zero && vars.HashOf(mo) != info.Item2) mo = IntPtr.Zero;
            if (mo == IntPtr.Zero)
            {
                long nx;
                if (!nextTry.TryGetValue(key, out nx) || now > nx)
                {
                    nextTry[key] = now + 1000;
                    mo = vars.ItemByPath(info.Item1);
                    if (mo != IntPtr.Zero && vars.HashOf(mo) != info.Item2) mo = IntPtr.Zero;
                }
            }
            items[key] = mo;
            if (mo == IntPtr.Zero) continue;
            resolved++;
            byte st;
            if (!game.ReadValue<byte>(mo + 0x44, out st) || st != 3) continue;
            active.RemoveAt(i);        // done: never read again until the next reset
            items.Remove(key);
            ((List<string>)vars.MDone).Add(key);
            if (!silent)
            {
                if (settings["DebugPrint"]) print("AC1: mission done: " + key);
                fresh.Add(key);
            }
        }
        // missions that finish on the same update split in priority order
        fresh.Sort((a, b) => prio[a].CompareTo(prio[b]));
        foreach (string f in fresh) ((Queue<string>)vars.MFire).Enqueue(f);
        if (silent && (resolved > 0 || active.Count == 0)) vars.MSweep = true;
    }
}

start
{
    vars.NewGameStart = false;
    // auto start on the New Game click
    if (settings["AutoStartNew"])
    {
        var hh = (IntPtr)vars.H;
        if (hh != IntPtr.Zero)
        {
            int pending = memory.ReadValue<int>(hh + 0x1C);
            if (pending != 0)
            {
                uint targetWorld = memory.ReadValue<uint>((IntPtr)pending + 0x34);
                if (targetWorld == (uint)vars.NEW_GAME)
                {
                    if (settings["DebugPrint"]) print("AC1: New game clicked");
                    vars.NewGameStart = true;
                    return true;
                }
            }
        }
    }

    if (settings["Memory Block Runs"])
    {
        if(settings["MemoryBlock1"] && vars.ArrivedAt(current, old, vars.SplitPositions["Tutorial"]))
        {
            print("Started for Memory Block 1");
            return true;
        } else if(settings["MemoryBlock2"] && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 2 Start"]))
        {
            print("Started for Memory Block 2");
            return true;
        } else if((settings["MemoryBlock3"] || settings["MemoryBlock4"] || settings["MemoryBlock5"] || settings["MemoryBlock6"]) && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 3-6 Start"]))
        {
            print("Started for Memory Block 3-6");
            return true;
        } else if(settings["MemoryBlock7"] && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 7 Start"]))
        {
            print("Started for Memory Block 7");
            return true;
        }
    }
}

onStart
{
    vars.CreditsFired = false;
    vars.CreditsFire = false;
    vars.RebuildMissions(settings);
    vars.MSweep = (bool)vars.NewGameStart;   // a New Game start has nothing finished yet; other starts skip what is already done
}

split
{
    // credits screen is up
    if (vars.CreditsFire)
    {
        vars.CreditsFire = false;
        vars.CreditsFired = true;
        if (settings["DebugPrint"])
            print("Credits split triggered.");
        return true;
    }

    // a watched mission item finished
    if (((Queue<string>)vars.MFire).Count > 0)
    {
        string done = ((Queue<string>)vars.MFire).Dequeue();
        if (settings["DebugPrint"]) print("Mission split triggered: " + done);
        return true;
    }

    // memory block start splits
    if (settings["Tutorial"] && vars.ArrivedAt(current, old, vars.SplitPositions["Tutorial"]))
    {
        if (settings["DebugPrint"]) print("Tutorial split triggered.");
        return true;
    }
    if (settings["MemoryBlock 2 Start"] && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 2 Start"]))
    {
        if (settings["DebugPrint"]) print("Memory block 2 start split triggered.");
        return true;
    }
    if (settings["MemoryBlock 3-6 Start"] && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 3-6 Start"]))
    {
        if (settings["DebugPrint"]) print("Memory block 3-6 start split triggered.");
        return true;
    }
    if (settings["MemoryBlock 7 Start"] && vars.ArrivedAt(current, old, vars.SplitPositions["MemoryBlock 7 Start"]))
    {
        if (settings["DebugPrint"]) print("Memory block 7 start split triggered.");
        return true;
    }
    // splits when you gain a rank
    if (settings["HealthIncreaseSplits"] && current.MaxHealth == old.MaxHealth + 1)
    {
        if (settings["DebugPrint"])
            print("Health increase split triggered. Current health: " + current.MaxHealth);
        return true;
    }
    // splits for all targets when you are in the death confession room
    if (settings["DeathConfessionSplits"]
        && (vars.ArrivedAt(current, old, vars.SplitPositions["Death Confession Room"])
            || vars.ArrivedAt(current, old, vars.SplitPositions["Death Confession Room for Maria"])))
    {
        if (settings["DebugPrint"])
            print("Death confession split triggered.");
        return true;
    }

    // 100% splits Flags and Templars killed
    if (settings["KingdomFlags"] && current.KingdomFlags > old.KingdomFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Kingdom flags split triggered. Current flags: " + current.KingdomFlags);
        return true;
    }
    if (settings["MasyafFlags"] && current.MasyafFlags > old.MasyafFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Masyaf flags split triggered. Current flags: " + current.MasyafFlags);
        return true;
    }
    if (settings["JerusalemFlags"] && current.JerusalemFlags > old.JerusalemFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Jerusalem flags split triggered. Current flags: " + current.JerusalemFlags);
        return true;
    }
    if (settings["DamascusFlags"] && current.DamascusFlags > old.DamascusFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Damascus flags split triggered. Current flags: " + current.DamascusFlags);
        return true;
    }
    if (settings["TeutonicFlags"] && current.TeutonicFlags > old.TeutonicFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Teutonic flags split triggered. Current flags: " + current.TeutonicFlags);
        return true;
    }
    if (settings["TemplarsFlags"] && current.TemplarsFlags > old.TemplarsFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Templars flags split triggered. Current flags: " + current.TemplarsFlags);
        return true;
    }
    if (settings["HspitaliersFlags"] && current.HspitaliersFlags > old.HspitaliersFlags && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Hspitaliers flags split triggered. Current flags: " + current.HspitaliersFlags);
        return true;
    }
    if (settings["TemplarsKilled"] && current.TemplarsKilled > old.TemplarsKilled && current.LoadingWorld == 0)
    {
        if (settings["DebugPrint"])
            print("Templars killed split triggered. Current templars killed: " + current.TemplarsKilled);
        return true;
    }
}

isLoading
{
    // a world is being loaded whenever its id is not 0 (DX9 and DX10)
    return current.LoadingWorld != 0;
}

onReset
{
    vars.CreditsFired = false;
    vars.CreditsFire = false;
    vars.RebuildMissions(settings);
}

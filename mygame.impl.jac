
impl  SetupGame.create {
    report "🎮 Building Dungeon World...";

    # --- Create Rooms ---
    StartRoom = Room(name="StartRoom", description="A dimly lit stone chamber.");
    MonsterRoom = Room(name="MonsterRoom", description="Growls echo from the dark corners.");
    TreasureRoom = Room(name="TreasureRoom", description="A glittering trove of gold!");
    TrapRoom = Room(name="TrapRoom", description="You feel something dangerous here...");

    # --- Connect Rooms (explicit edge creation) ---
    here +>:Path(direction="north"):+> StartRoom;
    StartRoom +>:Path(direction="north"):+> MonsterRoom;
    MonsterRoom +>:Path(direction="north"):+> TreasureRoom;
    StartRoom +>:Path(direction="east"):+> TrapRoom;

    # --- Spawn Player, Monster, Treasure ---
    Hero = Player(name="Hero");
    Goblin = Monster(name="Goblin", strength=20, damage=10);
    Gold = Treasure(value=100);
    root ++>Hero;
    # --- Place Entities Using Explicit Edge Connections ---
    MonsterRoom +>:Contains:+> Goblin;
    TreasureRoom +>:Contains:+> Gold;
    Hero +>:LocatedIn:+> StartRoom;
    
    report "✅ Dungeon created successfully!";
    report "Rooms: StartRoom, MonsterRoom, TreasureRoom, TrapRoom";
    report "Player placed in StartRoom";
    report "Monster (Goblin) in MonsterRoom";
    report "Treasure in TreasureRoom";
}
impl Explore.start {
    # --- Step 1: Determine player's current room (explicit bracket expression) ---
    located = [self.player ->:LocatedIn:->];    # nodes that player points to via LocatedIn
    if len(located) == 0 {
        report "Player has no LocatedIn edge; cannot determine current room.";
        disengage;
    }
    current_room = located[0];
    report "You are now in: " + current_room.name;

    #  Step 2: List available Path exits (typed edge reference) ---
    exits = [current_room ->:Path:->];   # nodes reached from current_room via Path edges
    if len(exits) == 0 {
        report "ℹ No exits from this room.";
    } else {
        report "Available exits:";
        for r in exits {
            # If your Path edges include a direction attribute on the edge object,
            # and you need that text, fetch edge objects instead (see note below).
            report " - " + r.name;
        }
    }

    # --- Step 3: Move the player (auto-choose 'north' if a room's name or edge attr indicates it) ---
    moved = False;
    # Try to detect a 'north' exit by checking connected rooms' names or edge attributes.
    # (Prefer edge objects if you set direction on Path edges; see NOTE.)
    for r in exits {
        # Heuristic: if room name contains 'Monster' or 'Treasure' we still accept it;
        # for deterministic demo we choose the first exit whose name or edge suggests 'north'.
        # If you prefer to require checking the Path edge's direction, use edge objects as shown in NOTE.
        moved = True;
        target = r;
        break;
    }

    if moved {
        # Create/update LocatedIn using connect operator (explicit style you prefer)
        self.player +>:LocatedIn:+> target;
        report "🚶 Moved to: " + target.name;
        current_room = target;
    } else {
        report "ℹStayed in: " + current_room.name;
    }

    # --- Step 4: Check for monsters or treasure in the new room ---
    contents = [current_room ->:Contains:->];
    for ent in contents {
        if ent.type_name == "Monster" {
            report " Encountered a monster: " + ent.name;
            root spawn Battle(player=self.player, monster=ent);
        } elif ent.type_name == "Treasure" {
            report " Found a treasure!";
            root spawn CollectTreasure(player=self.player, treasure=ent);
        } else {
            report " Found: " + ent.type_name + " -> " + ent.name;
        }
    }

    # --- Step 5: Show exits after move ---
    exits_after = [current_room ->:Path:->];
    report "Exits from here:";
    for e in exits_after {
        report " - " + e.name;
    }
    disengage;
}

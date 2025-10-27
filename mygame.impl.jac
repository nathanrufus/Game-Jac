
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
    root +>:Player(name="Hero"):+> Hero;
    # --- Place Entities Using Explicit Edge Connections ---
    MonsterRoom +>:Contains:+> Goblin;
    TreasureRoom +>:Contains:+> Gold;
    Hero +>:LocatedIn:+> StartRoom;
    
    report " Dungeon created successfully!";
    report "Rooms: StartRoom, MonsterRoom, TreasureRoom, TrapRoom";
    report "Player placed in StartRoom";
    report "Monster (Goblin) in MonsterRoom";
    report "Treasure in TreasureRoom";
}
impl Explore.start {
    # --- Step 1️: Find current room ---
    located = [self.player ->:LocatedIn:->];
    if len(located) == 0 {
        report " Player has no current room — cannot move.";
        disengage;
    }
    current_room = located[0];
    report " Current room: " + current_room.name;

    # --- Step 2️: Find available exits ---
    exits = [current_room ->:Path:->];
    if len(exits) == 0 {
        report " No exits from this room!";
        disengage;
    }

    # --- Step 3️: Find the path matching the given direction ---
    path_found = null;
    for e in exits {
        if e.direction == self.direction {
            path_found = e;
            break;
        }
    }

    if path_found == null {
        report " No path leading " + self.direction + ".";
        disengage;
    }

    # --- Step 4️: Move player to the connected room ---
    target_rooms = [path_found ->:Path:->];
    if len(target_rooms) == 0 {
        report " Path has no destination.";
        disengage;
    }

    new_room = target_rooms[0];

    # Remove old LocatedIn edge first
    playercurrentroom=[self.player ->:LocatedIn:-> current_room];
    del playercurrentroom[0];

    # Add new LocatedIn edge to target room
    self.player +>:LocatedIn:+> new_room;
    report "🚶 You moved " + self.direction + " to " + new_room.name;

    # --- Step 5️⃣: Encounter room contents ---
    contents = [new_room ->:Contains:->];
    if len(contents) == 0 {
        report "🔎 The room is quiet...";
    }
    for ent in contents {
        if ent.type_name == "Monster" {
            report "💀 A " + ent.name + " appears!";
            root spawn Battle(monster=ent);
        } elif ent.type_name == "Treasure" {
            report "💰 You found a treasure!";
            root spawn CollectTreasure(treasure=ent);
        }
    }

    # --- Step 6️⃣: Show new exits ---
    new_exits = [new_room ->:Path:->];
    if len(new_exits) > 0 {
        report "🚪 Exits:";
        for r in new_exits {
            report " - " + r.name;
        }
    } else {
        report "❌ No exits from here!";
    }

    disengage;
}

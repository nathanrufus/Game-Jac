
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

    # --- Place Entities Using Explicit Edge Connections ---
    MonsterRoom +>:Contains:+> Goblin;
    TreasureRoom +>:Contains:+> Gold;
    Hero +>:LocatedIn:+> StartRoom;

    # --- Summary ---
    report "✅ Dungeon created successfully!";
    report "Rooms: StartRoom, MonsterRoom, TreasureRoom, TrapRoom";
    report "Player placed in StartRoom";
    report "Monster (Goblin) in MonsterRoom";
    report "Treasure in TreasureRoom";
}
impl Explore.start {
    # Step 1: Get the player's current location (explicit traversal)
    # self.current_room = visit[self.player ->:LocatedIn:->][0];
    self.current_room=visit[root ->:LocatedIn:-> self.player][0]; 
    print("📍 You are now in: " + self.current_room.name);

    # Step 2: List available directions
    print("➡️  Available directions:");
    for next_path in visit[self.current_room ->:Path:->]:
        print(" - " + next_path.direction);

    # Step 3: Move player to the next room (auto choose 'north' for now)
    for next_room in visit[self.current_room ->:Path:->]:
        if next_room.direction == "north":
            print("🚶 Moving north...");
            self.current_room = next_room;
            disengage;

    # # Step 4: Update the player location
    # spawn edge::LocatedIn() from self.player to self.current_room;

    # # Step 5: Check what is inside the room
    # for entity in visit[self.current_room -[:Contains]->]:
    #     if entity.type_name == "Monster":
    #         print("⚔️ You encountered a monster!");
    #         spawn walker::Battle(player=self.player, monster=entity);
    #     elif entity.type_name == "Treasure":
    #         print("💰 You found a treasure!");
    #         spawn walker::CollectTreasure(player=self.player, treasure=entity);
    #     else:
    #         print("🪶 The room is empty...");

    # # Step 6: Show exits again
    # print("🚪 Exits from here:");
    # for path in visit[self.current_room -[:Path]->]:
    #     print(" - " + path.direction);
}


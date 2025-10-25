
node Room {
    has name: str;
    has description: str;
}

node Player {
    has name: str;
    has health: int = 100;
}

node Monster {
    has name: str;
    has strength: int = 20;
    has damage: int = 10;
}

node Treasure {
    has value: int = 100;
}

edge Path { has direction: str; }
edge Contains;
edge LocatedIn;

walker SetupGame {
    can create with `root entry;
}
walker Explore {
    has player: node;
    has current_room: node;

    can start with `root entry;
}



with entry {
    # Step 1: Run SetupGame first to build the world
    setup = root spawn SetupGame();
    setup.create;  # run its entry automatically

    # # Step 2: Retrieve player and starting room explicitly
    # player_node = None;
    # start_room = None;
    # contain= [root ->:Contains:-> ];
    # for n in contain {
    #     if n.name == "Hero" {
    #         player_node = n;
    #     }
    #     if n.name == "StartRoom" {
    #         start_room = n;
    #     }
    
    # # Step 3: Start exploring if both exist
    # if player_node != None and start_room != None {
    #     explorer = root spawn Explore(player=player_node, current_room=start_room);
    #     explorer.start;
    # } else {
    #     report "⚠️ Could not find player or start room.";
    # }
    # }
}




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
edge Contains{}
edge LocatedIn{}

walker SetupGame {
    can create with `root entry;
}
walker Explore {
    has player: node;
    has current_room: node;

    can start with `root entry;
}
walker Battle {
    has monster: node;

    can start with Player entry {
        # Announce combat
        report "⚔️ Combat begins between " + here.name + " and " + self.monster.name + "!";

        # Confirm both are in the same room (explicit bracket traversal)
        player_room_list = [here ->:LocatedIn:->];
        monster_room_list = [self.monster ->:LocatedIn:->];

        if (len(player_room_list) == 0 or len(monster_room_list) == 0) {
            report "⚠️ Cannot determine rooms for combat.";
            disengage;
        }

        player_room = player_room_list[0];
        monster_room = monster_room_list[0];

        if (player_room != monster_room) {
            report "❌ The monster is not in your room.";
            disengage;
        }

        # Randomized single-round exchange (you can loop for multiple rounds)
        p_hit = rand(1, 10);
        m_hit = rand(1, 10);

        if (p_hit > m_hit) {
            # Player wounds monster
            self.monster.strength = self.monster.strength - 6;
            report "💥 " + here.name + " hits " + self.monster.name + " (monster strength -> " + str(self.monster.strength) + ")";
        } else {
            # Monster wounds player
            here.health = here.health - 6;
            report "😵 " + self.monster.name + " hits " + here.name + " (player health -> " + str(here.health) + ")";
        }

        # Result handling
        if (self.monster.strength <= 0) {
            report "🏆 " + self.monster.name + " defeated!";
            # remove Contains edge from room to monster (disconnect)
            player_room= [self.monster ->:Contains:->] ;
            del player_room;
            # optionally destroy node: (if you use destroy syntax in your codebase)
            # destroy(self.monster);
        }

        if (here.health <= 0) {
            report "💀 " + here.name + " has fallen!";
        }

        # Ask CheckEnd to evaluate game end state
        here spawn CheckEnd;
        disengage;
    }
}


walker CollectTreasure {
    has treasure: node;

    can start with Player entry {
        report "💎 " + here.name + " sees: " + self.treasure.name + "!";
        # Mark collected
        self.treasure.collected = True;

        # Add to player's inventory (explicit concatenation)
        # If inventory list not defined, ensure Player node defines `inventory: list = []`
        here.inventory = here.inventory + [ self.treasure.name ];
        report "👜 Added " + self.treasure.name + " to " + here.name + "'s inventory.";

        # Trigger check for victory
        here spawn CheckEnd;
        disengage;
    }
}

walker Status {
    can start with Player entry {
        report "📊 Player Status";
        report "Name : " + here.name;
        report "Health: " + str(here.health);

        # Inventory
        if (len(here.inventory) > 0) {
            report "Inventory: " + ", ".join(here.inventory);
        } else {
            report "Inventory: (empty)";
        }

        # Current room and description
        room_list = [here ->:LocatedIn:->];
        if (len(room_list) > 0) {
            room = room_list[0];
            report "Location: " + room.name;
            report "Description: " + room.description;

            # Show path-connected rooms (names)
            exits = [room ->:Path:->];
            if (len(exits) > 0) {
                report "Exits:";
                for ex in exits {
                    report " - " + ex.name;
                }
            } else {
                report "No exits.";
            }
        } else {
            report "You are not located in any room.";
        }

        disengage;
    }
}

walker CheckEnd {
    can start with Player entry {
        # Defeat check
        if (here.health <= 0) {
            report "💀 GAME OVER — " + here.name + " has perished.";
            disengage;
        }

        # Victory check: look for any treasure names in inventory OR treasure.collected property
        for item in here.inventory {
            # If your treasure nodes use predictable names like "Gold" / "Treasure", adjust accordingly
            if ("Treasure" in item or "Gold" in item) {
                report "🎉 VICTORY — " + here.name + " secured the treasure: " + item;
                disengage;
            }
        }

        # Also check world nodes for collected treasure flag (alternative check)
        treasures = [root ->:Treasure:->];
        for t in treasures {
            if (t.collected == True) {
                report "🎉 VICTORY — Treasure was collected: " + t.name;
                disengage;
            }
        }

        # Otherwise continue
        report "🕹️ The adventure continues...";
        disengage;
    }
}

walker PlayGame {
    can start with Player entry {
        # Ask user for command
        report "👉 Command (move/status/quit): ";
        cmd = input();

        if cmd == "move" {
            report "Direction (north/east/south/west): ";
            dir = input();
            here spawn Explore(direction=dir);
        }
        elif cmd == "status" {
            here spawn Status;
        }
        elif cmd == "quit" {
            report "👋 Goodbye!";
            disengage;
        }
        else {
            report "⚠️ Unknown command.";
        }

        # Always check end conditions
        here spawn CheckEnd;

        # Continue game — recursively call itself
        here spawn PlayGame;
    }
}
walker FindPlayer {
    can start with root entry {
        # Try to find a Player node connected to root
        players = [root ->:Player:->];
        if len(players) == 0 {
            report "⚠️ No Player found. Creating a new one...";

            # Create and link a default Player
            player = Player(name="Hero");
            root +>:Player:+> player;

            report "✅ Player 'Hero' created and linked to root.";
        } else {
            player = players[0];
        }

        # Welcome and start the main game
        report "\n🧭 Welcome to the Dungeon Explorer!";
        report "🎮 Player: " + player.name;
        report "Commands: move / status / quit";

        # Start the main game walker
        player spawn PlayGame;
        disengage;
    }
}


with entry {
    root spawn SetupGame();

    root spawn FindPlayer();

}

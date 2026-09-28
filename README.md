# Full-stack-Procedural-Multiplayer-FPS-Game
A round-based 3D multiplayer first-person shooter built in Roblox Studio using Luau. The game pairs dynamic procedural maze generation with battle-royale survival mechanics: players inspect the map layout from above, drop into a procedurally generated maze, scavenge weapons/upgrades, and outrun a shrinking damage storm to be the last one standing.

---

## Technical & System Architecture

* **Procedural Maze Generation:** Map geometry is generated fresh every match using Kruskal's algorithm over a graph representation, ensuring no two rounds share the same layout or pathing.
* **Match Lifecycle & State Machine:** Server-side state machine orchestrates lobby queuing, overhead platform teleportation, a 10-second tactical reconnaissance phase, map drops, progressive storm radius reduction, and victory condition resolution.
* **Global Persistence:** Cross-server Top-100 player leaderboards synchronized across all running server instances using Roblox `DataStoreService`.
* **Lobby Ecosystem:** Non-combatants can spectate active matches, queue in the `Match Starting Area`, or practice in an offline/lobby training arena with all weapons unlocked.
* **Engine & Codebase Scope:** 140+ modular Luau scripts handling networking, UI state, damage verification, and world generation. Built from first principles with minimal external dependencies.

---

## Core Script Map & Code Pointers

Key architectural components located across `ServerScriptService`, `ReplicatedStorage`, and `StarterPlayerScripts`:

### World Generation
* [`/Scripts/Generator.luau`](/Scripts/Generator.luau) – Implementation of Kruskal's algorithm operating on a grid graph to generate maze walls, corridors, and structural variants dynamically.
* [`/Scripts/MazeStarterSettings.luau`](/Scripts/MazeStarterSettings.luau) – Module class defining maze dimensions, cell density, and structural parameters passed into `Generator` before each match start.

### Match Lifecycle & State Management
* [`/Scripts/MatchManager.luau`](/Scripts/MatchManager.luau) – Central server state controller. Manages match transitions, storm progression timings, active/remaining player counts, and win-condition checks.
* [`/Scripts/MatchStartingArea.luau`](/Scripts/MatchStartingArea.luau) – Handles lobby queue detection zones, player registration, and overhead platform teleportation logic.
* [`/Scripts/MatchStatsModule.luau`](/Scripts/MatchStatsModule.luau) – Data module tracking live in-game metrics for active combatants (kills, deaths, upgrades acquired, current session standings).

### Equipment, Loot & UI Systems
* [`/Scripts/LootScript.luau`](/Scripts/LootScript.luau) – Controls server-authoritative loot table distribution, weapon/upgrade spawning, and ground pickup interactions.
* [`/Scripts/ToolUI.luau`](/Scripts/ToolUI.luau) – Client-side interface controller handling player hotbars, weapon state transitions, and real-time inventory updates.
* [`/Scripts/BatClientScript.luau`](/Scripts/BatClientScript.luau) & [`/Scripts/BatServerScript.luau`](/Scripts/BatServerScript.luau) – Client/Server RPC pair implementing melee combat logic (baseball bat), handling local animation triggers, server-side hit validation, and damage application.

---

## Project Status

* **Current Stage:** Minimum Viable Product (MVP) complete and fully functional.
* **Codebase Scope:** 140+ custom Luau scripts handling the complete game loop, client UI, matchmaking, and persistence.
* **Repository Note:** As this project is intended for eventual commercial release, the full repository remains private. This folder contains a selection of core scripts demonstrating system architecture, networking, and key algorithmic implementations.

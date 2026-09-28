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
* **`Generator`** – Implementation of Kruskal's algorithm operating on a grid graph to generate maze walls, corridors, and structural variants dynamically.
* **`Maze starter settings`** – Module class defining maze dimensions, cell density, and structural parameters passed into `Generator` before each match start.

### Match Lifecycle & State Management
* **`Match Manager`** – Central server state controller. Manages match transitions, storm progression timings, active/remaining player counts, and win-condition checks.
* **`Match Starting Area`** – Handles lobby queue detection zones, player registration, and overhead platform teleportation logic.
* **`Match stats module`** – Data module tracking live in-game metrics for active combatants (kills, deaths, upgrades acquired, current session standings).

### Equipment, Loot & UI Systems
* **`Loot Script`** – Controls server-authoritative loot table distribution, weapon/upgrade spawning, and ground pickup interactions.
* **`Tool UI`** – Client-side interface controller handling player hotbars, weapon state transitions, and real-time inventory updates.
* **`Bad Server Script`** & **`Bad Client Script`** – Client/Server RPC pair implementing melee combat logic (baseball bat), handling local animation triggers, server-side hit validation, and damage application.

---

## Project Status

* **Current Stage:** Minimum Viable Product (MVP) complete and fully functional.
* **Codebase Scope:** 140+ custom Luau scripts handling the complete game loop, client UI, matchmaking, and persistence.
* **Repository Note:** As this project is intended for eventual commercial release, the full repository remains private. This folder contains a selection of core scripts demonstrating system architecture, networking, and key algorithmic implementations.

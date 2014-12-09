Introduction
============

- Relevance: importance of networking for Scala.js
- Motivation: Many JS APIs
    - Websocket
    - Comet
    - WebRtc
- Motivation: Many network programing models
    - Akka
    - RPC (type safe)
    - Steams (scalaz, akka-stream)
- Plan/Contributions


Transport
=========

- Scope: A unified, transparent interface to build upon.
- No magic.

### The interface:

    trait Transport {}
    trait ConnectionHandle {}

### Implementations

- js (WebSocket client, SockJS client, WebRtc client)
- netty (WebSocket server, SockJS server (next netty))
- tyrus (WebSocket client)
- play (WebSocket client, SockJS client (plugin))

### Wrappers

- Works fine with the raw api
- Akka
- Autowire (RPC)

### Testing infrastructure

- Two configurable browsers


Example: A Cross-platform Multiplayer Game
==========================================

- Goal: Cross platform JS/JVM realtime mutiplayer game
- History: Scala.js port of a JS port of a Commodore 64 game

### Architecture

- Purely functional multiplayer game engine
- Clock synked, same game simulated on both platforms
- Requires: initialState, nextState, render, transport
- Result: Immutability everywhere
- Result: everything but input handler & UI is shared

### Compensate Network Latency

- Traditional solutions (actual lag, fixed delay with animation)
- Solution: go back in time (Figure)
- Scala List and Ref quality and fixed size buffer solution

### Implementation

- React UI (& hack for the JVM version)
- Simple Server for matchmaking
- WebRtc with SockJS fallback
- Results: 60FPS on both platforms, lag free gameplay
- Results: Lag Compensation in action (Screenshots)


Related Work
============

- Js/NodeJs
- Closure
- Steam Engine/AoE/Sc2/Google docs


Conclusion and Future Work
==========================

- Web workers
- scalaz-stream/akka-stream wrappers
- More utilities on top of Transport

@Gil

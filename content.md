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


\newpage

Transport
=========

* This section, scala-js-transport library, main contribution

### The interface:

In order to unify different means of communication, we begin by the definition of unique interface for asynchronous transports. This interface aims at *transparently* modeling the different underlying implementations, meaning it is not meant to add functionalities but rather to delegate its tasks to the underlying transport.

\lstinputlisting{../transport/transport/shared/transport/Transport.cache}

interface to build upon.

### Implementations

- js (WebSocket client, SockJS client, WebRtc client)
- netty (WebSocket server, SockJS server (next netty))
- tyrus (WebSocket client)
- play (WebSocket client, SockJS client (plugin))

### Wrappers

- Works fine with the raw api
- Akka
- Autowire (RPC)

### Going further

- Testing infrastructure
- Two configurable browsers


\newpage

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


\newpage

Related Work
============

- Js/NodeJs, relies on duck typing
- Closure
- Steam Engine/AoE/Sc2/Google docs


\newpage

Conclusion and Future Work
==========================

- Web workers
- scalaz-stream/akka-stream wrappers
- More utilities on top of Transport

@Gil

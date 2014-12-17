Introduction
============

- Relevance: importance of networking for Scala.js
- Motivation: Many JS APIs
    - Websocket
    - Comet
    - WebRTC
- Motivation: Many network programing models
    - Akka
    - RPC (type safe)
    - Steams (scalaz, akka-stream)
- Plan/Contributions


\newpage

Transport
=========

* This section, scala-js-transport library, main contribution

### A Uniform Interface

We begin our discussion by the definition of an interface for asynchronous transports, presented in #transportInterface. This interface aims at *transparently* modeling the different underlying technologies, meaning that is simply delegates tasks to the actual implementation, without adding new functionalities.

\transportInterface{Definition of the core networking interfaces.}

A *Transport* can both *listen* for incoming connections and *connect* to remote *Transports*. Platforms limited to act either as client or server will return a failed future for either of these methods. In order to listen for incoming connections, the user of a *Transport* has to complete the promise returned by the listen method with a *ConnectionListener*. To keep the definition generic, *Address* is an abstract type. As we will see later, it varies greatly from one technology to another.

*ConnectionHandle* represents an opened connection. Thereby, it supports four type of interactions: writing a message, listening for incoming messages, closing the connection and listening for connection closure. Similarly to *Transport*, listening for incoming messages is achieved by completing a promise of *MessageListener*.

The presented *Transport* and *ConnectionHandle* interfaces have several advantages compared to their  alternative in other languages, such the WebSocket interface in JavaScript. For example, errors are not transmitted by throwing exceptions, but simply returned as a failed future. Also, some incorrect behaviors such as writing to a no yet opened connection, or receiving duplicate notifications for a closed connection, are made impossible by construction. Thanks to support of futures and promises in Scala.js, these interfaces cross compile to both Java bytecode and JavaScript.

### Implementations

The scala-js-transport library contains several implementations of *Transports* for WebSocket, SockJS and WebRTC. This subsection briefly presents the different technologies and their respective advantages. #impl-summary summarizes the available *Transports* for each platform and technology.

Table: Summary of the available Transports.\label{impl-summary}

Platform        WebSocket   SockJS   WebRTC
-------------- ----------- -------- --------
JavaScript       client     client   client    
Play Framework   server     server     -     
Netty            both          -       -      
Tyrus            client        -       -      

###### WebSocket
WebSocket provides full-duplex communication over a single TCP connection. 

Connection establishment begin with an HTTP request from client to server. After the handshake is completed, the TCP connection used for the initial HTTP request is *upgraded* to change protocol, and kept open to become the actual WebSocket connection. This mechanism allows WebSocket to be wildly supported over different network configurations.

WebSocket is also well supported across different platforms. Our library provides four WebSocket *Transports*, a native JavaScript client, a Play Framework server, a Netty client/server and a Tyrus client. While having all three Play, Netty and Tyrus might seem redundant, each of them comes with its own advantages. Play is a complete web framework, suitable to build every component of a web application. Play is based on Netty, which means that for a standalone WebSocket server, using Netty directly leads to better performances and less dependencies. Regarding client side, the Tyrus library offers a standalone WebSocket client which is lightweight compared to the Netty framework.

###### SockJS
SockJS is a WebSocket emulation protocol which fallbacks to different protocols when WebSocket is not supported. Is supports a large number of techniques to emulate the sending of messages from server to client, such as AJAX long polling, AJAX streaming, EventSource and streaming content by slowly loading an HTML file in an iframe. These techniques are based on the following idea: by issuing a regular HTTP request from client to server, and voluntarily delaying the response from the server, the server side can decide when to release information. This allows to emulate the sending of messages from server to client which not supported in the traditional request-response communication model.

The scala-js-transport library provides a *Transport* build on the official SockJS JavaScript client, and a server on the Play Framework via a community plugin @play2-sockjs. Netty developers have scheduled SockJS support for the next major release.

###### WebRTC
WebRTC is an experimental API for peer to peer communication between web browsers. Initially targeted at audio and video communication, WebRTC also provides *Data Channels* to communicate arbitrary data. Contrary to WebSocket only supports TCP, WebRTC can be configures to use either TCP, UDP or SCTP.

As opposed to WebSocket and SockJS which only need a URL to establish a connection, WebRTC requires a *signaling channel* in order to open the peer to peer connection. The *signaling channel* is not tight to a particular technology, its only requirement is to allow a back an forth communication between peers. This is commonly achieved by connecting both peers via WebSocket to a server, which then serves as a relay for the WebRTC connection establishment.

To simplify the process of relaying messages from one peer to another, our library uses picklers for *ConnectionHandle*. Concretely, when a *ConnectionHandle* object connecting node *A* and *B* is sent by *B* over an already established connection with *C*, the *ConnectionHandle* received by *C* will act as a connection between *A* and *C*, hiding the fact that *B* relays messages between the two nodes.

At the time of writing, WebRTC is implemented is Chrome, Firefox and Opera, and lakes support in Safari and Internet Explorer. The only non browser implementations are available on the node.js platform.

### Wrappers

By using *Transport* interface, it is possible write programs with an abstract communication medium. We present two *Transport* wrappers, for Akka @akka and Autowire\ @autowire, which allow to work with different model of concurrency. Because Autowire and Akka (via @scala-js-actors) can both be used on the JVM and on JavaScript, these wrappers can be used to build cross compiling programs compatible with all the *Transport* implementations presented in #implementations.

###### Akka
The actor model is based on asynchronous message passing between primitive entities called actors. Featuring both location transparency and fault tolerance via supervision, the actor model is particularly adapted to distributed environment. Akka, a toolkit build around the actor model for the JVM, was partly ported to Scala.js by S. Doeraene in @scala-js-actors. The communication interface implemented in @scala-js-actors was revisited into the *Transport* wrapper presented in #actorWrapper.

\actorWrapper{Transport wrappers to handle connections with actors.}

The two methods *acceptWithActor* and *connectWithActor* use the underlying *listen* and *connect* methods of the wrapped *Transport*, and create an *handler* actor to handle the connection. The semantic is as follows: the *handler* actor is given an *ActorRef* in it is constructor, to which sending messages results in sending outgoing messages thought the connection, and messages received by the *handler* actor are incoming messages received from the connection. Furthermore, the life span of an *handler* actor is tight to life span of its connection, meaning that the *preStart* and *postStop* hooks can be used to detect the creation and the termination of the connection, and killing the *handler* actor results in closing the connection. #yellingActor shows an example of a simple *handler* actor which than sending back whatever it receives in uppercase.

\yellingActor{Example of a connection handling actor.}

Thanks to the picking mechanism developed in @scala-js-actors, it is possible to sent messages of any type thought a connection, given that implicit picklers are available for these types of messages. Out of the box, picklers for case classes and case objects can be macros-generated by the pickling library. In addition, an *ActorRef* pickler allows the transmission of *ActorRefs* thought a connection, making them transparently usable from the side of the connection as if they were references to local actors.

###### Autowire
Remote procedure call allow remote systems to communicate through an interface similar to method calls. The Autowire library allows to perform type-safe, reflection-free remote procedure calls between Scala system. It uses macros and is agnostic of both the transport-mechanism and the serialization library.

The scala-js-transport library offers a *RpcWrapper*, which makes internal use of Autowire to provide remote provide call on top of any of the available *Transports*. Because the *Transport* interface communicates with *Strings*, the *RpcWrapper* is able to set all the type parameters of Autowire, as well embedding the uPickle serialization library @upickle, thus trading flexibility to reduce boilerplate. #rpcExample shows a complete remote procedure call implementation on top of WebSocket.

\rpcExample{Example of remote procedure call implementation.}

The main strength of remote procedure calls are their simplicity and type-safety. Indeed, because of how similar remote procedure calls are to actual method calls, they can be used without any learning curve, and consistency between client and server side is can be verified by the compiler. However, this simplicity also comes with some draw backs. Contrary to the actor model which can be used to explicitly model the life span of connections, and different types of failures, there are no such things build in when using remote procedure calls. In order to implement a fine grain error detection and recovery mechanism on top of recovery procedure calls, one would have to work at a lower lever than the one offered by the model it self, which is with the *Transport* interface in our case.

### Going further

The different *Transport* implementations and wrappers presented is this section allows for several interesting combinations. Because the scala-js-transport library is built with a central communication interface (presented in #a-uniform-interface), it is easily expendable in both directions. Indeed, any new implementation of the *Transport* interface with a different underlaying technologies would immediately be usable with the different wrappers. Analogously, any new wrapper on top of the *Transport* interface would automatically be compatible with the variety of available implementations.

All the implementations and wrappers are accompanied by integration tests. In most cases, these tests are built using the *Selenium WebDriver* included in the Play Framework test tools, which allow to access proper behavior of the library using real web browsers. Our tests for WebRTC include an extension of the default Play test tools to use two browsers on a single test. The tests can then be configures to run with two different browsers, such as Chrome and Firefox, to test their compatibility.


Lag Compensation Framework
==========================

- Why do we need this
- Google Docs
- Goal: Cross platform JS/JVM realtime lag compensation framework

### Compensate Network Latency

- Traditional solutions (actual lag, fixed delay with animation)
- Solution: go back in time (Figure)
- Clock synked, same game simulated on both platforms

### Architecture

- Requires: initialState, nextState, render, transport
- Immutability everywhere
- Scala List and Ref quality and fixed size buffer solution


\newpage

Example: A Real Time Multi-player Game
======================================

- History: Scala.js port of a JS port of a Commodore 64 game

### Functional User Interface

- React UI
- React
- Hack for the JVM version)

### Functional User Interface

- React UI
- React
- Hack for the JVM version)

### Result

- Everything but input handler shared (but UI shouldn't...)
- WebRTC with SockJS fallback
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

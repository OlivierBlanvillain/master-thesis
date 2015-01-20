# This Presentation

1. Transport library

2. Latency compensation framework

3. Example: online multiplayer game

# Motivation

- Many JavaScript APIs

- Many network programming models

- Goal: cross platform networking

#
\ 

\centering\Huge\sc
Diving in...

#
    4~2~1~trait Transport~ {
      type Address
      def listen(): Future[Promise[ConnectionListener]]
      def connect(remote: Address): Future[ConnectionHandle]
      def shutdown(): Future[Unit]
    }~
    3~1~trait ConnectionHandle~ {
      def handlerPromise: Promise[MessageListener]
      def write(message: String): Unit
      def closedFuture: Future[Unit]
      def close(): Unit
    }~
    2~type ConnectionListener = ConnectionHandle => Unit~
    3~type MessageListener = String => Unit~~

# Client Example
    4~2~1~val transport = new WebSocketClient()
    val url = WebSocketUrl("ws://echo.websocket.org")~
    
    val futureConnection = transport.connect(url)
    futureConnection.onSuccess { case connection =>~
      3~connection.write("Hello WebSocket!")
      connection.handlerPromise.success { message =>
        print("Received: " + message)
        connection.close()
      }~
    2~}~~

# Server Example
    5~2~1~val transport = new WebSocketServer(8080, "/ws")~
    try {
      3~transport.listen()~~3~.foreach { _.success { connection =>~
        4~connection.handlerPromise.success { message =>
          connection.write(message)
        }~
      3~}}~
    2~} finally transport.shutdown()~~

# Targeted Technologies

- WebSocket

- SockJS

- WebRTC

# WebSocket

- Bidirectional client-server communication

- Handshake = HTTP upgrade request

- Long lived TCP

# WebSocket Support, caniuse.com

\includegraphics{ciu-websocket}
\medskip

\centering
Availability: ~84%

# SockJS

- WebSocket emulation, same API

- Fallbacks to HTTP requests + long polling

- Supports sticky sessions

- Well defined protocol, standard test suite

# SockJS, Supported Transports

\includegraphics{sockjs-table.pdf}

# WebRTC

- Peer to peer

- Made for Video, Audio and Data

- Supports TCP, UDP and SCTP

- RTC = Real Time Communication

# WebRTC Connection Establishment

- Requires a signaling channel

- Typically thought a relay server

-       1~class WebRTCClient extends Transport {
          type Address = ConnectionHandle
          ...
        }~

# WebRTC Support, caniuse.com

\includegraphics{ciu-webrtc}
\medskip

\centering
Availability: ~54%

# Transport Implementations

Platform        WebSocket   SockJS   WebRTC
----------     ----------- -------- --------
JavaScript      client      client   client
Play Framework  server      server   -
Netty           both        -        -
Tyrus           client      -        -

#
\Huge\sc
Network
Programming
Abstractions

# The Actor Model

- Akka on the JVM

- scala-js-actors on the browser

- Let's do everything with actors!

# Actor Transport Wrapper
    2~1~class ActorWrapper[T <: Transport](t: T) {~
      type Handler = ActorRef => Props
      def acceptWithActor(handler: Handler): Unit
      def connectWithActor(
          address: t.Address)(handler: Handler): Unit
    1~}~~

# Connection Handling Actor
    3~1~class YellingActor(2~out: ActorRef~) extends Actor {
      override def preStart = println("Connected")
      override def postStop = println("Disconnected")~
      2~def receive = {
        case message: String =>
          println("Received: " + message)
          out ! message.toUpperCase
      }~
    1~}~~

# Remote Procedure Calls

- Wrapper around Autowire

- Future based RPC

- Agnostic of the serialization library

#
    4~1~trait Api {
      3~def doThing(i: Int, s: String): Seq[String]~
    }~
      
    2~object Server extends Api {
      def doThing(i: Int, s: String) = Seq.fill(i)(s)
    }
    val transport = new WebSocketServer(8080, "/ws")
    new MyRpcWrapper(transport).serve(_.route[Api](Server))~
      
    3~val transport = new WebSocketClient()
    val url = WebSocketUrl("ws://localhost:8080/ws")
    val client = new MyRpcWrapper(transport).connect(url)
    val result: Future[Seq[String]] =
        client[Api].doThing(3, "ha").call()~~


#
\Huge\sc
Latency
Compensation

#
\vspace{-1pt}\noindent\makebox[\columnwidth]{\includegraphics[width=1.333\paperwidth]{living-with-lag}}

#
\bigskip\Large
Let's see how [Google Docs](https://docs.google.com/document/d/1iO8Jx-0M8-ZTwxzmK_SwjGScgN42XuIxt5fhpbM5Nao/edit#) does it!

    1~
      sudo tc qdisc add dev eth0 root netem delay 3000ms
      sudo tc qdisc del dev eth0 root netem~

#
\bigskip\centering\caslon\small
\psscalebox{0.8 0.8}{\input{state-graph.tex}}
<!-- http://tex.stackexchange.com/questions/96418/beamer-pause-and-grey-not-in-order -->

# Latency Compensation Framework

- Predictive algorithm

- Peer to peer

- Zero input latency

- Eventual consistency

# Functional interface

    4~1~case class Action[Input](input: Input, peer: Peer)
     
    2~class Engine[Input, State]~~2~(
        initState: State,
        nextState: (State, Set[Action[Input]]) => State,
        render: State => Unit,
        broadcastConnection: ConnectionHandle) {~
      
      3~def triggerRendering(): Unit
      def futureAct: Future[Input => Unit]~
    2~}~~

#
\bigskip\centering\caslon\small
\psscalebox{0.8 0.8}{\input{../report/figures/lagcomp-engine.tex}}

# StateLoop Implementation

todo...
  
#
\vspace{-1pt}\noindent\makebox[\columnwidth]{\includegraphics[width=0.54\paperwidth]{survivor}}

# Demo

- Cross platform

- WebRTC

- [Online](http://olivierblanvillain.github.io/survivor/)

# React

- Re-render the whole application every frame

-       1~def render(state: State): Html~

- Divided into Components

- Virtual DOM diff algorithm

#
\bigskip\centering\Huge\sc
Thanks!

<!-- #
\ 

\centering\Huge\sc
Bonus Slides

# WebRTC connection establishment
    4~1~2~val webSocketClient = new WebSocketClient()~
    3~val webRTCClient = new WebRTCClient()~
    2~val relayURL = WebSocketUrl("ws://localhost:8080/ws")~~

    2~3~val signalingChannel: Future[ConnectionHandle]~ =
      webSocketClient.connect(relayURL)~

    3~val p2pConnection: Future[ConnectionHandle] =
      signalingChannel.flatMap(webRTCClient.connect(_))~~

 -->

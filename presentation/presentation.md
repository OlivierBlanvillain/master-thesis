# This Presentation

1. Transport library

2. Latency compensation framework

3. Example: online multiplayer game

# Motivation

- Share

- Many JavaScript APIs

- Many network programming models

#
\ 

\centering\Huge
Diving in...

#
    124~trait Transport~ 24~{
      type Address
      def listen(): Future[Promise[ConnectionListener]]
      def connect(remote: Address): Future[ConnectionHandle]
      def shutdown(): Future[Unit]
    }~
    134~trait ConnectionHandle~ 34~{
      def handlerPromise: Promise[MessageListener]
      def write(message: String): Unit
      def closedFuture: Future[Unit]
      def close(): Unit
    }~
    24~type ConnectionListener = ConnectionHandle => Unit~
    34~type MessageListener = String => Unit~

# Targeted Technologies

- WebSocket

- SockJS

- WebRTC

# WebSocket

- Introduction

# WebSocket Support

\centering
\includegraphics[width=\linewidth]{ciu-websocket}
\medskip

Availability: ~84%

# SockJS

- Introduction

# SockJS, Supported Transports

\includegraphics[width=\linewidth]{sockjs-table.pdf}

# WebRTC

- Introduction

# WebRTC Support

\centering
\includegraphics[width=\linewidth]{ciu-webrtc}
\medskip

Availability: ~54%

# Transport Implementations

Platform        WebSocket   SockJS   WebRTC
----------     ----------- -------- --------
JavaScript      client      client   client
Play Framework  server      server   -
Netty           both        -        -
Tyrus           client      -        -

#
\ 

\centering\Huge\sc
Thanks!

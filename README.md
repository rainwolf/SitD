# SitD
An iOS client to exchange Pond messages.

**!! This is a toy (for now) !!**

You can exchange messages with other Pond clients, but,
- not files (yet),
- no PANDA, only manual key exchange (and iPhone-to-iPhone key exchange) is supported,
- no older clients (only the new ratchet is supported),
- the p2p key exchange needs to be looked at (in terms of security) but works,
- ... a bunch of other things that I missed.

This wouldn't have been possible without
- [Pond](https://github.com/agl/pond)
- [CPAProxy](https://github.com/ursachec/CPAProxy)
- [YapDatabase](https://github.com/yapstudios/YapDatabase)
- [ProxyKit](https://github.com/chrisballinger/ProxyKit)
- [TSMessages](https://github.com/KrauseFx/TSMessages)
- [Popoverview](https://github.com/runway20/PopoverView)
- [Protobuf](https://github.com/google/protobuf)

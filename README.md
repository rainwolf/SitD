# SitD
An iOS client to exchange Pond messages.

**!! This is a toy (for now) !!**

You can exchange messages with other Pond clients, but,
- not files (yet),
- no PANDA, only manual key exchange (and iPhone-to-iPhone key exchange) is supported,
- no older clients (only the new ratchet is supported),
- the p2p key exchange needs to be looked at (in terms of security) but works,
- ... a bunch of other things that I missed.

## features

- This app allows multiple identities, each with a different database protected by a password, the databases are protected by SQLCipher. In theory, you could allow a friend use the app with his own password, and if you don't know their password, you don't have access to that identity and messages. Plausible deniability.
- Key exchange can be repeated, together with P2P key exchange, this makes a great countermeasure against an adversary who can solve the discrete logarithm problem.

This wouldn't have been possible without
- [Pond](https://github.com/agl/pond)
- [CPAProxy](https://github.com/ursachec/CPAProxy)
- [YapDatabase](https://github.com/yapstudios/YapDatabase)
- [ProxyKit](https://github.com/chrisballinger/ProxyKit)
- [TSMessages](https://github.com/KrauseFx/TSMessages)
- [Popoverview](https://github.com/runway20/PopoverView)
- [Protobuf](https://github.com/google/protobuf)

License
=======
I'm licensing it under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
until I find a better alternative.

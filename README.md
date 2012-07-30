# Impersonator - Your IRC Doppelgänger #

Impersonator is a [Cinch](http://github.com/cinchrb/cinch)-based IRC bot that can speak for you, as you.

## Installation ##

To get started, install with:

    gem install impersonator

## Configuration ##

Once installed, create a config file in ~/.impersonator.yml (or wherever you want it). An example config file:

    nick: tom
    channels:
      - "#tom-bots"
    server: asimov.freenode.net
    port: 6665
    ssl: true
    password: 
    logs: /var/log/bip/log/freenode
    blacklist:
      - mybot
    keywords:
      - tom
      - tom-bot
    weights:
      speak_nick: 3
      speak_channel: 3
      speak_private: 1

## Usage ##

Run with the `impersonator` command:

    $ impersonator

## Logs and Personality ##

Impersonator is tailored to [bip](http://bip.milkypond.org)-style IRC logs, but you can modify it to use just about any kind of log format.

## TODO ##

Right now, Impersonator uses grep to establish its personality (read: to build a markov representation of your IRC logs). This isn't terrible in and of itself. Doing so on-demand, without caching is, well, terrible. That will change. Soon.

## Author ##

tom metge <tom@metge.us>

he's an awesome guy

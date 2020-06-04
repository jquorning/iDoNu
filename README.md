
# WeDoNu - We Do Nu
Collaborative activity management tool

## Status
* Stable
* Somewhat raw interaction
* Many errors

## Features
1. Command line editing
1. Web editing on port 8080

## Dependencys
* AWS - Ada Web Server
* SQLite3 - Simple Components by D. Kazakow
* readline - GNATColl.Readline

## Configuring
```sh
$ ed var/PROGRAM_VERSION
$ ed var/PROGRAM_NAME
```

## Building
```sh
$ make
```

or

```sh
$ gprbuild wedonu.gpr
```

## Running
```sh
$ cd var/
$ ../binary/wedonu
```

## Files
to-do-it.wedonu
   Database (backup). Den aktuelle ligger Work/etc/to-do-it.todoit

bin/wedonu
   Executable





# rescript-event-store
event-store-gateway abstract module for rescript


## API

#### EventGateway.resi
```rescript
module type Event = {
  type event

  let parseUnknown: unknown => option<event>
}

module type EventGateway = {
  type event

  let createTableIfNotExist: unit => result<unit, exn>
  let dropTableIfExist: unit => result<unit, exn>
  let getEvents: (int, option<int>) => result<array<event>, exn>
  let insertEvents: array<event> => result<unit, exn>
}
```

#### JsonRecordEventGateway.resi
```rescript
open EventGateway

module type JsonRecordConf = {
  let fileName: string
}

module type MakeJsonRecordEventGateway = (Event: Event, JsonRecordConf: JsonRecordConf) =>
(EventGateway with type event = Event.event)

module MakeJsonRecordEventGateway: MakeJsonRecordEventGateway
```


## Author
Anatoly Starodubtsev
tostar74@mail.ru


## License
MIT
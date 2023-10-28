# rescript-event-store
event-store-gateway abstract module for rescript


## API

#### EventGateway.resi
```rescript
module type Event = {
  type event

  let parseUnknown: unknown => option<event>
}

type eventRecord<'e> = {
  id: int,
  val: 'e,
  timestamp: float,
}

module type EventGateway = {
  type event

  let createTableIfNotExist: unit => result<unit, exn>
  let dropTableIfExist: unit => result<unit, exn>
  let getEvents: (int, option<int>, option<float>) => result<array<eventRecord<event>>, exn>
  let insertEvent: event => result<int, exn>
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
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

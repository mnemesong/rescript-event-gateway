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

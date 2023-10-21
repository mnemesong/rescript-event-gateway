module type Event = {
  type event

  let parseUnknown: unknown => option<event>
}

module type EventGateway = {
  type event

  let createTableIfNotExist: unit => result<unit, string>
  let dropTableIfExist: unit => result<unit, string>
  let getEvents: (int, option<int>) => result<array<event>, string>
  let insertEvents: array<event> => result<unit, string>
}

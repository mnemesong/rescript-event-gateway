open EventGateway

module type JsonRecordConf = {
  let fileName: string
}

module type MakeJsonRecordEventGateway = (Event: Event, JsonRecordConf: JsonRecordConf) =>
(EventGateway with type event = Event.event)

module MakeJsonRecordEventGateway: MakeJsonRecordEventGateway

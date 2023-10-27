open JsonRecordEventGateway
open EventGateway
open Belt

%%raw(`
let path = require('path');
`)

let filePath: string = %raw(`path.resolve(module.path, '..', '..', '..', '..', 'test.json')`)

type event = [
  | #event1
  | #event2
]

module type TestEvent = Event with type event = event

module TestEvent: TestEvent = {
  type event = event

  let parseUnknown: unknown => option<event> = %raw(`
  function (u) {
    return ((u === 'event1') || (u === 'event2'))
      ? u
      : undefined;
  }
  `)
}

module TestJsonRecordConf: JsonRecordConf = {
  let fileName: string = filePath
}

module TestJsonRecordEventGateway = MakeJsonRecordEventGateway(TestEvent, TestJsonRecordConf)

Ok()
->Result.flatMap(() => TestJsonRecordEventGateway.createTableIfNotExist())
->Result.flatMap(() => TestJsonRecordEventGateway.insertEvents([#event1, #event2, #event1]))
->Result.flatMap(() => TestJsonRecordEventGateway.getEvents(0, None)->Result.map(Js.Console.log))
->Result.map(() => Js.Console.log("---"))
->Result.flatMap(() => TestJsonRecordEventGateway.getEvents(1, Some(1))->Result.map(Js.Console.log))
->Result.flatMap(() => TestJsonRecordEventGateway.dropTableIfExist())
->Js.Console.log

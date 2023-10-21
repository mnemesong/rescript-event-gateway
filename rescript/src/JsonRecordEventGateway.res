open EventGateway
open Belt

%%raw(`
const JsonRecords = require('json-records');
const fs = require('fs');
`)

module type JsonRecordConf = {
  let fileName: string
}

module type MakeJsonRecordEventGateway = (Event: Event, JsonRecordConf: JsonRecordConf) =>
(EventGateway with type event = Event.event)

module MakeJsonRecordEventGateway: MakeJsonRecordEventGateway = (
  Event: Event,
  JsonRecordConf: JsonRecordConf,
) => {
  type event = Event.event

  let createTableIfNotExist: unit => result<unit, string> = () =>
    try {
      let createFile: string => unit = %raw(`
    function (path) {
      fs.writeFileSync(path, '{}');
    }
    `)
      createFile(JsonRecordConf.fileName)
      Ok()
    } catch {
    | Js.Exn.Error(e) => Error(e->Js.Exn.message->Option.getWithDefault(""))
    | _ => Error("Unknown error")
    }

  let dropTableIfExist: unit => result<unit, string> = () =>
    try {
      let dropFile: string => unit = %raw(`
      function (path) {
        fs.unlinkSync(path);
      }
      `)
      dropFile(JsonRecordConf.fileName)
      Ok()
    } catch {
    | Js.Exn.Error(e) => Error(e->Js.Exn.message->Option.getWithDefault(""))
    | _ => Error("Unknown error")
    }

  let getEvents = (from: int, limit: option<int>): result<array<event>, string> =>
    try {
      let getResult: (string, int, option<int>, unknown => option<event>) => array<event> = %raw(`
    function (path, from, limit, parseFunc) {
      const jr = new JsonRecords(path);
      const result = jr
        .get( r => (limit ? ((r.id >= from) && (r.id < from + limit)) : (r.id >= from)))
      return result.map(r => {
        if((!r.id) || (!r.val)) {
          throw new Error("result is not event record: " + JSON.stringify(r));
        }
        const parseResult = parseFunc(r.val);
        if(!parseResult) { 
          throw new Error("event is not valid: " + JSON.stringify(r));
        }
        return parseResult;
      });
    }
    `)
      Ok(getResult(JsonRecordConf.fileName, from, limit, Event.parseUnknown))
    } catch {
    | Js.Exn.Error(e) => Error(e->Js.Exn.message->Option.getWithDefault(""))
    | _ => Error("Unknown error")
    }

  let insertEvents = (events: array<event>): result<unit, string> =>
    try {
      let state = getEvents(0, None)->Result.getExn
      let maxId = Array.length(state)
      let addBulk: (string, array<event>, int) => unit = %raw(`
      function (path, events, firstId) {
        const result = events.map((e, i) => ({
          id: (firstId + i),
          val: e
        }));
        const jr = new JsonRecords(path);
        jr.addBulk(result);
      }
      `)
      addBulk(JsonRecordConf.fileName, events, maxId + 1)
      Ok()
    } catch {
    | Js.Exn.Error(e) => Error(e->Js.Exn.message->Option.getWithDefault(""))
    | _ => Error("Unknown error")
    }
}

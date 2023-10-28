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

  let createTableIfNotExist: unit => result<unit, exn> = () =>
    ResultExn.tryExec(() => {
      let createFile: string => unit = %raw(`
      function (path) {
        fs.writeFileSync(path, '{}');
      }
      `)
      createFile(JsonRecordConf.fileName)
    })

  let dropTableIfExist: unit => result<unit, exn> = () =>
    ResultExn.tryExec(() => {
      let dropFile: string => unit = %raw(`
      function (path) {
        fs.unlinkSync(path);
      }
      `)
      dropFile(JsonRecordConf.fileName)
    })

  let getEvents = (from: int, limit: option<int>, time: option<float>): result<
    array<eventRecord<event>>,
    exn,
  > =>
    ResultExn.tryExec(() => {
      let getResult: (
        string,
        int,
        option<int>,
        option<float>,
        unknown => option<event>,
      ) => array<eventRecord<event>> = %raw(`
      function (path, from, limit, time, parseFunc) {
        const jr = new JsonRecords(path);
        let timeCond = (r) => (time ? (r.timestamp >= time) : true);
        let idCond = (r) => (r.id >= from);
        return jr
          .get( r => (timeCond(r) && idCond(r)))
          .filter((el, i) => (limit ? (i < limit) : true))
          .map(r => {
            if((!r.id) || (!r.val)) {
              throw new Error("result is not event record: " + JSON.stringify(r));
            }
            const parseResult = parseFunc(r.val);
            if(!parseResult) { 
              throw new Error("event is not valid: " + JSON.stringify(r));
            }
            return {id: r.id, val: parseResult, timestamp: r.timestamp};
          });
      }
      `)
      getResult(JsonRecordConf.fileName, from, limit, time, Event.parseUnknown)
    })

  let insertEvent = (event: event): result<int, exn> =>
    ResultExn.tryExec(() => {
      let state = getEvents(0, None, None)->Result.getExn
      let maxId = Array.length(state)
      let addEvent: (string, event, int) => unit = %raw(`
      function (path, event, id) {
        const jr = new JsonRecords(path);
        jr.add({ id: id, val: event, timestamp: Date.now() });
      }
      `)
      addEvent(JsonRecordConf.fileName, event, maxId + 1)
      maxId + 1
    })
}

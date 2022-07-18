(* let list_blocks _request = *)
(*   let blocks = `List (List.map block_to_json (Blockchain.current ())) in *)
(*   blocks |> Yojson.Safe.to_string |> Dream.json *)

let add_endpoint name =
  let result = Db.add name |> Lwt_main.run in
  match result with
  | Ok _ -> Dream.empty `OK
  | Error _ -> Dream.empty `Not_Found

let get_all_endpoint =
  let result = Db.get_all () |> Lwt_main.run in
  match result with
  | Ok list ->
      (* Card.Card.t.Caqti_pool_sig *)
      (* Dream.empty `OK *)
      (* let open Card.Card in *)
      let first = List.nth list 0 in
      let json = Card.to_json first in
      let sJson = Yojson.Safe.to_string json in
      Dream.json sJson
      (* Yojson.Safe.to_string list |> Dream.respond *)
  | Error _ -> Dream.empty `Not_Found

let health_endpoint = "Service is  up and running." |> Dream.respond
(* let health_endpoint = *)
(*   let result = Db.pool.find Db.plus (7, 13) in *)
(*   match result with *)
(*   | Ok 1 -> "Service is up and running." |> Dream.respond *)
(*   | _ -> "Service is not up and running." |> Dream.respond *)

(* module Connection = (val Db.Database.connect ()) *)

(* let migrate = Db.migrate () *)

let start () =
  Dream.run ~port:Config.api_base_port
  @@ Dream.logger
  @@ Middlewares.cors_middleware
  @@ Dream.router
       [
         Dream.get "/all" (fun _ -> get_all_endpoint);
         Dream.post "/add" (fun _ -> "Vai" |> add_endpoint);
         Dream.get "/health" (fun _ -> health_endpoint);
       ]

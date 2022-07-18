(* let list_blocks _request = *)
(*   let blocks = `List (List.map block_to_json (Blockchain.current ())) in *)
(*   blocks |> Yojson.Safe.to_string |> Dream.json *)

(* let add_endpoint _res = *)
(*   let result = Db.add name |> Lwt_main.run in *)
(*   match result with *)
(*   | Ok _ -> Dream.empty `OK *)
(*   | Error _ -> Dream.empty `Not_Found *)

let get_all_endpoint _request =
  let%lwt result = Db.get_all () in
  match result with
  | Ok list ->
      let cards_to_json =  List.map Card.to_json in
      let cards_json = `List(cards_to_json list) in
      let cards_string = Yojson.Safe.to_string cards_json in
      Dream.json cards_string
  | Error _ -> Dream.empty `Not_Found

let health_endpoint (_res) =
  let%lwt result = Db.health (7,13) in
  match result with
  (* 7 + 13 = 20. So the Database is working well *)
  | Ok 20 -> "Service is up and running." |> Dream.respond
  | _ -> "Service is not up and running." |> Dream.respond

let start () =
  Dream.run ~port:Config.api_base_port
  @@ Dream.logger
  @@ Middlewares.cors_middleware
  @@ Dream.router
       [
         Dream.get "/all" get_all_endpoint;
         (* Dream.post "/add" add_endpoint; *)
         Dream.get "/health" health_endpoint
       ]

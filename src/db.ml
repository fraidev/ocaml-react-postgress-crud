open Caqti_request.Infix
        
let pool =
  match
    Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string Config.connection_url)
  with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

let or_error m =
  match%lwt m with
  | Ok a -> Ok a |> Lwt.return
  | Error e -> Error (Caqti_error.show e) |> Lwt.return

let migrate_query =
  (Caqti_type.unit ->. Caqti_type.unit)
    {| CREATE TABLE cards (
             id SERIAL NOT NULL PRIMARY KEY,
             name VARCHAR
          )
       |}

let destroy_query = (Caqti_type.unit ->. Caqti_type.unit) {| DROP TABLE cards |}

let get_all_query =
  (Caqti_type.unit ->* Caqti_type.(tup2 int string))
    "SELECT id, name FROM cards"

let get_all () =
  let get_all' (module C : Caqti_lwt.CONNECTION) =
    let open Card in
    C.fold get_all_query
      (fun (id, name) acc -> { id ; name } :: acc)
      () [] in
  Caqti_lwt.Pool.use get_all' pool |> or_error

let plus_query = (Caqti_type.(tup2 int int) ->! Caqti_type.int) "SELECT ? + ?"

let health (a,b) = 
  let plus' (module C: Caqti_lwt.CONNECTION) = C.find plus_query (a, b) in
  Caqti_lwt.Pool.use plus' pool |> or_error

let add_query =
  (Caqti_type.string ->. Caqti_type.unit) "INSERT INTO cards (name) VALUES (?)"

let add name =
  let add' name (module C : Caqti_lwt.CONNECTION) = C.exec add_query name in
  Caqti_lwt.Pool.use (add' name) pool |> or_error

let migrate () =
  let migrate' (module C : Caqti_lwt.CONNECTION) = C.exec migrate_query () in
  Caqti_lwt.Pool.use migrate' pool |> or_error

let destroy () =
  let destroy' (module C : Caqti_lwt.CONNECTION) = C.exec destroy_query () in
  Caqti_lwt.Pool.use destroy' pool |> or_error


(* let createTables = Db. *)

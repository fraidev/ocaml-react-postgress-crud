(* open Lwt.Infix *)
open Caqti_request.Infix

        
let pool =
  match
    Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string Config.connection_url)
  with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

(* module Database = struct *)
(*   let connect () = *)
(*     let open Lwt.Infix in *)
(*     Uri.of_string Config.connection_url *)
(*     |> Caqti_lwt.connect *)
(*     >>= Caqti_lwt.or_fail *)
(*     |> Lwt_main.run *)
(* end *)

(* type error = Database_error of string *)

(* let print_error e : error -> unit = raise (Database_error "Oh no!") *)

let or_error m =
  match%lwt m with
  | Ok a -> Ok a |> Lwt.return
  (* | Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return *)
  | Error e -> Error (Caqti_error.show e) |> Lwt.return

let migrate_query =
  (Caqti_type.unit ->. Caqti_type.unit)
    {| CREATE TABLE cards (
             id SERIAL NOT NULL PRIMARY KEY,
             name VARCHAR
          )
       |}

let destroy_query = (Caqti_type.unit ->. Caqti_type.unit) {| DROP TABLE cards |}

(* let get_all_query2 = *)
(*   Caqti_request.collect *)
(*     Caqti_type.unit *)
(*     Caqti_type.(tup2 int string) *)
(*     "SELECT id, content FROM todos" *)

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
(* let get_all f = *)
(*   let get_all' (module C : Caqti_lwt.CONNECTION) = C.iter_s get_all_query f in *)
(*   Caqti_lwt.Pool.use get_all' pool |> or_error *)

(* let get_all' f (module C : Caqti_lwt.CONNECTION) = C.fold_s get_all_query f *)
(* let get_all f = Caqti_lwt.Pool.use (get_all' f) pool |> or_error *)
(* Caqti_lwt.Pool.use (get_all_ name) pool |> or_error *)

(* let get_all (module Db : Caqti_lwt.CONNECTION) f = Db.iter_s get_all_query f () *)
(* let get_all () = Db.iter Caqti_lwt.Pool.use get_all' pool |> or_error *)

(* let get_all () = *)
(*   let get_all' (module C : Caqti_lwt.CONNECTION) f = *)

(* Caqti_lwt.Pool.use get_all' pool |> or_error *)

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

let plus = (Caqti_type.(tup2 int int) ->! Caqti_type.int) "SELECT ? + ?"

(* let createTables = Db. *)

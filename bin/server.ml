let api = ref false
let migrate = ref false
let destroy = ref false

let usage = "server [-migrate/-destroy]"

let spec_list =
  [
    ("-api", Arg.Set api, "Run WEB API");
    ("-migrate", Arg.Set migrate, "Run migration on database");
    ("-destroy", Arg.Set destroy, "Run destroy on database");
  ]

let anon_fun _ = ()

(* let a = Crud.Db.add "hero" |> Lwt_main.run in *)
(* match a with *)
(* | Ok _ -> () *)
(* | Error e -> failwith e *)

let () =
  Arg.parse spec_list anon_fun usage;
  (if !migrate then
     let r = Crud.Db.migrate () |> Lwt_main.run in
     match r with
     | Ok _ -> ()
     | Error e -> failwith e);

  (if !destroy then
     match Crud.Db.destroy () |> Lwt_main.run with
     | Ok _ -> ()
     | Error e -> failwith e);

  if !api then
    Crud.Api.start ()

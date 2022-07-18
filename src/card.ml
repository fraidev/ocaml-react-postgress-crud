(* module Card = struct *)
  type t = {
    id : int;
    name : string;
  }[@@deriving yojson]

  let to_json a = yojson_of_t a;;
  
  (* let of_yojson json = *)
  (*   let%ok t = of_yojson json in *)
  (*   let%ok t = verify t.hash t.payload in *)
  (*   Ok json *)
(* end *)
  


(lang dune 3.3)

(name curd)

(version 0.1)

(maintainers "fraifelipe@gmail.com")

(generate_opam_files true)

(package
 (name crud)
 (synopsis "crud")
 (description "Crud")
 (depends
  (alcotest :with-test)
  (dune
   (and
    :build
    (>= 3.1.1)))
  (dream
   (= 1.0.0~alpha4))
  lwt_ppx
  ppx_yojson_conv
  caqti
  caqti-driver-postgresql
  hexstring))

(package
 (name dev)
 (synopsis "A package to install dev dependencies")
 (description "THIS PACKAGE IS FOR DEVELOPMENT PURPOSE")
 (allow_empty)
 (depends
  (ocamlformat
   (>= 0.20))
  (ocamlformat-rpc
   (>= 0.19))
  (ocaml-lsp-server
   (>= 1.10.3))))

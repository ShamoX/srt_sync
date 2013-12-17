#!/usr/bin/env ocaml str.cma

(* Version declaration *)
let version = "0.2.0";;
let showVersion () =
  print_endline ("Current version of srt_sync : " ^ version);
  exit 0
;;

(** Dealing with arguments **)
(* Declaring variables *)
let a = ref 1.0
and b = ref 0.0
and c = ref 0.0
and files = ref []
and is_unix = ref false
;;

let parsing_list = [
  ("-a", Arg.Set_float(a), "'a' parameter to resync");
  ("-b", Arg.Set_float(b), "'b' parameter to resync");
  ("-c", Arg.Set_float(c), "'c' parameter to resync");
  ("--unix", Arg.Set(is_unix), "use this if input file is a unix one");
  ("-v", Arg.Unit(showVersion), "display current version : " ^ version);
  ("--version", Arg.Unit(showVersion), "display current version : " ^ version);
];;

Arg.parse parsing_list (fun s -> files := !files @ [s]) "Resyncing all the times of the srt file with t' = a.t + b"
;;

if List.length !files = 0 then begin
  Arg.usage parsing_list "Thanks to provide at least one argument";
  exit 1
end;;

(* Function to create the output file name regarding the input file name *)
let makeOutputFileName iF =
  iF ^ "-resync.srt"
;;
let output_line oc str =
  let endline =
    if !is_unix then
      "\n"
    else
      "\r\n"
  in
  output_string oc (str ^ endline)
;;

(** Real deal here **)

(* Parsing ... *)
(* Declaring some usefull constants *)
let time_val = "\\([0-9]+\\):\\([0-9]+\\):\\([0-9]+\\),\\([0-9]+\\)"
;;
let time_line = Str.regexp ((*"^" ^*) time_val ^ " --> " ^ time_val (*^ "$"*))
;;

(* smart little functions *)
let getMatchedAndConvert i s =
  float_of_string (Str.matched_group i s)
;;
let getTimeGroup s i =
  let hours = getMatchedAndConvert i s
  and minutes = getMatchedAndConvert (i+1) s
  and seconds = getMatchedAndConvert (i+2) s
  and ms =getMatchedAndConvert (i+3) s
  in (hours *. 3600.) +.
    (minutes *. 60.) +.
    seconds +.
    (ms /. 1000.)
;;
let setTimeGroup time =
  let ms = floor ((time -. (floor time)) *. 1000.)
  and seconds = mod_float (floor time) 60.
  and minutes = mod_float (floor (time /. 60.)) 60.
  and hours = floor (time /. 3600.) in
  Printf.sprintf "%02.0f:%02.0f:%02.0f,%03.0f"
    hours minutes seconds ms
;;

(* The treatment function for a line *)
let treatLine l =
  if Str.string_match time_line l 0 then
    let start_time = getTimeGroup l 1
    and end_time = getTimeGroup l 5 in
    (setTimeGroup ((!a *. (start_time +. !c)) +. !b))
    ^ " --> " ^
    (setTimeGroup ((!a *. (end_time +. !c)) +. !b))
  else
    l
;;

(* The treatment function for a file *)
(*
 * May raise TODO
 *)
let treatFile iF =
  let oF = makeOutputFileName iF in
  let iC = open_in iF
  and oC = open_out oF in
  try
    while true do
      output_line oC (
        treatLine (
          input_line iC))
    done
  with End_of_file -> begin
    close_in iC;
    close_out oC
  end
;;


(* This is the main engine ! *)
List.iter treatFile !files

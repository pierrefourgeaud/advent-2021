let rotate a =
  let n = Array.length a in
  let v = a.(0) in
  for i = 0 to n - 2 do
    a.(i) <- a.(i + 1)
  done;
  a.(n - 1) <- v;;

let reset_internal_timer fishes =
  let a = fishes.(6) + fishes.(8) in
  fishes.(6) <- a;;

let compute days fishes =
  let rec step_day days fishes =
    match days with
      | 0 -> fishes
      | _ -> (
        rotate fishes;
        reset_internal_timer fishes;
        step_day (days - 1) fishes)
  in
  List.fold_left (fun acc fish ->
    acc.(fish) <- acc.(fish) + 1;
    acc
  ) (Array.make 9 0) fishes
    |> step_day days

let part fishes n partN =
  compute n fishes
    |> Array.fold_left (fun acc fish ->
      acc + fish
    ) 0 |> Printf.printf "Part %d: %d\n" partN

let () =
  let fishes = read_line() |> String.split_on_char ','
                           |> List.map int_of_string in
  part fishes 80 1;
  part fishes 256 2
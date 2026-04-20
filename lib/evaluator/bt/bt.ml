let return x = List.to_seq [x]

let bind x f = Seq.flat_map f x

let empty = List.to_seq []

let fail = Seq.empty

let run m = m

let (let*) = bind
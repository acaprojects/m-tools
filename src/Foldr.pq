/**
 * Perform a right-associative reduction over a list.
 *
 * :: (a b -> b) -> b -> [a] -> b
 */
(f as function, seed as any) =>
    (a as list) =>
    if List.IsEmpty(a) then
        seed
    else
        let
            x = List.Last(a),
            xs = List.RemoveLastN(a, 1)
        in
            f(@Foldr(f, x)(xs), seed)

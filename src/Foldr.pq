/**
 * Perform a right-associative reduction over a list.
 *
 * :: (a b -> b) -> b -> [a] -> b
 */
(f as function, seed as any) =>
    (xs as list) =>
        if List.IsEmpty(xs) then
            seed
        else
            let
                h = List.Last(xs),
                t = List.RemoveLastN(xs, 1)
            in
                f(@Foldr(f, h)(t), seed)

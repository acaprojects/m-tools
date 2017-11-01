/**
 * Perform a left-associative reduction over a list.
 *
 * :: (a b -> a) a -> [b] -> a
 */
(f as function, seed as any) =>
    (xs as list) =>
        List.Accumulate(xs, seed, f)

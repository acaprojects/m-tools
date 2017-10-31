/**
 * Perform a left-associative reduction over a list.
 *
 * :: (a b -> a) a -> [b] -> a
 */
(f as function, seed as any) =>
    (a as list) =>
        List.Accumulate(a, seed, f)

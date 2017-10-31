/**
 * Apply a transform to all elements of a list.
 *
 * (a -> b) -> [a] -> [b]
 */
(f as function) =>
    (a as list) =>
        List.Transform(a, f)

/**
 * Apply a transform to all elements of a list.
 *
 * (a -> b) -> [a] -> [b]
 */
(f as function) =>
    (xs as list) =>
        List.Transform(xs, f)

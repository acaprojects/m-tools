/**
 * Given function that maps to a list, apply it to a list of values and
 * concatenate the result.
 *
 * :: (a -> [b]) -> [a] -> [b]
 */
(f as function) =>
    Compose(Concat, Map(f))

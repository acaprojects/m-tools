/**
 * Evaluate elements of a list against a predicate, returning a new list
 * of the items which evaluated to true.
 *
 * :: (a -> Bool) -> [a] -> [a]
 */
(f as function) =>
    (a as list) =>
        List.Select(a, f)

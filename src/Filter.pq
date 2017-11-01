/**
 * Evaluate elements of a list against a predicate, returning a new list
 * of the items which evaluated to true.
 *
 * :: (a -> Bool) -> [a] -> [a]
 */
(p as function) =>
    (xs as list) =>
        List.Select(xs, p)

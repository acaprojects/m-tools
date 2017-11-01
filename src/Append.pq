/**
 * Add a single element to the tail of a list and return a new list
 * containing the merged result.
 *
 * :: a -> [a] -> [a]
 */
(x as any) =>
    (xs as list) =>
        xs & Of(x)

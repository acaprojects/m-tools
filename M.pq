// A collection a useful tools for building Microsoft Power BI queries.
//
// Author:  Kim Burgess <kim@acaprojects.com>
// Repo:    https://github.com/acaprojects/m-tools
// License: MIT

[
    /**
     * Provide a simplified method for programmatically contructing table from
     * relationships between columns. Accepts a list of lists of the structure:
     *
     *     {<column name>, <column generator>, <type>}
     *
     * The chain may then be fed a table containing at least one column as a
     * seed.
     *
     * :: (Table a, Record b) => [(Text, b -> c, Type)] -> a -> a
     */
    AddColumns = Compose(ChainOperations, Map(Cons(Table.AddColumn))),

    /**
     * Check if all elements of a list satisfy a given predicate.
     *
     * :: (a -> Bool) -> [a] -> Bool
     */
    All = (p as function) =>
        (xs as list) =>
            And(Map(p, xs)),

    /**
     * Logical conjunction of a list of boolean values.
     *
     * :: [Bool] -> Bool
     */
    And = List.AllTrue,

    /**
     * Check if any elements of a list satisfy a given predicate.
     *
     * :: (a -> Bool) -> [a] -> Bool
     */
    Any = (p as function) =>
        (xs as list) =>
            Or(Map(p, xs)),

    /**
     * Take a function that accepts an arbitary number of arguments and
     * transform this to a function that takes a single list argument
     * containing the original function arguments.
     *
     * :: (*... -> a) -> [*] -> a
     */
    Apply = Curry(Function.Invoke),

    /**
     * Given two lists of values, return a list containing their product set.
     *
     * :: [a] [b] -> [[a, b]]
     */
    CartProd = (xs as list, ys as list) =>
        M[ConcatMap]((x) => M[ConcatMap]((y) => {
            {x, y}
        })(ys))(xs),

    /**
     * Provide the ability to chain sequences of internal table, record and
     * list operations.
     *
     * The internal transform functions all take the object being transformed
     * as parameter 0. To remove the need to assign intermediate variables
     * this lifts that argument to be within a higher-order function allowing
     * a sequence of operations to be performed. This sequence is defined as a
     * list of lists, with element 0 containing the transform function and
     * elements 1..n containing the arguments 1..n for that transform.
     *
     *     ExtractRoomInfo = M[ChainOperations]({
     *         {Table.SelectColumns, {"RoomID", "RoomName"}},
     *         {Table.RenameColumns, {"RoomID", "ID"}},
     *         {Table.RenameColumns, {"RoomName", "Name"}}
     *     })
     *
     * :: [(a -> b, x, y, ..n), (b -> c, x, y, ..n),...] -> a -> z
     */
    ChainOperations = let
        Transform = (t as list) =>
            let
                f = List.First(t),
                args = List.Skip(t)
            in
                PartialRight1(f, args)
    in
        Compose(Pipe, Map(Transform)),

    /**
     * Right-to-left composition of a pair of unary functions.
     *
     * :: (b -> c) (a -> b) -> a -> c
     */
    Compose = (f as function, g as function) =>
        (x as any) =>
            f(g(x)),

    /**
     * Perform a right-to-left composition across a list of functions.
     *
     * :: ((y -> z), (x -> y), ..., (a -> b)) -> a -> z
     */
    ComposeMany = Foldr(Compose, Id),

    /**
     * Flatten a list of lists in to a single list.
     *
     * :: [[a]] -> [a]
     */
    Concat = List.Combine,

    /**
     * Given function that maps to a list, apply it to a list of values and
     * concatenate the result.
     *
     * :: (a -> [b]) -> [a] -> [b]
     */
    ConcatMap = (f as function) =>
        Compose(Concat, Map(f)),

    /**
     * Add a single element to the head of a list and return a new list
     * containing the merged result.
     *
     * :: a -> [a] -> [a]
     */
    Cons = (x as any) =>
        (xs as list) =>
            {x} & xs,

    /**
     * Return a function which always returns a given value.
     *
     * :: a -> b -> a
     */
    Const = (a as any) =>
        (b as any) =>
            a,

    /**
     * Curry a function so that it will continue to return functions or arity 1
     * up until the original function is saturated, at which point it will be
     * invoked.
     *
     * e.g. Curry((a, b, c) => x) = (a) => (b) => (c) => x
     *
     * :: (* -> a) -> (* -> a)
     */
    Curry = (f as function) =>
        let
            arity = Record.FieldCount(Type.FunctionParameters(Value.Type(f))),
            ApplyTo =
                (args as list) =>
                    if List.Count(args) >= arity then
                        Function.Invoke(f, args)
                    else
                        (x as any) =>
                        @ApplyTo(args & Of(x))
        in
            ApplyTo({}),

    /**
     * Evaluate elements of a list against a predicate, returning a new list
     * of the items which evaluated to true.
     *
     * :: (a -> Bool) -> [a] -> [a]
     */
    Filter = (p as function) =>
        (xs as list) =>
            List.Select(xs, p),

    /**
     * Reverse the order of arguments to a function or arity 2.
     *
     * :: ((a, b) -> c) -> ((b, a) -> c)
     */
    Flip = (f as function) =>
        (a as any, b as any) =>
            f(b, a),

    /**
     * Perform a left-associative reduction over a list.
     *
     * :: (a b -> a) a -> [b] -> a
     */
    Foldl = (f as function, seed as any) =>
        (xs as list) =>
            List.Accumulate(xs, seed, f),

    /**
     * Perform a right-associative reduction over a list.
     *
     * :: (a b -> b) -> b -> [a] -> b
     */
    Foldr = (f as function, seed as any) =>
        (xs as list) =>
            if List.IsEmpty(xs) then
                seed
            else
                let
                    h = List.Last(xs),
                    t = List.RemoveLastN(xs, 1)
                in
                    f(@Foldr(f, h)(t), seed),

    /**
     * Identity for functions under composition.
     *
     * :: a -> a
     */
    Id = (a as any) =>
        a,

    /**
     * Given a list a and another list b, create a new list containing the
     * result of appending b to a.
     *
     * :: [a] -> [a] -> [a]
     */
    Join = (a as list) =>
        (b as list) =>
            a & b,

    /**
     * Apply a transform to all elements of a list.
     *
     * (a -> b) -> [a] -> [b]
     */
    Map = (f as function) =>
        (xs as list) =>
            List.Transform(xs, f),

    /**
     * Return a single item array containing the passed value.
     *
     * :: a -> [a]
     */
    Of = (a as any) =>
        {a},

    /**
     * Logical disjunction of a list of boolean values.
     *
     * :: [Bool] -> Bool
     */
    Or = List.AnyTrue,

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided initially followed by the argument list provided to g.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> ([d, e, f, ..., n] -> x)
     */
    Partial = (f as function, args as list) =>
        Compose(Apply(f), Join(args)),

    /**
     * Similar to Partial but instead of returning a function expecting a list
     * of remaining arguments, provides a function expecting a final single
     * argument in order to fully apply the initial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> (n -> x)
     */
    Partial1 = (f as function, args as list) =>
        Compose(Partial(f, args), Of),

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided to g followed by the argument list provided initially.
     *
     * :: ((a, b, c, ..., n) -> x) -> [d, e, f, ..., n] -> ([a, b, c, ...] -> x)
     */
    PartialRight = (f as function, a as list) =>
        Compose(Apply(f), (b as list) => b & a),

    /**
     * Similar to PartialRight however accepts a single, final argument in order
     * to fully apply the intial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> d, e, f, ..., n] -> (a -> x)
     */
    PartialRight1 = (f as function, a as list) =>
        Compose(PartialRight(f, a), Of),

    /**
     * Perform a left-to-right composition across a list of functions.
     *
     * :: ((a -> b), (b -> c), ..., (y -> z)) -> a -> z
     */
    Pipe = Foldl(Flip(Compose), Id)
]
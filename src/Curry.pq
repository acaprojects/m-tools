/**
 * Curry a function so that it will continue to return functions or arity 1
 * up until the original function is saturated, at which point it will be
 * invoked.
 *
 * e.g. Curry((a, b, c) => x) = (a) => (b) => (c) => x
 *
 * :: (* -> a) -> (* -> a)
 */
(f as function) =>
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
        ApplyTo({})

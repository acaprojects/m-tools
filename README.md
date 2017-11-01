# M-tools

A collection a useful tools for building queries in the Power Query Formula Language ("*M*") used by [Microsoft Power BI](https://powerbi.microsoft.com/).


## Usage

>Power BI does not (appear) to currently support external dependencies so setup is a little rudimentary.

1. Create a new blank query.
2. Copy the content of [M.pq](M.pq) to this query using the advanced editor.
3. Name the query `M`.

Functions may then be access from other queries as records on `M`. For example, `Pipe` may be invoked as:

    M[Pipe]({functionA, functionB, ...})


## Contributing

Do not directly edit [M.pq](M.pq). This is built from the components defined in
[src/](src/). It is provided, preassembled for convenience only.

To add functions, create new `*.pq` files within [src/](src/) containing the
expression body and any relevant documentation (see the other files for
reference). When compiled, the expression will be bound to the name of the file.

### Building

```bash
runhaskell build.hs
```

---

[M Language specification](https://msdn.microsoft.com/en-us/library/mt807488.aspx)

[Type system](https://msdn.microsoft.com/en-us/library/mt809131.aspx)

[Internal function references](https://msdn.microsoft.com/en-us/library/mt779182.aspx)

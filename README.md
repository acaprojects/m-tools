# M-tools

A collection a useful tools for building queries in the Power Query Formula Language ("*M*") used by [Microsoft Power BI](https://powerbi.microsoft.com/).


## Usage

>Power BI does not (appear) to currently support external dependencies so setup is a little rudimentary.

1. Create a new blank query.
2. Copy the content of [m-tools.pqfl](m-tools.pqfl) to this query using the advanced editor.
3. Name the query `M`.

Functions may then be access from other queries as records on `M`. For example, `Pipe` may be invoked as:

    M[Pipe]({functionA, functionB, ...})


---


[M Language specification](https://msdn.microsoft.com/en-us/library/mt807488.aspx)

[Type system](https://msdn.microsoft.com/en-us/library/mt809131.aspx)

[Internal function references](https://msdn.microsoft.com/en-us/library/mt779182.aspx)
// A collection a useful tools for building Microsoft Power BI queries.
//
// Author: Kim Burgess <kim@acaprojects.com>
// Repo:   https://github.com/acaprojects/m-tools

/**
 * Build a data table of common date base deliniations across the specified
 * period. This may then be related to other data sets containing date based
 * data for splitting and grouping in interesting ways.
 *
 * :: (date, date, string) -> table
 */
let CreateDateTable = (StartDate as date, EndDate as date, optional Culture as nullable text) as table =>
  let
    DaysInPeriod = Duration.Days(Duration.From(EndDate - StartDate)),

    DaysList = List.Dates(StartDate, DaysInPeriod, #duration(1,0,0,0)),

    Seed = M[ChainOperations]({
        {Table.FromList, Splitter.SplitByNothing(), {"Date"}},
        {Table.TransformColumnTypes, {{"Date", type date}}}
    })(DaysList),

    BuildTable = M[AddColumns]({
        // Date components
        {"Year", each Date.Year([Date]), Int64.Type},
        {"Month", each Date.Month([Date]), Int64.Type},
        {"Day", each Date.Day([Date]), Int64.Type},

        // Calendar based quantizations
        {"Quarter", each Date.QuarterOfYear([Date]), Int64.Type},
        {"DayOfMonth", each Date.Day([Date]), Int64.Type},
        {"DayOfWeek",
            each Date.DayOfWeek([Date], 1) + 1,
            Int64.Type
        },

        // Useful string based splits
        {"MonthName",
            each Date.ToText([Date], "MMMM", Culture),
            type text
        },
        {"MonthInCalendar",
            each (try Text.Range([MonthName], 0, 3) otherwise [MonthName])
                & " " & Number.ToText([Year]),
            type text
        },
        {"QuarterInCalendar",
            each "Q" & Number.ToText([Quarter]) & " " & Number.ToText([Year]),
            type text
        },
        {"DayOfWeekName",
            each Date.ToText([Date], "dddd", Culture),
            type text
        },

        // Financial periods
        {"FinancialYearNumber",
            each if [Month] >= 7 then [Year] else [Year] - 1,
            Int64.Type
        },
        {"FinancialYear",
            each "FY" & Text.End(Number.ToText([FinancialYearNumber]), 2) &
                "/" & Text.End(Number.ToText([FinancialYearNumber] + 1), 2),
            type text
        },
        {"FinancialMonth",
            each if [Month] >= 7 then [Month] - 6 else [Month] + 6,
            Int64.Type
        },
        {"FinancialQuarterNumber",
            each if [Quarter] > 2 then [Quarter] - 2 else [Quarter] + 2,
            Int64.Type
        },
        {"FinancialQuarter",
            each "FQ" & Number.ToText([FinancialQuarterNumber]),
            type text
        },

        // Sortable int representation
        {"DateInt",
            each [Year] * 10000 + [Month] * 100 + [DayOfMonth],
            Int64.Type
        },

        // ISO8601 weeks
        {"CurrentThursday",
            each Date.AddDays([Date], -Date.DayOfWeek([Date], 1) + 3),
            type date
        },
        {"ISOWeekJan4",
            each Date.FromText(Number.ToText(Date.Year([CurrentThursday])) & "-01-04"),
            type date
        },
        {"ISOWeekYear",
            each Date.Year([CurrentThursday]),
            Int64.Type
        },
        {"ISOWeekFirstMon",
            each
                if [CurrentThursday] < [ISOWeekJan4] then Date.AddDays([CurrentThursday], -3)
                else Date.AddDays([ISOWeekJan4], -Date.DayOfWeek([ISOWeekJan4], 1)),
            type date
        },
        {"ISOWeekNum",
            each Number.RoundUp(((Duration.Days(Duration.From([Date] - [ISOWeekFirstMon])) + 1 ) / 7)),
            Int64.Type
        },
        {"ISOWeekID",
            each [ISOWeekYear] * 100 + [ISOWeekNum],
            Int64.Type
        },
        {"ISOWeekName",
            each Number.ToText([ISOWeekYear]) & "W" &
                Text.End("0" & Number.ToText(([ISOWeekNum] * 10) + [DayOfWeek]), 3),
            type text
        },
        {"ISOWeekNameLong",
            each Text.From([ISOWeekYear]) & "-W" &
                Text.End("0" & Text.From([ISOWeekNum]), 2) & "-" &
                Text.From([DayOfWeek]),
            type text
        },

        // 4-4-5 Calendar
        {"445",
            each if [ISOWeekNum] < 5 then [Period=1, Quarter=1]
            else if [ISOWeekNum] < 9 then [Period=2, Quarter=1]
            else if [ISOWeekNum] < 14 then [Period=3, Quarter=1]
            else if [ISOWeekNum] < 18 then [Period=4, Quarter=2]
            else if [ISOWeekNum] < 22 then [Period=5, Quarter=2]
            else if [ISOWeekNum] < 27 then [Period=6, Quarter=2]
            else if [ISOWeekNum] < 31 then [Period=7, Quarter=3]
            else if [ISOWeekNum] < 35 then [Period=8, Quarter=3]
            else if [ISOWeekNum] < 40 then [Period=9, Quarter=3]
            else if [ISOWeekNum] < 44 then [Period=10, Quarter=4]
            else if [ISOWeekNum] < 48 then [Period=11, Quarter=4]
            else [Period=12, Quarter=4]
        }
    }),

    Table = BuildTable(Seed),

    RemoveExcess = M[ChainOperations]({
        {Table.ExpandRecordColumn, "445", {"Period", "Quarter"}, {"445 Period", "445 Quarter"}},
        {Table.RemoveColumns, {"CurrentThursday", "ISOWeekFirstMon"}}
    }),

    FinalTable = RemoveExcess(Table)

  in
    FinalTable
in
    CreateDateTable

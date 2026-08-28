# baseball-analytics-with-sql
Analyzing baseball data with MySQL to explore schools, team salaries, player careers, and player characteristics.

# Baseball Analytics with SQL

## Project Overview

This project explores historical baseball data using SQL to investigate four areas of baseball analytics:

- **School Analysis** — examining schools that produced professional baseball players.
- **Salary Analysis** — analyzing team spending and cumulative salary expenditure over time.
- **Player Career Analysis** — examining player age, career length, and team history.
- **Player Comparison Analysis** — comparing player characteristics and identifying trends over time.

The project demonstrates how SQL can be used to analyze relational data and answer analytical questions using MySQL.

## Tools Used

- MySQL
- SQL
- MySQL Workbench

## Database Tables

The analysis uses several related tables, including:

- `schools`
- `school_details`
- `salaries`
- `players`

## Analysis

### 1. School Analysis

This section examines the schools associated with professional baseball players.

Questions explored include:

- How many schools produced players in each decade?
- Which five schools produced the most players?
- Which three schools produced the most players in each decade?

**SQL techniques demonstrated:**

- `LEFT JOIN`
- `GROUP BY`
- `COUNT(DISTINCT)`
- Common Table Expressions (CTEs)
- `ROW_NUMBER()`
- Aggregation and ranking

### 2. Salary Analysis

This section examines team salary spending over time.

Questions explored include:

- Which teams were in the top 20% based on average annual spending?
- What was each team's cumulative spending over the years?
- In which year did each team's cumulative spending first exceed $1 billion?

**SQL techniques demonstrated:**

- Common Table Expressions (CTEs)
- `SUM()`
- `AVG()`
- Window functions
- `NTILE()`
- Running totals
- `ROW_NUMBER()`

### 3. Player Career Analysis

This section examines player careers using biographical and salary data.

Questions explored include:

- How many players are in the dataset?
- How old were players when they began and ended their careers?
- How long did their careers last?
- Which teams did players play for in their starting and ending years?
- Which players started and ended with the same team while playing for more than a decade?

**SQL techniques demonstrated:**

- `INNER JOIN`
- Date conversion
- `TIMESTAMPDIFF()`
- Date calculations
- Filtering and sorting

### 4. Player Comparison Analysis

This section compares player characteristics and examines changes over time.

Questions explored include:

- Which players shared the same birthday?
- What percentage of players on each team batted right-handed, left-handed, or both?
- How did average player height and weight at debut change across decades?

**SQL techniques demonstrated:**

- Common Table Expressions (CTEs)
- `CASE`
- Conditional aggregation
- `GROUP_CONCAT()`
- `LAG()`
- Window functions
- Date functions

## SQL Skills Demonstrated

This project provided practical experience working with:

- Joins
- Aggregate functions
- Common Table Expressions
- Window functions
- `ROW_NUMBER()`
- `NTILE()`
- `LAG()`
- Conditional aggregation with `CASE`
- Date parsing and conversion
- Date calculations
- Running totals
- Ranking and comparison
- Data filtering and ordering

## Project Takeaway

This project strengthened my ability to use SQL to explore relational data, perform multi-step analysis, and apply advanced querying techniques to answer analytical questions.

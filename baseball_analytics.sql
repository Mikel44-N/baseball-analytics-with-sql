-- ============================================================
-- BASEBALL ANALYTICS WITH SQL
-- ============================================================
-- Database: maven_advanced_sql
-- Tool: MySQL
--
-- This project explores historical baseball data across four
-- analytical areas:
--   1. School Analysis
--   2. Salary Analysis
--   3. Player Career Analysis
--   4. Player Comparison Analysis
-- ============================================================

USE maven_advanced_sql;


-- ============================================================
-- PART I: SCHOOL ANALYSIS
-- ============================================================

-- 1. View the schools and school details tables
SELECT *
FROM schools;

SELECT *
FROM school_details;


-- 2. In each decade, how many schools were there that produced
--    players?
SELECT
    FLOOR(yearID / 10) * 10 AS decade,
    COUNT(DISTINCT schoolID) AS num_schools
FROM schools
GROUP BY decade
ORDER BY decade;


-- 3. What are the names of the top 5 schools that produced
--    the most players?
SELECT
    sd.name_full,
    COUNT(DISTINCT s.playerID) AS num_players
FROM schools AS s
LEFT JOIN school_details AS sd
    ON s.schoolID = sd.schoolID
GROUP BY s.schoolID, sd.name_full
ORDER BY num_players DESC
LIMIT 5;


-- 4. For each decade, what were the names of the top 3 schools
--    that produced the most players?
WITH school_counts AS (
    SELECT
        FLOOR(s.yearID / 10) * 10 AS decade,
        s.schoolID,
        sd.name_full,
        COUNT(DISTINCT s.playerID) AS num_players
    FROM schools AS s
    LEFT JOIN school_details AS sd
        ON s.schoolID = sd.schoolID
    GROUP BY
        decade,
        s.schoolID,
        sd.name_full
),
ranked_schools AS (
    SELECT
        decade,
        name_full,
        num_players,
        ROW_NUMBER() OVER (
            PARTITION BY decade
            ORDER BY num_players DESC
        ) AS row_num
    FROM school_counts
)
SELECT
    decade,
    name_full,
    num_players
FROM ranked_schools
WHERE row_num <= 3
ORDER BY decade DESC, row_num;


-- ============================================================
-- PART II: SALARY ANALYSIS
-- ============================================================

-- 1. View the salaries table
SELECT *
FROM salaries;


-- 2. Return the top 20% of teams in terms of average annual
--    spending.
WITH team_spending AS (
    SELECT
        teamID,
        yearID,
        SUM(salary) AS total_spend
    FROM salaries
    GROUP BY teamID, yearID
),
team_averages AS (
    SELECT
        teamID,
        AVG(total_spend) AS avg_spend,
        NTILE(5) OVER (
            ORDER BY AVG(total_spend) DESC
        ) AS spend_pct
    FROM team_spending
    GROUP BY teamID
)
SELECT
    teamID,
    ROUND(avg_spend / 1000000, 1) AS avg_spend_millions
FROM team_averages
WHERE spend_pct = 1
ORDER BY avg_spend DESC;


-- 3. For each team, show the cumulative sum of spending
--    over the years.
WITH team_spending AS (
    SELECT
        teamID,
        yearID,
        SUM(salary) AS total_spend
    FROM salaries
    GROUP BY teamID, yearID
)
SELECT
    teamID,
    yearID,
    ROUND(
        SUM(total_spend) OVER (
            PARTITION BY teamID
            ORDER BY yearID
        ) / 1000000,
        1
    ) AS cumulative_sum_millions
FROM team_spending
ORDER BY teamID, yearID;


-- 4. Return the first year that each team's cumulative spending
--    surpassed $1 billion.
WITH team_spending AS (
    SELECT
        teamID,
        yearID,
        SUM(salary) AS total_spend
    FROM salaries
    GROUP BY teamID, yearID
),
cumulative_spending AS (
    SELECT
        teamID,
        yearID,
        SUM(total_spend) OVER (
            PARTITION BY teamID
            ORDER BY yearID
        ) AS cumulative_sum
    FROM team_spending
),
first_billion AS (
    SELECT
        teamID,
        yearID,
        cumulative_sum,
        ROW_NUMBER() OVER (
            PARTITION BY teamID
            ORDER BY yearID
        ) AS row_num
    FROM cumulative_spending
    WHERE cumulative_sum > 1000000000
)
SELECT
    yearID,
    teamID,
    ROUND(cumulative_sum / 1000000000, 2) AS cumulative_sum_billions
FROM first_billion
WHERE row_num = 1
ORDER BY yearID, teamID;


-- ============================================================
-- PART III: PLAYER CAREER ANALYSIS
-- ============================================================

-- 1. View the players table and find the number of players
--    in the table.
SELECT *
FROM players;

SELECT COUNT(*) AS num_players
FROM players;


-- 2. For each player, calculate their age at their first game,
--    their last game, and their career length (all in years).
--    Sort from longest career to shortest career.
SELECT
    nameGiven,
    CAST(
        CONCAT(birthYear, '-', birthMonth, '-', birthDay)
        AS DATE
    ) AS birth_date,
    TIMESTAMPDIFF(
        YEAR,
        CAST(
            CONCAT(birthYear, '-', birthMonth, '-', birthDay)
            AS DATE
        ),
        debut
    ) AS starting_age,
    TIMESTAMPDIFF(
        YEAR,
        CAST(
            CONCAT(birthYear, '-', birthMonth, '-', birthDay)
            AS DATE
        ),
        finalGame
    ) AS end_age,
    TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_length
FROM players
ORDER BY career_length DESC;


-- 3. What team did each player play on for their starting
--    and ending years?
SELECT
    p.nameGiven,
    s.yearID AS starting_year,
    s.teamID AS starting_team,
    e.yearID AS ending_year,
    e.teamID AS ending_team
FROM players AS p
INNER JOIN salaries AS s
    ON p.playerID = s.playerID
    AND YEAR(p.debut) = s.yearID
INNER JOIN salaries AS e
    ON p.playerID = e.playerID
    AND YEAR(p.finalGame) = e.yearID;


-- Supporting view of player, year, and team information.
SELECT
    playerID,
    yearID,
    teamID
FROM salaries;


-- 4. How many players started and ended on the same team and
--    also played for over a decade?
SELECT
    p.nameGiven,
    s.yearID AS starting_year,
    s.teamID AS starting_team,
    e.yearID AS ending_year,
    e.teamID AS ending_team
FROM players AS p
INNER JOIN salaries AS s
    ON p.playerID = s.playerID
    AND YEAR(p.debut) = s.yearID
INNER JOIN salaries AS e
    ON p.playerID = e.playerID
    AND YEAR(p.finalGame) = e.yearID
WHERE s.teamID = e.teamID
  AND e.yearID - s.yearID > 10;


-- ============================================================
-- PART IV: PLAYER COMPARISON ANALYSIS
-- ============================================================

-- 1. View the players table.
SELECT *
FROM players;


-- 2. Which players have the same birthday?
--    This analysis focuses on players born between 1980 and 1990
--    and returns only birthdays shared by more than one player.
WITH birth_names AS (
    SELECT
        CAST(
            CONCAT(birthYear, '-', birthMonth, '-', birthDay)
            AS DATE
        ) AS birth_date,
        nameGiven
    FROM players
)
SELECT
    birth_date,
    GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM birth_names
WHERE YEAR(birth_date) BETWEEN 1980 AND 1990
GROUP BY birth_date
HAVING COUNT(*) > 1
ORDER BY birth_date;


-- 3. Create a summary table showing, for each team, the
--    percentage of players who bat right, left, and both.
WITH team_players AS (
    SELECT DISTINCT
        teamID,
        playerID
    FROM salaries
)
SELECT
    tp.teamID,
    ROUND(
        SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        1
    ) AS bats_right,
    ROUND(
        SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        1
    ) AS bats_left,
    ROUND(
        SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        1
    ) AS bats_both
FROM team_players AS tp
LEFT JOIN players AS p
    ON tp.playerID = p.playerID
GROUP BY tp.teamID
ORDER BY tp.teamID;


-- 4. How have average height and weight at debut changed
--    over the years, and what is the decade-over-decade
--    difference?
WITH height_weight AS (
    SELECT
        FLOOR(YEAR(debut) / 10) * 10 AS decade,
        AVG(height) AS avg_height,
        AVG(weight) AS avg_weight
    FROM players
    GROUP BY decade
)
SELECT
    decade,
    ROUND(avg_height, 2) AS avg_height,
    ROUND(avg_weight, 2) AS avg_weight,
    ROUND(
        avg_height - LAG(avg_height) OVER (ORDER BY decade),
        2
    ) AS height_diff,
    ROUND(
        avg_weight - LAG(avg_weight) OVER (ORDER BY decade),
        2
    ) AS weight_diff
FROM height_weight
WHERE decade IS NOT NULL
ORDER BY decade;


-- ============================================================
-- END OF PROJECT
-- ============================================================

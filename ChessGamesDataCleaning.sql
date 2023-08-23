/*

Cleaning Data in SQL QUeries

*/

Select * 
From ChessDB.dbo.chess_games

/*
REPLACING NUMERIC VALUES WITH TEXT VALUES

Originally the table returned a value of Zero's and One's for the rated column
meaning Yes or No. The edits below are the steps I took to replace a value of 1 with yes and 0 with no.
I couldn't alter the column because it was a different type so I create a new column.
*/

ALTER TABLE chess_games
ADD rated_temp VARCHAR(3)

UPDATE chess_games
SET rated_temp = CASE
                   WHEN rated = 0 THEN 'No'
                   WHEN rated = 1 THEN 'Yes'
                 END;

Alter Table chess_games
drop column rated

exec sp_rename 'chess_games.rated_temp', 'rated', 'COLUMN';

/*------------------------------------------------------------------------------------------------------------------------------*/

-- Looking at the Opening Variation Data
-- Removing any row that has a NULL value in the Opening_Variation Column

Select *
From ChessDB.dbo.chess_games
Where opening_variation is null

DELETE
From ChessDB.dbo.chess_games
Where opening_variation is null


------------------------------------------------------------------------------------------------------------------------------------

-- Looking at the time_increment column and 
-- Adding a seperate column for Minutes and Seperate Column for TimeIncrement

exec sp_help chess_games

Select
Substring(time_increment, 1, CHARINDEX('+',time_increment) -1) as Minutes,
Substring(time_increment, CHARINDEX('+',time_increment) +1, LEN(time_increment)) as TimeIncrement
From ChessDB.dbo.chess_games

ALTER TABLE ChessDB.dbo.chess_games
add GameMinutes Nvarchar(255)

Update ChessDB.dbo.chess_games
SET GameMinutes = Substring(time_increment, 1, CHARINDEX('+',time_increment) -1)

ALTER TABLE ChessDB.dbo.chess_games
add SecondsAdded Nvarchar(255)

Update ChessDB.dbo.chess_games
SET SecondsAdded = Substring(time_increment, CHARINDEX('+',time_increment) +1, LEN(time_increment))

Select *
From ChessDB.dbo.chess_games


-------------------------------------------------------------------------------------------------------------

--Taking a look at the the Victory Status
--Changing Mate to Checkmate

Select Distinct(victory_status), count(victory_status)
From ChessDB.dbo.chess_games
Group By victory_status
Order by 2

Select victory_status
, CASE When victory_status = 'Mate' THEN 'Checkmate'
	ELSE victory_status
	END
From ChessDB.dbo.chess_games

Update ChessDB.dbo.chess_games
SET victory_status = CASE When victory_status = 'Mate' THEN 'Checkmate'
	ELSE victory_status
	END


------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- I understand this is not standard practice to delete data from a DB but just wanted to show the query

Select distinct(white_id), count(white_id) as Occurances
From ChessDB.dbo.chess_games
Group By white_id

-- Deleting the usernames that pop up more than once in the white_id column

WITH CTE(white_id,
		duplicatecount)
AS (Select white_id,
		   ROW_NUMBER() Over(Partition by white_id Order By game_id) as DuplicateCount
	From ChessDB.dbo.chess_games)
Delete from cte
Where duplicatecount > 1

-- Deleting the usernames that pop up more than once in the black_id column

WITH CTE(black_id,
		duplicatecount)
AS (Select black_id,
		   ROW_NUMBER() Over(Partition by black_id Order By game_id) as DuplicateCount
	From ChessDB.dbo.chess_games)
Delete from cte
Where duplicatecount > 1


--------------------------------------------------------------------------------------------------------------------------

-- Delete unused Columns

Select *
From ChessDB.dbo.chess_games

ALTER TABLE ChessDB.dbo.chess_games
DROP Column opening_code, opening_response, turns
--count of table rows
select count(*) from dbo.Education_Statistics 

select * from dbo.Education_Statistics

--remove column 2019 and 2020 since contains no data
alter table dbo.Education_Statistics
drop column [2019 (YR2019)], [2020 (YR2020)]

 --check distinct of countries
 select distinct( [Country Name]) from dbo.Education_Statistics
 order by 1 asc

--delete all countries which are not countries or are aggregation of areas
 delete from dbo.Education_Statistics
 where [Country Name] in 
(
	 'Arab World'
	,'East Asia & Pacific'
	,'East Asia & Pacific (excluding high income)'
	,'East Asia & Pacific (IDA & IBRD countries)'
	,'Euro area'
	,'Europe & Central Asia'
	,'Europe & Central Asia (excluding high income)'
	,'Europe & Central Asia (IDA & IBRD countries)'
	,'European Union'
	,'Fragile and conflict affected situations'
	,'Heavily indebted poor countries (HIPC)'
	,'High income'
	,'IBRD only'
	,'IDA & IBRD total'
	,'IDA blend'
	,'IDA only'
	,'IDA total'
	,'Latin America & Caribbean (excluding high income)'
	,'Latin America & the Caribbean (IDA & IBRD countries)'
	,'Least developed countries: UN classification'
	,'Lending category not classified'
	,'Middle East & North Africa'
	,'Middle East & North Africa (excluding high income)'
	,'Middle East & North Africa (IDA & IBRD countries)'
	,'OECD members'
	,'Post-demographic dividend'
	,'Pre-demographic dividend'
	,'Small states'
)

 --check data integrity of all dimensional data
 select * from dbo.Education_Statistics
 where [Country Name] is null OR [Country Code] is null OR Series is null OR [Series Code] is null
 order by 1 asc

 --check null for all fields value
 select 
  [2016 (YR2016)]
 ,[2017 (YR2017)]
 ,[2018 (YR2018)]
 from dbo.Education_Statistics
 where 
  [2016 (YR2016)] is null OR
  [2017 (YR2017)] is null OR
  [2018 (YR2018)] is null
 order by 1 asc

-- unpitot year from 2016 to 2018 preservin NULL values
SELECT a.[Country Name]
      ,a.[Country Code]
      ,a.[Series]
      ,a.[Series Code]
	  ,A.StatisticCode
	  ,Value
  FROM Education_Statistics a
CROSS APPLY (VALUES ('[2016 (YR2016)]', [2016 (YR2016)]),
					('[2017 (YR2017)]', [2017 (YR2017)]),
					('[2016 (YR2016)]', [2018 (YR2018)]))
					CrossApplied([Country Name],Value)

--Create a Concatenate Field (StatisticCode) between Country Name and Series Code to check duplicate rows
 select *,
 ([Country Name] + '-' + [Series Code]) as StatisticCode
 from dbo.Education_Statistics

--Add the new StatisticCode column to the table
Alter table dbo.Education_Statistics
Add StatisticCode Nvarchar(150)

--populate the column StatisticCode
Update dbo.Education_Statistics
set StatisticCode = [Country Name] + '-' + [Series Code]

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY [Country Name]
				,[Country Code]
				,[Series]
				,[Series Code]
				ORDER BY
					StatisticCode
					) row_num

from dbo.Education_Statistics
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY [Series Code]

--Create a View to save the Unpivoted table
Create view v_Education_Statistics
as
SELECT a.[Country Name]
      ,a.[Country Code]
      ,a.[Series]
      ,a.[Series Code]
	  ,A.StatisticCode
	  ,Value
  FROM Education_Statistics a
CROSS APPLY (VALUES ('[2016 (YR2016)]', [2016 (YR2016)]),
					('[2017 (YR2017)]', [2017 (YR2017)]),
					('[2016 (YR2016)]', [2018 (YR2018)]))
					CrossApplied([Country Name],Value)
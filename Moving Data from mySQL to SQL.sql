EXEC ('SELECT * FROM distinte') AT MYSQL_SERVER

EXEC ('SELECT LENGTH(scheda) FROM distinte') AT MYSQL_SERVER

--Select data from table distinte inside mySQL database 
SELECT *
FROM OPENQUERY([MYSQL_SERVER], 'SELECT * FROM distinte')

--Create distinte table inside Futurcom Database
use Futurcom truncate table dbo.Distinte
use Futurcom drop table dbo.Distinte

use Futurcom create table dbo.Distinte (
id int IDENTITY(1,1) primary key,
scheda varchar(11) not null,
item varchar(15) not null,
quantita int,
descrizione nvarchar(100),
created_at datetime,
updated_at datetime
);

use Futurcom select * from dbo.Distinte

--Copying all data from mySQL distinte table to SQL distinte table
use Futurcom
SET IDENTITY_INSERT dbo.Distinte ON
insert into dbo.Distinte
(
[id],
[scheda],
[item],
[quantita],
[descrizione],
[created_at],
[updated_at]
)
SELECT
id,
scheda,
item,
[quantità],
descrizione,
created_at,
updated_at
FROM OPENQUERY([MYSQL_SERVER], 'SELECT * FROM distinte')
SET IDENTITY_INSERT  dbo.Distinte OFF


-- Create Store Procedure to truncate and populate dbo.Distinte
Create Procedure truncateAndPop_Distinte
as
SET IDENTITY_INSERT dbo.Distinte OFF
begin
declare @Database nvarchar(max) = 'Futurcom'
declare @Sql nvarchar(max)
declare @TruncateStage nvarchar(max)
declare @SchemaStage VARCHAR(MAX) = 'dbo'
declare @Stage VARCHAR(MAX) = 'distinte'
declare @Insert nvarchar(max)
declare @LinkedService nvarchar(max) = '[MYSQL_SERVER]'
declare @Source nvarchar(max) = 'distinte'

set @TruncateStage = 'use' + ' ' + @Database + ' ' + 'truncate table' + ' ' + @SchemaStage + '.' + @Stage + ';'

set @Insert = '
' + 
'use' + ' ' + @Database + '
' + 'SET IDENTITY_INSERT' + ' ' + @SchemaStage + '.' + @Stage + ' ' + 'ON ' + '
' + 'insert into' + ' ' + @SchemaStage + '.' + @Stage + ' ' +
'
(
[id],
[scheda],
[item],
[quantita],
[descrizione],
[created_at],
[updated_at]
)
SELECT
id,
scheda,
item,
[quantità],
descrizione,
created_at,
updated_at
FROM OPENQUERY(' + @LinkedService + ',' + ' ' + '''SELECT * FROM' + ' ' + @Source + ''')' + ';'

set @Sql = @TruncateStage + @Insert

print @Sql

exec sp_executesql @Sql
SET IDENTITY_INSERT  dbo.Distinte OFF
end
--
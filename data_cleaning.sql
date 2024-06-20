drop table [dbo].[netflix_raw]

CREATE TABLE [dbo].[netflix_raw](
	[show_id] [varchar](10) PRIMARY KEY,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] [int] NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
) 


select * from netflix_raw
where show_id='s5023';
-- we handled the foreign characters by changing the properties of column

-- checking duplicates.
select show_id,count(*)
from netflix_raw
group by show_id
having count(*) > 1;

select title,count(*)
from netflix_raw
group by title
having count(*) > 1;

select * from netflix_raw
where title in (
select title from netflix_raw
group by title
having count(*) > 1
)
order by title;


select * from netflix_raw
where concat(title,type) in (
select concat(title,type) 
from netflix_raw
group by title,type
having count(*) > 1
)
order by title



with cte as (
select *
,ROW_NUMBER() over (partition by title , type order by show_id) as rn
from netflix_raw
)
select * from cte
where rn=1


--new table for listed_in director,cast,country

select show_id, trim(value) as director        -- trim is used to reomve space at the begging or end
into netflix_director						   -- the result will be put into new table called ntflix_director
from netflix_raw
cross apply string_split(director,',')		   -- it will split the director column using comma, and cross applys using show_id

select show_id ,trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

select show_id , trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')

select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')



--populate missing values in country, duration columns
select * from netflix_raw
where country is null

-- (we are getting the data of the directors and which country so that we can fill the null values in country field by director)
-- (if same director has multiple country we consider all the possible country to fill country null values)
select director,country
from netflix_country nc
inner join netflix_director nd on nc.show_id=nd.show_id
group by director,country
order by director
-- (this above code is for selecting the directors coutry)

insert into netflix_country 
select show_id,m.country
from netflix_raw nr
inner join(
select director,country
from netflix_country nc
inner join netflix_director nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null

-----------------------------------------
select * from netflix_raw where duration is null
--(from the above result, the duration values are inside rating column)

------------------------------------------------
--creating new table after removing duplicate data,conversion of data type,after handling missing values
-- we get the some part of the code from checking duplicates 

with cte as (
select *
,ROW_NUMBER() over (partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title, cast(date_added as date) as date_added, release_year,rating
,case when duration is null then rating else duration end as duration,description    --(from the above command result,taking rating as duration, else duration value remains same)
into netflix
from cte
where rn=1

select * from netflix

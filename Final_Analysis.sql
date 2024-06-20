-- Netflix data Analysis
use ananthdb1
go

/* 1) For each director count the number of movies and tv shows created by them in seperate columns
      for directors who have created both movies and tv shows */

SELECT nd.director
, count(distinct case when n.type='Movie' then n.show_id end) as no_of_movies
, count(distinct case when n.type='TV Show' then n.show_id end) as no_of_tv_shows
from netflix n
inner join netflix_director nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type) >1


-- 2) which country has highest number of comedy movies
select nc.country, count(distinct ng.show_id) as No_of_comedy_movies 
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix n on ng.show_id=n.show_id
where ng.genre='Comedies' and n.type='Movie'
group by nc.country
order by No_of_comedy_movies desc

-- 3) for each year (as per date added to netflix), which director has maximum number of movies released.
with cte as(
select nd.director as director,YEAR(n.date_added) as year,count(n.show_id) as no_of_movies
from netflix_director nd
inner join netflix n on nd.show_id=n.show_id
where n.type='Movie'
group by nd.director,YEAR(n.date_added)
) 
, cte2 as(
SELECT *
,ROW_NUMBER() over (partition by year order by no_of_movies desc,director) as rn
from cte
)

select * 
from cte2
where rn=1;

-- 4) What is average duration of movies in each genre

select ng.genre, avg(cast(replace(n.duration,'min','') as int)) as average_duration
from netflix_genre ng
inner join netflix n on ng.show_id=n.show_id
where n.type='Movie'
group by ng.genre
order by ng.genre

--5) find the list of directors who have created horror and comedy movies both
--    (display director name along with number of comedy and horror movies directed by them)

Select  nd.director
,count(distinct case when ng.genre='Comedies' then n.show_id end) as Comedy_movies
,count(distinct case when ng.genre='Horror Movies' then n.show_id end) as Horror_Movies
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
inner join netflix_director nd on n.show_id=nd.show_id
where n.type='Movie' and ng.genre in('Comedies' ,'Horror Movies')
group by nd.director
having count(distinct ng.genre)=2

----append the 2 tables from the database
with cte as (
select *from BIKES
union all
select*from BIKES1)

----Optimize a query for a Power Bi Report
select 
dteday,
season,
weekday,
hr,
price,
COGS,
a.yr,
riders,
rider_type,
riders*price as revenue,
riders*price -COGS as profit
from cte a
left join COSTS b
on a.yr=b.yr
----Exploratory Data Analysis

----Join all tables
select * from Absenteeism_at_work a 
left join compensation c
on a.id=c.id 
left join Reasons r 
on a.Reason_for_absence=r.Number

----The most common reason for absence is medical consultation
select count(reason) as count,
reason 
from Absenteeism_at_work a 
join Reasons r on
a.Reason_for_absence=r.Number 
group by reason 
order by 1 desc

----On Monday we have the highest average(absenteeism time)
----in hours per employee 
select day_of_the_week as day,
avg(absenteeism_time_in_hours) as avg 
from Absenteeism_at_work
group by day_of_the_week 
order by 2 desc

----Exploring age-related avg(absenteeism time)  
select avg(Absenteeism_time_in_hours) as avg,
Category_age 
from
(select Absenteeism_time_in_hours,
case 
when age<40 then 'A'
when age between 40 and 50 then'B'
when age>50 then 'C'
END AS Category_age
from Absenteeism_at_work) as p
group by Category_age
order by 1 desc
 
----Employees with fewer children(0-1) 
----have less avg(Absenteeism time) 
select son,
avg(Absenteeism_time_in_hours) as avg 
from Absenteeism_at_work 
group by son 
order by 2 desc

----Workload Category seems to have no effect on absenteeism time 
select workload_category,
avg(absenteeism_time_in_hours) as avg
from
(select absenteeism_time_in_hours,
case 
when Work_load_Average_day>300000 then 'Heavy_Workload'
when Work_load_Average_day<300000 then 'Easy_Workload'
end as Workload_Category
from  Absenteeism_at_work) as p
group by Workload_Category
order by 2 desc

----Employees with lower education level have higher avg(Absenteeism time)   
select education,
avg(Absenteeism_time_in_hours) as avg 
from Absenteeism_at_work 
group by Education 
order by 2 desc

----During the Spring and Summer months we have the most avg(absenteeism time) 
----in hours per employee 
select Season_name,
avg(Absenteeism_time_in_hours) as avg
from(
select Absenteeism_time_in_hours,
case 
when Month_of_absence in (12,1,2) then 'winter'
when Month_of_absence in (3,4,5) then 'Spring'
when Month_of_absence in (6,7,8) then 'Summer'
when Month_of_absence in (9,10,11) then 'Autumn'
end as Season_name
from Absenteeism_at_work) as p
group by Season_name
order by 2 desc

----The work-house distance seems to have no effect on absenteeism time 
select avg(Absenteeism_time_in_hours) as difficult_movement,
(select avg(Absenteeism_time_in_hours) 
from Absenteeism_at_work 
where Distance_from_Residence_to_Work<30) as easy_movement
from Absenteeism_at_work 
where Distance_from_Residence_to_Work>30

----Exploring the healthiest employees
select * from Absenteeism_at_work where social_drinker=0 and social_smoker=0
and body_mass_index between 19 and 25 and 
Absenteeism_time_in_hours<(select avg(Absenteeism_time_in_hours) 
from Absenteeism_at_work)

----Optimize a query for a Power Bi Dashboard
select a.id,
r.Reason,
Month_of_absence,
Body_mass_index,
case when Body_mass_index<18.5 then 'underweight'
when Body_mass_index between 18.5 and 25 then 'healthy weight'
when Body_mass_index between 25 and 30 then 'overweight'
when Body_mass_index>30 then 'obese'
else 'null' end as bmi_category,
case when Month_of_absence in (12,1,2) then 'winter'
when Month_of_absence in (3,4,5) then 'Spring'
when Month_of_absence in (6,7,8) then 'Summer'
when Month_of_absence in (9,10,11) then 'Autumn'
else 'null' end as season_names,
Seasons,
Day_of_the_week,
Transportation_expense,
Education,
Son,
Social_drinker,
Social_smoker,
Pet,
Disciplinary_failure,
age,
Work_load_Average_day,
Absenteeism_time_in_hours
from Absenteeism_at_work a left join compensation c
on a.id=c.id left join Reasons r on a.Reason_for_absence=r.Number
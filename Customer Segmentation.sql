----Exploratory Data Analysis

----Exploring unique values
SELECT distinct(dealsize) from salesdata
select distinct(status) from salesdata
select distinct(year_id) from salesdata
select distinct(productline) from salesdata
select distinct(country) from salesdata
select count(distinct(country)) from salesdata
select distinct(territory) from salesdata
select distinct(qtr_id) from salesdata
select distinct(orderlinenumber) from salesdata
select distinct(msrp) from salesdata
select distinct(month_id) from salesdata where year_id=2003
select distinct(month_id) from salesdata where year_id =2004
select distinct(month_id) from salesdata where year_id =2005----In 2005 business operated only for 5 months
 
----revenue for each productline
select productline,sum(sales) as revenue from salesdata
group by productline order by revenue desc

----revenue by year
select year_id as year,sum(sales) as revenue from salesdata group by year_id
order by sum(sales) desc

----revenue by size
select dealsize,sum(sales) as revenue from salesdata group by dealsize order by sum(sales) desc

----What was the best month for sales in 2003? How much was earned that month? 
select month_id,sum(sales) as revenue,count(ordernumber) as totalorders from salesdata where year_id=2003 group by month_id order by 2 desc

----November was the best month in the previous query.Now i explore the productline for November 2003,2004

select month_id as month,productline,count(*) as totalorders,sum(sales) as revenue from salesdata where month_id=11 and year_id=2003 group by month_id,productline order by 4 desc
select month_id as month,productline,count(*) as totalorders,sum(sales) as revenue from salesdata where month_id=11 and year_id=2004 group by month_id,productline order by 4 desc

----This query shows that USA is the best performing country for revenue
select country,sum(sales) as revenue from salesdata  group by country order by 2 desc 

----Best performing city in USA
select city,sum(sales) as revenue from salesdata where country='USA' group by city order by 2 desc

----What is the best product in USA?
select productcode,sum(sales) as revenue from salesdata where country='USA' group by productcode order by 2 desc

----The code below shows the main part of the Project
----Who is the best Customer?I create a customer segmentation analysis using the RFM technique

DROP TABLE IF EXISTS #rfm
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from salesdata) as max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from salesdata )) as Recency
        from salesdata
	    group by CUSTOMERNAME
),
rfm_calc as
(

	select *,
		NTILE(4) OVER (order by Recency desc) as rfm_recency,
		NTILE(4) OVER (order by Frequency) as rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) as rfm_monetary
	from rfm 
)
select 
	*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar) as rfm_cell_string
into #rfm
from rfm_calc 

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'big spenders who havent purchased lately'
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' ----(Customers who buy often and recently, but dont spend too much )
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm


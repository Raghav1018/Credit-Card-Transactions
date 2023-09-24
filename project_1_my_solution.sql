--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

WITH city_wise_spend AS(SELECT city, SUM(amount) AS city_total_amount
FROM credit_card_transcations$
GROUP BY city)

, total AS(SELECT SUM(amount) AS total_amount
FROM credit_card_transcations$)

SELECT TOP 5 city, city_total_amount, ROUND(100*city_total_amount/total_amount,2) AS percentage_contribution
FROM city_wise_spend
INNER JOIN total ON 1=1
ORDER BY city_total_amount DESC;


--2- write a query to print highest spend month and amount spent in that month for each card type



WITH month_spend AS(SELECT card_type, DATEPART(year,transaction_date) AS t_year, DATEPART(month,transaction_date) AS t_month, SUM(amount) AS total_amount
FROM credit_card_transcations$
GROUP BY card_type, DATEPART(year,transaction_date),DATEPART(month,transaction_date))


, ranking AS(SELECT *, RANK() OVER(PARTITION BY card_type ORDER BY total_amount DESC, t_year,t_month) AS rnk
FROM month_spend)

SELECT card_type,t_year,t_month, total_amount
FROM ranking
WHERE rnk=1;



--3 write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)



with cte as (
select *,sum(amount) over(partition by card_type order by transaction_date,transaction_id) as total_spend
from credit_card_transcations$
--order by card_type,total_spend desc
)
select * from (select *, rank() over(partition by card_type order by total_spend) as rn  
from cte where total_spend >= 1000000) a where rn=1;


--4- write a query to find city which had lowest percentage spend for gold card type

SELECT TOP 1 city,SUM(CASE WHEN card_type='Gold' THEN amount ELSE 0 END) *100/SUM(amount) gold_percentage
FROM credit_card_transcations$
GROUP BY city
HAVING SUM(CASE WHEN card_type='Gold' THEN amount ELSE 0 END)>0
ORDER BY gold_percentage;


--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)


WITH city_wise_exp AS(SELECT city,exp_type,SUM(amount) AS total_amount
FROM credit_card_transcations$
GROUP BY city,exp_type)

, rn AS(SELECT *, RANK() OVER(PARTITION BY city ORDER BY total_amount) rn_asc
 , RANK() OVER(PARTITION BY city  ORDER BY total_amount DESC) rn_des
FROM city_wise_exp)


SELECT city, MAX(CASE WHEN rn_asc=1 THEN exp_type END) lowest_expense_type, MAX(CASE WHEN rn_des=1 THEN exp_type END) highest_expense_type
FROM rn
GROUP BY city;




--6- write a query to find percentage contribution of spends by females for each expense type


WITH female_expense AS(SELECT exp_type,SUM(amount) as total_amount,SUM(CASE WHEN gender='F' THEN amount ELSE 0 END) AS total_female_amount
FROM credit_card_transcations$
GROUP BY exp_type)


SELECT exp_type, ROUND(total_female_amount*100/total_amount,2) AS female_contribution
FROM female_expense
ORDER BY female_contribution DESC;




--7 7- which card and expense type combination saw highest month over month growth in Jan-2014



WITH card_expense AS(SELECT card_type,exp_type,DATEPART(YEAR,transaction_date) AS yt, DATEPART(MONTH,transaction_date) AS mt, SUM(amount) AS current_spend
FROM credit_card_transcations$
GROUP BY card_type,exp_type,DATEPART(YEAR,transaction_date),DATEPART(MONTH,transaction_date))

, prev_cards_expense AS(SELECT *, LAG(current_spend,1) OVER(PARTITION BY card_type,exp_type ORDER BY yt,mt) prev_month_spend
FROM card_expense
)

SELECT  TOP 1*, current_spend-prev_month_spend/prev_month_spend AS mom_growth
FROM prev_cards_expense
WHERE prev_month_spend >0 AND  yt=2014 AND mt=1 
ORDER BY mom_growth DESC;


--8- during weekends which city has highest total spend to total no of transcations ratio 


SELECT TOP 1 city, SUM(amount) *100/COUNT(*) AS ratio
FROM credit_card_transcations$
WHERE DATENAME(WEEKDAY,transaction_date) IN ('Saturday','Sunday')
GROUP BY city
ORDER BY ratio DESC;

-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city


WITH A AS(SELECT city, transaction_date, ROW_NUMBER() OVER(PARTITION BY city ORDER BY transaction_date ) rnk
FROM credit_card_transcations$)


select TOP 1 city,DATEDIFF(DAY,MIN(transaction_date),MAX(transaction_date)) duration from A
WHERE rnk=500 OR rnk=1
GROUP BY city
HAVING COUNT(*)=2
ORDER BY duration;























, 






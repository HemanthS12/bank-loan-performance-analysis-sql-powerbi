--KPI Queries:

-- Total Loan Applications
select COUNT(id) as Total_Loan_Applications
from bank_loan_data;

-- MTD Loan Applications
select COUNT(id) as MTD_Total_Loan_Applications
from bank_loan_data
where MONTH(issue_date) = MONTH((select MAX(issue_date) from bank_loan_data))
  and YEAR(issue_date) = YEAR((select MAX(issue_date) from bank_loan_data));

-- MOM Loan Applications
WITH Monthly_Applications AS (
    SELECT 
        YEAR(issue_date) AS Year_data,
        MONTH(issue_date) AS Month_data,
        COUNT(id) AS Total_Applications
    FROM bank_loan_data
    GROUP BY YEAR(issue_date), MONTH(issue_date)
)
select cast(round(((curr.Total_Applications - prev.Total_Applications) * 100.0 / nullif(prev.Total_Applications, 0)), 2) as decimal(10, 2)) as MOM_percentage
from Monthly_Applications curr
join Monthly_Applications prev	
on curr.Year_data = prev.Year_data
and curr.Month_data = prev.Month_data + 1
where curr.Month_data = (select Month(max(issue_date)) from bank_loan_data)
and curr.Year_data = (select YEAR(max(issue_date)) from bank_loan_data);
------------------------------------------------------------------------------------------------
-- Total Funded Amount
select SUM(loan_amount) as Total_Funded_Amount 
from bank_loan_data;

-- MTD Total Funded Amount
select SUM(loan_amount) as MTD_Total_Funded_Amount
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data));

-- MOM Total Funded Amount
with Curr_Mnth_Amt as
(
select SUM(loan_amount) as MTD_Total_Funded_Amount
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data))
),
Prev_Mnth_Amt as
(
select SUM(loan_amount) as Prev_Mnth_Total_Funded_Amount
from bank_loan_data
where MONTH(issue_date) = MONTH(dateadd(MONTH, -1, (select MAX(issue_date) from bank_loan_data)))
and YEAR(issue_date) = YEAR(dateadd(MONTH, -1, (select MAX(issue_date) from bank_loan_data)))
)
select cast(round(((cma.MTD_Total_Funded_Amount - pma.Prev_Mnth_Total_Funded_Amount) * 100.0 / nullif(pma.Prev_Mnth_Total_Funded_Amount, 0)), 2) as decimal(10, 2)) as MOM_Total_Funded_Amount
from Curr_Mnth_Amt cma
cross join Prev_Mnth_Amt pma;

/*
with Month_data_applications as
(
select YEAR(issue_date) as year_data,
MONTH(issue_date) as month_data,
SUM(loan_amount) as Total_Funded_Amount
from bank_loan_data
group by YEAR(issue_date), MONTH(issue_date)
)
select *,
cast(round(((curr_mnth.Total_Funded_Amount - prev_mnth.Total_Funded_Amount) * 100.0 / prev_mnth.Total_Funded_Amount), 2) as decimal(10, 2)) as MOM_Total_Funded_Amount
from Month_data_applications curr_mnth
join Month_data_applications prev_mnth
on curr_mnth.year_data = prev_mnth.year_data
and curr_mnth.month_data = prev_mnth.month_data + 1
where curr_mnth.month_data = (select MONTH(max(issue_date)) from bank_loan_data)
and curr_mnth.year_data = (select YEAR(MAX(issue_date)) from bank_loan_data)
*/
------------------------------------------------------------------------------------------------
-- Total Amount Received
select SUM(total_payment) as Total_Amount_Received
from bank_loan_data;

-- MTD Total Amount Received
select SUM(total_payment) as MTD_Total_Amount_Received
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data));

-- MOM Total Amount Received
with curr_mnth as
(
select SUM(total_payment) as Curr_Mnth_Total_Amount_Received
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data))
),
prev_mnth as
(
select SUM(total_payment) as Prev_Mnth_Total_Amount_Received
from bank_loan_data
where MONTH(issue_date) = month(DATEADD(month, -1, (select max(issue_date) from bank_loan_data)))
and YEAR(issue_date) = year(DATEADD(month, -1, (select max(issue_date) from bank_loan_data)))
)
select 
cast(round(((cm.Curr_Mnth_Total_Amount_Received - pm.Prev_Mnth_Total_Amount_Received) * 100.0 / nullif(pm.Prev_Mnth_Total_Amount_Received, 0)), 2) as decimal(10, 2)) as MOM_Total_Amount_Received
from curr_mnth cm
cross join prev_mnth pm;

/*
with cte1 as
(
select YEAR(issue_date) as year_data,
MONTH(issue_date) as month_data,
SUM(total_payment) as total_amount_received
from bank_loan_data
group by YEAR(issue_date), MONTH(issue_date)
)
select *,
cast(round(((curr.total_amount_received - prev.total_amount_received) * 100.0 / prev.total_amount_received), 2) as decimal(10, 2)) as MOM_total_amount_received
from cte1 curr
join cte1 prev
on curr.year_data = prev.year_data
and curr.month_data = prev.month_data + 1
*/
------------------------------------------------------------------------------------------------
-- Average Interest Rate
select round(AVG(int_rate), 4) * 100 as Avg_Interest_Rate
from bank_loan_data;

-- MTD Average Interest Rate
select round(AVG(int_rate), 4) * 100 as MTD_Avg_Interest_Rate
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data));

-- MOM Average Interest Rate
with latest as
(
select MAX(issue_date) as max_date from bank_loan_data
),
curr_mnth as
(
select round(AVG(int_rate), 4) * 100 as Curr_Mnth_Avg_Interest_Rate
from bank_loan_data
where MONTH(issue_date) = MONTH((select max_date from latest))
and YEAR(issue_date) = YEAR((select max_date from latest))
),
prev_mnth as
(
select round(AVG(int_rate), 4) * 100 as Prev_Mnth_Avg_Interest_Rate
from bank_loan_data
where MONTH(issue_date) = month(DATEADD(month, -1, (select max_date from latest)))
and YEAR(issue_date) = year(DATEADD(month, -1, (select max_date from latest)))
)
select 
cast(round(((currm.Curr_Mnth_Avg_Interest_Rate - prevm.Prev_Mnth_Avg_Interest_Rate) / nullif(prevm.Prev_Mnth_Avg_Interest_Rate, 0) * 100.0), 2) as decimal(10, 2)) as MOM_Avg_Interest_Rate
from curr_mnth currm
cross join prev_mnth prevm;

/*
with monthly_applications as
(
select YEAR(issue_date) as year_data,
MONTH(issue_date) as month_data,
round(AVG(int_rate), 4) * 100 as Avg_Interest_Rate
from bank_loan_data
group by YEAR(issue_date), MONTH(issue_date)
)
select *,
cast(round(((curr.Avg_Interest_Rate - prev.Avg_Interest_Rate) / prev.Avg_Interest_Rate * 100), 2) as decimal(10, 2)) as MOM_Avg_Interest_Rate
from monthly_applications curr
join monthly_applications prev
on curr.year_data = prev.year_data
and curr.month_data = prev.month_data + 1
*/
------------------------------------------------------------------------------------------------
-- Average Debt-to-Income Ratio (DTI)
select round(AVG(dti), 4) * 100 as Avg_DTI
from bank_loan_data;

-- MTD Average DTI
select round(AVG(dti), 4) * 100 as MTD_Avg_DTI
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data));

-- MOM Average DTI
with curr_mnth_avg_dti as
(
select round(AVG(dti), 4) * 100 as Curr_Mnth_Avg_DTI
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data))
),
prev_mnth_avg_dti as
(
select round(AVG(dti), 4) * 100 as Prev_Mnth_Avg_DTI
from bank_loan_data
where MONTH(issue_date) = month(DATEADD(month, -1, (select max(issue_date) from bank_loan_data)))
and YEAR(issue_date) = year(DATEADD(month, -1, (select max(issue_date) from bank_loan_data)))
)
select
round(((currm.Curr_Mnth_Avg_DTI - prevm.Prev_Mnth_Avg_DTI) / nullif(prevm.Prev_Mnth_Avg_DTI, 0) * 100.0), 2) as MOM_Average_DTI
from curr_mnth_avg_dti currm
cross join prev_mnth_avg_dti prevm;

/*
with mnth_calc as
(
select YEAR(issue_date) as year_data,
MONTH(issue_date) as mnth_data,
round(avg(dti), 4) * 100 as avg_dti
from bank_loan_data
group by YEAR(issue_date), MONTH(issue_date)
)
select curr_mnth.year_data, curr_mnth.mnth_data as curr_mnth_data, curr_mnth.avg_dti as curr_mnth_avg_dti, prev_mnth.mnth_data as prev_mnth_data, prev_mnth.avg_dti as prev_mnth_avg_dti,
round(((curr_mnth.avg_dti - prev_mnth.avg_dti) / prev_mnth.avg_dti * 100), 2) as MOM_Avg_DTI
from mnth_calc curr_mnth
join mnth_calc prev_mnth
on curr_mnth.year_data = prev_mnth.year_data
and curr_mnth.mnth_data = prev_mnth.mnth_data + 1
order by curr_mnth.mnth_data asc;
*/
------------------------------------------------------------------------------------------------
-- Good Loan vs Bad Loan KPI's

-- Good Loan Application Percentage
select 
cast(round(COUNT(case when loan_status = 'Fully Paid' or loan_status = 'Current' then id end) * 100.0
/
COUNT(id), 2) as decimal(10, 2)) as Good_Loan_Percentage
from bank_loan_data;

-- Good Loan Applications
select COUNT(id) as Good_Loan_Applications
from bank_loan_data
where loan_status = 'Fully Paid' or loan_status = 'Current';

-- Good Loan Funded Amount
select SUM(loan_amount) as Good_Loan_Funded_Amount
from bank_loan_data
where loan_status in ('Fully Paid', 'Current');

-- Good Loan Total Received Amount
select SUM(total_payment) as Good_Loan_Received_Amount
from bank_loan_data
where loan_status in ('Fully Paid', 'Current');
------------------------------------------------------------------------------------------------
-- Bad Loan Total Application Percentage
select
cast(round(COUNT(case when loan_status = 'Charged Off' then id end) * 100.0
/
COUNT(id), 2) as decimal(10, 2)) as Bad_Loan_Percentage
from bank_loan_data;

-- Bad Loan Applications
select COUNT(id) as Bad_Loan_Applications
from bank_loan_data
where loan_status = 'Charged Off';

-- Bad Loan Funded Amount
select SUM(loan_amount) as Bad_Loan_Funded_Amount
from bank_loan_data
where loan_status = 'Charged Off';

-- Bad Loan Total Received Amount
select SUM(total_payment) as Bad_Loan_Amount_Received
from bank_loan_data
where loan_status = 'Charged Off';
------------------------------------------------------------------------------------------------
-- Loan Status
select loan_status, 
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received,
round(AVG(int_rate) * 100.0, 2) as Avg_Int_Rate,
round(AVG(dti) * 100.0, 2) as Avg_DTI
from bank_loan_data
group by loan_status;

select loan_status,
SUM(loan_amount) as MTD_Funded_Amount,
SUM(total_payment) as MTD_Amount_Received
from bank_loan_data
where MONTH(issue_date) = MONTH((select max(issue_date) from bank_loan_data))
and YEAR(issue_date) = YEAR((select max(issue_date) from bank_loan_data))
group by loan_status;
------------------------------------------------------------------------------------------------
-- Overview
-- Metrics to be shown: Total Loan Applications, Total Funded Amount, and Total Amount Received

-- Monthly trends by Issue Date
select 
MONTH(issue_date) as Month_Num,
DATENAME(MONTH, issue_date) as Month_Name,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by MONTH(issue_date), DATENAME(MONTH, issue_date)
order by Month_Num;

-- Regional Analysis by State
select address_state, 
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by address_state
order by SUM(loan_amount) desc;

-- Loan Term Analysis
select term,
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by term;

-- Employee Length Analysis
select emp_length,
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by emp_length
order by COUNT(id) desc;

-- Loan Purpose Breakdown
select purpose,
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by purpose
order by COUNT(id) desc;

-- Home Ownership Analysis
select home_ownership,
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
group by home_ownership
order by COUNT(id) desc;

-- Applying Multiple Filters
select home_ownership,
COUNT(id) as Total_Loan_Applications, 
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Amount_Received
from bank_loan_data
where grade = 'A' and address_state = 'CA' and loan_status = 'Fully Paid'
group by home_ownership
order by COUNT(id) desc;
------------------------------------------------------------------------------------------------
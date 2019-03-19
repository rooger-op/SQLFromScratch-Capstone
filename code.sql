-- 1 
SELECT *
FROM subscriptions
LIMIT 100;

SELECT *
FROM subscriptions
GROUP BY segment;

-- 2
SELECT MIN(subscription_start), MAX(subscription_end)
FROM subscriptions;

-- 3 
WITH months AS
(SELECT
'2017-01-01' as first_day,
'2017-01-31' as last_day
UNION
SELECT
'2017-02-01' as first_day,
'2017-02-28' as last_day
UNION
SELECT
'2017-03-01' as first_day,
'2017-03-31' as last_day
),

--4
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

--5
status AS
(SELECT id, first_day as month,
CASE
WHEN (subscription_start < first_day)
AND (
subscription_end > first_day
OR subscription_end IS NULL
)
THEN 1
ELSE 0
END as is_active,
CASE
WHEN (subscription_end BETWEEN first_day AND
last_day)
THEN 1
ELSE 0
END as is_canceled FROM cross_join),

--6
status_aggregate AS
(SELECT
month,
SUM(is_active) as sum_active,
SUM(is_canceled) as sum_canceled
FROM status
GROUP BY month)
SELECT month,
1.0*sum_canceled/sum_active as 'overall
churn_rate'
FROM status_aggregate;

--7
status_aggregate AS
(SELECT
month,
SUM(is_active) as sum_active,
SUM(is_active_30) as sum_active_30,
SUM(is_active_87) as sum_active_87,
SUM(is_canceled) as sum_canceled,
SUM(is_canceled_30) as sum_canceled_30,
SUM(is_canceled_87) as sum_canceled_87
FROM status
GROUP BY month)

-- Full code to calculate the churn rates for the two segments over the first three months

 --Create a temporary table for months
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
--Cross Join the Months table and the subscriptions table
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
--Create a temporary status table 
status AS
(SELECT id, first_day as month,
  CASE
  WHEN (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    )
 THEN 1
  ELSE 0
END as is_active,
CASE
WHEN (subscription_end BETWEEN first_day AND last_day)
THEN 1
ELSE 0
END as is_canceled,
 CASE
  WHEN (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    )
 AND segment = 87
 THEN 1
  ELSE 0
END as is_active_87,

CASE
WHEN (subscription_end BETWEEN first_day AND last_day) AND ( segment= 87) 
THEN 1
ELSE 0
END as is_canceled_87,
 CASE
  WHEN (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) 
   AND segment = 30
 THEN 1
  ELSE 0
END as is_active_30,
CASE
WHEN (subscription_end BETWEEN first_day AND last_day) AND ( segment= 30) 
THEN 1
ELSE 0
END as is_canceled_30

FROM cross_join),

--Create the segments
status_aggregate AS
(SELECT
  month,
 SUM(is_active) as sum_active,
  SUM(is_active_30) as sum_active_30,
  SUM(is_active_87) as sum_active_87, 
 SUM(is_canceled) as sum_canceled,
  SUM(is_canceled_30) as sum_canceled_30,
  SUM(is_canceled_87) as sum_canceled_87
FROM status
GROUP BY month)

-- Calculating churn rates for each month and each segment
SELECT month, 
1.0*sum_canceled/sum_active as total_churn_rate,
1.0*sum_canceled_30/sum_active_30 as churn_rate_30,
1.0*sum_canceled_87/sum_active_87 as churn_rate_87
FROM status_aggregate;

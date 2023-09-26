// CustomerID,Age,Gender,Tenure,Usage Frequency,Support Calls,Payment Delay,Subscription Type,Contract Length,Total Spend,Last Interaction,Churn
create database churn;

use churn;

CREATE TABLE churn_source (
  CustomerID string NOT NULL comment "客户ID",
  Age string NOT NULL comment "客户年龄",
  Gender string NOT NULL comment "客户性别",
  Tenure string NOT NULL comment "客户存活时间",
  Usage_Frequency string NOT NULL comment "客户使用频率",
  Support_Calls string NOT NULL comment "客户电话",
  Payment_Delay string NOT NULL comment "付款延迟",
  Subscription_Type string NOT NULL comment "订阅类型",
  Contract_Length string NOT NULL comment "合同期限",
  Total_Spend string NOT NULL comment "总支出",
  Last_Interaction string NOT NULL comment "上次活跃",
  Churn string NOT NULL  comment "是否流失"
)
row format delimited fields terminated by ',';

load data inpath '/churn.csv' into table churn.churn_source;

//总数统计
create table if not exists chrun_sum comment "总数统计" as SELECT
  COUNT(*) AS total_count,
  SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END) AS non_churn_count,
  SUM(CASE WHEN Churn != 0 THEN 1 ELSE 0 END) AS churn_count
FROM churn_source;

// 流失客户性别统计
create table if not exists chrun_gender comment "流失客户性别统计" as
SELECT Gender, COUNT(*) AS total_count
FROM churn_source where Churn = 0
GROUP BY Gender;


// 流失客户按年龄分布统计
create table if not exists chrun_age comment "流失客户按年龄分布统计" as
SELECT
  CASE
    WHEN Age < 20 THEN 'Under 20'
    WHEN Age BETWEEN 20 AND 29 THEN REPLACE(SUBSTRING('20s', 1, LENGTH('20s') - 1), 's', '')
    WHEN Age BETWEEN 30 AND 39 THEN REPLACE(SUBSTRING('30s', 1, LENGTH('30s') - 1), 's', '')
    WHEN Age BETWEEN 40 AND 49 THEN REPLACE(SUBSTRING('40s', 1, LENGTH('40s') - 1), 's', '')
    WHEN Age BETWEEN 50 AND 59 THEN REPLACE(SUBSTRING('50s', 1, LENGTH('50s') - 1), 's', '')
    ELSE '60 or older'
  END AS age_group,
  COUNT(*) AS total_count
FROM churn_source
where Churn = 0
GROUP BY
  CASE
    WHEN Age < 20 THEN 'Under 20'
    WHEN Age BETWEEN 20 AND 29 THEN REPLACE(SUBSTRING('20s', 1, LENGTH('20s') - 1), 's', '')
    WHEN Age BETWEEN 30 AND 39 THEN REPLACE(SUBSTRING('30s', 1, LENGTH('30s') - 1), 's', '')
    WHEN Age BETWEEN 40 AND 49 THEN REPLACE(SUBSTRING('40s', 1, LENGTH('40s') - 1), 's', '')
    WHEN Age BETWEEN 50 AND 59 THEN REPLACE(SUBSTRING('50s', 1, LENGTH('50s') - 1), 's', '')
   ELSE '60 or older'
  END;

// 按订阅类型分组统计
create table if not exists chrun_sub comment "按订阅类型分组统计" as
SELECT COALESCE(NULLIF(TRIM(subscription_type), ''), 'none') AS subscription_type, COUNT(*) AS total_count
FROM churn_source
GROUP BY COALESCE(NULLIF(TRIM(subscription_type), ''), 'none');


// 流失客户按年龄分组统计取前十
create table if not exists chrun_age_top10 comment "流失客户按年龄分组统计取前十" as
SELECT Age, COUNT(*) AS churn_count
FROM churn_source
WHERE Churn = 0
GROUP BY Age
ORDER BY churn_count DESC
LIMIT 10;

// 按活跃时间分组统计流失人数
create table if not exists chrun_Interaction comment "按活跃时间分组统计流失人数" as
SELECT COALESCE(NULLIF(TRIM(Last_Interaction), ''), 'none') as Last_Interaction , 
COALESCE(NULLIF(TRIM(Churn), ''), 'none') as Churn , COUNT(*) AS total_count
FROM churn_source where Churn = 0
GROUP BY Last_Interaction, Churn;

// 按订阅时长统计流失人数
create table if not exists chrun_Contract comment "按订阅时长统计流失人数" as
SELECT Contract_Length, COUNT(*) AS life
FROM churn_source
WHERE Churn = 0
GROUP BY Contract_Length
order by life desc;

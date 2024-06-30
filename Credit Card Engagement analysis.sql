Create database credit_analysis;
use credit_analysis


/* Create table for customerDemographics and transactionalData*/

CREATE TABLE CustomerDemographics (
    customer_id INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(10),
    Income_level VARCHAR(10),
    Location VARCHAR(50),
    Education_level VARCHAR(20)
);

CREATE TABLE TransactionalData (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    transaction_date DATETIME,
    amount_spent FLOAT,
    merchant_category VARCHAR(20),
    reward_points_earned INT,
    card_type varchar(20),
    FOREIGN KEY (customer_id) REFERENCES CustomerDemographics(customer_id)
);

select * from TransactionalData


/* Customer Engagement Analysis*/

-- Total amount spent per customer
SELECT customer_id, SUM(amount_spent) AS total_spent
FROM TransactionalData
GROUP BY customer_id;

-- Average spend per transaction by card type
SELECT card_type, AVG(amount_spent) AS avg_spent
FROM TransactionalData
GROUP BY card_type;

-- Number of transactions by card type
SELECT card_type, COUNT(*) AS transaction_count
FROM TransactionalData
GROUP BY card_type;

-- Share of Wallet (SoW) Calculation
-- Calculate total spend for internal and external cards per customer

SELECT customer_id,
       SUM(CASE WHEN card_type = 'Internal' THEN amount_spent ELSE 0 END) AS internal_spent,
       SUM(CASE WHEN card_type = 'External' THEN amount_spent ELSE 0 END) AS external_spent
FROM TransactionalData
GROUP BY customer_id;

-- Number of trnsactions on Internal Card
SELECT COUNT(*) 
FROM TransactionalData 
WHERE card_type = 'Internal';

-- Number of trnsactions on External Card
SELECT COUNT(*) 
FROM TransactionalData 
WHERE card_type = 'External';

-- Transaction date and customer Id of Internal card users
SELECT customer_id, transaction_date
FROM TransactionalData 
WHERE card_type = 'Internal' 
ORDER BY transaction_date DESC 
LIMIT 10;

-- -- Transaction date and customer Id of External card users
SELECT customer_id, transaction_date
FROM TransactionalData 
WHERE card_type = 'External' 
ORDER BY transaction_date DESC 
LIMIT 10;

-- This query calculates the total number of transactions, average transaction amount,
-- and the counts of internal and external card transactions for each customer.

SELECT
    customer_id AS CustomerID,
    COUNT(DISTINCT transaction_id) AS NumTransactions,
    AVG(amount_spent) AS AvgTransactionAmount,
    SUM(CASE WHEN card_type = 'Internal' THEN 1 ELSE 0 END) AS NumInternalTransactions,
    SUM(CASE WHEN card_type = 'External' THEN 1 ELSE 0 END) AS NumExternalTransactions
FROM
    transactionaldata
GROUP BY
    customer_id;
    
-- Identify customers who have not made internal transactions in the past 3 months
-- but have made transactions with external cards, including reward points analysis.
SELECT
    t1.customer_id,
    COUNT(DISTINCT t1.transaction_id) AS num_external_transactions,
    AVG(t1.amount_spent) AS avg_external_transaction_amount,
    SUM(t1.reward_points_earned) AS total_external_reward_points,
    MAX(t1.transaction_date) AS last_external_transaction_date,
    t2.num_internal_transactions,
    t2.avg_internal_transaction_amount,
    t2.total_internal_reward_points,
    t2.last_internal_transaction_date
FROM
    transactionaldata t1
LEFT JOIN
    (SELECT
        customer_id,
        COUNT(DISTINCT transaction_id) AS num_internal_transactions,
        AVG(amount_spent) AS avg_internal_transaction_amount,
        SUM(reward_points_earned) AS total_internal_reward_points,
        MAX(transaction_date) AS last_internal_transaction_date
     FROM
        transactionaldata
     WHERE
        card_type = 'Internal'
     GROUP BY
        customer_id) t2
ON t1.customer_id = t2.customer_id
WHERE
    t1.card_type = 'External'
    AND (t2.last_internal_transaction_date IS NULL OR t2.last_internal_transaction_date < CURDATE() - INTERVAL 3 MONTH)
GROUP BY
    t1.customer_id;


-- Identify customers who have not made external transactions in the past 3 months
-- but have made transactions with internal cards, including reward points analysis.
SELECT
    t1.customer_id,
    COUNT(DISTINCT t1.transaction_id) AS num_internal_transactions,
    AVG(t1.amount_spent) AS avg_internal_transaction_amount,
    SUM(t1.reward_points_earned) AS total_internal_reward_points,
    MAX(t1.transaction_date) AS last_internal_transaction_date,
    t2.num_external_transactions,
    t2.avg_external_transaction_amount,
    t2.total_external_reward_points,
    t2.last_external_transaction_date
FROM
    transactionaldata t1
LEFT JOIN
    (SELECT
        customer_id,
        COUNT(DISTINCT transaction_id) AS num_external_transactions,
        AVG(amount_spent) AS avg_external_transaction_amount,
        SUM(reward_points_earned) AS total_external_reward_points,
        MAX(transaction_date) AS last_external_transaction_date
     FROM
        transactionaldata
     WHERE
        card_type = 'External'
     GROUP BY
        customer_id) t2
ON t1.customer_id = t2.customer_id
WHERE
    t1.card_type = 'Internal'
    AND (t2.last_external_transaction_date IS NULL OR t2.last_external_transaction_date < CURDATE() - INTERVAL 3 MONTH)
GROUP BY
    t1.customer_id;

-- Calculate average reward points earned per transaction for internal cards
SELECT
    'Internal' AS CardType,
    AVG(reward_points_earned) AS AvgRewardPoints
FROM
    TransactionalData
WHERE
    card_type = 'Internal';

-- Calculate average reward points earned per transaction for external cards
SELECT
    'External' AS CardType,
    AVG(reward_points_earned) AS AvgRewardPoints
FROM
    TransactionalData
WHERE
    card_type = 'External';
    
    
    -- Calculate Share of Wallet (SoW) percentage for internal cards
SELECT
    'Internal' AS CardType,
    SUM(amount_spent) / (SELECT SUM(amount_spent) FROM TransactionalData) * 100 AS SoW_Percentage
FROM
    TransactionalData
WHERE
    card_type = 'Internal';

-- Calculate Share of Wallet (SoW) percentage for external cards
SELECT
    'External' AS CardType,
    SUM(amount_spent) / (SELECT SUM(amount_spent) FROM TransactionalData) * 100 AS SoW_Percentage
FROM
    TransactionalData
WHERE
    card_type = 'External';



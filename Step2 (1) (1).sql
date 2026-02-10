# 1.  What med did we spend the most money on in total?

SELECT
  med_name,
  sum (total_value) AS total_money
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock in'
GROUP BY
  med_name
ORDER BY
  total_money DESC;

-- Answer: Vetmedin (Pimobendan) with 1035780.0 $


  # 2. What med had the highest monthly total_value spent on patients? At what month?
  -- This question is not clear, is it the purchse of med or spending of med. Therefore both analyzes.

  -- Purchase
SELECT
  month,
  med_name,
  SUM (total_value) AS total_money
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock in'
GROUP BY
  month,
  med_name
ORDER BY
  total_money DESC
  LIMIT 1;

-- Answer: Vetmedin (Pimobendan) in December 2024 for the purchse of med for patient

-- Spending
SELECT
  month,
  med_name,
  SUM (total_value) AS total_money
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock out'
GROUP BY
  month,
  med_name
ORDER BY
  total_money DESC
  LIMIT 1;

-- Answer: In November 2024, the highest spending to patients was Palladia (Toceranib Phosphate)


# 3.  What month was the highest in packs of meds spent in vet clinic?

SELECT
  month,
  ROUND (SUM (total_packs), 2) AS tot_packs
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock out'
GROUP BY
  month
ORDER BY
  tot_packs DESC;

-- Answer: December 2024, it was spent the highest packs with 3861.62 packs


# 4.  What's an average monthly spent in packs of the med that generated the most revenue?

-- First, find the med with the most revenue
SELECT
  med_name,
  SUM (total_value) AS revenue
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock out'
GROUP BY
  med_name
ORDER BY
  revenue DESC
  LIMIT 1;

-- Palladia (Toceranib Phosphate) had the most revenue with 630500.0 $

-- Calculate the monthly spending in packs for this particular med. Behaviour in general, in which month is the spending much higher.

SELECT
  month,
  SUM(total_packs) AS total_packs_spent,
  SUM (total_value) AS total_money
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
WHERE
  stock_movement = 'stock out'
  AND med_name = 'Palladia (Toceranib Phosphate)'
GROUP BY
  month
ORDER BY
  total_money DESC;

-- There are big differences in monthly spending in this med from 2250 $ to 50000 $. Therefore it is important to have a view on which month there ar the most and when there are not so much spending.

# What is the average monthly spending for this particular med

WITH monthly AS (
  SELECT
    month,
    SUM(total_value) AS month_total
  FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
  WHERE
  stock_movement = 'stock out'
  AND 
  med_name = 'Palladia (Toceranib Phosphate)'
  GROUP BY month
)

SELECT
  ROUND (AVG (month_total), 2) AS avg_monthly_spending
FROM
  monthly;

-- Answer: Average monthly spending for this med is 26270.83 $

# Additional Query for the Net Stock Change per month and med to see the stock of med and values comparison stock in and stock out.

SELECT
  month,
  med_name,
  SUM(
    CASE 
      WHEN stock_movement = 'stock in' THEN total_packs
      WHEN stock_movement = 'stock out' THEN -total_packs
    END
  ) AS net_packs_change,
  SUM(
    CASE 
      WHEN stock_movement = 'stock in' THEN total_value
      WHEN stock_movement = 'stock out' THEN -total_value
    END
  ) AS net_value_change
FROM
  adroit-solstice-460613-a2.health_tail_integration.med_audit
GROUP BY
  month,
  med_name
ORDER BY
  month,
  med_name;

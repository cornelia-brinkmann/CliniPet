SELECT
  * EXCEPT (breed,
    patient_name,
    owner_phone),
  COALESCE (breed, 'Unknown') AS breed,
  -- replace for missing data with 'Unknown'
  UPPER (patient_name) AS patient_name,
  -- standardisation for the names
  CAST (REGEXP_REPLACE(owner_phone, '[^0-9]', '') AS integer) AS owner_phone  -- remove non-numeric data from column owner_phone and
  -- changed the data type from STRING to INTEGER
FROM
  adroit-solstice-460613-a2.health_tail.healthtail_reg_cards;

  
  # The new table, med_audit, should track the movement of medications in stock—indicating "in" when medications are purchased and 
  #"out" when they are used in procedures. It should contain the following columns:
  # month, med_name, total_packs, total_value, stock_movement
  # To create the med_audit table as a joined view reflecting the receipt and usage of medications
WITH
  medications_receive_monthly AS (
  SELECT
    DATE_TRUNC (month_invoice, MONTH) AS month,
    med_name,
    SUM (packs) AS total_packs,
    SUM (total_price) AS total_value,
    'stock in' AS stock_movement
  FROM
    adroit-solstice-460613-a2.health_tail.invoices
  GROUP BY
    month,
    med_name),
  medications_spent_monthly AS (
  SELECT
    DATE_TRUNC (visit_datetime, MONTH) AS month,
    med_prescribed AS med_name,
    SUM (med_dosage) AS total_packs,
    SUM (med_cost) AS total_value,
    'stock out' AS stock_movement
  FROM
    adroit-solstice-460613-a2.health_tail.visits
  GROUP BY
    month,
    med_name)
SELECT
  *
FROM
  medications_receive_monthly
UNION ALL
SELECT
  *
FROM
  medications_spent_monthly;
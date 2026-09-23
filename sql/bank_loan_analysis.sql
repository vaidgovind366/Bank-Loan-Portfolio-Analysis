-- =============================================================
-- BANK LOAN ANALYSIS - SQL QUERIES
-- Project: Bank Loan Analysis Dashboard using Tableau
-- SQL Dialect: MySQL 8+
-- =============================================================

-- Assumed table name: financial_loan
-- Key columns used in this analysis:
-- id, loan_amnt, funded_amnt, total_pymnt, int_rate, dti,
-- issue_date, loan_status, purpose, term, emp_length,
-- home_ownership, state, grade, sub_grade, verification_status

USE bank_loan;

-- =============================================================
-- 1. Overall KPI Metrics
-- =============================================================
SELECT
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_pymnt) AS total_amount_received,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan;

-- =============================================================
-- 2. Monthly Loan Applications
-- =============================================================
SELECT
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    COUNT(*) AS total_loan_applications
FROM financial_loan
GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY month;

-- =============================================================
-- 3. Month-over-Month (MoM) Loan Applications
-- =============================================================
WITH monthly_data AS (
    SELECT
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        COUNT(*) AS total_applications
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
),
monthly_with_previous AS (
    SELECT
        month,
        total_applications,
        LAG(total_applications) OVER (ORDER BY month) AS previous_month_applications
    FROM monthly_data
)
SELECT
    month,
    total_applications,
    previous_month_applications,
    ROUND(
        ((total_applications - previous_month_applications)
        / NULLIF(previous_month_applications, 0)) * 100, 2
    ) AS mom_growth_pct
FROM monthly_with_previous
ORDER BY month;

-- =============================================================
-- 4. Good Loan vs Bad Loan
-- Good Loan = Fully Paid + Current
-- Bad Loan = Charged Off
-- =============================================================
SELECT
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current') THEN 'Good Loan'
        WHEN loan_status = 'Charged Off' THEN 'Bad Loan'
        ELSE 'Other'
    END AS loan_category,
    COUNT(*) AS loan_applications,
    SUM(funded_amnt) AS funded_amount,
    SUM(total_pymnt) AS amount_received,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan
GROUP BY loan_category
ORDER BY loan_category;

-- =============================================================
-- 5. Good Loan Percentage
-- =============================================================
SELECT
    ROUND(
        100.0 * SUM(
            CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END
        ) / COUNT(*), 2
    ) AS good_loan_percentage
FROM financial_loan;

-- =============================================================
-- 6. Bad Loan Percentage
-- =============================================================
SELECT
    ROUND(
        100.0 * SUM(
            CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END
        ) / COUNT(*), 2
    ) AS bad_loan_percentage
FROM financial_loan;

-- =============================================================
-- 7. Loan Status Summary
-- =============================================================
SELECT
    loan_status,
    COUNT(*) AS total_loan_applications,
    SUM(total_pymnt) AS total_amount_received,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(dti), 2) AS avg_dti,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate
FROM financial_loan
GROUP BY loan_status
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 8. Loan Applications by State
-- =============================================================
SELECT
    state,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_pymnt) AS total_amount_received
FROM financial_loan
GROUP BY state
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 9. Loan Applications by Purpose
-- =============================================================
SELECT
    purpose,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_pymnt) AS total_amount_received
FROM financial_loan
GROUP BY purpose
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 10. Loan Applications by Employment Length
-- =============================================================
SELECT
    emp_length,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan
GROUP BY emp_length
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 11. Loan Applications by Home Ownership
-- =============================================================
SELECT
    home_ownership,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate
FROM financial_loan
GROUP BY home_ownership
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 12. Loan Applications by Term
-- =============================================================
SELECT
    term,
    COUNT(*) AS total_loan_applications,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS application_percentage
FROM financial_loan
GROUP BY term
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 13. Loan Applications by Grade
-- =============================================================
SELECT
    grade,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan
GROUP BY grade
ORDER BY grade;

-- =============================================================
-- 14. Verification Status Analysis
-- =============================================================
SELECT
    verification_status,
    COUNT(*) AS total_loan_applications,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_pymnt) AS total_amount_received
FROM financial_loan
GROUP BY verification_status
ORDER BY total_loan_applications DESC;

-- =============================================================
-- 15. Top 10 Loan Purposes by Funded Amount
-- =============================================================
SELECT
    purpose,
    SUM(funded_amnt) AS total_funded_amount
FROM financial_loan
GROUP BY purpose
ORDER BY total_funded_amount DESC
LIMIT 10;

-- =============================================================
-- 16. Top 10 States by Loan Applications
-- =============================================================
SELECT
    state,
    COUNT(*) AS total_loan_applications
FROM financial_loan
GROUP BY state
ORDER BY total_loan_applications DESC
LIMIT 10;

-- =============================================================
-- 17. High Interest Rate Loans
-- =============================================================
SELECT
    id,
    loan_amnt,
    funded_amnt,
    int_rate,
    grade,
    sub_grade,
    loan_status
FROM financial_loan
WHERE int_rate >= 20
ORDER BY int_rate DESC;

-- =============================================================
-- 18. Fully Paid Loan Performance
-- =============================================================
SELECT
    COUNT(*) AS fully_paid_loans,
    SUM(funded_amnt) AS funded_amount,
    SUM(total_pymnt) AS amount_received,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan
WHERE loan_status = 'Fully Paid';

-- =============================================================
-- 19. Charged Off Loan Performance
-- =============================================================
SELECT
    COUNT(*) AS charged_off_loans,
    SUM(funded_amnt) AS funded_amount,
    SUM(total_pymnt) AS amount_received,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(dti), 2) AS avg_dti
FROM financial_loan
WHERE loan_status = 'Charged Off';

-- =============================================================
-- 20. Data Quality Checks
-- =============================================================
SELECT
    COUNT(*) AS total_rows,
    SUM(id IS NULL) AS null_ids,
    SUM(funded_amnt IS NULL) AS null_funded_amount,
    SUM(total_pymnt IS NULL) AS null_amount_received,
    SUM(int_rate IS NULL) AS null_interest_rate,
    SUM(dti IS NULL) AS null_dti,
    SUM(loan_status IS NULL) AS null_loan_status
FROM financial_loan;

-- =============================================================
-- END OF SCRIPT
-- =============================================================

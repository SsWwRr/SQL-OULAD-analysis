-- Open University Learning Analytics Dataset (OULAD)

--     **QUESTIONS**

--1. **Course Analysis:**
--   1.1. Count the number of unique modules (courses).
SELECT COUNT(DISTINCT code_module) AS num_of_unique_courses 
FROM courses;
--   1.2. Calculate the length of each module-presentation in days.
SELECT code_module,
SUM(length::INTEGER) 
FROM courses 
GROUP BY code_module 
ORDER BY code_module;
--   1.3. Identify modules with both February (B) and October (J) presentations.
SELECT sub.code_module 
FROM
(SELECT code_module,
COUNT(
    CASE 
        WHEN RIGHT(code_presentation,1) = 'J' 
        THEN 1 
        ELSE NULL 
    END)AS count_j,
COUNT(
    CASE 
        WHEN RIGHT(code_presentation,1) = 'B' 
        THEN 1 
        ELSE NULL 
    END)AS count_b
FROM courses 
GROUP BY code_module)sub
WHERE sub.count_j > 0 
AND sub.count_b > 0 
ORDER BY sub.code_module;
--2. **Assessment Insights:**
--   2.1. List all assessment types.
SELECT DISTINCT assessment_type 
FROM assessments;
--   2.2. Calculate the total weight of assessments (excluding exams) for each module-presentation.
SELECT code_module,code_presentation,
SUM(
    CASE 
        WHEN assessment_type = 'Exam' 
        THEN 0 
        ELSE  weight::FLOAT 
    END)
AS total_weight 
FROM assessments 
GROUP BY code_module,code_presentation 
ORDER BY code_module,code_presentation;
--   2.3. Determine the distribution of assessment types across modules and presentations.
WITH assesment_counts
AS (
    SELECT c.code_module,c.code_presentation, 
    COUNT(
        CASE 
            WHEN assessment_type = 'TMA' 
            THEN 1 
            ELSE NULL 
        END)
    AS tma_count,
    COUNT(
        CASE 
            WHEN assessment_type = 'CMA' 
            THEN 1 
            ELSE NULL 
        END) 
    AS cma_count,
    COUNT(
        CASE 
            WHEN assessment_type = 'Exam' 
            THEN 1 
            ELSE NULL 
        END) 
    AS exam_count,
    (COUNT(assessment_type)) 
    AS total_count
    FROM courses c 
    JOIN assessments a 
    ON c.code_module = a.code_module 
    AND c.code_presentation = a.code_presentation 
    GROUP BY c.code_module,c.code_presentation
    ORDER BY c.code_module,c.code_presentation
)
SELECT code_module,code_presentation,
ROUND((tma_count*100.0 / total_count),2) AS tma_percentage,
ROUND((cma_count*100.0 / total_count),2) AS cma_percentage,
ROUND((exam_count*100.0 / total_count),2) AS exam_percentage
FROM assesment_counts;
--3. **Student Performance:**
--   3.1. Count the number of unique students enrolled in each module-presentation.
SELECT code_module,code_presentation,
COUNT(DISTINCT id_student) 
AS num_of_students 
FROM studentinfo 
GROUP BY code_module,code_presentation
ORDER BY code_module,code_presentation;
--   3.2. Calculate the average number of previous attempts for each module.
SELECT code_module,
AVG(num_of_prev_attempts::INTEGER)
AS avg_prev_attempts
FROM studentinfo 
GROUP BY code_module 
ORDER BY code_module;
--   3.3. Compute average final scores for each module-presentation.
SELECT a.code_module,a.code_presentation,
ROUND(AVG(sa.score::INTEGER),2) 
AS final_score
FROM studentassessment sa 
JOIN assessments a 
ON sa.id_assessment = a.id_assessment 
WHERE assessment_type = 'Exam' 
GROUP BY a.code_module,a.code_presentation;
--   3.4 Compute average pass rates for each module-presentation.
WITH pass_fail AS(
    SELECT
    code_module,code_presentation,
    COUNT(
        CASE
            WHEN final_result = 'Pass'
            OR final_result = 'Distinction'
            THEN 1 
            ELSE NULL
        END
    )
    AS pass_count,
    COUNT(
        CASE
            WHEN final_result = 'Fail'
            OR final_result = 'Withdrawn'
            THEN 1 
            ELSE NULL
        END
    )
    AS fail_count,
    COUNT(final_result)
    AS all_count
    FROM studentinfo
    GROUP BY code_module,code_presentation
)
SELECT pf.code_module,pf.code_presentation,ROUND((pass_count*100.0/all_count),2) 
AS pass_percentage,
ROUND((pf.fail_count*100.0/pf.all_count),2) 
AS fail_percentage
FROM pass_fail pf 
JOIN assessments a 
ON a.code_module = pf.code_module 
AND 
a.code_presentation = pf.code_presentation
WHERE assessment_type = 'Exam'
ORDER BY code_module,code_presentation;
--   3.5. Analyze the impact of disability status on student performance.
WITH pass_fail_able_bodied AS(
    SELECT
    code_module,code_presentation,
    COUNT(
        CASE
            WHEN final_result = 'Pass'
            OR final_result = 'Distinction'
            THEN 1 
            ELSE NULL
        END
    )
    AS pass_count,
    COUNT(
        CASE
            WHEN final_result = 'Fail'
            OR final_result = 'Withdrawn'
            THEN 1 
            ELSE NULL
        END
    )
    AS fail_count,
    COUNT(final_result)
    AS all_count
    FROM studentinfo
    WHERE disability = 'N'
    GROUP BY code_module,code_presentation
),
pass_fail_disabled AS (
    SELECT
    code_module,code_presentation,
    COUNT(
        CASE
            WHEN final_result = 'Pass'
            OR final_result = 'Distinction'
            THEN 1 
            ELSE NULL
        END
    )
    AS pass_count,
    COUNT(
        CASE
            WHEN final_result = 'Fail'
            OR final_result = 'Withdrawn'
            THEN 1 
            ELSE NULL
        END
    )
    AS fail_count,
    COUNT(final_result)
    AS all_count
    FROM studentinfo
    WHERE disability = 'Y'
    GROUP BY code_module,code_presentation
)
SELECT pfab.code_module,pfab.code_presentation,
ROUND((pfd.pass_count*100.0/pfd.all_count),2) - 
ROUND((pfab.pass_count*100.0/pfab.all_count),2)
-- prch -> pass rate compared (to) healthy (people)
AS prch,
ROUND((pfd.fail_count*100.0/pfd.all_count),2) - 
ROUND((pfab.fail_count*100.0/pfab.all_count),2)
-- frch -> fail rate compared (to) healthy (people)
AS frch 
FROM pass_fail_able_bodied pfab 
JOIN pass_fail_disabled pfd 
ON pfd.code_module = pfab.code_module 
AND pfd.code_presentation = pfab.code_presentation 
ORDER BY pfab.code_module,pfab.code_presentation;
-- ANSWER: The disability causes students to fail 30% more often on average than the healthy students
--4. **Student Engagement:**
--   4.1. Identify VLE materials with the highest `sum_clicks`.
SELECT id_site,
SUM(sum_click::INTEGER) 
AS click_sum 
FROM studentvle 
GROUP BY id_site 
ORDER BY SUM(sum_click::INTEGER) 
DESC 
LIMIT 10;
--  4.2. Calculate the average number of interactions per student with VLE materials for each module-presentation.
SELECT code_module,code_presentation,id_student,
AVG(sum_click::INTEGER)
AS sc 
FROM studentvle 
GROUP BY code_module,code_presentation,id_student 
ORDER BY sc 
DESC;
--  4.3. Compare student interactions based on gender, age band, and region.
--BY AGE:
SELECT si.age_band,
ROUND(
    SUM(sv.sum_click::INTEGER)*100.0/
    (
    SELECT SUM(sum_click::INTEGER)
    AS total_clicks
    FROM studentvle 
),2)
AS percentage_of_clicks
FROM studentvle sv
JOIN studentinfo si 
ON sv.id_student = si.id_student
AND si.code_module = sv.code_module
AND si.code_presentation = sv.code_presentation
GROUP BY si.age_band;
--BY GENDER:
SELECT si.gender,
ROUND(
    SUM(sv.sum_click::INTEGER)*100.0/
    (
    SELECT SUM(sum_click::INTEGER)
    AS total_clicks
    FROM studentvle 
),2)
AS percentage_of_clicks
FROM studentvle sv
JOIN studentinfo si 
ON sv.id_student = si.id_student
AND si.code_module = sv.code_module
AND si.code_presentation = sv.code_presentation
GROUP BY si.gender;
--BY REGION:
SELECT si.region,
ROUND(
    SUM(sv.sum_click::INTEGER)*100.0/
    (
    SELECT SUM(sum_click::INTEGER)
    AS total_clicks
    FROM studentvle 
),2)
AS percentage_of_clicks
FROM studentvle sv
JOIN studentinfo si 
ON sv.id_student = si.id_student
AND si.code_module = sv.code_module
AND si.code_presentation = sv.code_presentation
GROUP BY si.region ORDER BY percentage_of_clicks DESC;



--5. **Registration and Unregistration Patterns:**
--   5.1. Analyze the distribution of registration dates relative to module-presentation start dates.
SELECT
COUNT(
    CASE
        WHEN date_registration != '' 
        AND date_registration::INTEGER < -28 THEN 1
        ELSE NULL
    END
) AS registered_month_before_start,
COUNT(
    CASE
        WHEN date_registration != '' 
        AND date_registration::INTEGER >= -28 
        AND date_registration::INTEGER <= 28 THEN 1
        ELSE NULL
    END
) AS registered_28d_around_start,
COUNT(
    CASE
        WHEN date_registration != '' 
        AND date_registration::INTEGER > 28 THEN 1
        ELSE NULL
    END
) AS registered_month_after_start
FROM studentregistration;
--ANSWER: Vast majority of people registered more than a month before the start of the course
--around 30% registered less than one month away from the start of the course 
--less than 1% registered more than one month after the start of the course
--   5.2. Identify modules with high unregistration rates.
SELECT code_module,
ROUND(
COUNT(
    CASE
        WHEN date_unregistration != ''
        THEN 1
        ELSE NULL
    END
)*100.0/
COUNT(
    date_registration
),2)
AS percentage_of_unregistration
FROM studentregistration
GROUP BY code_module
ORDER BY percentage_of_unregistration 
DESC LIMIT 3;

--   5.3. Calculate the average duration students stay enrolled before unregistration for each module-presentation.
SELECT code_module,code_presentation,
ROUND(
AVG(date_unregistration::INTEGER)
)
AS avg_before_unregistration
FROM studentregistration
WHERE date_unregistration != '' 
GROUP BY code_module,code_presentation
ORDER BY code_module,code_presentation;
--6. **Comparative Analysis:**
--   6.1. Compare student performance between B and J presentations for modules with both.
WITH both_semesters AS
(
    SELECT
    c.code_module,c.code_presentation,
    RANK(
    ) 
    OVER(
        PARTITION BY 
        c.code_module || SUBSTR(c.code_presentation,0,5) 
        ORDER BY c.code_presentation)AS s_count
    FROM courses c    
)
 
SELECT RIGHT(bs.code_presentation,1),
ROUND(
COUNT(
    CASE 
        WHEN si.final_result 
        IN('Distinction','Pass')
        THEN 1
        ELSE NULL
    END
) *100.0/
COUNT(
    CASE 
        WHEN si.final_result 
        IN('Withdrawn','Fail')
        THEN 1
        ELSE NULL
    END
),2) AS pass_percentage
FROM studentinfo si
JOIN 
(SELECT code_module,code_presentation,
COUNT(
    CASE 
    WHEN bs.s_count = 2 
    THEN 1
    ELSE NULL
END)
OVER(PARTITION BY 
    code_module || SUBSTR(code_presentation,0,5))
AS two_semesters
FROM both_semesters bs 
ORDER BY code_module) bs
ON bs.code_module = si.code_module
AND bs.code_presentation = si.code_presentation
WHERE bs.two_semesters = 1
GROUP BY RIGHT(bs.code_presentation,1);
--ANSWER: The J semester has a 12% higher pass rate than the B semester
--   6.2. Analyze how availability and usage of VLE materials impact student performance in assessments.
-- 1q represents the bottom 20%,5q represents the upper 20%
WITH activity_and_results AS(
SELECT si.final_result AS fr
,sv.id_student AS id,
sv.code_module AS module,
sv.code_presentation AS presentation,
SUM(sv.sum_click::INTEGER)
AS click_sum 
FROM studentvle sv
JOIN studentinfo si
ON 
si.id_student = sv.id_student
AND
si.code_module = sv.code_module
AND
sv.code_presentation = si.code_presentation
GROUP BY sv.id_student,sv.code_module,
sv.code_presentation,si.final_result 
ORDER BY click_sum 
DESC),
quintiles AS(
  (SELECT id,click_sum,fr,
NTILE(5) OVER(ORDER BY click_sum) as quintile
FROM activity_and_results)  
),
counts AS(
SELECT
COUNT(*) FILTER (WHERE quintile = 1 AND fr IN('Withdrawn','Fail')) AS fail_1q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 1 
        AND fr IN('Distinction','Pass')) 
        AS pass_1q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 2 
        AND fr IN('Withdrawn','Fail')) 
        AS fail_2q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 2 
        AND fr IN('Distinction','Pass')) 
        AS pass_2q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 3 
        AND fr IN('Withdrawn','Fail')) 
        AS fail_3q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 3 
        AND fr IN('Distinction','Pass')) 
        AS pass_3q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 4 
        AND fr IN('Withdrawn','Fail')) 
        AS fail_4q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 4 
        AND fr IN('Distinction','Pass')) 
        AS pass_4q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 5 
        AND fr IN('Withdrawn','Fail')) 
        AS fail_5q,
        COUNT(*) 
        FILTER 
        (WHERE quintile = 5 
        AND fr IN('Distinction','Pass')) 
        AS pass_5q
FROM quintiles
)SELECT 
ROUND(pass_1q*100.0/(pass_1q + fail_1q),2)
AS q1_pass_percentage,
ROUND(pass_2q*100.0/(pass_2q + fail_2q),2)
AS q2_pass_percentage,
ROUND(pass_3q*100.0/(pass_3q + fail_3q),2)
AS q3_pass_percentage,
ROUND(pass_4q*100.0/(pass_4q + fail_4q),2)
AS q4_pass_percentage,
ROUND(pass_5q*100.0/(pass_5q + fail_5q),2)
AS q5_pass_percentage
FROM counts
--ANSWER: The pass is heavily correlated with the usage of the VLE materials.
--The bottom 20% of people who used the VLE's the least have a pass rate of only 5%
--The people from the top 20% have a pass rate of 89% 

# SQL-OULAD-analysis
# INTRODUCTION:
This project analyzes Online University Learning Analytics Data, showcasing my proficiency in using PostgreSQL with a focus on Common Table Expressions (CTEs) and Window Functions.

|TECHNOLOGIES USED|SKILLS USED|
| ----------------- | ------------ |
| SQL/PostgreSQL | Complex Window functions, CTE's, data manipulation, data creation |
| PgAdmin4 | Database creation, Data type manipulation |
| Excel | Data manipulation |

# Conclusion
# This project provided significant insights into the academic performance of students and their interactions with online learning materials. Through the use of advanced PostgreSQL techniques such as Common Table Expressions (CTEs) and Window Functions, I was able to extract and analyze complex datasets. I learned how to leverage these techniques to perform deep dives into student behavior, module performance, and the impact of various factors such as disability status and assessment types on academic outcomes.

# Database Schema:
![image](https://github.com/user-attachments/assets/b983ee84-47c9-416f-b4f9-ebe55e2814e9)

Acknowledgment: 
https://www.kaggle.com/datasets/mexwell/open-university-learning-analytics - for providing the database

# Queries
This section includes a list of all the SQL queries used in the analysis. For more complex queries, the results are commented directly in the SQL code.

* Query 1: Count the number of unique modules (courses).
* Query 2: Calculate the length of each module-presentation in days.
* Query 3: Identify modules with both February (B) and October (J) presentations.
* Query 4: List all assessment types.
* Query 5: Calculate the total weight of assessments (excluding exams) for each module-presentation.
* Query 6: Determine the distribution of assessment types across modules and presentations.
* Query 7: Count the number of unique students enrolled in each module-presentation.
* Query 8: Calculate the average number of previous attempts for each module.
* Query 9: Compute average final scores for each module-presentation.
* Query 10: Compute average pass rates for each module-presentation.
* Query 11: Analyze the impact of disability status on student performance.
* Query 12: Identify VLE materials with the highest sum_clicks.
* Query 13: Calculate the average number of interactions per student with VLE materials for each module-presentation.
* Query 14: Compare student interactions based on gender, age band, and region.
* Query 15: Analyze the distribution of registration dates relative to module-presentation start dates.
* Query 16: Identify modules with high unregistration rates.
* Query 17: Calculate the average duration students stay enrolled before unregistration for each module-presentation.
* Query 18: Compare student performance between B and J presentations for modules with both.
* Query 19: Analyze how the availability and usage of VLE materials impact student performance in assessments.

Note: The studyvle.csv file is not included in the databases folder due to its large size, but it is available for download at the acknowledgment link provided above.

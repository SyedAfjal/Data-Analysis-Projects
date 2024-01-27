-- Percentage Distribution of Funding Sources for International Students

SELECT
    source_of_fund,
    SUM(students) AS students_sum,
    (SELECT SUM(students) FROM PortfolioProject3.source_of_fund) AS total_sum
FROM
    source_of_fund
GROUP BY
    source_of_fund
ORDER BY
    students_sum DESC;
    
-- Top 3 Fields of Study by Region 

WITH RankedFieldOfStudy AS (
SELECT
        fos.field_of_study,
        ori.origin_region,
        SUM(AD.students) AS total_students,
        ROW_NUMBER() OVER (PARTITION BY ori.origin_region ORDER BY SUM(AD.students) DESC) AS field_rank
    FROM
        field_of_study fos
    JOIN 
        academic_detail AD ON fos.year = AD.year
    JOIN 
        origin ori ON ori.year = AD.year AND ori.academic_type = AD.academic_type
    GROUP BY
        fos.field_of_study,
        ori.origin_region )
	SELECT 
          field_of_study,
          origin_region,
          total_students
    FROM RankedFieldOfStudy
    WHERE
    field_rank <= 3
ORDER BY
    origin_region,
    field_rank;

-- Enrollment Trends in 'Computer and Information Sciences': Percentage Change by Academic Type

WITH InternationalStudents AS (
SELECT
        fos.year,
        fos.major,
        ad.academic_type,
        sof.source_type,
        SUM(fos.students) AS total_students
    FROM
        field_of_study fos
    JOIN
        academic_detail ad ON fos.year = ad.year
                                             
    JOIN
        source_of_fund sof ON fos.year = sof.year
                                             AND ad.academic_type = sof.academic_type
    WHERE
        fos.major LIKE 'Computer and Information Sciences%'
    GROUP BY
        fos.year,
        fos.major,
        ad.academic_type,
        sof.source_type
)
SELECT 
       present.year,
       present.major,
       present.academic_type,
       present.source_type,
       CASE
        WHEN previous.total_students IS NULL THEN 'No Change'
        WHEN present.total_students > previous.total_students THEN 'Positive'
        WHEN present.total_students < previous.total_students THEN 'Negative'
        ELSE 'No Change'
    END AS change_category,
    (present.total_students - previous.total_students) * 100.0 / NULLIF(previous.total_students, 0) AS percentage_change
FROM InternationalStudents present
LEFT JOIN
    InternationalStudents previous ON present.year = previous.year - 1
                                     AND present.major = previous.major
                                     AND present.academic_type = previous.academic_type
                                     AND present.source_type = previous.source_type;
    
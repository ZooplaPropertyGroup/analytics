-- TESTING GITHUB OUT
SELECT 
    outcode, 
    COUNT(distinct total_email_leads) email_leads, 
    COUNT(distinct total_phone_leads) phone_leads
FROM
(
    SELECT 
        b.outcode,
        COUNT(DISTINCT e.id) AS total_email_leads,
        0 AS total_phone_leads
    FROM 
        agent_email_leads_nopii AS e
        LEFT JOIN agent_branches_nopii AS b ON b.branch_id = e.branch_id
        LEFT JOIN postal_area_outcodes AS pac ON pac.outcode = b.outcode 
    WHERE 
        lead_sent_date >= '2015-12-01' 
        AND lead_sent_date < '2016-01-01'
    GROUP BY 1
    UNION ALL
    SELECT 
        b.outcode,
        0 AS total_email_leads,
        COUNT(DISTINCT l.id) AS total_phone_leads
    FROM 
        agent_phone_leads_nopii AS l
        LEFT JOIN agent_branches_nopii AS b ON b.branch_id = l.branch_id
        LEFT JOIN postal_area_outcodes AS pac ON pac.outcode = b.outcode 
    WHERE 
        call_start >= '2015-12-01' 
        AND call_start < '2016-01-01'
    GROUP BY 1
)
GROUP BY 1
ORDER BY 1

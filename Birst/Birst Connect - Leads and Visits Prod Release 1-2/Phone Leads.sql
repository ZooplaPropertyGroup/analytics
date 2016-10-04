SELECT 
	id AS Phone_id,
    external_id,
    branch_id,
    source,
    call_result,
    call_start,
    call_end,
    node_id,
    node_name,
    has_recording,
    call_start AS lead_creation_date
FROM agent_phone_leads_nopii
WHERE call_start > CURRENT_DATE - INTERVAL '10 days'
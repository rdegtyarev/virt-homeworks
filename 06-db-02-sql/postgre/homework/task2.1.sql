SELECT table_catalog, grantee, string_agg(privilege_type, ', ')
FROM information_schema.role_table_grants 
WHERE table_catalog='test_db' and table_schema = 'public'
group by table_catalog, grantee
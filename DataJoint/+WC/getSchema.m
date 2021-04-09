function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'WC', 'arseny_watercue_analysis');
end
obj = schemaObject;
end

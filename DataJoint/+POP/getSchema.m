function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'POP', 'arseny_analysis_pop');
end
obj = schemaObject;
end

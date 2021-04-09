function [empty_struct] = fn_EmptyStruct (table_name)

t = eval(table_name);
k = t.header.names;
k{2,1} = {};
empty_struct = struct(k{:});

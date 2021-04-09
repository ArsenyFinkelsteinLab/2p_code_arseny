%{
# 
virus_source                : varchar(60)                   # 
%}


classdef VirusSource < dj.Lookup
        properties
        contents = {
            'Janelia'
            'UPenn'
            'Addgene'
            'UNC'
            'Other'
            }
    end
end
%{
# 
session_epoch_type              : varchar(200)                   # 
----
session_epoch_type_description  : varchar(2000)                  # 

%}


classdef SessionEpochType < dj.Lookup
     properties
        contents = {
            'behav_only' 'behavior only'
            'behav_photo' 'behavior with photostimulation'
            'spont_only' 'spontaneous activity only'
            'spont_photo' 'spontaneous activity with photostimulation'
            }
    end
end
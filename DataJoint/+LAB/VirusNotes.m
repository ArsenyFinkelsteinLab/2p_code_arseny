%{
# Notes for virus
-> LAB.Virus
note_id                     : int                           # 
---
note                        : varchar(256)                  # 
%}


classdef VirusNotes < dj.Part
    properties(SetAccess=protected)
        master= LAB.Virus
    end
end
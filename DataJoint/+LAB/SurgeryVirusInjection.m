%{
# Virus injections
-> LAB.Surgery
injection_id                : int                           # 
---
-> LAB.Virus
-> LAB.SkullReference
ml_location                         : decimal(8,3)                  # um from ref left is positive
ap_location                         : decimal(8,3)                  # um from ref anterior is positive
dv_location                         : decimal(8,3)                  # um from dura dorsal is positive
volume                              : decimal(10,3)                 # in nl
dilution                            : decimal(10,2)                 # 1 to how much
surgery_virus_injection_description : varchar(1000)          # 
%}


classdef SurgeryVirusInjection < dj.Part
    properties(SetAccess=protected)
        master= LAB.Surgery
    end
end

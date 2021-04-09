%{
# Subject gene modifications
-> LAB.Subject
-> LAB.ModifiedGene
---
zygosity="Unknown"          : enum('Het','Hom','Unknown')   # 
type="Unknown"              : enum('Knock-in','Transgene','Unknown') # 
%}


classdef SubjectGeneModification < dj.Part
    properties(SetAccess=protected)
        master= LAB.Subject
    end
end
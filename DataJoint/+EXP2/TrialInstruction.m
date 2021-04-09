%{
# Instruction to mouse
trial_instruction           : varchar(8)                    # 
%}


classdef TrialInstruction < dj.Lookup
    properties
        contents = {
            'left'
            'right'
            'go'
            'no go'
            }
    end
end
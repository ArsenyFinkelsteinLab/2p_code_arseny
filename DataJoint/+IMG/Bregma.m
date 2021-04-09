%{
# Field of View
-> EXP2.Session
---
bregma_x_cm               : double                # FOV anterior-posterior edge relative to bregma
bregma_y_cm                : double                # FOV medial-lateral  edge relative to bregma
%}


classdef Bregma < dj.Lookup
     properties
        contents = {
            464724 1    2.95   0.25
            464724 2    3.10   0.25
            464724 3    3.10   0.25
            464724 4    2.75   0.25
            464724 5    2.95   0.25
            464724 6    3.10   0.25
            464724 7    2.65   0.5
            464724 8    2.75   0.25
            464724 9    2.85   0.45
            
            
            464725 1    3.1   0.25
            464725 2    3.1   0.25
            464725 3    3.1   0.25
            464725 4    3.1   0.25
            464725 5    3.1   0.25
            464725 6    3.1   0.25
            464725 7    3.1   0.25
            464725 8    3.1   0.25
            464725 9    3.1   0.25
            464725 10   3.1  0.35
            464725 11   3.2   0.25
            464725 12   2.9   0.25
            464725 13   3.1   0.25

            }
    end
end
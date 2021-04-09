%{
# 
subject_id                  : int                           # institution 6 digit animal ID
---
-> LAB.Person
cage_number                 : int                           # institution 6 digit cage ID
date_of_birth               : date                          # format: yyyy-mm-dd
sex                         : enum('M','F','Unknown')       # 
-> LAB.AnimalSource
%}


classdef Subject < dj.Manual
end
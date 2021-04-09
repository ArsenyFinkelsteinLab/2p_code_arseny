%{
# 
-> LAB.Subject
surgery_id                  : int                           # surgery number
---
-> LAB.Person
start_time                  : datetime                      # start time
end_time                    : datetime                      # end time
surgery_description         : varchar(1000)                 # 
%}


classdef Surgery < dj.Manual
end

%{
# 
virus_id                    : int unsigned                  # 
---
-> LAB.VirusSource
-> LAB.Serotype
-> LAB.Person
virus_name                  : varchar(256)                  # 
titer                       : decimal(20,1)                 # 
order_date                  : date                          # 
remarks                     : varchar(256)                  # 
%}


classdef Virus < dj.Manual
end
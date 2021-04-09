%{
# 
-> LAB.Subject
---
water_restriction_number    : varchar(16)                   # WR number
cage_number                 : int                           # 
wr_start_date               : date                          # 
wr_start_weight             : decimal(6,3)                  # 
%}


classdef WaterRestriction < dj.Manual
end
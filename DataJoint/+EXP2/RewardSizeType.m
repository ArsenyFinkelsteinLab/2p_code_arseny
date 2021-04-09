%{
# 
reward_size_type                     : varchar(32)                    # 
%}


classdef RewardSizeType < dj.Lookup
    properties
        contents = {
            'regular'
            'omission'
            'large'
            }
    end
end
%{
-> EXP2.SessionTrial
-----
num_trials_in_block                                      : smallint       # if the same trial is repeated, for how many trials it is repeated
current_trial_num_in_block                               : smallint       # position of trial in a block
num_licks_for_reward                                     : smallint       # how many licks are needed to trigger a water release. The mouse can collect the water drop on num_licks_for_reward +1 lick
roll_deg                                                 : double      # roll angle of the lickport positions in deg.Positve roll means the mouse is turning its head towards its right shoulder
flag_auto_water_curret_trial=null                        : smallint        # 1 if this this an auto-water trial, in which a drop is presented before the tongue contact; 0 otherwise
flag_auto_water_settings=null                            : smallint    # 1 if the settings indicate that the behavior is on auto-water; 0 otherwise
flag_auto_water_first_trial_in_block_settings =null      : smallint    # 1 if the settings indicate that the first trial in the block is an auto-water trial; 0 otherwise

%}

classdef TrialLickBlock < dj.Imported
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end

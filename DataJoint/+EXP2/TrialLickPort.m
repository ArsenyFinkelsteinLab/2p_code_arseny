%{
-> EXP2.SessionTrial
-----
lickport_pos_number         : int  # 
lickport_pos_x=null         : double    # in zabor motor units
lickport_pos_y=null         : double    # in zabor motor units
lickport_pos_z=null         : double    # in zabor motor units
lickport_pos_x_bins=null    : blob    # in zabor motor units
lickport_pos_y_bins=null    : blob    # in zabor motor units
lickport_pos_z_bins=null    : blob    # in zabor motor units



%}

classdef TrialLickPort < dj.Imported
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end

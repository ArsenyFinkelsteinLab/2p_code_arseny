%{
# first frame of a session with a concatenated array of frames spanning multisessions
-> IMG.FOVmultiSessions
----
first_frame_in_session_out_of_multisession         : int           # first frame of a session with a concatenated array of frames spanning multisessions
%}


classdef FOVmultiSessionsFirstFrame < dj.Imported
     properties(SetAccess=protected)
        master= IMG.FOVmultiSessions
    end
    methods(Access=protected)
        function makeTuples(self, key)            
            k.multiple_sessions_uid = fetch1(IMG.FOVmultiSessions & key,'multiple_sessions_uid');
            
            session_list = fetchn(IMG.FOVmultiSessions & k,'session','ORDER BY session');

            total_frames_in_previous_sessions = 0;
            for i_s = 1:1:sum(session_list<key.session)
                k_s = key;
                k_s.session = session_list (i_s);
                total_frames_in_previous_sessions = [total_frames_in_previous_sessions + sum(fetch1(IMG.FOV & k_s,'number_of_frames_in_trial'))];
            end
            key.first_frame_in_session_out_of_multisession = 1 + total_frames_in_previous_sessions;
            insert(self,key)
        end
    end
end
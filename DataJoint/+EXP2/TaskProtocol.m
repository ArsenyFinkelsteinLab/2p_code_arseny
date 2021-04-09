%{
# SessionType
-> EXP2.Task
task_protocol       : tinyint                   # task ptotcol
-----
task_protocol_description           : varchar(4000)                 # 
%}

classdef TaskProtocol < dj.Lookup
    properties
         contents = {
                     'sound' 1 '3 Khz - lick right; 12kHz - lick left'
                     'lick2D' 2 'lick upon presentation of the lickport that can appear at different locations on the 2D X-Z plane around mouse face '
                     'waterCue' 3 '2 lick ports appear, one of them with a small drop of water. They are withdrawn and then presented again after some delay. The mouse has to choose the lickport that was cued with water in the first lickport-presentation, in order to recieve another water reward'
            }
    end
end
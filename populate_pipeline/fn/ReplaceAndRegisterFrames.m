function ReplaceAndRegisterFrames(flag_do_registration, flag_find_bad_frames_only)

rel = (EXP2.SessionEpoch*EXP2.SessionEpochDirectory*EXP2.Session - IMG.FOV); % only do this step for sessions that have not been processed by suite2p yet
% rel = (EXP2.SessionEpoch*EXP2.SessionEpochDirectory *EXP2.Session & 'session=2' & 'session_epoch_number=2'); % only do this step for sessions that have not been processed by suite2p yet

if rel.count>0
    session_info= fetch(rel,'*');
    for i_s=1:1:numel(session_info)
        fn_ReplaceAndRegisterFrames(session_info(i_s), flag_do_registration, flag_find_bad_frames_only)
    end
end
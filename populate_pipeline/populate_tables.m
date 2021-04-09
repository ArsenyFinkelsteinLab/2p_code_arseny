function populate_tables()
rig='imaging1';
user_name ='ars';
dir_behavioral_data = 'Z:\users\Arseny\Projects\Learning\imaging2p\RawData\BPOD_behavior\anm442411_AF12\';
behavioral_protocol_name='af_2D';
IMG.Parameters; %configure the path to your data folder here

flag_multi_session_registration = 1;


%% STEP 0 - populate LAB (for each new person/rig/animal)
% populate_LAB_new_Rig_Person_Animal % 

% Definition tables - make sure they are not empty by running them
% EXP2.ActionEventType;
% EXP2.TrialEventType;
% EXP2.TrainingType;
% EXP2.Task;
% EXP2.TrialNameType;
% EXP2.EarlyLick;
% EXP2.Outcome;
% EXP2.TrialInstruction;
% EXP2.TaskProtocol;
% EXP2.EpochName;
% EXP2.EpochName2;
% EXP2.SessionEpochType

%% STEP 1 - could be run independelty of suite2p
populate_Session_without_behavior (user_name, rig); % populate session without behavior
% populate_behavior_Lick2D(dir_behavioral_data, behavioral_protocol_name);
% populate_Session_and_behavior (dir_behavioral_data, user_name, rig); % populate session with behavior

populate(EXP2.SessionEpoch); % reads info about FOV and trial duration from SI files. Also populates EXP2.SessionEpochDirectory, EXP2.SessionEpochFrame, IMG.FrameTime, IMG.FrameStartFile

flag_do_registration=1;
flag_find_bad_frames_only=0;
ReplaceAndRegisterFrames(flag_do_registration, flag_find_bad_frames_only);


%% STEP 2 - run suite2p (outside this script)
populate(IMG.FOV); % also populates IMG.Plane

populate(IMG.ROI);
populate(IMG.ROIGood); 
populate(IMG.ROITrace); 
populate(IMG.ROISpikes); 

populate(IMG.PhotostimGroup);
populate(IMG.PhotostimGroupROI); % also populates IMG.PhotostimDATfile;

populate(STIM.ROIResponse50);
populate(STIM.ROIResponseDirect);

populate(STIM.ROIResponseMost);

populate(STIM.ROIGraph2);

populate(ANLI.ROICorr);
% 
populate(ANLI.ROILick2Dmap);
populate(ANLI.ROILick2Dangle);
populate(ANLI.ROILick2DangleShuffle);
populate(ANLI.ROILick2DmapShuffle);

% populate(STIM.ROIResponseDistance)
% populate(STIM.ROIResponseTrace);

% %% STEP 3 - should run *AFTER* suite2p had finished. Can run in paralel with STEP 4
% populate_imaging_roi_across_days;  %Specify within the script the directory for single/multi session registration 
% populate(IMG.FOVmultiSessionsFirstFrame);
% populate(ANLI.FPSTHaverage);
% 
% %% STEP 4 - should run *AFTER* suite2p had finished. Can run in paralel with STEP 3
% populate(IMG.FOVRegisteredMovie);  % requires manual updating of dir at this point
% populate(IMG.FOVMapBaselineF);
% populate(IMG.FOVMapActivity);
% populate(IMG.FOVMapSelectivity);







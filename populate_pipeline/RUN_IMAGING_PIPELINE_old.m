function RUN_IMAGING_PIPELINE()
% DJconnect;
rig='imaging1';
user_name ='ars';

dir_base_behavior ='G:\Arseny\2p\BPOD_behavior\';

% dir_behavioral_data = [dir_base_behavior 'anm447991_AF13\'];
% dir_behavioral_data = [dir_base_behavior 'anm445873_ST68\]'
% dir_behavioral_data = [dir_base_behavior 'anm445980_ST66\'];
% dir_behavioral_data = [dir_base_behavior 'anm447990_AF14\'];
% dir_behavioral_data = [dir_base_behavior 'anm462458_AF17\'];
% dir_behavioral_data = [dir_base_behavior 'anm462455_AF23\'];
dir_behavioral_data = [dir_base_behavior 'anm463190_AF26\'];
% dir_behavioral_data = [dir_base_behavior 'anm463189_AF27\'];
% dir_behavioral_data = [dir_base_behavior 'anm464724_AF28\'];
% dir_behavioral_data = [dir_base_behavior 'anm464725_AF29\'];
% dir_behavioral_data = [dir_base_behavior 'anm463192_AF25\'];
% dir_behavioral_data = [dir_base_behavior 'anm464728_AF32\'];


% populate_somatotopy; %populate EXP2.SessionEpochSomatotopy, in case somatopic mapping was done

behavioral_protocol_name='af_2D';
% behavioral_protocol_name='waterCue';

IMG.Parameters; %configure the path to your data folder here

flag_multi_session_registration = 0;


%% STEP 0 - populate LAB (for each new person/rig/animal)
% populate_LAB_new_Rig_Person_Animal() % 

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
% IMG.Zoom2Microns
%% STEP 1 - could be run independelty of suite2p
populate_Session_without_behavior (user_name, rig); % populate session without behavior
% populate_behavior_WaterCue (dir_behavioral_data, behavioral_protocol_name);
populate_behavior_Lick2D(dir_behavioral_data, behavioral_protocol_name);
populate_Session_and_behavior (dir_behavioral_data, user_name, rig); % populate session with behavior

% should run after populate_behavior_Lick2D
populate(EXP2.SessionEpoch); % reads info about FOV and trial duration from SI files. Also populates EXP2.SessionEpochDirectory, IMG.SessionEpochFrame, IMG.FrameTime, IMG.FrameStartFile

% flag_do_registration=1;
% flag_find_bad_frames_only=0;
% ReplaceAndRegisterFrames(flag_do_registration, flag_find_bad_frames_only);
% 

%% STEP 2 - run suite2p (outside this script)
populate(IMG.FOV); % also populates IMG.Plane, IMG.PlaneCoordinates, IMG.PlaneDirectory, IMG.PlaneSuite2p
populate(IMG.FOVEpoch); 
populate(IMG.SessionEpochFramePlane); %deals with missing frames at the end of the session epoch in some planes, due to volumetric imaging

populate(IMG.ROI);
populate(IMG.ROIGood); 
populate(IMG.ROITrace); 
populate(IMG.ROISpikes); 

populate(IMG.ROIdeltaF); % IMG.ROIdeltaFMean IMG.ROIdeltaFMean
% populate(ANLI.IncludeROI4);
populate(IMG.ROIdeltaFPeak); 

populate(IMG.ROITraceNeuropil); 
populate(IMG.ROIdeltaFNeuropil); % IMG.ROIdeltaFMean IMG.ROIdeltaFMean

% populate(IMG.ROIdeltaFNeuropilSubtr);
 
populate(IMG.PhotostimGroup); % also IMG.PhotostimProtocol
populate(IMG.PhotostimGroupROI); % also populates IMG.PhotostimDATfile;
populate(STIM.ROIResponse); % also populates STIM.ROIResponseVector
% populate(STIM.ROIResponse2); % control with the stim window (for detection) is shifted forward

populate(STIM.ROIResponseDirect);

populate(STIM.ROIResponseMost);

% populate(STIM.ROIGraph2);
% populate(STIM.ROIGraphAll);
% populate(ANLI.ROICorr1);
% populate(ANLI.ROICorr3);
% populate(ANLI.ROICorr5);
% populate(ANLI.ROICorr10);




%% Lick 2D
%based on dff
%--------------------------------
populate(LICK2D.ROILick2Dangle);
populate(LICK2D.ROILick2DangleNeuropil);
populate(LICK2D.ROILick2DPSTH); %LICK2D.ROILick2DPSTHStats
populate(LICK2D.ROILick2Dmap); %also populates LICK2D.ROILick2DSelectivity LICK2D.ROILick2DSelectivityStats

% populate(PLOTS.Cells2DTuning);
% populate(PLOTS.Maps2Dtheta);
% populate(PLOTS.Maps2DPSTH);

% populate(PLOTS.Maps2DPSTHpreferred);

% %based on spikes
% %--------------------------------
% populate(LICK2D.ROILick2DangleSpikes);
% populate(LICK2D.ROILick2DPSTHSpikes); %LICK2D.ROILick2DPSTHStatsSpikes
% populate(LICK2D.ROILick2DmapSpikes); %also populates LICK2D.ROILick2DSelectivitySpikes LICK2D.ROILick2DSelectivityStatsSpikes
% 
% populate(PLOTS.Cells2DTuningSpikes);
% populate(PLOTS.Maps2DthetaSpikes);
% populate(PLOTS.Maps2DPSTHSpikes);

% populate(ANLI.ROILick2DangleShuffle);
% populate(ANLI.ROILick2DmapShuffle);

% lick2D_analysis; % this script summarizes them all

% % populate(ANLI.ROILick2DmapReward);
% populate(ANLI.ROILick2DPSTHReward);
% populate(ANLI.ROILick2DPSTHBlock);


%% Clustering
% populate(ANLI.ROIHierarCluster);
% populate(ANLI.ROIHierarClusterSelectivity);
% populate(ANLI.ROIHierarClusterShapeAndSelectivity);


% populate(POP.ROIClusterCorr2); %smoothed
% populate(POP.ROISubClusterCorr);
% populate(POP.ROICorrLocal);
% populate(POP.ROIClusterCorrThresholded);

% populate(POP.ROIClusterCorr);
% populate(POP.ROIClusterCorrNeuropil);
% populate(POP.ROIClusterCorrNeuropilSubtr)


% populate(WC.FPSTHaverage);
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


%% MAPS
populate(PLOTS.MapsClusterCorr);
populate(PLOTS.MapsClusterCorrNeuropil);

% populate(PLOTS.MapsClusterCorrThresholded);
% populate(PLOTS.MapsSpontVsBeharDeltaMeanDFF);

%% SOMATOSENSORY MAPS
% populate(PLOTS.SomatotopyDeltaFiringRate);
% populate(PLOTS.SomatotopyDeltaMeanFiringRate);
% populate(PLOTS.SomatotopyDeltaMeanFlourescence);

%% MAPS LICK 2D
% populate(PLOTS.Maps2Dtheta);

% populate(PLOTS.MapsClusterCorrThresholded);
% populate(PLOTS.MapsSpontVsBeharDeltaMeanDFF);

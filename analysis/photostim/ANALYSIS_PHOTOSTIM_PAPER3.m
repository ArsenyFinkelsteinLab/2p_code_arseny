function ANALYSIS_PHOTOSTIM_PAPER3()

STIMANAL.SessionEpochsIncludedFinal %% manually update session info here

% photostim_direct_new()
% distance_dependence_new()


% Correction based on ETL callibration
populate(STIM.ROIInfluence2)
populate(STIM.ROIResponseDirect2);
populate(STIMANAL.NeuronOrControl2);
populate(STIMANAL.NeuronOrControlNumber2);
populate(STIMANAL.InfluenceDistance222);
populate(STIMANAL.ROIGraphAll)
populate(STIMANAL.ROIGraphAllETL)
populate(STIMANAL.OutDegree)
populate(POP.ROICorrLocalPhoto2);

% Correction based on anatomical fiducial
populate(STIM.ROIInfluence3)
populate(STIM.ROIResponseDirect3);
populate(STIMANAL.NeuronOrControl3);
populate(STIMANAL.NeuronOrControlNumber3);
populate(STIMANAL.InfluenceDistance3);
populate(STIMANAL.ROIGraphAllETL3)
populate(STIMANAL.OutDegree3)
populate(POP.ROICorrLocalPhoto3);

PLOT_InfluenceDistance()
PLOT_InfluenceDistance3()

PLOT_ConnectionProbabilityDistance()
PLOT_ConnectionProbabilityDistance3()

PLOT_Network_Degree()
PLOT_Network_Degree3()

%requires: populate(POP.ROICorrLocalPhoto)
PLOT_Network_Degree_vs_tuning() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL3() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL4() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)

PLOT_Network_Degree_vs_tuning_reward()
PLOT_Network_Degree_vs_tuning_reward_ETL()

%% Influence versus noise correlations 
populate(STIMANAL.Target2AllCorrTraceSpont);%based on spikes
populate(STIMANAL.InfluenceVsCorrTraceSpont);
populate(STIMANAL.InfluenceVsCorrTraceSpontShuffled); 
populate(STIMANAL.InfluenceVsCorrTraceSpontResidual); 

% populate(STIMANAL.Target2AllCorrTraceSpontETL);%based on spikes
% populate(STIMANAL.InfluenceVsCorrTraceSpontETL);
% populate(STIMANAL.InfluenceVsCorrTraceSpontResidualETL); 
% populate(STIMANAL.InfluenceVsCorrTraceSpontShuffledETL); 
PLOT_InfluenceVsCorrTraceSpontResidual()


%% Influence versus signal correlations (based on PSTH)
populate(STIMANAL.Target2AllCorrPSTH);

populate(STIMANAL.Target2AllCorrPSTH3); %ETL correction


populate(STIMANAL.InfluenceVsCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrPSTH2);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled2); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrPSTH3);  %ETL correction
populate(STIMANAL.InfluenceVsCorrPSTHShuffled3);  %ETL correction


% populate(STIMANAL.Target2AllCorrPSTHETL);
% populate(STIMANAL.InfluenceVsCorrPSTHETL);
% populate(STIMANAL.InfluenceVsCorrPSTHShuffledETL); % this is what I show in the presentation

PLOT_InfluenceVsCorrPSTH();
PLOT_InfluenceVsCorrPSTHShuffledDiff(); % this is what I show in the presentation

% PLOT_InfluenceVsCorrQuadrantsResidual();  % what is it?
% PLOT_InfluenceVsCorrTraceSpontResidual() % what is it?


%% Influence versus signal correlations (based on PSTH quadrants)
% populate(STIMANAL.Target2AllCorrQuadrantsETL);
% populate(STIMANAL.InfluenceVsCorrQuadrantsETL);
% populate(STIMANAL.InfluenceVsCorrQuadrantsShuffledETL); % this is what I show in the presentation

populate(STIMANAL.Target2AllCorrQuadrants);
populate(STIMANAL.InfluenceVsCorrQuadrants);
populate(STIMANAL.InfluenceVsCorrQuadrantsShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrQuadrants2);
populate(STIMANAL.InfluenceVsCorrQuadrantsShuffled2); % this is what I show in the presentation


PLOT_InfluenceVsCorrQuadrants();
% PLOT_InfluenceVsCorrQuadrantsShuffledDiffETL(); % this is what I show in the presentation
PLOT_InfluenceVsCorrQuadrantsShuffledDiff(); % this is what I show in the presentation

% PLOT_InfluenceVsCorrQuadrantsResidual();  % what is it?
% PLOT_InfluenceVsCorrTraceSpontResidual() % what is it?
%% Influence versus signal correlations (based on PSTH concatenated)

populate(STIMANAL.Target2AllCorrConcat);

populate(STIMANAL.Target2AllCorrConcat2);

populate(STIMANAL.Target2AllCorrConcat3); %% new ETL correction


populate(STIMANAL.InfluenceVsCorrConcat);
populate(STIMANAL.InfluenceVsCorrConcatShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat2);
populate(STIMANAL.InfluenceVsCorrConcatShuffled2); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat3);
populate(STIMANAL.InfluenceVsCorrConcatShuffled3); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat4);
populate(STIMANAL.InfluenceVsCorrConcatShuffled4); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat44);
populate(STIMANAL.InfluenceVsCorrConcatShuffled44); % this is what I show in the presentation


populate(STIMANAL.InfluenceVsCorrConcat5);
populate(STIMANAL.InfluenceVsCorrConcatShuffled5); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat6);
populate(STIMANAL.InfluenceVsCorrConcatShuffled6); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat33); %% new ETL correction
populate(STIMANAL.InfluenceVsCorrConcatShuffled33); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat333); %% new ETL correction
populate(STIMANAL.InfluenceVsCorrConcatShuffled333); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrConcat3333); %% new ETL correction
populate(STIMANAL.InfluenceVsCorrConcatShuffled3333); % this is what I show in the presentation


PLOT_InfluenceVsCorrConcatShuffledDiff(); % this is what I show in the presentation


%% Influence versus signal correlations (based on Angular preferred direction)
populate(STIMANAL.Target2AllCorrAngle);

populate(STIMANAL.Target2AllCorrAngle3);


populate(STIMANAL.InfluenceVsCorrAngle);
populate(STIMANAL.InfluenceVsCorrAngleShuffled); % this is what I show in the presentation


populate(STIMANAL.InfluenceVsCorrAngle1);
populate(STIMANAL.InfluenceVsCorrAngleShuffled1); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrAngle2);
populate(STIMANAL.InfluenceVsCorrAngleShuffled2); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrAngle3);
populate(STIMANAL.InfluenceVsCorrAngleShuffled3); % this is what I show in the presentation


populate(STIMANAL.InfluenceVsCorrAngle33);  %% ETL based
populate(STIMANAL.InfluenceVsCorrAngleShuffled33); % this is what I show in the presentation


PLOT_InfluenceVsCorrAngle();
PLOT_InfluenceVsCorrAngleShuffledDiff();

%% Influence versus signal correlations (based on Angular tuning)
populate(STIMANAL.Target2AllCorrAngleTuning);
populate(STIMANAL.InfluenceVsCorrAngleTuning);
populate(STIMANAL.InfluenceVsCorrAngleTuningShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrAngleTuning2);
populate(STIMANAL.InfluenceVsCorrAngleTuningShuffled2); % this is what I show in the presentation


PLOT_InfluenceVsCorrAngularTuning();
PLOT_InfluenceVsCorrAngularTuningShuffledDiff(); % this is what I show in the presentation


%% Correlations 
PLOT_CorrPairwiseDistanceVoxels()

PLOT_CorrPairwiseDistanceSpikes_MesoSinglePlane()
PLOT_CorrPairwiseDistanceSpikes_MesoVolumetric()
PLOT_CorrPairwiseDistanceSpikes_PhotoRigVolumetric()

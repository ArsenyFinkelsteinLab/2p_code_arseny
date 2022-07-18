function ANALYSIS_PHOTOSTIM_PAPER2()

STIMANAL.SessionEpochsIncludedFinal %% manually update session info here

% photostim_direct_new()
% distance_dependence_new()

populate(STIM.ROIInfluence2)

populate(STIM.ROIInfluence3)


populate(STIM.ROIResponseDirect2);
populate(STIMANAL.NeuronOrControl2);
populate(STIMANAL.NeuronOrControlNumber2);
populate(STIMANAL.InfluenceDistance222);

 populate(STIMANAL.ROIGraphAll)
 populate(STIMANAL.ROIGraphAllETL)
 populate(STIMANAL.ROIGraphAllETL2)

PLOT_InfluenceDistance()
PLOT_ConnectionProbabilityDistance()

PLOT_Network_Degree()
%requires: populate(POP.ROICorrLocalPhoto)
PLOT_Network_Degree_vs_tuning() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)

PLOT_Network_Degree_vs_tuning_reward()


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
populate(STIMANAL.InfluenceVsCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrPSTH2);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled2); % this is what I show in the presentation


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



%% Influence versus signal correlations (based on Angular preferred direction)
populate(STIMANAL.Target2AllCorrAngle);
populate(STIMANAL.InfluenceVsCorrAngle);
populate(STIMANAL.InfluenceVsCorrAngleShuffled); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrAngle2);
populate(STIMANAL.InfluenceVsCorrAngleShuffled2); % this is what I show in the presentation

populate(STIMANAL.InfluenceVsCorrAngle3);
populate(STIMANAL.InfluenceVsCorrAngleShuffled3); % this is what I show in the presentation

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

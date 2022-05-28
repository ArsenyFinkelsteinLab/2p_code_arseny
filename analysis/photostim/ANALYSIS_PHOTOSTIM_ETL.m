function ANALYSIS_PHOTOSTIM_ETL()

STIMANAL.SessionEpochsIncluded  %% manually update session info here

photostim_direct_new()
distance_dependence_new()

populate(STIM.ROIInfluence5ETL); % also populates STIM.ROIInfluenceTrace
populate(STIM.ROIResponseDirect);
populate(STIM.ROIResponseDirect5);
populate(STIM.ROIResponseDirect5ETL2);

populate(STIMANAL.NeuronOrControl5);
populate(STIMANAL.NeuronOrControl5ETL);
populate(STIMANAL.NeuronOrControl5ETL2);

populate(STIMANAL.InfluenceDistance55);
populate(STIMANAL.InfluenceDistance55ETL);
populate( STIMANAL.InfluenceDistance55ETL3);
 
 populate(STIMANAL.ROIGraphAll)
 populate(STIMANAL.ROIGraphAllETL)



PLOT_InfluenceDistance5()
PLOT_InfluenceDistance5ETL()
PLOT_InfluenceDistance5ETL2()

PLOT_Network_Degree()
%requires: populate(POP.ROICorrLocalPhoto)
PLOT_Network_Degree_vs_tuning() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)

PLOT_Network_Degree_vs_tuning_reward()

PLOT_ConnectionProbabilityDistance()

%% Influence versus noise correlations 

populate(STIMANAL.Target2AllCorrTraceSpontETL);%based on spikes
populate(STIMANAL.InfluenceVsCorrTraceSpontETL);
populate(STIMANAL.InfluenceVsCorrTraceSpontResidualETL); 
populate(STIMANAL.InfluenceVsCorrTraceSpontShuffledETL); 
PLOT_InfluenceVsCorrTraceSpontResidual_ETL()


%% Influence versus signal correlations (based on PSTH)
populate(STIMANAL.Target2AllCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrPSTH();
PLOT_InfluenceVsCorrPSTHShuffledDiff(); % this is what I show in the presentation

% PLOT_InfluenceVsCorrQuadrantsResidual();  % what is it?
% PLOT_InfluenceVsCorrTraceSpontResidual() % what is it?


%% Influence versus signal correlations (based on PSTH quadrants)
populate(STIMANAL.Target2AllCorrQuadrantsETL);
populate(STIMANAL.InfluenceVsCorrQuadrantsETL);
populate(STIMANAL.InfluenceVsCorrQuadrantsShuffledETL); % this is what I show in the presentation

PLOT_InfluenceVsCorrQuadrants();
PLOT_InfluenceVsCorrQuadrantsShuffledDiff(); % this is what I show in the presentation

% PLOT_InfluenceVsCorrQuadrantsResidual();  % what is it?
% PLOT_InfluenceVsCorrTraceSpontResidual() % what is it?



%% Influence versus signal correlations (based on Angular preferred direction)
populate(STIMANAL.Target2AllCorrAngle2);
populate(STIMANAL.InfluenceVsCorrAngle2);
populate(STIMANAL.InfluenceVsCorrAngleShuffled2); % this is what I show in the presentation

PLOT_InfluenceVsCorrAngle2();
PLOT_InfluenceVsCorrAngle2ShuffledDiff();

%% Influence versus signal correlations (based on Angular tuning)
populate(STIMANAL.Target2AllCorrAngleTuning);
populate(STIMANAL.InfluenceVsCorrAngleTuning);
populate(STIMANAL.InfluenceVsCorrAngleTuningShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrAngularTuning();
PLOT_InfluenceVsCorrAngularTuningShuffledDiff(); % this is what I show in the presentation


%% Correlations 
PLOT_CorrPairwiseDistanceVoxels()

PLOT_CorrPairwiseDistanceSpikes_MesoSinglePlane()
PLOT_CorrPairwiseDistanceSpikes_MesoVolumetric()
PLOT_CorrPairwiseDistanceSpikes_PhotoRigVolumetric()

%% Spatial scales
PLOT_SVD_Variance_and_SpatialScale()
function ANALYSIS_PHOTOSTIM()

photostim_direct_new()


populate(STIM.ROIInfluence5); % also populates STIM.ROIInfluenceTrace
populate(STIM.ROIResponseDirect);

populate(STIMANAL.NeuronOrControl5);
populate(STIMANAL.InfluenceDistance55);





PLOT_InfluenceDistance5()

PLOT_Network_Degree()
PLOT_Network_Degree_vs_tuning()

PLOT_ConnectionProbabilityDistance()

PLOT_InfluenceVsCorrTraceSpontResidual()


%% Influence versus signal correlations (based on PSTH)
populate(STIMANAL.Target2AllCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTH);
populate(STIMANAL.InfluenceVsCorrPSTHShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrPSTH();
PLOT_InfluenceVsCorrPSTHShuffledDiff(); % this is what I show in the presentation

% PLOT_InfluenceVsCorrQuadrantsResidual();  % what is it?
% PLOT_InfluenceVsCorrTraceSpontResidual() % what is it?


%% Influence versus signal correlations (based on PSTH quadrants)
populate(STIMANAL.Target2AllCorrQuadrants);
populate(STIMANAL.InfluenceVsCorrQuadrants);
populate(STIMANAL.InfluenceVsCorrQuadrantsShuffled); % this is what I show in the presentation

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
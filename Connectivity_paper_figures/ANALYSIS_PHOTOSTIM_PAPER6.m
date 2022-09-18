function ANALYSIS_PHOTOSTIM_PAPER6()

STIMANAL.SessionEpochsIncludedFinal %% manually update session info here

% photostim_direct_new()
% distance_dependence_new()


% XYZ coordinate correction of ETL abberations based on ETL callibration
populate(STIM.ROIInfluence2)
populate(STIM.ROIResponseDirect2);
populate(STIMANAL.NeuronOrControl2);
populate(STIMANAL.NeuronOrControlNumber2);
populate(STIMANAL.InfluenceDistance222);
populate(STIMANAL.ROIGraphAllETL2)
populate(STIMANAL.OutDegree)
populate(POP.ROICorrLocalPhoto2);

PLOT_InfluenceDistance()
PLOT_ConnectionProbabilityDistance()

PLOT_Network_Degree_vs_tuning_ETL__final_with_shuffle() %directional, temporal, and reward tuning -- this is what I show in presentations


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
populate(STIMANAL.Target2AllCorrPSTH); %ETL correction

populate(STIMANAL.InfluenceVsCorrPSTH);  %ETL correction
populate(STIMANAL.InfluenceVsCorrPSTHShuffled);  %ETL correction

PLOT_InfluenceVsCorrPSTHShuffledDiff(); % this is what I show in the presentation


%% Influence versus signal correlations (based on PSTH concatenated)
populate(STIMANAL.Target2AllCorrConcat); %% new ETL correction

populate(STIMANAL.InfluenceVsCorrConcat); %% new ETL correction
populate(STIMANAL.InfluenceVsCorrConcatShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrConcatShuffledDiff(); % this is what I show in the presentation


%% Influence versus signal correlations (based on Angular preferred direction)
populate(STIMANAL.Target2AllCorrAngle);

populate(STIMANAL.InfluenceVsCorrAngle);  %% ETL based
populate(STIMANAL.InfluenceVsCorrAngleShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrAngleShuffledDiff();

%% Influence versus signal correlations (based on Angular tuning)
populate(STIMANAL.Target2AllCorrAngleTuning);

populate(STIMANAL.InfluenceVsCorrAngleTuning);
populate(STIMANAL.InfluenceVsCorrAngleTuningShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrAngularTuningShuffledDiff(); % this is what I show in the presentation


%% Influence versus signal correlations (based on 2D map concatenated)
populate(STIMANAL.Target2AllCorrMap); %% new ETL correction

populate(STIMANAL.InfluenceVsCorrMap); %% new ETL correction
populate(STIMANAL.InfluenceVsCorrMapShuffled); % this is what I show in the presentation

PLOT_InfluenceVsCorrMapShuffledDiff(); % this is what I show in the presentation

%% Correlations 
PLOT_CorrPairwiseDistanceVoxels()

PLOT_CorrPairwiseDistanceSpikes_MesoSinglePlane()
PLOT_CorrPairwiseDistanceSpikes_MesoVolumetric()
PLOT_CorrPairwiseDistanceSpikes_PhotoRigVolumetric()

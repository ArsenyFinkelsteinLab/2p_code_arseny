function bin_size_effects
%%
subplot(3,2,1)
hold on
b3=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=3') - IMG.Mesoscope,'information_per_spike_regular');
b4=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=4')  - IMG.Mesoscope,'information_per_spike_regular');
b5=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=5')  - IMG.Mesoscope,'information_per_spike_regular');
h3=histogram(b3,linspace(0,0.3,100),'normalization','probability');
h4=histogram(b4,linspace(0,0.3,100),'normalization','probability');
h5=histogram(b5,linspace(0,0.3,100),'normalization','probability');
xlabel('SI (bits/spike)')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})

%%
subplot(3,2,2)
hold on
b3=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=3')  - IMG.Mesoscope,'lickmap_regular_odd_vs_even_corr');
b4=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=4')  - IMG.Mesoscope,'lickmap_regular_odd_vs_even_corr');
b5=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=5')  - IMG.Mesoscope,'lickmap_regular_odd_vs_even_corr');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
ylabel('Probability')
xlabel('2D map corr')
legend({'bin=3', 'bin=4', 'bin=5'})


%%
subplot(3,2,3)
hold on
b3=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=3')  - IMG.Mesoscope,'psth_position_concat_regular_odd_even_corr');
b4=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=4')  - IMG.Mesoscope,'psth_position_concat_regular_odd_even_corr');
b5=fetchn((LICK2D.ROILick2DmapStatsSpikes3bins & 'number_of_bins=5')  - IMG.Mesoscope,'psth_position_concat_regular_odd_even_corr');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
xlabel('PSTH concat corr')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})

%%
subplot(3,2,4)
hold on
b3=fetchn(LICK2D.ROILick2DPSTHStatsSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=3')  - IMG.Mesoscope,'psth_regular_odd_vs_even_corr');
b4=fetchn(LICK2D.ROILick2DPSTHStatsSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=4')  - IMG.Mesoscope,'psth_regular_odd_vs_even_corr');
b5=fetchn(LICK2D.ROILick2DPSTHStatsSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=5')  - IMG.Mesoscope,'psth_regular_odd_vs_even_corr');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
xlabel('PSTH corr')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})


%%
subplot(3,2,5)
hold on
b3=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=3')  - IMG.Mesoscope,'theta_tuning_odd_even_corr');
b4=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=4')  - IMG.Mesoscope,'theta_tuning_odd_even_corr');
b5=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=5')  - IMG.Mesoscope,'theta_tuning_odd_even_corr');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
xlabel('Angular tuning corr')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})

%%
subplot(3,2,6)
hold on
b3=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=3')  - IMG.Mesoscope,'goodness_of_fit_vmises');
b4=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=4')  - IMG.Mesoscope,'goodness_of_fit_vmises');
b5=fetchn(LICK2D.ROILick2DangleSpikes & (LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=5')  - IMG.Mesoscope,'goodness_of_fit_vmises');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
xlabel('Von mises goodness of fit')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})
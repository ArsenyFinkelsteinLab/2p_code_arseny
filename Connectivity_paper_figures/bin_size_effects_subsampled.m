function bin_size_effects_subsampled

rel_roi =(IMG.ROI&IMG.ROIGood) - IMG.ROIBad - IMG.Mesoscope;

mean_dff=fetchn(IMG.ROIdeltaFStats & LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi,'median_dff', 'ORDER BY roi_number');
info=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi,'information_per_spike_regular', 'ORDER BY roi_number');
corr_map=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi,'lickmap_regular_odd_vs_even_corr', 'ORDER BY roi_number');
corr_concat=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi,'psth_position_concat_regular_odd_even_corr', 'ORDER BY roi_number');
subplot(2,2,1)
plot(mean_dff,info,'.')
r=corr([mean_dff(:),info(:)],'Rows' ,'pairwise');
r=r(2);
title(sprintf('r = %.2f',r));
xlabel('Mean DF/F')
ylabel('SI (bits/spike)')

subplot(2,2,2)
plot(mean_dff,corr_concat,'.')
r=corr([mean_dff(:),corr_concat(:)],'Rows' ,'pairwise');
r=r(2);
title(sprintf('r = %.2f',r));
xlabel('Mean DF/F')
ylabel('PSTH concat corr')

subplot(2,2,3)
plot(mean_dff,corr_map,'.')
r=corr([mean_dff(:),corr_map(:)],'Rows' ,'pairwise');
r=r(2);
title(sprintf('r = %.2f',r));
xlabel('Mean DF/F')
ylabel('2D map corr')

rel_roi_b3 = IMG.ROI &(LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=3') - IMG.Mesoscope;
rel_roi_b4 = IMG.ROI &(LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=4') - IMG.Mesoscope;
rel_roi_b5 = IMG.ROI &(LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=4') - IMG.Mesoscope;
%%
subplot(3,2,1)
hold on
b3=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b3, 'information_per_spike_regular');
b4=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b4, 'information_per_spike_regular');
b5=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b5, 'information_per_spike_regular');
b3_original=fetchn((LICK2D.ROILick2DmapStatsSpikes & 'number_of_bins=3') - IMG.Mesoscope, 'information_per_spike_regular');
h3=histogram(b3,linspace(0,0.3,100),'normalization','probability');
h4=histogram(b4,linspace(0,0.3,100),'normalization','probability');
h5=histogram(b5,linspace(0,0.3,100),'normalization','probability');
h3_original=histogram(b3_original,linspace(0,0.3,100),'normalization','probability');
xlabel('SI (bits/spike)')
ylabel('Probability')
legend({'bin=3', 'bin=4', 'bin=5'})

%%
subplot(3,2,2)
hold on
b3=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b3, 'lickmap_regular_odd_vs_even_corr');
b4=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b4, 'lickmap_regular_odd_vs_even_corr');
b5=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b5, 'lickmap_regular_odd_vs_even_corr');
h3=histogram(b3,100,'normalization','probability');
h4=histogram(b4,100,'normalization','probability');
h5=histogram(b5,100,'normalization','probability');
ylabel('Probability')
xlabel('2D map corr')
legend({'bin=3', 'bin=4', 'bin=5'})


%%
subplot(3,2,3)
hold on
b3=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b3, 'psth_position_concat_regular_odd_even_corr');
b4=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b4, 'psth_position_concat_regular_odd_even_corr');
b5=fetchn(LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi_b5, 'psth_position_concat_regular_odd_even_corr');
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
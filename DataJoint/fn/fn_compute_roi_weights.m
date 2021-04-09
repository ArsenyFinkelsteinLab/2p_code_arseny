function [k_insert,weights] = fn_compute_roi_weights (psth_roi_tr_fr, trials1, trials2, tint1, tint2, psth_t_vector, k_insert)

k_insert.mode_time1_st =  tint1(1);
k_insert.mode_time1_end = tint1(2);
k_insert.mode_time2_st = tint2(1);
k_insert.mode_time2_end = tint2(2);


%set 1 - trial average and variance, for the specified time-interval for all units
ix_t = find(psth_t_vector >= tint1(1) & psth_t_vector < tint1(2));
set1 = squeeze(nanmean(psth_roi_tr_fr( :, trials1, ix_t), 3));
set1avg = squeeze(nanmean(set1, 2));
set1var =  squeeze(nanvar(set1,[], 2));

%set 2 - trial average and variance, for the specified time-interval for all units
ix_t = find(psth_t_vector >= tint2(1) & psth_t_vector < tint2(2));
set2 = squeeze(nanmean(psth_roi_tr_fr( :, trials2, ix_t), 3));
set2avg = squeeze(nanmean(set2, 2));
set2var =  squeeze(nanvar(set2,[], 2));


k_insert =repmat(k_insert,size(set1,1),1);

for i_roi = 1:1:size(set1,1)
    if ( isnan(set1avg(i_roi))    || isnan(set2avg(i_roi))    || (set1var(i_roi)+set2var(i_roi)<1e-9))
        weights (i_roi) =NaN;
    else
          weights(i_roi) = (set1avg(i_roi) - set2avg(i_roi))./sqrt(set1var(i_roi)+set2var(i_roi));
%         weights(i_roi) = set1avg(i_roi) - set2avg(i_roi);
        
    end
    k_insert(i_roi).mode_unit_weight =  weights(i_roi);
    k_insert(i_roi).roi_number = i_roi;
end



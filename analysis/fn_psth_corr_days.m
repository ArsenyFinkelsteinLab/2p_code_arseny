function fn_psth_corr_days(k, first_date)


k.session_date=first_date{1};

key=fetch(EXP.Session & k);
multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key,'multiple_sessions_uid');

%     key=fetch(IMG.FOVmultiSessions & key);
roi_number_list = fetchn(IMG.ROI & key, 'roi_number', 'ORDER BY roi_number');
numberROI = numel(roi_number_list);

for iROI=1:1:numberROI
    key.roi_number = iROI;
    
    roi_number_uid = (fetchn(IMG.ROI & key,'roi_number_uid'));
    
    key_roi_uid.roi_number_uid=roi_number_uid;
    key_roi_uid.outcome='hit';
    key_roi_uid.trial_type_name='l';
    psth_l = (fetchn(IMG.ROI*ANLI.FPSTHaverage & key_roi_uid,'psth_avg', 'ORDER BY roi_number'));
    psth_t_l = (fetchn(IMG.ROI*ANLI.FPSTHaverage & key_roi_uid,'psth_timestamps', 'ORDER BY roi_number'));
    
    key_roi_uid.trial_type_name='r';
    psth_r = (fetchn(IMG.ROI*ANLI.FPSTHaverage & key_roi_uid,'psth_avg', 'ORDER BY roi_number'));
    psth_t_r = (fetchn(IMG.ROI*ANLI.FPSTHaverage & key_roi_uid,'psth_timestamps', 'ORDER BY roi_number'));
    
    for i_s=1:1:numel(psth_t_l)
        t_idx=psth_t_l{i_s}<3;
        psth_m_l(i_s,:) = psth_l{i_s}(t_idx); %works only if trial-duration is the same across sessions
    end
    
    for i_s=1:1:numel(psth_t_r)
        t_idx=psth_t_r{i_s}<3;
        psth_m_r(i_s,:) = psth_r{i_s}(t_idx); %works only if trial-duration is the same across sessions
    end
    
    psth=[psth_m_l,psth_m_r];
    
    r(iROI,:,:)=corr(psth', 'rows', 'pairwise');
    %         diag_nan=[1:1:numel(dates)]+NaN;
    %         diag_m = diag(diag_nan,0)
    %         imagescnan(r+diag_m,[0 1])
    %         colorbar
end

r_mean=squeeze(nanmean(r,1));
diag_nan=[1:1:size(r_mean,1)]+NaN;
diag_m = diag(diag_nan,0);
imagescnan(r_mean+diag_m,[0 1]);
colormap(jet);
colorbar;
end
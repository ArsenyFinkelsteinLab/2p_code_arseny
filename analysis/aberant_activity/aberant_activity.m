function aberant_activity
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\aberant_activity\'];

figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 40 18]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);


sessions=fetch((EXP2.Session - IMG.Mesoscope) & (EXP2.SessionEpoch& 'session_epoch_type="spont_only"'));

for i_s=40:1:numel(sessions)
    i_s
    key=sessions(i_s);
    session_date=fetch1(EXP2.Session & key,'session_date');
    filename=[session_date '_anm' num2str(key.subject_id)];
    
    key = fetch((EXP2.SessionEpoch& 'session_epoch_type="spont_only"')& key, 'LIMIT 1');
    imaging_frame_rate=fetchn(IMG.FOV & key,'imaging_frame_rate');
    if imaging_frame_rate==0
       imaging_frame_rate=fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');
    end
        
    Fall=fetchn(IMG.ROITrace &key,'f_trace','ORDER BY roi_number');
    if isempty(Fall)
        continue
    end
    mean_activity=mean(cell2mat(Fall));
    t=(1:1:numel(mean_activity))/imaging_frame_rate;
    t_idx=t<180; % 3 mins
    
    subplot(2,4,1)
    plot(t,mean_activity)
    ylabel(sprintf('Mean F'))
    xlabel('Time(s)')
    title(sprintf('%s anm%d',session_date,key.subject_id));
    %zoom in
    subplot(2,4,5)
    plot(t(t_idx),mean_activity(t_idx))
    ylabel(sprintf('Mean F'))
    xlabel('Time(s)')
    title('Zoom in');
    
    
    Fall=fetchn(IMG.ROIdeltaF &key,'dff_trace','ORDER BY roi_number');
    mean_activity=mean(cell2mat(Fall));
    subplot(2,4,2)
    plot(t,mean_activity)
    ylabel(sprintf('Mean dF/F'))
    xlabel('Time(s)')
    %zoom in
    subplot(2,4,6)
    plot(t(t_idx),mean_activity(t_idx))
    ylabel(sprintf('Mean dF/F'))
    xlabel('Time(s)')
    
    Fall=fetchn(IMG.ROITraceNeuropil &key,'f_trace','ORDER BY roi_number');
    if ~isempty(Fall)
        mean_activity=mean(cell2mat(Fall));
        subplot(2,4,3)
        plot(t,mean_activity)
        ylabel(sprintf('Mean Neuropil F'))
        xlabel('Time(s)')
        %zoom in
        subplot(2,4,7)
        plot(t(t_idx),mean_activity(t_idx))
        ylabel(sprintf('Mean dF/F'))
        xlabel('Time(s)')
        
        Fall=fetchn(IMG.ROIdeltaFNeuropil &key,'dff_trace','ORDER BY roi_number');
        mean_activity=mean(cell2mat(Fall));
        subplot(2,4,4)
        plot(t,mean_activity)
        ylabel(sprintf('Mean Neuropil dF/F'))
        xlabel('Time(s)')
        %zoom in
        subplot(2,4,8)
        plot(t(t_idx),mean_activity(t_idx))
        ylabel(sprintf('Mean dF/F'))
        xlabel('Time(s)')
    end
    
    
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r100']);
    
    
end

end
function lick2D_map_meso()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 

flag_all_or_signif=2;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses

% key.subject_id = 463195;
% key.session =3;

% key.subject_id = 462458;
% key.session =11;  

% key.subject_id = 462455;
% key.session =3;

% key.subject_id = 445873;
% key.session =5;

% key.subject_id = 447990;
% key.session =8;
%  key.subject_id =463190;
% key.session =8;
%  key.subject_id =463189;
% key.session =2;

 key.subject_id =464724;
key.session =2;


% key.session_epoch_number = 1;
% key.number_of_bins=4;
% key.fr_interval_start=-2000;
% key.fr_interval_end=0;
key.fr_interval_start=-1000;
key.fr_interval_end=2000;
session_date = fetch1(EXP2.Session & key,'session_date');
if flag_all_or_signif ==0
    dir_current_fig = [dir_base  '\Lick2D\anm' num2str(key.subject_id) '\' session_date '\cells_all\' ];
    rel= LICK2D.ROILick2Dmap * LICK2D.ROILick2Dselectivity* LICK2D.ROILick2Dangle * LICK2D.ROILick2DPSTH & IMG.ROIGood & key;
elseif flag_all_or_signif ==1
    dir_current_fig = [dir_base  '\Lick2D\anm' num2str(key.subject_id) '\' session_date '\cells_all\' ];
    rel= LICK2D.ROILick2Dmap* LICK2D.ROILick2Dselectivity * LICK2D.ROILick2Dangle * LICK2D.ROILick2DangleShuffle * LICK2D.ROILick2DmapShuffle * LICK2D.ROILick2DPSTH & IMG.ROIGood & key;
% elseif flag_all_or_signif ==2
%     dir_current_fig = [dir_base  '\Lick2D\anm' num2str(key.subject_id) '\' session_date '\cells_signif_2Dlick\'];
%     rel= (ANLI.ROILick2Dmap* ANLI.ROILick2Dselectivity * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH) & IMG.ROIGood & key  & 'lickmap_odd_even_corr>=0.5';
elseif flag_all_or_signif ==2
    dir_current_fig = [dir_base  '\Lick2D\anm' num2str(key.subject_id) '\' session_date '\cells_signif_2Dlick\'];
    rel= LICK2D.ROILick2Dmap * LICK2D.ROILick2Dselectivity* LICK2D.ROILick2Dangle * LICK2D.ROILick2DPSTH & IMG.ROIGood & key  & 'theta_tuning_odd_even_corr>0.5' & 'goodness_of_fit_vmises>0.5';
elseif flag_all_or_signif ==3
    dir_current_fig = [dir_base  '\Lick2D\anm' num2str(key.subject_id) '\' session_date '\cells_signif_motor\' ];
    rel= (LICK2D.ROILick2Dmap* LICK2D.ROILick2Dselectivity * LICK2D.ROILick2Dangle * LICK2D.ROILick2DangleShuffle * LICK2D.ROILick2DmapShuffle * LICK2D.ROILick2DPSTH) & IMG.ROIGood & key  & 'pval_psth<=0.05';
    %     rel= ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH & IMG.ROIGood & key  & 'pval_information_per_spike<=0.01';
    % rel= ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH & IMG.ROIGood & key  & 'pval_information_per_spike<=0.05' & 'pval_lickmap_odd_even_corr<=0.05' ;
    % rel= ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH & IMG.ROIGood & key  & 'pval_rayleigh_length<=0.05';
    % rel= ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH & IMG.ROIGood & key  & 'rayleigh_length>=1';
end

roi_number=fetchn(rel,'roi_number','ORDER BY roi_number');

% rel= rel & 'information_per_spike>0.05';
% dir_current_fig = [dir_current_fig 'time' num2str(key.fr_interval_start) '-' num2str(key.fr_interval_end) '\' 'bins' num2str(key.number_of_bins) '\' ];
dir_current_fig = [dir_current_fig 'time' num2str(key.fr_interval_start) '-' num2str(key.fr_interval_end) '\' ];

number_of_bins = 3;



time_bin=[-3,4]; %2 sec
smooth_bin = 3;


horizontal_dist1=(1/(number_of_bins+2))*0.7;
vertical_dist1=(1/(number_of_bins+2))*0.6;
panel_width1=(1/(number_of_bins+6))*0.8;
panel_height1=(1/(number_of_bins+6))*0.7;
position_x1(1)=0.1;
position_y1(1)=0.2;
for i=1:1:number_of_bins-1
    position_x1(end+1)=position_x1(end)+horizontal_dist1;
    position_y1(end+1)=position_y1(end)+vertical_dist1;
end

plots_order_mat_x=repmat([1:1:number_of_bins],number_of_bins,1);
plots_order_mat_y=repmat([1:1:number_of_bins]',1,number_of_bins);

horizontal_dist2=(1/(number_of_bins+2))*1.2;
vertical_dist2=(1/(number_of_bins+2));
panel_width2=(1/(number_of_bins+5));
panel_height2=(1/(number_of_bins+5));
position_x2(1)=0.1;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.73;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);



for i_roi2=1:1:numel(roi_number)
    kkkroi.roi_number=roi_number(i_roi2);
        M=fetch(rel & kkkroi,'*');

    i_roi=1;
time=M.psth_time;
    
    psth_max= cell2mat(reshape(M(i_roi).psth_per_position,[number_of_bins^2,1]));
    psth_max= psth_max(:,time>-2 & time<=3);
    psth_max=max(psth_max(:));
    for  i_l=1:1:number_of_bins^2
        
        
        axes('position',[position_x1(plots_order_mat_x(i_l)), position_y1(plots_order_mat_y(i_l)), panel_width1, panel_height1]);
        hold on;
        
        plot(time,smooth(M(i_roi).psth_per_position{i_l},smooth_bin),'-r','LineWidth',2);
        try
            plot(time,smooth(M(i_roi).psth_per_position_odd{i_l},smooth_bin),'-','Color',[0 0 0]);
            plot(time,smooth(M(i_roi).psth_per_position_even{i_l},smooth_bin),'-','Color',[0.5 0.5 0.5]);
        end
        ylims=[0,ceil(psth_max)+eps];
        ylim(ylims);
        xlim(time_bin);
        if i_l ==1
            xlabel('Time to lick (s)', 'FontSize',14);
            ylabel('Spikes/s', 'FontSize',14);
            set(gca,'XTick',[time_bin(1),0,time_bin(2)],'Ytick',ylims, 'FontSize',10,'TickLength',[0.05,0]);
        else
            set(gca,'XTick',[time_bin(1),0,time_bin(2)],'Ytick',ylims,'YtickLabel',[], 'FontSize',10,'TickLength',[0.05,0]);
        end
        %         title(num2str(plots_order(i_l)))
    end
    
    axes('position',[position_x2(1),position_y2(1), panel_width2, panel_height2])
    hold on;
    psth_m= smooth(M(i_roi).psth_averaged_over_all_positions,smooth_bin);
    psth_stem = smooth(M(i_roi).psth_stem_over_all_positions,smooth_bin);
    shadedErrorBar(time,psth_m, psth_stem,'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    xlim(time_bin);
    ylim([0, ceil(nanmax(psth_m))]);
    title(sprintf('All positions \n p-val = %.4f ', M(i_roi).pval_psth), 'FontSize',10);
    xlabel('Time to lick (s)', 'FontSize',10);
    ylabel('Spikes/s', 'FontSize',10);
    set(gca,'XTick',[time_bin(1),0,time_bin(2)],'Ytick',[0, ceil(nanmax(psth_m))],'TickLength',[0.05,0], 'FontSize',10);
    

    axes('position',[position_x2(2),position_y2(1), panel_width2, panel_height2])
    hold on;
    psth_preferred= smooth(M(i_roi).psth_preferred,smooth_bin)';
    psth_non_preferred= smooth(M(i_roi).psth_non_preferred,smooth_bin)';
    plot(time,psth_preferred,'-b');
    plot(time,psth_non_preferred,'-r');
    xlim(time_bin);
    ylim([0, ceil(nanmax([psth_preferred,psth_non_preferred]))]);
    title(sprintf('Preferred position \n versus all others '), 'FontSize',10);
    xlabel('Time to lick (s)', 'FontSize',10);
    ylabel('Spikes/s', 'FontSize',10);
    set(gca,'XTick',[time_bin(1),0,time_bin(2)],'Ytick',[0, ceil(nanmax([psth_preferred,psth_non_preferred]))],'TickLength',[0.05,0], 'FontSize',10);


    axes('position',[position_x2(3),position_y2(1), panel_width2, panel_height2])
    hold on;
    xxx=M(i_roi).theta_bins_centers;
    yyy=M(i_roi).theta_tuning_curve;
            yyy_vnmises=M(i_roi).theta_tuning_curve_vmises;
        plot([-180:1:179],yyy_vnmises,'-g','LineWidth',2);
    plot(xxx,yyy,'-b','LineWidth',2);
    plot(xxx,M(i_roi).theta_tuning_curve_odd,'-','Color',[0 0 0]);
    plot(xxx,M(i_roi).theta_tuning_curve_even,'-','Color',[0.5 0.5 0.5]);

    try
    title(sprintf('Directional tuning \n RV = %.2f p-val = %.2f \n r = %.2f  p-val = %.4f \n theta = %d thetaVM = %d deg',M(i_roi).rayleigh_length,M(i_roi).pval_rayleigh_length, M(i_roi).theta_tuning_odd_even_corr,  M(i_roi).pval_theta_tuning_odd_even_corr, floor(M(i_roi).preferred_theta), floor(M(i_roi).preferred_theta_vmises)), 'FontSize',10);
    catch
            title(sprintf('Directional tuning \n RV = %.2f\n r = %.2f  r^2 fit VM = %.2f \n theta = %d VM = %d deg',M(i_roi).rayleigh_length, M(i_roi).theta_tuning_odd_even_corr, M(i_roi).goodness_of_fit_vmises,  floor(M(i_roi).preferred_theta), floor(M(i_roi).preferred_theta_vmises)), 'FontSize',10);
    end
    xlim([-180,180])
    ylim([0, ceil(nanmax([yyy,yyy_vnmises]))])
    xlabel('Direction ({\circ})', 'FontSize',10);
    ylabel('Spikes/s', 'FontSize',10);
    set(gca,'XTick',[-180,0,180],'Ytick',[0, ceil(nanmax([yyy,yyy_vnmises]))-eps], 'FontSize',10,'TickLength',[0.05,0]);
    
    %% Maps
    axes('position',[position_x2(4),position_y2(1)-0.03, panel_width2*1.5, panel_height2*1.5])
    imagescnan(M(i_roi).pos_x_bins_centers, M(i_roi).pos_x_bins_centers, M(i_roi).lickmap_fr)
    max_map=max(M(i_roi).lickmap_fr(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    try
    title(sprintf('ROI %d anm%d %s\n \n Positional (2D) tuning  \n I = %.2f bits/spike  \n  p-val = %.4f  ',roi_number(i_roi2),key.subject_id, session_date, M(i_roi).information_per_spike, M(i_roi).pval_information_per_spike ), 'FontSize',10);
    catch
            title(sprintf('ROI %d anm%d %s\n \n Positional (2D) tuning  \n I = %.2f bits/spike  \n  ',roi_number(i_roi2),key.subject_id, session_date, M(i_roi).information_per_spike), 'FontSize',10);
    end
    axis xy
    axis equal;
    axis tight
    colorbar
    xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    
    axes('position',[position_x2(4),position_y2(3)-0.05, panel_width2*1.5, panel_height2*1.5])
    imagescnan(M(i_roi).pos_x_bins_centers, M(i_roi).pos_x_bins_centers, M(i_roi).lickmap_fr_odd)
    max_map=max(M(i_roi).lickmap_fr_odd(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    try
    title(sprintf('Stability r <odd,even> = %.2f \n p-val = %.4f  \n \n Odd trials', M(i_roi).lickmap_odd_even_corr, M(i_roi).pval_lickmap_odd_even_corr ), 'FontSize',10);
    catch
            title(sprintf('Stability r <odd,even> = %.2f \n\n \n Odd trials', M(i_roi).lickmap_odd_even_corr), 'FontSize',10);
    end
    axis xy
    axis equal;
    axis tight
    set(gca,'YDir','normal');
    colorbar
    
    axes('position',[position_x2(4),position_y2(4)-0.05, panel_width2*1.5, panel_height2*1.5])
    imagescnan(M(i_roi).pos_x_bins_centers, M(i_roi).pos_x_bins_centers, M(i_roi).lickmap_fr_even)
    max_map=max(M(i_roi).lickmap_fr_even(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('\n  \n Even trials '), 'FontSize',10);
    axis xy
    axis equal;
    axis tight;
    set(gca,'YDir','normal');
    colorbar
    
    
%     x_bins=M(i_roi).pos_x_bins_centers;
%     z_bins =M(i_roi).pos_z_bins_centers;
%     counter=1;
%     for ix=1:1:numel(x_bins)
%         for iz=1:1:numel(z_bins)
%             pos_x(counter) = x_bins(ix);
%             pos_z(counter) = z_bins(iz);
%             counter=counter+1;
%         end
%     end
%     [theta, radius] = cart2pol(pos_x,pos_z);
%     theta=rad2deg(theta);
%     theta_bins=linspace(-180,180,9);
%     theta_bins = theta_bins - mean(diff(theta_bins))/2;
%     theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;
%     
%     
%     [temp,~,theta_idx] = histcounts(theta,theta_bins);
%     
%     theta_idx(theta_idx==0)=1;
%     
%     map=M(i_roi).lickmap_fr;
%     
%     for i_theta=1:1:numel(theta_bins_centers)
%         idx= find( (theta_idx==i_theta));
%         theta_spikes_binned(i_theta) = sum(map(idx));
%         theta_timespent_binned(i_theta)=numel(idx);
%     end
%     
%     [~, theta_firing_rate_smoothed, preferred_theta,Rayleigh_length]  = fn_compute_generic_1D_tuning2 ...
%         (theta_timespent_binned, theta_spikes_binned, theta_bins_centers, 1,  1, 1, 1);
%     plot(theta_bins_centers,theta_firing_rate_smoothed,'-r')
%     
    
    
    
    
    
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
    filename=['roi_' num2str(roi_number(i_roi2))];
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r200']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    
    clf
end


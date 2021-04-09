function lick2D_clusters_block()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 

%
% key.subject_id = 463195;
% key.session =3;

% key.subject_id = 462455;
% key.session =2;

% key.subject_id = 462458;
% key.session =12;


key.number_of_bins=4;
key.fr_interval_start=-1000;
key.fr_interval_end=2000;

% key.fr_interval_start=-1000;
% key.fr_interval_end=0;
% session_date = fetch1(EXP2.Session & key,'session_date');

smooth_bins=1; % one element backward, current element, and one element forward

flag_plot_rois =1; % 1 to plot ROIs on top of the image plane, 0 not to plot

flag_all_or_signif=1;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses
filename=[];
dir_current_fig = [dir_base  '\Lick2D\population\clusters_nlock\bins' num2str(key.number_of_bins) '\'];
if flag_all_or_signif ==1
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2Dselectivity * ANLI.ROILick2DPSTH*ANLI.ROILick2DPSTHReward *ANLI.ROILick2DPSTHBlock * ANLI.ROIHierarClusterShapeAndSelectivity )* IMG.ROI  & IMG.ROIGood & key ;
elseif flag_all_or_signif ==2
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2Dselectivity * ANLI.ROILick2DPSTH*ANLI.ROILick2DPSTHReward *ANLI.ROILick2DPSTHBlock * ANLI.ROIHierarClusterShapeAndSelectivity )* IMG.ROI  & IMG.ROIGood & key * IMG.ROI  & IMG.ROIGood & key   & 'lickmap_odd_even_corr>0.5';
    filename=['signif_2Dlick'];
end

try
session_date = fetch1(EXP2.Session & key,'session_date');
filename = [filename 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]
catch
 filename = ['all'];

end

if flag_plot_rois==0
    filename=[filename '_norois'];
end
% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
% rel = rel & 'heirar_cluster_percent>2' & 'psth_selectivity_odd_even_corr>0.5';
rel = rel & 'heirar_cluster_percent>=1';


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.25;
vertical_dist=0.25;

panel_width1=0.2;
panel_height1=0.2;

position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.7;
position_y1(end+1)=position_y1(end)-vertical_dist*1.1;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;



horizontal_dist2=0.1;
vertical_dist2=0.15;

panel_width2=0.07;
panel_height2=0.1;



position_x2(1)=0.05;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;



position_y2(1)=0.82;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;




M=fetch(rel ,'*');
M=struct2table(M);

roi_cluster_id = M.heirar_cluster_id;
heirar_cluster_percent = M.heirar_cluster_percent;
[unique_cluster_id,ia,ic]  = unique(roi_cluster_id);
heirar_cluster_percent = heirar_cluster_percent(ia);
[B,I]  = sort(heirar_cluster_percent,'descend');
heirar_cluster_percent = heirar_cluster_percent(I);
unique_cluster_id = unique_cluster_id(I);
for ic=1:1:numel(roi_cluster_id)
    roi_cluster_renumbered(ic) = find(unique_cluster_id ==roi_cluster_id(ic));
end
my_colormap=hsv(numel(unique_cluster_id));
% my_colormap(4,:)=my_colormap(5,:);
% my_colormap(3,:)=my_colormap(2,:);
% my_colormap(6,:)=my_colormap(4,:);



%% Plot clusters

PSTH1= M.psth_averaged_over_all_positions;
PSTH1 = movmean(PSTH1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
PSTH1_before_scaling=PSTH1;
PSTH1 = PSTH1./nanmax(PSTH1,[],2);

Select1= M.selectivity;
Select1 = movmean(Select1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
Select1 = Select1./nanmax(PSTH1_before_scaling,[],2);

Select2= M.selectivity_first;
Select2 = movmean(Select2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
Select2 = Select2./nanmax(PSTH1_before_scaling,[],2);

Select3= M.selectivity_begin;
Select3 = movmean(Select3 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
Select3 = Select3./nanmax(PSTH1_before_scaling,[],2);

Select4= M.selectivity_mid;
Select4 = movmean(Select4 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
Select4 = Select4./nanmax(PSTH1_before_scaling,[],2);

Select5= M.selectivity_end;
Select5 = movmean(Select5 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
Select5 = Select5./nanmax(PSTH1_before_scaling,[],2);

SelectRew1= M.selectivity_small;
SelectRew1 = movmean(SelectRew1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
SelectRew1 = SelectRew1./nanmax(PSTH1_before_scaling,[],2);

SelectRew2= M.selectivity_regular;
SelectRew2 = movmean(SelectRew2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
SelectRew2 = SelectRew2./nanmax(PSTH1_before_scaling,[],2);

SelectRew3= M.selectivity_large;
SelectRew3 = movmean(SelectRew3 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
SelectRew3 = SelectRew3./nanmax(PSTH1_before_scaling,[],2);



% Block0= M.psth_averaged_over_all_positions_first;
% Block0 = movmean(Block0 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Block0 = Block0./nanmax(PSTH1_before_scaling,[],2);
% 
% Block1= M.psth_averaged_over_all_positions_begin;
% Block1 = movmean(Block1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Block1 = Block1./nanmax(PSTH1_before_scaling,[],2);
% 
% Block2 = M.psth_averaged_over_all_positions_mid;
% Block2 = movmean(Block2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Block2 = Block2./nanmax(PSTH1_before_scaling,[],2);
% 
% Block3= M.psth_averaged_over_all_positions_end;
% Block3 = movmean(Block3 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Block3 = Block3./nanmax(PSTH1_before_scaling,[],2);
% 
% Reward0= M.psth_averaged_over_all_positions_small;
% Reward0 = movmean(Reward0 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Reward0 = Reward0./nanmax(PSTH1_before_scaling,[],2);
% 
% Reward1= M.psth_averaged_over_all_positions_regular;
% Reward1 = movmean(Reward1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Reward1 = Reward1./nanmax(PSTH1_before_scaling,[],2);
% 
% Reward2= M.psth_averaged_over_all_positions_large;
% Reward2 = movmean(Reward2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% Reward2 = Reward2./nanmax(PSTH1_before_scaling,[],2);


for ic=1:1:numel(unique_cluster_id)
    psth_cluster(ic,:)=nanmean(PSTH1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    axes('position',[position_x2(ic), position_y2(1), panel_width2, panel_height2]);
    hold on;
    plot([0 0],[0,1],'-k');
    plot(M.time_psth(1,:),psth_cluster(ic,:))
    title(sprintf('C%d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
    ylim([0, 1]);
        xlim([-1.5,2.5]);

%     axes('position',[position_x2(ic), position_y2(2), panel_width2, panel_height2]);
%     hold on;
%     plot([0 0],[0,1],'-k');
%     psth_cluster(ic,:)=nanmean(Block0(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 0])
%     psth_cluster(ic,:)=nanmean(Block1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[1 0 0])
%         psth_cluster(ic,:)=nanmean(Block2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 1 0])
%         psth_cluster(ic,:)=nanmean(Block3(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 1])
% %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
% %     ylim([0, 1]);
% 
%  axes('position',[position_x2(ic), position_y2(3), panel_width2, panel_height2]);
%     hold on;
%     plot([0 0],[0,1],'-k');
%     psth_cluster(ic,:)=nanmean(Reward0(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 0])
%     psth_cluster(ic,:)=nanmean(Reward1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[1 0 0])
%         psth_cluster(ic,:)=nanmean(Reward2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
%     plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 1])
    
    
    axes('position',[position_x2(ic), position_y2(2), panel_width2, panel_height2]);
    hold on;
    plot([0 0],[0,1],'-k');
            psth_cluster(ic,:)=nanmean(Select1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:))
%     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
        xlim([-1.5,2.5]);



    axes('position',[position_x2(ic), position_y2(3), panel_width2, panel_height2]);
    hold on;
    plot([0 0],[0,1],'-k');
   psth_cluster(ic,:)=nanmean(Select2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 0])
    psth_cluster(ic,:)=nanmean(Select3(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[1 0 0])
        psth_cluster(ic,:)=nanmean(Select4(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 1 0])
        psth_cluster(ic,:)=nanmean(Select5(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 1])    
        xlim([-1.5,2.5]);

    
     axes('position',[position_x2(ic), position_y2(4), panel_width2, panel_height2]);
    hold on;
    plot([0 0],[0,1],'-k');
    psth_cluster(ic,:)=nanmean(SelectRew1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 0])
    psth_cluster(ic,:)=nanmean(SelectRew2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[1 0 0])
        psth_cluster(ic,:)=nanmean(SelectRew3(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
    plot(M.time_psth(1,:),psth_cluster(ic,:),'Color',[0 0 1])
        xlim([-1.5,2.5]);
end




if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);





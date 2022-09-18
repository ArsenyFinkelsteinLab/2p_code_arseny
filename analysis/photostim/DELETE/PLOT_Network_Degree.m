function PLOT_Network_Degree()
clf

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity\'];
filename = 'network_degree_vs_correlations';

k_degree.max_distance_lateral =100;
k_degree.session_epoch_number=2;
k_degree.p_val = 0.05;
k_neurons_or_control.neurons_or_control=1;

k_corr_local.radius_size=100;
k_corr_local.session_epoch_type = 'spont_only'; % behav_only spont_only
k_corr_local.num_svd_components_removed=0;
rel_session = EXP2.Session & (STIMANAL.OutDegree & IMG.Volumetric) & (EXP2.SessionEpoch& 'session_epoch_type="spont_only"') &  (STIMANAL.NeuronOrControlNumber2 & 'num_targets_neurons>=50') &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1' );


%Graphics
%---------------------------------

set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);
left_color=[0 0 0];
right_color=[0 0 0];
set(gcf,'defaultAxesColorOrder',[left_color; right_color]);


horizontal_dist=0.25;
vertical_dist=0.3;

panel_width1=0.15;
panel_height1=0.15;

position_x1(1)=0.07;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.75;
position_y1(end+1)=position_x1(end)-vertical_dist;
position_y1(end+1)=position_x1(end)-vertical_dist;
position_y1(end+1)=position_x1(end)-vertical_dist;


sessions = fetch(rel_session);

DATA_DEGREE_ALL=[];
DATA_CORR_ALL=[];

for i_s = 1:1:rel_session.count
    k_s = sessions(i_s);
    i_s;
    rel_degree = STIMANAL.OutDegree*STIM.ROIResponseDirect2  & (STIMANAL.NeuronOrControl2 & k_neurons_or_control) & k_degree & k_s;
    DATA_DEGREE = struct2table(fetch(rel_degree, '*'));
    %    numel(unique(DATA_DEGREE.roi_number))
    
    key_epoch = fetch(EXP2.SessionEpoch & k_s & k_corr_local);
    rel_corr_local = POP.ROICorrLocalPhoto2  & k_s & k_corr_local & key_epoch;
    
    max_degree_session_excit(i_s)=max([DATA_DEGREE.out_degree_excitatory]);
    mean_degree_session_excit(i_s)=mean([DATA_DEGREE.out_degree_excitatory]);
    
    max_degree_session_inhibit(i_s)=max([DATA_DEGREE.out_degree_inhibitory]);
    mean_degree_session_inhibit(i_s)=mean([DATA_DEGREE.out_degree_inhibitory]);
    
    
%         if max_degree_session_excit(i_s)<30
%             continue
%         end
    
    if rel_corr_local.count==0
        continue
    end
    rel_corr_local =  rel_corr_local& key_epoch(1);
    
    DATA_CORR = struct2table(fetch(rel_corr_local, '*'));
    
    
    idx=[];
    for i_r=1:1:size(DATA_DEGREE,1)
        idx(i_r) = find(DATA_CORR.roi_number == DATA_DEGREE.roi_number(i_r));
    end
    DATA_CORR_ALL =[DATA_CORR_ALL; DATA_CORR(idx,:)];
    DATA_DEGREE_ALL =[DATA_DEGREE_ALL; DATA_DEGREE];
end

num_neurons_in_radius = DATA_CORR_ALL.num_neurons_in_radius_without_inner_ring;

% if flag_response==0
%     out_degree = DATA_DEGREE_ALL.out_degree_all1;
% elseif flag_response==1
%     out_degree = DATA_DEGREE_ALL.out_degree_excitatory;
% elseif flag_response==2
%     out_degree = DATA_DEGREE_ALL.out_degree_inhibitory;
% end

% out_degree=(out_degree./num_neurons_in_radius)*mean(num_neurons_in_radius);

corr_local = DATA_CORR_ALL.corr_local_without_inner_ring;
response_mean = DATA_DEGREE_ALL.response_mean;

out_degree_excitatory = DATA_DEGREE_ALL.out_degree_excitatory;
out_degree_inhibitory= DATA_DEGREE_ALL.out_degree_inhibitory;

out_degree_excitatory = (out_degree_excitatory./num_neurons_in_radius)*mean(num_neurons_in_radius);
out_degree_inhibitory= (out_degree_inhibitory./num_neurons_in_radius)*mean(num_neurons_in_radius);





% subplot(2,3,1)
% plot(out_degree,corr_local,'.')
% r=corr(out_degree,corr_local);
% xlabel('Number of connections')
% ylabel('Local correlation')
% title(sprintf('r = %.2f',r));




% subplot(2,3,2)
% plot(out_degree,num_neurons_in_radius,'.')
% r=corr(out_degree,num_neurons_in_radius);
% xlabel('Number of connections')
% ylabel('Number of neurons in radius')
% title(sprintf('r = %.2f',r));

% subplot(2,3,6)
% plot(out_degree_excitatory,out_degree_inhibitory,'.')
% r=corr(out_degree_excitatory,out_degree_inhibitory);
% xlabel('Number of connections, excitatory')
% ylabel('Number of connections, inhibitory')
% title(sprintf('r = %.2f',r));


% subplot(2,3,3)
% plot(out_degree,response_mean,'.')
% r=corr(out_degree,response_mean);
% xlabel('Number of connections')
% ylabel('Response, z-score')
% title(sprintf('r = %.2f',r));




%% Excitatory connections, versus Random Network
k=out_degree_excitatory;
hist_bins = linspace(0,max(k),10); %14
hist_bins_centers = hist_bins(1:end-1) + diff(hist_bins)/2;
hist_bins_centers=round(hist_bins_centers);

ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
hold on
[k_prob]=histcounts(k,hist_bins);
k_prob=k_prob./length(k);
plot(hist_bins_centers,k_prob,'.-r')
% poisson
poisson_prob_at_bins = poisspdf(hist_bins_centers,mean(k));
continuous_bins=[0:1:max(hist_bins)];
poisson_prob_continuous = poisspdf(continuous_bins,mean(k));
poisson_prob_at_bins=[];
for i_b=2:1:numel(hist_bins)
    poisson_prob_at_bins(i_b)=sum(poisson_prob_continuous([ceil(hist_bins(i_b-1))+1:1: ceil(hist_bins(i_b))]))
end
poisson_prob = max( poisson_prob_at_bins)*(poisson_prob_continuous./max(poisson_prob_continuous));
plot(continuous_bins,poisson_prob,'-' ,'Color',[0.5 0.5 0.5])
xlabel('Effective Connections')
ylabel('Probability')
title('Excitatory connections', 'Color',[1 0 0]);
text(35,0.2,'Observed','Color',[1 0 0]);
text(25,0.7,sprintf('Random Network \n(Erdos-Renyi)'),'Color',[0.5 0.5 0.5]);

%log scale
ax1=axes('position',[position_x1(1), position_y1(2), panel_width1, panel_height1]);
loglog((hist_bins_centers),(k_prob),'.-r');
hold on
%poisson
loglog(continuous_bins,poisson_prob,'-','Color',[0.5 0.5 0.5]);
xlabel('Effective Connections')
ylabel('Probability')
box off;
set(gca,'Xtick',[1,10,100], 'Ytick',[0.0001, 0.001, 0.01, 0.1, 1])
ylim([10^-4, 1]);
xlim([4 100]);



%% Inhibitory connections, versus Random Network
k=out_degree_inhibitory;
hist_bins = linspace(0,max(k),10); %14
hist_bins_centers = hist_bins(1:end-1) + diff(hist_bins)/2;
hist_bins_centers=round(hist_bins_centers);

ax1=axes('position',[position_x1(2), position_y1(1), panel_width1, panel_height1]);
hold on
[k_prob]=histcounts(k,hist_bins);
k_prob=k_prob./length(k);
plot(hist_bins_centers,k_prob,'.-b')
poisson_prob_at_bins = poisspdf(hist_bins_centers,mean(k));
continuous_bins=[0:1:max(hist_bins)];
poisson_prob_continuous = poisspdf(continuous_bins,mean(k));
poisson_prob_at_bins=[];
for i_b=2:1:numel(hist_bins)
    poisson_prob_at_bins(i_b)=sum(poisson_prob_continuous([ceil(hist_bins(i_b-1))+1:1: ceil(hist_bins(i_b))]))
end
poisson_prob = max( poisson_prob_at_bins)*(poisson_prob_continuous./max(poisson_prob_continuous));
plot(continuous_bins,poisson_prob,'-' ,'Color',[0.5 0.5 0.5])
xlabel('Effective Connections')
ylabel('Probability')
title('Inhibitory connections','Color', [0 0 1]);
text(35,0.2,'Observed','Color',[0 0 1]);

%log scale
ax1=axes('position',[position_x1(2), position_y1(2), panel_width1, panel_height1]);
loglog((hist_bins_centers),(k_prob),'.-b');
hold on
%poisson
loglog(continuous_bins,poisson_prob,'-','Color',[0.5 0.5 0.5]);
xlabel('Effective Connections')
ylabel('Probability')
k_prob(k_prob==0)=NaN;
% set(gca,'FontSize',12);
ylim([10^-3.2, 1]);
box off;
set(gca,'Xtick',[1,10,100], 'Ytick',[0.001, 0.01, 0.1, 1])
xlim([4 150]);

%% Local correlations
ax1=axes('position',[position_x1(3), position_y1(1), panel_width1, panel_height1]);
hold on

% % inhibitory
% k =out_degree_inhibitory;
% hist_bins = prctile(k,linspace(0,100,12));
% hist_bins_centers = hist_bins(1:end-1) + diff(hist_bins)/2;
% x=k;
% y=corr_local;
% [y_binned_mean, y_binned_stem]= fn_bin_data(x,y,hist_bins);
% 
% shadedErrorBar(hist_bins_centers,y_binned_mean,y_binned_stem,'lineprops',{'.-','Color',[0 0 1]})
% xlabel('Effective Connections')
% ylim([0,max(y_binned_mean+y_binned_stem)])
% 

% excitatory
k =out_degree_excitatory;
% hist_bins = prctile(k,linspace(1,100,10));
hist_bins = linspace(1,ceil(max(k)),9);
hist_bins(end-1)=[];
hist_bins_centers = hist_bins(1:end-1) + diff(hist_bins(1:1:2))/2;
x=k;
y=corr_local;
[y_binned_mean, y_binned_stem]= fn_bin_data(x,y,hist_bins);
shadedErrorBar(hist_bins_centers,y_binned_mean,y_binned_stem,'lineprops',{'.-','Color',[1 0 0]})
xlabel('Effective Connections')
ylabel('Local Correlation')
title(sprintf('Trace correlation with \nneighboring neurons\n'))
% ylim([0,max(y_binned_mean+y_binned_stem)])
% ylim([0.025,max(y_binned_mean+y_binned_stem)])
ylim([0.025,0.15])
set(gca, 'Ytick',[0.05, 0.1, 0.15])

box off;
% text(15,0.01,'Inhibitory','Color',[0 0 1]);
% text(15,0.03,'Excitatory','Color',[1 0 0]);


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

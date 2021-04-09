function graph_analysis()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\graph_analysis\'];

key.subject_id = 445105;
key.session =3;
epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
key.session_epoch_number = epoch_list(end); % to take the photostim groups from
rel=STIM.ROIResponse50;

GRAPH=fetch(STIM.ROIGraph2 & key,'*');


p_val_threshold =0.001;
minimal_distance =30; %in microns

pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
minimal_distance = minimal_distance/pix2dist; % in pixels


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.12;
panel_height=0.12;
horizontal_distance=0.18;
vertical_distance=0.18;

position_x(1)=0.07;
position_x(end+1)=position_x(end) + horizontal_distance+0.19;
position_x(end+1)=position_x(end) + horizontal_distance;
position_x(end+1)=position_x(end) + horizontal_distance;

position_y(1)=0.8;


session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\'];
filename=['graph_stats' num2str(key.session) '_' session_date ];


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);


% Creating a Graph
M=GRAPH.mat_response_mean;

M = M - diag(diag(M)); %setting diagonal values to 0
M(GRAPH.mat_response_pval>p_val_threshold)=0;
M(GRAPH.mat_distance<=minimal_distance)=0;

G = digraph(M);
LWidths = 5*abs(G.Edges.Weight)/max(abs(G.Edges.Weight));

%% Out degree
subplot(2,2,1);
hold on
D = outdegree(G);

hist_bins = linspace(0,max(D),7);
hist_bins_centers = hist_bins(1:end-1) + mean(diff(hist_bins))/2;

[D_prob]=histcounts(D,hist_bins);
D_prob=D_prob./length(D);
loglog(log10(hist_bins_centers),log10(D_prob),'.-b');
xlabel('Log (In Degree)')
ylabel('Log (Probability)')


D_poisson = poissrnd(mean(D),1000*numel(D),1); 
[poisson_prob]=histcounts(D_poisson,hist_bins);
poisson_prob=poisson_prob./(1000*numel(D));
loglog(log10(hist_bins_centers),log10(poisson_prob),'.-g');
text(0,0,'ALM','Color',[0 0 1]);
text(0,-0.25,'Random Network (Erdos-Renye)','Color',[0 1 0]);
set(gca,'FontSize',12);

%% In degree
subplot(2,2,2);
hold on
D = indegree(G);

hist_bins = linspace(0,max(D),7);
hist_bins_centers = hist_bins(1:end-1) + mean(diff(hist_bins))/2;

[D_prob]=histcounts(D,hist_bins);
D_prob=D_prob./length(D);
loglog(log10(hist_bins_centers),log10(D_prob),'.-b');
xlabel('Log (In Degree)')
ylabel('Log (Probability)')

D_poisson = poissrnd(mean(D),1000*numel(D),1); 
[poisson_prob]=histcounts(D_poisson,hist_bins);
poisson_prob=poisson_prob./(1000*numel(D));
loglog(log10(hist_bins_centers),log10(poisson_prob),'.-g');
set(gca,'FontSize',12);


%% In vs out degree
subplot(2,2,3);
Din = indegree(G);
Dout = outdegree(G);

plot(Dout+rand(size(Dout)),Din+rand(size(Din)),'.')
r=corr([Dout,Din])
r=r(2);
xlabel('Out Degree')
ylabel('In Degree')
title(sprintf('r = %.2f',r));
set(gca,'FontSize',12);

% %% cluster coeff
% subplot(2,2,4)
% [C1,C2, C] = clustCoeff(M);
% % loglog(log10(Dout),log10(C+abs(rand(size(Dout))/1000)),'.b');
% plot(Dout+rand(size(Dout)),C+rand(size(Dout))/1000,'.')



% %% out degree all neurons
% subplot(2,2,4)
% hold on
% group_list = fetchn(IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<17.38') & key,'photostim_group_num','ORDER BY photostim_group_num');
% rel=STIM.ROIResponse50 & 'response_p_value<=0.001' & 'response_distance_pixels>30' & key;
% S=fetch(rel ,'*');
% network_k=[];
% for i_g=1:1:numel(group_list)
%         idx=[S.photostim_group_num] ==i_g;
%         network_k(i_g)=numel(S(idx));
% end
% 
% 
% D = network_k;
% 
% hist_bins = linspace(0,max(D),7);
% hist_bins_centers = hist_bins(1:end-1) + mean(diff(hist_bins))/2;
% 
% [D_prob]=histcounts(D,hist_bins);
% D_prob=D_prob./length(D);
% loglog(log10(hist_bins_centers),log10(D_prob),'.-b');
% xlabel('Log (In Degree)')
% ylabel('Log (Probability)')
% 
% 
% D_poisson = poissrnd(mean(D),1000*numel(D),1); 
% [poisson_prob]=histcounts(D_poisson,hist_bins);
% poisson_prob=poisson_prob./(1000*numel(D));
% loglog(log10(hist_bins_centers),log10(poisson_prob),'.-g');
% text(0,0,'ALM','Color',[0 0 1]);
% text(0,-0.25,'Random Network (Erdos-Renye)','Color',[0 1 0]);
% set(gca,'FontSize',12);

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

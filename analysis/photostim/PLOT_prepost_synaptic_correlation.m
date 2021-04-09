function PLOT_prepost_synaptic_correlation()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity\'];
filename = 'pre_post_synaptic_correlation';

clf;

DefaultFontSize =24;
% figure
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

% set(gcf,'DefaultAxesFontSize',6);



horizontal_dist=0.45;
vertical_dist=0.35;

panel_width=0.4;
panel_height=0.4;
position_x(1)=0.2;
position_x(end+1)=position_x(end)+horizontal_dist;

position_y(1)=0.5;
position_y(end+1)=position_y(end)-vertical_dist;


%% Correlation
r_all=fetchn(STIMANAL.ROIInfluenceVariability,'pre_post_synaptic_response_correlation');


ax1=axes('position',[position_x(1), position_y(1), panel_width, panel_height/2]);
hold on
hist_bins=linspace(-1,1,15);
hhh=histogram(r_all,hist_bins,'FaceColor',[0.5 0.5 0.5]);
%                     xlabel([sprintf('''Pre-synaptic'' response \n peak ') ('(\Delta F/F)')]);

ylabel(sprintf('Counts (pairs)'));
set(gca,'FontSize',24);
xlabel(sprintf('  Correlation, r\n <Pre-synaptic,Post-synaptic>'),'FontSize',24);

title(sprintf('  Response correlation \n r = %.2f',nanmean(r_all)),'FontSize',24)



fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

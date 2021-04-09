function PLOT_NumSignifResponseCellsSVD()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\'];
clf;

% figure
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 15 10]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.35;
vertical_dist=0.35;

panel_width1=0.3;
panel_height1=0.25;
position_x1(1)=0.2;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.5;
position_y1(end+1)=position_y1(end)-vertical_dist;



% key.is_volumetric =1; % 1 volumetric, 1 single plane
% distance_axial_bins=[0,60,90,120];
% % key.session_epoch_number=2;
% rel = STIM.ROIResponseSVD;
% flag_response=0 ; %0 all, 1 excitation, 2 inhibition, 3 absolute
% key.num_svd_components_removed=0;
% response_p_val=0.05;


%% Direct response
num_svd_components_removed_vector = [0, 1,10];
key.neurons_or_control=1; 
for i_c = 1:1:numel(num_svd_components_removed_vector)
    key.num_svd_components_removed = num_svd_components_removed_vector(i_c);
    rel = STIM.ROIResponseDirect  & (STIMANAL.NeuronOrControl & key);
    D=struct2table(fetch(rel,'*'));
    plot(D.response_mean_odd,D.response_mean_even,'.')
        plot( -log10(D.response_p_value2_odd), -log10(D.response_p_value2_even),'.')
        plot( -log10(D.response_p_value1), -log10(D.response_p_value2),'.')
        plot( -log10(D.response_p_value1), -log10(D.response_p_value3),'.')

   	
end



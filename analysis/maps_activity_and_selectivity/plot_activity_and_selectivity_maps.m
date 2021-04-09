
function plot_activity_and_selectivity_maps
close all
dir_save_figure = ['Z:\users\Arseny\Projects\Learning\imaging2p\Activity_maps\anm\'];

% FIGURE
%--------------------------------------------------------------------------
% Some WYSIWYG options:
figure;

set(gcf,'DefaultAxesFontSize',7);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0.5 0.5 21 29.7]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[0 0 0 0]);

panel_width1=0.33;
panel_height1=panel_width1*0.7071;
horizontal_distance1=0.23;
vertical_distance1=0.3;


position_x1(1)=-0.01;
position_x1(2)=position_x1(1)+horizontal_distance1;
position_x1(3)=position_x1(2)+horizontal_distance1;
position_x1(4)=position_x1(3)+horizontal_distance1;
position_x1(5)=position_x1(4)+horizontal_distance1;

position_y1(1)=0.68;
position_y1(2)=position_y1(1)-vertical_distance1;
position_y1(3)=position_y1(2)-vertical_distance1;
position_y1(4)=position_y1(3)-vertical_distance1;
position_y1(5)=position_y1(4)-vertical_distance1;
position_y1(6)=position_y1(5)-vertical_distance1;



% trial_epoch_name = fetchn(ANLI.EpochName2,'trial_epoch_name');
trial_epoch_name={'sample','delay','response','all'};
sessions = unique(fetchn(IMG.FOVMapSelectivity,'session'));

for i_s = 1:1:numel(sessions)
    k.session = sessions(i_s);
    for i_epoch=1:1:numel(trial_epoch_name)
        k.trial_epoch_name =trial_epoch_name{i_epoch};
        
        ax1=axes('position',[position_x1(i_epoch) position_y1(1) panel_width1 panel_height1]);
        k.trial_type_name='r';
        k.outcome='hit';
        label='Right, hit';
        map=fetch1(IMG.FOVMapActivity & k,'map_activity_dff');
        cmp1 = fn_plot_map3(map, label, k);
        colormap(ax1,cmp1);
        
        ax2=axes('position',[position_x1(i_epoch) position_y1(2) panel_width1 panel_height1]);
        k.trial_type_name='l';
        k.outcome='hit';
        label='Left, hit';
        map=fetch1(IMG.FOVMapActivity & k,'map_activity_dff');
        cmp2 = fn_plot_map3(map, label, k);
        colormap(ax2,cmp2);
        
        
        ax3=axes('position',[position_x1(i_epoch) position_y1(3) panel_width1 panel_height1]);
        label='R-L selectivity';
        map=fetch1(IMG.FOVMapSelectivity & k,'map_selectivity_dff');
        map=map*(-1);
        cmp3 = fn_plot_map3(map, label, k);
        colormap(ax3,cmp3);
        
    end
    
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    
    filename=['maps_' num2str(sessions(i_s))];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff  -r600']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    clf;
end
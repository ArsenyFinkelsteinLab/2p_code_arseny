function proj_across_days()
close all;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\ProjLongitudinal\AF09_anm437545\'];
anm=437545;

first_date{1}='2019_01_18';
first_date{2}='2019_02_04';

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 -5 23*1.2 25*1.4]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);


for i=1:1:numel(first_date)
    key.subject_id=anm;
    fn_proj_across_days (key, first_date{i}, dir_save_figure)
end





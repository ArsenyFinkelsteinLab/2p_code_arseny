function populate_imaging_psth_cluster()
close all;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PSTHlongitudinal_cluster_intersect\AF09_anm437545\'];
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

rel_inclusion=ANLI.IncludeROImultiSession2intersect;

for i=1:1:numel(first_date)
    key.subject_id=anm;
    fn_populate_imaging_psth_cluster (key, first_date{i}, dir_save_figure, rel_inclusion)
end





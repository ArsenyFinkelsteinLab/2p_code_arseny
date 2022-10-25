
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity_stability\'];
filename = 'connectivity_stability';


rel_12_half=STIM.ROIInfluenceStability & (IMG.PhotostimGroup & STIM.ROIResponseDirectUnique) & 'response_p_value1<=0.05' & 'response_mean>0' & 'response_distance_lateral_um>=25';

response_mean_1half = fetchn(rel_12_half,'response_mean_1half');
response_mean_2half = fetchn(rel_12_half,'response_mean_2half');

rel_odd_even=STIM.ROIInfluence2 & (IMG.PhotostimGroup & STIM.ROIResponseDirectUnique) & (EXP2.SessionEpoch & STIM.ROIInfluenceStability)  & 'response_p_value1<=0.05' & 'response_mean>0' & 'response_distance_lateral_um>=25';

response_mean_odd = fetchn(rel_odd_even,'response_mean_odd');
response_mean_even = fetchn(rel_odd_even,'response_mean_even');


figure
subplot(2,2,1)
hold on
h1=histogram(response_mean_1half,linspace(-0.1,2,15),'FaceAlpha',0.6,'FaceColor',[1 0 0],'EdgeColor',[1 0 0]);
h2=histogram(response_mean_2half,linspace(-0.1,2,15),'FaceAlpha',0.25,'FaceColor',[0 0 1],'EdgeColor',[0 0 1]);
title(sprintf('Repeated (within day) measurements of \neffective connectivity for same neurons\n'))
ylabel('Neuronal pairs')
xlabel (['Connection stength' newline '(\Delta z-score activity)']);
legend({'First repeat','Second repeat'})

subplot(2,2,2)
hold on
corr(response_mean_1half,response_mean_2half)
plot(response_mean_1half,response_mean_2half,'.');
plot([0,6],[0,6],'-k')

[h,p]=ttest(response_mean_1half,response_mean_2half)
a=(response_mean_1half-response_mean_2half)./(response_mean_1half+response_mean_2half);


subplot(2,2,3)
hold on
h1=histogram(response_mean_odd,linspace(-0.1,2,50));
h2=histogram(response_mean_even,linspace(-0.1,2,50));

subplot(2,2,4)
hold on
corr(response_mean_odd,response_mean_even)
plot(response_mean_odd,response_mean_even,'.');
plot([0,6],[0,6],'-k')

[h,p]=ttest(response_mean_odd,response_mean_even)
b=(response_mean_odd-response_mean_even)./(response_mean_odd+response_mean_even);



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
eval(['print ', figure_name_out, ' -dpdf -r200']);


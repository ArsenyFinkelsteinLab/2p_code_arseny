auto_ROI_fluor(1,dat.IM,0,1,5)
figure
imagesc(dat.IM)
hold on
for i_c=1:1:numel(dat.roi)
    x=dat.roi(i_c).centroid(1);
    y=dat.roi(i_c).centroid(2);
    plot(x,y,'*m')
end
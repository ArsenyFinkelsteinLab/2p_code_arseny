M=[];
M(:,1) = rand(1,100);
M(:,2) = rand(1,100);
M(:,3) = 0.3*M(:,1) + 0.7*M(:,2) + rand(1,100)'/10;
M(:,4) = 0.7*M(:,1) + 0.3*M(:,3)+ rand(1,100)';
M(:,5) = rand(1,100);

M=M-mean(M);
[loadings,components,~, ~, explained] = pca(M);
Mreconstructed=components*loadings';

% function test()
% 
% rng(0)
% data(:,1) = randn(30,1);
% data(:,2) = 3.4 + 1.2 * data(:,1);
% data(:,2) = data(:,2) + 0.2*randn(size(data(:,1)));
% data = sortrows(data,1);
% 
% figure
% axes('LineWidth',0.6,...
%     'FontName','Helvetica',...
%     'FontSize',8,...
%     'XAxisLocation','Origin',...
%     'YAxisLocation','Origin');
% line(data(:,1),data(:,2),...
%     'LineStyle','None',...
%     'Marker','o');
% axis equal
% 
% data(:,1) = data(:,1)-mean(data(:,1));
% data(:,2) = data(:,2)-mean(data(:,2));
% 
% C = cov(data)
% [V,D] = eig(C)
% var(newdata)
% var(newdata)/sum(var(newdata))
% 
% figure
% axes('LineWidth',0.6,...
%     'FontName','Helvetica',...
%     'FontSize',8,...
%     'XAxisLocation','Origin',...
%     'YAxisLocation','Origin');
% line(data(:,1),data(:,2),...
%     'LineStyle','None',...
%     'Marker','o');
% line([0 V(1,1)],[0 V(2,1)],...
%     'Color',[0.8 0.5 0.3],...
%     'LineWidth',0.75);
% line([0 V(1,2)],[0 V(2,2)],...
%     'Color',[0.8 0.5 0.3],...
%     'LineWidth',0.75);
% axis equal
% 
% 
% newdata = V * data';
% newdata = newdata';
% newdata = fliplr(newdata)

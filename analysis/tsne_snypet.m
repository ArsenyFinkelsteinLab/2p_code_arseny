trial_types=zeros(size(b.trial,1),1);

trials(1).tr = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit'));
trials(1).lick_direction='left hit';

trials(2).tr = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit'));
trials(2).lick_direction='right hit';
% trials(3).tr = find(contains(b.trial_instruction,'left') & contains(b.outcome,'miss'));
% trials(3).lick_direction='left miss';
% trials(4).tr = find(contains(b.trial_instruction,'right') & contains(b.outcome,'miss'));
% trials(4).lick_direction='right miss';
% trials(5).tr = find(contains(b.outcome,'ignore'));
% trials(5).lick_direction='ignore';


trial_types(trials(1).tr)=1;
trial_types(trials(2).tr)=2;
% trial_types(trials(3).tr)=3;
% trial_types(trials(4).tr)=4;
% trial_types(trials(5).tr)=5;

trial_types = [trial_types;trial_types];

figure
Y = tsne(r_mat_cells,'Perplexity',10);
gscatter(Y(:,1),Y(:,2))

% Y = tsne(r_mat_trials,'Perplexity',100);
% Y = tsne(r_mat_trials,'Perplexity',30);

gscatter(Y(:,1),Y(:,2),trial_types)

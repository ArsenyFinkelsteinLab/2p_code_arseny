function [k, mu, X_firing_rate_vMises_fit, r2_von_mises_fit] ...
    = fn_compute_von_mises (X_firing_rate,X_bins_vector_of_centers)

if sum(~isnan(X_firing_rate))<1
    k=NaN;
    mu=NaN;
    X_firing_rate_vMises_fit=NaN;
    r2_von_mises_fit=NaN;
    return;
end;

%fits a Von Mises (circular normal distribution)
x = deg2rad(X_bins_vector_of_centers);
if X_bins_vector_of_centers(1)<0
    x = deg2rad(X_bins_vector_of_centers)+pi;
end

y = X_firing_rate;
x(isnan(X_firing_rate))=[];
y(isnan(X_firing_rate))=[];

y=double(y);

Starting=[max(y)  x(find(y==max(y), 1, 'first')), 0, 3.5];
% Starting=[max(y)  x(find(y==max(y), 1, 'first')), 3.5, min(y)];
options=optimset('Display','iter', 'TolX', 1e-6, 'TolFun', 1e-6, 'MaxIter', 1000, 'MaxFunEvals', 1200,'Display','off');
Est=fminsearch(@My_Von_Mises_Fit,Starting,options,x,y); %scale mean deviation basal_firing_rate

vector_1_deg=deg2rad(0:1:359);
peak_FR_fit=Est(1);
mu=Est(2); %preferred angle
mu=mod(mu,2*pi);
k=Est(3); %tuning width
% baseline=abs(Est(4)); %baseline


% The fit doesn't constrain k to be positive, so in principle this fit
% can return a negative kappa. In this case we want to use its absolute
% value and correct the resulting fit by shifting the preferred direction "mu" by pi.

if k<0
    k=abs(k);
    mu=mod(mu+pi,2*pi);
end

% X_firing_rate_vMises_fit=abs(peak_FR_fit)* exp(k.*cos(vector_1_deg-mu)) + baseline;
X_firing_rate_vMises_fit=abs(peak_FR_fit)* exp(k.*cos(vector_1_deg-mu));


%% Goodness of fit
[temp fit_x_ix]=intersect(round(rad2deg(vector_1_deg)),round(X_bins_vector_of_centers));
[r2_von_mises_fit rmse]=rsquare(X_firing_rate,X_firing_rate_vMises_fit(fit_x_ix));

mu=rad2deg(mu);
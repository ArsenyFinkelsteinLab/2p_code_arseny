function SSE=My_Von_Mises_Fit(params,Input,Actual_Output)
% see also circ_vmpdf; - for probability density function

peak_FR=params(1);
mu=params(2);
k=params(3);
% baseline=params(4);

% Fitted_Curve=abs(peak_FR)*exp(k.*cos(Input-mu) -1);
% Fitted_Curve=abs(peak_FR)*exp(k.*cos(Input-mu)) + abs(baseline);
Fitted_Curve=abs(peak_FR)*exp(k.*cos(Input-mu)) ;


% The fit doesn't constrain k to be positive, so in principle this fit
% can return a negative kappa. In this case we want to use its absolute
% value and correct the resulting fit by shifting the preferred direction "mu" by pi.
% The script below should be added to the parent function that calls to My_Von_Mises_Fit_no_baseline

%     if k<0
%         k=abs(k);
%         mu=mod(mu+pi,2*pi);
%     end

Error_Vector=Fitted_Curve - Actual_Output;
SSE=sum(Error_Vector.^2);
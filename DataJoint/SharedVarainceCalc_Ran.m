function SharedVarainceCalc_Ran (F,G)
% F N x T
% G M x T
% Cf=F*F'; Cg=G*G'; F*G' is NxM
M=size(G,1);N=size(F,1); T=size(F,1);
CrosCor=1/size(F,2).*(F*G');
CrosCorG=1/size(G,2).*(G*G');
CrosCorF=1/size(F,2).*(F*F');


% [Ufg,Sfg,Vfg]=svd(CrosCor); % S N time X M neurons; % U N X N;  V M x M
[Ufg,Sfg,Vfg]=svdecon(single(CrosCor)); % Faster?
z1=Ufg(:,1)'*F; % 1xT- first 'pc'
z2=Ufg(:,2)'*F; % 1xT- first 'pc'
z3=Ufg(:,3)'*F; % 1xT- first 'pc'

% [Ugg,Sgg,Vgg]=svd(CrosCorG); % S N time X M neurons; % U N X N;  V M x M
[Ugg,Sgg,Vgg]=svdecon(single(CrosCorG)); % Faster?

% [Uff,Sff,Vff]=svd(CrosCorF); % S N time X M neurons; % U N X N;  V M x M
[Uff,Sff,Vff]=svdecon(single(CrosCorF)); % Faster?

sv_fg =diag(Sfg);
sv_ff =diag(Sff);
sv_gg =diag(Sgg);

figure(10)
subplot(3,1,1)
loglog(sv_fg(1:M));hold all; loglog(sv_ff(1:M)); loglog(sv_gg(1:M));
legend('fg','ff','gg')
subplot(3,1,2)
loglog(sv_fg(1:M)./(sv_fg(1)));hold all; loglog(sv_ff(1:M)./sv_ff(1)); loglog(sv_gg(1:M)./sv_gg(1));

% Fraction of reliable variance:
% denum=(Ufg'*CrosCorF*Ufg+Vfg'*CrosCorG*Vfg)./(2);
pcF=diag(Uff'*CrosCorF*Uff)./T;
pcG=diag(Vgg'*CrosCorG*Vgg)./T;

denum=(pcF(1:M)+pcG)./(2);
num=sv_fg;
subplot(3,1,3)
loglog(num./denum);
hold on


% SV are computed that way:
% sfg=Ufg'*CrosCor*Vfg; 
% sff=Uff'*CrosCorF*Vff;
% sgg=Ugg'*CrosCorG*Vgg;





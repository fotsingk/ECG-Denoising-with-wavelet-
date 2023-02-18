%% débruitage des Signaux par ondelette
% 1) charger le signal
load('100m.mat')
signal = val(1,1:3600)./200; % prendre 10s, pour un signal à 360HZ

% 2) bruité le signal avec bruit gaussien à 2dB
signal_bruit = awgn(signal,20);
plot(signal_bruit)

%% 3) Débruitage par ondelette
% 3.1) parametre
wave = 'db2'; %on choisit daubechies, faites varier avec d'autres ondelettes
lvl = 3; % niveau de decomposition
 
% 3.2) decomposition
detail=cell(lvl,1);
approx = cell(lvl,1);

A = signal_bruit;
for i=1:lvl
 [A, D]= dwt(A,wave);
 approx(i) = {A};
 detail(i) = {D};
end

detail_debruit=cell(lvl,1);
for i=1:lvl
% 3.3) coefficient de detail et calcul du seuil
Det = detail{i};
thr = thselect(Det,'rigrsure'); % changer ''rigrsure', pour voir 

% 3.4) appliquer le seuil
Det_debruit = {wthresh(Det,'s',thr)}; % 's' pour soft 
detail_debruit(i,1) = Det_debruit;
end

% 3.5) reconstruire
signal_debruit= approx{lvl,1};
for i=lvl:-1:1
signal_debruit = idwt(signal_debruit(1:length(detail_debruit{i,1})), detail_debruit{i,1},wave);
end
subplot(211)
plot(signal_bruit)
title('signal bruité')
subplot(212)
plot(signal), hold on, plot(signal_debruit), hold off
legend('orig','debruit')
title('debruité')

clear all;clc;%close all;
%Choose file w/dialog
% filename = uigetfile({'*.csv','Compression Data'},...
%                       'Select Raw Compression Data',...
%                       'C:\Users\Christopher\Google Drive\MetaHealth Data');
filename = 'Accelerometer_20170224-160058346.csv';
% filename = 'Accelerometer_20170228-182720191.csv';
% filename = 'child-lean.csv';

%Extract Raw Data
Acc = importdata(filename);
t = Acc.data(:,1);
a = Acc.data(:,4);

Ts = (t(2)-t(1));
% [bh,ah] = butter(2,0.04,'high');
% plot(t,a,t,filter(bh,ah,a))
a = (a - mean(a))*9.80665;%better normalization?

aInit = find(a<min(a)/3,1);
% startIndex = 540;
startIndex = find(t == floor(t(aInit)),1);
aFinal = find(fliplr(a)>max(a)/3,1);
% endIndex = 1800;
endIndex = find(t == ceil(t(end - aFinal)),1);


%Trim Data
t = t(startIndex:endIndex);
a = a(startIndex:endIndex);


plot(t,a)

% hold on
% plot(t(1:end-1),diff(a)./diff(t),'-.r')

[pks,locs] = findpeaks(a,'MINPEAKHEIGHT',-.5);
locs = locs(pks<1.25);
pks = pks(pks<1.25);
% plot(t, a, t(locs), pks, 'or');

for i = 2:length(locs)
    if locs(i)-locs(i-1) < 15
        locs(i-1) = 0;
        pks(i-1)  = 0;
    end
end
pks = pks(locs~=0);
locs = locs(locs~=0);

%Initialize integrated values
v = zeros(length(t),1);
s = v;
s2 = s;

%Compute velocity & displacement
for i = 2:length(t)
    v(i) = v(i-1)+(a(i)+a(i-1))*Ts/2;
    s(i) = s(i-1)+(v(i)+v(i-1))*Ts/2;
end
v2 = detrend(v);
for i = 2:length(t)
    s2(i) = s2(i-1)+(v2(i)+v2(i-1))*Ts/2;
end

bpm = length(locs(2:end-1))/(t(locs(end-1))-t(locs(2)))*60;

fprintf('Interval Start: %fs\n', t(locs(2)));
fprintf('Interval End: %fs\n', t(locs(end-1)));
fprintf('Interval Duration: %fs\n\n', t(locs(end-1))-t(locs(2)));


fprintf('Avg. Compression Rate: %f bpm\n', bpm);

plot(t, a,'-k', t,10*v,'--m.',t,100*s,':b.', t(locs), pks, 'vr');
vline(t(locs),':k');
hline(0,':k');
title('Windowed Compressions','FontSize', 14)
% xlim([t(1) t(1)+3])
xlabel('Elapsed Time (s)','FontSize', 12)
ylabel('Motion Signals'   ,'FontSize', 12)
set(gca,'fontsize',12)
legend('Acceleration (m/s/s)', 'Velocity (dm/s)', 'Displacement (cm)')
%'I:\Dropbox\SuperfineBear Lab\Raw data\ARP23 tests\020620 JR20 Parental 40
%kPa\split\2 6 20 JR20 Parental 40 kPa_11_20.tif'

%Script to test various methods of analyzing periodic behaviour from cell
%SED data (to start) and correlate with other metrics. 
close all
%inputfolder = 'I:\Dropbox\SuperfineBear Lab\Raw data\ARP23 tests\020620 JR20 Parental 40 kPa\split\2 6 20 JR20 Parental 40 kPa_11_20.tif';
%inputfolder = 'I:\Dropbox\SuperfineBear Lab\Raw data\ARP23 tests\020620 JR20 Parental 40 kPa\split\2 6 20 JR20 Parental 40 kPa_20_20.tif';
inputfolder = uigetdir;
%Load data
strainNCMdatapath = strcat(inputfolder,'\compiledData.csv');
sedTFareadatapath = strcat(inputfolder,'\compiledSEDandTractiondata.csv');

strainNCMdata = csvread(strainNCMdatapath);
sedTFareadata = csvread(sedTFareadatapath);

%Fix nans in data sets 
%for now with 0's, strip rows with zeros
strainNCMdata(isnan(strainNCMdata)) = 0;
strainNCMdata = strainNCMdata(all(strainNCMdata,2),:);
sedTFareadata(isnan(sedTFareadata)) = 0;
sedTFareadata = sedTFareadata(all(sedTFareadata,2),:);
%Find cutoff where data plumets to 0 due to relax state concatentation
diffSED = diff(sedTFareadata(:,2));
[maxdiffSED, indexmax] = max(abs(diffSED));
%Going by max difference could be bad as it won't catch drops due to
%maskign problems. Last few frames could also be an issue if the cell dies
%part way through. Some combination?


%Now we can do some different analysis attempts, put everything in seconds

%for now just strip off the last 5 frames
endframe = numel(sedTFareadata(:,2)) - 5;
frames = sedTFareadata(1:endframe,1)*5*60;
%Frequency spacing of measurements, in this case every five minutes. This
%is just the number of measurements per frequency unit you want to analyze.
%For hours, there is 12 measurements at 1 measurement every five minutes.
%For seconds, there are 1/300 measurements a second.
fs = 1/(frames(2)-frames(1));
SED = sedTFareadata(1:endframe,2);
SED = smoothdata(SED);
SEDnorm = SED - mean(SED);
plot(frames/3600,SEDnorm);
xlabel('Time (hours)')
ylabel('Normalized Strain Energy Density')

%Lets see if we can match something by messing with sin wave
timevals = linspace(0,max(frames),max(frames)+1);
%sinvals = 0.015*sin((timevals*.075) - pi/2.4);
curvfit = 0.01165*sin((frames*0.0002531) - 1.426);
hold on
%plot(timevals,sinvals,'r')
plot(frames/3600,curvfit,'g')

legend('Normalized SED Data','Curve Fit Sin Wave')
hold off

% %Fourier Analysis: Does not work nearly as well as the autocorrelation
% analysis. 
% [pxx,f] = periodogram(SEDnorm,[],[],fs);
% [fpks, plocs] = findpeaks(pxx);
% %Restrict Peaks to suitable changes in fs,right now greatest 3 peaks
% 
% %Fourier Analysis of Curv fit sin wave
% [pxx2, f2] = periodogram(curvfit,[],[],fs);
% 
% 
% figure
% subplot(2,1,1)
% plot(f,pxx)
% xlabel('Frequency (Hz)')
% ylabel('Magnitude')
% legend('SED Data')
% hold on 
% subplot(2,1,2)
% plot(f2,pxx2,'r')
% legend('Curve Fitted Sin Wave')
% xlabel('Frequency (Hz)')
% ylabel('Magnitude')
% hold off

%AutoCorrelation Analysis For SED
figure
[autocor,lags] = xcorr(SEDnorm,round(frames(end)*fs),'coeff');
[apks, alocs] = findpeaks(autocor);
short = mean(diff(alocs))/fs;
plot(lags/fs,autocor)

[pklg,lclg] = findpeaks(autocor, ...
    'MinPeakDistance',ceil(short)*fs,'MinPeakheight',0.2);
long = mean(diff(lclg))/fs;
hold on
pks = plot(lags(lclg)/fs,pklg+0.05,'vk');
xlabel('Lag (Seconds)')
ylabel('Autocorrelation')
hold off


%Do some auto correlations on other data sets
%SED
SEDdata = sedTFareadata(1:endframe,2);
figure
[SEDlong, SEDshort] = autoCorrelate(frames,SEDdata);
title('Strain Energy Density Periodicity')

%TF
TFdata = sedTFareadata(1:endframe,3);
figure

[TFlong, TFshort] = autoCorrelate(frames,TFdata);
title('Traction Force Periodicity')
%Area
Areadata = sedTFareadata(1:endframe,4);
figure

[Arealong, Areashort] = autoCorrelate(frames,Areadata);
title('Area Periodicity')
%SE
SEdata = strainNCMdata(1:endframe,2);
figure

[SElong, SEshort] = autoCorrelate(frames,SEdata);
title('Strain Energy Periodicity')
%NCM
NCMdata = strainNCMdata(1:endframe,3);
figure

[NCMlong, NCMshort] = autoCorrelate(frames,NCMdata);
title('Net Contractile Moment Periodicity')
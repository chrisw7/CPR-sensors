function [RATE, DEPTH, T, A] = train(L,OUTPUT)
%train Capture IMU data and compute rate/depth of compression
%   [RATE, DEPTH] = train(L) returns the RATE of compressions
%   (bpm) and DEPTH of compression (cm) for a given sampling period, L,
%   for a Razor 9DoF IMU @ 100 Hz 
%   (NOTE: IMU gyro/magnetometer is suppressed - see README.txt in /imu/)
%
%   [RATE, DEPTH] = train(L,OUTPUT) additional output options for
%   debugging/LabVIEW demo purposes
%   - Set OUTPUT.debug to 'true' to enable detailed output including plots
%   (signal, fft, reconstructed signal) for each interval (req. colors.m).
%   - Set the value of OUTPUT.simple to 'true' to transform the output
%   into an integer between -1 and 1 indicating whether the calculated
%   rate/depth is below the recommended range (-1), above said range (1) or
%   within said range (0).
%   ---
%   Authour: Chris Williams | Last Updated: April 27, 2017
%   McMaster University 2017

%Check for 'debug' (verbose output) & 'simple' (boolean output) params
if nargin<1
    error('Too few parameters; at least two (T,A) are required.');
elseif nargin==1
    OUTPUT.debug  = false;
    OUTPUT.simple = false;
else
    if ~isfield(OUTPUT, 'debug')
        OUTPUT.debug = false;
    end
    if ~isfield(OUTPUT, 'simple')
        OUTPUT.simple = false;
    end
end

port = 'COM4';%default port

%# of samples
if L > 10
    L = 10;
elseif L<2
    L = 2;
end

Nsamples = round(L)*100;%for 100 Hz!
delay = 2;

%Capture serial data
offset = calibrate(port);
fprintf('Recording will start in %i seconds\n',delay)
pause(delay);
[T,A] =  extract(Nsamples, port, offset);

%Compute CD/CPM
[RATE, DEPTH] = process(T,A,OUTPUT);

beep
end
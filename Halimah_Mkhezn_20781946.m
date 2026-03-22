% Halimah Mkhezn
% Egyhm8@nottingham.ac.uk

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]
% Insert answers here

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]
clear all;
close all;
clc;

% Connect to Arduino
a = arduino('COM4', 'Uno');

% Temperature sensor on analog pin A0
tempPin = 'A0';

% Data acquisition duration (10 minutes = 600 seconds)
duration = 600;

% Sensor specifications (MCP9700A)
TC = 0.01;      % 10 mV/°C
V0C = 0.5;      % 500 mV at 0°C

% Create arrays
timeArray = zeros(1, duration);
temperatureArray = zeros(1, duration);

disp('Starting temperature acquisition...');

% Read temperature every 1 second
for i = 1:duration
    timeArray(i) = i;
    voltage = readVoltage(a, tempPin);
    temperatureArray(i) = (voltage - V0C) / TC;
    
    % Show progress every minute
    if mod(i, 60) == 0
        disp(['Minute ' num2str(i/60) ': ' num2str(temperatureArray(i)) ' °C']);
    end
    
    pause(1);
end

% Calculate statistics
minTemp = min(temperatureArray);
maxTemp = max(temperatureArray);
avgTemp = mean(temperatureArray);

% Plot temperature
figure;
plot(timeArray, temperatureArray, 'b-', 'LineWidth', 1.5);
xlabel('Time (seconds)');
ylabel('Temperature (°C)');
title('Capsule Temperature vs Time');
grid on;
saveas(gcf, 'temperature_plot.png');

% Display formatted output
disp(' ');
disp('================================================================');
disp('        CAPSULE TEMPERATURE REPORT');
disp('================================================================');
disp(['Date: ' datestr(now, 'dd/mm/yyyy')]);
disp('Location: Sub-orbital Spacecraft Crew Capsule');
disp('================================================================');
disp('Time Point          Temperature (°C)');
disp('----------------------------------------------------------------');

% Display data at each minute
for i = 0:10
    if i*60 + 1 <= length(temperatureArray)
        disp(['Minute ' num2str(i) sprintf('\t\t%.2f', temperatureArray(i*60 + 1))]);
    end
end

disp('----------------------------------------------------------------');
disp('Statistical Summary');
disp('----------------------------------------------------------------');
disp(['Minimum Temperature:  ' sprintf('%.2f', minTemp) ' °C']);
disp(['Maximum Temperature:  ' sprintf('%.2f', maxTemp) ' °C']);
disp(['Average Temperature:  ' sprintf('%.2f', avgTemp) ' °C']);
disp('================================================================');

% Write to file
fileID = fopen('capsule_temperature.txt', 'w');
fprintf(fileID, 'CAPSULE TEMPERATURE REPORT\n');
fprintf(fileID, 'Date: %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf(fileID, 'Location: Sub-orbital Spacecraft Crew Capsule\n\n');
fprintf(fileID, 'Time Point\tTemperature (C)\n');

for i = 0:10
    if i*60 + 1 <= length(temperatureArray)
        fprintf(fileID, 'Minute %d\t%.2f\n', i, temperatureArray(i*60 + 1));
    end
end

fprintf(fileID, '\nStatistical Summary\n');
fprintf(fileID, 'Minimum Temperature: %.2f C\n', minTemp);
fprintf(fileID, 'Maximum Temperature: %.2f C\n', maxTemp);
fprintf(fileID, 'Average Temperature: %.2f C\n', avgTemp);
fclose(fileID);

disp('Data saved to capsule_temperature.txt');

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]
clear all;
close all;
clc;

% Connect to Arduino
a = arduino('COM4', 'Uno');

% Define pins
tempPin = 'A0';      % Temperature sensor
greenLED = 'D8';    % Green LED for in-range temperature
yellowLED = 'D9';   % Yellow LED for below-range temperature
redLED = 'D10';     % Red LED for above-range temperature

disp('===================================');
disp('Task 2: LED Temperature Monitoring');
disp('===================================');
disp('Hardware Check:');
disp('- Green LED on D8');
disp('- Yellow LED on D9');
disp('- Red LED on D10');
disp('- Temperature sensor on A0');
disp(' ');
disp('Starting real-time monitoring...');
disp('Press Ctrl+C to stop');
disp(' ');

% Call monitoring function
temp_monitor(a, tempPin, greenLED, yellowLED, redLED);


%% TASK 3 - ALGORITHMS - TEMPERATURE PREDICTION [30 MARKS]
clear all;
close all;
clc;

% Connect to Arduino
a = arduino('COM4', 'Uno');

% Define pins
tempPin = 'A0';      % Temperature sensor
greenLED = 'D8';    % Green LED for stable temperature
yellowLED = 'D9';   % Yellow LED for rapid decrease
redLED = 'D10';     % Red LED for rapid increase

disp('========================================');
disp('Task 3: Temperature Prediction System');
disp('========================================');
disp('Hardware Check:');
disp('- Green LED on D8');
disp('- Yellow LED on D9');
disp('- Red LED on D10');
disp('- Temperature sensor on A0');
disp(' ');
disp('Starting temperature prediction...');
disp('Press Ctrl+C to stop');
disp(' ');

% Call prediction function
temp_prediction(a, tempPin, greenLED, yellowLED, redLED);


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]
% No need to enter any answers here, please answer on the .docx template.

%% TASK 5 - COMMENTING, VERSION CONTROL AND PROFESSIONAL PRACTICE [15 MARKS]
% No need to enter any answers here, but remember to:
% - Comment the code throughout.
% - Commit the changes to your git repository as you progress in your programming tasks.
% - Hand the Arduino project kit back to the lecturer with all parts and in working order.

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

function temp_monitor(a, tempPin, greenLED, yellowLED, redLED)
% TEMP_MONITOR Real-time temperature monitoring with LED control
%
% Monitors temperature continuously and controls three LEDs:
% - Green LED (constant): 18-24°C (comfort range)
% - Yellow LED (blink 0.5s): below 18°C (too cold)
% - Red LED (blink 0.25s): above 24°C (too hot)
%
% Usage: temp_monitor(a, tempPin, greenLED, yellowLED, redLED)

    % Sensor specs (MCP9700A)
    TC = 0.01;       % 10 mV/°C
    V0C = 0.5;       % 500 mV at 0°C
    
    % Temperature comfort range
    TEMP_MIN = 18;   % Minimum comfort temperature
    TEMP_MAX = 24;   % Maximum comfort temperature
    
    % Data storage for plotting
    timeData = [];
    tempData = [];
    startTime = tic;
    
    % Setup live plot
    figure;
    h = plot(timeData, tempData, 'b-', 'LineWidth', 1.5);
    xlabel('Time (seconds)');
    ylabel('Temperature (°C)');
    title('Real-time Temperature Monitoring');
    grid on;
    hold on;
    yline(TEMP_MIN, 'g--', '18°C Min', 'LineWidth', 1.5);
    yline(TEMP_MAX, 'r--', '24°C Max', 'LineWidth', 1.5);
    hold off;
    
    % LED blink control
    ledState = 0;
    lastBlinkTime = tic;
    
    disp('Time(s)  Temp(°C)  LED Status');
    disp('-------  --------  ----------');
    
    % Main monitoring loop (runs forever)
    while true
        % Read temperature
        elapsedTime = toc(startTime);
        voltage = readVoltage(a, tempPin);
        temperature = (voltage - V0C) / TC;
        
        % Store data for plotting
        timeData = [timeData, elapsedTime];
        tempData = [tempData, temperature];
        
        % Control LEDs based on temperature
        if temperature >= TEMP_MIN && temperature <= TEMP_MAX
            % Temperature in comfort range
            % GREEN LED: constant ON
            writeDigitalPin(a, greenLED, 1);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
            ledStatus = 'GREEN (constant)';
            
        elseif temperature < TEMP_MIN
            % Temperature below range (too cold)
            % YELLOW LED: blink every 0.5 seconds
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, redLED, 0);
            
            if toc(lastBlinkTime) >= 0.5
                ledState = ~ledState;
                writeDigitalPin(a, yellowLED, ledState);
                lastBlinkTime = tic;
            end
            
            if ledState
                ledStatus = 'YELLOW (blink ON)';
            else
                ledStatus = 'YELLOW (blink OFF)';
            end
            
        else
            % Temperature above range (too hot)
            % RED LED: blink every 0.25 seconds
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            
            if toc(lastBlinkTime) >= 0.25
                ledState = ~ledState;
                writeDigitalPin(a, redLED, ledState);
                lastBlinkTime = tic;
            end
            
            if ledState
                ledStatus = 'RED (blink ON)';
            else
                ledStatus = 'RED (blink OFF)';
            end
        end
        
        % Update live plot
        set(h, 'XData', timeData, 'YData', tempData);
        xlim([max(0, elapsedTime-60), elapsedTime+5]);
        
        if ~isempty(tempData)
            ylim([min(tempData)-2, max(tempData)+2]);
        end
        
        drawnow;
        
        % Display status every 5 seconds
        if mod(length(timeData), 5) == 0
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '     ' ledStatus]);
        end
        
        pause(1);
    end
end

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

function temp_prediction(a, tempPin, greenLED, yellowLED, redLED)
% TEMP_PREDICTION Temperature prediction and rate monitoring
%
% Calculates temperature change rate and predicts future temperature.
% Controls LEDs based on rate of change:
% - Green LED (constant): stable temperature (|rate| <= 4°C/min)
% - Red LED (constant): rapid increase (rate > +4°C/min)
% - Yellow LED (constant): rapid decrease (rate < -4°C/min)
%
% Usage: temp_prediction(a, tempPin, greenLED, yellowLED, redLED)

    % Sensor specs (MCP9700A)
    TC = 0.01;       % 10 mV/°C
    V0C = 0.5;       % 500 mV at 0°C
    
    % Rate of change threshold
    CRITICAL_RATE = 4.0 / 60;  % 4°C/min converted to °C/s
    
    % Data storage
    tempHistory = [];
    timeHistory = [];
    startTime = tic;
    
    disp('Time(s)  Temp(°C)  Rate(°C/s)  Rate(°C/min)  Predict(°C)  LED Status');
    disp('-------  --------  ----------  ------------  -----------  ----------');
    
    % Main monitoring loop (runs forever)
    while true
        % Read temperature
        elapsedTime = toc(startTime);
        voltage = readVoltage(a, tempPin);
        temperature = (voltage - V0C) / TC;
        
        % Store data
        tempHistory = [tempHistory, temperature];
        timeHistory = [timeHistory, elapsedTime];
        
        % Calculate rate of change after collecting enough data
        if length(tempHistory) >= 10
            % Smooth data with moving average to reduce noise
            smoothTemp = movmean(tempHistory, 10);
            
            % Calculate rate of change (derivative)
            timeDiff = timeHistory(end) - timeHistory(end-1);
            tempDiff = smoothTemp(end) - smoothTemp(end-1);
            rateOfChange = tempDiff / timeDiff;  % °C/s
            ratePerMinute = rateOfChange * 60;   % °C/min
            
            % Predict temperature in 5 minutes (300 seconds)
            predictedTemp = temperature + (rateOfChange * 300);
            
            % Control LEDs based on rate of change
            if rateOfChange > CRITICAL_RATE
                % Rapid temperature INCREASE
                % RED LED: constant ON
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 1);
                ledStatus = 'RED (increase)';
                
            elseif rateOfChange < -CRITICAL_RATE
                % Rapid temperature DECREASE
                % YELLOW LED: constant ON
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 1);
                writeDigitalPin(a, redLED, 0);
                ledStatus = 'YELLOW (decrease)';
                
            else
                % Temperature STABLE
                % GREEN LED: constant ON
                writeDigitalPin(a, greenLED, 1);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 0);
                ledStatus = 'GREEN (stable)';
            end
            
            % Display results
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '      ' ...
                  num2str(rateOfChange, '%.4f') '       ' ...
                  num2str(ratePerMinute, '%.2f') '          ' ...
                  num2str(predictedTemp, '%.2f') '       ' ...
                  ledStatus]);
        else
            % Not enough data yet - turn off all LEDs
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
            
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '      Collecting data...']);
        end
        
        % Limit history size (keep last 600 samples = 10 minutes)
        if length(tempHistory) > 600
            tempHistory = tempHistory(end-599:end);
            timeHistory = timeHistory(end-599:end);
        end
        
        pause(1);
    end
end

%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]
% No need to enter any answers here, please answer on the .docx template.

%% TASK 5 - COMMENTING, VERSION CONTROL AND PROFESSIONAL PRACTICE [15 MARKS]
% No need to enter any answers here, but remember to:
% - Comment the code throughout.
% - Commit the changes to your git repository as you progress in your programming tasks.
% - Hand the Arduino project kit back to the lecturer with all parts and in working order.
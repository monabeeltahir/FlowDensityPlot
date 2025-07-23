% FuncName - DensityPlotter: A GUI to generate the the scatter density
% plots add gates, and plot the histograms by using the fluorescence flow
% cytometer data .fcs files
% With average feature.
%
% Author: Muhammad Nabeel Tahir
% Date: Nov 14, 2023
% Copyright (c) 2023, Muhammad Nabeel Tahir.

function DensityPlotterv3()
   % Create a UIFigure
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Define the size of the UIFigure
    figWidth = screenWidth * 0.8; % 80% of the screen width
    figHeight = screenHeight * 0.8; % 80% of the screen height
    figX = screenWidth * 0.1; % Centered horizontally
    figY = screenHeight * 0.1; % Centered vertically

    % Create a UIFigure
    fig = uifigure('Name', 'Density Plotter', 'Position', [figX, figY, figWidth, figHeight]);
    % Define the positions of the axes and buttons
    axesWidth = figWidth * 0.2;
    axesHeight = figHeight * 0.4;
    buttonWidth = 150;
    buttonHeight = 30;
    spacing = 10; % Spacing between elements
    % Define initial variables
    data = []; % Variable to store the data from the .fcs file
    columnNames = {}; % Variable to store column names from the .fcs file
    shapes = {}; % Cell array to store shape handles
    currentShapeType = 'Rectangle'; % Default shape type
    scaleType = 'Linear'; % Default scale type for axes
    xposbuts = 550;
    % Add axes to the figure
   % Adjust the positions of axes and add two more axes
    ax = uiaxes('Parent', fig, 'Position', [spacing, figHeight - axesHeight - spacing, axesWidth, axesHeight]); % First plot
    ax2 = uiaxes('Parent', fig, 'Position', [2 * spacing + axesWidth, figHeight - axesHeight - spacing, axesWidth, axesHeight]);  % Second plot
    ax3 = uiaxes('Parent', fig, 'Position', [spacing , figHeight - 2*axesHeight - spacing, axesWidth, axesHeight]); % Third plot
    ax4 = uiaxes('Parent', fig, 'Position', [2 * spacing + axesWidth, figHeight - 2*axesHeight - spacing, axesWidth, axesHeight]);  % Fourth plot
    axesHandles = [ax2, ax3, ax4];
  
 

    % Add UI controls
    % File selection button
    % Position the buttons and other controls
    controlX = 3 * spacing + 2 * axesWidth;
    fileBtn = uibutton(fig, 'push', 'Text', 'Load FCS File', 'Position', [controlX, figHeight - spacing - buttonHeight, buttonWidth, buttonHeight],...
                       'ButtonPushedFcn', @loadFcsFile);
    % Labels for selecting columns
    xLabel = uilabel(fig, 'Text', 'X-axis:', 'Position', [controlX, figHeight - spacing - 2*buttonHeight, buttonWidth, buttonHeight]);
    

    % Dropdowns for selecting columns
    xDropdown = uidropdown(fig, 'Position', [controlX, figHeight - spacing - 3*buttonHeight, buttonWidth, buttonHeight], 'Items', {'Select X-axis'});
    yLabel = uilabel(fig, 'Text', 'Y-axis:', 'Position', [controlX, figHeight - spacing - 4*buttonHeight, buttonWidth, buttonHeight]);
    yDropdown = uidropdown(fig, 'Position', [controlX, figHeight - spacing - 5*buttonHeight, buttonWidth, buttonHeight], 'Items', {'Select Y-axis'});

    % Button for updating the plot
    updatePlotBtn = uibutton(fig, 'push', 'Text', 'Update Plot', 'Position', [controlX, figHeight - 2*spacing - 6*buttonHeight, buttonWidth, buttonHeight],...
                             'ButtonPushedFcn', @updatePlot);

     
    % Scale text
     scaletext = uilabel(fig, 'Text', 'Scale:', 'Position', [controlX, figHeight - 2*spacing - 7*buttonHeight, buttonWidth, buttonHeight]);
    % Dropdown for scale selection
     scaleDropdown = uidropdown(fig, 'Position', [controlX, figHeight - spacing - 8*buttonHeight, buttonWidth, buttonHeight], 'Items', {'Linear', 'Log'},...
                               'ValueChangedFcn', @(dd, event) setScaleType(dd.Value));
    % Polygon Selector text
     polygontext = uilabel(fig, 'Text', 'Select Polygon:', 'Position', [controlX, figHeight - spacing - 9*buttonHeight, buttonWidth, buttonHeight]);
    % Dropdown for shape selection
    shapeDropdown = uidropdown(fig, 'Position', [controlX, figHeight - spacing - 10*buttonHeight, buttonWidth, buttonHeight], 'Items', {'Rectangle', 'Polygon', 'Circle'},...
                               'ValueChangedFcn', @(dd, event) setCurrentShapeType(dd.Value));

    % Button for drawing shapes
    drawShapeBtn = uibutton(fig, 'push', 'Text', 'Draw Shape', 'Position', [controlX+buttonWidth+spacing, figHeight - spacing - buttonHeight, buttonWidth, buttonHeight],...
                            'ButtonPushedFcn', @drawShape);

    % Button for extracting and plotting data from shapes
    extractDataBtn = uibutton(fig, 'push', 'Text', 'Extract Data', 'Position', [controlX+buttonWidth+spacing, figHeight - spacing - 3*buttonHeight, buttonWidth, buttonHeight],...
                              'ButtonPushedFcn', @extractData);
    
    % Button to clear data and shapes
    clearDataBtn = uibutton(fig, 'push', 'Text', 'Clear Data', 'Position', [controlX+buttonWidth+spacing, figHeight - spacing - 5*buttonHeight, buttonWidth, buttonHeight],...
                            'ButtonPushedFcn', @clearData);
    vartypetext = uilabel(fig, 'Text', 'Select Variable Type:', 'Position', [controlX+buttonWidth+spacing, figHeight - spacing - 6*buttonHeight, buttonWidth, buttonHeight]);
    
    vartypeDropdown = uidropdown(fig, 'Position', [controlX+buttonWidth+spacing, figHeight - spacing - 7*buttonHeight, buttonWidth, buttonHeight], 'Items', {'Linear', 'Average', 'Normalized'},...
                               'ValueChangedFcn', @(dd, event) setCurrentShapeType(dd.Value));
    
    %disp(figHeight - spacing - 13*buttonHeight);
    % Label to show the loaded file name
    fileNameLabel = uilabel(fig, 'Position', [controlX figHeight - spacing - 14*buttonHeight, buttonWidth, buttonHeight], 'Text', '');

    % Function to set the current shape type
    function setCurrentShapeType(shapeType)
        currentShapeType = shapeType;
    end

    % Function to set the scale type
    function setScaleType(type)
        scaleType = type;
        updatePlot(); % Update plot with new scale
    end
      % Set labels for axes
    setAxisLabels(ax);
    setAxisLabels(ax2);
    setAxisLabels(ax3);
    setAxisLabels(ax4);

     % Function to set axis labels
    function setAxisLabels(ax)
        xlabel(ax, xDropdown.Value);
        ylabel(ax, yDropdown.Value);
    end
    % Function to draw a shape based on selection
    function drawShape(~, ~)
        switch currentShapeType
            case 'Rectangle'
                shape = drawrectangle(ax, 'Color', rand(1,3));
            case 'Polygon'
                shape = drawpolygon(ax, 'Color', rand(1,3));
            case 'Circle'
                shape = drawcircle(ax, 'Color', rand(1,3));
        end
        shapes{end+1} = shape;
    end

    % Function to load and read .fcs file
    function loadFcsFile(~, ~)
        [file, path] = uigetfile('*.fcs');
        if isequal(file, 0)
            return;
        end
        fullFilePath = fullfile(path, file);

        % Read the .fcs file
        [fcsdat, fcshdr] = fca_readfcs(fullFilePath);

        % Extract data and column names
        data = fcsdat;
        columnNames = {fcshdr.par.name};
        columnNames = string(columnNames);

        % Update dropdown items
        xDropdown.Items = columnNames;
        yDropdown.Items = columnNames;

        % Update file name label
        fileNameLabel.Text = ['Loaded File: ', file];
    end

    % Function to clear data and shapes
    function clearData(~, ~)
        data = [];
        columnNames = {};

        xDropdown.Items = {'Select X-axis'};
        yDropdown.Items = {'Select Y-axis'};

        for i = 1:length(shapes)
            if isvalid(shapes{i})
                delete(shapes{i});
            end
        end
        shapes = {};
        cla(ax);
        cla(ax2);
        cla(ax3);
        cla(ax4);
        fileNameLabel.Text = '';
    end

    % Function to attempt to update the plot
    function attemptUpdatePlot()
        if ~isempty(data) && ~strcmp(xDropdown.Value, 'Select X-axis') && ~strcmp(yDropdown.Value, 'Select Y-axis')
            updatePlot();
        end
    end

 % Function to update the plot based on selected columns
    function updatePlot(~, ~)
        if ~isempty(data) && ~strcmp(xDropdown.Value, 'Select X-axis') && ~strcmp(yDropdown.Value, 'Select Y-axis')
            if vartypeDropdown.Value=="Linear"
                xColumn = find(columnNames == xDropdown.Value);
                yColumn = find(columnNames == yDropdown.Value);
                  % Extracting the data for the selected columns
                xData = data(:, xColumn);
                yData = data(:, yColumn);
    
                % Ensure xData and yData are vectors
                %xData = xData(:);
                %yData = yData(:);
                plotScatterHeat(ax, xData, yData);
                updateAxesScale(ax); % Update axes scale
            elseif vartypeDropdown.Value=="Average"
                xColumn = [];
                yColumn = [];
                xColumn = [xColumn; find(columnNames == xDropdown.Value)];
                yColumn = [yColumn; find(columnNames == yDropdown.Value)];
                vartypes = ["W"; "H"];
                for i=1:2
                    xstrchanged = xDropdown.Value;

                    xstrchanged(end) = vartypes(i);
                    ystrchanged = yDropdown.Value;

                    ystrchanged(end) = vartypes(i);
                    xColumn = [xColumn; find(columnNames == xstrchanged)];
                    yColumn = [yColumn; find(columnNames == ystrchanged)];
             
                end
         
                  % Extracting the data for the selected columns
                xData = data(:, xColumn);
                yData = data(:, yColumn);
    
                % Ensure xData and yData are vectors
                %xData = xData(:);
                %yData = yData(:);
                plotScatterHeat(ax2, mean(xData, 2), mean(yData,2));
                updateAxesScale(ax2); % Update axes scale
                x1limits = xlim(ax);
                y1limits = ylim(ax);
                xlim(ax2, x1limits);
                ylim(ax2, y1limits);
            elseif vartypeDropdown.Value=="Normalized"
                     xColumn = [];
                yColumn = [];
                xColumn = [xColumn; find(columnNames == xDropdown.Value)];
                yColumn = [yColumn; find(columnNames == yDropdown.Value)];
                vartypes = ["W"; "H"];
                for i=1:2
                    xstrchanged = xDropdown.Value;

                    xstrchanged(end) = vartypes(i);
                    ystrchanged = yDropdown.Value;

                    ystrchanged(end) = vartypes(i);
                    xColumn = [xColumn; find(columnNames == xstrchanged)];
                    yColumn = [yColumn; find(columnNames == ystrchanged)];
             
                end
         
                  % Extracting the data for the selected columns
                xData = data(:, xColumn);
                yData = data(:, yColumn);
                xData = normalize(xData, "range");
                yData = normalize(yData,"range");
                % Ensure xData and yData are vectors
                %xData = xData(:);
                %yData = yData(:);
                plotScatterHeat(ax3, mean(xData, 2), mean(yData,2));
                updateAxesScale(ax3); % Update axes scale
            end
        else
            uialert(fig, 'Please select both X-axis and Y-axis columns.', 'Column Selection');
        end
    end


    % Function to plot scatter heat with optimized density calculation
    function plotScatterHeat(ax, x, y)
        % Downsampling data for density calculation
        downsampleFactor = 35; % Adjust this factor as needed
        
        idx = randperm(length(x), min(length(x), round(length(x)/downsampleFactor)));
      
        xSample = x(idx);
        ySample = y(idx);
        tic
        % Calculate density on the downsampled data
        [density, ~] = ksdensity([xSample, ySample], [x, y]);
        toc
        % Plot the scatter plot with density as color
        scatter(ax, x, y, 6, density, 'filled');
        title(ax, ['Count of Cells: ' num2str(length(x))])
        setAxisLabels(ax);
        colormap(ax, 'jet');
        colorbar(ax);
    end


    % % Function to plot scatter heat
    % function plotScatterHeat(ax, x, y)
    %     [density, ~] = ksdensity([x, y], [x, y]);
    %     scatter(ax, x, y, 6, density, 'filled');
    %     xlabel(ax, xDropdown.Value);
    %     ylabel(ax, yDropdown.Value);
    %     colormap(ax, 'jet');
    %     colorbar(ax);
    % end

    % Function to update axes scale based on selected scale type
    function updateAxesScale(ax)
        switch scaleType
            case 'Linear'
                ax.XScale = 'linear';
                ax.YScale = 'linear';
            case 'Log'
                ax.XScale = 'log';
                ax.YScale = 'log';
        end
    end

    % Function to extract and plot data from shapes
    function extractData(~, ~)
        xColumn = find(columnNames == xDropdown.Value);
        yColumn = find(columnNames == yDropdown.Value);
        for i = 1:length(shapes)
            shape = shapes{i};
            if ~isempty(shape) && isvalid(shape)
                % Determine the shape type and extract data accordingly
                switch class(shape)
                    case 'images.roi.Rectangle'
                        pos = shape.Position;
                        inside = data(:, xColumn) >= pos(1) & data(:, xColumn) <= (pos(1) + pos(3)) & ...
                                 data(:, yColumn) >= pos(2) & data(:, yColumn) <= (pos(2) + pos(4));
                    case 'images.roi.Polygon'
                        inside = inpolygon(data(:, xColumn), data(:, yColumn), shape.Position(:,1), shape.Position(:,2));
                    case 'images.roi.Circle'
                        centerX = shape.Center(1);
                        centerY = shape.Center(2);
                        radius = shape.Radius;
                        inside = (data(:, xColumn) - centerX).^2 + (data(:, yColumn) - centerY).^2 <= radius^2;
                end

                % Plot extracted data
              
                %f = figure('Name', ['Data in Gate ' num2str(i)], 'NumberTitle', 'off');
                %axNew = axes(f);
                %scatter(axNew, data(inside, xColumn), data(inside, yColumn),6, 'filled');
                histogram(axesHandles(i), data(inside,xColumn), 1024, 'Normalization', 'probability')
                xlabel(axesHandles(i), xDropdown.Value);
                title(axesHandles(i), ['Count of Cells: ' num2str(length(data(inside,xColumn)))])
                %ylabel(axNew, yDropdown.Value);
                %updateAxesScale(axNew); % Apply scale to new plot
            end
        end
    end

end


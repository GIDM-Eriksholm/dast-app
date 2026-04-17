function plotData = processPupilData(plotData, Param)
% processPupilData
% Performs: CLEANING → REPAIR → LOW-PASS → BASELINE REMOVAL → TIME VECTORS

    N = plotData.Ntrials;

    %% -------------------------------------------------------
    % CLEAN DATA
    % --------------------------------------------------------
    plotData.Cleaned_Diameter_L = nan(size(plotData.LeftEye));
    plotData.Cleaned_Diameter_R = nan(size(plotData.RightEye));
    plotData.Metadata_Cleaning_L = cell(N,1);
    plotData.Metadata_Cleaning_R = cell(N,1);

    for i = 1:N
        % LEFT
        [cleanL, metaL] = setnan(plotData.LeftEye(i,:), Param);
        plotData.Cleaned_Diameter_L(i,:) = cleanL.';
        plotData.Metadata_Cleaning_L{i} = metaL;

        % RIGHT
        [cleanR, metaR] = setnan(plotData.RightEye(i,:).', Param);
        plotData.Cleaned_Diameter_R(i,:) = cleanR.';
        plotData.Metadata_Cleaning_R{i} = metaR;
    end


    %% -------------------------------------------------------
    % REPAIR DATA (preprocpupil)
    % --------------------------------------------------------
    plotData.Repaired_Diameter_L = nan(size(plotData.LeftEye));
    plotData.Repaired_Diameter_R = nan(size(plotData.RightEye));
    plotData.Metadata_L = cell(N,1);
    plotData.Metadata_R = cell(N,1);

    for i = 1:N
        % LEFT
        [repL, metaL] = preprocpupil(plotData.Cleaned_Diameter_L(i,:), Param);
        plotData.Repaired_Diameter_L(i,:) = repL.';
        plotData.Metadata_L{i} = metaL;

        % RIGHT
        [repR, metaR] = preprocpupil(plotData.Cleaned_Diameter_R(i,:).', Param);
        plotData.Repaired_Diameter_R(i,:) = repR.';
        plotData.Metadata_R{i} = metaR;
    end


    %% -------------------------------------------------------
    % LOW-PASS FILTER
    % --------------------------------------------------------
    plotData.LP_Diameter_L = nan(size(plotData.Repaired_Diameter_L));
    plotData.LP_Diameter_R = nan(size(plotData.Repaired_Diameter_R));

    for i = 1:N
        vecL = plotData.Repaired_Diameter_L(i,:).';
        if ~all(isnan(vecL))
            plotData.LP_Diameter_L(i,:) = padfilter(vecL, plotData.LPWindow).';
        end

        vecR = plotData.Repaired_Diameter_R(i,:).';
        if ~all(isnan(vecR))
            plotData.LP_Diameter_R(i,:) = padfilter(vecR, plotData.LPWindow).';
        end
    end


    %% -------------------------------------------------------
    % BASELINE REMOVAL
    % --------------------------------------------------------
    for i = 1:N
        plotData.LP_Diameter_L_B(i,:) = plotData.LP_Diameter_L(i,:) - mean(plotData.LP_Diameter_L(i,Param.BaselineWindow(1):Param.BaselineWindow(2)));
        plotData.LP_Diameter_R_B(i,:) = plotData.LP_Diameter_R(i,:) - mean(plotData.LP_Diameter_R(i,Param.BaselineWindow(1):Param.BaselineWindow(2)));;
    end

    %% -------------------------------------------------------
    % TIME VECTORS
    % --------------------------------------------------------
    T = size(plotData.LeftEye,2);
    plotData.t = (0:T-1) ./ Param.Fs - Param.DurationSilence - app.Param.DurationNoise;
    plotData.t_B = plotData.t(BL:Param.EndSample);

end

function A32_Convolution_Correlation_GUI
% A32: Convolution vs Correlation Comparator with Matched Filter Detector
% Save this file as A32_Convolution_Correlation_GUI.m and run:
% A32_Convolution_Correlation_GUI

clc; close all;
fig = figure('Name','A32 - Convolution vs Correlation Comparator', ...
    'NumberTitle','off','Position',[80 50 1250 780], ...
    'Color',[0.94 0.96 0.98]);
tabs = uitabgroup(fig,'Position',[0.015 0.02 0.97 0.96]);
tab1 = uitab(tabs,'Title','Convolution vs Correlation');
tab2 = uitab(tabs,'Title','Matched Filter Detector');
tab3 = uitab(tabs,'Title','SNR Comparison');

%% TAB 1: Convolution and correlation
uicontrol(tab1,'Style','text','String','CONVOLUTION VS CROSS-CORRELATION', ...
    'FontSize',16,'FontWeight','bold','Units','normalized', ...
    'Position',[0.20 0.92 0.60 0.05]);
uicontrol(tab1,'Style','text','String','Input signal x[n]:', ...
    'Units','normalized','Position',[0.05 0.84 0.15 0.04], ...
    'HorizontalAlignment','left','FontSize',11);
xInput = uicontrol(tab1,'Style','edit','String','1 2 3 4', ...
    'Units','normalized','Position',[0.20 0.84 0.20 0.05],'FontSize',11);
uicontrol(tab1,'Style','text','String','Impulse response h[n]:', ...
    'Units','normalized','Position',[0.45 0.84 0.18 0.04], ...
    'HorizontalAlignment','left','FontSize',11);
hInput = uicontrol(tab1,'Style','edit','String','1 -1 2', ...
    'Units','normalized','Position',[0.63 0.84 0.20 0.05],'FontSize',11);
uicontrol(tab1,'Style','pushbutton','String','Calculate and Plot', ...
    'Units','normalized','Position',[0.38 0.76 0.24 0.055], ...
    'FontSize',11,'FontWeight','bold','Callback',@plotConvCorr);
axConv = axes('Parent',tab1,'Position',[0.08 0.43 0.38 0.27]);
axCorr = axes('Parent',tab1,'Position',[0.55 0.43 0.38 0.27]);
resultText = uicontrol(tab1,'Style','text','String','Results will appear here.', ...
    'Units','normalized','Position',[0.05 0.05 0.90 0.30], ...
    'HorizontalAlignment','left','FontSize',11,'BackgroundColor',[1 1 1]);
plotConvCorr([],[]);

%% TAB 2: Matched filter detector
uicontrol(tab2,'Style','text','String','MATCHED FILTER DETECTOR', ...
    'FontSize',16,'FontWeight','bold','Units','normalized', ...
    'Position',[0.20 0.92 0.60 0.05]);
uicontrol(tab2,'Style','text','String','Input SNR (dB):', ...
    'Units','normalized','Position',[0.12 0.84 0.16 0.04],'FontSize',11);
snrInput = uicontrol(tab2,'Style','edit','String','0', ...
    'Units','normalized','Position',[0.29 0.84 0.12 0.05],'FontSize',11);
uicontrol(tab2,'Style','pushbutton','String','Run Matched Filter', ...
    'Units','normalized','Position',[0.47 0.84 0.25 0.055], ...
    'FontSize',11,'FontWeight','bold','Callback',@runMatchedFilter);
axReceived = axes('Parent',tab2,'Position',[0.08 0.55 0.38 0.23]);
axFiltered = axes('Parent',tab2,'Position',[0.55 0.55 0.38 0.23]);
axNoise = axes('Parent',tab2,'Position',[0.30 0.25 0.40 0.20]);
matchedText = uicontrol(tab2,'Style','text', ...
    'String',sprintf('Matched filter: h[n] = s[-n]\nSignal: [1 -1 1 -1]'), ...
    'Units','normalized','Position',[0.05 0.02 0.90 0.18], ...
    'HorizontalAlignment','left','FontSize',11,'BackgroundColor',[1 1 1]);

%% TAB 3: SNR comparison
uicontrol(tab3,'Style','text','String','MATCHED FILTER VS THRESHOLD DETECTOR', ...
    'FontSize',16,'FontWeight','bold','Units','normalized', ...
    'Position',[0.15 0.92 0.70 0.05]);
uicontrol(tab3,'Style','pushbutton','String','Run SNR Comparison', ...
    'Units','normalized','Position',[0.37 0.84 0.26 0.06], ...
    'FontSize',12,'FontWeight','bold','Callback',@compareSNR);
axSNR = axes('Parent',tab3,'Position',[0.12 0.35 0.78 0.42]);
snrText = uicontrol(tab3,'Style','text', ...
    'String','Compare matched-filter SNR with threshold-detector performance.', ...
    'Units','normalized','Position',[0.05 0.05 0.90 0.23], ...
    'HorizontalAlignment','left','FontSize',11,'BackgroundColor',[1 1 1]);

%% Callback: convolution and correlation
    function plotConvCorr(~,~)
        x = str2num(get(xInput,'String')); %#ok<ST2NM>
        h = str2num(get(hInput,'String')); %#ok<ST2NM>
        if isempty(x) || isempty(h) || ~isvector(x) || ~isvector(h) || ...
                ~isreal(x) || ~isreal(h) || any(~isfinite(x)) || any(~isfinite(h))
            errordlg('Enter valid real-valued sequences.','Input Error'); return;
        end
        x = x(:).'; h = h(:).';
        yConv = conv(x,h);
        yCorr = conv(x,fliplr(h));
        nConv = 0:length(yConv)-1;
        nCorr = -(length(h)-1):(length(x)-1);
        cla(axConv); stem(axConv,nConv,yConv,'filled','LineWidth',1.4);
        grid(axConv,'on'); title(axConv,'Linear Convolution'); xlabel(axConv,'n');
        ylabel(axConv,'y[n] = x[n] * h[n]');
        cla(axCorr); stem(axCorr,nCorr,yCorr,'filled','LineWidth',1.4);
        grid(axCorr,'on'); title(axCorr,'Cross-Correlation'); xlabel(axCorr,'Lag n');
        ylabel(axCorr,'R_{xh}[n]');
        txt = sprintf(['INPUT x[n] = %s\nIMPULSE RESPONSE h[n] = %s\n\n' ...
            'CONVOLUTION: %s\n\nCorrelation lags: %s\n' ...
            'CROSS-CORRELATION: %s\n\n' ...
            'For real sequences, R_xh[n] = conv(x, fliplr(h)).'], ...
            mat2str(x),mat2str(h),mat2str(yConv),mat2str(nCorr),mat2str(yCorr));
        set(resultText,'String',txt);
    end

%% Callback: matched filter
    function runMatchedFilter(~,~)
        inputSNRdB = str2double(get(snrInput,'String'));
        if ~isscalar(inputSNRdB) || ~isfinite(inputSNRdB)
            errordlg('Enter a valid input SNR in dB.','Input Error'); return;
        end
        s = [1 -1 1 -1];
        hMF = fliplr(s); % h[n] = s[-n] for this real-valued signal
        signalPower = mean(s.^2);
        noiseVariance = signalPower/10^(inputSNRdB/10);
        noise = sqrt(noiseVariance)*randn(size(s));
        received = s + noise;
        yMF = conv(received,hMF);
        yIdeal = conv(s,hMF);
        [peakValue,peakIndex] = max(yIdeal);
        outputNoiseVariance = noiseVariance*sum(hMF.^2);
        outputSNRdB = 10*log10(peakValue^2/outputNoiseVariance);
        detected = ones(size(received)); detected(received < 0) = -1;
        errors = sum(detected ~= s); ber = errors/length(s);
        cla(axReceived); stem(axReceived,0:length(s)-1,received,'filled','LineWidth',1.4);
        hold(axReceived,'on'); plot(axReceived,0:length(s)-1,s,'--','LineWidth',1.5);
        yline(axReceived,0,'k:'); hold(axReceived,'off'); grid(axReceived,'on');
        title(axReceived,'Signal Buried in Noise'); xlabel(axReceived,'n'); ylabel(axReceived,'Amplitude');
        legend(axReceived,'Received signal','Original signal','Location','best');
        cla(axFiltered); stem(axFiltered,0:length(yMF)-1,yMF,'filled','LineWidth',1.4);
        hold(axFiltered,'on'); plot(axFiltered,0:length(yIdeal)-1,yIdeal,'--','LineWidth',1.5);
        plot(axFiltered,peakIndex-1,yMF(peakIndex),'ro','MarkerSize',9,'LineWidth',2);
        hold(axFiltered,'off'); grid(axFiltered,'on'); title(axFiltered,'Matched Filter Output');
        xlabel(axFiltered,'n'); ylabel(axFiltered,'y[n]');
        legend(axFiltered,'Noisy output','Noise-free output','Expected peak','Location','best');
        cla(axNoise); stem(axNoise,0:length(s)-1,detected,'filled','LineWidth',1.5);
        hold(axNoise,'on'); plot(axNoise,0:length(s)-1,s,'--','LineWidth',1.5);
        hold(axNoise,'off'); grid(axNoise,'on'); title(axNoise,'Threshold Detector Decisions');
        xlabel(axNoise,'n'); ylabel(axNoise,'Decision');
        legend(axNoise,'Detected','Original','Location','best');
        if ber > 0
            threshTxt = sprintf('Threshold detector BER = %.3f',ber);
        else
            threshTxt = 'No threshold errors observed in four samples; more trials are needed for a reliable BER estimate.';
        end
        txt = sprintf(['Signal s[n] = %s\nMatched filter h[n] = %s\nReceived r[n] = %s\n\n' ...
            'Input SNR = %.2f dB\nTheoretical matched-filter output SNR = %.2f dB\n' ...
            'Noise-free output peak = %.2f\nThreshold decisions = %s\n' ...
            'Threshold errors = %d out of %d\n%s'], ...
            mat2str(s),mat2str(hMF),mat2str(received),inputSNRdB,outputSNRdB, ...
            peakValue,mat2str(detected),errors,length(s),threshTxt);
        set(matchedText,'String',txt);
    end

%% Callback: SNR sweep
    function compareSNR(~,~)
        snrDB = -10:2:12; s = [1 -1 1 -1];
        signalPower = mean(s.^2); signalEnergy = sum(s.^2); numTrials = 20000;
        matchedSNRdB = zeros(size(snrDB)); thresholdSNRdB = zeros(size(snrDB));
        BERvalues = zeros(size(snrDB)); rng(12345);
        for k = 1:length(snrDB)
            noiseVariance = signalPower/10^(snrDB(k)/10);
            noiseStd = sqrt(noiseVariance);
            matchedSNRdB(k) = 10*log10(signalEnergy/noiseVariance);
            signalMatrix = repmat(s,numTrials,1);
            receivedMatrix = signalMatrix + noiseStd*randn(numTrials,length(s));
            detectedMatrix = ones(size(receivedMatrix));
            detectedMatrix(receivedMatrix < 0) = -1;
            BERvalues(k) = sum(sum(detectedMatrix ~= signalMatrix))/(numTrials*length(s));
            if BERvalues(k) > 0
                thresholdSNRdB(k) = 10*log10(1/(4*BERvalues(k)));
            else
                thresholdSNRdB(k) = NaN;
            end
        end
        cla(axSNR); plot(axSNR,snrDB,matchedSNRdB,'-o','LineWidth',2,'MarkerSize',6);
        hold(axSNR,'on'); plot(axSNR,snrDB,thresholdSNRdB,'-s','LineWidth',2,'MarkerSize',6);
        hold(axSNR,'off'); grid(axSNR,'on'); xlabel(axSNR,'Input SNR (dB)');
        ylabel(axSNR,'Output / Effective Decision SNR (dB)');
        title(axSNR,'Matched Filter vs Threshold Detector');
        legend(axSNR,'Matched filter (theoretical)','Threshold detector (Monte Carlo)', ...
            'Location','northwest');
        txt = sprintf('SNR sweep completed using %d trials at each input SNR.\n\n',numTrials);
        txt = [txt sprintf('Input SNR | Matched filter SNR | Threshold effective SNR | BER\n')];
        for k = 1:length(snrDB)
            txt = [txt sprintf('%7.1f dB | %8.2f dB | %8.2f dB | %.6f\n', ...
                snrDB(k),matchedSNRdB(k),thresholdSNRdB(k),BERvalues(k))]; %#ok<AGROW>
        end
        txt = [txt sprintf('\nNote: the matched-filter value is theoretical; threshold values are BER-based estimates. These are different metrics.')];
        set(snrText,'String',txt);
    end
end

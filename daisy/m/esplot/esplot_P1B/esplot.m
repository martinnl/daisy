function [varargout]=esplot(varargin)
% fh=esplot(commands)
%
% Commands:
%   'figure', figurenumber, file-prefix
%       The format and plot action command, given the figurenumber of
%       orginal figure and file-prefix.
%       
%   'style', styles
%       Defines the styles to be used. Argument styles is ether a string or
%       a list of strings of styles.
%
%   'path', output-path
%       Sets up the default output path of prints.
%
%   'print', formats
%       String or list of string of output formats. 
%       Available formats are:
%           'eps'       Encapsulated EPS level2 with preview tiff
%           'fig'       Matlab figure.
%           'png'       Portable Network Graphics
%           'pdf'       Portable Description Format
%           'jpeg'      Joint Photographic Experts Group
%           'orgfig'    Saves the orginal fugure in Matlab fig format.  
%
%   'map', maplist
%       Optional re-maping of styles. Example: 
%           'map', {[1:2:10 2:2:10], [10:-1:1]}
%       will use the odd defenitions first and then the even for the first
%       style and reverse order of the second style.
%
%   'n_marker', n
%       Optional change of number of dual markers to be used.
%
%   'nomap'
%       Clears user defined re-mapping.
%
%   'date' 
%       Adds date to output file name.
%
%   'nodate'
%       Clears date in filename.
%
%   'time'
%       Adds time to output file name. Note: Both time and date are only
%       changed when commands are invoked. 
%
%   'notime'
%       Clears time in filename.
%
%   'close' 
%       Closes all formated versions. Alternative command: 'nokeep'.
%
%   'noclose' 
%       Let all windows remain. Alternative command: 'keep'.
%
%
% Usage example
%   Generate a figure:
%       figure(1); plot(0:0.1:10,exp(-(0:0.1:10)'*(1./(1:10))))
%       legend('1','2','3','4','5','6','7','8','9','10')
%       xlabel('t [s]'); ylabel('u [V]'); title('exp(-t/\beta)');
%
%   Set up esplot:
%       esplot('style', {'esplot_default', 'esplot_press', 'esplot_ieee_article'}, 'print', {'eps','png'}, 'noclose');
% 
%   Invoke formating and printing:
%       esplot('figure', 1, 'test')
%


%% function set up
doplot = false;
ver='P1B';

%% Save the objects in variable
% Mandotary settings
persistent fig;
persistent styles;
persistent print_formats;

% Optional settings
persistent path;
persistent doprint;
persistent datestring;
persistent timestring;
persistent doclose;
persistent map;
persistent n_markers;

if isempty(doprint)
    doprint=false;
    path='';
    datestring='';
    timestring='';
    doclose=false; 
    map={};
end

if isempty(n_markers) 
    n_markers = [];
end



%% pharse input
i=1;
    while i<=nargin
        switch lower(varargin{i})

            case {'figure'}
                doplot = true;
                fig=varargin{i+1};
                name=varargin{i+2};
                i=i+3;
                
            case {'style'}
                styles = varargin{i+1};
                if ~iscell(styles)
                    styles={styles};
                end
                i=i+2;
                
            case {'n_marker'}
                n_markers = varargin{i+1};
                i=i+2;
                
            case {'map'}
                map=varargin{i+1};
                if ~iscell(map)
                    map={map};
                end
                i=i+2;
                
            case {'nomap'}
                map={};
                i=i+1;
                
            case {'path'}
                path=varargin{i+1};
                i=i+2;
                
            case {'print'}
                doprint = true;
                print_formats = varargin{i+1};
                if ~iscell(print_formats)
                    print_formats={print_formats};
                end
                i=i+2;
                
            case {'noprint'}
                doprint= false;
                i=i+1;
                
            case {'date'}
                datestring=datestr(now, '_yyyy-mm-dd');
                i=i+1;
                
            case {'nodate'}
                datestring='';
                i=i+1;
            
            case {'time'}
                timestring=datestr(now, '_HH-MM-SS');
                i=i+1;
                
            case {'notime'}
                timestring='';
                i=i+1;   
                
            case {'close', 'nokeep'}
                doclose=true;
                i=i+1;
                
            case {'noclose', 'keep'}
                doclose=false;
                i=i+1;

            case {'ver', 'version'}
                disp(strcat('Current version: ', ver));
                
                 files=ls('esplot_*.m');
                 
                 for a=1:size(files,1)
                    fil=files(a, 1:strfind(files(a,:), '.m') -1 );
                    
                    work=true;
                    try
                        form=feval(strcat(fil));
                    catch fel
                        %work=false;
                       
                    end
                        
                    if work
                        if isfield(form, 'ver')
                            disp(strcat( fil, ':', form.ver ));
                        end
                    end
                     
                 end
                
                i=i+1;
                
            otherwise
                Disp('Unknown argument');
                i=i+1;

        end

    end
    
    if doplot
        % figure handle list
        fhList=zeros(1,length(styles));
        
        % Run over styles
        for a=1:length(styles)
            
            % call form definition
            form=feval(styles{a});
                   
            % Focus on org figure
            org_fh=figure(fig);
            
            %Create figure
            fh=figure;
            fhList(a)=fh;
            %objects=allchild(org_fh);
            copyobj(get(org_fh,'children'),fh);
             
            
            % user mapping
            if ~isempty(map)
                linemap=map{ mod(a-1, length(map)  )+1};
            else
              	linemap=1:form.nLineFormat; 
            end
         
            %Get subwindows
            subFigureList=get(fh, 'Children');
            
            %Reverse subwindowslist in order to catch mainframe of plot.
            subFigureList=subFigureList(end:-1:1);

            for i=1:length(subFigureList)

                subFig=subFigureList(i);

                tag=get(subFig, 'Tag');
                
                switch lower(tag)
                    case {'legend'}
                      
                        legends=get(subFig, 'Children');
                        legends=legends(end:-1:1);
                        
                        
                        % Mess with legendbox only if knowledge about
                        % plotarea is known.
                        if ~isempty(plotPosition)
                        
                            legendPos=get(subFig, 'Position');
                        
                            fig_base = plotPosition(1:2);
                            fig_size = plotPosition(3:4);
                            leg_base = legendPos(1:2); 
                            leg_size = legendPos(3:4); 
                        
                            % Find out corner, crude
                            leg_mass = (fig_base + fig_size/2) - (leg_base + leg_size/2); 
                             
                            
                            % Claculate the different corners
                            Corners=[0 0.5 1 1   1 0.5 0  0; ...
                                     1 1   1 0.5 0 0   0  0.5];
                            
                          
                                 
                            fig_corners = ones(8,1)*fig_base + Corners'.* (ones(8,1)*fig_size); 
                            leg_corners = ones(8,1)*leg_base + Corners'.* (ones(8,1)*leg_size);
                            
                            %find closes corner
                            [m Corner]= min( (fig_corners(:,1)-leg_corners(:,1)).^2 +  (fig_corners(:,2)-leg_corners(:,2)).^2  ); 
                            
                            new_leg_size = leg_size;
                            
                            borderspace=[0 0]; %Default zeros.
                            
                            if(isfield(form, 'legendbox'))
                                
                                % if scale define, scale
                                if(isfield(form.legendbox, 'scale'))
                                    new_leg_size = new_leg_size.* form.legendbox.scale;
                                end

                                % if fixed border defined, add
                                if(isfield(form.legendbox, 'borderoffset'))
                                    new_leg_size = new_leg_size + form.legendbox.borderoffset;
                                end

                                % get some bordersapcing

                                if(isfield(form.legendbox, 'borderspace'))
                                    borderspace = form.legendbox. borderspace;
                                end
                            end
                            
                            new_leg_base = [0 0]; 
                            
                            switch Corner
                                
                                case {1, 2, 3} %upper
                                    new_leg_base(2) = fig_base(2) + fig_size(2) - borderspace(2) - new_leg_size(2); 
                                        
                                case {4,8} %mid
                                    new_leg_base(2) = fig_base(2) + fig_size(2)/2 - new_leg_size(2)/2;
                                    
                                case {5, 6, 7} %lower
                                    new_leg_base(2) = fig_base(2) + borderspace(2);
                            end
                            
                            
                            switch Corner
                                
                                case {1 , 7, 8} % Left
                                    new_leg_base(1) = fig_base(1) + borderspace(1);
                                    
                                case {2, 6} %mid
                                    new_leg_base(1) = fig_base(1) + fig_size(1)/2 - new_leg_size(1)/2;
                                    
                                case {3, 4, 5} % Right
                                    new_leg_base(1) = fig_base(1) + fig_size(1) - borderspace(1) - new_leg_size(1); 
                                    
                            end
                            
                            set(subFig, 'Position', [new_leg_base new_leg_size]);
                        
                            %set(subFig, 'Position', [0.2 0.20 0.6 0.6])
                        
                        end
                        
                        
                        %nLines=round(length(legends)/3);
                        
                        line=1;
                        
                        for leg=1:3:length(legends)-1
                            
                            % user defined maping
                            tline=linemap(mod(line-1,length(linemap))+1);
                            
                            % form line wrapping
                            formLine=mod(tline-1,form.nLineFormat)+1;
                            
                            if isfield(form, 'legendFontSize') 
                               set(legends(leg), 'FontSize', form.legendFontSize) 
                            end
                            
                            if isfield(form, 'legendFontName') 
                               set(legends(leg), 'FontName', form.legendFontName) 
                            end
                            
                            if isfield(form.lineFormat(formLine), 'lineWidth') 
                               set(legends(leg+1), 'LineWidth', form.lineFormat(formLine).lineWidth);   
                               set(legends(leg+2), 'LineWidth', form.lineFormat(formLine).lineWidth);  
                            end

                            if isfield(form.lineFormat(formLine), 'lineStyle') 
                               set(legends(leg+1), 'LineStyle', form.lineFormat(formLine).lineStyle);   
                            end
                                
                            if isfield(form.lineFormat(formLine), 'color') 
                               set(legends(leg+1), 'Color', form.lineFormat(formLine).color); 
                               if isfield(form.lineFormat(formLine), 'dualColor')
                                   dualColor=form.lineFormat(formLine).dualColor;
                               else
                                   dualColor=form.lineFormat(formLine).color;
                               end
                               set(legends(leg+2), 'Color', dualColor); 
                            end
                            
                            if isfield(form.lineFormat(formLine), 'marker') 
                               set(legends(leg+2), 'Marker', form.lineFormat(formLine).marker);   
                            end
                                
                            if isfield(form.lineFormat(formLine), 'markerSize') 
                               set(legends(leg+2), 'MarkerSize', form.lineFormat(formLine).markerSize);   
                            end
                            
                            % MarkerFaceColor?
                            
                            
                            line=line+1;
                        end %for legend
                    
                    otherwise
                        
                    % Catch frame size for plot to be used in legend box
                    % calc.
                    plotPosition = get(subFigureList(i), 'Position');
                        
                    % Format labels
                    xLabel = get(subFigureList(i), 'XLabel');
                    yLabel = get(subFigureList(i), 'YLabel');

                    if isfield(form, 'axesFontSize') 
                        set(subFig, 'FontSize', form.axesFontSize);
                        
                        if ~isempty(xLabel)
                            set(xLabel, 'FontSize', form.axesFontSize);
                        end
                        if ~isempty(yLabel)
                            set(yLabel, 'FontSize', form.axesFontSize);
                        end
                    end

                    if isfield(form, 'axesFontName')
                        set(subFig, 'FontName', form.axesFontName);
                        
                        if ~isempty(xLabel)
                            set(xLabel, 'FontName', form.axesFontName); 
                        end
                        if ~isempty(yLabel)
                            set(yLabel, 'FontName', form.axesFontName);
                        end
                    end


                    % Format subtitle
                    subTitle = get(subFigureList(i), 'Title');
                    if isfield(form, 'subTitleFontName') 
                        set(subTitle, 'FontName', form.subTitleFontName);              
                    end
                    if isfield(form, 'subTitleFontSize') 
                        set(subTitle, 'FontSize', form.subTitleFontSize);  
                    end



                    lineList=get(subFigureList(i), 'Children');

                    %Reverse list
                    lineList=lineList(end:-1:1);

                    % Find type of xscale
                    xScaleType = get(subFigureList(i), 'XScale');
                    
                    %Find xmin and xmax
                    xmin=min(get(lineList(1), 'XData'));
                    xmax=max(get(lineList(1), 'XData'));
                    for line=2:length(lineList)
                        xmin=min(xmin, min(get(lineList(line), 'XData')));
                        xmax=max(xmax, max(get(lineList(line), 'XData'))); 
                    end

                    % Calculate dual marker offsets
                    if ~isempty(n_markers)
                        nDualMarker = n_markers;
                    else
                        if isfield(form, 'nDualMarker')
                            nDualMarker = form.nDualMarker;
                        else
                            nDualMarker = 5;
                        end
                    end
                    delta = (xmax-xmin)/ nDualMarker; %Major division
                    %gamma = delta / length(lineList);  %Minor division


                    %if isField(form, 'lineFormat')

                       for line=1:length(lineList)

                           % user defined maping
                           tline=linemap(mod(line-1,length(linemap))+1);
                            
                           %index wrapper
                           formLine=mod(tline-1,form.nLineFormat)+1;

                           dual = false;
                           if isfield(form.lineFormat(formLine), 'dual')
                               if form.lineFormat(formLine).dual
                                   dual=true;
                               end
                           end

                           if ~dual        
                                if isfield(form.lineFormat(formLine), 'lineWidth') 
                                    set(lineList(line), 'LineWidth', form.lineFormat(formLine).lineWidth);   
                                end

                                if isfield(form.lineFormat(formLine), 'lineStyle') 
                                    set(lineList(line), 'LineStyle', form.lineFormat(formLine).lineStyle);   
                                end

                                if isfield(form.lineFormat(formLine), 'color') 
                                    set(lineList(line), 'Color', form.lineFormat(formLine).color);   
                                end

                                if isfield(form.lineFormat(formLine), 'marker') 
                                    set(lineList(line), 'Marker', form.lineFormat(formLine).marker);   
                                end

                                if isfield(form.lineFormat(formLine), 'markerSize') 
                                    set(lineList(line), 'MarkerSize', form.lineFormat(formLine).markerSize);   
                                end

                            else
                                %Dual plot
                                x=get(lineList(line), 'XData');
                                y=get(lineList(line), 'YData');

                                xMarker=zeros(1,nDualMarker);
                                yMarker=zeros(1,nDualMarker);
                                for seg=0:nDualMarker-1
                                    %[d ind]=min( ((line-0.5)*gamma+delta*seg -x).^2);
                                    switch xScaleType
                                        case 'log'
                                            [d ind]=min( ((seg+0.5)/nDualMarker*(log(xmax)-log(xmin))+log(xmin) - log(x) ).^2);
                                        case 'linear'
                                            [d ind]=min( ((seg+0.5)/nDualMarker*(xmax-xmin)+xmin - x ).^2);
                                    end
                                    xMarker(seg+1)=x(ind);
                                    yMarker(seg+1)=y(ind);

                                end

                                %Add line for marker
                                markerLine=copyobj(lineList(line), subFig);

                                set(markerLine, 'XData', xMarker);
                                set(markerLine, 'YData', yMarker);

                                if isfield(form.lineFormat(formLine), 'lineWidth') 
                                    set(lineList(line), 'LineWidth', form.lineFormat(formLine).lineWidth);
                                    set(markerLine,     'LineWidth', form.lineFormat(formLine).lineWidth);
                                end

                                if isfield(form.lineFormat(formLine), 'lineStyle') 
                                    set(lineList(line), 'LineStyle', form.lineFormat(formLine).lineStyle);  
                                    set(markerLine,     'LineStyle', 'none');   
                                end

                                if isfield(form.lineFormat(formLine), 'color') 
                                    set(lineList(line), 'Color', form.lineFormat(formLine).color);
                                    
                                    if isfield(form.lineFormat(formLine), 'dualColor')
                                        dualColor=form.lineFormat(formLine).dualColor;
                                    else
                                        dualColor=form.lineFormat(formLine).color;
                                    end
                                    set(markerLine,     'Color', dualColor);
                                end

                                if isfield(form.lineFormat(formLine), 'marker') 
                                    set(lineList(line), 'Marker', 'none');   
                                    set(markerLine,     'Marker', form.lineFormat(formLine).marker);  
                                end

                                if isfield(form.lineFormat(formLine), 'markerSize') 
                                    set(markerLine,    'MarkerSize', form.lineFormat(formLine).markerSize);   
                                end



                           end % dual
                  
                       end % line
   
                end %switch 
            end %for subplots
            
            % Set units
            if isfield(form, 'unit')
                set(fh, 'PaperUnits', form.unit);
                set(fh, 'Units',      form.unit);
            end
            
            % Set size
            if isfield(form, 'figXSize') && isfield(form, 'figYSize')
                
                if isfield(form, 'figMargin')
                    Margin = form.figMargin;
                else
                    Margin = 0;
                end
                
                set(fh, 'PaperSize', [form.figXSize+2*Margin form.figYSize+2*Margin]);
                set(fh, 'PaperPositionMode', 'Manual');
                %set(fh, 'PaperPosition', [0 0 form.figXSize form.figYSize])
                %set(fh, 'PaperPosition', [Margin Margin+form.figYSize/2-0.635 form.figXSize form.figYSize])
                set(fh, 'PaperPosition', [Margin Margin form.figXSize form.figYSize])
                
                oldPos =  get(fh, 'Position');
                set(fh, 'Position', [oldPos(1) oldPos(2) form.figXSize form.figYSize]) 
            end
            
            % Set Orientation
            if isfield(form, 'figOrientation') 
                set(fh, 'PaperOrientation', form.figOrientation);                
            end
            
            if isfield(form, 'color') 
                set(fh, 'Color', form.color);                
            end
           
            
           
 
            
            if doprint && doplot
            
                for iformats=1:length(print_formats)
               
                    filename = strcat(path, name, '_', styles{a}, datestring, timestring);
                    
                    switch lower(print_formats{iformats})
                        
                        case {'eps'}
                            print(fh, '-depsc2', '-r200', '-tiff', '-loose', strcat(filename, '.eps')  );
                            
                        case {'fig'}
                            saveas(fh, strcat(filename, '.fig') , 'fig');
                            
                        case {'orgfig', 'org_fig', 'orginal'}
                            saveas(org_fh, strcat(filename, '.org','.fig') , 'fig');
                            
                        case {'jpg', 'jpeg'}
                            print(fh, '-djpeg', '-r200', strcat(filename, '.jpg')  );
                            
                        case {'png'}
                            print(fh, '-dpng', '-r200', strcat(filename, '.png')  );
                            
                        case {'pdf'}
                            print('-dpdf', strcat(filename, '.pdf')  );
                    end
                
                end
            end
            
            if doclose
                close(fh);
            end
        end %styles

        if (nargout >=1) && ~doclose
            varargout{1}=fhList;
        end
    end %doplot
end





 
 
 
%% Suggested changes:

% JJW: Set default path to $USERAREA/doc/figs
% JJW: Remove space in file names (replace with "_")

% JA: Option to remove legend box outline
% JA: Option to fill markers
% JA: Handle text in figures

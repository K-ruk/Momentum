classdef mmt_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        MinimalnewymaganemomentumEditField  matlab.ui.control.NumericEditField
        MinimalnewymaganemomentumEditFieldLabel  matlab.ui.control.Label
        CheckBox                        matlab.ui.control.CheckBox
        Onlyconsiderstocksabove100daymovingaverageCheckBox  matlab.ui.control.CheckBox
        DanezaokresdugikompletneLamp    matlab.ui.control.Lamp
        DanezaokresdugikompletneLampLabel  matlab.ui.control.Label
        RysujwykresButton               matlab.ui.control.Button
        OkresdugiEditField              matlab.ui.control.NumericEditField
        OkresdugiEditFieldLabel         matlab.ui.control.Label
        OkreskrtkiEditField             matlab.ui.control.NumericEditField
        OkreskrtkiEditFieldLabel        matlab.ui.control.Label
        WybrspkiDropDown                matlab.ui.control.DropDown
        WybrspkiDropDownLabel           matlab.ui.control.Label
        DatasprawdzeniaDatePicker       matlab.ui.control.DatePicker
        DatasprawdzeniaDatePickerLabel  matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
        function check_c(app)
                
                %przerobić jako funkcję wywoływaną dowolną zmianą.
                check_c_dates=readtable(strcat("wse stocks/",app.WybrspkiDropDown.Value,".txt"));
                check_c_dates=table2array(check_c_dates(1:end,3));
                check_c_x=size(find(check_c_dates>str2double(datestr(app.DatasprawdzeniaDatePicker.Value,"yyyymmdd"))),1);
                check_c_dates=check_c_dates(end-check_c_x-app.OkresdugiEditField.Value);
            
                c_benchmark=readtable(strcat("wse stocks/wig20.txt"));
                c_benchmark=table2array(c_benchmark(1:end,3));
                x_benchmark=size(find(c_benchmark>str2double(datestr(app.DatasprawdzeniaDatePicker.Value,"yyyymmdd"))),1);  %data sprawdzenia jako ostateczna data do sprawdzenia kompletności dancyh
                c_benchmark=c_benchmark(end-x_benchmark-app.OkresdugiEditField.Value);
            
                if datetime(string(check_c_dates),'InputFormat','yyyyMMdd') < datetime(string(c_benchmark),'InputFormat','yyyyMMdd')
                    app.DanezaokresdugikompletneLamp.Color=[1 0 0];
                else 
                    app.DanezaokresdugikompletneLamp.Color=[0 1 0];
                end
             end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            listing={dir("wse stocks").name};
            [~,stock_id,~]=fileparts(listing);
            stock_id=stock_id(3:end);
                       
            app.WybrspkiDropDown.Items=stock_id;                                                %załadowanie listy spółek do dropdown
            app.WybrspkiDropDown.Value="wig20";                                                 %dodany wig20 celem ustalenia dni tradingu
            l_date=readtable("wse stocks/wig20.txt");          
            l_date=datetime(string(table2cell(l_date(end,3))),'InputFormat','yyyyMMdd');        %sprawdzenie jaka jest najnowsza data załadowanych plików
            
            clear listing, clear stock_id;
            
            app.DatasprawdzeniaDatePicker.Value=l_date;                                         %domyślna data (najnowsza)
            app.OkreskrtkiEditField.Value=125;                                                  %domyślne wartości okresów
            app.OkresdugiEditField.Value=250;
            
            
            
            app.DatasprawdzeniaDatePicker.Limits = [datetime([1992 1 1]) l_date];               %zabronione przyszłe daty
        end

        % Button pushed function: RysujwykresButton
        function RysujwykresButtonPushed(app, event)
            
            app.check_c();                                                                      %sprawdzenie kompletności danych dla okresu długiego
            
            if isnat(app.DatasprawdzeniaDatePicker.Value)
                errordlg("Nie wybrano daty sprawdzenia")
            else
                if app.OkresdugiEditField.Value < 2 
                    errordlg("Okres długi musi wynosić minimum 2 dni")
                else
                    

                    
                    tabela=readtable(strcat("wse stocks/",app.WybrspkiDropDown.Value,".txt"));  %pobranie danych za wybrany okres
                    dates=table2array(tabela(1:end,3));
                    
                    x=size(find(dates>str2double(datestr(app.DatasprawdzeniaDatePicker.Value,"yyyymmdd"))),1); %zaciągnięcie daty sprawdzenia
                    
                    values=table2array(tabela(end-app.OkresdugiEditField.Value-x:end-x,8));
                    plot(app.UIAxes,values);                                                    %rysowanie
                    
                    % app.UIAxes.XTickLabel=dates; etykiety osi X
                    
                    
                    
                end
            end

        end

        % Value changed function: WybrspkiDropDown
        function WybrspkiDropDownValueChanged(app, event)
            value = app.WybrspkiDropDown.Value;           
            app.check_c();                                                      %sprawdzenie kompletności danych dla okresu długiego
        end

        % Value changed function: DatasprawdzeniaDatePicker
        function DatasprawdzeniaDatePickerValueChanged(app, event)
            value = app.DatasprawdzeniaDatePicker.Value;
            app.check_c();                                                      %sprawdzenie kompletności danych dla okresu długiego
        end

        % Value changed function: OkresdugiEditField
        function OkresdugiEditFieldValueChanged(app, event)
            value = app.OkresdugiEditField.Value;
            
            if app.OkresdugiEditField.Value <= app.OkreskrtkiEditField.Value 
                errordlg("Okres długi musi być większy od krótkiego");
                app.OkresdugiEditField.Value = app.OkreskrtkiEditField.Value+1;
            end
            
            app.check_c();                                                      %sprawdzenie kompletności danych dla okresu długiego
        end

        % Value changed function: OkreskrtkiEditField
        function OkreskrtkiEditFieldValueChanged(app, event)
            value = app.OkreskrtkiEditField.Value;
             
            if app.OkresdugiEditField.Value <= app.OkreskrtkiEditField.Value 
                errordlg("Okres długi musi być większy od krótkiego");
                app.OkreskrtkiEditField.Value = app.OkresdugiEditField.Value-1;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 681 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Cena')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTickLabelRotation = 90;
            app.UIAxes.Position = [307 234 342 204];

            % Create DatasprawdzeniaDatePickerLabel
            app.DatasprawdzeniaDatePickerLabel = uilabel(app.UIFigure);
            app.DatasprawdzeniaDatePickerLabel.HorizontalAlignment = 'right';
            app.DatasprawdzeniaDatePickerLabel.Position = [19 416 102 22];
            app.DatasprawdzeniaDatePickerLabel.Text = 'Data sprawdzenia';

            % Create DatasprawdzeniaDatePicker
            app.DatasprawdzeniaDatePicker = uidatepicker(app.UIFigure);
            app.DatasprawdzeniaDatePicker.Limits = [datetime([1992 1 1]) datetime([2022 12 31])];
            app.DatasprawdzeniaDatePicker.ValueChangedFcn = createCallbackFcn(app, @DatasprawdzeniaDatePickerValueChanged, true);
            app.DatasprawdzeniaDatePicker.Position = [133 416 110 22];

            % Create WybrspkiDropDownLabel
            app.WybrspkiDropDownLabel = uilabel(app.UIFigure);
            app.WybrspkiDropDownLabel.HorizontalAlignment = 'right';
            app.WybrspkiDropDownLabel.Position = [26 200 74 22];
            app.WybrspkiDropDownLabel.Text = 'Wybór spółki';

            % Create WybrspkiDropDown
            app.WybrspkiDropDown = uidropdown(app.UIFigure);
            app.WybrspkiDropDown.ValueChangedFcn = createCallbackFcn(app, @WybrspkiDropDownValueChanged, true);
            app.WybrspkiDropDown.Position = [115 200 249 22];

            % Create OkreskrtkiEditFieldLabel
            app.OkreskrtkiEditFieldLabel = uilabel(app.UIFigure);
            app.OkreskrtkiEditFieldLabel.HorizontalAlignment = 'right';
            app.OkreskrtkiEditFieldLabel.Position = [20 376 70 22];
            app.OkreskrtkiEditFieldLabel.Text = 'Okres krótki';

            % Create OkreskrtkiEditField
            app.OkreskrtkiEditField = uieditfield(app.UIFigure, 'numeric');
            app.OkreskrtkiEditField.Limits = [1 Inf];
            app.OkreskrtkiEditField.ValueChangedFcn = createCallbackFcn(app, @OkreskrtkiEditFieldValueChanged, true);
            app.OkreskrtkiEditField.Position = [105 376 59 22];
            app.OkreskrtkiEditField.Value = 1;

            % Create OkresdugiEditFieldLabel
            app.OkresdugiEditFieldLabel = uilabel(app.UIFigure);
            app.OkresdugiEditFieldLabel.HorizontalAlignment = 'right';
            app.OkresdugiEditFieldLabel.Position = [20 334 66 22];
            app.OkresdugiEditFieldLabel.Text = 'Okres długi';

            % Create OkresdugiEditField
            app.OkresdugiEditField = uieditfield(app.UIFigure, 'numeric');
            app.OkresdugiEditField.Limits = [2 Inf];
            app.OkresdugiEditField.ValueChangedFcn = createCallbackFcn(app, @OkresdugiEditFieldValueChanged, true);
            app.OkresdugiEditField.Position = [101 334 63 22];
            app.OkresdugiEditField.Value = 2;

            % Create RysujwykresButton
            app.RysujwykresButton = uibutton(app.UIFigure, 'push');
            app.RysujwykresButton.ButtonPushedFcn = createCallbackFcn(app, @RysujwykresButtonPushed, true);
            app.RysujwykresButton.Position = [27 270 140 25];
            app.RysujwykresButton.Text = 'Rysuj wykres';

            % Create DanezaokresdugikompletneLampLabel
            app.DanezaokresdugikompletneLampLabel = uilabel(app.UIFigure);
            app.DanezaokresdugikompletneLampLabel.HorizontalAlignment = 'right';
            app.DanezaokresdugikompletneLampLabel.Position = [376 200 170 22];
            app.DanezaokresdugikompletneLampLabel.Text = 'Dane za okres długi kompletne';

            % Create DanezaokresdugikompletneLamp
            app.DanezaokresdugikompletneLamp = uilamp(app.UIFigure);
            app.DanezaokresdugikompletneLamp.Position = [561 200 20 20];

            % Create Onlyconsiderstocksabove100daymovingaverageCheckBox
            app.Onlyconsiderstocksabove100daymovingaverageCheckBox = uicheckbox(app.UIFigure);
            app.Onlyconsiderstocksabove100daymovingaverageCheckBox.Text = 'Only consider stocks above 100 day moving average';
            app.Onlyconsiderstocksabove100daymovingaverageCheckBox.Position = [29 135 308 22];

            % Create CheckBox
            app.CheckBox = uicheckbox(app.UIFigure);
            app.CheckBox.Text = 'Disqualify any stock that has a move larger than 15% in the past 90 days';
            app.CheckBox.Position = [29 114 416 22];

            % Create MinimalnewymaganemomentumEditFieldLabel
            app.MinimalnewymaganemomentumEditFieldLabel = uilabel(app.UIFigure);
            app.MinimalnewymaganemomentumEditFieldLabel.HorizontalAlignment = 'right';
            app.MinimalnewymaganemomentumEditFieldLabel.Position = [28 89 221 22];
            app.MinimalnewymaganemomentumEditFieldLabel.Text = 'Minimalne wymagane momentum';

            % Create MinimalnewymaganemomentumEditField
            app.MinimalnewymaganemomentumEditField = uieditfield(app.UIFigure, 'numeric');
            app.MinimalnewymaganemomentumEditField.Position = [29 89 29 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mmt_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
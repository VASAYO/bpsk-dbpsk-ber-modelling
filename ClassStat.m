classdef ClassStat < handle
    properties (SetAccess = private)
        % Параметры, используемые для накопления статистики
            NumTrBits;   % количество переданных бит
            NumTrFrames; % количество переданных кадров
            NumErBits;   % количество ошибочных  бит
            NumErFrames; % количество ошибочных  кадров
        % Переменная управления языком вывода информации для пользователя
            LogLanguage;
    end
    methods
        function obj = ClassStat(LogLanguage) % Конструктор
            % Инициализация значений переменных статистики
                obj.NumTrBits   = 0;
                obj.NumTrFrames = 0;
                obj.NumErBits   = 0;
                obj.NumErFrames = 0;
            % Переменная LogLanguage
                obj.LogLanguage = LogLanguage;
        end

        function Step(obj, Frame, Objs)
            
                if ~Objs.Encoder.isTransparent
                % Для случая с использованием свёрточного кодирования

                    % Объект подсчёта ошибок
                        errorCalc = comm.ErrorRate( ...
                            ReceiveDelay=Objs.Encoder.TBDepth);

                    % Подсчёт ошибок
                        Buf = errorCalc(Frame.TxData, Frame.RxData);

                    % Обновление статистики
                        obj.NumTrBits   = obj.NumTrBits   + ...
                            Buf(3);
                        obj.NumTrFrames = obj.NumTrFrames + 1;
                        obj.NumErBits   = obj.NumErBits   + Buf(2);
                        obj.NumErFrames = obj.NumErFrames + sign(Buf(2));

                else
                % Случай без кодирования

                    % Обновление статистики
                        obj.NumTrBits   = obj.NumTrBits   + ...
                            length(Frame.TxData);
                        obj.NumTrFrames = obj.NumTrFrames + 1;
                        Buf = sum(Frame.TxData ~= Frame.RxData);
                        obj.NumErBits   = obj.NumErBits   + Buf;
                        obj.NumErFrames = obj.NumErFrames + sign(Buf);
                end
        end
        function Reset(obj)
            obj.NumTrBits   = 0;
            obj.NumTrFrames = 0;
            obj.NumErBits   = 0;
            obj.NumErFrames = 0;
        end            
    end
end
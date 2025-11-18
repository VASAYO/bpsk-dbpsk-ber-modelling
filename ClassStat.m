classdef ClassStat < handle
    properties (SetAccess = private)
        % Параметры, используемые для накопления статистики
            NumTrBits;   % количество переданных бит
            NumTrFrames; % количество переданных кадров
            NumErBits;   % количество ошибочных  бит
            NumErFrames; % количество ошибочных  кадров
        % Переменная управления языком вывода информации для пользователя
            LogLanguage;

        % Объект подсчета ошибок
            errCalc;
    end
    methods
        function obj = ClassStat(LogLanguage, Objs) % Конструктор
            % Инициализация значений переменных статистики
                obj.NumTrBits   = 0;
                obj.NumTrFrames = 0;
                obj.NumErBits   = 0;
                obj.NumErFrames = 0;
            % Переменная LogLanguage
                obj.LogLanguage = LogLanguage;

            % Объект подсчета ошибок
                obj.errCalc = comm.ErrorRate( ...
                    "ReceiveDelay", Objs.Encoder.TBDepth);
        end

        function Step(obj, Frame)

            % Подсчёт ошибок и обновление переменных
                Buf = obj.errCalc(Frame.TxData, Frame.RxData);

                obj.NumTrBits   = Buf(3);
                obj.NumTrFrames = obj.NumTrFrames + 1;
                obj.NumErBits   = Buf(2);
                % Неправильно
                obj.NumErFrames = obj.NumErFrames + sign(Buf(2));

                % % Обновление статистики (исходный вариант подсчёта ошибок)
                %     obj.NumTrBits   = obj.NumTrBits   + ...
                %         length(Frame.TxData);
                %     obj.NumTrFrames = obj.NumTrFrames + 1;
                %     Buf = sum(Frame.TxData ~= Frame.RxData);
                %     obj.NumErBits   = obj.NumErBits   + Buf;
                %     obj.NumErFrames = obj.NumErFrames + sign(Buf);
        end
        function Reset(obj)
            obj.NumTrBits   = 0;
            obj.NumTrFrames = 0;
            obj.NumErBits   = 0;
            obj.NumErFrames = 0;

            obj.errCalc.reset();
        end            
    end
end
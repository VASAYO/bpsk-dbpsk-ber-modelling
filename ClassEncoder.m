classdef ClassEncoder < handle
    properties (SetAccess = private) % Переменные из параметров
        % Нужно ли выполнять кодирование и декодирование
            isTransparent;
        % Вид кодирования
            Type;
        % Поступают ли на вход декодера мягкие решения
            isSoftInput;
        % Память алгоритма Витерби
            TBDepth;

        % Переменная управления языком вывода информации для пользователя
            LogLanguage;
    end
    properties (SetAccess = private) % Вычисляемые переменные
        % Скорость кодирования
            Rate;
        % Структура, описывающая свёрточный кодер
            Trellis;
        % Сверточный кодер
            Coder;
        % Декодер Витерби
            DeCoder;
    end

    methods
        function obj = ClassEncoder(Params, LogLanguage) % Конструктор
            % Выделим поля Params, необходимые для инициализации
                Encoder  = Params.Encoder;
            % Инициализация значений переменных из параметров
                obj.isTransparent = Encoder.isTransparent;
                obj.Type          = Encoder.Type;
                obj.isSoftInput   = Encoder.isSoftInput;
                obj.TBDepth       = Encoder.TBDepth;

            % Переменная LogLanguage
                obj.LogLanguage = LogLanguage;

            % Скорость кодирования и описание свёрточного кодера
                if strcmp(obj.Type, 'Convolutional, [171 133]')
                    obj.Rate = 1/2;
                    obj.Trellis = poly2trellis(7, [171 133]);
                end

            % Свёрточный кодер [171 133]
                obj.Coder = comm.ConvolutionalEncoder(obj.Trellis);

            % Указатель на функцию декодера Витерби
                if ~obj.isSoftInput
                    decType = 'Hard';
                else
                    decType = "Unquantized";
                end

                obj.DeCoder = comm.ViterbiDecoder( ...
                    obj.Trellis, ...
                    InputFormat=decType, ...
                    TracebackDepth=obj.TBDepth);
        end

        function OutData = StepTx(obj, InData)
            if obj.isTransparent
                OutData = InData;
                return
            end
            
            % Здесь должна быть процедура кодирования
                if strcmp(obj.Type, 'Convolutional, [171 133]')
                    OutData = obj.Coder(InData);
                end
        end

        function OutData = StepRx(obj, InData)
            if obj.isTransparent
                OutData = InData;
                return
            end
            
            % Здесь должна быть процедура декодирования
                if strcmp(obj.Type, 'Convolutional, [171 133]')

                    OutData = obj.DeCoder(InData);
                end
        end
    end
end
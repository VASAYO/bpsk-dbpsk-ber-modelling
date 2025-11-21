classdef ClassEncoder < handle
    properties (SetAccess = private) % Переменные из параметров
        % Нужно ли выполнять кодирование и декодирование
            isTransparent;
        % Вид кодирования
            Type;
        % Поступают ли на вход декодера мягкие решения
            isSoftInput;

        % Переменная управления языком вывода информации для пользователя
            LogLanguage;
    end
    properties (SetAccess = private) % Вычисляемые переменные
        % Скорость кодирования
            Rate;
        % Длина кодового ограничения свёрточного кодера
            ConstraintLength;
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
            % Переменная LogLanguage
                obj.LogLanguage = LogLanguage;

            % Инициализация остальных параметров на основании прозрачности
            % блока и используемого кодирования
                if obj.isTransparent
                    obj.Rate             = 1;
                    obj.ConstraintLength = [];
                    obj.Coder            = [];
                    obj.DeCoder          = [];

                elseif strcmp(obj.Type, 'Convolutional, [171 133]')
                    obj.Rate = 1/2;
                    obj.ConstraintLength = 7;

                    % Описание свёрточного кодера
                        Trellis = poly2trellis( ...
                            obj.ConstraintLength, [171 133]);
                    % Память алгоритма Витерби
                        TBDepth = 30;

                    obj.Coder   = @(x) convenc(x, Trellis);
                    if obj.isSoftInput % На вход декодера поступают ЛОПы
                        obj.DeCoder = @(x) vitdec(x, ...
                            Trellis, TBDepth, "term", "unquant");

                    else % На вход декодера поступают жёсткие решения
                        obj.DeCoder = @(x) vitdec(x, ...
                            Trellis, TBDepth, "term", "hard");
                    end
                end
        end


        function OutData = StepTx(obj, InData)
        % Процедура кодирования
            % Проверка прозрачности блока
                if obj.isTransparent
                    OutData = InData;
                    return
                end
            
            if strcmp(obj.Type, 'Convolutional, [171 133]')
                % Добавление терминационных бит
                    DataAdd = [InData; zeros(obj.ConstraintLength, 1)];
                % Кодирование
                    OutData = obj.Coder(DataAdd);
            end
        end


        function OutData = StepRx(obj, InData)
        % Процедура декодирования
            % Проверка прозрачности блока
                if obj.isTransparent
                    OutData = InData;
                    return
                end
            
            if strcmp(obj.Type, 'Convolutional, [171 133]')
                % Декодирование
                    DecodedData = obj.DeCoder(InData);
                % Удаление терминационных бит
                    OutData = DecodedData(1:end-obj.ConstraintLength);
            end
        end
    end
end

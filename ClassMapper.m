classdef ClassMapper < handle
    properties (SetAccess = private) % Переменные из параметров
        % Нужно ли выполнять модуляцию и демодуляцию
            isTransparent;
        % Тип сигнального созвездия
            Type;
        % Размер сигнального созвездия
            ModulationOrder;
        % Ротация сигнального созвездия
            PhaseOffset;
        % Тип отображения бит на точки сигнального созвездия: 
        % bin | gray
            SymbolMapping;
        % Вариант принятия решений о модуляционных символах: 
        % bit | llr | approxllr
            DecisionMethod;
        % Переменная управления языком вывода информации для пользователя
            LogLanguage;
    end
    properties (SetAccess = private) % Вычисляемые переменные
        % Массив точек сигнального созвездия и соответствующий ему массив
        % бит
            Constellation;
            Bits;
        % Часто используемое значение
            log2M;
        % Указатели на функции модуляции/демодуляции
            MapperFun;
            DeMapperFun;
    end
    methods
        function obj = ClassMapper(Params, LogLanguage) % Конструктор
            % Выделим поля Params, необходимые для инициализации
                Mapper  = Params.Mapper;
            % Инициализация значений переменных из параметров
                obj.isTransparent = Mapper.isTransparent;
                obj.Type            = Mapper.Type;
                obj.ModulationOrder = Mapper.ModulationOrder;
                obj.PhaseOffset     = Mapper.PhaseOffset;
                obj.SymbolMapping   = Mapper.SymbolMapping;
                obj.DecisionMethod  = Mapper.DecisionMethod;
            % Переменная LogLanguage
                obj.LogLanguage = LogLanguage;

            % Расчёт часто используемого значения
                obj.log2M = log2(Mapper.ModulationOrder);
            
            % Инициализация указателей на функции модуляции/демодуляции
                if strcmp(Mapper.Type, 'PSK')
                    % Маппер
                        obj.MapperFun = @(x) pskmod(x, ...
                            obj.ModulationOrder, obj.PhaseOffset, ...
                            obj.SymbolMapping, ...
                            "InputType", "bit", ...
                            "OutputDataType", "double");

                    % Демаппер
                        obj.DeMapperFun = @(y, nvar) pskdemod(y, ...
                            obj.ModulationOrder, obj.PhaseOffset, ...
                            obj.SymbolMapping, ...
                            "OutputType", obj.DecisionMethod, ...
                            "NoiseVariance", nvar, ...
                            "OutputDataType", "double");

                elseif strcmp(Mapper.Type, 'DBPSK')
                    % Маппер
                        obj.MapperFun = @(x) dpskmod(x, ...
                            obj.ModulationOrder, ...
                            obj.PhaseOffset, ...
                            obj.SymbolMapping);

                    % Демаппер
                        obj.DeMapperFun = ...
                            @obj.DBPSKDemod;
                end

            % Определим массив возможных бит на входе модулятора и
            % соответствующих модуляционных символов
                if obj.isTransparent
                    obj.Bits = 1;
                    obj.Constellation = 1;
                else
                    obj.Bits = de2bi(0:obj.ModulationOrder-1, ...
                        obj.log2M, 'left-msb').';
                    obj.Constellation = obj.MapperFun(obj.Bits(:));
                end
        end

        function OutData = StepTx(obj, InData)
        % Маппинг

            if obj.isTransparent
                OutData = InData;
                return
            end
            
            OutData = obj.MapperFun(InData);
        end

        function OutData = StepRx(obj, InData, InstChannelParams)
        % Демаппинг

            if obj.isTransparent
                OutData = InData;
                return
            end
            
            OutData = obj.DeMapperFun(InData, InstChannelParams.Variance);
        end
    end

    methods (Access = private) % Методы для использования внутри объекта
        function OutData = DBPSKDemod(obj, InData, nvar)
        % Функция DBPSK демодулятора

            if strcmp(obj.DecisionMethod, 'bit')
                % Вынесение жестких решений
                    OutData = dpskdemod(InData, ...
                        obj.ModulationOrder, ...
                        obj.PhaseOffset, ...
                        obj.SymbolMapping);

            elseif strcmp(obj.DecisionMethod, 'llr') || ...
                    strcmp(obj.DecisionMethod, 'approxllr')

                % Тут должен находится алгоритм вынесения мягких решений
                    error(['Вынесение мягких решений для DBPSK пока ' ...
                        'не предусмотрено моделью']);
            end
        end
    end
end
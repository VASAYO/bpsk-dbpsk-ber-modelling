% Сетап лист, содержащий наборы параметров для основных вариантов
% вычислений

    Mapper.isTransparent = false;
    Channel.isTransparent = false;

    Mapper.Type = 'PSK';
    Mapper.ModulationOrder = 2;

    BER.h2dBInit = 0;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('BPSK');
% End of Params (ФМ-2)

    Mapper.isTransparent = false;
    Channel.isTransparent = false;

    Mapper.Type = 'DBPSK';
    Mapper.DecisionMethod = 'bit';

    BER.h2dBInit = 0;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('DBPSK');
% End of Params (ДФМ-2)

    Encoder.isTransparent = false;
    Mapper.isTransparent = false;
    Channel.isTransparent = false;
    
    Mapper.Type = 'PSK';
    Mapper.ModulationOrder = 2;
    Mapper.DecisionMethod = 'bit';

    BER.h2dBInit = 0;
    BER.MinNumErBits = 500;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('BPSK-ConvEnc-hard');
% End of Params (ФМ-2, кодирование, жесткие решения)

    Encoder.isTransparent = false;
    Mapper.isTransparent = false;
    Channel.isTransparent = false;

    Mapper.Type = 'PSK';
    Mapper.ModulationOrder = 2;
    Mapper.DecisionMethod = 'llr';

    BER.h2dBInit = 0;
    BER.MinNumErBits = 500;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('BPSK-ConvEnc-soft');
% End of Params (ФМ-2, кодирование, мягкие решения)

    Encoder.isTransparent = false;
    Mapper.isTransparent = false;
    Channel.isTransparent = false;
    
    Mapper.Type = 'DBPSK';
    Mapper.ModulationOrder = 2;
    Mapper.DecisionMethod = 'bit';

    BER.h2dBInit = 0;
    BER.MinNumErBits = 500;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('DBPSK-ConvEnc-hard');
% End of Params (ДФМ-2, кодирование, жесткие решения)

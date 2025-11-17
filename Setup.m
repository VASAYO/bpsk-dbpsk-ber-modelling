    Mapper.Type = 'PSK';
    Mapper.isTransparent = false;
    Channel.isTransparent = false;
    Mapper.ModulationOrder = 2;

    Common.NumWorkers = 8;

    BER.h2dBInit = 0;
% End of Params

    Mapper.Type = 'DBPSK';
    Mapper.isTransparent = false;
    Channel.isTransparent = false;
    Mapper.DecisionMethod = 'bit';

    Common.NumWorkers = 8;

    BER.h2dBInit = 0;
% End of Params

    Encoder.isTransparent = false;
    Mapper.isTransparent = false;
    Channel.isTransparent = false;
    
    Mapper.Type = 'PSK';
    Mapper.ModulationOrder = 2;
    Mapper.DecisionMethod = 'bit';

    BER.h2dBInit = 0;
    BER.MinNumErBits = 500;

    Common.NumWorkers = 8;
    Common.SaveFileName = sprintf('PSK-ConvEnc-hard');

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
    Common.SaveFileName = sprintf('PSK-ConvEnc-soft');
% End of Params (ФМ-2, кодирование, мягкие решения)

require 'paths'
local M = { }

function M.parse(arg)
    local cmd = torch.CmdLine()
    cmd:text()
    cmd:text('Torch-7 Training script')
    cmd:text()
    cmd:text('Options:')
    ------------- General options ---------------------
    cmd:option('-cache', 'checkpoint/', 'subdirectory in which to save/log experiments')
    cmd:option('-data',  '/path/to/dataset/folder', 'dataset folder')
    cmd:option('-subset', 'LO19', 'LO19 | LN83 | LN84 | LG36 | L498')
    ------------- Data options ------------------------
    cmd:option('-manualSeed',  2,         'Manually set RNG seed')
    cmd:option('-GPU',         1,         'Default preferred GPU')
    cmd:option('-nGPU',        1,         'Number of GPUs to use by default')
    cmd:option('-nDonkeys',    8,         'number of donkeys to initialize (data loading threads)')
    cmd:option('-imageSize',   960,       'image size')
    cmd:option('-imageCrop',   720,       'cropping size')
    cmd:option('-nClasses',    3,      'number of classes in the dataset')
    cmd:option('-kernelSize',  5,     'size for LCN')
    ------------- Training options --------------------
    cmd:option('-nEpochs',     120,        'Number of total epochs to run')
    cmd:option('-epochSize',   100,     'Number of iterations per epoch')
    cmd:option('-epochNumber', 1,         'Manual epoch number (useful on restarts)')
    cmd:option('-batchSize',   64,       'mini-batch size (1 = pure stochastic)')
    cmd:option('-iterSize',    1,         'Number of batches per iteration')
    ------------- Testing/Eval options ----------------
    cmd:option('-nEpochsTest',  1,        'Number of epochs to perform one testing')
    cmd:option('-nEpochsEval',  1,        'Number of epochs to perform one evaluation')
    cmd:option('-nEpochsSave',  1,        'Number of epochs to save model')
    cmd:option('-saveBest',     false,    'If Save the best model')
    ------------- Optimization options ----------------
    cmd:option('-LR',          0.0,       'learning rate; if set, overrides default LR/WD recipe')
    cmd:option('-momentum',    0.9,       'momentum')
    cmd:option('-weightDecay', 5e-4,      'weight decay')
    ------------- Model options -----------------------
    cmd:option('-netType',     'simple_cnn', 'your deep-net implementation')
    cmd:option('-dataset',     'single_dataset',  'Select a customized dataset loader')
    cmd:option('-retrain',     'none',    'provide path to model to retrain with')
    ------------- Run Options -------------------------
    cmd:option('-train',       false,    'run train procedure, note that not every -dataset support trainDataLoader')
    cmd:option('-eval',        false,    'run eval procedure, note that not every -dataset support evalDataLoader')
    cmd:option('-test',        false,    'run test procedure, note that not every -dataset support testDataLoader')
    cmd:option('-pipeline',    'standard','run a standard/customized train,test,eval procedure')

    cmd:text()

    ------------ Options from sepcified network -------------
    local netType = ''
    for i=1, #arg do
        if arg[i] == '-netType' then
            netType = arg[i+1]
        end
    end

    if netType ~= '' then
        cmd:text('Network "'..netType..'" options:')
        local config = netType
        -- all models should inherit from a basic model
        local basicnet = paths.dofile('models/basic_model.lua')
        local net = paths.dofile('models/' .. config .. '.lua')
        setmetatable(net, {__index=basicnet})
        net.arguments(cmd)
        cmd:text()
    end

    local opt = cmd:parse(arg or {})
    if (not opt.train) and (not opt.eval) and (not opt.test) then
        cmd:error('Must specify at least one running scheme: train, eval or test.')
    end
    -- append dataset to cache name
    opt.cache = path.join(opt.cache, opt.dataset)
    -- add commandline specified options
    opt.save = paths.concat(
        opt.cache,
        cmd:string(opt.netType, opt,
            {netType=true, retrain=true, cache=true, data=true}))
    -- add date/time
    opt.save = paths.concat(opt.save, '' .. os.date():gsub(' ',''))
    return opt
end

return M

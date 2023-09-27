/**
 * @file
 * Implements Trend meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_TREND_MQH
#define STG_META_TREND_MQH

// User input params.
INPUT2_GROUP("Meta Trend strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Trend_Strategy = STRAT_STOCHASTIC;  // Strategy to filter by trend
INPUT2_GROUP("Meta Trend strategy: common params");
INPUT2 float Meta_Trend_LotSize = 0;                // Lot size
INPUT2 int Meta_Trend_SignalOpenMethod = 0;         // Signal open method
INPUT2 float Meta_Trend_SignalOpenLevel = 0;        // Signal open level
INPUT2 int Meta_Trend_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT2 int Meta_Trend_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT2 int Meta_Trend_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT2 int Meta_Trend_SignalCloseMethod = 0;        // Signal close method
INPUT2 int Meta_Trend_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT2 float Meta_Trend_SignalCloseLevel = 0;       // Signal close level
INPUT2 int Meta_Trend_PriceStopMethod = 0;          // Price limit method
INPUT2 float Meta_Trend_PriceStopLevel = 2;         // Price limit level
INPUT2 int Meta_Trend_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT2 float Meta_Trend_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT2 short Meta_Trend_Shift = 0;                  // Shift
INPUT2 float Meta_Trend_OrderCloseLoss = 200;       // Order close loss
INPUT2 float Meta_Trend_OrderCloseProfit = 200;     // Order close profit
INPUT2 int Meta_Trend_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta Trend strategy: RSI oscillator params");
INPUT int Meta_Trend_RSI_Period = 16;                                    // Period
INPUT ENUM_APPLIED_PRICE Meta_Trend_RSI_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT int Meta_Trend_RSI_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_Trend_RSI_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Trend_Params_Defaults : StgParams {
  Stg_Meta_Trend_Params_Defaults()
      : StgParams(::Meta_Trend_SignalOpenMethod, ::Meta_Trend_SignalOpenFilterMethod, ::Meta_Trend_SignalOpenLevel,
                  ::Meta_Trend_SignalOpenBoostMethod, ::Meta_Trend_SignalCloseMethod, ::Meta_Trend_SignalCloseFilter,
                  ::Meta_Trend_SignalCloseLevel, ::Meta_Trend_PriceStopMethod, ::Meta_Trend_PriceStopLevel,
                  ::Meta_Trend_TickFilterMethod, ::Meta_Trend_MaxSpread, ::Meta_Trend_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Trend_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Trend_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Trend_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Trend_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Trend_SignalOpenFilterTime);
  }
};

class Stg_Meta_Trend : public Strategy {
 protected:
  Ref<Strategy> strat;

 public:
  Stg_Meta_Trend(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Trend *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Trend_Params_Defaults stg_trend_defaults;
    StgParams _stg_params(stg_trend_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Trend(_stg_params, _tparams, _cparams, "(Meta) Trend");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    SetStrategy(Meta_Trend_Strategy);
    // Initialize indicators.
    {
      IndiRSIParams _indi_params(::Meta_Trend_RSI_Period, ::Meta_Trend_RSI_Applied_Price, ::Meta_Trend_RSI_Shift);
      _indi_params.SetDataSourceType(::Meta_Trend_RSI_SourceType);
      _indi_params.SetTf(PERIOD_D1);
      SetIndicator(new Indi_RSI(_indi_params));
    }
  }

  /**
   * Sets strategy.
   */
  bool SetStrategy(ENUM_STRATEGY _sid) {
    bool _result = true;
    long _magic_no = Get<long>(STRAT_PARAM_ID);
    ENUM_TIMEFRAMES _tf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);

    switch (_sid) {
      case STRAT_NONE:
        break;
      case STRAT_AC:
        _result &= StrategyAdd<Stg_AC>(_tf, _magic_no, _sid);
        break;
      case STRAT_AD:
        _result &= StrategyAdd<Stg_AD>(_tf, _magic_no, _sid);
        break;
      case STRAT_ADX:
        _result &= StrategyAdd<Stg_ADX>(_tf, _magic_no, _sid);
        break;
      case STRAT_AMA:
        _result &= StrategyAdd<Stg_AMA>(_tf, _magic_no, _sid);
        break;
      case STRAT_ARROWS:
        _result &= StrategyAdd<Stg_Arrows>(_tf, _magic_no, _sid);
        break;
      case STRAT_ASI:
        _result &= StrategyAdd<Stg_ASI>(_tf, _magic_no, _sid);
        break;
      case STRAT_ATR:
        _result &= StrategyAdd<Stg_ATR>(_tf, _magic_no, _sid);
        break;
      case STRAT_ALLIGATOR:
        _result &= StrategyAdd<Stg_Alligator>(_tf, _magic_no, _sid);
        break;
      case STRAT_AWESOME:
        _result &= StrategyAdd<Stg_Awesome>(_tf, _magic_no, _sid);
        break;
      case STRAT_BWMFI:
        _result &= StrategyAdd<Stg_BWMFI>(_tf, _magic_no, _sid);
        break;
      case STRAT_BANDS:
        _result &= StrategyAdd<Stg_Bands>(_tf, _magic_no, _sid);
        break;
      case STRAT_BEARS_POWER:
        _result &= StrategyAdd<Stg_BearsPower>(_tf, _magic_no, _sid);
        break;
      case STRAT_BULLS_POWER:
        _result &= StrategyAdd<Stg_BullsPower>(_tf, _magic_no, _sid);
        break;
      case STRAT_CCI:
        _result &= StrategyAdd<Stg_CCI>(_tf, _magic_no, _sid);
        break;
      case STRAT_CHAIKIN:
        _result &= StrategyAdd<Stg_Chaikin>(_tf, _magic_no, _sid);
        break;
      case STRAT_DEMA:
        _result &= StrategyAdd<Stg_DEMA>(_tf, _magic_no, _sid);
        break;
      case STRAT_DEMARKER:
        _result &= StrategyAdd<Stg_DeMarker>(_tf, _magic_no, _sid);
        break;
      case STRAT_DPO:
        _result &= StrategyAdd<Stg_DPO>(_tf, _magic_no, _sid);
        break;
      case STRAT_ENVELOPES:
        _result &= StrategyAdd<Stg_Envelopes>(_tf, _magic_no, _sid);
        break;
      case STRAT_FORCE:
        _result &= StrategyAdd<Stg_Force>(_tf, _magic_no, _sid);
        break;
      case STRAT_FRACTALS:
        _result &= StrategyAdd<Stg_Fractals>(_tf, _magic_no, _sid);
        break;
      case STRAT_GATOR:
        _result &= StrategyAdd<Stg_Gator>(_tf, _magic_no, _sid);
        break;
      case STRAT_HEIKEN_ASHI:
        _result &= StrategyAdd<Stg_HeikenAshi>(_tf, _magic_no, _sid);
        break;
      case STRAT_ICHIMOKU:
        _result &= StrategyAdd<Stg_Ichimoku>(_tf, _magic_no, _sid);
        break;
      case STRAT_INDICATOR:
        _result &= StrategyAdd<Stg_Indicator>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA:
        _result &= StrategyAdd<Stg_MA>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA_BREAKOUT:
        _result &= StrategyAdd<Stg_MA_Breakout>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA_CROSS_PIVOT:
        _result &= StrategyAdd<Stg_MA_Cross_Pivot>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA_CROSS_SHIFT:
        _result &= StrategyAdd<Stg_MA_Cross_Shift>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA_CROSS_SUP_RES:
        _result &= StrategyAdd<Stg_MA_Cross_Sup_Res>(_tf, _magic_no, _sid);
        break;
      case STRAT_MA_TREND:
        _result &= StrategyAdd<Stg_MA_Trend>(_tf, _magic_no, _sid);
        break;
      case STRAT_MACD:
        _result &= StrategyAdd<Stg_MACD>(_tf, _magic_no, _sid);
        break;
      case STRAT_MFI:
        _result &= StrategyAdd<Stg_MFI>(_tf, _magic_no, _sid);
        break;
      case STRAT_MOMENTUM:
        _result &= StrategyAdd<Stg_Momentum>(_tf, _magic_no, _sid);
        break;
      case STRAT_OBV:
        _result &= StrategyAdd<Stg_OBV>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR:
        _result &= StrategyAdd<Stg_Oscillator>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_DIVERGENCE:
        _result &= StrategyAdd<Stg_Oscillator_Divergence>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_MULTI:
        _result &= StrategyAdd<Stg_Oscillator_Multi>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_CROSS:
        _result &= StrategyAdd<Stg_Oscillator_Cross>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_CROSS_SHIFT:
        _result &= StrategyAdd<Stg_Oscillator_Cross_Shift>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_CROSS_ZERO:
        _result &= StrategyAdd<Stg_Oscillator_Cross_Zero>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_RANGE:
        _result &= StrategyAdd<Stg_Oscillator_Range>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSCILLATOR_TREND:
        _result &= StrategyAdd<Stg_Oscillator_Trend>(_tf, _magic_no, _sid);
        break;
      case STRAT_OSMA:
        _result &= StrategyAdd<Stg_OsMA>(_tf, _magic_no, _sid);
        break;
      case STRAT_PATTERN:
        _result &= StrategyAdd<Stg_Pattern>(_tf, _magic_no, _sid);
        break;
      case STRAT_PINBAR:
        _result &= StrategyAdd<Stg_Pinbar>(_tf, _magic_no, _sid);
        break;
      case STRAT_PIVOT:
        _result &= StrategyAdd<Stg_Pivot>(_tf, _magic_no, _sid);
        break;
      case STRAT_RSI:
        _result &= StrategyAdd<Stg_RSI>(_tf, _magic_no, _sid);
        break;
      case STRAT_RVI:
        _result &= StrategyAdd<Stg_RVI>(_tf, _magic_no, _sid);
        break;
      case STRAT_SAR:
        _result &= StrategyAdd<Stg_SAR>(_tf, _magic_no, _sid);
        break;
      case STRAT_STDDEV:
        _result &= StrategyAdd<Stg_StdDev>(_tf, _magic_no, _sid);
        break;
      case STRAT_STOCHASTIC:
        _result &= StrategyAdd<Stg_Stochastic>(_tf, _magic_no, _sid);
        break;
      case STRAT_WPR:
        _result &= StrategyAdd<Stg_WPR>(_tf, _magic_no, _sid);
        break;
      case STRAT_ZIGZAG:
        _result &= StrategyAdd<Stg_ZigZag>(_tf, _magic_no, _sid);
        break;
      default:
        logger.Warning(StringFormat("Unknown strategy: %d", _sid), __FUNCTION_LINE__, GetName());
        break;
    }

    return _result;
  }

  /**
   * Adds strategy to specific timeframe.
   *
   * @param
   *   _tf - timeframe to add the strategy.
   *   _magic_no - unique order identified
   *
   * @return
   *   Returns true if the strategy has been initialized correctly, otherwise false.
   */
  template <typename SClass>
  bool StrategyAdd(ENUM_TIMEFRAMES _tf, long _magic_no = 0, int _type = 0) {
    bool _result = true;
    _magic_no = _magic_no > 0 ? _magic_no : rand();
    Ref<Strategy> _strat = ((SClass *)NULL).Init(_tf);
    _strat.Ptr().Set<long>(STRAT_PARAM_ID, _magic_no);
    _strat.Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
    _strat.Ptr().Set<int>(STRAT_PARAM_TYPE, _type);
    _strat.Ptr().OnInit();
    strat = _strat;
    return _result;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    if (!strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    IndicatorBase *_indi = GetIndicator();
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] >= 50 - _level && _indi[_shift + 1][0] >= 50 - _level;
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] <= 50 + _level && _indi[_shift + 1][0] <= 50 + _level;
        break;
    }
    _level = _level == 0.0f ? strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? strat.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= strat.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    if (!strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    IndicatorBase *_indi = GetIndicator();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] <= 50 + _level && _indi[_shift + 1][0] <= 50 + _level;
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] >= 50 - _level && _indi[_shift + 1][0] >= 50 - _level;
        break;
    }
    return _result;
  }
};

#endif  // STG_META_TREND_MQH

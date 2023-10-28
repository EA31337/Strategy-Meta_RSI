/**
 * @file
 * Implements RSI meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_RSI_MQH
#define STG_META_RSI_MQH

// User input params.
INPUT2_GROUP("Meta RSI strategy: main params");
INPUT2 ENUM_STRATEGY Meta_RSI_Strategy_RSI_Neutral = STRAT_BANDS;  // Strategy for RSI at neutral range (40-60)
INPUT2 ENUM_STRATEGY Meta_RSI_Strategy_RSI_Peak = STRAT_FORCE;     // Strategy for RSI at peak range (0-20,80-100)
INPUT2 ENUM_STRATEGY Meta_RSI_Strategy_RSI_Trend = STRAT_AC;       // Strategy for RSI at trend range (20-40,60-80)
INPUT3_GROUP("Meta RSI strategy: common params");
INPUT3 float Meta_RSI_LotSize = 0;                // Lot size
INPUT3 int Meta_RSI_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_RSI_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_RSI_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_RSI_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_RSI_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_RSI_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_RSI_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_RSI_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_RSI_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_RSI_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_RSI_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_RSI_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_RSI_Shift = 0;                  // Shift
INPUT3 float Meta_RSI_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_RSI_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_RSI_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta RSI strategy: RSI oscillator params");
INPUT int Meta_RSI_RSI_Period = 14;                                    // Period
INPUT ENUM_APPLIED_PRICE Meta_RSI_RSI_Applied_Price = PRICE_TYPICAL;   // Applied Price
INPUT int Meta_RSI_RSI_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_RSI_RSI_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_RSI_Params_Defaults : StgParams {
  Stg_Meta_RSI_Params_Defaults()
      : StgParams(::Meta_RSI_SignalOpenMethod, ::Meta_RSI_SignalOpenFilterMethod, ::Meta_RSI_SignalOpenLevel,
                  ::Meta_RSI_SignalOpenBoostMethod, ::Meta_RSI_SignalCloseMethod, ::Meta_RSI_SignalCloseFilter,
                  ::Meta_RSI_SignalCloseLevel, ::Meta_RSI_PriceStopMethod, ::Meta_RSI_PriceStopLevel,
                  ::Meta_RSI_TickFilterMethod, ::Meta_RSI_MaxSpread, ::Meta_RSI_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_RSI_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_RSI_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_RSI_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_RSI_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_RSI_SignalOpenFilterTime);
  }
};

class Stg_Meta_RSI : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_RSI(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_RSI_Params_Defaults stg_rsi_defaults;
    StgParams _stg_params(stg_rsi_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_RSI(_stg_params, _tparams, _cparams, "(Meta) RSI");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_RSI_Strategy_RSI_Neutral, 0);
    StrategyAdd(Meta_RSI_Strategy_RSI_Peak, 1);
    StrategyAdd(Meta_RSI_Strategy_RSI_Trend, 2);
    // Initialize indicators.
    {
      IndiRSIParams _indi_params(::Meta_RSI_RSI_Period, ::Meta_RSI_RSI_Applied_Price, ::Meta_RSI_RSI_Shift);
      _indi_params.SetDataSourceType(::Meta_RSI_RSI_SourceType);
      _indi_params.SetTf(PERIOD_D1);
      SetIndicator(new Indi_RSI(_indi_params));
    }
  }

  /**
   * Sets strategy.
   */
  bool StrategyAdd(ENUM_STRATEGY _sid, long _index = -1) {
    ENUM_TIMEFRAMES _tf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);
    Ref<Strategy> _strat = StrategiesManager::StrategyInitByEnum(_sid, _tf);
#ifdef __strategies_meta__
    if (!_strat.IsSet()) {
      _strat = StrategiesMetaManager::StrategyInitByEnum((ENUM_STRATEGY_META)_sid, _tf);
    }
#endif
    if (_strat.IsSet()) {
      _strat.Ptr().Set<long>(STRAT_PARAM_ID, Get<long>(STRAT_PARAM_ID));
      _strat.Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
      _strat.Ptr().Set<int>(STRAT_PARAM_TYPE, _sid);
      _strat.Ptr().OnInit();
      if (_index >= 0) {
        strats.Set(_index, _strat);
      } else {
        strats.Push(_strat);
      }
    }
    return _strat.IsSet();
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    IndicatorBase *_indi = GetIndicator();
    Ref<Strategy> _strat_ref;
    if (_indi[_ishift][0] <= 20 || _indi[_ishift][0] >= 80) {
      // RSI value is at peak range (0-20 or 80-100).
      _strat_ref = strats.GetByKey(1);
    } else if (_indi[_ishift][0] < 40 || _indi[_ishift][0] > 60) {
      // RSI value is at trend range (20-40 or 60-80).
      _strat_ref = strats.GetByKey(2);
    } else if (_indi[_ishift][0] > 40 && _indi[_ishift][0] < 60) {
      // RSI value is at neutral range (40-60).
      _strat_ref = strats.GetByKey(0);
    }
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = false;
    _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_RSI_MQH

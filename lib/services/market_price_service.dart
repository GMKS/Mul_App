/// Market Price Service
/// Handles fetching real-time market data, predictions, and analysis

import 'dart:async';
import 'dart:math';
import '../models/market_price_model.dart';

class MarketPriceService {
  static final MarketPriceService _instance = MarketPriceService._internal();
  factory MarketPriceService() => _instance;
  MarketPriceService._internal();

  // Stream controllers for real-time updates
  final _niftyController = StreamController<MarketIndex>.broadcast();
  final _bankNiftyController = StreamController<MarketIndex>.broadcast();
  final _commoditiesController =
      StreamController<List<RegionalCommodity>>.broadcast();
  final _signalsController = StreamController<List<TradingSignal>>.broadcast();

  Stream<MarketIndex> get niftyStream => _niftyController.stream;
  Stream<MarketIndex> get bankNiftyStream => _bankNiftyController.stream;
  Stream<List<RegionalCommodity>> get commoditiesStream =>
      _commoditiesController.stream;
  Stream<List<TradingSignal>> get signalsStream => _signalsController.stream;

  Timer? _updateTimer;
  final Random _random = Random();

  // Start real-time updates (simulated with mock data)
  void startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateMarketData();
    });
    _updateMarketData(); // Initial update
  }

  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
  }

  void _updateMarketData() {
    // Update Nifty
    _niftyController.add(_generateMockNifty());

    // Update Bank Nifty
    _bankNiftyController.add(_generateMockBankNifty());

    // Update commodities
    _commoditiesController.add(_generateMockCommodities());

    // Update trading signals
    _signalsController.add(_generateMockTradingSignals());
  }

  // Fetch all market indices
  Future<List<MarketIndex>> fetchMarketIndices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      _generateMockNifty(),
      _generateMockBankNifty(),
      _generateMockIndex('Nifty IT', 'NIFTYIT', IndexType.niftyIt, 35000),
      _generateMockIndex(
          'Nifty Pharma', 'NIFTYPHARMA', IndexType.niftyPharma, 14000),
      _generateMockIndex('Nifty Auto', 'NIFTYAUTO', IndexType.niftyAuto, 16000),
    ];
  }

  MarketIndex _generateMockNifty() {
    final basePrice = 21800.0;
    final variation = _random.nextDouble() * 200 - 100;
    final currentPrice = basePrice + variation;
    final previousClose = basePrice;
    final changeValue = currentPrice - previousClose;
    final changePercent = (changeValue / previousClose) * 100;

    return MarketIndex(
      id: 'nifty50',
      type: IndexType.nifty50,
      name: 'Nifty 50',
      symbol: 'NIFTY',
      currentPrice: currentPrice,
      openPrice: basePrice + (_random.nextDouble() * 50 - 25),
      highPrice: currentPrice + _random.nextDouble() * 50,
      lowPrice: currentPrice - _random.nextDouble() * 50,
      previousClose: previousClose,
      changeValue: changeValue,
      changePercent: changePercent,
      volume: 150000000 + _random.nextInt(50000000),
      lastUpdated: DateTime.now(),
      isMarketOpen: _isMarketOpen(),
      historicalData: _generateHistoricalData(basePrice, 30),
      prediction: _generateAIPrediction('nifty', currentPrice),
      sentiment: changePercent > 1
          ? MarketSentiment.bullish
          : changePercent < -1
              ? MarketSentiment.bearish
              : MarketSentiment.neutral,
      expertCommentary:
          'Markets showing resilience amid global uncertainty. Tech and banking sectors leading gains.',
    );
  }

  MarketIndex _generateMockBankNifty() {
    final basePrice = 46500.0;
    final variation = _random.nextDouble() * 300 - 150;
    final currentPrice = basePrice + variation;
    final previousClose = basePrice;
    final changeValue = currentPrice - previousClose;
    final changePercent = (changeValue / previousClose) * 100;

    return MarketIndex(
      id: 'banknifty',
      type: IndexType.bankNifty,
      name: 'Bank Nifty',
      symbol: 'BANKNIFTY',
      currentPrice: currentPrice,
      openPrice: basePrice + (_random.nextDouble() * 100 - 50),
      highPrice: currentPrice + _random.nextDouble() * 100,
      lowPrice: currentPrice - _random.nextDouble() * 100,
      previousClose: previousClose,
      changeValue: changeValue,
      changePercent: changePercent,
      volume: 80000000 + _random.nextInt(30000000),
      lastUpdated: DateTime.now(),
      isMarketOpen: _isMarketOpen(),
      historicalData: _generateHistoricalData(basePrice, 30),
      prediction: _generateAIPrediction('banknifty', currentPrice),
      sentiment: changePercent > 1
          ? MarketSentiment.veryBullish
          : changePercent < -1
              ? MarketSentiment.bearish
              : MarketSentiment.neutral,
      expertCommentary:
          'Banking sector supported by strong credit growth and improving asset quality.',
    );
  }

  MarketIndex _generateMockIndex(
      String name, String symbol, IndexType type, double basePrice) {
    final variation =
        _random.nextDouble() * (basePrice * 0.02) - (basePrice * 0.01);
    final currentPrice = basePrice + variation;
    final previousClose = basePrice;
    final changeValue = currentPrice - previousClose;
    final changePercent = (changeValue / previousClose) * 100;

    return MarketIndex(
      id: symbol.toLowerCase(),
      type: type,
      name: name,
      symbol: symbol,
      currentPrice: currentPrice,
      openPrice: basePrice + (_random.nextDouble() * 50 - 25),
      highPrice: currentPrice + _random.nextDouble() * 50,
      lowPrice: currentPrice - _random.nextDouble() * 50,
      previousClose: previousClose,
      changeValue: changeValue,
      changePercent: changePercent,
      volume: 50000000 + _random.nextInt(20000000),
      lastUpdated: DateTime.now(),
      isMarketOpen: _isMarketOpen(),
      historicalData: _generateHistoricalData(basePrice, 30),
      sentiment:
          changePercent > 0 ? MarketSentiment.bullish : MarketSentiment.bearish,
    );
  }

  bool _isMarketOpen() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    // Market open Monday-Friday, 9:15 AM - 3:30 PM IST
    return dayOfWeek >= 1 && dayOfWeek <= 5 && hour >= 9 && hour < 16;
  }

  List<PricePoint> _generateHistoricalData(double basePrice, int days) {
    final data = <PricePoint>[];
    var currentPrice = basePrice;

    for (int i = days; i >= 0; i--) {
      final timestamp = DateTime.now().subtract(Duration(days: i));
      final change = (_random.nextDouble() - 0.5) * (basePrice * 0.02);
      currentPrice += change;

      data.add(PricePoint(
        timestamp: timestamp,
        price: currentPrice,
        open: currentPrice - _random.nextDouble() * 50,
        high: currentPrice + _random.nextDouble() * 50,
        low: currentPrice - _random.nextDouble() * 50,
        close: currentPrice,
        volume: 100000000 + _random.nextInt(50000000),
      ));
    }

    return data;
  }

  AIPrediction _generateAIPrediction(String assetId, double currentPrice) {
    final predictedChange =
        (_random.nextDouble() - 0.5) * (currentPrice * 0.05);
    final predictedPrice = currentPrice + predictedChange;
    final confidence = 0.6 + (_random.nextDouble() * 0.3);

    final forecastPoints = <PricePoint>[];
    var price = currentPrice;
    for (int i = 1; i <= 7; i++) {
      price += (predictedPrice - currentPrice) / 7;
      forecastPoints.add(PricePoint(
        timestamp: DateTime.now().add(Duration(days: i)),
        price: price,
      ));
    }

    return AIPrediction(
      id: '${assetId}_pred_${DateTime.now().millisecondsSinceEpoch}',
      predictedPrice: predictedPrice,
      confidenceScore: confidence,
      timeframe: '7 days',
      forecastPoints: forecastPoints,
      indicators: {
        'RSI': 45 + _random.nextInt(20),
        'MACD': _random.nextDouble() * 10 - 5,
        'EMA': currentPrice * (1 + (_random.nextDouble() - 0.5) * 0.02),
      },
      model: 'LSTM-Transformer',
      generatedAt: DateTime.now(),
    );
  }

  // Fetch regional commodities
  Future<List<RegionalCommodity>> fetchRegionalCommodities(String city) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateMockCommodities(city: city);
  }

  List<RegionalCommodity> _generateMockCommodities(
      {String city = 'Hyderabad'}) {
    return [
      _generateCommodity(
          'Tomato', 'టమాటో', 40, CommodityCategory.vegetables, city),
      _generateCommodity(
          'Onion', 'ఉల్లిపాయ', 35, CommodityCategory.vegetables, city),
      _generateCommodity(
          'Potato', 'బంగాళాదుంప', 25, CommodityCategory.vegetables, city),
      _generateCommodity('Rice', 'బియ్యం', 45, CommodityCategory.grains, city),
      _generateCommodity('Wheat', 'గోధుమ', 28, CommodityCategory.grains, city),
      _generateCommodity('Mango', 'మామిడి', 80, CommodityCategory.fruits, city),
      _generateCommodity('Banana', 'అరటి', 50, CommodityCategory.fruits, city),
      _generateCommodity(
          'Turmeric', 'పసుపు', 180, CommodityCategory.spices, city),
      _generateCommodity(
          'Chili', 'మిర్చి', 120, CommodityCategory.spices, city),
      _generateCommodity(
          'Toor Dal', 'కందిపప్పు', 95, CommodityCategory.pulses, city),
    ];
  }

  RegionalCommodity _generateCommodity(String name, String localName,
      double basePrice, CommodityCategory category, String city) {
    final variation = (_random.nextDouble() - 0.5) * (basePrice * 0.2);
    final currentPrice = basePrice + variation;
    final previousPrice = basePrice;
    final changePercent =
        ((currentPrice - previousPrice) / previousPrice) * 100;

    return RegionalCommodity(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      localName: localName,
      category: category,
      currentPrice: currentPrice,
      previousPrice: previousPrice,
      changePercent: changePercent,
      unit: 'kg',
      market: '$city Wholesale Market',
      city: city,
      state: 'Telangana',
      lastUpdated: DateTime.now(),
      priceHistory: _generateCommodityHistory(basePrice, 30),
    );
  }

  List<PricePoint> _generateCommodityHistory(double basePrice, int days) {
    final data = <PricePoint>[];
    var currentPrice = basePrice;

    for (int i = days; i >= 0; i--) {
      final timestamp = DateTime.now().subtract(Duration(days: i));
      final change = (_random.nextDouble() - 0.5) * (basePrice * 0.1);
      currentPrice += change;

      data.add(PricePoint(
        timestamp: timestamp,
        price: currentPrice,
      ));
    }

    return data;
  }

  // Fetch trading signals
  Future<List<TradingSignal>> fetchTradingSignals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateMockTradingSignals();
  }

  List<TradingSignal> _generateMockTradingSignals() {
    return [
      TradingSignal(
        id: 'signal_1',
        assetId: 'nifty50',
        assetName: 'Nifty 50',
        signalType: SignalType.buy,
        targetPrice: 22000,
        stopLoss: 21600,
        takeProfit: 22300,
        confidenceScore: 0.78,
        riskLevel: RiskLevel.medium,
        strategy: 'Breakout Strategy',
        rationale:
            'Strong momentum with bullish RSI divergence. Volume confirmation present.',
        generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      ),
      TradingSignal(
        id: 'signal_2',
        assetId: 'banknifty',
        assetName: 'Bank Nifty',
        signalType: SignalType.strongBuy,
        targetPrice: 47500,
        stopLoss: 46000,
        takeProfit: 48000,
        confidenceScore: 0.85,
        riskLevel: RiskLevel.medium,
        strategy: 'Trend Following',
        rationale:
            'Banking sector showing strong fundamentals. Credit growth accelerating.',
        generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
      TradingSignal(
        id: 'signal_3',
        assetId: 'niftyit',
        assetName: 'Nifty IT',
        signalType: SignalType.hold,
        targetPrice: 35500,
        stopLoss: 34500,
        confidenceScore: 0.65,
        riskLevel: RiskLevel.low,
        strategy: 'Wait and Watch',
        rationale:
            'Consolidation phase. Wait for clear breakout before taking position.',
        generatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        expiresAt: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
  }

  // Fetch market news
  Future<List<MarketNews>> fetchMarketNews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MarketNews(
        id: 'news_1',
        title: 'RBI Maintains Repo Rate at 6.5%',
        summary:
            'Reserve Bank of India keeps key lending rates unchanged, focuses on inflation control.',
        content:
            'The Monetary Policy Committee decided to maintain the status quo on interest rates...',
        source: 'Economic Times',
        sentiment: MarketSentiment.neutral,
        tags: ['RBI', 'Interest Rates', 'Monetary Policy'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        url: 'https://example.com/news/1',
      ),
      MarketNews(
        id: 'news_2',
        title: 'IT Sector Shows Strong Q4 Results',
        summary:
            'Major IT companies report better-than-expected earnings driven by digital transformation deals.',
        content:
            'The Indian IT sector continues to outperform with major players announcing...',
        source: 'Business Standard',
        sentiment: MarketSentiment.bullish,
        tags: ['IT Sector', 'Earnings', 'Growth'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        url: 'https://example.com/news/2',
      ),
      MarketNews(
        id: 'news_3',
        title: 'FII Inflows Reach ₹15,000 Crore This Month',
        summary:
            'Foreign institutional investors show renewed interest in Indian equities.',
        content:
            'Strong macroeconomic indicators and stable government policies attract foreign capital...',
        source: 'Mint',
        sentiment: MarketSentiment.veryBullish,
        tags: ['FII', 'Foreign Investment', 'Market Rally'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        url: 'https://example.com/news/3',
      ),
    ];
  }

  // Fetch user watchlist
  Future<Watchlist> fetchUserWatchlist(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Watchlist(
      id: 'watchlist_$userId',
      userId: userId,
      name: 'My Watchlist',
      indexIds: ['nifty50', 'banknifty', 'niftyit'],
      commodityIds: ['tomato', 'onion', 'rice'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  // Create price alert
  Future<bool> createPriceAlert(PriceAlert alert) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, save to database
    return true;
  }

  // Fetch portfolio impact
  Future<PortfolioImpact> fetchPortfolioImpact(String portfolioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PortfolioImpact(
      portfolioId: portfolioId,
      totalValue: 500000 + _random.nextDouble() * 50000,
      dayChange: (_random.nextDouble() - 0.5) * 10000,
      dayChangePercent: (_random.nextDouble() - 0.5) * 2,
      assetAllocation: {
        'Equities': 60.0,
        'Bonds': 25.0,
        'Commodities': 10.0,
        'Cash': 5.0,
      },
      overallRisk: RiskLevel.medium,
      recommendations: [
        'Consider rebalancing equity allocation',
        'Monitor Bank Nifty exposure',
        'Diversify into defensive sectors',
      ],
      analyzedAt: DateTime.now(),
    );
  }

  void dispose() {
    _updateTimer?.cancel();
    _niftyController.close();
    _bankNiftyController.close();
    _commoditiesController.close();
    _signalsController.close();
  }
}

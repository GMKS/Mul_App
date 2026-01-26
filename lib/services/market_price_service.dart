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
  final _stocksController = StreamController<List<Stock>>.broadcast();
  final _globalMarketsController =
      StreamController<List<GlobalMarket>>.broadcast();
  final _tradeSuggestionsController =
      StreamController<List<TradeSuggestion>>.broadcast();
  final _indicesController = StreamController<List<MarketIndex>>.broadcast();

  Stream<MarketIndex> get niftyStream => _niftyController.stream;
  Stream<MarketIndex> get bankNiftyStream => _bankNiftyController.stream;
  Stream<List<RegionalCommodity>> get commoditiesStream =>
      _commoditiesController.stream;
  Stream<List<TradingSignal>> get signalsStream => _signalsController.stream;
  Stream<List<Stock>> get stocksStream => _stocksController.stream;
  Stream<List<GlobalMarket>> get globalMarketsStream =>
      _globalMarketsController.stream;
  Stream<List<TradeSuggestion>> get tradeSuggestionsStream =>
      _tradeSuggestionsController.stream;
  Stream<List<MarketIndex>> get indicesStream => _indicesController.stream;

  Timer? _updateTimer;
  final Random _random = Random();

  // Start real-time updates (simulated with mock data)
  void startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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

    // Update all indices
    _indicesController.add([
      _generateMockNifty(),
      _generateMockBankNifty(),
      _generateMockIndex('Nifty IT', 'NIFTYIT', IndexType.niftyIt, 38500),
      _generateMockIndex(
          'Nifty Pharma', 'NIFTYPHARMA', IndexType.niftyPharma, 18200),
      _generateMockIndex('Nifty Auto', 'NIFTYAUTO', IndexType.niftyAuto, 23800),
    ]);

    // Update stocks with live data
    _stocksController.add(_generateMockStocks());

    // Update global markets with live data
    _globalMarketsController.add(_generateGlobalMarkets());

    // Update trade suggestions dynamically
    _tradeSuggestionsController.add(_generateTradeSuggestions());

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
      _generateMockIndex('Nifty IT', 'NIFTYIT', IndexType.niftyIt, 37850),
      _generateMockIndex(
          'Nifty Pharma', 'NIFTYPHARMA', IndexType.niftyPharma, 17980),
      _generateMockIndex('Nifty Auto', 'NIFTYAUTO', IndexType.niftyAuto, 23420),
    ];
  }

  MarketIndex _generateMockNifty() {
    final basePrice = 23250.0;
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
    final basePrice = 49850.0;
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
        targetPrice: 23650,
        stopLoss: 23000,
        takeProfit: 24100,
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
        targetPrice: 51200,
        stopLoss: 49200,
        takeProfit: 52500,
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
        targetPrice: 38450,
        stopLoss: 37200,
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

  // Fetch popular stocks
  Future<List<Stock>> fetchPopularStocks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateMockStocks();
  }

  List<Stock> _generateMockStocks() {
    return [
      _generateStock(
          'TCS', 'Tata Consultancy Services', 'NSE', StockSector.it, 4185),
      _generateStock(
          'RELIANCE', 'Reliance Industries', 'NSE', StockSector.energy, 1305),
      _generateStock('HDFCBANK', 'HDFC Bank', 'NSE', StockSector.banking, 1725),
      _generateStock('INFY', 'Infosys', 'NSE', StockSector.it, 1845),
      _generateStock(
          'ICICIBANK', 'ICICI Bank', 'NSE', StockSector.banking, 1285),
      _generateStock(
          'HINDUNILVR', 'Hindustan Unilever', 'NSE', StockSector.fmcg, 2380),
      _generateStock('ITC', 'ITC Limited', 'NSE', StockSector.fmcg, 475),
      _generateStock(
          'SBIN', 'State Bank of India', 'NSE', StockSector.banking, 820),
      _generateStock(
          'BHARTIARTL', 'Bharti Airtel', 'NSE', StockSector.telecom, 1595),
      _generateStock(
          'SUNPHARMA', 'Sun Pharma', 'NSE', StockSector.pharma, 1755),
      _generateStock('MARUTI', 'Maruti Suzuki', 'NSE', StockSector.auto, 12980),
      _generateStock('TITAN', 'Titan Company', 'NSE', StockSector.other, 3720),
      _generateStock('WIPRO', 'Wipro', 'NSE', StockSector.it, 295),
      _generateStock(
          'ASIANPAINT', 'Asian Paints', 'NSE', StockSector.other, 2820),
      _generateStock('TATAMOTORS', 'Tata Motors', 'NSE', StockSector.auto, 780),
    ];
  }

  Stock _generateStock(String symbol, String name, String exchange,
      StockSector sector, double basePrice) {
    final variation = (_random.nextDouble() - 0.5) * (basePrice * 0.04);
    final currentPrice = basePrice + variation;
    final previousClose = basePrice;
    final changeValue = currentPrice - previousClose;
    final changePercent = (changeValue / previousClose) * 100;

    final marketCap = currentPrice * (1000000 + _random.nextInt(5000000));
    final eps = basePrice * 0.05 * (0.8 + _random.nextDouble() * 0.4);
    final pe = currentPrice / eps;

    return Stock(
      id: symbol.toLowerCase(),
      symbol: symbol,
      name: name,
      exchange: exchange,
      sector: sector,
      currentPrice: currentPrice,
      openPrice: basePrice + (_random.nextDouble() * 20 - 10),
      highPrice: currentPrice + _random.nextDouble() * 30,
      lowPrice: currentPrice - _random.nextDouble() * 30,
      previousClose: previousClose,
      changeValue: changeValue,
      changePercent: changePercent,
      volume: 1000000 + _random.nextInt(10000000),
      marketCap: marketCap,
      pe: pe,
      eps: eps,
      bookValue: basePrice * (0.6 + _random.nextDouble() * 0.4),
      week52High: currentPrice * (1.1 + _random.nextDouble() * 0.3),
      week52Low: currentPrice * (0.7 - _random.nextDouble() * 0.2),
      lastUpdated: DateTime.now(),
      historicalData: _generateHistoricalData(basePrice, 30),
      analysis: _generateStockAnalysis(symbol, currentPrice),
      technicals: _generateTechnicalIndicators(currentPrice),
      fundamentals: _generateFundamentals(),
    );
  }

  StockAnalysis _generateStockAnalysis(String symbol, double currentPrice) {
    final signalTypes = [SignalType.strongBuy, SignalType.buy, SignalType.hold];
    final signal = signalTypes[_random.nextInt(signalTypes.length)];
    final targetPrice = currentPrice * (1.08 + _random.nextDouble() * 0.12);
    final upside = ((targetPrice - currentPrice) / currentPrice) * 100;

    return StockAnalysis(
      recommendation: signal,
      targetPrice: targetPrice,
      stopLoss: currentPrice * (0.90 + _random.nextDouble() * 0.05),
      upside: upside,
      confidenceScore: 0.70 + _random.nextDouble() * 0.25,
      analyst: 'AI Trading Bot',
      rationale:
          'Strong fundamentals with positive technical setup. Sector outlook improving.',
      analyzedAt: DateTime.now(),
    );
  }

  TechnicalIndicators _generateTechnicalIndicators(double currentPrice) {
    final rsi = 30 + _random.nextDouble() * 40;
    final trend = rsi > 50
        ? 'bullish'
        : rsi < 40
            ? 'bearish'
            : 'neutral';

    return TechnicalIndicators(
      rsi: rsi,
      macd: (_random.nextDouble() - 0.5) * 10,
      sma20: currentPrice * (0.98 + _random.nextDouble() * 0.04),
      sma50: currentPrice * (0.95 + _random.nextDouble() * 0.06),
      sma200: currentPrice * (0.90 + _random.nextDouble() * 0.10),
      trend: trend,
      signals: _generateTechnicalSignals(rsi),
    );
  }

  List<String> _generateTechnicalSignals(double rsi) {
    final signals = <String>[];
    if (rsi > 70) signals.add('Overbought - Consider profit booking');
    if (rsi < 30) signals.add('Oversold - Potential buying opportunity');
    if (rsi >= 40 && rsi <= 60)
      signals.add('Neutral zone - Wait for confirmation');
    if (_random.nextBool()) signals.add('Golden Cross forming');
    if (_random.nextBool()) signals.add('Volume spike detected');
    return signals;
  }

  FundamentalAnalysis _generateFundamentals() {
    return FundamentalAnalysis(
      roe: 10 + _random.nextDouble() * 15,
      debtToEquity: 0.2 + _random.nextDouble() * 0.8,
      currentRatio: 1.2 + _random.nextDouble() * 0.8,
      dividendYield: 1.0 + _random.nextDouble() * 2.5,
      profitGrowth: 5 + _random.nextDouble() * 20,
      revenueGrowth: 8 + _random.nextDouble() * 15,
      healthScore: 'strong',
    );
  }

  // Fetch global markets
  Future<List<GlobalMarket>> fetchGlobalMarkets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateGlobalMarkets();
  }

  List<GlobalMarket> _generateGlobalMarkets() {
    return [
      _generateGlobalMarket('S&P 500', 'SPX', 'USA', 'USD', 5995),
      _generateGlobalMarket('Dow Jones', 'DJI', 'USA', 'USD', 44565),
      _generateGlobalMarket('NASDAQ', 'IXIC', 'USA', 'USD', 19250),
      _generateGlobalMarket('FTSE 100', 'FTSE', 'UK', 'GBP', 8485),
      _generateGlobalMarket('DAX', 'GDAXI', 'Germany', 'EUR', 20680),
      _generateGlobalMarket('Nikkei 225', 'N225', 'Japan', 'JPY', 38420),
      _generateGlobalMarket('Hang Seng', 'HSI', 'Hong Kong', 'HKD', 18250),
      _generateGlobalMarket('Shanghai Composite', 'SSEC', 'China', 'CNY', 3285),
      _generateGlobalMarket('CAC 40', 'FCHI', 'France', 'EUR', 7820),
      _generateGlobalMarket('ASX 200', 'AXJO', 'Australia', 'AUD', 8180),
    ];
  }

  GlobalMarket _generateGlobalMarket(String name, String symbol, String country,
      String currency, double basePrice) {
    final variation = (_random.nextDouble() - 0.5) * (basePrice * 0.02);
    final currentPrice = basePrice + variation;
    final changeValue = variation;
    final changePercent = (changeValue / basePrice) * 100;

    return GlobalMarket(
      id: symbol.toLowerCase(),
      name: name,
      symbol: symbol,
      country: country,
      currency: currency,
      currentPrice: currentPrice,
      changeValue: changeValue,
      changePercent: changePercent,
      volume: 500000000 + _random.nextInt(1000000000),
      lastUpdated: DateTime.now(),
      isOpen: _isGlobalMarketOpen(country),
      historicalData: _generateHistoricalData(basePrice, 30),
    );
  }

  bool _isGlobalMarketOpen(String country) {
    final now = DateTime.now().toUtc();
    final hour = now.hour;

    // Simplified market hours (UTC)
    switch (country) {
      case 'USA':
        return hour >= 14 && hour < 21; // 9:30 AM - 4:00 PM EST
      case 'UK':
      case 'Germany':
      case 'France':
        return hour >= 8 && hour < 16; // 8:00 AM - 4:30 PM CET
      case 'Japan':
        return hour >= 0 && hour < 6; // 9:00 AM - 3:00 PM JST
      case 'Hong Kong':
      case 'China':
        return hour >= 1 && hour < 8; // 9:30 AM - 4:00 PM HKT
      case 'Australia':
        return hour >= 23 || hour < 6; // 10:00 AM - 4:00 PM AEDT
      default:
        return false;
    }
  }

  // Fetch trade suggestions
  Future<List<TradeSuggestion>> fetchTradeSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateTradeSuggestions();
  }

  List<TradeSuggestion> _generateTradeSuggestions() {
    return [
      TradeSuggestion(
        id: 'trade_1',
        stockSymbol: 'TCS',
        stockName: 'Tata Consultancy Services',
        action: SignalType.buy,
        entryPrice: 4185,
        targetPrice: 4380,
        stopLoss: 4050,
        potentialReturn: 6.49,
        riskLevel: RiskLevel.low,
        timeframe: '2-3 weeks',
        strategy: 'Swing Trading',
        reasons: [
          'Strong Q4 earnings beat expectations',
          'Digital transformation deals pipeline robust',
          'RSI showing bullish divergence',
          'Breaking out of consolidation zone',
        ],
        successProbability: 78.5,
        generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      TradeSuggestion(
        id: 'trade_2',
        stockSymbol: 'RELIANCE',
        stockName: 'Reliance Industries',
        action: SignalType.strongBuy,
        entryPrice: 1305,
        targetPrice: 1420,
        stopLoss: 1265,
        potentialReturn: 7.02,
        riskLevel: RiskLevel.medium,
        timeframe: '1-2 months',
        strategy: 'Position Trading',
        reasons: [
          'Retail and telecom segments showing strong growth',
          'Upcoming new energy projects announcement',
          'FII accumulation pattern visible',
          'Technical breakout above 200-day MA',
        ],
        successProbability: 82.0,
        generatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        expiresAt: DateTime.now().add(const Duration(days: 14)),
      ),
      TradeSuggestion(
        id: 'trade_3',
        stockSymbol: 'HDFCBANK',
        stockName: 'HDFC Bank',
        action: SignalType.buy,
        entryPrice: 1725,
        targetPrice: 1820,
        stopLoss: 1680,
        potentialReturn: 6.06,
        riskLevel: RiskLevel.low,
        timeframe: '3-4 weeks',
        strategy: 'Value Investing',
        reasons: [
          'Merger synergies starting to show results',
          'Asset quality metrics improving',
          'Attractive valuation compared to peers',
          'Strong institutional support',
        ],
        successProbability: 75.5,
        generatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        expiresAt: DateTime.now().add(const Duration(days: 10)),
      ),
      TradeSuggestion(
        id: 'trade_4',
        stockSymbol: 'INFY',
        stockName: 'Infosys',
        action: SignalType.buy,
        entryPrice: 1845,
        targetPrice: 1950,
        stopLoss: 1795,
        potentialReturn: 6.33,
        riskLevel: RiskLevel.medium,
        timeframe: '2-3 weeks',
        strategy: 'Momentum Trading',
        reasons: [
          'Large deal wins in BFSI sector',
          'Margin expansion guidance maintained',
          'Volume surge with price breakout',
          'Positive management commentary',
        ],
        successProbability: 73.0,
        generatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      TradeSuggestion(
        id: 'trade_5',
        stockSymbol: 'MARUTI',
        stockName: 'Maruti Suzuki',
        action: SignalType.strongBuy,
        entryPrice: 12980,
        targetPrice: 13850,
        stopLoss: 12680,
        potentialReturn: 6.67,
        riskLevel: RiskLevel.medium,
        timeframe: '1-2 months',
        strategy: 'Sectoral Play',
        reasons: [
          'Auto sector recovery gaining momentum',
          'New model launches planned',
          'Rural demand showing signs of revival',
          'Technical pattern suggests bullish continuation',
        ],
        successProbability: 80.0,
        generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 14)),
      ),
    ];
  }

  // Search stocks
  Future<List<Stock>> searchStocks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allStocks = _generateMockStocks();
    return allStocks
        .where((stock) =>
            stock.name.toLowerCase().contains(query.toLowerCase()) ||
            stock.symbol.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

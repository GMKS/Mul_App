import 'dart:async';
import 'package:flutter/material.dart';
import '../models/market_price_model.dart';
import '../services/market_price_service.dart';
import '../widgets/market_price_widgets.dart';

/// Market Prices Screen
/// Main screen for viewing market indices, commodities, trading signals, and news
class MarketPricesScreen extends StatefulWidget {
  final String? userCity;

  const MarketPricesScreen({Key? key, this.userCity}) : super(key: key);

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen>
    with TickerProviderStateMixin {
  final MarketPriceService _service = MarketPriceService();
  late TabController _tabController;

  List<MarketIndex> _indices = [];
  List<RegionalCommodity> _commodities = [];
  List<TradingSignal> _signals = [];
  List<MarketNews> _news = [];
  List<Stock> _stocks = [];
  List<GlobalMarket> _globalMarkets = [];
  List<TradeSuggestion> _tradeSuggestions = [];

  bool _isLoading = true;
  StreamSubscription? _niftySubscription;
  StreamSubscription? _bankNiftySubscription;
  StreamSubscription? _indicesSubscription;
  StreamSubscription? _stocksSubscription;
  StreamSubscription? _globalMarketsSubscription;
  StreamSubscription? _tradeSuggestionsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _niftySubscription?.cancel();
    _bankNiftySubscription?.cancel();
    _indicesSubscription?.cancel();
    _stocksSubscription?.cancel();
    _globalMarketsSubscription?.cancel();
    _tradeSuggestionsSubscription?.cancel();
    _service.stopRealTimeUpdates();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _service.fetchMarketIndices(),
        _service.fetchRegionalCommodities(widget.userCity ?? 'Hyderabad'),
        _service.fetchTradingSignals(),
        _service.fetchMarketNews(),
        _service.fetchPopularStocks(),
        _service.fetchGlobalMarkets(),
        _service.fetchTradeSuggestions(),
      ]);

      setState(() {
        _indices = results[0] as List<MarketIndex>;
        _commodities = results[1] as List<RegionalCommodity>;
        _signals = results[2] as List<TradingSignal>;
        _news = results[3] as List<MarketNews>;
        _stocks = results[4] as List<Stock>;
        _globalMarkets = results[5] as List<GlobalMarket>;
        _tradeSuggestions = results[6] as List<TradeSuggestion>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _startRealTimeUpdates() {
    _service.startRealTimeUpdates();

    // Listen to all indices updates
    _indicesSubscription = _service.indicesStream.listen((indices) {
      if (mounted) {
        setState(() {
          _indices = indices;
        });
      }
    });

    // Listen to stocks updates
    _stocksSubscription = _service.stocksStream.listen((stocks) {
      if (mounted) {
        setState(() {
          _stocks = stocks;
        });
      }
    });

    // Listen to global markets updates
    _globalMarketsSubscription = _service.globalMarketsStream.listen((markets) {
      if (mounted) {
        setState(() {
          _globalMarkets = markets;
        });
      }
    });

    // Listen to trade suggestions updates (dynamic based on stock performance)
    _tradeSuggestionsSubscription =
        _service.tradeSuggestionsStream.listen((suggestions) {
      if (mounted) {
        setState(() {
          _tradeSuggestions = suggestions;
        });
      }
    });

    // Keep individual index streams for backwards compatibility
    _niftySubscription = _service.niftyStream.listen((index) {
      if (mounted) {
        setState(() {
          final idx = _indices.indexWhere((i) => i.id == 'nifty50');
          if (idx != -1) {
            _indices[idx] = index;
          }
        });
      }
    });

    _bankNiftySubscription = _service.bankNiftyStream.listen((index) {
      if (mounted) {
        setState(() {
          final idx = _indices.indexWhere((i) => i.id == 'banknifty');
          if (idx != -1) {
            _indices[idx] = index;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        title: Row(
          children: [
            Flexible(
              child: const Text(
                'Market Prices',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: _showAlertSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Indices', icon: Icon(Icons.trending_up, size: 18)),
            Tab(text: 'Stocks', icon: Icon(Icons.show_chart, size: 18)),
            Tab(text: 'Global', icon: Icon(Icons.public, size: 18)),
            Tab(text: 'Trades', icon: Icon(Icons.lightbulb_outline, size: 18)),
            Tab(
                text: 'Commodities',
                icon: Icon(Icons.shopping_basket, size: 18)),
            Tab(text: 'Signals', icon: Icon(Icons.analytics, size: 18)),
            Tab(text: 'News', icon: Icon(Icons.newspaper, size: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIndicesTab(),
                _buildStocksTab(),
                _buildGlobalMarketsTab(),
                _buildTradeSuggestionsTab(),
                _buildCommoditiesTab(),
                _buildSignalsTab(),
                _buildNewsTab(),
              ],
            ),
    );
  }

  Widget _buildIndicesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Market Status Banner
          _buildMarketStatusBanner(),

          const SizedBox(height: 16),

          // AI Analytics Section
          _buildAIAnalyticsSection(),

          const SizedBox(height: 16),

          // Indices List
          ..._indices.map((index) => MarketIndexCard(
                index: index,
                onTap: () => _showIndexDetails(index),
              )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMarketStatusBanner() {
    final isOpen = _indices.isNotEmpty ? _indices.first.isMarketOpen : false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.green[700]!, Colors.green[500]!]
              : [Colors.red[700]!, Colors.red[500]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.access_time : Icons.schedule,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Market is Open' : 'Market is Closed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOpen
                      ? 'Live updates are active'
                      : 'Will reopen on next trading day',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOpen ? Colors.greenAccent : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isOpen ? Colors.greenAccent : Colors.white,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalyticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[300], size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Market Analysis',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Market sentiment is moderately bullish with strong technicals. AI models predict continued upward momentum in banking and IT sectors.',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSentimentChip('Bullish', Colors.green),
              const SizedBox(width: 8),
              _buildSentimentChip('Confidence: 78%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCommoditiesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.userCity ?? "Hyderabad"} Market Prices',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ..._commodities.map((commodity) => CommodityCard(
                commodity: commodity,
                onTap: () => _showCommodityDetails(commodity),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[900]?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[700]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[300], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These signals are AI-generated and for informational purposes only.',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._signals.map((signal) => TradingSignalCard(
                signal: signal,
                onTap: () => _showSignalDetails(signal),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ..._news.map((news) => MarketNewsCard(
                news: news,
                onTap: () => _showNewsDetails(news),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showIndexDetails(MarketIndex index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                index.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                index.symbol,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Price',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹${index.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (index.isPositive ? Colors.green : Colors.red)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              index.isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  index.isPositive ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            Text(
                              '${index.changePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: index.isPositive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${index.changeValue.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: index.isPositive ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              _buildDetailRow('Open', '₹${index.openPrice.toStringAsFixed(2)}'),
              _buildDetailRow('High', '₹${index.highPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Low', '₹${index.lowPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Previous Close',
                  '₹${index.previousClose.toStringAsFixed(2)}'),
              _buildDetailRow('Volume', index.volume.toString()),
              if (index.prediction != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'AI Prediction',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Predicted Price',
                  '₹${index.prediction!.predictedPrice.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Confidence',
                  '${(index.prediction!.confidenceScore * 100).toStringAsFixed(0)}%',
                ),
                _buildDetailRow('Timeframe', index.prediction!.timeframe),
              ],
              if (index.expertCommentary != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Expert Commentary',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  index.expertCommentary!,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
              if (index.historicalData.isNotEmpty) ...[
                const SizedBox(height: 24),
                PriceChartWidget(
                  data: index.historicalData,
                  title: '30-Day Price History',
                  lineColor: index.isPositive ? Colors.green : Colors.red,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _createAlert(index.name, index.currentPrice);
                  },
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Create Price Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommodityDetails(RegionalCommodity commodity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commodity.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          commodity.localName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${commodity.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'per ${commodity.unit}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              _buildDetailRow('Market', commodity.market),
              _buildDetailRow('City', commodity.city),
              _buildDetailRow(
                  'Category', commodity.category.toString().split('.').last),
              _buildDetailRow('Previous Price',
                  '₹${commodity.previousPrice.toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Change', '${commodity.changePercent.toStringAsFixed(2)}%'),
              if (commodity.priceHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                PriceChartWidget(
                  data: commodity.priceHistory,
                  title: '30-Day Price History',
                  lineColor: commodity.isPriceUp ? Colors.green : Colors.red,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSignalDetails(TradingSignal signal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          signal.assetName,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: signal.signalColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: signal.signalColor),
              ),
              child: Text(
                signal.signalType.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: signal.signalColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Strategy: ${signal.strategy}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              signal.rationale,
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Target Price', '₹${signal.targetPrice}'),
            _buildDetailRow('Stop Loss', '₹${signal.stopLoss}'),
            if (signal.takeProfit != null)
              _buildDetailRow('Take Profit', '₹${signal.takeProfit}'),
            _buildDetailRow('Confidence',
                '${(signal.confidenceScore * 100).toStringAsFixed(0)}%'),
            _buildDetailRow(
                'Risk Level', signal.riskLevel.toString().split('.').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNewsDetails(MarketNews news) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                news.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    news.source,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    news.publishedAt.toString().split(' ')[0],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                news.content,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              if (news.tags.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: news.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[900]?.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _createAlert(String assetName, double currentPrice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Create Price Alert',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get notified when $assetName reaches your target price',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Price',
                hintText: currentPrice.toStringAsFixed(2),
                prefixText: '₹',
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Price alert created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  void _showAlertSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Alert Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Manage your price alerts and notification preferences',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Stocks Tab
  Widget _buildStocksTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Live indicator banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Updates Every 3 Seconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ],
            ),
          ),
          // Header with stock count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Top Stocks',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_stocks.length} stocks',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stocks list
          ..._stocks.map((stock) => _buildStockCard(stock)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStockCard(Stock stock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stock.isPositive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showStockDetails(stock),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.name,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${stock.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          stock.isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: stock.performanceColor,
                          size: 16,
                        ),
                        Text(
                          '${stock.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: stock.performanceColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStockMetric('P/E', stock.pe.toStringAsFixed(2)),
                _buildStockMetric('EPS', '₹${stock.eps.toStringAsFixed(2)}'),
                _buildStockMetric('Vol', _formatVolume(stock.volume)),
                if (stock.analysis != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSignalColor(stock.analysis!.recommendation)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getSignalText(stock.analysis!.recommendation),
                      style: TextStyle(
                        color: _getSignalColor(stock.analysis!.recommendation),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 10000000) {
      return '${(volume / 10000000).toStringAsFixed(1)}Cr';
    } else if (volume >= 100000) {
      return '${(volume / 100000).toStringAsFixed(1)}L';
    }
    return '${(volume / 1000).toStringAsFixed(1)}K';
  }

  void _showStockDetails(Stock stock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                stock.symbol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stock.name,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${stock.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            stock.isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: stock.performanceColor,
                            size: 18,
                          ),
                          Text(
                            '${stock.changePercent.toStringAsFixed(2)}% (₹${stock.changeValue.toStringAsFixed(2)})',
                            style: TextStyle(
                              color: stock.performanceColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),

              // Key Metrics
              Text(
                'Key Metrics',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Market Cap',
                  '₹${(stock.marketCap / 10000000).toStringAsFixed(2)} Cr'),
              _buildDetailRow('P/E Ratio', stock.pe.toStringAsFixed(2)),
              _buildDetailRow('EPS', '₹${stock.eps.toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Book Value', '₹${stock.bookValue.toStringAsFixed(2)}'),
              _buildDetailRow(
                  '52W High', '₹${stock.week52High.toStringAsFixed(2)}'),
              _buildDetailRow(
                  '52W Low', '₹${stock.week52Low.toStringAsFixed(2)}'),
              _buildDetailRow('Volume', _formatVolume(stock.volume)),

              // Analysis
              if (stock.analysis != null) ...[
                const SizedBox(height: 24),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Analyst Recommendation',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSignalColor(stock.analysis!.recommendation)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSignalText(stock.analysis!.recommendation),
                        style: TextStyle(
                          color:
                              _getSignalColor(stock.analysis!.recommendation),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Target Price',
                    '₹${stock.analysis!.targetPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Stop Loss',
                    '₹${stock.analysis!.stopLoss.toStringAsFixed(2)}'),
                _buildDetailRow(
                    'Upside', '${stock.analysis!.upside.toStringAsFixed(2)}%'),
                _buildDetailRow('Confidence',
                    '${(stock.analysis!.confidenceScore * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 12),
                Text(
                  stock.analysis!.rationale,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _createAlert(stock.name, stock.currentPrice);
                  },
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Create Price Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Global Markets Tab
  Widget _buildGlobalMarketsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Live indicator banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[500]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Real-time Global Market Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.public, color: Colors.white, size: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Global Indices',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._globalMarkets.map((market) => _buildGlobalMarketCard(market)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildGlobalMarketCard(GlobalMarket market) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: market.isPositive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          market.country,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: market.isOpen ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          market.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: market.isOpen ? Colors.green : Colors.red,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${market.currency} ${market.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        market.isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: market.isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        '${market.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: market.isPositive ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Trade Suggestions Tab
  Widget _buildTradeSuggestionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Live AI indicator banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[700]!, Colors.orange[500]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Suggestions Updated Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.psychology, color: Colors.white, size: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Trade Suggestions',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI-powered trading recommendations based on live market data, technical and fundamental analysis',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._tradeSuggestions
              .map((suggestion) => _buildTradeSuggestionCard(suggestion)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTradeSuggestionCard(TradeSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSignalColor(suggestion.action).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.stockSymbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      suggestion.stockName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSignalColor(suggestion.action).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSignalText(suggestion.action),
                  style: TextStyle(
                    color: _getSignalColor(suggestion.action),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Key Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTradeMetic(
                  'Entry', '₹${suggestion.entryPrice.toStringAsFixed(2)}'),
              _buildTradeMetic(
                  'Target', '₹${suggestion.targetPrice.toStringAsFixed(2)}'),
              _buildTradeMetic(
                  'Stop Loss', '₹${suggestion.stopLoss.toStringAsFixed(2)}'),
              _buildTradeMetic('Return',
                  '+${suggestion.potentialReturn.toStringAsFixed(1)}%'),
            ],
          ),

          const SizedBox(height: 16),

          // Strategy and Timeframe
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                suggestion.timeframe,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.trending_up, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                suggestion.strategy,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Success Probability
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Probability',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: suggestion.successProbability / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSignalColor(suggestion.action),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${suggestion.successProbability.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getSignalColor(suggestion.action),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),

          // Reasons
          Text(
            'Key Reasons:',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...suggestion.reasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTradeMetic(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(SignalType signal) {
    switch (signal) {
      case SignalType.strongBuy:
        return Colors.green[700]!;
      case SignalType.buy:
        return Colors.green;
      case SignalType.hold:
        return Colors.orange;
      case SignalType.sell:
        return Colors.red;
      case SignalType.strongSell:
        return Colors.red[700]!;
    }
  }

  String _getSignalText(SignalType signal) {
    switch (signal) {
      case SignalType.strongBuy:
        return 'STRONG BUY';
      case SignalType.buy:
        return 'BUY';
      case SignalType.hold:
        return 'HOLD';
      case SignalType.sell:
        return 'SELL';
      case SignalType.strongSell:
        return 'STRONG SELL';
    }
  }
}

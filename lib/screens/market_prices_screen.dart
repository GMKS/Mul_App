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

  bool _isLoading = true;
  StreamSubscription? _niftySubscription;
  StreamSubscription? _bankNiftySubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _niftySubscription?.cancel();
    _bankNiftySubscription?.cancel();
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
      ]);

      setState(() {
        _indices = results[0] as List<MarketIndex>;
        _commodities = results[1] as List<RegionalCommodity>;
        _signals = results[2] as List<TradingSignal>;
        _news = results[3] as List<MarketNews>;
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

    _niftySubscription = _service.niftyStream.listen((index) {
      setState(() {
        final idx = _indices.indexWhere((i) => i.id == 'nifty50');
        if (idx != -1) {
          _indices[idx] = index;
        }
      });
    });

    _bankNiftySubscription = _service.bankNiftyStream.listen((index) {
      setState(() {
        final idx = _indices.indexWhere((i) => i.id == 'banknifty');
        if (idx != -1) {
          _indices[idx] = index;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        title: const Text(
          'Market Prices',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          tabs: const [
            Tab(text: 'Indices', icon: Icon(Icons.trending_up, size: 20)),
            Tab(
                text: 'Commodities',
                icon: Icon(Icons.shopping_basket, size: 20)),
            Tab(text: 'Signals', icon: Icon(Icons.analytics, size: 20)),
            Tab(text: 'News', icon: Icon(Icons.newspaper, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIndicesTab(),
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
}

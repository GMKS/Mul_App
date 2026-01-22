/// Market Price Widgets
/// Reusable widgets for displaying market data

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/market_price_model.dart';

// Market Index Card Widget
class MarketIndexCard extends StatelessWidget {
  final MarketIndex index;
  final VoidCallback? onTap;

  const MarketIndexCard({
    super.key,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index.symbol,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (!index.isMarketOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'CLOSED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${index.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            index.isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: index.isPositive ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${index.changeValue.toStringAsFixed(2)} (${index.changePercent.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color:
                                  index.isPositive ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Mini chart
                  if (index.historicalData.isNotEmpty)
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: _buildMiniChart(index),
                    ),
                ],
              ),
              if (index.prediction != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.auto_graph, color: Colors.blue[300], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'AI Prediction: ₹${index.prediction!.predictedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(index.prediction!.confidenceScore * 100).toStringAsFixed(0)}% confidence',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChart(MarketIndex index) {
    final spots = index.historicalData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: index.isPositive ? Colors.green : Colors.red,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (index.isPositive ? Colors.green : Colors.red)
                  .withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// Commodity Card Widget
class CommodityCard extends StatelessWidget {
  final RegionalCommodity commodity;
  final VoidCallback? onTap;

  const CommodityCard({
    super.key,
    required this.commodity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commodity.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      commodity.localName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commodity.market,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'per ${commodity.unit}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        commodity.isPriceUp
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: commodity.isPriceUp ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      Text(
                        '${commodity.changePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color:
                              commodity.isPriceUp ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (commodity.category) {
      case CommodityCategory.grains:
        return Colors.amber;
      case CommodityCategory.vegetables:
        return Colors.green;
      case CommodityCategory.fruits:
        return Colors.orange;
      case CommodityCategory.pulses:
        return Colors.brown;
      case CommodityCategory.spices:
        return Colors.red;
      case CommodityCategory.metals:
        return Colors.grey;
      case CommodityCategory.energy:
        return Colors.blue;
      case CommodityCategory.livestock:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon() {
    switch (commodity.category) {
      case CommodityCategory.grains:
        return Icons.grain;
      case CommodityCategory.vegetables:
        return Icons.eco;
      case CommodityCategory.fruits:
        return Icons.apple;
      case CommodityCategory.pulses:
        return Icons.rice_bowl;
      case CommodityCategory.spices:
        return Icons.local_fire_department;
      case CommodityCategory.metals:
        return Icons.construction;
      case CommodityCategory.energy:
        return Icons.bolt;
      case CommodityCategory.livestock:
        return Icons.pets;
    }
  }
}

// Trading Signal Card Widget
class TradingSignalCard extends StatelessWidget {
  final TradingSignal signal;
  final VoidCallback? onTap;

  const TradingSignalCard({
    super.key,
    required this.signal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          signal.assetName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          signal.strategy,
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
                      color: signal.signalColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: signal.signalColor, width: 1),
                    ),
                    child: Text(
                      _getSignalText(),
                      style: TextStyle(
                        color: signal.signalColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                signal.rationale,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                        'Target',
                        '₹${signal.targetPrice.toStringAsFixed(0)}',
                        Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip('Stop Loss',
                        '₹${signal.stopLoss.toStringAsFixed(0)}', Colors.red),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                        'Confidence',
                        '${(signal.confidenceScore * 100).toStringAsFixed(0)}%',
                        Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getSignalText() {
    switch (signal.signalType) {
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

// Market News Card Widget
class MarketNewsCard extends StatelessWidget {
  final MarketNews news;
  final VoidCallback? onTap;

  const MarketNewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSentimentColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getSentimentText(),
                            style: TextStyle(
                              color: _getSentimentColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          news.source,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeAgo(),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.summary,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (news.imageUrl != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    news.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor() {
    switch (news.sentiment) {
      case MarketSentiment.veryBullish:
        return Colors.green[700]!;
      case MarketSentiment.bullish:
        return Colors.green;
      case MarketSentiment.neutral:
        return Colors.grey;
      case MarketSentiment.bearish:
        return Colors.red;
      case MarketSentiment.veryBearish:
        return Colors.red[700]!;
    }
  }

  String _getSentimentText() {
    switch (news.sentiment) {
      case MarketSentiment.veryBullish:
        return 'V.BULLISH';
      case MarketSentiment.bullish:
        return 'BULLISH';
      case MarketSentiment.neutral:
        return 'NEUTRAL';
      case MarketSentiment.bearish:
        return 'BEARISH';
      case MarketSentiment.veryBearish:
        return 'V.BEARISH';
    }
  }

  String _getTimeAgo() {
    final difference = DateTime.now().difference(news.publishedAt);
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Price Chart Widget
class PriceChartWidget extends StatelessWidget {
  final List<PricePoint> data;
  final String title;
  final Color lineColor;

  const PriceChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    final minY = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[800]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY * 0.99,
                maxY: maxY * 1.01,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

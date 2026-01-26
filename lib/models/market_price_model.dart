/// Market Prices Data Models
/// Comprehensive models for market indices, commodities, predictions, and trading

import 'package:flutter/material.dart';

// Market Index Types
enum IndexType {
  nifty50,
  bankNifty,
  niftyIt,
  niftyPharma,
  niftyAuto,
  sensex,
  other,
}

// Commodity Categories
enum CommodityCategory {
  grains,
  vegetables,
  fruits,
  pulses,
  spices,
  metals,
  energy,
  livestock,
}

// Trade Signal Types
enum SignalType {
  buy,
  sell,
  hold,
  strongBuy,
  strongSell,
}

// Risk Level
enum RiskLevel {
  low,
  medium,
  high,
  veryHigh,
}

// Market Sentiment
enum MarketSentiment {
  bullish,
  bearish,
  neutral,
  veryBullish,
  veryBearish,
}

// Market Index Model
class MarketIndex {
  final String id;
  final IndexType type;
  final String name;
  final String symbol;
  final double currentPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double previousClose;
  final double changeValue;
  final double changePercent;
  final int volume;
  final DateTime lastUpdated;
  final bool isMarketOpen;
  final List<PricePoint> historicalData;
  final AIPrediction? prediction;
  final MarketSentiment sentiment;
  final String? expertCommentary;

  MarketIndex({
    required this.id,
    required this.type,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.previousClose,
    required this.changeValue,
    required this.changePercent,
    required this.volume,
    required this.lastUpdated,
    required this.isMarketOpen,
    this.historicalData = const [],
    this.prediction,
    required this.sentiment,
    this.expertCommentary,
  });

  bool get isPositive => changePercent > 0;

  Color get sentimentColor {
    switch (sentiment) {
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

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      id: json['id'] ?? '',
      type: IndexType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => IndexType.other,
      ),
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      openPrice: (json['openPrice'] ?? 0).toDouble(),
      highPrice: (json['highPrice'] ?? 0).toDouble(),
      lowPrice: (json['lowPrice'] ?? 0).toDouble(),
      previousClose: (json['previousClose'] ?? 0).toDouble(),
      changeValue: (json['changeValue'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isMarketOpen: json['isMarketOpen'] ?? false,
      historicalData: (json['historicalData'] as List?)
              ?.map((e) => PricePoint.fromJson(e))
              .toList() ??
          [],
      prediction: json['prediction'] != null
          ? AIPrediction.fromJson(json['prediction'])
          : null,
      sentiment: MarketSentiment.values.firstWhere(
        (e) => e.toString() == json['sentiment'],
        orElse: () => MarketSentiment.neutral,
      ),
      expertCommentary: json['expertCommentary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'symbol': symbol,
      'currentPrice': currentPrice,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'previousClose': previousClose,
      'changeValue': changeValue,
      'changePercent': changePercent,
      'volume': volume,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isMarketOpen': isMarketOpen,
      'historicalData': historicalData.map((e) => e.toJson()).toList(),
      'prediction': prediction?.toJson(),
      'sentiment': sentiment.toString(),
      'expertCommentary': expertCommentary,
    };
  }
}

// Price Point for Charts
class PricePoint {
  final DateTime timestamp;
  final double price;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;

  PricePoint({
    required this.timestamp,
    required this.price,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      timestamp: DateTime.parse(json['timestamp']),
      price: (json['price'] ?? 0).toDouble(),
      open: json['open'] != null ? (json['open'] as num).toDouble() : null,
      high: json['high'] != null ? (json['high'] as num).toDouble() : null,
      low: json['low'] != null ? (json['low'] as num).toDouble() : null,
      close: json['close'] != null ? (json['close'] as num).toDouble() : null,
      volume: json['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'price': price,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}

// AI Prediction Model
class AIPrediction {
  final String id;
  final double predictedPrice;
  final double confidenceScore;
  final String timeframe;
  final List<PricePoint> forecastPoints;
  final Map<String, dynamic> indicators;
  final String model;
  final DateTime generatedAt;

  AIPrediction({
    required this.id,
    required this.predictedPrice,
    required this.confidenceScore,
    required this.timeframe,
    this.forecastPoints = const [],
    this.indicators = const {},
    required this.model,
    required this.generatedAt,
  });

  factory AIPrediction.fromJson(Map<String, dynamic> json) {
    return AIPrediction(
      id: json['id'] ?? '',
      predictedPrice: (json['predictedPrice'] ?? 0).toDouble(),
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      timeframe: json['timeframe'] ?? '',
      forecastPoints: (json['forecastPoints'] as List?)
              ?.map((e) => PricePoint.fromJson(e))
              .toList() ??
          [],
      indicators: json['indicators'] ?? {},
      model: json['model'] ?? 'AI-ML',
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predictedPrice': predictedPrice,
      'confidenceScore': confidenceScore,
      'timeframe': timeframe,
      'forecastPoints': forecastPoints.map((e) => e.toJson()).toList(),
      'indicators': indicators,
      'model': model,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

// Regional Commodity Model
class RegionalCommodity {
  final String id;
  final String name;
  final String localName;
  final CommodityCategory category;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final String unit;
  final String market;
  final String city;
  final String state;
  final DateTime lastUpdated;
  final List<PricePoint> priceHistory;
  final String? imageUrl;

  RegionalCommodity({
    required this.id,
    required this.name,
    required this.localName,
    required this.category,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
    required this.unit,
    required this.market,
    required this.city,
    required this.state,
    required this.lastUpdated,
    this.priceHistory = const [],
    this.imageUrl,
  });

  bool get isPriceUp => changePercent > 0;

  factory RegionalCommodity.fromJson(Map<String, dynamic> json) {
    return RegionalCommodity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      localName: json['localName'] ?? '',
      category: CommodityCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => CommodityCategory.vegetables,
      ),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      previousPrice: (json['previousPrice'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      market: json['market'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated']),
      priceHistory: (json['priceHistory'] as List?)
              ?.map((e) => PricePoint.fromJson(e))
              .toList() ??
          [],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'localName': localName,
      'category': category.toString(),
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'changePercent': changePercent,
      'unit': unit,
      'market': market,
      'city': city,
      'state': state,
      'lastUpdated': lastUpdated.toIso8601String(),
      'priceHistory': priceHistory.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
    };
  }
}

// Price Alert Model
class PriceAlert {
  final String id;
  final String userId;
  final String assetId;
  final String assetName;
  final String assetType; // 'index' or 'commodity'
  final double targetPrice;
  final String condition; // 'above', 'below'
  final bool isActive;
  final bool isTriggered;
  final DateTime createdAt;
  final DateTime? triggeredAt;

  PriceAlert({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.targetPrice,
    required this.condition,
    this.isActive = true,
    this.isTriggered = false,
    required this.createdAt,
    this.triggeredAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      assetType: json['assetType'] ?? '',
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'above',
      isActive: json['isActive'] ?? true,
      isTriggered: json['isTriggered'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.parse(json['triggeredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'assetId': assetId,
      'assetName': assetName,
      'assetType': assetType,
      'targetPrice': targetPrice,
      'condition': condition,
      'isActive': isActive,
      'isTriggered': isTriggered,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
    };
  }
}

// Trading Signal Model
class TradingSignal {
  final String id;
  final String assetId;
  final String assetName;
  final SignalType signalType;
  final double targetPrice;
  final double stopLoss;
  final double? takeProfit;
  final double confidenceScore;
  final RiskLevel riskLevel;
  final String strategy;
  final String rationale;
  final DateTime generatedAt;
  final DateTime expiresAt;

  TradingSignal({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.signalType,
    required this.targetPrice,
    required this.stopLoss,
    this.takeProfit,
    required this.confidenceScore,
    required this.riskLevel,
    required this.strategy,
    required this.rationale,
    required this.generatedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Color get signalColor {
    switch (signalType) {
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

  factory TradingSignal.fromJson(Map<String, dynamic> json) {
    return TradingSignal(
      id: json['id'] ?? '',
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      signalType: SignalType.values.firstWhere(
        (e) => e.toString() == json['signalType'],
        orElse: () => SignalType.hold,
      ),
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      takeProfit: json['takeProfit'] != null
          ? (json['takeProfit'] as num).toDouble()
          : null,
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == json['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      strategy: json['strategy'] ?? '',
      rationale: json['rationale'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'signalType': signalType.toString(),
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel.toString(),
      'strategy': strategy,
      'rationale': rationale,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

// Market News Model
class MarketNews {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String source;
  final String? imageUrl;
  final List<String> tags;
  final MarketSentiment sentiment;
  final DateTime publishedAt;
  final String url;

  MarketNews({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.source,
    this.imageUrl,
    this.tags = const [],
    required this.sentiment,
    required this.publishedAt,
    required this.url,
  });

  factory MarketNews.fromJson(Map<String, dynamic> json) {
    return MarketNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      sentiment: MarketSentiment.values.firstWhere(
        (e) => e.toString() == json['sentiment'],
        orElse: () => MarketSentiment.neutral,
      ),
      publishedAt: DateTime.parse(json['publishedAt']),
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'source': source,
      'imageUrl': imageUrl,
      'tags': tags,
      'sentiment': sentiment.toString(),
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
    };
  }
}

// User Watchlist Model
class Watchlist {
  final String id;
  final String userId;
  final String name;
  final List<String> indexIds;
  final List<String> commodityIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Watchlist({
    required this.id,
    required this.userId,
    required this.name,
    this.indexIds = const [],
    this.commodityIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'My Watchlist',
      indexIds: List<String>.from(json['indexIds'] ?? []),
      commodityIds: List<String>.from(json['commodityIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'indexIds': indexIds,
      'commodityIds': commodityIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Portfolio Impact Analysis
class PortfolioImpact {
  final String portfolioId;
  final double totalValue;
  final double dayChange;
  final double dayChangePercent;
  final Map<String, double> assetAllocation;
  final RiskLevel overallRisk;
  final List<String> recommendations;
  final DateTime analyzedAt;

  PortfolioImpact({
    required this.portfolioId,
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    this.assetAllocation = const {},
    required this.overallRisk,
    this.recommendations = const [],
    required this.analyzedAt,
  });

  factory PortfolioImpact.fromJson(Map<String, dynamic> json) {
    return PortfolioImpact(
      portfolioId: json['portfolioId'] ?? '',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      dayChange: (json['dayChange'] ?? 0).toDouble(),
      dayChangePercent: (json['dayChangePercent'] ?? 0).toDouble(),
      assetAllocation: Map<String, double>.from(json['assetAllocation'] ?? {}),
      overallRisk: RiskLevel.values.firstWhere(
        (e) => e.toString() == json['overallRisk'],
        orElse: () => RiskLevel.medium,
      ),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioId': portfolioId,
      'totalValue': totalValue,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'assetAllocation': assetAllocation,
      'overallRisk': overallRisk.toString(),
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

// Stock Sector
enum StockSector {
  banking,
  it,
  pharma,
  fmcg,
  auto,
  energy,
  metals,
  realty,
  media,
  telecom,
  other,
}

// Stock Model
class Stock {
  final String id;
  final String symbol;
  final String name;
  final String exchange; // 'NSE' or 'BSE'
  final StockSector sector;
  final double currentPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double previousClose;
  final double changeValue;
  final double changePercent;
  final int volume;
  final double marketCap;
  final double pe;
  final double eps;
  final double bookValue;
  final double week52High;
  final double week52Low;
  final DateTime lastUpdated;
  final List<PricePoint> historicalData;
  final StockAnalysis? analysis;
  final TechnicalIndicators? technicals;
  final FundamentalAnalysis? fundamentals;

  Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.sector,
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.previousClose,
    required this.changeValue,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.pe,
    required this.eps,
    required this.bookValue,
    required this.week52High,
    required this.week52Low,
    required this.lastUpdated,
    this.historicalData = const [],
    this.analysis,
    this.technicals,
    this.fundamentals,
  });

  bool get isPositive => changePercent > 0;

  Color get performanceColor {
    if (changePercent >= 3) return Colors.green[700]!;
    if (changePercent > 0) return Colors.green;
    if (changePercent <= -3) return Colors.red[700]!;
    return Colors.red;
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'] ?? 'NSE',
      sector: StockSector.values.firstWhere(
        (e) => e.toString() == json['sector'],
        orElse: () => StockSector.other,
      ),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      openPrice: (json['openPrice'] ?? 0).toDouble(),
      highPrice: (json['highPrice'] ?? 0).toDouble(),
      lowPrice: (json['lowPrice'] ?? 0).toDouble(),
      previousClose: (json['previousClose'] ?? 0).toDouble(),
      changeValue: (json['changeValue'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      marketCap: (json['marketCap'] ?? 0).toDouble(),
      pe: (json['pe'] ?? 0).toDouble(),
      eps: (json['eps'] ?? 0).toDouble(),
      bookValue: (json['bookValue'] ?? 0).toDouble(),
      week52High: (json['week52High'] ?? 0).toDouble(),
      week52Low: (json['week52Low'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      historicalData: (json['historicalData'] as List?)
              ?.map((e) => PricePoint.fromJson(e))
              .toList() ??
          [],
      analysis: json['analysis'] != null
          ? StockAnalysis.fromJson(json['analysis'])
          : null,
      technicals: json['technicals'] != null
          ? TechnicalIndicators.fromJson(json['technicals'])
          : null,
      fundamentals: json['fundamentals'] != null
          ? FundamentalAnalysis.fromJson(json['fundamentals'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'exchange': exchange,
      'sector': sector.toString(),
      'currentPrice': currentPrice,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'previousClose': previousClose,
      'changeValue': changeValue,
      'changePercent': changePercent,
      'volume': volume,
      'marketCap': marketCap,
      'pe': pe,
      'eps': eps,
      'bookValue': bookValue,
      'week52High': week52High,
      'week52Low': week52Low,
      'lastUpdated': lastUpdated.toIso8601String(),
      'historicalData': historicalData.map((e) => e.toJson()).toList(),
      'analysis': analysis?.toJson(),
      'technicals': technicals?.toJson(),
      'fundamentals': fundamentals?.toJson(),
    };
  }
}

// Stock Analysis
class StockAnalysis {
  final SignalType recommendation;
  final double targetPrice;
  final double stopLoss;
  final double upside;
  final double confidenceScore;
  final String analyst;
  final String rationale;
  final DateTime analyzedAt;

  StockAnalysis({
    required this.recommendation,
    required this.targetPrice,
    required this.stopLoss,
    required this.upside,
    required this.confidenceScore,
    required this.analyst,
    required this.rationale,
    required this.analyzedAt,
  });

  factory StockAnalysis.fromJson(Map<String, dynamic> json) {
    return StockAnalysis(
      recommendation: SignalType.values.firstWhere(
        (e) => e.toString() == json['recommendation'],
        orElse: () => SignalType.hold,
      ),
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      upside: (json['upside'] ?? 0).toDouble(),
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      analyst: json['analyst'] ?? '',
      rationale: json['rationale'] ?? '',
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation.toString(),
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
      'upside': upside,
      'confidenceScore': confidenceScore,
      'analyst': analyst,
      'rationale': rationale,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

// Technical Indicators
class TechnicalIndicators {
  final double rsi;
  final double macd;
  final double sma20;
  final double sma50;
  final double sma200;
  final String trend;
  final List<String> signals;

  TechnicalIndicators({
    required this.rsi,
    required this.macd,
    required this.sma20,
    required this.sma50,
    required this.sma200,
    required this.trend,
    this.signals = const [],
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicators(
      rsi: (json['rsi'] ?? 0).toDouble(),
      macd: (json['macd'] ?? 0).toDouble(),
      sma20: (json['sma20'] ?? 0).toDouble(),
      sma50: (json['sma50'] ?? 0).toDouble(),
      sma200: (json['sma200'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'neutral',
      signals: List<String>.from(json['signals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rsi': rsi,
      'macd': macd,
      'sma20': sma20,
      'sma50': sma50,
      'sma200': sma200,
      'trend': trend,
      'signals': signals,
    };
  }
}

// Fundamental Analysis
class FundamentalAnalysis {
  final double roe;
  final double debtToEquity;
  final double currentRatio;
  final double dividendYield;
  final double profitGrowth;
  final double revenueGrowth;
  final String healthScore;

  FundamentalAnalysis({
    required this.roe,
    required this.debtToEquity,
    required this.currentRatio,
    required this.dividendYield,
    required this.profitGrowth,
    required this.revenueGrowth,
    required this.healthScore,
  });

  factory FundamentalAnalysis.fromJson(Map<String, dynamic> json) {
    return FundamentalAnalysis(
      roe: (json['roe'] ?? 0).toDouble(),
      debtToEquity: (json['debtToEquity'] ?? 0).toDouble(),
      currentRatio: (json['currentRatio'] ?? 0).toDouble(),
      dividendYield: (json['dividendYield'] ?? 0).toDouble(),
      profitGrowth: (json['profitGrowth'] ?? 0).toDouble(),
      revenueGrowth: (json['revenueGrowth'] ?? 0).toDouble(),
      healthScore: json['healthScore'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roe': roe,
      'debtToEquity': debtToEquity,
      'currentRatio': currentRatio,
      'dividendYield': dividendYield,
      'profitGrowth': profitGrowth,
      'revenueGrowth': revenueGrowth,
      'healthScore': healthScore,
    };
  }
}

// Global Market
class GlobalMarket {
  final String id;
  final String name;
  final String symbol;
  final String country;
  final String currency;
  final double currentPrice;
  final double changeValue;
  final double changePercent;
  final int volume;
  final DateTime lastUpdated;
  final bool isOpen;
  final List<PricePoint> historicalData;

  GlobalMarket({
    required this.id,
    required this.name,
    required this.symbol,
    required this.country,
    required this.currency,
    required this.currentPrice,
    required this.changeValue,
    required this.changePercent,
    required this.volume,
    required this.lastUpdated,
    required this.isOpen,
    this.historicalData = const [],
  });

  bool get isPositive => changePercent > 0;

  factory GlobalMarket.fromJson(Map<String, dynamic> json) {
    return GlobalMarket(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      country: json['country'] ?? '',
      currency: json['currency'] ?? 'USD',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      changeValue: (json['changeValue'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isOpen: json['isOpen'] ?? false,
      historicalData: (json['historicalData'] as List?)
              ?.map((e) => PricePoint.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'country': country,
      'currency': currency,
      'currentPrice': currentPrice,
      'changeValue': changeValue,
      'changePercent': changePercent,
      'volume': volume,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOpen': isOpen,
      'historicalData': historicalData.map((e) => e.toJson()).toList(),
    };
  }
}

// Trade Suggestion
class TradeSuggestion {
  final String id;
  final String stockSymbol;
  final String stockName;
  final SignalType action;
  final double entryPrice;
  final double targetPrice;
  final double stopLoss;
  final double potentialReturn;
  final RiskLevel riskLevel;
  final String timeframe;
  final String strategy;
  final List<String> reasons;
  final double successProbability;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final bool isActive;

  TradeSuggestion({
    required this.id,
    required this.stockSymbol,
    required this.stockName,
    required this.action,
    required this.entryPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.potentialReturn,
    required this.riskLevel,
    required this.timeframe,
    required this.strategy,
    this.reasons = const [],
    required this.successProbability,
    required this.generatedAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory TradeSuggestion.fromJson(Map<String, dynamic> json) {
    return TradeSuggestion(
      id: json['id'] ?? '',
      stockSymbol: json['stockSymbol'] ?? '',
      stockName: json['stockName'] ?? '',
      action: SignalType.values.firstWhere(
        (e) => e.toString() == json['action'],
        orElse: () => SignalType.hold,
      ),
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      potentialReturn: (json['potentialReturn'] ?? 0).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == json['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      timeframe: json['timeframe'] ?? '',
      strategy: json['strategy'] ?? '',
      reasons: List<String>.from(json['reasons'] ?? []),
      successProbability: (json['successProbability'] ?? 0).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockSymbol': stockSymbol,
      'stockName': stockName,
      'action': action.toString(),
      'entryPrice': entryPrice,
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
      'potentialReturn': potentialReturn,
      'riskLevel': riskLevel.toString(),
      'timeframe': timeframe,
      'strategy': strategy,
      'reasons': reasons,
      'successProbability': successProbability,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

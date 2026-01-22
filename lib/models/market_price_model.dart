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

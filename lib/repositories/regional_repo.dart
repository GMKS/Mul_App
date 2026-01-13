// regional_repo.dart
// Repository for regional content

import '../models/video_model.dart';

class RegionalRepo {
  // Add methods for fetching and managing regional data
}

class RegionalRepository {
  List<VideoModel> fetchRegionalVideos() {
    return [
      VideoModel(
        id: '1',
        title: 'Local Temple Festival',
        thumbnailUrl: '',
        distanceKm: 25,
        location: 'My Town',
      ),
      VideoModel(
        id: '2',
        title: 'Village Comedy Skit',
        thumbnailUrl: '',
        distanceKm: 120,
        location: 'Nearby District',
      ),
      VideoModel(
        id: '3',
        title: 'Regional News Clip',
        thumbnailUrl: '',
        distanceKm: 350,
        location: 'Same State',
      ),
    ];
  }
}

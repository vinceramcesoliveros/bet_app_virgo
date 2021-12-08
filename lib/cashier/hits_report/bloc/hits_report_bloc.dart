import 'package:bet_app_virgo/models/winning_hits.dart';
import 'package:bet_app_virgo/utils/http_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hits_report_event.dart';
part 'hits_report_state.dart';

class HitsReportBloc extends Bloc<HitsReportEvent, HitsReportState> {
  HitsReportBloc({STLHttpClient? httpClient})
      : _httpClient = httpClient ?? STLHttpClient(),
        super(HitsReportInitial()) {
    on<FetchHitReportsEvent>(_onFetch);
  }
  final STLHttpClient _httpClient;
  void _onFetch(FetchHitReportsEvent event, Emitter emit) async {
    emit(HitsReportLoading());
    final result = await _httpClient.get<List>("$adminEndpoint/winning-hits",
        queryParams: {}, onSerialize: (json) {
      return json['data'];
    });
    final draws = result.map((e) => WinningHitsResult.fromMap(e)).toList();
    emit(HitsReportLoaded(draws: draws, drawDate: event.dateTime));
  }
}

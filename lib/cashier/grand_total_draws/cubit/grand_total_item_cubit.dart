import 'package:bet_app_virgo/models/models.dart';
import 'package:bet_app_virgo/utils/http_client.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'grand_total_item_state.dart';

class GrandTotalItemCubit extends Cubit<GrandTotalItemState> {
  GrandTotalItemCubit({
    STLHttpClient? httpClient,
    required this.cashierId,
  })  : _httpClient = httpClient ?? STLHttpClient(),
        super(GrandTotalItemState());
  final STLHttpClient _httpClient;
  final String cashierId;

  Map<String, String> get cashierIdParam => {'filter[cashier_id]': cashierId};

  void fetchByDrawId(int id) async {
    emit(state.copyWith(
      isLoading: true,
    ));

    try {
      final result = await _httpClient.get(
        '$adminEndpoint/bets',
        queryParams: {
          'filter[draw_id]': id,
          ...cashierIdParam,
        },
        onSerialize: (json) =>
            (json['data'] as List).map((e) => BetResult.fromMap(e)).toList(),
      );
      emit(state.copyWith(items: result));
    } catch (e) {
      if (e is DioError) {
        final err = e.response?.statusMessage ?? e.message;
        emit(state.copyWith(error: "$err"));
      } else {
        emit(state.copyWith(error: "$e"));
      }
    }
  }
}

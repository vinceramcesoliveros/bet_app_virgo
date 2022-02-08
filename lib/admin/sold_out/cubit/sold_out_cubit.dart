import 'package:bet_app_virgo/utils/http_client.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../models/models.dart';

part 'sold_out_state.dart';

class SoldOutCubit extends Cubit<SoldOutState> {
  SoldOutCubit({required this.user, STLHttpClient? httpClient})
      : _http = httpClient ?? STLHttpClient(),
        super(SoldOutState());
  final STLHttpClient _http;
  final UserAccount user;
  Map<String, String> get _userParam => {
        'filter[show_all_or_not]': "${user.id},${user.type}",
      };
  void submit({
    required String number,
    required String type,
    String amount = '',
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _http.post('$adminEndpoint/${type}',
          queryParams: _userParam,
          body: {
            if (type == 'low-wins') ...{
              'winning_amount': int.parse(amount),
              'low_win_number': int.parse(number),
            } else
              'sold_out_number': int.parse(number),
          },
          onSerialize: (json) => BetSoldOut.fromMap(json));
      final newItems = state.items..add(result);
      emit(state.copyWith(
        items: newItems,
      ));
    } catch (e) {
      emit(state.copyWith(error: throwableDioError(e)));
      addError(e);
    }
  }

  void delete({
    bool soldOut = false,
    required int id,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      String endPoint = soldOut ? 'sold-outs' : 'low-wins';
      final result = await _http.delete(
        '$adminEndpoint/$endPoint/$id',
        queryParams: _userParam,
      );
      final newItems = state.items.where((e) => e.id != id).toList();
      emit(state.copyWith(items: newItems));
    } catch (e) {
      if (e is DioError) {
        final err = e.response?.statusMessage ?? e.message;
        emit(state.copyWith(error: err));
      } else {
        emit(state.copyWith(error: "$e"));
      }
      addError(e);
    }
  }

  void fetch() async {
    emit(state.copyWith(isLoading: true));
    try {
      final soldOuts = await _http.get('$adminEndpoint/sold-outs',
          onSerialize: (json) => (json['data'] as List)
              .map((e) => BetSoldOut.fromMap(e))
              .toList());
      final lowWins = await _http.get(
        '$adminEndpoint/low-wins',
        onSerialize: (json) =>
            (json['data'] as List).map((e) => BetSoldOut.fromMap(e)).toList(),
      );

      final newItems = [
        ...state.items,
        ...soldOuts,
        ...lowWins,
      ];
      emit(state.copyWith(items: newItems));
    } catch (e) {
      addError(e);

      emit(state.copyWith(error: throwableDioError(e)));
    }
  }
}

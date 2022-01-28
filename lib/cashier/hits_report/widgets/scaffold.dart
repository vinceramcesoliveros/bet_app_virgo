import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/hits_report_bloc.dart';
import 'builder.dart';

class HitReportsProvider extends StatelessWidget {
  const HitReportsProvider({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HitsReportBloc(),
      child: child,
    );
  }
}

class CashierHitScaffold extends StatelessWidget {
  static const path = "/cashier/hits";
  const CashierHitScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HitReportsProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Hits Report"),
          actions: [_RefreshHits()],
        ),
        body: _HitsBody(),
      ),
    );
  }
}

class _RefreshHits extends StatelessWidget {
  const _RefreshHits({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context.read<HitsReportBloc>().add(FetchHitReportsEvent(
                dateTime: DateTime.now(),
              ));
        },
        icon: Icon(Icons.refresh));
  }
}

class _HitsBody extends StatefulWidget {
  const _HitsBody({Key? key}) : super(key: key);

  @override
  State<_HitsBody> createState() => _HitsBodyState();
}

class _HitsBodyState extends State<_HitsBody> {
  @override
  void initState() {
    context.read<HitsReportBloc>().add(FetchHitReportsEvent(
          dateTime: DateTime.now(),
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HitsReportBloc>().add(FetchHitReportsEvent(
              dateTime: DateTime.now(),
            ));
      },
      child: Column(
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  _HitsReportDrawDateText(),
                  Spacer(),
                  HitsReportChangeDateButton(),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: _HitsTable(),
          ),
        ],
      ),
    );
  }
}

class _HitsTable extends StatelessWidget {
  const _HitsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HitsReportBuilder(
        onLoading: Center(child: CircularProgressIndicator.adaptive()),
        builder: (state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                rows: state.draws
                    .map((bet) => DataRow(cells: [
                          DataCell(Text("${bet.draw?.id}")),
                          DataCell(Text("${bet.draw?.winningCombination}")),
                          DataCell(Text("${bet.totalBetAmount}")),
                          DataCell(Text("${bet.id}")),
                          DataCell(Text("${bet.readablePrize}")),
                        ]))
                    .toList(),
                columns: [
                  DataColumn(label: Text("Draw")),
                  DataColumn(label: Text("Bet Number")),
                  DataColumn(label: Text("Bet Amount")),
                  DataColumn(label: Text("Doc No.")),
                  DataColumn(label: Text("Prize")),
                ],
              ),
            ),
          );
        });
  }
}

class HitsReportChangeDateButton extends StatelessWidget {
  const HitsReportChangeDateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final state = context.read<HitsReportBloc>().state;
        if (state is HitsReportLoaded) {
          final startDate = state.drawDate;

          final result = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: DateTime(2022),
            lastDate: DateTime.now(),
          );
          if (result != null) {
            context.read<HitsReportBloc>().add(
                  FetchHitReportsEvent(
                    dateTime: result,
                  ),
                );
          }
        }
      },
      child: Text("CHANGE DATE"),
    );
  }
}

class _HitsReportDrawDateText extends StatelessWidget {
  const _HitsReportDrawDateText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return HitsReportBuilder(
      builder: (state) {
        return Text(
            "Draw date: ${DateFormat('DD/MM/yyyy').format(state.drawDate)}",
            style: textTheme.subtitle2);
      },
    );
  }
}
